# Linux Tycoon Classic (Redot Engine Port)

[![Engine](https://img.shields.io/badge/Engine-Redot%20v26.3-blue.svg)](https://www.redotengine.org/)
[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-green.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
[![Target Resolution](https://img.shields.io/badge/Target%20Resolution-850x500-orange.svg)]()

A complete modern port of **Linux Tycoon Classic v1.1.2** (originally released in 2012 by Bryan Lunduke), rebuilt from the ground up in **GDScript** using the community-driven **Redot Engine v26.3** (Compatibility Renderer). 

Originally authored in proprietary Xojo (REALbasic), this open-source revival brings the premier Linux distribution simulation into the modern era—running natively across **GNU/Linux, Windows, and macOS**, with mobile and Web export targets on the horizon.

Developed with collaborative programming and architectural assistance from Google Gemini and Argon LLMs.

---

## What's New & Modernized

While preserving the core mechanics, classic pixel aesthetic, and dry satirical wit of Lunduke's original release, this version incorporates substantial quality-of-life additions—many inspired by open-source classics like the [*CorsixTH*](https://corsixth.com/) project:

### 🎵 In-Game MP3 Jukebox
* **Top Bar Mini-Player:** Displays the current track ticker with an authentic music note icon alongside quick Skip and Mute controls.
* **Full CorsixTH-Inspired Jukebox Window:** Click the list icon to open the dedicated MP3 Player window featuring:
  * Individual track checkboxes to include or exclude songs from playback.
  * Dedicated mechanical-style controls: **Play**, **Pause**, **Stop**, **Skip Previous/Next**, and **Shuffle**.
  * Quick **Enable All** and **Disable All** playlist buttons.
  * Active track row highlighting with crisp white text contrast.
  * Includes 10 royalty-free downtempo and acid-jazz tracks from Pixabay artists.

### 🖥️ Modernized UI & HUD Layout
* **Normalized Window Layout (850x500 Target):** Main panels (Development Stats, Bryan Notifications, and DistroRank) are vertically locked and padded so buttons never touch window borders.
* **Expanded DistroRank:** View up to 14 competing distros at once without cramped scrolling.
* **System Clock:** A customizable real-world clock at the top-left (12-hour, 24-hour, optional seconds, or disabled) so you don't lose track of time managing packages.
* **Dynamic Header Date:** The in-game calendar date dynamically centers itself in the available top-bar space.
* **Google Material Icons:** Clean icon buttons for top-bar functions and worker assignments with Ubuntu-style (black background, white text) hover tooltips on desktop builds.
* **Z-Index Layer Management:** Modal dialogs (*Save Overwrite*, *Release Version*, and *Quit Confirmation*) always lock to the top layer (`z_index = 100`) so they never get hidden behind draggable windows.

### 📦 Enhanced Package & Worker Management
* **Package Selection Sorting:** Multi-criteria sorting dropdown supporting Default, Alphabetical, Bug Count, Nerd Cred, Open Source status, Popularity, and Size (MB).
* **Worker Assignment Up-Opening Sort:** Sort assigned workers by Default, Alphabetical, Bug Count, Paid Workers Assigned, or Volunteers Assigned.
* **Aligned Control Steppers:** `+` and `-` worker assignment buttons are neatly aligned with total volunteer and paid worker availability counters.

### 🐐 Bryan's Guidance & Feedback
* **CD Size Warning:** Bryan now warns you the moment your distribution exceeds **700 MB**, letting you know that exceeding standard CD-ROM capacity will begin hurting your daily user conversion on older hardware.
* **Varied Community Notifications:** New volunteers, hires, and save confirmations now cycle through randomized notification dialogs rather than repetitive static text.

---

## Legacy Upstream Bug Fixes

This Redot port resolves several longstanding issues and unmerged pull requests from the original 2012–2014 upstream repository:

1. **Grocer's Apostrophe Fix ([PR #3 / Tea23](https://github.com/BryanLunduke/Linux-Tycoon/pull/3)):** Corrected erratic punctuation and apostrophe usage across dialog strings.
2. **Worker/Volunteer "Deja Vu" Bug ([Issue #5 / Ala-lala](https://github.com/BryanLunduke/Linux-Tycoon/issues/5)):** Resuming a saved game that already had volunteers or paid workers previously caused Bryan to re-trigger the *"You got your first volunteer/paid worker!"* tutorial message on the next hire. Save-state parsing now correctly tracks prior workforce history.
3. **Modal Dialog Pause Enforcement ([Issue #2 / mechanical-snail](https://github.com/BryanLunduke/Linux-Tycoon/issues/2)):** Opening modal confirmations (such as *Release Version*, *Save*, or *Quit*) now immediately pauses simulation time so the game state does not advance underneath confirmation dialogs.

---

## Getting Started

### Prerequisites
* A copy of the **Redot Engine v26.3** (or compatible Godot 4.x build using the Compatibility / OpenGL3 backend):  
  👉 [Download Redot Engine](https://www.redotengine.org/download/)

### Running from Source
1. Clone this repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/linux-tycoon-redot.git
   ```
2. Launch the Redot Engine editor.
3. Click **Import**, navigate to the cloned folder, and select `project.godot`.
4. Click **Run Project** (or press `F5`).

---

## Planned Features & Roadmap

- [ ] **Scenario Architecture:** Document and extend the XML scenario specification (`*.ltx`) to allow community custom scenario authoring.
- [ ] **Online Mode Investigation:** Research the protocol behind the legacy *Linux Tycoon Server* for potential headless server recreation.
- [ ] **Android / Mobile Touch Support:** Implement a responsive touch layout alternative to right-click dragging and small steppers.
- [ ] **Extended Localization:** Expand beyond the English base strings with community translations.
- [ ] **Distro ISO Targets:** Option to configure media format targets beyond CD-ROM (e.g., Floppy sets, DVD, USB Flash drive).

---

## Music Soundtrack

All background music is provided royalty-free via Pixabay licenses:

1. **Alex Morgan** — *Downtempo Chill Electronic*
2. **Amplify Music** — *Jazz Cafe Music - Electric Velvet Groove*
3. **Kulakovka** — *Inspiring Downtempo*
4. **Soundsurfer** — *Downtempo*
5. **Turning Pages** — *Kindling The Flame*
6. **Alex Morgan** — *Acid Jazz Cafe*
7. **Tunetank** — *Inspiring Downtempo*
8. **Pavetraxx** — *Digital Beauty*
9. **Serge Pavkin** — *Looking at the Horizon*
10. **Tunetank** — *Downtempo Beat*

---

## Support Bryan Lunduke & Original Releases

If you enjoy *Linux Tycoon*, consider supporting the original creator, **Bryan Lunduke**, by picking up his commercial releases and collections on itch.io:

* 🐧 [Linux Tycoon Mega Collection on itch.io](https://lunduke.itch.io/linux-tycoon-mega-collection) ($12 for the full bundle, including classic DOS, Game Boy, and Android editions)
* 🐧 [Linux Tycoon 3](https://lunduke.itch.io/linux-tycoon-3)
* 🐧 [Lunduke Computer Operating System (LCOS)](https://lunduke.com/lcos.html)
* 🌐 Official Website: [lunduke.com](https://lunduke.com/)

I would love to see more of his legacy projects become open-sourced in a similar manner!

---

## License

*Linux Tycoon Classic (Redot)* is licensed under the **GNU General Public License v2 (GPLv2)**, in accordance with the licensing of the original upstream project. You are free to inspect, modify, and redistribute this software under the terms of GPLv2.

See the full license text in the game's **Credits > License** menu or consult [gnu.org/licenses/old-licenses/gpl-2.0.html](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html).