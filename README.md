# Linux Tycoon (Redot Engine)

A port of Linux Tycoon Classic v1.1.2 from around 14 years ago made with the help of Google Gemini Argon using the Redot Engine v26.3 with the Compatibility renderer which can support Desktop, mobile and even the web - since Linux Tycoon is a 2D game, it may as well run anywhere.

This isn't a 1:1 port as all the windows are draggable and it should support full-screen.

# Outstanding issues from source repo:

* **Worker/Volunteer Deja Vu** which Ala-lala opened on Apr 9, 2014 (https://github.com/BryanLunduke/Linux-Tycoon/issues/5): Get say 30 volunteers and 10 paid workers, save your game and quit, then start up and resume your game. When you get your 31st volunteer or your 11th paid worker, you get a message saying that you have gotten your first volunteer or paid worker. (From Windows download).
* **Game should pause while dialogs are open** which mechanical-snail opened on Jun 3, 2013
(https://github.com/BryanLunduke/Linux-Tycoon/issues/2): If you press the "Release Version" or "Save" buttons while the game is running, it keeps running while the dialog is open. It is therefore not clear what version is being released and what state is being saved. The game should pause whenever dialogs are open. (Version 1.1.1 on Linux)


# Current status
The game actually launches in Redot! But has a number of bugs which I have identified so far:

## Critical
* No saving - the "Save" button is greyed out and unusable
* No assign workers - the "Assign Workers" button is also greyed out and unusable

## Minor
* The buttons are of varying widths and some touch the window border such as "Import scenario".
* The "Package Selection" dialogue has an ugly box drawn around the checkboxes used to select packages.
* The text is ugly and seems to have hinting problems. I don't mind using Open Sans instead of Roboto, but it has to look good!

# Planned features
* How do Scenarios work? - I see they are XML files...
* How did the Online mode work? Do we have any documentation on that? - I can see on Google there was a "Linux Tycoon Server" back in the day.
* Music would be cool! Some cool free .oggs with a tycoon vibe.
* Options menu with support for audio, localisation, etc.

## Buy a copy of Linux Tycoon from itch.io

Support Bryan Lunduke directly by purchasing a copy of Linux Tycoon v1.3 from itch.io:

* https://lunduke.itch.io/linux-tycoon-mega-collection - all the games for just $12, which includes the additional Android and Gameboy ports!
* https://lunduke.itch.io/linux-tycoon-3 - $5
* https://lunduke.itch.io/linux-tycoon-for-dos - $10
* https://lunduke.itch.io/linux-tycoon-classic - $10

## Lunduke Computer Operating System (LCOS)

https://lunduke.com/lcos.html

Bryan Lunduke released his own GNU/Linux distro called the **Lunduke Computer Operating System (LCOS)**:

* No Age or ID Verification.
* No Online Accounts Needed.
* No Built-in AI Features.
* No Weird Politics.
* No Systemd.
* No Forced Rust Clones.
* Modern Tech. With 90s Inspirations.

It even has some games included, such as *Micropolis*. But I don't see *Linux Tycoon*, which is stuck in the proprietary Xojo (formerly RealBASIC) language. Therefore, let's try porting the game to the modern Redot Engine to use GDScript instead with the assistance of Google Gemini!

**Side note:** I hope Bryan Lunduke open-sources more of his older projects from 10+ years ago.

# Licence

The original *Linux Tycoon* project was licenced under the GNU GPLv2 and since this is a derivative project, the licence also applies here.

Bryan Lunduke himself is very welcome to incorporate the latest features in a proprietary build of this game, and in fact, I would be flattered if he did!