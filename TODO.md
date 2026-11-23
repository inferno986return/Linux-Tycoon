# TODO.md

## Short-term

These are things I want to achieve before this game hits v1.0 and I am confident to annouce the game formally to the general public:

### Bugs

* Continue playtesting to find unexpected bugs.
* Many of the windows have buttons which touch the bottom border without making any space. The space should be conistent too!
* ~~The "Release Version" and "Quit" dialogues have centred buttons when all "Ok!" and "Cancel" should be right-aligned.~~ <-- No! This looks worse.
* The game still has weird text rendering issues.
* The "Overwite Save" window from the "Save" button should match the "Quit" dialogue.
* Formally support Scenarios and test them - the RealLife.json JSON doesn't work when selected and starting a new game, then the packages. Save has an issue where it asks to overwrite but it hasn't been created yet, so we need a check for New Game to force Save As on first save.
* Show Size: label in DistroRank next to Users: and reposition.
* Game feels unbalanced - make Sacrifice Worker more neccessary with more random events towards rival distros (especially positive ones), etc.

### Features

* We can squeeze row 11 on the DistroRank with the optimal window sizing and arrangement.
* In-game hotkeys (with underlining and tooltips): Space (to pause/play the game), S to Save, A to Assign Workers, P to Edit Packages, M for MP3 Player, audio playback keys for the music (some keyboards have them), F5 does Quicksave, Esc for Quit etc.
* Make the distro development window shorter and DistroRank longer to show 11 and 12.
* Add functionality to the Hotkeys button in the Settings menu which shows and allows rebinding hotkeys - Esc has been implemented, but should double Esc should quit to main menu or close the game entirely?
* Add some left and right margin on the Overview window to space it out better..
* Show the competition's Size next to Users in DistroRank - this is buggy and some distros have 0 MB and yet a growing userbase
* More packages, especially for when the 4.7GB DVD limit is reached.
* Add the Rank to the Overview window on the right side after Age:.
* How about in DistroRank - Users:, Size: with mini-arrows next to them. And right-align the crown fully at the top?
* Show the distro dev window on the left while the Edit Packages and Assign Workers is open.
* More packages and even more random events inspired by Monopoly's Chance and Community Chest - 60 or 75? I also like a package randomly becoming closed or open-sourced or even abandoned

## Long-term
* Dedicated GitHub website - would be cool if it had the same blue window design using Hugo or something.
* Actually compile the game for Windows and GNU/Linux, then test the "Fullscreen" checkbox in the "Settings" actually works.
* Add a localisation for Esperanto to pave the way for translations.
* Implement multiplayer exactly as Bryan Lunduke intended and enable the "Run Server" and "Online Game" buttons in the Main Menu.
* Other single player modes - I would like getting a certain rank or higher within 1 year or 2 years with balancing adjustments made (or even player-set parameters like FNAF's "Custom Night")
* Achievements (though I like the Newgrounds term of "medals" too) for playing for 10, 20, 500 and 100 years, reaching the top 10, then number 1 and keeping number 1 for at least 1 year, getting 100,000 and then 150,000 users, exceeding 700MB (Got a flash drive?), etc.
* Hard mode
* Provide some kind of end game, as the classic game has no end
* A hamburger (3 horizontal lines ≡) or kebab (vertical ellipis ⁝) menu in the top-right if there is a button overspill and we need a dedicated menu for Save As, Quit, etc.
* Different speeds like with SimCity and RCT: 0 - Paused, 1 - Normal, 2 - Fast, 3 - Extreme
* Refactor all the code to be as efficient as it can be.
* When you click on the distro in DistroRank, it shows the growth (or shrinkage) of the distro's userbase with a line graph over 30 days (or more).
* Punish long release windows over 180 days or inconsistent release periods - how should be implemented whilst keeping the balancing?
* Icons for each Linux distro and a choice of unique icon for the player's distro. Icons show in DistroRank - pinched the LCOS 32px from Bryan Lunduke's branding repo on GitHub.
* How to increase game longevity?
* Show gamesave playtime and even an achievement for a number of gametime hours on it
* Different package management standards across distros - even Lunduke has discussed this in-detail with his Why Linux Sucks speeches
* Do we have feature parity with Linux Tycoon for DOS?
* *Linux is Badass* CHOA Easter egg (which I will EPUB 3.2+ at some point) - I am thinking of an icon you click such as Tux (or maybe the Konami code) in the main menu?, I will credit the book (and it's CC BY-SA NC) and link it via: https://www.amazon.com/dp/1365052095, https://www.amazon.ca/dp/1365052095, https://www.amazon.co.uk/dp/1365052095, and https://www.amazon.com.au/dp/1365052095
* itch.io and GitHub Pages website for the game in the windowed style
* Better rival distro AI which modifies their package line up, especially once the CD restriction has been lifted