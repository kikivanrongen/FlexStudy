import UIKit
import FirebaseAuth
import FirebaseDatabase

class FriendsViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchFriends: UISearchBar!
    
    var ref: DatabaseReference = Database.database().reference()
    var users: [String:String] = [:]
    
    // properties of chosen user and last activity
    var emailFriend: String?
//    var idFriend: String?
    var lastLocation: String?
    var duration: String?
    
    // set current day and month
    let date = Date()
    let calendar = Calendar.current
    
    // store users in dict as [e-mail address : primary key]
    func fetchUsers() {
        
        // retrieve mail addresses and primary keys of users in firebase
        ref.child("email addresses").observe(.value) { (snapshot) in
            if let dict = snapshot.value as? [String:String] {
                for (key, value) in dict {
                    self.users[key] = value
                    print(self.users)
                }
            }
        }

    }
    
    // fetch the last activity of a user
    func fetchLastActivity(friendId: String) {
        
        let currentDay = calendar.component(.day, from: date)
        let currentMonth = calendar.component(.month, from: date)
        print("\(currentDay)/\(currentMonth)")
        
        // find activities
        ref.child("users").child(friendId).observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let child = (child as! DataSnapshot).value as! [String:AnyObject]
                
                print(child)
                
                // check for activities at current date
                if child["date"] as? String == "\(currentDay)/\(currentMonth)" {
                    
                    print("--- IM HERE ----")
                    
                    // store activity if found
                    self.lastLocation = child["location"] as? String
                    self.duration = child["duration"] as? String
                    
                    self.alertUser()
                    
                }
                
                // alert user that no activities have been made today
                else {
                    print("no activities yet today")
                }
            }
        }
            
    }
    
    // search user accounts for typed in friend
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // iterate over emails and ids
        for (id, email) in users {
            
            // check if typed in user corresponds with email address of a user in the database
            if searchFriends.text! == email {
                
                // store email
                emailFriend = email

                // find last activity
                fetchLastActivity(friendId: id)
            }
                
            else {
                
                // alert user not found
                let alert = UIAlertController(title: "Gebruiker niet gevonden", message: "Het gekozen e-mail adres bestaat niet of is fout ingetypt. Probeer het nog eens.", preferredStyle: UIAlertControllerStyle.alert)
                
                // add return button
                alert.addAction(UIAlertAction(title: "Oke", style: UIAlertActionStyle.cancel, handler: nil))
                
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // message user with last activity of a friend
    func alertUser() {
        
        let alert = UIAlertController(title: "Gevonden!", message: "Je vriend \(emailFriend ?? "") heeft vandaag ingecheckd bij \(lastLocation ?? "") met een duur van \(duration ?? "") uur", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Oke", style: UIAlertActionStyle.cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
