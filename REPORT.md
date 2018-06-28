# Description
This app allows students to check-in and check-out at study locations of the UvA, track study activities and find study friends at other locations.

<img src=https://github.com/kikivanrongen/FlexStudy/blob/master/doc/Scherm2.png "App start screen" "width="170" height="290" />

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
Otherwise, the user must log in via the built-in facebook button. Facebook asks permission for email and public profile and if accepted the user is logged in, stored in firebase via storeUserInFirebase() and redirected to the 'location view controller'. The storeUserInFirebase function sets the current acces token and creates the user in the database. it can then be found under 'authentication'. Another node is also created called 'email addresses' in which users are stores as [user id : email address]. This is necessary for the find friends function that will be explained later on. The Log In View Controller also contains an IBAction for the unwind segue from the logout button in location view controller.

## Location view controller
The locations have been manually set in a list and are all stored in firebase once (first time you run the program). Each location is of a struct 'Location' containing: name, address, latitude, longitude, opening hours, total seats, available seats and studentID (boolean). For every location a marker is created in the updateUI() function and all these markers are again stored in a list. The markers are then showed on the map via the showMarkers() function. Clicking on a marker triggers the info window to pop up and clicking the infowindow redirects the user to the next view controller (mapview function, built-in google maps function). The chosen location is stored in a variable and is passed on to the screen (detail view controller), as well as the list of locations.

The log out button at the top logs out the user using FacebookLoginManager and unwinds to the 'log in view controller'.

## Detail view controller
This screen displays the information of the variable 'chosenLocation'. In the viewDidLoad function the available seats of chosenLocation are fetched from Firebase via fetchAvailableSeats() with a single event observer. If this is completed the updateUI() and updateButtons() function is triggered. The first function sets the labels with the correct titles/values. The second function first checks whether there are seats available. If not, it disables checkin. Otherwise, it looks into firebase at the current logged in user node and checks whether the user is already checked in at the location. This is the case if the duration is empty. This means that an activity is started but not yet ended. It updates the buttons accordingly. 

When the check-in button is pressed (with pulse animation), a couple of things happen:
1) updateButtons() function is triggered so that checkin is disabled and checkout enabled. 
2) Starttime is set at current time in date object
3) The available seats of the location is updated in firebase. Via an 'observe event of child changed' this is also visible for other users.
4) addActivity() is triggered

The function addActivity() stores information of the currently started activity in firebase. It first converts the start date to string as firebase does not accept 'date' objects. Then it substracts the month and date of the starttime 'date' object and stores it into a date variable with structure "\(day)/\(month)". It generates an automated autoid key in firebase and stores this in firebase too so it is easy to look up activities. 

When the check-out button is pressed (with pulse animation), an alert pops up prompting the user to confirm their check-out. At confirmation the following happens:
1) the key and starttime of the ended activity is determined via 'observeSingleEvent'. This is done via iteration over all activities of the logged in user and selecting the one that has an empty duration (as this is the activity that the user is currently attending). If the starttime is determined a function setEndtime() is triggered. In this function a dateformatter is established in order to convert the starttime to a date object again, so that the elapsed time can be determined. Elapsed time is calculated via the timeIntervalSince method and then converted to hours. 
2) The index of the chosen location in the locations list is determined so that we can update the available seats in firebase. This is necessary because locations are stored with child id corresponding to their index in the locations list. Therefore, in order to acces the information of a locations in firebase we must first determine the correct index. When completed, the seats are updated via a runTransactionBlock. This is a built-in method of firebase that ensures that the availability update runs smoothly. For example, if two users were to check out at the same time this might cause problems as firebase would receive two updates at a time. RunTransacitonBlock prevents that. 
3) updateButtons() is again triggered to make sure that checkin is again enabled and checkout disabled. 

# ProgressViewController
The user can tap on the progress icon below. This will redirect to the progress screen which is a tablevliew of all the started and ended activities of the user. Herein the viewDidLoad functions starts with two functions:
1) fetchActivityData(); This function contains of two parts. First, all the activities are seperately stored in an object Activity, via an observe ChildAdded event. The Activity structure contains location, starttime, duration, date and key. After this, the object is stored in a list 'activities' and the table is reloaded. Secondly, the functions observes events for childChanged. This is needed so that an activity cell is updated when an activity is ended (and duration is set). The observer determines which activity is modified, which index this activity has in the activities list and removes it accordingly. It then creates a new (updated) Activity object and appends it to the activities list. This way the activity is not shown twice. When completed it reloads the tableview again. 
2) updateUI(); this function just sets the navigation title. A seperate function is made for the simple reason that lay-out can be adjusted herein.

There are also a number of tableview functions:
1) cellForRowAt function: This function sets the content of a particular cell and returns it. For the cell to have the correct structure a class is created at the top of the progressTableViewController. This is called ProgressViewCell and in this class the outlets for three labels are created: date, location and duration. Within the cellForRowAt function these labels are set using the information stored in the activities list (fetched under fetchActivityData()). 
2) numberOfRowsInSection function: This just counts the number of activities that the user has and returns this exact number.
3) canEditRowAt function: To enable editing of cells, returns true
4) commit editingstyle function: function to enable deleting cells. It selects the indexPath that is chosen and removes this element from the activities list. The function removeItemFromDatabase() is then triggered with argument the removed activity. Here, the activity key is determined and the built-in function 'removeValue' is called to remove the activity with this particular id in firebase. 

Last, in the upper right corner a button is displayed called 'find friends' Clicking the button redirects to the friends view controller

# Friends view controller
In this view controller the user is able to check whether friends are at a UBA location at the moment. The viewDidLoad function calls fetchUsers(). This function iterates over all users in firebase in the 'email addresses' node and stores them in a dictionary, called users. 

The screen displays a search bar in which the user can enter a email address. When the user hits enter the searchBarSearchButtonClicked() function is triggered. This function iterated over the users dictionary and checks whether the typed in address corresponds to an email address in the dictionary. If so, the function fetchLastActivity() is called, otherwise the user is alerted that there is no such user known in the database or it might be typed in wrong. fetchLastActivity() first determines the current date and month. It then iterates (via a single event observer) over every activity of the found friend and looks for activities that match the current date. When an activity today is found, it stores the location and duration in seperate variables. and calls alertUser().

alertUser() first checks whether the found activity is already ended or not via the duration variable stored earlier. If this variable is empty it alerts the user that his friend is currently checked in at a specific location (known because of the previously stored location variable). This alert also has an action that can redirects the user to the map with an unwind segue. This unwind segue passes on a marker created in the override perpare function. There, it first fetches information of the friend's location. It then creates a new marker with this information, adds the emaill address of the friend in the info window, and changes the color to green. This will make it clear to the user where the friend is at the map. The Location View Controller contains an IBAction for this unwind segue and makes sure that the markers list is updated with the newly created marker: it removes the old one and appends the new one (passed on with the segue) and displays all markers again on the map via showMarkers(). 













 

