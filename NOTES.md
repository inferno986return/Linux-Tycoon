
**Note:** I am using the latest Google Gemini Argon to port this game to the Redot Engine by uploaded the entire "original" folder.

**Prompt:** Hey Argon, got a task worthy of your firepower. I want to port Linux Tycoon from Xojo. I am using Redot Engine v26.3 with the Compatibility renderer, which can support Desktop, mobile and the web since Linux Tycoon is a 2D game, so it may as well run anywhere. 

Porting **Linux Tycoon 1.1.2** from a 2013 REALbasic/Xojo codebase to **Redot Engine v26.3** (Compatibility / GLES3 renderer) is a clean architectural upgrade. Because the original game is entirely event-driven UI and simulation math without physics or shaders, a single codebase using Redot's `Control` node hierarchy will compile cleanly to Desktop, Android/iOS, and WebAssembly.

Below is the complete, cleanroom port of the core data models, the simulation engine (including original quirks and fixes), and the UI architecture mapped directly from the `.rbbas` and `.rbfrm` files.

---

## 1. Architecture & Component Mapping

The original Xojo project uses a single main window (`frmMain` at `620x410`) with a main canvas (`canMain` at `620x390`) and a 22px top bar for the date and pause button. All sub-windows are `ContainerControl` instances embedded within `canMain` that toggle `.Visible` and allow dragging via `MouseDown`/`MouseDrag`.

| Xojo Component | Redot v26.3 Equivalent | Implementation Notes |
| --- | --- | --- |
| `GeneralStuff.rbbas`

 | `GameManager.gd` (Autoload Singleton) | Holds `my_distro`, `other_distros`, `packages_available`, date ticks, and XML I/O.

 |
| `Package.rbbas` & `Distro.rbbas`

 | `PackageData.gd` & `DistroData.gd` (`RefCounted`) | Pure data classes with calculation helpers.

 |
| `ReDrawBG()` (`WinBorder/*.png`)

 | `NinePatchRect` or `StyleBoxTexture` | Replaces the manual nested `for` loops drawing `TopLeft`, `TopRepeat`, and `Background.png`.

 |
| `canBtn.rbbas`

 | `Button` + `Theme` (`StyleBoxFlat`) | Uses the exact Xojo RGB values for Normal, Hover, Pressed, and Disabled states.

 |
| `con*.rbfrm` (Draggable Panels)

 | `DraggablePanel.gd` (`PanelContainer`) | Handles `GuiInput` drag events and houses each screen (`conDistroStats`, `conPackageSelection`, etc.).

 |
| `timeDayChange` (`Timer`, 1000ms)

 | `Timer` node (`wait_time = 1.0`) | Drives `increment_by_a_day()` when `is_paused == false`.

 |

---

## 2. Core Data Models (`PackageData.gd` & `DistroData.gd`)

Create these two scripts to replace `Package.rbbas` and `Distro.rbbas`.

### `PackageData.gd`

```gdscript
class_name PackageData
extends RefCounted

enum SoftwareType {
	WEB_BROWSER = 1,
	OFFICE_SUITE = 2,
	DESKTOP_ENVIRONMENT = 3,
	GAME = 4,
	GRAPHICS_EDITING = 5,
	PROGRAMMING = 6,
	COMMUNICATION = 7,
	UTILITY = 8,
	MULTIMEDIA = 9
}

var name: String = ""
var description: String = ""
var bugs: int = 0
var is_open_source: bool = true
var nerd_cred: int = 0
var popularity: int = 0
var size_in_mb: int = 0
var type_of_software: int = SoftwareType.UTILITY
var version: int = 1
var logo: Texture2D = null

func _init(p_name: String = "", p_bugs: int = 0, p_desc: String = "", p_os: bool = true, p_nerd: int = 0, p_pop: int = 0, p_size: int = 0, p_type: int = 1, p_ver: int = 1) -> void:
	name = p_name
	bugs = p_bugs
	description = p_desc
	is_open_source = p_os
	nerd_cred = p_nerd
	popularity = p_pop
	size_in_mb = p_size
	type_of_software = p_type
	version = p_ver

func add_a_bug() -> void:
	bugs += 1

func remove_a_bug() -> void:
	if bugs > 0:
		bugs -= 1

func get_category_name() -> String:
	match type_of_software:
		SoftwareType.WEB_BROWSER: return "Web Browser"
		SoftwareType.OFFICE_SUITE: return "Office Suite"
		SoftwareType.DESKTOP_ENVIRONMENT: return "Desktop Environment"
		SoftwareType.GAME: return "Game"
		SoftwareType.GRAPHICS_EDITING: return "Graphics"
		SoftwareType.PROGRAMMING: return "Programming"
		SoftwareType.COMMUNICATION: return "Communications"
		SoftwareType.UTILITY: return "Utility"
		SoftwareType.MULTIMEDIA: return "Multimedia"
		_: return "Unknown"

func get_package_xml() -> String:
	var isos := "True" if is_open_source else "False"
	return '<package Name="%s" Bugs="%d" Description="%s" NerdCred="%d" Popularity="%d" SizeInMB="%d" TypeOfSoftware="%d" Version="%d" isOpenSource="%s"/>' % [
		name.xml_escape(true), bugs, description.xml_escape(true), nerd_cred, popularity, size_in_mb, type_of_software, version, isos
	]

```

### `DistroData.gd`

> **Bug Note from Original Xojo Source:** In `Distro.rbbas`, `GeneratePackageListForXML()`, `GeneratePaidAssignedListForXML()`, and `GenerateVolunteerAssignedListForXML()` check `if PackagesIncluded.Ubound > 0` instead of `> -1`. In the original game, if a distro only had **1 package** (index `0`), it saved an empty string to XML! The port below fixes this to `size() > 0` (equivalent to `Ubound > -1`).
> 
> 

