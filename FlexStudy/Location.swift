import Foundation
import GoogleMaps

// information of a UBA location
struct Location {
    var name: String
    var address: String
    var lat: CLLocationDegrees
    var long: CLLocationDegrees
    var openingHours: String
    var totalSeats: Int
    var availableSeats: Int
    var studentId: Bool
}
