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
    let uid = Auth.auth().currentUser?.uid
    var activities = [Activity]()
    var autoIds: [String:String] = [:]
    
    // MARK: Functions
    
    // enable editing
    func updateUI(){
        
        navigationItem.leftBarButtonItem = editButtonItem

    }
    
    // retrieve data of study activities of current user
    func fetchActivityData() {

        
        // observe events for added activity
        ref.child("users").child(uid!).observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {

                // create new activity object for each fetched activity and store in list
                let newActivity = Activity(location: dictionary["location"] as? String, starttime: dictionary["starttime"] as? Date, duration: dictionary["duration"] as? String, date: dictionary["date"] as? String, key: dictionary["key"] as? String)
                self.activities.append(newActivity)

                self.tableView.reloadData()
            }
        }, withCancel: nil)
        
        // observe events for changed activity
        ref.child("users").child(uid!).observe(.childChanged, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                
                // iterate over activities
                var index = 0
                for item in self.activities {
                    
                    if item.key == dictionary["key"] as? String {
                        break
                    }
                    index += 1
                }
                
                // remove old activity from activities
                self.activities.remove(at: index)
                
                // append new activity with correct duration
                let newActivity = Activity(location: dictionary["location"] as? String, starttime: dictionary["starttime"] as? Date, duration: dictionary["duration"] as? String, date: dictionary["date"] as? String, key: dictionary["key"] as? String)
                
                self.activities.append(newActivity)
                
                self.tableView.reloadData()
            }

        },withCancel: nil)
        
    }
    
    // look for activity key infirebase and remove item
    func removeItemFromDatabase(_ activity: Activity) {

        let key = activity.key
        
        // remove activity in firebase
        self.ref.child("users").child(uid!).child(key!).removeValue { (error, refer) in
            if error != nil {
                print(error ?? "")
            } else {
                print("child removed correctly")
            }
        }
    }
    
    // MARK: Tableview functions
    
    // create cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:
            "ActivityCellIdentifier", for: indexPath) as! ProgressViewCell
        
        let activity = activities[indexPath.row]
        cell.dateLabel?.text = activity.date!
        
        // set content
        if activity.duration! == " " {
            cell.durationLabel?.text = ""
        } else {
            cell.durationLabel?.text = String(format: "%.2f", Double(activity.duration!)!)
        }
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

            let removedActivity = activities[indexPath.row]
            
            // update table view
            activities.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // acces database and remove
            removeItemFromDatabase(removedActivity)
            
        }
    }

    // MARK: Load functions
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    // fetch user activities and update user interface when loaded
    override func viewDidLoad() {
        fetchActivityData()
        updateUI()

        super.viewDidLoad()

    }
}
