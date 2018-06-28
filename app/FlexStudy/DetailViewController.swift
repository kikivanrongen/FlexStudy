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
    
    @IBOutlet weak var checkinButton: UIButton!
    @IBOutlet weak var checkoutButton: UIButton!
    
    // MARK: Actions
    
    // start activity
    @IBAction func checkinButtonPressed(_ sender: UIButton) {
        
        // pulse animation
        sender.pulsate()
        
        // disable checkin and enable checkout button
        updateButtons()
        
        // set start time
        let starttime = Date()
        
        // find index of chosen location
        var index = 0
        for i in 0...(self.locations.count - 1){
            if self.locations[i].name == self.response.name {
                index = i
            }
        }
        
        // update available seats of location
        self.ref.child("location").child(String(index)).runTransactionBlock({ (data) -> TransactionResult in
            if var location = data.value as? [String:AnyObject] {
                var seats = location["available"] as? Int
                seats! -= 1
                location["available"] = seats as AnyObject
                data.value = location
                return TransactionResult.success(withValue: data)
            }
            return TransactionResult.success(withValue: data)
        })
        
        // store activity in database
        addActivity(start: starttime)
    }
    
    // ask for confirmation
    @IBAction func checkoutButtonPressed(_ sender: UIButton) {
        
        // pulse animation
        sender.pulsate()
        
        // alert for end activity: update variables and store data
        let alert = UIAlertController(title: "Bevestig check-out", message: "Wil je je studie activiteit beëindigen?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ja", style: UIAlertActionStyle.default, handler: { action in
            
            // get key of ended activity and retrieve starttime when completed
            self.ref.child("users").child(self.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                var key: String?
                
                // iterate over childs (activities of the user)
                for child in snapshot.children {
                    
                    let child = (child as! DataSnapshot).value as! [String:AnyObject]
                    
                    // store key in variable if location and duration matches requirements
                    if child["location"] as? String == self.response.name && child["duration"] as? String == " " {
                        key = child["key"] as? String
                        break
                    }
                }
                
                // retrieve starttime from chosen activity to be ended
                self.ref.child("users").child(self.uid).child(key!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String:AnyObject] {
                        
                        // determine endtime
                        let starttime = dictionary["starttime"] as? String
                        self.setEndtime(start: starttime!, key: key!)
                        
                    }
                }, withCancel: nil)
                
            }, withCancel: nil)
            
            // find index of chosen location
            var index = 0
            for i in 0...(self.locations.count - 1){
                if self.locations[i].name == self.response.name {
                    index = i
                }
            }
            
            // update available seats of location
            self.ref.child("location").child(String(index)).runTransactionBlock({ (data) -> TransactionResult in
                if var location = data.value as? [String:AnyObject] {
                    var seats = location["available"] as? Int
                    seats! += 1
                    location["available"] = seats as AnyObject
                    data.value = location
                    return TransactionResult.success(withValue: data)
                }
                return TransactionResult.success(withValue: data)
            })
            
            // disable checkout and enable checkin button
            self.updateButtons()
            
        }))
            
        alert.addAction(UIAlertAction(title: "Terug", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Variables
    
    var response: Location!
    var dateComponents = DateComponents()
    var locations: [Location]!
    var available: [String:String] = [:]
    
    // get current logged in user
    let uid = Auth.auth().currentUser!.uid
    
    // create databse reference
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
    func addActivity(start: Date) {

        // format date object to string for firebase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let time = dateFormatter.string(from: start)
        
        // get day and month from date object
        let calendar = Calendar.current
        let day = calendar.component(.day, from: start)
        let month = calendar.component(.month, from: start)

        // get autoID
        let reference = ref.child("users").child(uid).childByAutoId()
        
        // create activity node
        ref.child("users").child(uid).child(reference.key).setValue(["location": response.name, "starttime": time, "duration": " ", "date": "\(day)/\(month)", "key": reference.key])
        
    }
    
    // determine end time of activity
    func setEndtime(start: String, key: String) {
        
        // format starttime (string) to correct date format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let date = dateFormatter.date(from: start) else {
            fatalError("ERROR: Date conversion failed due to mismatched format.")
        }
        
        // calculate duration of activity
        let elapsed = Date().timeIntervalSince(date)
        print("elapsed: \(elapsed)")
        let elapsedHours = Double(elapsed) / 3600
        
        // set in database
        ref.child("users").child(uid).child(key).updateChildValues(["duration": String(elapsedHours)])
        
    }
    
    // configure start screen
    func updateUI() {
        
        // set labels with text
        navigationItem.title = response.name
        let seats = available[response.name]
        availableSeatsLabel.text = seats
        
        totalSeatsLabel.text = String(response.totalSeats)
        openingHoursLabel.text = response.openingHours
        
        // view additional information for location if required
        if response.studentId == true {
            studentIdLabel.isHidden = false
        }
            
        else {
            studentIdLabel.isHidden = true
        }
        
        // set layout for buttons
        
        // border color
        checkinButton.layer.borderColor = UIColor(red:1.00, green:0.76, blue:0.97, alpha:1.0).cgColor
        checkoutButton.layer.borderColor = UIColor(red:1.00, green:0.76, blue:0.97, alpha:1.0).cgColor
        
        // round borders
        checkinButton.layer.cornerRadius = 20
        checkinButton.layer.borderWidth = 1
        checkoutButton.layer.cornerRadius = 20
        checkoutButton.layer.borderWidth = 1
        
    }
    
    // create dict of location and corresponding available seats
    func fetchAvailableSeats() {
        
        // get values of location data
        ref.child("location").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // iterate over childs
            for child in snapshot.children {

                let child = (child as! DataSnapshot).value as! [String:AnyObject]

                // determine name and seats, store in dict
                let name = child["name"] as? String
                let seats = child["available"] as? Int
                self.available[name!] = String(seats!)
            
            }
            
            // set user interface
            self.updateUI()
            self.updateButtons()
            
        }, withCancel: nil)
        
        // observe check-in and check-out events
        ref.child("location").observe(.childChanged, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                
                // update availability
                let name = dictionary["name"] as? String
                let seats = dictionary["available"] as? Int
                self.available[name!] = String(seats!)
                
            }

            self.updateUI()
            
        }, withCancel: nil)

    }
    
    // update check-in and check-out buttons according to activity
    func updateButtons() {
        
        // check if there are seats available
        if response.availableSeats == 0 {
            checkinButton.isEnabled = false
            checkoutButton.isEnabled = false
        }
        
        else {
        
            // check if user is already checked in at location
            ref.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                
                // iterate over activities
                for child in snapshot.children {
                    
                    let child = (child as! DataSnapshot).value as! [String:AnyObject]
                    
                    // check for clicked marker location and empty duration variable, update buttons
                    if child["location"] as? String == self.response.name && child["duration"] as? String == " " {
                        self.checkinButton.isEnabled = false
                        self.checkoutButton.isEnabled = true
                        self.checkinButton.setTitleColor(.lightGray, for: .normal)
                        self.checkoutButton.setTitleColor(.black, for: .normal)
                        
                    } else {
                        self.checkinButton.isEnabled = true
                        self.checkoutButton.isEnabled = false
                        self.checkinButton.setTitleColor(.black, for: .normal)
                        self.checkoutButton.setTitleColor(.lightGray, for: .normal)
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAvailableSeats()
        
        // store UBA locations in firebase
        // uncomment this block the first time you are running this program
//        storeLocationData()
    }
}
