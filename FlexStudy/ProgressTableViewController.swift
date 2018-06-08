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
    
    var progress: [Activity]!
    
    // MARK: Functions
    
    // enable editing
    func updateUI(){

        navigationItem.leftBarButtonItem = editButtonItem
        
    }
    
    // create cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:
            "ActivityCellIdentifier", for: indexPath) as! ProgressViewCell
        
        let activity = progress[indexPath.row]
        cell.dateLabel?.text = activity.date
        cell.durationLabel?.text = String(activity.duration)
        cell.locationLabel?.text = activity.location
        
//        configure(cell: cell, forItemAt: indexPath)
        return cell
    }
    
//    func configure(cell: UITableViewCell, forItemAt indexPath:
//        IndexPath) {
//        
//        // insert text in cells
//
//
//    }
    
    // set number of rows equal to number of activities
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return progress.count
    }

    
    // enable deleting
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // remove deleted activity
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            progress.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)

        }
    }

    
    override func viewDidLoad() {

        updateUI()
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
