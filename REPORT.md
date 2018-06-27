# Description
This app allows students to check-in and check-out at study locations of the UvA, track study activities and find study friends at other locations.

<img src=https://github.com/kikivanrongen/FlexStudy/blob/master/doc/Scherm2.png width="170" height="290" />

# Technical design
When the user opens the app the log in screen is presented. The app allows the user to login via facebook. However, if the current user has already opened the app previously, the user is prompted with an alert. This alert suggests whether he would like to proceed with the currently signed in user at facebook. When the user has logged in with a facebook account the screen redirects to the 'location view controller'. 

The 'location view controller' is the start of the tab bar controller that is divided in 'location' and 'progress', show below in the tab bar. In the location controller a map is presented with markers for all UBA locations of the UvA. A logout button is also available at the navigation bar, if the user wishes to sign in with a different account. Clicking on a particular marker shows an infowindow with the name of that location and the address. When the user taps on the infowindow it will be redirected to the 'detail view controller'. 

The 'detail view controller' contains information regarding the clicked location. It shows how many study places there are available of the total, opening hours and additional information (if required). Two buttons are displayed at the bottom for check-in and check-out. These buttons are updated every time the user is directed to the detail view controller. Meaning, when the user is already checked in at the location, the checkin button is disabled and only check out is possible (and the other way around). If the check in button is pressed an activity is started and send to the online database. When the check out button is pressed, the duration is set and stored again in the database. 

Now we can move in with the second part of the tab bar controller: progress. As mentioned before the user is able to track its study activities. When it is interested in its progress or whether it is already checked in somewhere it can click on the 'progress' icon at the bottom. Redirecting to progress table view controller, the name says it already, is a table. This table includes the date, location and duration (if the activity is ended) of a study activity. In the navigation bar a button is presented called 'find friends'. When the user taps on this button it is redirected to the 'friends view controller'.

Within the 'friends view controller' is a search bar. Here the user can type in the email address of a friend. The computer will look inside the 'users' node of the database for the typed in email address and two options are possible:

1) Either the email address is incorrectly spelled or the user is not known in the database
2) the email address is in the database and the computer proceeds with finding the a study activity of this friend/user

The computer will now set the current date and check whether the friend is currently checked-in at a location or has ended an activity at the current date. In the first case, the user is presented with an alert that his friend is currently checked in at ... location and can click on a button that unwinds to the 'location view controller'. The 'location view controller' will now show a green marker at that location with an info window that displays the friend's email address. In the second case the user is alerted with today's ended activity of his friend. In the case that no acitivity has yet been started or ended by his friend, the user is also alerted with a 'sorry no activities today of ...' message. This search method builds on the fact that users will only be interested where friends are at the present time, so that they can meet.

# Detail design
## Log in view controller
In the viewDidAppear function the program checks for currentUser being equal to nil. If this is not the case, the user is alerted with the question whether it wants to login with the currently known email address. If so it is immediately directed to 'location view controller'.
Otherwise, the user must log in via the built-in facebook button. Facebook asks permission for email and public profile and if accepted the user is logged in and redirected to the 'location view controller'.

## Location view controller
The locations have been manually set in a list and are all stored in firebase once (first time you run the program). Each location is of a struct 'Location' containing: name, address, latitude, longitude, opening hours, total seats, available seats and studentID (boolean). For every location a marker is created in the updateUI() function and all these markers are again stored in a list. The markers are then showed on the map via the showMarkers() function. Clicking on a marker triggers the info window to pop up and clicking the infowindow redirects the user to the next view controller (mapview function, built-in google maps function). The chosen location is stored in a variable and is passed on to the screen (detail view controller), as well as the list of locations.

The log out button at the top logs out the user using FacebookLoginManager and unwinds to the 'log in view controller'.

## Detail view controller
This screen displays the information of the variable 'chosenLocation'. First, the  are set

 

