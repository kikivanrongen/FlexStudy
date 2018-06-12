import UIKit
import FBSDKLoginKit
import FirebaseAuth

class LogInViewController: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get fb login button
        let loginButton = FBSDKLoginButton()
        view.addSubview(loginButton)
        loginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32, height: 50)
        
        loginButton.delegate = self
        
        // create acces to email addresses
        loginButton.readPermissions = ["email", "public_profile"]

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
            
            print(result ?? "")
        }
        
        // store in database
        storeUserInFirebase()
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
            
            // go to location view controller
            self.performSegue(withIdentifier: "logInSegue", sender: self)
        })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
