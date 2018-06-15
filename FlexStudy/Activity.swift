import Foundation
import FirebaseDatabase

// properties of a study activity
struct Activity {
    var location: String?
    var duration: Double?
    var date: String?
    
    let firebaseData: DatabaseReference = Database.database().reference()
    
    func addItem(userId: String, location: String, duration: Double, date: String) {
        firebaseData
            .child("users")
            .child(userId)
            .childByAutoId()
            .setValue(["location": location, "duration": duration, "date": date])
    }
    
    func removeItem(userId: String, activityId: String) {
        firebaseData
            .child("users")
            .child(userId)
            .child(activityId)
            .setValue(nil)
    }
}