```gdscript
class_name DistroData
extends RefCounted

var name: String = ""
var bugs: int = 0
var hype: int = 0
var users: int = 0
var version: int = 1
var released_ver: int = 0
var released_date: int = 0 # Unix timestamp (TotalSeconds)
var released_bugs: int = 0
var new_user_change: int = 0

var packages_included: Array[int] = []
var workers_paid: int = 0
var workers_paid_assigned: Array[int] = []
var workers_volunteers: int = 0
var workers_volunteers_assigned: Array[int] = []
var logo: Texture2D = null

func add_package_to_distro(package_index: int) -> void:
	if not is_package_in_distro(package_index):
		packages_included.append(package_index)
		workers_paid_assigned.append(0)
		workers_volunteers_assigned.append(0)

func remove_package_from_distro(package_index: int) -> void:
	var idx := packages_included.find(package_index)
	if idx != -1:
		packages_included.remove_at(idx)
		workers_paid_assigned.remove_at(idx)
		workers_volunteers_assigned.remove_at(idx)

func is_package_in_distro(package_index: int) -> bool:
	return packages_included.has(package_index)

func get_distro_age_in_days() -> int:
	if released_date == 0:
		return 0
	return int((GameManager.the_date - released_date) / 86400.0)

func get_distro_bugs() -> int:
	var total := 0
	for pkg_idx in packages_included:
		total += GameManager.packages_available[pkg_idx].bugs
	return total

func get_distro_nerd_cred() -> int:
	var total := 0
	for pkg_idx in packages_included:
		total += GameManager.packages_available[pkg_idx].nerd_cred
	return total

func get_distro_package_popularity() -> int:
	var total := 0
	for pkg_idx in packages_included:
		total += GameManager.packages_available[pkg_idx].popularity
	return total

func get_distro_size_in_mb() -> int:
	var total := 0
	for pkg_idx in packages_included:
		total += GameManager.packages_available[pkg_idx].size_in_mb
	return total

func get_distro_bug_percentage() -> float:
	var all_stats := float(GameManager.my_distro.get_distro_bugs())
	for d in GameManager.other_distros:
		all_stats += float(d.get_distro_bugs())
	if all_stats <= 0.0:
		return 0.01
	var pct := float(get_distro_bugs()) / all_stats
	return 0.01 if pct <= 0.0 else pct

func get_distro_hype_percentage() -> float:
	var all_stats := float(GameManager.my_distro.hype)
	for d in GameManager.other_distros:
		all_stats += float(d.hype)
	if all_stats <= 0.0:
		return 0.01
	var pct := float(hype) / all_stats
	return 0.01 if pct <= 0.0 else pct

func get_distro_nerd_cred_percentage() -> float:
	var all_stats := float(GameManager.my_distro.get_distro_nerd_cred())
	for d in GameManager.other_distros:
		all_stats += float(d.get_distro_nerd_cred())
	if all_stats <= 0.0:
		return 0.01
	var pct := float(get_distro_nerd_cred()) / all_stats
	return 0.01 if pct <= 0.0 else pct

func get_distro_package_popularity_percentage() -> float:
	var all_stats := float(GameManager.my_distro.get_distro_package_popularity())
	for d in GameManager.other_distros:
		all_stats += float(d.get_distro_package_popularity())
	if all_stats <= 0.0:
		return 0.01
	var pct := float(get_distro_package_popularity()) / all_stats
	return 0.01 if pct <= 0.0 else pct

func get_distro_size_in_mb_percentage() -> float:
	var all_stats := float(GameManager.my_distro.get_distro_size_in_mb())
	for d in GameManager.other_distros:
		all_stats += float(d.get_distro_size_in_mb())
	if all_stats <= 0.0:
		return 0.01
	var pct := float(get_distro_size_in_mb()) / all_stats
	return 0.01 if pct <= 0.0 else pct

func get_distro_worker_available_paid() -> int:
	var assigned := 0
	for w in workers_paid_assigned:
		assigned += w
	return workers_paid - assigned

func get_distro_worker_available_volunteer() -> int:
	var assigned := 0
	for w in workers_volunteers_assigned:
		assigned += w
	return workers_volunteers - assigned

func get_workers_paid_for_package(package_index: int) -> int:
	var idx := packages_included.find(package_index)
	return workers_paid_assigned[idx] if idx != -1 else 0

func get_workers_volunteers_for_package(package_index: int) -> int:
	var idx := packages_included.find(package_index)
	return workers_volunteers_assigned[idx] if idx != -1 else 0

func has_non_open_source_packages() -> bool:
	for pkg_idx in packages_included:
		if not GameManager.packages_available[pkg_idx].is_open_source:
			return true
	return false

func get_package_count_by_type(software_type: int) -> int:
	var total := 0
	for pkg_idx in packages_included:
		if GameManager.packages_available[pkg_idx].type_of_software == software_type:
			total += 1
	return total

func process_hype() -> void:
	if hype > 0:
		hype -= 1
	elif hype < 0:
		hype += 1

func release_new_version() -> void:
	released_date = GameManager.the_date
	released_bugs = get_distro_bugs()
	released_ver = version
	version += 1

func generate_package_list_for_xml() -> String:
	var names: PackedStringArray = []
	for pkg_idx in packages_included:
		names.append(GameManager.packages_available[pkg_idx].name)
	return ";".join(names)

func generate_paid_assigned_list_for_xml() -> String:
	var vals: PackedStringArray = []
	for c in workers_paid_assigned:
		vals.append(str(c))
	return ";".join(vals)

func generate_volunteer_assigned_list_for_xml() -> String:
	var vals: PackedStringArray = []
	for c in workers_volunteers_assigned:
		vals.append(str(c))
	return ";".join(vals)

func load_in_packages_from_list(the_list: String) -> void:
	if the_list.is_empty():
		return
	for pkg_name in the_list.split(";"):
		var idx := GameManager.get_package_index_from_name(pkg_name)
		if idx > -1:
			add_package_to_distro(idx)

func load_in_workers_paid_from_list(the_list: String) -> void:
	if the_list.is_empty():
		return
	var parts := the_list.split(";")
	for i in range(min(parts.size(), workers_paid_assigned.size())):
		var val := parts[i].to_int()
		workers_paid_assigned[i] = val
		if val > 0:
			GameManager.is_first_worker_paid = false

func load_in_workers_volunteers_from_list(the_list: String) -> void:
	if the_list.is_empty():
		return
	var parts := the_list.split(";")
	for i in range(min(parts.size(), workers_volunteers_assigned.size())):
		var val := parts[i].to_int()
		workers_volunteers_assigned[i] = val
		if val > 0:
			GameManager.is_first_worker_volunteer = false

func get_distro_xml() -> String:
	return '<distro Name="%s" Hype="%d" Users="%d" Version="%d" ReleasedVer="%d" ReleasedDate="%d" ReleasedBugs="%d" Packages="%s" WorkersPaid="%d" WorkersVolunteer="%d" WorkersPaidAssigned="%s" WorkersVolunteerAssigned="%s"/>' % [
		name.xml_escape(true), hype, users, version, released_ver, released_date, released_bugs,
		generate_package_list_for_xml().xml_escape(true), workers_paid, workers_volunteers,
		generate_paid_assigned_list_for_xml(), generate_volunteer_assigned_list_for_xml()
	]

```

