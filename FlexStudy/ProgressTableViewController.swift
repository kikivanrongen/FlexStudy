import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProgressViewCell: UITableViewCell {
    // MARK: Outlets
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
}

class ProgressTableViewController: UITableViewController {
    

    // MARK: Actions
    @IBAction func findFriendButtonTapped(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "friendsSegue", sender: nil)
    }
    
    // MARK: Variables
    
    var ref: DatabaseReference = Database.database().reference()
    let uid = Auth.auth().currentUser!.uid
    var activities = [Activity]()
//    var removedActivity: Activity? = nil
    var autoIds: [String:String] = [:]
    
    // MARK: Functions
    
    // enable editing
    func updateUI(){
        
        navigationItem.leftBarButtonItem = editButtonItem

    }
    
    // retrieve data of study activities of current user
    func fetchActivityData() {
        
        // observe events for added activity
        ref.child("users").child(uid).observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                print("---- ACTIVITIES ADDED ----")
                print(dictionary)
                let newActivity = Activity(location: dictionary["location"] as? String, duration: dictionary["duration"] as? Double, date: dictionary["date"] as? String, key: dictionary["key"] as? String)
                self.activities.append(newActivity)
                
                self.tableView.reloadData()
            }
        },withCancel: nil)
        
        // observe events for removed activity
        ref.child("users").child(uid).observe(.childRemoved, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                print("---- ACTIVITIES REMOVED ----")
                print(dictionary)
                let newActivity = Activity(location: dictionary["location"] as? String, duration: dictionary["duration"] as? Double, date: dictionary["date"] as? String, key: dictionary["key"] as? String)
                self.activities.append(newActivity)
                
                self.tableView.reloadData()
            }
        },withCancel: nil)
        
    }
    
    // store autoIds in local variable
//    func fetchAutoIds() {
//
//        ref.child("id's").observe(.childAdded) { (snapshot) in
//            if let dict = snapshot.value as? [String:String] {
//                for (key, value) in dict {
//                    print("key: \(key)")
//                    print("value: \(value)")
//                    self.autoIds[key] = value
//                    print(self.autoIds)
//                }
//            }
//        }
    
//        // observeSingleEvent??
//        ref.child("id's").observe(.value) { (snapshot) in
//            if let dict = snapshot.value as? [String:String] {
//                for (key, value) in dict {
//                    print("key: \(key)")
//                    print("value: \(value)")
//                    self.autoIds[key] = value
//                    print(self.autoIds)
//                }
//            }
//        }

//    }
    
    func removeItemFromDatabase(_ activity: Activity) {
        
        // get autoIds from detail view controller
//        let viewController = DetailViewController()
//        let autoIds = viewController.autoIds
        
        let key = activity.key
        
        // remove item in firebase
        self.ref.child("users").child(uid).child(key!).removeValue { (error, refer) in
            if error != nil {
                print(error ?? "")
            } else {
                print(refer)
                print("child removed correctly")
            }
        }
        
//        // iterate over autoIds dictionary
//        for (activityid, uuid) in autoIds {
//
//            // get location, duration and date of activity
//            ref.child("users").child(uuid).child(activityid).observeSingleEvent(of: .value, with: { (snapshot) in
//                print("-- IM HERE --")
//                if let dictionary = snapshot.value as? [String:AnyObject] {
//
//                    // store activity properties
//                    let location = dictionary["location"] as? String
//                    let duration = dictionary["duration"] as? Double
//                    let date = dictionary["date"] as? String
//
//                    // find removed activity in firebase
//                    if (location == self.removedActivity!.location! && duration == self.removedActivity!.duration! && date == self.removedActivity!.date!) {
//
//                        // remove item in firebase
//                        self.ref.child("users").child(uuid).child(activityid).removeValue { (error, refer) in
//                            if error != nil {
//                                print(error ?? "")
//                            } else {
//                                print(refer)
//                                print("child removed correctly")
//                            }
//                        }
//
//                    }
//                }
//            })
//        }
    }
    
    // create cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:
            "ActivityCellIdentifier", for: indexPath) as! ProgressViewCell
        
        let activity = activities[indexPath.row]
        cell.dateLabel?.text = activity.date!
        cell.durationLabel?.text = String(format: "%.2f", activity.duration!)
        cell.locationLabel?.text = activity.location!

        return cell
    }
    
    // set number of rows equal to number of activities
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }

    
    // enable deleting
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // remove deleted activity
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // update table view
            activities.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // acces database and remove
            removeItemFromDatabase(activities[indexPath.row])
            
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        fetchActivityData()
//        fetchAutoIds()
        updateUI()
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
