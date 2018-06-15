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
    // MARK: Variables
    
    var ref: DatabaseReference = Database.database().reference()
    var activities = [Activity]()
    
    // MARK: Functions
    
    // enable editing
    func updateUI(){
        
        navigationItem.leftBarButtonItem = editButtonItem

    }
    
    // retrieve data of study activities of current user
    func fetchActivityData() {
        let uid = Auth.auth().currentUser!.uid
        
        ref.child("users").child(uid).observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                print(dictionary)
                let newActivity = Activity(location: dictionary["location"] as? String, duration: Double(dictionary["duration"] as! String), date: dictionary["date"] as? String)
                self.activities.append(newActivity)
                
                self.tableView.reloadData()
            }
        }, withCancel: nil)
        
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
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            activities.remove(at: indexPath.row) // overbodig
//            // REMOVE ITEM FROM FIREBASE
////            Activity.activities[indexPath.row].removeItem(userId: Auth.auth().currentUser!.uid, activityId: String)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//
//        }
//    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        fetchActivityData()
        updateUI()
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