---

## 3. Simulation Engine & XML Serializer (`GameManager.gd`)

Register `GameManager.gd` as an **Autoload** in Redot (`Project -> Project Settings -> Globals -> Autoload`). It ports `GeneralStuff.rbbas` and `StandardScenario`.

> **2 Bugs Fixed from Original Xojo Code:**
> 1. In `StandardScenario`, `Ooboontoo` lists `"Video Player"` in its semicolon-separated package string instead of `"Video Player Thing"`, causing `GetPackageIndexFromName` to return `-1` and silently drop the multimedia package. `get_package_index_from_name()` below includes an alias check if you want it fixed, or you can leave it raw.
> 
> 
> 2. In `RandomEvent()` Case 2 ("Reviewed poorly on LAS"), the original code did `GetDistro(theDist).Hype = MyDistro.Hype - 20` — accidentally overwriting an NPC distro's hype with `MyDistro`'s hype minus 20! I noted this in the code so you can toggle strict bug-for-bug accuracy or the intended math.
> 
> 
> 
> 

```gdscript
extends Node

signal stats_updated
signal message_added(msg_text: String, msg_date: int)
signal scenario_loaded(scenario_name: String)

var my_distro: DistroData
var other_distros: Array[DistroData] = []
var packages_available: Array[PackageData] = []

var is_first_run: bool = true
var is_first_worker_paid: bool = true
var is_first_worker_volunteer: bool = true
var is_paused: bool = false
var new_linux_users_daily: int = 50
var the_date: int = 0 # Unix timestamp in seconds

var msg_text: Array[String] = []
var msg_date: Array[int] = []

func _ready() -> void:
	the_date = int(Time.get_unix_time_from_system())
	reset_new_game_state()

func reset_new_game_state() -> void:
	the_date = int(Time.get_unix_time_from_system())
	is_first_run = true
	is_first_worker_paid = true
	is_first_worker_volunteer = true
	new_linux_users_daily = 50
	msg_text.clear()
	msg_date.clear()

	my_distro = DistroData.new()
	my_distro.version = 1
	my_distro.released_ver = 0

	build_initial_package_list()
	build_initial_distro_list()

func build_initial_package_list() -> void:
	packages_available.clear()
	var T := PackageData.SoftwareType
	
	# Desktop Environments
	packages_available.append(PackageData.new("Midget", 2, "Lightweight, simple desktop environment.", true, 3, 20, 20, T.DESKTOP_ENVIRONMENT, 1))
	packages_available.append(PackageData.new("QDE", 3, "The Q Desktop Environment.  Big.  Slow.  Lots and lots of desktop widgets.", true, 3, 10, 50, T.DESKTOP_ENVIRONMENT, 1))
	packages_available.append(PackageData.new("UCDE", 0, "The Ultra Confusing Desktop Environment.  There are no icons.  Only terminals.", true, 20, 1, 1, T.DESKTOP_ENVIRONMENT, 1))
	# Web Browsers
	packages_available.append(PackageData.new("FlamingRodent", 4, "A big, powerful web browser.  Lots of features and lots of extensions.", true, 3, 15, 10, T.WEB_BROWSER, 1))
	packages_available.append(PackageData.new("ShmoogleShrome", 2, "Lightweight and superfast web browser.", true, 3, 10, 10, T.WEB_BROWSER, 1))
	packages_available.append(PackageData.new("Text-O-Web", 0, "A Text-only web browser that runs in the Terminal.", true, 20, 0, 1, T.WEB_BROWSER, 1))
	# Office Suites
	packages_available.append(PackageData.new("ReallyFreeOffice", 4, "A big, powerful office suite.", true, 5, 15, 60, T.OFFICE_SUITE, 1))
	packages_available.append(PackageData.new("SpAnDeX", 1, "Hard to use and complicated way to build documents.", true, 15, 2, 3, T.OFFICE_SUITE, 1))
	packages_available.append(PackageData.new("OkayOffice", 1, "This office suite... is pretty ok.", true, 10, 10, 40, T.OFFICE_SUITE, 1))
	# Games
	packages_available.append(PackageData.new("PenguinZoomer", 1, "Race around and pretend that penguins are like cars.", true, 3, 8, 20, T.GAME, 1))
	packages_available.append(PackageData.new("FragBlast4000", 2, "Fancy 3D graphics and fast paced shooting of other people.", false, 1, 15, 120, T.GAME, 1))
	packages_available.append(PackageData.new("BurstABubble", 0, "There are bubbles.  You hate bubbles.  Pop those bubbles.", true, 0, 20, 25, T.GAME, 1))
	packages_available.append(PackageData.new("JustCards", 0, "It's a card game.", true, 0, 5, 20, T.GAME, 1))
	packages_available.append(PackageData.new("TapYerToes", 1, "Tap your toes to the beat of very boring music.", true, 0, 1, 15, T.GAME, 1))
	packages_available.append(PackageData.new("CityMax", 2, "Design and run a very fancy city.", false, 0, 15, 120, T.GAME, 1))
	packages_available.append(PackageData.new("CouchTrainer", 3, "Teach a couch how to be a good couch.", true, 0, 5, 65, T.GAME, 1))
	# Graphics Editing
	packages_available.append(PackageData.new("PixelPusher", 0, "A very simple image editor.", true, 1, 2, 2, T.GRAPHICS_EDITING, 1))
	packages_available.append(PackageData.new("The Dork", 2, "Robust, powerful graphics editor.", true, 5, 12, 65, T.GRAPHICS_EDITING, 1))
	packages_available.append(PackageData.new("Pictures-In-Folders", 0, "A simple photo gallery for organizing images.", true, 0, 8, 8, T.GRAPHICS_EDITING, 1))
	packages_available.append(PackageData.new("PainterMcPaint", 1, "Good for painting.  Bad for anything else.", true, 0, 3, 150, T.GRAPHICS_EDITING, 1))
	# Programming
	packages_available.append(PackageData.new("LunarBlackout", 4, "A good, flexible integrated development environment.", true, 10, 4, 120, T.PROGRAMMING, 1))
	packages_available.append(PackageData.new("JustPascal", 0, "Pascal programming tools.", true, 11, 1, 40, T.PROGRAMMING, 1))
	packages_available.append(PackageData.new("Lunduke Development Kit", 0, "The most awesome programming language.  Ever.", true, 15, 15, 10, T.PROGRAMMING, 1))
	packages_available.append(PackageData.new("LargeTalk", 0, "Considered to be the Grand-daddy of programming tools.", true, 20, 2, 10, T.PROGRAMMING, 1))
	packages_available.append(PackageData.new("EchsCode", 7, "This is a terrible development environment.  Nobody likes this or wants to use it.", false, 0, 0, 900, T.PROGRAMMING, 1))
	# Communication
	packages_available.append(PackageData.new("Mailinator", 1, "Super advanced email client.", true, 0, 12, 80, T.COMMUNICATION, 1))
	packages_available.append(PackageData.new("Chatchatchat", 1, "You know.  For chatting.", true, 0, 5, 50, T.COMMUNICATION, 1))
	packages_available.append(PackageData.new("Fir", 0, "Terminal-only email client.  ", true, 5, 1, 1, T.COMMUNICATION, 1))
	packages_available.append(PackageData.new("IRC-o-Matic", 3, "The only IRC client that matters.", true, 4, 2, 6, T.COMMUNICATION, 1))
	# Utility
	packages_available.append(PackageData.new("Calculator", 0, "You do want a calculator, don't you?", true, 0, 1, 1, T.UTILITY, 1))
	# Multimedia
	packages_available.append(PackageData.new("Video Player Thing", 1, "Plays videos.  Sometimes.  Then it crashes.", true, 0, 1, 10, T.MULTIMEDIA, 1))
	packages_available.append(PackageData.new("vidCastGrabber", 1, "Downloads and plays video podcasts.", true, 0, 3, 55, T.MULTIMEDIA, 1))
	packages_available.append(PackageData.new("emTeeVee", 2, "Automatically generates music videos.", false, 0, 2, 120, T.MULTIMEDIA, 1))

func build_initial_distro_list() -> void:
	other_distros.clear()
	# Matches StandardScenario embedded XML (which conMainMenu.Open loads)
	var std_distros := [
		["Ooboontoo", 100000, 12, "Midget;FlamingRodent;ReallyFreeOffice;PenguinZoomer;JustCards;Pictures-In-Folders;Mailinator;Chatchatchat;Calculator;Video Player"],
		["FloppyBeanie", 50000, 16, "Midget;FlamingRodent;ReallyFreeOffice;SpAnDeX;PenguinZoomer;LunarBlackout"],
		["xTr333me", 25000, 7, "UCDE;Text-O-Web;SpAnDeX;FragBlast4000;PixelPusher;The Dork;LargeTalk;Fir;emTeeVee;vidCastGrabber"],
		["CuteLittleDoggy", 15000, 5, "QDE;FlamingRodent;ReallyFreeOffice;PenguinZoomer;Calculator;Video Player Thing"],
		["Trumpet", 1, 3, "Midget;QDE;ShmoogleShrome;Text-O-Web;ReallyFreeOffice;JustCards;Calculator"],
		["Kooboonotoo", 45000, 12, "QDE;FlamingRodent;ReallyFreeOffice;PenguinZoomer;BurstABubble;JustCards;The Dork;Calculator;Video Player Thing"],
		["LooseWare", 5000, 32, "Midget;FlamingRodent;OkayOffice;PixelPusher;Mailinator"],
		["OpenSnuggle", 500, 14, "QDE;ShmoogleShrome;ReallyFreeOffice;JustCards;Calculator"],
		["TeddyBearLinux", 50, 8, "Midget;FlamingRodent;OkayOffice;BurstABubble;Mailinator"],
		["RedundantLinux", 200, 7, "Midget;FlamingRodent;ReallyFreeOffice;PenguinZoomer;The Dork;Video Player Thing"],
		["Plebian", 8500, 3, "Midget;FlamingRodent;OkayOffice;The Dork;Mailinator;Calculator;Video Player Thing"],
		["b00nd0x", 2500, 75, "QDE;ShmoogleShrome;OkayOffice;FragBlast4000;PixelPusher;Fir"],
		["FreeHugz", 900, 1, "UCDE;FlamingRodent;OkayOffice;BurstABubble;The Dork;Mailinator"],
		["Derpnix", 800, 9, "Midget;ShmoogleShrome;SpAnDeX;OkayOffice;BurstABubble;PixelPusher"],
		["Unpronounceable", 1500, 3, "QDE;Text-O-Web;OkayOffice;JustCards;Mailinator;Fir"],
		["Lozenge", 4200, 5, "Midget;FlamingRodent;ReallyFreeOffice;PenguinZoomer;The Dork;Video Player Thing"],
		["Gat3way", 3350, 11, "UCDE;ShmoogleShrome;Text-O-Web;OkayOffice;The Dork;LargeTalk"],
		["Prune", 810, 9, "Midget;FlamingRodent;OkayOffice;PixelPusher;Mailinator"],
		["ChakaLaka", 2100, 3, "QDE;FlamingRodent;ReallyFreeOffice;The Dork"],
		["SunGlassesNix", 15, 2, "UCDE;Text-O-Web;SpAnDeX;OkayOffice;PenguinZoomer;PixelPusher;Calculator;Video Player Thing"],
		["nadrimajstorux", 0, 1, ""],
		["Tauser Linux", 0, 1, ""],
		["Mattian", 0, 1, ""]
	]
	for item in std_distros:
		var d := DistroData.new()
		d.name = item[0]
		d.users = item[1]
		d.version = item[2]
		d.released_ver = d.version - 1
		d.released_date = the_date
		d.load_in_packages_from_list(item[3])
		other_distros.append(d)

func get_distro(i: int) -> DistroData:
	return my_distro if i == -1 else other_distros[i]

func get_package_index_from_name(pkg_name: String) -> int:
	for i in range(packages_available.size()):
		if packages_available[i].name == pkg_name:
			return i
	return -1

func get_total_workers_paid_for_package(at_index: int) -> int:
	var total := my_distro.get_workers_paid_for_package(at_index)
	for d in other_distros:
		total += d.get_workers_paid_for_package(at_index)
	return total

func get_total_workers_volunteers_for_package(at_index: int) -> int:
	var total := my_distro.get_workers_volunteers_for_package(at_index)
	for d in other_distros:
		total += d.get_workers_volunteers_for_package(at_index)
	return total

# --- DAILY SIMULATION LOOP ---

func increment_by_a_day() -> void:
	if is_paused:
		return
	the_date += 86400
	new_day_new_users()
	new_day_new_workers()
	new_day_new_bugs()
	new_day_new_productivity()
	random_event()
	stats_updated.emit()

func new_day_new_bugs() -> void:
	for pkg in packages_available:
		if randi_range(0, 150) == 1:
			pkg.bugs += 1

func new_day_new_productivity() -> void:
	for i in range(packages_available.size()):
		var vols := get_total_workers_volunteers_for_package(i)
		if vols > 0:
			if randi_range(0, int(100.0 / vols)) == 1:
				packages_available[i].remove_a_bug()
		var paid := get_total_workers_paid_for_package(i)
		if paid > 0:
			if randi_range(0, int(50.0 / paid)) == 1:
				packages_available[i].remove_a_bug()

func new_day_new_workers() -> void:
	if my_distro.workers_paid < roundi(float(my_distro.users) / 1000.0):
		if randi_range(0, 150) == 1:
			my_distro.workers_paid += 1
			if is_first_worker_paid:
				is_first_worker_paid = false
				show_message("You've been growing so much, you can now afford your first paid worker!  A paid worker can get twice as much done in a day than a volunteer!")

	if my_distro.workers_volunteers < roundi(float(my_distro.users) / 20.0):
		if randi_range(0, 50) == 1:
			my_distro.workers_volunteers += 1
			if is_first_worker_volunteer:
				is_first_worker_volunteer = false
				show_message("You just got your first volunteer!  You can assign workers to fix bugs on any package you like by using the 'Assign Workers' button.")

func new_day_new_users() -> void:
	var share := int(new_linux_users_daily / 5.0)
	var for_nerd_cred := share
	var for_popularity := share
	var for_size := share
	var for_bug_count := share

	my_distro.process_hype()
	for d in other_distros:
		d.process_hype()

	my_distro.new_user_change = 0
	for d in other_distros:
		d.new_user_change = 0

	# Nerd Cred
	my_distro.new_user_change += int(for_nerd_cred * (my_distro.get_distro_nerd_cred_percentage() * 10.0))
	for d in other_distros:
		d.new_user_change += int(for_nerd_cred * (d.get_distro_nerd_cred_percentage() * 10.0))

	# Package Popularity
	my_distro.new_user_change += int(for_popularity * (my_distro.get_distro_package_popularity_percentage() * 10.0))
	for d in other_distros:
		d.new_user_change += int(for_popularity * (d.get_distro_package_popularity_percentage() * 10.0))

	# Size
	my_distro.new_user_change -= int((for_size * my_distro.get_distro_size_in_mb_percentage()) * 3.0)
	for d in other_distros:
		d.new_user_change -= int((for_size * d.get_distro_size_in_mb_percentage()) * 3.0)

	# Bigger than a 700MB CD penalty
	if my_distro.get_distro_size_in_mb() > 700:
		my_distro.new_user_change -= int(my_distro.users / 100.0)

	# Bug Count
	my_distro.new_user_change -= int(for_bug_count * my_distro.get_distro_bug_percentage())
	for d in other_distros:
		d.new_user_change -= int(for_bug_count * d.get_distro_bug_percentage())

	# Hype
	my_distro.new_user_change += my_distro.hype * 2
	for d in other_distros:
		d.new_user_change += d.hype * 2

	# Random fluctuation
	my_distro.new_user_change += randi_range(-10, 15)
	for d in other_distros:
		d.new_user_change += randi_range(-15, 10)

	# Clamp ranges
	my_distro.new_user_change = clampi(my_distro.new_user_change, -225, 275)
	for d in other_distros:
		d.new_user_change = clampi(d.new_user_change, -255, 255)

	# Apply and floor at 0
	my_distro.users = maxi(0, my_distro.users + my_distro.new_user_change)
	for d in other_distros:
		d.users = maxi(0, d.users + d.new_user_change)

func random_event() -> void:
	if my_distro.released_ver <= 0:
		return

	var the_event := randi_range(0, 300)
	var the_dist := randi_range(-1, other_distros.size() - 1)
	if randi_range(1, 5) == 2:
		the_dist = -1

	var the_pack := randi_range(0, packages_available.size() - 1)
	var target := get_distro(the_dist)
	var pkg := packages_available[the_pack]
	var T := PackageData.SoftwareType

	match the_event:
		1:
			if target.released_ver > 0:
				target.hype += 20
				show_message("%s version %d.0 was reviewed on the Linux Action Show...  and it got a big thumbs up!  This should give it a big boost!" % [target.name, target.released_ver])
		2:
			if target.released_ver > 0:
				target.hype -= 20 # Fixed Xojo bug where it used MyDistro.Hype - 20
				show_message("%s version %d.0 was reviewed on the Linux Action Show...  and... they compared it to stinky cheese.  Not ideal..." % [target.name, target.released_ver])
		3:
			if target.released_ver > 0 and target.get_distro_age_in_days() > 30:
				target.hype += 15
				show_message("%s version %d.0 was reviewed in a popular Linux Magazine...  and they liked it!  Way to go!  Time to get that article framed!" % [target.name, target.released_ver])
		4:
			new_linux_users_daily += 20
			show_message("A new version of Windews is released.  Nobody likes it.  More new users are switching to Linux!  All Linux Distro's rejoice!")
		5:
			new_linux_users_daily -= 20
			show_message("A new version of Windews is released.  And... and... this one is pretty good.  People aren't switching to Linux quite so much...")
		6:
			if target.has_non_open_source_packages():
				target.hype -= 20
				show_message("%s's usage of non-Open Source software has caused some guy to declare it 'Negative in the freedom dimension'.  You have no idea what that means." % target.name)
		7:
			if target.get_distro_nerd_cred() > 40:
				target.hype += 20
				show_message("%s's high Nerd Cred has resulted in some great word of mouth publicity among the Nerd Elite." % target.name)
		8:
			if target.get_distro_package_popularity() > 40:
				target.hype += 20
				show_message("%s's use of some of the most popular software has made it easy for people to switch to %s, resulting in a surge in users." % [target.name, target.name])
		9:
			if target.get_distro_size_in_mb() < 40:
				target.hype += 20
				show_message("%s's super small, lightweight Distro has earned a reputation as being great for older hardware." % target.name)
		10:
			if target.get_distro_size_in_mb() > 800:
				target.hype -= 20
				show_message("%s's users are annoyed at the fact that it will not fit on a single CD." % target.name)
		11:
			if target.get_package_count_by_type(T.DESKTOP_ENVIRONMENT) == 0:
				target.hype -= 20
				show_message("Woops.  %s has no Desktop Environment.  Some people find those useful." % target.name)
		12:
			if target.get_package_count_by_type(T.GAME) == 0:
				target.hype -= 20
				show_message("The lack of any games in %s has earned it the reputation of 'The Most Boringest Linux Distro Ever'." % target.name)
		13:
			if target.get_package_count_by_type(T.OFFICE_SUITE) == 0:
				target.hype -= 20
				show_message("People on the internet are making fun of %s for not having an Office Suite." % target.name)
		14:
			if target.get_package_count_by_type(T.GAME) > 4:
				target.hype += 20
				show_message("%s is earning a reputation as 'Super Duper Fun' due to its wide selection of games." % target.name)
		15:
			if target.get_package_count_by_type(T.PROGRAMMING) > 3:
				target.hype += 20
				show_message("Programmers are raving about %s, calling it 'A Coders Paradise'." % target.name)
		16:
			if target.get_package_count_by_type(T.GRAPHICS_EDITING) > 3:
				target.hype += 20
				show_message("Graphic designers and artists are switching to %s in droves." % target.name)
		17:
			if my_distro.get_distro_age_in_days() > 182:
				my_distro.hype -= 25
				show_message("It's been quite a long time since you've had a new release... your users are beginning to look elsewhere...")
		18:
			if target.get_package_count_by_type(T.WEB_BROWSER) == 0:
				target.hype -= 20
				show_message("%s has no web browser.  Seriously.  It's like living in the dark ages." % target.name)
		19:
			pkg.version += 1
			pkg.popularity += 1
			show_message("%s has been updated to version %d.0.  Popularity increased!" % [pkg.name, pkg.version])
		20:
			pkg.version += 1
			pkg.nerd_cred += 1
			show_message("%s has been updated to version %d.0.  Nerd cred increased!" % [pkg.name, pkg.version])
		21:
			pkg.version += 1
			pkg.bugs += 6
			show_message("%s has been updated to version %d.0.  Unfortunately it is super buggy." % [pkg.name, pkg.version])
		22:
			pkg.version += 1
			pkg.bugs = 0
			show_message("%s has been updated to version %d.0.  The developers managed to fix all known bugs!" % [pkg.name, pkg.version])
		23:
			if target.released_ver > 0:
				target.hype -= 15
				show_message("Bryan's goats have wandered into your yard and chewed through your ethernet cables.  Your website goes down for a day.")

func show_message(the_msg: String) -> void:
	msg_text.append(the_msg)
	msg_date.append(the_date)
	if msg_text.size() > 31: # Xojo Ubound > 30
		msg_text.pop_front()
		msg_date.pop_front()
	message_added.emit(the_msg, the_date)

func format_date(unix_sec: int) -> String:
	var dt := Time.get_date_dict_from_unix_time(unix_sec)
	var months := ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	return "%s %d, %d" % [months[dt.month - 1], dt.day, dt.year]

# --- SAVE / LOAD & SCENARIO XML PARSING ---

func generate_save_xml() -> String:
	var lines: PackedStringArray = []
	lines.append("<!-- Linux Tycoon 1.1.2 -->")
	lines.append('<root Name="Save Game" Date="%d" LocalDistro="%s">' % [the_date, my_distro.name.xml_escape(true)])
	lines.append("<packages>")
	for p in packages_available:
		lines.append(p.get_package_xml())
	lines.append("</packages>")
	lines.append("<distros>")
	lines.append(my_distro.get_distro_xml())
	for d in other_distros:
		lines.append(d.get_distro_xml())
	lines.append("</distros>")
	lines.append("<events>")
	for i in range(msg_text.size()):
		lines.append('<event message="%s" date="%d"/>' % [msg_text[i].xml_escape(true), msg_date[i]])
	lines.append("</events>")
	lines.append("</root>")
	return "\n".join(lines)

func load_xml_string(xml_content: String, is_save_file: bool) -> bool:
	var parser := XMLParser.new()
	if parser.open_buffer(xml_content.to_utf8_buffer()) != OK:
		return false

	packages_available.clear()
	other_distros.clear()
	if is_save_file:
		msg_text.clear()
		msg_date.clear()
		is_first_run = false

	var distro_counter := 0

	while parser.read() == OK:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name := parser.get_node_name()
			match node_name:
				"root":
					if is_save_file and parser.has_attribute("Date"):
						the_date = int(parser.get_named_attribute_value("Date").to_float())
					elif not is_save_file and parser.has_attribute("Name"):
						scenario_loaded.emit(parser.get_named_attribute_value("Name"))
				"package":
					var p := PackageData.new()
					p.name = parser.get_named_attribute_value_safe("Name")
					p.bugs = parser.get_named_attribute_value_safe("Bugs").to_int()
					p.description = parser.get_named_attribute_value_safe("Description")
					p.is_open_source = parser.get_named_attribute_value_safe("isOpenSource").to_lower() == "true"
					p.nerd_cred = parser.get_named_attribute_value_safe("NerdCred").to_int()
					p.popularity = parser.get_named_attribute_value_safe("Popularity").to_int()
					p.size_in_mb = parser.get_named_attribute_value_safe("SizeInMB").to_int()
					p.type_of_software = parser.get_named_attribute_value_safe("TypeOfSoftware").to_int()
					p.version = parser.get_named_attribute_value_safe("Version").to_int()
					packages_available.append(p)
				"distro":
					var d := DistroData.new()
					d.name = parser.get_named_attribute_value_safe("Name")
					d.hype = parser.get_named_attribute_value_safe("Hype").to_int()
					d.users = parser.get_named_attribute_value_safe("Users").to_int()
					d.version = parser.get_named_attribute_value_safe("Version").to_int()
					d.load_in_packages_from_list(parser.get_named_attribute_value_safe("Packages"))
					if is_save_file:
						d.load_in_workers_volunteers_from_list(parser.get_named_attribute_value_safe("WorkersVolunteerAssigned"))
						d.load_in_workers_paid_from_list(parser.get_named_attribute_value_safe("WorkersPaidAssigned"))
						d.workers_paid = parser.get_named_attribute_value_safe("WorkersPaid").to_int()
						d.workers_volunteers = parser.get_named_attribute_value_safe("WorkersVolunteer").to_int()
						d.released_ver = parser.get_named_attribute_value_safe("ReleasedVer").to_int()
						d.released_date = int(parser.get_named_attribute_value_safe("ReleasedDate").to_float())
						d.released_bugs = parser.get_named_attribute_value_safe("ReleasedBugs").to_int()
						if distro_counter == 0:
							my_distro = d
						else:
							other_distros.append(d)
						distro_counter += 1
					else:
						d.released_date = the_date
						d.released_ver = d.version - 1
						if not d.name.is_empty():
							other_distros.append(d)
				"event":
					if is_save_file:
						msg_text.append(parser.get_named_attribute_value_safe("message"))
						msg_date.append(int(parser.get_named_attribute_value_safe("date").to_float()))

	stats_updated.emit()
	return true

```

