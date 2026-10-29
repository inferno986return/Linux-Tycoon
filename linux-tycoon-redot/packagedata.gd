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
