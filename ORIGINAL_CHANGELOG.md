# Linux Tycoon: Version Evolution Change Log (v1.1.2 → v1.3)

I used Google Gemini, the `strings` command, and a Python script to try and reverse-engineer a changelog between the source code for v1.12 and the commercial releases for v1.2 which I purchased back in 2012 and the final v1.3 on itch.io. 

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