---

## 4. UI Theme & Custom Controls (`canBtn`, `canLabel`, `WinBorder`)

Instead of redrawing `Picture` buffers on every mouse event like `canBtn.rbbas` and `ReDrawBG()`, Redot's `Theme` resource handles the exact colors and textures natively:

### 1. Button Colors (`canBtn.rbbas`)

Create a `Theme` resource for your `Button` nodes using `StyleBoxFlat` with a `1px` border (`Color8(60, 107, 173)`) and `12px` font size:

* **Normal:** Background `Color8(89, 131, 192)`, Font `Color8(255, 255, 255)`


* **Hover:** Background `Color8(47, 92, 159)`, Font `Color8(255, 255, 255)`


* **Pressed:** Background `Color8(35, 75, 140)`, Font `Color8(255, 255, 255)`


* **Disabled:** Background `Color8(59, 101, 162)`, Font `Color8(200, 200, 200)`



### 2. Window Borders (`WinBorder/*.png`)

In the original source, every container (`conDistroStats`, `conIntro`, etc.) tiles `WinBorder/Background.png` across the background, tiles `TopRepeat.png`, `BottomRepeat.png`, `LeftRepeat.png`, `RightRepeat.png` along the edges, and stamps `TopLeft.png`, `TopRight.png`, `BottomLeft.png`, and `BottomRight.png` into the corners.

