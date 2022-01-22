@tool
extends EditorPlugin

const vrm_logo = null#preload("vrm_v_logo_16.png")
const vrm_toplevel_const = preload("res://addons/vrm/vrm_toplevel.gd")

const vsk_vrm_avatar_converter_editor_const = preload("vsk_vrm_avatar_converter_editor.gd")
var vsk_vrm_avatar_converter_editor: Node = null

const VRM_IMPORT_FILE_STRING = "Create Avatar from VRM"

func _init():
	print("Initialising VSKVRMAvatarTool plugin")


func _notification(p_notification: int):
	match p_notification:
		NOTIFICATION_PREDELETE:
			print("Destroying VSKVRMAvatarTool plugin")


func _get_plugin_name() -> String:
	return "VSKVRMAvatarTool"


func _enter_tree() -> void:
	vsk_vrm_avatar_converter_editor = vsk_vrm_avatar_converter_editor_const.new(self, vrm_logo)
	
	call_deferred("add_child", vsk_vrm_avatar_converter_editor, true)


func _exit_tree() -> void:
	remove_tool_menu_item(VRM_IMPORT_FILE_STRING)
	
	vsk_vrm_avatar_converter_editor.queue_free()


func _edit(p_object : Object) -> void:
	if p_object is Node and typeof(p_object.get("vrm_meta")) != TYPE_NIL:
		vsk_vrm_avatar_converter_editor.edit(p_object)


func _handles(p_object : Object) -> bool:
	if p_object.get_script() == vrm_toplevel_const:
		return true
	else:
		return false


func _make_visible(p_visible : bool) -> void:
	if (p_visible):
		if vsk_vrm_avatar_converter_editor:
			if vsk_vrm_avatar_converter_editor.options:
				vsk_vrm_avatar_converter_editor.options.show()
	else:
		if vsk_vrm_avatar_converter_editor:
			if vsk_vrm_avatar_converter_editor.options:
				vsk_vrm_avatar_converter_editor.options.hide()
			vsk_vrm_avatar_converter_editor.edit(null)
			
