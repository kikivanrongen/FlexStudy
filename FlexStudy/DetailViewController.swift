import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class DetailViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var availableSeatsLabel: UILabel!
    @IBOutlet weak var totalSeatsLabel: UILabel!
    @IBOutlet weak var openingHoursLabel: UILabel!
    @IBOutlet weak var studentIdLabel: UILabel!
    @IBOutlet weak var additionalInfoLabel: UILabel!
    
    @IBOutlet weak var checkinButton: UIButton!
    @IBOutlet weak var checkoutButton: UIButton!
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var popUpLabel: UILabel!
    
    // MARK: Actions
    
    // start activity
    @IBAction func checkinButtonPressed(_ sender: UIButton) {
        checkinButton.isEnabled = false
        checkinButton.backgroundColor = UIColor.lightGray
        
        starttime = Date()
        
        // update available seats in firebase and label
        response.availableSeats -= 1
        availableSeatsLabel.text = String(response.availableSeats)
        updateAvailableSeats()
    }
    
    // ask for confirmation
    @IBAction func checkoutButtonPressed(_ sender: UIButton) {
        
        // alert for end activity: update variables and store data
        let alert = UIAlertController(title: "Bevestig check-out", message: "Wil je je studie activiteit beëindigen?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ja", style: UIAlertActionStyle.default, handler: { action in
            
            self.checkoutButton.isEnabled = false
            self.checkinButton.isEnabled = true
            self.checkoutButton.backgroundColor = UIColor.lightGray
            self.checkinButton.backgroundColor = UIColor.blue
            
            self.elapsed = Date().timeIntervalSince(self.starttime!)
            self.elapsedHours = Double(self.elapsed) / 60
            
            // update available seats
            self.response.availableSeats += 1
            self.updateAvailableSeats()
            
            // store study activity
//            self.addActivity()
            
        }))
            
        alert.addAction(UIAlertAction(title: "Terug", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Variables
    
    var response: Location!
    var dateComponents = DateComponents()
    var starttime: Date?
    var elapsed: TimeInterval = 0
    var elapsedHours: Double = 0
    var locations: [Location]!
    
    var ref: DatabaseReference! = Database.database().reference()
    
    // MARK: Functions

    // store location data in firebase
    func storeLocationData() {
        for i in 0...(locations.count - 1) {
            
            // create Firebase reference for locations
            let locationStorage = ["name": locations[i].name, "available": String(locations[i].availableSeats),
            "total": String(locations[i].totalSeats)]
            
            self.ref.child("location").child(String(i)).setValue(locationStorage)
        }
    }
    
    // store activity with properties
    func addActivity() {

        let calendar = Calendar.current
        let day = calendar.component(.day, from: starttime!)
        let month = calendar.component(.month, from: starttime!)

        // create activity node
        let uid = Auth.auth().currentUser!.uid
        ref.child("users").child(uid).childByAutoId().setValue(["location": response.name, "duration": elapsedHours, "date": "\(day)/\(month)"])
        
    }
    
    // retrieve data of study activities of current user
    func fetchActivityData() {
        let uid = Auth.auth().currentUser!.uid
        
        ref.child("users").child(uid).observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                print(dictionary)
            }
        }, withCancel: nil)

    }
    
    // configure start screen
    func updateUI() {
        
        // set labels with text
        navigationItem.title = response.name
        availableSeatsLabel.text = String(response.availableSeats)
        totalSeatsLabel.text = String(response.totalSeats)
        openingHoursLabel.text = response.openingHours
        
        if response.studentId == true {
            studentIdLabel.isHidden = false
            additionalInfoLabel.isHidden = false
        }
            
        else {
            studentIdLabel.isHidden = true
            additionalInfoLabel.isHidden = true
        }
        
        checkinButton.isEnabled = true
        checkoutButton.isEnabled = true
        checkinButton.backgroundColor = UIColor.blue
        checkoutButton.backgroundColor = UIColor.blue

    }
    
    func updateAvailableSeats() -> Void {
        
        var handle: DatabaseHandle?
        
        // get reference
        for i in 0...(locations.count - 1){
            
            handle = ref.child("location").child(String(i)).child("name").observe(.value, with: { (snapshot) in
                
                let value = snapshot.value as? String
                
                if let actualValue = value {
                    if actualValue == self.response.name {
                        self.ref.child("location").child(String(i)).updateChildValues(["available": self.response.availableSeats])
                    }
                }
            })
    
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
//        storeLocationData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