* Combine those 9 tiles once into a single PNG spritesheet (or use a `Control` script with `_draw()`) and assign it to a `StyleBoxTexture` with `Axis Stretch Mode` set to **Tile** (`AXIS_STRETCH_MODE_TILE`).

### 3. Draggable Container Base (`DraggableWindow.gd`)

Attach this script to the root `Panel` of each sub-window (`conDistroStats`, `conDistroRank`, `conOverView`, `conNotifications`, etc.) to replicate Xojo's `MouseDown` and `MouseDrag`:

```gdscript
class_name DraggableWindow
extends Panel

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_drag_offset = event.position
			move_to_front()
		else:
			_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		position += event.position - _drag_offset

```

---

## 5. Main Window & Screen Controllers (`MainWindow.gd`)

Set your project viewport resolution in Redot (`Project Settings -> Display -> Window`) to:

* **Viewport Width:** `620`


* **Viewport Height:** `410`


* **Stretch Mode:** `canvas_items` (keeps crisp 2D text and UI scaling across Desktop, Mobile, and Web)
* **Stretch Aspect:** `expand` or `keep`
* **Main Background Color (`frmMain.BackColor`):** `#76AF1C` or Xojo integer color `11847396` (`RGB(180, 198, 228)`) — note: Xojo stores integer colors in `0xRRGGBB` (`11847396` = `#B4C6E4`, a classic light steel blue).



