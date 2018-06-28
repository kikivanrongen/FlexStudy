import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase

class LogInViewController: UIViewController, FBSDKLoginButtonDelegate {
 
    // MARK: Variables
    
    var ref: DatabaseReference!
    var mailStorage: [String:String] = [:]
    
    // MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create database reference
        ref = Database.database().reference()
        
        // set background image
        let imgView =  UIImageView(frame: self.view.frame)
        let img = UIImage(named: "stars")
        imgView.image = img
        imgView.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height)
        imgView.contentMode = UIViewContentMode.scaleAspectFill
        view.addSubview(imgView)
        
        // get fb login button
        let loginButton = FBSDKLoginButton()
        view.addSubview(loginButton)
        loginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32, height: 50)
        
        loginButton.delegate = self
        
        // create acces to email addresses
        loginButton.readPermissions = ["email", "public_profile"]

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // check if user is already logged in
        if let _ = Auth.auth().currentUser {
            
            // ask user to check-in with currently known email address
            let email = Auth.auth().currentUser!.email
            
            let alert = UIAlertController(title: "Facebook Log-in", message: "Wil je inloggen met het e-mailadres \(email ?? "")?", preferredStyle: UIAlertControllerStyle.alert)
            
            // go to next view controller if email address is correct
            alert.addAction(UIAlertAction(title: "Ja", style: UIAlertActionStyle.default, handler: { action in
                self.performSegue(withIdentifier: "logInSegue", sender: self)
            }))
            
            // log out user
            alert.addAction(UIAlertAction(title: "Nee", style: UIAlertActionStyle.cancel, handler: { action in
                let manager: FBSDKLoginManager = FBSDKLoginManager()
                manager.logOut()
                
                // clear token and profile --> NECESSARY??
                FBSDKAccessToken.setCurrent(nil)
                FBSDKProfile.setCurrent(nil)
            }))
            
            self.present(alert, animated: true, completion: nil)

        }
    }
    
    // log out of facebook
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
    // log in to facebook
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
    
        print("succesfully logged in ...")
        
        // start graph request
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start {
            (connection, result, err) in
            if err != nil {
                print("failed to start graph request:", err ?? "")
                return
            }
            
            if let _ = result {
                
                // store in database
                self.storeUserInFirebase()
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "logInSegue", sender: self)
                }
            }
            print(result ?? "")
        }

    }
    
    func storeUserInFirebase() {
        
        // store user in firebase
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        // ensure authentication for logging in
        Auth.auth().signInAndRetrieveData(with: credential, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with FB user", error ?? "")
                return
            }
            
            print("succesfully logged in the user: ", user ?? "")
            
            // get email and user id from logged in user
            let email = Auth.auth().currentUser?.email
            let uid = Auth.auth().currentUser?.uid
            
            // store in seperate node in firebase
            self.mailStorage = [uid!:email!]
            self.ref.child("email addresses").setValue(self.mailStorage)

            
        })

    }
    
    // unwind segue from location view controller
    @IBAction func unwindLogIn (_ sender: UIStoryboardSegue){

    }
}
