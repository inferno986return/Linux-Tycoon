extends Node

signal stats_updated
signal message_added(msg_text: String, msg_date: int)
signal scenario_loaded(scenario_name: String)

var my_distro: DistroData
var other_distros: Array[DistroData] = []
var packages_available: Array[PackageData] = []

var triggered_milestones: Dictionary = {} # Acts as a set: { "rank_1": true, ... }
var is_first_run: bool = true
var is_first_worker_paid: bool = true
var is_first_worker_volunteer: bool = true
var is_paused: bool = false
var new_linux_users_daily: int = 50
var max_media_mb: int = 700
var active_scenario_name: String = "Standard"
var active_scenario_raw: String = ""
var the_date: int = 0 # Unix timestamp in seconds

var start_date: int = 0
var has_entered_dvd_era: bool = false

var msg_text: Array[String] = []
var msg_date: Array[int] = []

func has_milestone(id: String) -> bool:
	return triggered_milestones.get(id, false)

func mark_milestone(id: String) -> void:
	triggered_milestones[id] = true

func trigger_milestone(id: String, message: String) -> bool:
	if has_milestone(id):
		return false
	mark_milestone(id)
	show_message(message)
	return true

func _ready() -> void:
	the_date = int(Time.get_unix_time_from_system())
	reset_new_game_state()

func reset_new_game_state() -> void:
	the_date = int(Time.get_unix_time_from_system())
	start_date = the_date
	has_entered_dvd_era = false
	is_first_run = true
	is_first_worker_paid = true
	is_first_worker_volunteer = true
	new_linux_users_daily = 50
	max_media_mb = 700
	msg_text.clear()
	msg_date.clear()

	my_distro = DistroData.new()
	my_distro.version = 1
	my_distro.released_ver = 0

	if not active_scenario_raw.is_empty():
		load_file_string(active_scenario_raw, false)
	else:
		build_initial_package_list()
		build_initial_distro_list()
	
	triggered_milestones.clear()

