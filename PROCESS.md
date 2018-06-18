# day 1
Project goedgekeurd, basis schets gemaakt.

# day 2
Design file gemaakt met geavanceerde schets. Functies en classes uitgewerkt die nodig zijn voor de app.

# day 3
Alle schermen zijn aangemaakt in de storyboard met alle segues. Google maps werkt een geeft markers weer voor UBA locaties.
Bij het klikken op een marker komt een infowindow tevoorschijn. Als er op het infowindow wordt geklikt, ga je naar het volgende scherm
met informatie over de betreffende locatie. Hierbij is een check-in en check-out button gemaakt die gebruikt kunnen worden. Pop-up venster
voor bevestiging van uitchecken. Bij bevestigen wordt je naar de progress table gestuurd, hierin kun je je activiteiten zien (to do dag 4). Firebase is geinstalleerd, maar wordt nog geen data in gezet of uitgehaald. 

# day 4
App communiceert met firebase en past gegevens aan. 

# day 5
Anoniem inloggen, studieactiviteiten static var van gemaakt. Activiteiten opslaan in firebase. Tableview laat nu alle activiteiten zien

# day 6
FB login pagina is aangemaakt. Users worden in firebase gezet. Morgen users in realtime database zetten met studieactiviteiten. Ook zorgen dat dit niet dubbelop gebeurt. Check of er al een valide acces token van fb is, voordat je een nieuwe maakt? 

# day 8
users worden nu met correcte uid opgeslagen in de database. Studieactiviteiten worden hieronder gehangen. Ik ben nu bezig met een handige manier bedenken om activiteiten te verwijderen en toe te voegen. Hoe kan ik via al m'n view controllers bij m'n firebase database reference komen. Morgen moet ik zorgen dat alle data die gepresenteerd wordt uit firebase wordt gehaald en niet uit een lokale variabele (static var).  

# day 9
delete functionaliteit toegevoegd. Werkt nu goed met table view en firebase.
