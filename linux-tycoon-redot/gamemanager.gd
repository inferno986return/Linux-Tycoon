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
			show_message("A new version of Windews is released.  Nobody likes it.  More new users are switching to Linux!  All Linux Distros rejoice!")
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

	# --- NEW: Fix the Deja Vu Bug ---
	if my_distro != null:
		if my_distro.workers_paid > 0:
			is_first_worker_paid = false
		if my_distro.workers_volunteers > 0:
			is_first_worker_volunteer = false
	# --------------------------------

	stats_updated.emit()
	return true
