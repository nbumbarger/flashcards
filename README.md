#Flashcards Project

##Run instructions:
    *Requires an empty database called flashcards
    *Execute with ruby run.rb
    *Clears and seeds the database when run. To enable persistance, remove lines 20-22.

#Major last-minute bug:
    *Main menu item 4, View/Reset Statistics, cannot be accessed whatsoever. I need to count up my end statements to see what isn't closed and is preventing the "4" case from firing. I literally don't have time to do this before submitting.
        *Without the ability to reset statistics, program must be reloaded with database seeding on in order to revert the categories' score to 0.

#Things that suck:
    *Focused too much time on user interface; when I ran out of time the code turned into spaghetti and I had no time for testing.