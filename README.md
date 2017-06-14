# AdvancedAutomationScripts
Advanced Command Line Scripts for automating JSON functions.

What this does . . .
- Automatically create directories for the Bots
- Allow for ease of changing settings on multiple bots
- Can run all your bots from one JAR file

Who its intended for:
- Advanced users with more than 100 accounts
- Need to have PokeBot.Ninja Radioactive

There are no detailed instructions or howtos (yet). 
These scripts are all open source, so if you find something not working properly or you want to customize it, then please submit your suggestions to the GitHub repository.

Where to start?
- Download the Assimilator.CMD file
https://github.com/dilborg/AdvancedAutomationScripts/blob/master/Assimilator.cmd
- Save it to a directory on your computer 
- Run the Assimilator . .

Running the Assimilator.CMD tool, will:
- Download the rest of the Pokeborg CMD tools and unzip them
- Download the Pokebot.Ninja program and unzip to the proper directory
- Extract your Ninja Bot details and Keys from an existing JSON
- Start the main PokeBorg CMD

There is currently not a function to scan the computer for existing Ninja.JSONs and import them, but I'm working on it.
If you have existing JSONs you would need to manually copy your existing Ninja.JSONs to the DroneXXXX directories.

PokeBorg.CMD:
- This is the main script launcher
- Once everything is installed, you should be able to:
  - Import Bots from CSV (still being perfected)
  - Create / Edit / Extract ninja.jsons
  - Launch the bots for Farming / Gym or Sniping


* A note about where to save the Assimilator:
- Where you place the Assimilator is where the directories and all the rest will be saved
- It needs to be a location where you have WRITE permissions
- Ideally the path to this location doesn't contain any spaces . . .
- So MyDocuments\Pogo is possible, but C:\Pogo is ideal

** Features I'm currently working on . . .
- Scan the system for ninja.json
- Maintain a CSV or database of Bots
- Ability to import 100 bots at a time
- The current system has cap of 9999 bots, can be expanded

*** If you have any questions, suggestions or find a bug please don't hesitate to use Github Issues.
