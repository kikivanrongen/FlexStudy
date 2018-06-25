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

# day 10
Extra variabele aan struct activity aangemaakt (key) waardoor het nu gemakkelijker zoeken is in firebase naar een activiteit. Functies hiernaar aangepast. Ook een extra viewcontroller gemaakt waarin mbv een search bar vrienden gezocht kunnen worden (op email adres). Morgen: add activity als functie al aanroepen bij check-in van een activiteit. Op deze manier kan je vrienden zoeken op het moment waar ze dan zijn ingecheckd. Op het moment van checkout kan je de duration dan vastleggen en de node updaten in firebase --> Kijk of hierdoor de observe events nog kloppen. Misschien niet meer .childAdded, maar .childChanged!

# day 11
Functie addActivity wordt nu aangeroepen bij check-in. Hierdoor kunnen vrienden gezocht worden op het moment dat ze daadwerkelijk op een locatie zijn ingecheckt. Daarvoor moest ik wel firebase updaten (met duration) bij het afronden van een activiteit. Inderdaad observer voor childChanged moeten toevoegen. Progress table view geeft nu ook de activiteit weer op het moment dat deze nog niet is afgerond en vervangt deze door de afgeronde activiteit bij check-out. Al wat animaties gemaakt voor buttons (pulse) en ga morgen verder met lay-out animaties.

# day 12
Nieuwe functie gemaakt 'updateButtons()' die de buttons enabled adhv of een user al is ingecheckt. Volgende probleem: de starttijd wordt nergens opgeslagen in firebase (alleen lokaal). Dit betekent dat op het moment dat een user incheckd, de app afsluit en terugkomt dat hij niet meer kan uitchecken omdat de starttijd niet bekend is. RunTransactionBlock toegevoegd bij het updaten van beschikbare plekken. Dit voorkomt dat het mis gaat op het moment dat studenten tegelijkertijd inchecken en uitchecken.

# day 13
Er wordt nu een nieuwe marker toegevoegd met andere kleur op het moment dat een vriend is gevonden. Code is wat bijgewerkt en ziet er netter uit. Alle functies werken volledig nu (ook met firebase).
