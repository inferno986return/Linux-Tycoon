# Linux Tycoon: Version Evolution Change Log (v1.1.2 → v1.3 & DOS Edition)

I used Google Gemini, the `strings` command, and a Python script to try and reverse-engineer a changelog between the source code for v1.1.2, the commercial releases for v1.2 (which I purchased back in 2012) and the final v1.3 on itch.io, as well as the Visual Basic for DOS (`v0.9.2`) source code.

## Baseline: v1.1.2 (Open-Source Release)

* **Architecture:** Standalone single-player executable compiled via REAL Studio.
* **Core Systems:** Local game simulation loop, daily event tickers, manual package selection, basic worker allocation, and local XML save/load architecture.
* **UI Foundation:** Basic canvas-rendered custom buttons (`canBtn`, `canLabel`) and default window frames.

---

## Version 1.2 Changes

*(Transition from pure local simulation to an online-connected ecosystem)*

### 1. New Multiplayer & Networking Architecture (`theServer`, `theClientSocket`)

* **Client-Socket Integration (`theClientSocket.rbbas`):** Added asynchronous networking capabilities allowing the game to communicate with remote backends using structured command separators (`[*/*]`) and completion tokens (`[*Complete*]`).
* **Server-Side Sockets (`theServer.rbbas`, `theServerSocket.rbbas`):** Introduced a multi-threaded TCP socket server framework on port `6175` to manage player logins, multiplayer state synchronization, and score tracking.
* **New Network UI Containers Added:**
  * **`conLogin.rbfrm`:** Implemented player authentication views for user credential sign-in.
  * **`conNewUser.rbfrm`:** Added account creation and password confirmation forms.
  * **`conServer.rbfrm`:** Provided host controls for running local servers and publishing to trackers.
  * **`conServerList.rbfrm`:** Implemented a live browser to query and parse active server lists from `bbs.lunduke.com` via XML.

### 2. Gameplay Mechanics & Visual Customization

* **Worker Sacrifice Feature (`conSacrificeWorker.rbfrm`):** Formalized the mechanic allowing players to burn/sacrifice volunteer workers for randomized, high-stakes daily boosts to hype (`-5` to `+15`) and user growth (`-30` to `+65`).
* **Contextual Image Customization (`frmMain.rbfrm`):** Added right-click context menu options allowing users to dynamically assign custom desktop wallpapers and custom distribution logos (`Set Wallpaper`, `Set Distro Logo`) from local PNG/JPEG files.
* **Scrollable Notification Drawer (`conNotifications.rbfrm`):** Upgraded the notification history window with vertical scrolling capabilities to track historical logs and event timestamps.

---

## Version 1.3 Changes

*(Engine migration and modernization release)*

### 1. Xojo Engine & Modern Runtime Migration

* **Stub Loader Architecture (`LinuxTycoon.exe`):** Transitioned away from the monolithic static x86 binary structure of v1.1.2/1.2 into a slim C++ bootstrap launcher stub (`GUIStubWin32.pdb`).
* **Dynamic Library Separation (`LinuxTycoon Libs/`):** Shifted all core game code, window layouts, and simulation logic out of the executable and into a dedicated library runtime (`LinuxTycoon Libs\LinuxTycoon.dll` and framework dependencies), decoupling the launcher from the game engine.
* **Platform Compatibility:** Modernized the compilation toolchain to target compatibility renderers supporting newer 64-bit OS window managers, laying the groundwork for mobile/web distribution exports.

### 2. Quality-of-Life & Upstream Bug Fixes

* **Resolved Upstream Issues:** Formally integrated fixes for historical GitHub issues, including the "Grocer's Apostrophe" text bug (PR #3), the workforce counting de-sync ("DejaVu" issue #5), and enforcing mandatory game pausing while modal dialogs (such as *Release Version* or *Save*) are open (Issue #2).

---

## Spin-Off Variation: Linux Tycoon for DOS (v0.9.2)

*(Lightweight MS-DOS text-mode adaptation compared to vanilla v1.1.2)*

### 1. Architecture & UI Layout

* **Toolchain & Project Structure (`LINUXT.MAK`):** Built in **Microsoft Visual Basic for MS-DOS 1.00 (VBDOS)** across four active modules: `MAIN.BAS` (the entire simulation engine), `GAME.FRM`, `PACK.FRM`, and `ABOUT.FRM`.
* **Collapsed Single-Screen TUI (`GAME.FRM`):** Unlinked prototype forms (`RANK.FRM`, `STATS.FRM`, `MYDISTRO.FRM`, and `EVENTS.FRM`) show an early attempt to mirror v1.1.2's multi-window desktop layout before collapsing Stats, DistroRank, and Events into a single main screen.
* **Master-Detail Package Picker (`PACK.FRM`):** Replaced v1.1.2's scrollable multi-line package cards with a two-column DOS layout—a package name list on one side and a detail panel with an `Include in Distro` checkbox on the other.

### 2. Simulation & Feature Differences vs. v1.1.2

* **Unimplemented Workers & Saving:** Although `WorkersPaid` / `WorkersVolunteers` fields exist on the `Distro` struct and `Workers` / `Save` buttons appear on `GameForm`, `MAIN.BAS` contains no worker hiring, bug-fixing productivity, or save/load routines.
* **Simplified Growth & Dummy AI:**
  * Tracks **20** competing distros (omitting `nadrimajstorux`, `Tauser Linux`, and `Mattian`). Competitors hold no packages; `NewUsersAll()` simply nudges their user counts up (`0–10`) or down (`0–5`) at random each day.
  * Player growth (`NewUsersMe()`) replaces v1.1.2's market-share percentage formulas with `((RND * (PackCred + PackPop)) / 2) + Hype` (halved if `Size > 700` MB) and applies no bug penalty.
* **Reduced Event Pool:** `DoRandomEvents()` rolls `RND * 500` and checks only **8** player-targeted events (`20–27`), compared to 23 events in v1.1.2.
* **Package Roster Parity & Bug Quirk:** Retains the same 33 packages (with minor typos like `ReallyFreeOfiice` and `CoutTrainer`, and slightly higher starting bugs on `FragBlast4000` and `Video Player Thing`). Due to a value-copy bug in `NewBugs()` (modifying `tempPackage` without writing it back to `AllPackages(i)`), new bugs never actually accumulate.

### 3. Unique DOS-Only Touches (Absent in v1.1.2)

* **Release Hype Bonus:** `MakeNewRelease()` immediately awards **`+5` Hype** whenever a new version ships.
* **Age of Universe Counter:** Displays total days elapsed (`CurrentDay` / `lblGameAge`) alongside the current release's age.
* **Unreleased Status & Default Name:** Displays `"UNRELEASED"` for version age prior to v1.0, and defaults a blank distro name to `"Nuthin'"` instead of `"MyLinuxDistro"`.