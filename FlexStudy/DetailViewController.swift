import UIKit
import Firebase
import FirebaseDatabase

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
    
    // start activity, update variables and disable check in button
    @IBAction func checkinButtonPressed(_ sender: UIButton) {
        checkinButton.isEnabled = false
        checkinButton.backgroundColor = UIColor.lightGray
        
        starttime = Date()
        
        response.availableSeats -= 1
        availableSeatsLabel.text = String(response.availableSeats)
    }
    
    // ask for confirmation
    @IBAction func checkoutButtonPressed(_ sender: UIButton) {
        popUpView.isHidden = false
    }
    
    // update variables, close pop up and store activity
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        checkoutButton.isEnabled = false
        checkinButton.isEnabled = true
        checkoutButton.backgroundColor = UIColor.lightGray
        
        elapsed = Date().timeIntervalSince(starttime!)
        
        popUpView.isHidden = true
        
        addActivity()
        
        // go to progress view controller
        performSegue(withIdentifier: "ConfirmSegue", sender: nil)
    }
    
    // return to info screen
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        popUpView.isHidden = true
    }
    
    // MARK: Variables
    
    var response: Location!
    var dateComponents = DateComponents()
    var activities = [Activity]()
    var starttime: Date?
    var elapsed: TimeInterval = 0
    var locations: [Location]!
    
    var ref: DatabaseReference! = Database.database().reference()
    
    func storeLocationData() {
        for i in 0...(locations.count - 1) {
            
            // create Firebase reference for locations
            let locationStorage = ["name": locations[i].name, "available": String(locations[i].availableSeats),
            "total": String(locations[i].totalSeats)]
            
            self.ref.child("location").child(String(i)).setValue(locationStorage)
        }
    }
    
    // MARK: Functions
    
    // store activity in list when check-out button is pressed
    func addActivity() {
    
        let calendar = Calendar.current
        let day = calendar.component(.day, from: starttime!)
        let month = calendar.component(.month, from: starttime!)
        
        let newActivity = Activity(location: response.name, duration: elapsed , date: "\(day)/\(month)")
        
        activities.append(newActivity)

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
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConfirmSegue" {
            let progressTableViewController = segue.destination as! ProgressTableViewController
            progressTableViewController.progress = activities
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        storeLocationData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
