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
