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
        popUpView.isHidden = false
    }
    
    // end activity: update variables and store data
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        checkoutButton.isEnabled = false
        checkinButton.isEnabled = true
        checkoutButton.backgroundColor = UIColor.lightGray
        
        elapsed = Date().timeIntervalSince(starttime!)
        elapsedHours = Double(elapsed) / 60
        
        // update available seats
        response.availableSeats += 1
        updateAvailableSeats()
        
        // close pop-up
        popUpView.isHidden = true
        
        // store study activity
        addActivity()
        
    }
    
    // return to info screen
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        popUpView.isHidden = true
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
    
    func signIn() {
        
        Auth.auth().signInAnonymously() { (authResult, error) in
            if let error = error {
                return
            }
        }

//        let user = authResult.user
//        let isAnonymous = user.isAnonymous  // true
//        let uid = user.uid
        
    }

    // store location data in firebase
    func storeLocationData() {
        for i in 0...(locations.count - 1) {
            
            // create Firebase reference for locations
            let locationStorage = ["name": locations[i].name, "available": String(locations[i].availableSeats),
            "total": String(locations[i].totalSeats)]
            
            self.ref.child("location").child(String(i)).setValue(locationStorage)
        }
    }
    
    // store activity in list when check-out button is pressed
    func addActivity() {
    
        let calendar = Calendar.current
        let day = calendar.component(.day, from: starttime!)
        let month = calendar.component(.month, from: starttime!)
        
        let newActivity = Activity(location: response.name, duration: elapsedHours , date: "\(day)/\(month)")
        
        Activity.activities.append(newActivity)
        
//        self.ref.child("users").childByAutoId().child("study activities").setValue()

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
        popUpView.isHidden = true
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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