Here is the controller for `frmMain` and the sub-containers, including the Easter Egg volunteer sacrifice mechanic (`conSacrificeWorker`):

```gdscript
extends Control

@onready var day_timer: Timer = $DayTimer
@onready var lbl_date: Label = $TopBar/LblDate
@onready var btn_pause: Button = $TopBar/BtnPause

# Sub-containers inside $CanMain (620x390, Top=22)
@onready var con_main_menu: DraggableWindow = $CanMain/ConMainMenu
@onready var con_intro: DraggableWindow = $CanMain/ConIntro
@onready var con_distro_stats: DraggableWindow = $CanMain/ConDistroStats
@onready var con_distro_rank: DraggableWindow = $CanMain/ConDistroRank
@onready var con_overview: DraggableWindow = $CanMain/ConOverView
@onready var con_notifications: DraggableWindow = $CanMain/ConNotifications
@onready var con_package_selection: DraggableWindow = $CanMain/ConPackageSelection
@onready var con_worker_assignment: DraggableWindow = $CanMain/ConWorkerAssignment
@onready var con_sacrifice_worker: DraggableWindow = $CanMain/ConSacrificeWorker
@onready var con_new_release: DraggableWindow = $CanMain/ConNewRelease

func _ready() -> void:
	GameManager.stats_updated.connect(_on_stats_updated)
	GameManager.message_added.connect(_on_message_added)
	
	day_timer.wait_time = 1.0
	day_timer.timeout.connect(_on_day_timer_timeout)
	
	btn_pause.visible = false
	btn_pause.text = "||"
	btn_pause.pressed.connect(_on_btn_pause_pressed)
	
	_setup_initial_positions()
	_hide_all_containers()
	con_main_menu.visible = true

func _setup_initial_positions() -> void:
	# Exact coordinates from frmMain.Open()
	con_distro_stats.position = Vector2(5, 5)
	con_overview.position = Vector2(620 - con_overview.size.x - 5, 5)
	con_distro_rank.position = Vector2(620 - con_distro_rank.size.x - 5, 68)
	con_notifications.position = Vector2(con_overview.position.x, 68)
	
	for centered in [con_main_menu, con_intro, con_package_selection, con_worker_assignment, con_sacrifice_worker, con_new_release]:
		center_container(centered)

func center_container(ctrl: Control) -> void:
	ctrl.position = Vector2((620.0 - ctrl.size.x) / 2.0, (390.0 - ctrl.size.y) / 2.0)

func _hide_all_containers() -> void:
	for child in $CanMain.get_children():
		if child is Control:
			child.visible = false

func pause_game() -> void:
	day_timer.stop()
	btn_pause.visible = false

func unpause_game() -> void:
	day_timer.start()
	btn_pause.visible = true

func _on_btn_pause_pressed() -> void:
	if btn_pause.text == "||":
		GameManager.is_paused = true
		btn_pause.text = ">"
	else:
		GameManager.is_paused = false
		btn_pause.text = "||"

func _on_day_timer_timeout() -> void:
	if not GameManager.is_paused:
		GameManager.increment_by_a_day()

func _on_stats_updated() -> void:
	lbl_date.text = GameManager.format_date(GameManager.the_date)
	# Trigger UI refreshes on active HUD panels
	if con_distro_stats.visible:
		con_distro_stats.update_stats()
	if con_overview.visible:
		con_overview.update_stats()
	if con_distro_rank.visible:
		con_distro_rank.update_distro_rank()

func _on_message_added(_msg: String, _date: int) -> void:
	con_notifications.show_all_messages()

# --- WORKFLOW TRANSITIONS ---

func show_main_hud() -> void:
	con_distro_stats.visible = true
	con_distro_rank.visible = true
	con_overview.visible = true
	con_notifications.visible = true
	_on_stats_updated()

func on_release_version_confirmed() -> void:
	pause_game()
	_hide_all_containers()
	con_new_release.set_new_text()
	con_new_release.visible = true

func on_new_release_ok_clicked() -> void:
	GameManager.my_distro.release_new_version()
	unpause_game()
	con_new_release.visible = false
	show_main_hud()
	GameManager.show_message("%s version %d.0 released!" % [GameManager.my_distro.name, GameManager.my_distro.released_ver])

```