func build_initial_package_list() -> void:
	packages_available.clear()
	var T := PackageData.SoftwareType
	
	# Desktop Environments
	packages_available.append(PackageData.new("Midget", 2, "Lightweight, simple desktop environment.", true, 3, 20, 20, T.DESKTOP_ENVIRONMENT, 1))
	packages_available.append(PackageData.new("QDE", 3, "The Q Desktop Environment. Big. Slow. Lots and lots of desktop widgets.", true, 3, 10, 50, T.DESKTOP_ENVIRONMENT, 1))
	packages_available.append(PackageData.new("UCDE", 0, "The Ultra Confusing Desktop Environment. There are no icons. Only terminals.", true, 20, 1, 1, T.DESKTOP_ENVIRONMENT, 1))
	# Web Browsers
	packages_available.append(PackageData.new("FlamingRodent", 4, "A big, powerful web browser. Lots of features and lots of extensions.", true, 3, 15, 10, T.WEB_BROWSER, 1))
	packages_available.append(PackageData.new("ShmoogleShrome", 2, "Lightweight and superfast web browser.", true, 3, 10, 10, T.WEB_BROWSER, 1))
	packages_available.append(PackageData.new("Text-O-Web", 0, "A Text-only web browser that runs in the Terminal.", true, 20, 0, 1, T.WEB_BROWSER, 1))
	# Office Suites
	packages_available.append(PackageData.new("ReallyFreeOffice", 4, "A big, powerful office suite.", true, 5, 15, 60, T.OFFICE_SUITE, 1))
	packages_available.append(PackageData.new("SpAnDeX", 1, "Hard to use and complicated way to build documents.", true, 15, 2, 3, T.OFFICE_SUITE, 1))
	packages_available.append(PackageData.new("OkayOffice", 1, "This office suite... is pretty ok.", true, 10, 10, 40, T.OFFICE_SUITE, 1))
	# Games
	packages_available.append(PackageData.new("PenguinZoomer", 1, "Race around and pretend that penguins are like cars.", true, 3, 8, 20, T.GAME, 1))
	packages_available.append(PackageData.new("FragBlast4000", 2, "Fancy 3D graphics and fast paced shooting of other people.", false, 1, 15, 120, T.GAME, 1))
	packages_available.append(PackageData.new("BurstABubble", 0, "There are bubbles. You hate bubbles. Pop those bubbles.", true, 0, 20, 25, T.GAME, 1))
	packages_available.append(PackageData.new("JustCards", 0, "It's a card game.", true, 0, 5, 20, T.GAME, 1))
	packages_available.append(PackageData.new("TapYerToes", 1, "Tap your toes to the beat of very boring music.", true, 0, 1, 15, T.GAME, 1))
	packages_available.append(PackageData.new("CityMax", 2, "Design and run a very fancy city.", false, 0, 15, 120, T.GAME, 1))
	packages_available.append(PackageData.new("CouchTrainer", 3, "Teach a couch how to be a good couch.", true, 0, 5, 65, T.GAME, 1))
	# Graphics Editing
	packages_available.append(PackageData.new("PixelPusher", 0, "A very simple image editor.", true, 1, 2, 2, T.GRAPHICS_EDITING, 1))
	packages_available.append(PackageData.new("The Dork", 2, "Robust, powerful graphics editor.", true, 5, 12, 65, T.GRAPHICS_EDITING, 1))
	packages_available.append(PackageData.new("Pictures-In-Folders", 0, "A simple photo gallery for organizing images.", true, 0, 8, 8, T.GRAPHICS_EDITING, 1))
	packages_available.append(PackageData.new("PainterMcPaint", 1, "Good for painting. Bad for anything else.", true, 0, 3, 150, T.GRAPHICS_EDITING, 1))
	# Programming
	packages_available.append(PackageData.new("LunarBlackout", 4, "A good, flexible integrated development environment.", true, 10, 4, 120, T.PROGRAMMING, 1))
	packages_available.append(PackageData.new("JustPascal", 0, "Pascal programming tools.", true, 11, 1, 40, T.PROGRAMMING, 1))
	packages_available.append(PackageData.new("Lunduke Development Kit", 0, "The most awesome programming language. Ever.", true, 15, 15, 10, T.PROGRAMMING, 1))
	packages_available.append(PackageData.new("LargeTalk", 0, "Considered to be the Grand-daddy of programming tools.", true, 20, 2, 10, T.PROGRAMMING, 1))
	packages_available.append(PackageData.new("EchsCode", 7, "This is a terrible development environment. Nobody likes this or wants to use it.", false, 0, 0, 900, T.PROGRAMMING, 1))
	# Communication
	packages_available.append(PackageData.new("Mailinator", 1, "Super advanced email client.", true, 0, 12, 80, T.COMMUNICATION, 1))
	packages_available.append(PackageData.new("Chatchatchat", 1, "You know. For chatting.", true, 0, 5, 50, T.COMMUNICATION, 1))
	packages_available.append(PackageData.new("Fir", 0, "Terminal-only email client. ", true, 5, 1, 1, T.COMMUNICATION, 1))
	packages_available.append(PackageData.new("IRC-o-Matic", 3, "The only IRC client that matters.", true, 4, 2, 6, T.COMMUNICATION, 1))
	# Utility
	packages_available.append(PackageData.new("Calculator", 0, "You do want a calculator, don't you?", true, 0, 1, 1, T.UTILITY, 1))
	# Multimedia
	packages_available.append(PackageData.new("Video Player Thing", 1, "Plays videos. Sometimes. Then it crashes.", true, 0, 1, 10, T.MULTIMEDIA, 1))
	packages_available.append(PackageData.new("vidCastGrabber", 1, "Downloads and plays video podcasts.", true, 0, 3, 55, T.MULTIMEDIA, 1))
	packages_available.append(PackageData.new("emTeeVee", 2, "Automatically generates music videos.", false, 0, 2, 120, T.MULTIMEDIA, 1))

