import UIKit
import FirebaseAuth
import FirebaseDatabase
import GoogleMaps

class FriendsViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchFriends: UISearchBar!
    
    // MARK: Variables
    
    var ref: DatabaseReference = Database.database().reference()
    var users: [String:String] = [:]
    
    // properties of chosen user and last activity
    var emailFriend: String?
    var lastLocation: String?
    var duration: AnyObject?
    
    // create new GMSMarker for friend location
    var newMarker = GMSMarker()
    
    // set current day and month
    let date = Date()
    let calendar = Calendar.current
    
    // MARK: Functions
    
    // store users in dict as [e-mail address : primary key]
    func fetchUsers() {
        
        // retrieve mail addresses and primary keys of users in firebase
        ref.child("email addresses").observe(.value) { (snapshot) in
            if let dict = snapshot.value as? [String:String] {
                for (key, value) in dict {
                    self.users[key] = value
                }
            }
        }

    }
    
    // fetch the last activity of a user
    func fetchLastActivity(friendId: String) {
        
        let currentDay = calendar.component(.day, from: date)
        let currentMonth = calendar.component(.month, from: date)
        
        // find activities
        ref.child("users").child(friendId).observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                
                let child = (child as! DataSnapshot).value as! [String:AnyObject]
                print("child: \(child)")
                
                // check for activities at current date
                if child["date"] as? String == "\(currentDay)/\(currentMonth)" {
                    
                    // store activity if found
                    self.lastLocation = child["location"] as? String
                    self.duration = child["duration"]
                    
                    // alert user with last activity
                    self.alertUser()
                    break // return?
                
                }
            }
                
            // alert user that no activities have been made today
            let alert = UIAlertController(title: "Helaas!", message: "Je vriend \(self.emailFriend ?? "") heeft vandaag nog niet bij een UBA locatie ingecheckt", preferredStyle: UIAlertControllerStyle.alert)

            // add return button
            alert.addAction(UIAlertAction(title: "Oke", style: UIAlertActionStyle.cancel, handler: nil))

            self.present(alert, animated: true, completion: nil)
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
        
        // check if user is currently checked in
        if duration as? String == " " {
            
            let alert = UIAlertController(title: "Gevonden!", message: "Je vriend \(emailFriend ?? "") is op het moment ingecheckt bij \(lastLocation ?? "")", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ga naar map", style: UIAlertActionStyle.cancel, handler: { action in
                
                // update location marker with friend location
                self.performSegue(withIdentifier: "unwindToLocations", sender: nil)
                
            }))
            
            present(alert, animated: true, completion: nil)
            
            // delay alert with 5 seconds
//            let when = DispatchTime.now() + 5
//            DispatchQueue.main.asyncAfter(deadline: when){
//                alert.dismiss(animated: true, completion: nil)
//            }
            

        
        // otherwise present last activity
        } else {
            
            // convert duration to string format
//            let durationString = String(format: "%.2f", Double(duration as! NSNumber))
            
            let alert = UIAlertController(title: "Gevonden!", message: "Je vriend \(emailFriend ?? "") heeft vandaag ingecheckt bij \(lastLocation ?? "")", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Oke", style: UIAlertActionStyle.cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    // set new marker and pass on to location view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToLocations" {
            let locationVC = segue.destination as! LocationViewController
            let locations = locationVC.locations
            
            // store address, latitude and longitude for friend's location
            var address: String!
            var lat: CLLocationDegrees!
            var long: CLLocationDegrees!
            
            // iterate over locations
            for location in locations {
                if location.name == lastLocation {
                    address = location.address
                    lat = location.lat
                    long = location.long
                }
            }
            
            // set marker properties
            newMarker.position = CLLocationCoordinate2DMake(lat, long)
            newMarker.title = lastLocation
            newMarker.snippet = "\(address!) \n \(emailFriend ?? "")"
            newMarker.icon = GMSMarker.markerImage(with: .green)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
