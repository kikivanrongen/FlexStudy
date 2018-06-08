import UIKit
import GoogleMaps

class LocationViewController: UIViewController, GMSMapViewDelegate {
    
    // MARK: Outlets
    
    // MARK: Actions
    
    // MARK: Variables
    
    var mapView: GMSMapView?
    var chosenLocation: Location?
    
    // object with UBA locations information
    var locations: [Location] = [
        
        Location(name: "Universiteitsbibliotheek Singel", address: "Singel 425", lat: 52.367734, long: 4.889741, openingHours: "08:30 - 23:45" , totalSeats: 702, availableSeats: 702, studentId: true),
        Location(name: "PC Hoofthuis", address: "Spuistraat 134", lat: 52.373598, long: 4.889595, openingHours: "09:00 - 18:00", totalSeats: 385, availableSeats: 385, studentId: false),
        Location(name: "Bushuis", address: "Kloveniersburgwal 48", lat: 52.370870, long: 4.898021, openingHours: "08:00 - 20:00", totalSeats: 50, availableSeats: 50, studentId: false),
        Location(name: "Library Learning Centre Roeterseilandcampus", address: "Roetersstraat 11", lat: 52.363580, long: 4.910951, openingHours: "08:30 - 22:00", totalSeats: 757, availableSeats: 757, studentId: true),
        Location(name: "Cedla", address: "Roetersstraat 33", lat: 52.362216, long: 4.911436, openingHours: "10:00 - 17:00", totalSeats: 20, availableSeats: 20, studentId: false),
        Location(name: "Juridische Bibliotheek", address: "Nieuwe Achtergracht 166", lat: 52.362957, long: 4.912404, openingHours: "09:00 - 21:00", totalSeats: 126, availableSeats: 0, studentId: false),
        Location(name: "Learning Space A0/BC1/A1", address: "Nieuwe Achtergracht 166", lat: 52.362816, long: 4.912702, openingHours: "08:00 - 22:00", totalSeats: 811, availableSeats: 811, studentId: false),
        Location(name: "Science Park", address: "Science Park 904", lat: 52.355312, long: 4.954016, openingHours: "08:00 - 22:00", totalSeats: 543, availableSeats: 0, studentId: false),
        Location(name: "Medische Bibliotheek AMC", address: "Meibergdreef 9", lat: 52.294767, long: 4.957973, openingHours: "08:30 - 21:45", totalSeats: 294, availableSeats: 294, studentId: false),
        Location(name: "Tandheelkunde (ACTA)", address: "Gustav Mahlerlaan 3004", lat: 52.336300, long: 4.861460, openingHours: "08:30 - 17:00", totalSeats: 25, availableSeats: 25, studentId: false)
        
    ]
    
    // MARK: Functions
    
    // configure start UI
    func updateUI() {
        
        // create camera position and mapview
        let camera = GMSCameraPosition.camera(withLatitude: 52.367734, longitude: 4.889741, zoom: 14)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        
        // set view
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        self.view = mapView
        
        // add markers to mapview
        for location in locations {
        
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(location.lat, location.long)
            marker.title = location.name
            marker.snippet = location.address
            marker.map = mapView
        
        }
    }
    
    // GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        // determine chosen location
        for location in locations {
            if marker.title == location.name {
                chosenLocation = location
            }
        }
        
        // go to detail view controller
        performSegue(withIdentifier: "DetailSegue", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.response = chosenLocation!
            detailViewController.locations = locations
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