func build_initial_distro_list() -> void:
	other_distros.clear()
	# Matches StandardScenario embedded XML (which conMainMenu.Open loads)
	var std_distros := [
		["Ooboontoo", 100000, 12, "Midget;FlamingRodent;ReallyFreeOffice;PenguinZoomer;JustCards;Pictures-In-Folders;Mailinator;Chatchatchat;Calculator;Video Player"],
		
		# --- NEW: Competitively Configured LCOS ---
		["LCOS", 85000, 2, "Midget;ShmoogleShrome;OkayOffice;CityMax;FragBlast4000;The Dork;PixelPusher;Lunduke Development Kit;IRC-o-Matic;Calculator"],
		# ------------------------------------------

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

	# --- NEW: 10-Year DVD Era Transition (3650 days) ---
	if not has_entered_dvd_era and (the_date - start_date) >= 3650 * 86400:
		has_entered_dvd_era = true
		max_media_mb = 4700
		triggered_milestones.erase("media_size_warn")
		for pkg in packages_available:
			var growth := randf_range(1.10, 1.20)
			pkg.size_in_mb = maxi(1, roundi(float(pkg.size_in_mb) * growth))
		show_message("10 years have passed! CD-ROMs are out and 4.7 GB DVDs are the new standard. Software bloat has kicked in—packages are 10-20% larger, but ISOs up to 4700 MB are now acceptable!")

	if my_distro.released_ver > 0:
		var my_rank := _get_my_rank()
		if my_rank <= 10:
			trigger_milestone("top_10", "Incredible! %s has just broken into the Top 10 on DistroRank! You're in the big leagues now!" % my_distro.name)
		if my_rank == 1:
			trigger_milestone("rank_1", "STOP THE PRESSES! %s is officially #1 on DistroRank! You've conquered the Linux world! (Try not to let it go to your head.)" % my_distro.name)
		if my_distro.users >= 100000:
			trigger_milestone("users_100k", "100,000 users! %s isn't just a hobby project anymore—you're a legitimate Linux powerhouse!" % my_distro.name)
		if my_distro.released_ver >= 10:
			trigger_milestone("ver_10", "Version 10.0 of %s! Most distros get abandoned after version 1.2. Your stubbornness is truly inspiring." % my_distro.name)
		if my_distro.packages_included.size() > 0 and my_distro.get_distro_bugs() == 0:
			trigger_milestone("zero_bugs", "Wow! Your workers just squashed the very last bug in %s! A zero-bug Linux distro... I never thought I'd see the day! (Enjoy it before they find more tomorrow.)" % my_distro.name)

	new_day_new_users()
	new_day_new_workers()
	new_day_new_bugs()
	new_day_new_productivity()
	random_event()

	stats_updated.emit()

func _get_my_rank() -> int:
	if my_distro == null:
		return 999
	var rank: int = 1
	for d in other_distros:
		if d.users > my_distro.users:
			rank += 1
	return rank

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
	# --- PAID WORKERS ---
	var target_paid := roundi(float(my_distro.users) / 1000.0)
	if my_distro.workers_paid < target_paid:
		if randi_range(0, 150) == 1:
			var shortfall := target_paid - my_distro.workers_paid
			var hired_amount := randi_range(1, mini(shortfall, 5))
			my_distro.workers_paid += hired_amount
			
			if is_first_worker_paid:
				is_first_worker_paid = false
				show_message("You've been growing so much, you can now afford your first paid worker!  A paid worker can get twice as much done in a day than a volunteer!")
			else:
				var s := "s" if hired_amount > 1 else ""
				var paid_msgs = [
					"You secured %d new paid worker%s today! Put them to work!",
					"Budget approved! We just hired %d paid worker%s to squash some bugs.",
					"Good news! %d new paid worker%s signed on this morning. Time to assign them to a package.",
					"%d new paid worker%s joined the payroll. Let's get them coding!"
				]
				show_message(paid_msgs.pick_random() % [hired_amount, s])

	# --- VOLUNTEERS ---
	var target_vol := roundi(float(my_distro.users) / 20.0)
	if my_distro.workers_volunteers < target_vol:
		if randi_range(0, 50) == 1:
			var shortfall := target_vol - my_distro.workers_volunteers
			var hired_amount := randi_range(1, mini(shortfall, 15)) 
			my_distro.workers_volunteers += hired_amount
			
			if is_first_worker_volunteer:
				is_first_worker_volunteer = false
				show_message("You just got your first volunteer!  You can assign workers to fix bugs on any package you like by using the 'Assign Workers' button.")
			else:
				var s := "s" if hired_amount > 1 else ""
				var vol_msgs = [
					"Awesome! %d new volunteer%s joined the project today. Assign them to a package to speed up bug fixes!",
					"The community is growing! %d new volunteer%s decided to help out today.",
					"Great news! We just got %d new volunteer%s offering their free time for the distro.",
					"%d open-source enthusiast%s just volunteered to join your ranks. Put them to good use!"
				]
				show_message(vol_msgs.pick_random() % [hired_amount, s])

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

	# Bigger than media limit penalty (700MB CD by default)
	if my_distro.get_distro_size_in_mb() > max_media_mb:
		my_distro.new_user_change -= int(my_distro.users / 100.0)
		trigger_milestone("media_size_warn", "The ISO for %s is over %d MB! It will no longer fit on standard media. Some users with older hardware might look elsewhere." % [my_distro.name, max_media_mb])

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

	# Roll 1: Encounter check (~7.6% daily chance, matching vanilla v1.1.2)
	if randi_range(1, 13) != 1:
		return

	# Roll 2: Draw 1 of all 60 events
	var the_event := randi_range(1, 60)

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
				show_message("%s version %d.0 was reviewed on the Linux Action Show... and it got a big thumbs up!  This should give it a big boost!" % [target.name, target.released_ver])
		2:
			if target.released_ver > 0:
				target.hype -= 20 # Fixed Xojo bug where it used MyDistro.Hype - 20
				show_message("%s version %d.0 was reviewed on the Linux Action Show... and... they compared it to stinky cheese. Not ideal..." % [target.name, target.released_ver])
		3:
			if target.released_ver > 0 and target.get_distro_age_in_days() > 30:
				target.hype += 15
				show_message("%s version %d.0 was reviewed in a popular Linux Magazine... and they liked it!  Way to go!  Time to get that article framed!" % [target.name, target.released_ver])
		4:
			new_linux_users_daily += 20
			show_message("A new version of Windews is released. Nobody likes it. More new users are switching to Linux!  All Linux Distros rejoice!")
		5:
			new_linux_users_daily -= 20
			show_message("A new version of Windews is released. And... and... this one is pretty good. People aren't switching to Linux quite so much...")
		6:
			if target.has_non_open_source_packages():
				target.hype -= 20
				show_message("%s's usage of non-Open Source software has caused some guy to declare it 'Negative in the freedom dimension'. You have no idea what that means." % target.name)
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
			if target.get_distro_size_in_mb() > max_media_mb + 100:
				target.hype -= 20
				var media_name := "DVD" if has_entered_dvd_era else "CD"
				show_message("%s's users are annoyed at the fact that it will not fit on a single %s." % [target.name, media_name])
		11:
			if target.get_package_count_by_type(T.DESKTOP_ENVIRONMENT) == 0:
				target.hype -= 20
				show_message("Woops. %s has no Desktop Environment. Some people find those useful." % target.name)
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
				show_message("%s has no web browser. Seriously. It's like living in the dark ages." % target.name)
		19:
			pkg.version += 1
			pkg.popularity += 1
			show_message("%s has been updated to version %d.0. Popularity increased!" % [pkg.name, pkg.version])
		20:
			pkg.version += 1
			pkg.nerd_cred += 1
			show_message("%s has been updated to version %d.0. Nerd cred increased!" % [pkg.name, pkg.version])
		21:
			pkg.version += 1
			pkg.bugs += 6
			show_message("%s has been updated to version %d.0. Unfortunately it is super buggy." % [pkg.name, pkg.version])
		22:
			pkg.version += 1
			pkg.bugs = 0
			show_message("%s has been updated to version %d.0. The developers managed to fix all known bugs!" % [pkg.name, pkg.version])
		23:
			if target.released_ver > 0:
				target.hype -= 15
				show_message("Bryan's goats have wandered into your yard and chewed through your Ethernet cables. Your website goes down for a day.")
		24:
			new_linux_users_daily += 15
			show_message("Someone on the internet declared this 'The Year of the Linux Desktop'—and weirdly, people actually believed them! Daily new Linux users increased!")
		25:
			if target.released_ver > 0:
				target.hype -= 15
				show_message("A 400-page forum flamewar broke out over %s's choice of init system. Nobody won, and everyone is exhausted." % target.name)
		26:
			if target.released_ver > 0:
				target.hype += 20
				show_message("Bryan did a 2-hour livestream ranting about how much he loves %s's retro aesthetics. Hype is surging!" % target.name)
		27:
			if target.released_ver > 0:
				target.hype -= 15
				show_message("%s switched to a new universal container package format. Apps now take 14 seconds to open a calculator." % target.name)
		28:
			if my_distro.released_ver > 0:
				my_distro.workers_paid += 1
				show_message("A mysterious wealthy Linux fan just donated enough money to fund 1 new paid worker for %s! Put them to work!" % my_distro.name)
		29:
			if target.released_ver > 0:
				target.hype -= 10
				show_message("%s's download mirrors melted under traffic. Half the internet is stuck at 99%% on the ISO." % target.name)
		30:
			if target.released_ver > 0 and target.get_distro_bugs() <= 3:
				target.hype += 20
				show_message("Users are praising %s for being 'rock solid' and 'actually working after an update.' What a concept!" % target.name)
		31:
			pkg.bugs += 4
			show_message("A critical zero-day vulnerability was discovered in %s! It even has its own logo and theme song. (+4 bugs)" % pkg.name)
		32:
			if target.released_ver > 0:
				target.users += 250
				show_message("A local school district just switched all their computer labs to %s! (+250 users)" % target.name)
		33:
			if my_distro.released_ver > 0:
				my_distro.hype += 15
				show_message("Bryan's goats wandered into a rival distro's server room instead of yours this time. Your uptime looks fantastic by comparison!")
		# --- MONOPOLY-STYLE CHANCE & COMMUNITY CHEST EVENTS ---
		34: # Chance (Bad): Social Media Defamation (-1% users)
			if target.released_ver > 0 and target.users > 0:
				var lost := maxi(1, roundi(float(target.users) * 0.01))
				target.users = maxi(0, target.users - lost)
				target.hype -= 15
				show_message("PR Disaster! A prominent %s maintainer posted something defamatory on social media. The backlash cost them %d users (1%%)!" % [target.name, lost])
		35: # Community Chest (Good): Viral Video (+1% users, +20 hype)
			if target.released_ver > 0:
				var gained := maxi(50, roundi(float(target.users) * 0.01))
				target.users += gained
				target.hype += 20
				show_message("A YouTuber's 'Why I Switched to %s' video just went viral! (+%d users, +20 hype)" % [target.name, gained])
		36: # Community Chest (Good): Weekend Bug-Squash-a-Thon
			if pkg.bugs > 0:
				var fixed := mini(pkg.bugs, 3)
				pkg.bugs -= fixed
				show_message("Volunteers hosted a weekend Bug-Squash-a-Thon for %s and squashed %d bugs!" % [pkg.name, fixed])
		37: # Chance: Patent Troll Lawsuit
			if my_distro.released_ver > 0:
				if my_distro.get_distro_worker_available_paid() > 0:
					my_distro.workers_paid -= 1
					show_message("A patent troll sued %s over 'clicking a button with a mouse.' Legal fees forced you to lay off 1 paid worker." % my_distro.name)
				else:
					my_distro.hype -= 15
					show_message("A patent troll threatened to sue %s. The community rallied, but the drama cost you 15 hype." % my_distro.name)
		38: # Community Chest (Good): University Adoption
			if target.released_ver > 0:
				target.users += 400
				target.hype += 10
				show_message("A major university's Computer Science department just standardized on %s for all lab machines! (+400 users)" % target.name)
		39: # Chance (Bad): Rogue Maintainer Push
			pkg.bugs += 5
			if target.released_ver > 0:
				target.hype -= 10
			show_message("A rogue maintainer pushed an untested Friday-afternoon commit to %s. (+5 bugs)" % pkg.name)
		40: # Community Chest (Good): Hackathon Volunteer Surge
			if my_distro.released_ver > 0:
				my_distro.workers_volunteers += 3
				show_message("A local Linux User Group hosted an install-fest for %s. 3 new volunteers signed up to help!" % my_distro.name)
		41: # The Great Windews Outage (CrowdStrike nod)
			new_linux_users_daily += 25
			if my_distro.released_ver > 0:
				my_distro.hype += 10
			show_message("A bad update to a prominent closed-source cybersecurity product has taken out every online copy of Windews with it installed. Airports and banks are blue-screening worldwide. Linux is completely unaffected! (+25 daily Linux users)")
		42: # Stealthy Backdoor Caught (XZ Utils nod)
			pkg.nerd_cred += 2
			if pkg.bugs > 0:
				pkg.bugs -= 1
			show_message("An eagle-eyed developer noticed a 500ms login delay and caught a stealthy backdoor in %s before it hit stable! The open-source community breathes a massive sigh of relief. (+2 Nerd Cred)" % pkg.name)
		43: # Boutique Hardware Deal
			if target.released_ver > 0:
				target.users += 350
				target.hype += 15
				show_message("A boutique laptop manufacturer just announced they are shipping %s pre-installed on all new hardware! (+350 users, +15 hype)" % target.name)
		44: # Dependency Drama
			pkg.bugs += 3
			show_message("A grumpy developer unpublished a 10-line helper library in a huff, briefly breaking builds for %s. (+3 bugs)" % pkg.name)
		45: # Magazine Cover Disc
			if target.released_ver > 0:
				target.users += 150
				target.hype += 10
				show_message("A popular print computer magazine included %s on this month's cover disc! Old-school readers are installing it in droves. (+150 users)" % target.name)
		46: # Minimalist Logo Backlash
			if target.released_ver > 0:
				target.hype -= 15
				show_message("%s replaced its beloved classic logo with a flat, minimalist triangle. Longtime fans are furious. (-15 hype)" % target.name)
		47: # Readable Documentation
			if target.released_ver > 0:
				target.users += 200
				target.hype += 15
				show_message("Someone actually wrote clear, beginner-friendly documentation for %s instead of just telling newcomers to 'RTFM.' People are thrilled! (+200 users, +15 hype)" % target.name)
		48: # Expired SSL Cert
			if target.released_ver > 0:
				target.hype -= 10
				target.users = maxi(0, target.users - 100)
				show_message("%s forgot to renew its website's SSL certificate. Visitors are greeted by a terrifying red browser warning. (-100 users, -10 hype)" % target.name)
		49: # Kernel Speedup
			if my_distro.released_ver > 0:
				my_distro.hype += 15
				show_message("A wizardly kernel hacker submitted a patch that shaved 15%% off boot times. %s feels snappier than ever! (+15 hype)" % my_distro.name)
		50: # Volunteer Burnout
			if my_distro.released_ver > 0:
				if my_distro.get_distro_worker_available_volunteer() > 0:
					my_distro.workers_volunteers -= 1
					show_message("One of your volunteers burned out after reading too many bug reports and moved to the mountains to raise llamas. (-1 volunteer)")
				else:
					my_distro.hype -= 10
					show_message("Your community forums got a bit spicy over a minor UI tweak. Everyone needs a nap. (-10 hype)")
		51: # Bad Magazine Review (DOS variant)
			if target.released_ver > 0 and target.get_distro_age_in_days() > 30:
				target.hype -= 15
				show_message("%s version %d.0 was reviewed in a popular Linux Magazine... and they hated it! Time to pretend that issue never existed." % [target.name, target.released_ver])
		52: # Wallpaper Controversy
			if target.released_ver > 0:
				target.hype -= 10
				show_message("The default wallpaper in %s sparked a 3-week Reddit argument over whether it's 'too corporate.' (-10 hype)" % target.name)
		53: # Retro Hardware Revival
			if target.released_ver > 0 and target.get_distro_size_in_mb() <= 350:
				target.users += 200
				target.hype += 10
				show_message("A retro-computing enthusiast got %s running smoothly on a 15-year-old ThinkPad! Nostalgic nerds are flocking to it. (+200 users, +10 hype)" % target.name)
		54: # Conference Swag Hit
			if my_distro.released_ver > 0:
				my_distro.hype += 15
				my_distro.users += 150
				show_message("Your %s laptop stickers were the hottest item at this year's LinuxFest! (+150 users, +15 hype)" % my_distro.name)
		55: # Accidental Dependency Bloat
			pkg.size_in_mb += 15
			show_message("A developer accidentally bundled an entire web browser engine inside %s just to render a settings menu. (+15 MB)" % pkg.name)
		56: # Upstream Rewrite in Rust/Go
			pkg.bugs = maxi(0, pkg.bugs - 2)
			pkg.nerd_cred += 2
			show_message("Someone rewrote %s from scratch in a memory-safe language over a long weekend! (-2 bugs, +2 Nerd Cred)" % pkg.name)
		57: # Government Migration
			if target.released_ver > 0:
				target.users += 500
				target.hype += 15
				show_message("A small European city just announced it's migrating all municipal desktops to %s! (+500 users, +15 hype)" % target.name)
		58: # Broken Audio Update
			if target.released_ver > 0:
				target.hype -= 15
				show_message("An audio server update broke sound for half of %s's users. Everyone is furiously editing config files. (-15 hype)" % target.name)
		59: # Corporate Sponsorship
			if my_distro.released_ver > 0:
				my_distro.workers_paid += 1
				my_distro.hype += 10
				show_message("A friendly tech company just became a Platinum Sponsor of %s and funded 1 new paid worker! (+1 paid worker, +10 hype)" % my_distro.name)
		60: # Meme Distro Spike
			if target.released_ver > 0:
				target.users += 300
				target.hype += 10
				show_message("A hilarious meme about %s hit the front page of the internet. People are installing it 'ironically'—and actually liking it! (+300 users, +10 hype)" % target.name)

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

# --- SAVE / LOAD & SCENARIO PARSING (JSON + LEGACY XML) ---

func load_file_string(content: String, is_save_file: bool, fallback_name: String = "Custom Scenario") -> bool:
	var trimmed := content.trim_prefix("\uFEFF").strip_edges()
	if trimmed.is_empty():
		push_warning("Linux Tycoon: Loaded file is empty.")
		return false
	if not is_save_file:
		active_scenario_raw = trimmed
	if trimmed.begins_with("{"):
		return load_json_string(trimmed, is_save_file, fallback_name)
	elif trimmed.begins_with("<"):
		return load_xml_string(trimmed, is_save_file, fallback_name)
	push_warning("Linux Tycoon: Unrecognized file format (starts with: '%s')" % trimmed.left(10))
	return false

func generate_save_json() -> String:
	var pkgs: Array[Dictionary] = []
	for p in packages_available:
		pkgs.append(p.to_dict())

	var distros: Array[Dictionary] = [my_distro.to_dict()]
	for d in other_distros:
		distros.append(d.to_dict())

	var events: Array[Dictionary] = []
	for i in range(msg_text.size()):
		events.append({"message": msg_text[i], "date": msg_date[i]})

	var payload := {
		"format_version": 1,
		"name": "Save Game",
		"scenario": active_scenario_name,
		"date": the_date,
		"local_distro": my_distro.name,
		"rules": {
			"daily_users": new_linux_users_daily,
			"max_media_mb": max_media_mb,
			"start_date": start_date,
			"has_entered_dvd_era": has_entered_dvd_era
		},
		"packages": pkgs,
		"distros": distros,
		"events": events,
		"milestones": triggered_milestones.keys()
	}
	return JSON.stringify(payload, "\t")

func load_json_string(json_content: String, is_save_file: bool, fallback_name: String = "Custom Scenario") -> bool:
	var parsed = JSON.parse_string(json_content)
	if not (parsed is Dictionary):
		push_warning("Linux Tycoon: Failed to parse JSON.")
		return false

	packages_available.clear()
	other_distros.clear()
	triggered_milestones.clear()
	for m in parsed.get("milestones", []):
		mark_milestone(str(m)) # Make sure this is pure tabs

	if is_save_file:
		msg_text.clear()
		msg_date.clear()
		is_first_run = false

	var rules = parsed.get("rules", {})
	if rules is Dictionary:
		if rules.has("daily_users"):
			new_linux_users_daily = int(rules["daily_users"])
		if rules.has("max_media_mb"):
			max_media_mb = int(rules["max_media_mb"])
		if rules.has("has_entered_dvd_era"):
			has_entered_dvd_era = bool(rules["has_entered_dvd_era"])
		if rules.has("start_date"):
			var sd = rules["start_date"]
			var parsed_start := int(Time.get_unix_time_from_datetime_string(sd)) if sd is String else int(sd)
			start_date = parsed_start
			if not is_save_file:
				the_date = parsed_start

	if is_save_file:
		if parsed.has("date"):
			the_date = int(parsed["date"])
		if parsed.has("scenario"):
			active_scenario_name = str(parsed["scenario"])
	else:
		var s_name := str(parsed.get("name", "")).strip_edges()
		active_scenario_name = s_name if not s_name.is_empty() else fallback_name
		scenario_loaded.emit(active_scenario_name)

	for p_dict in parsed.get("packages", []):
		if p_dict is Dictionary:
			packages_available.append(PackageData.from_dict(p_dict))

	var distro_counter := 0
	for d_dict in parsed.get("distros", []):
		if d_dict is Dictionary:
			var d := DistroData.from_dict(d_dict, is_save_file)
			if is_save_file:
				if distro_counter == 0:
					my_distro = d
				else:
					other_distros.append(d)
				distro_counter += 1
			else:
				if not d.name.is_empty():
					other_distros.append(d)

	if is_save_file:
		for ev in parsed.get("events", []):
			if ev is Dictionary:
				msg_text.append(str(ev.get("message", "")))
				msg_date.append(int(ev.get("date", the_date)))

	_sync_loaded_state_flags()
	stats_updated.emit()
	return true

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

func load_xml_string(xml_content: String, is_save_file: bool, fallback_name: String = "Custom Scenario") -> bool:
	var parser := XMLParser.new()
	if parser.open_buffer(xml_content.to_utf8_buffer()) != OK:
		return false

	packages_available.clear()
	other_distros.clear()
	if is_save_file:
		triggered_milestones.clear()
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
						start_date = the_date
					elif not is_save_file:
						var s_name := parser.get_named_attribute_value_safe("Name")
						if s_name.is_empty():
							s_name = parser.get_named_attribute_value_safe("name")
						active_scenario_name = s_name if not s_name.is_empty() else fallback_name
						scenario_loaded.emit(active_scenario_name)
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

	_sync_loaded_state_flags()
	stats_updated.emit()
	return true

func _sync_loaded_state_flags() -> void:
	if my_distro == null:
		return

	if my_distro.workers_paid > 0:
		is_first_worker_paid = false
		mark_milestone("first_paid")
	if my_distro.workers_volunteers > 0:
		is_first_worker_volunteer = false
		mark_milestone("first_volunteer")
	if my_distro.get_distro_size_in_mb() > max_media_mb:
		mark_milestone("media_size_warn")

	if my_distro.released_ver > 0:
		var rank := _get_my_rank()
		if rank <= 10:
			mark_milestone("top_10")
		if rank == 1:
			mark_milestone("rank_1")
		if my_distro.users >= 100000:
			mark_milestone("users_100k")
		if my_distro.released_ver >= 10:
			mark_milestone("ver_10")
		if my_distro.packages_included.size() > 0 and my_distro.get_distro_bugs() == 0:
			mark_milestone("zero_bugs")