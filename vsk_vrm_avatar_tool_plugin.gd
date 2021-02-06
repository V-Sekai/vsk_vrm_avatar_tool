tool
extends EditorPlugin

const vsk_vrm_avatar_converter_editor_const = preload("vsk_vrm_avatar_converter_editor.gd")
var vsk_vrm_avatar_converter_editor: Node = null

const VRM_IMPORT_FILE_STRING = "Create Avatar from VRM"

func _init() -> void:
	print("Initialising VSKVRMAvatarTool plugin")


func _notification(p_notification: int):
	match p_notification:
		NOTIFICATION_PREDELETE:
			print("Destroying VSKVRMAvatarTool plugin")


func get_name() -> String:
	return "VSKVRMAvatarTool"


func _enter_tree() -> void:	
	vsk_vrm_avatar_converter_editor = vsk_vrm_avatar_converter_editor_const.new()
	vsk_vrm_avatar_converter_editor.assign_editor_interface(get_editor_interface())
	
	add_child(vsk_vrm_avatar_converter_editor)

	add_tool_menu_item(VRM_IMPORT_FILE_STRING, vsk_vrm_avatar_converter_editor, "import_vrm_file")


func _exit_tree() -> void:
	remove_tool_menu_item(VRM_IMPORT_FILE_STRING)
	
	vsk_vrm_avatar_converter_editor.queue_free()