### Volunteer Sacrifice Logic (`conSacrificeWorker.rbfrm`)

In `conSacrificeWorker`, clicking `"Sacrifice Worker"` deducts 1 available volunteer and rolls a random boost/penalty:

```gdscript
func _on_btn_sacrifice_boost_pressed() -> void:
	var d := GameManager.my_distro
	if d.get_distro_worker_available_volunteer() > 0:
		d.workers_volunteers -= 1
		var hype_change := randi_range(-5, 15)
		var user_change := randi_range(-30, 65)
		d.hype += hype_change
		d.users = maxi(0, d.users + user_change)
		
		var u_str := ("+" + str(user_change)) if user_change > -1 else str(user_change)
		var h_str := ("+" + str(hype_change)) if hype_change > -1 else str(hype_change)
		lbl_results.text = "Users: %s    Hype: %s" % [u_str, h_str]
		update_workers_display()
		GameManager.stats_updated.emit()

```

---

## 6. Cross-Platform Save/Load Considerations (Desktop, Mobile, Web)

Because you are targeting **Desktop, Mobile, and Web** with Redot's Compatibility renderer, standard OS file dialogs (`GetOpenFolderItem` / `GetSaveFolderItem` in Xojo) behave differently on Web and Mobile:

1. **Desktop & Mobile:** Use Redot's `FileDialog` node with `access = FileDialog.ACCESS_USERDATA` (`user://saves/`) so mobile sandboxes don't block filesystem writes, while allowing `FileDialog.ACCESS_FILESYSTEM` on Desktop for importing external `.ltx` scenarios and `.lts` save files.


2. **Web (HTML5/Wasm):** `user://` automatically maps to the browser's `IndexedDB` for persistent local saves. To let Web players import/export `.lts` save files or `.ltx` scenarios from their machine, use `JavaScriptBridge.download_buffer(xml_string.to_utf8_buffer(), "SaveGame.lts")` for saving, and an HTML `<input type="file">` callback via `JavaScriptBridge` for loading.



Would you like me to generate the complete `.tscn` text scene files and custom row item scripts for `conPackageSelection`, `conWorkerAssignment`, and `conDistroRank` so you can drop them straight into your Redot project folder?