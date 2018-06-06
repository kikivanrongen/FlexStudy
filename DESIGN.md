# Design

## Structs

### Struct location
* Name: String
* Total seats: Int
* Available seats: Int
* opening hours: String
* studentID: Bool

### Struct activity
* location: String
* duration: Double
* date: Date
* day: String

## Classes

### Class locationViewController

#### Outlets
* searchTextfield: enter location to be searched
* filterButton: pop-up filter possibilities
#### Actions
* locationButtonPressed(): fetch information of pressed location
* searchTextfieldEdited(): call searchLocation()  and go to location that is pressed by the user
#### Variables
#### Functions
* getMap(): Set google maps
* updateUI(): configure start screen 
* searchLocation(): search for a UBA location and return matches
* filterLocation(): filter UBA locations on opening hours

### Class detailViewController

#### Outlets
* checkinButton
* checkoutButton
* seatsAvailableLabel
* totalSeatsLabel
* openingHoursLabel
* studentIdLabel
#### Actions
* checkinButtonPressed(): set check-in time and store in variable, disable button
* checkoutButtonPressed(): calculate study duration and redirect to progress view controller, enable checkinButton, store activity in activities via addActivity()
#### Variables
* time: tuple → stores check-in and check-out time
* activities: List of completed study activities of type ‘activity’
#### Functions
* updateUI(): configure information of chosen location, disable checkoutButton, set navigation title
* calculateDuration(): calculate difference between check-in and check-out time
* addActivity(): store activity in activities
* prepare(): redirect to progressViewController, activities

### Class progressViewController

#### Outlets
* dateLabel
* activityLabel
* graph
* storeButton
#### Actions
* storeButtonPressed(): prompt user for name and store the current activities list in Firebase
#### Variables
#### Functions
* updateUI(): set graph, set navigation title

## Advanced sketch

![alt text](https://github.com/kikivanrongen/FlexStudy/blob/master/doc/advanced%20sketch.png "Advanced Sketch")
