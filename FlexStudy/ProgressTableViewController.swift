import UIKit


class ProgressViewCell: UITableViewCell {
    // MARK: Outlets
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
}

class ProgressTableViewController: UITableViewController {
    

    // MARK: Actions
    // MARK: Variables

    
    // MARK: Functions
    
    // enable editing
    func updateUI(){
        
        navigationItem.leftBarButtonItem = editButtonItem

    }
    
    // create cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:
            "ActivityCellIdentifier", for: indexPath) as! ProgressViewCell
        
        let activity = Activity.activities[indexPath.row]
        cell.dateLabel?.text = activity.date
        cell.durationLabel?.text = String(format: "%.2f", activity.duration)
        cell.locationLabel?.text = activity.location

        return cell
    }
    
    // set number of rows equal to number of activities
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Activity.activities.count
    }

    
    // enable deleting
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // remove deleted activity
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Activity.activities.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)

        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {

        updateUI()
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
