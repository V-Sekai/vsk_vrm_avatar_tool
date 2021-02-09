extends Reference
tool

enum {
	VRM_OK,
	VRM_FAILED,
	VRM_INVALID_MENU_OPTION,
	VRM_COULD_NOT_SAVE,
	VRM_COULD_NOT_PACK,
	VRM_INVALID_NODE,
	VRM_NO_EDITOR_PLUGIN
	
}

static func get_error_string(p_err: int) -> String:
	var error_string: String = "Unknown error!"
	match p_err:
		VRM_FAILED:
			error_string = "Generic VRM error! (complain to Saracen)"
		VRM_INVALID_MENU_OPTION:
			error_string = "Invalid menu option"
		VRM_COULD_NOT_SAVE:
			error_string = "Could not be saved"
		VRM_COULD_NOT_PACK:
			error_string = "Could not be packed"
		VRM_INVALID_NODE:
			error_string = "Invalid node"
		VRM_NO_EDITOR_PLUGIN:
			error_string = "No editor plugin found"
	
	return error_string

static func generic_error_check(p_root: Spatial) -> int:
	return VRM_OK
