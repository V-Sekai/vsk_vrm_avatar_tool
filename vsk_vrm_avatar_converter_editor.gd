@tool
extends Node

const vrm_toplevel_const = preload("res://addons/vrm/vrm_toplevel.gd")

const vsk_avatar_definition_editor_const = preload("res://addons/vsk_avatar/vsk_avatar_definition_editor.gd")
const vsk_vrm_avatar_functions_const = preload("vsk_vrm_avatar_functions.gd")
const vsk_vrm_callback_const = preload("vsk_vrm_callback.gd")

enum {
	MENU_OPTION_CONVERT_TO_VSK_AVATAR
}

const VRM_EXTENSION = "vrm"

var icon: Texture2D = null
var node: Node = null
var options: MenuButton = null
var editor_plugin: EditorPlugin = null
var err_dialog : AcceptDialog = null
var save_dialog : FileDialog = null

# Hack to deal with the fact that IK correction must be done in the scene tree currently
var avatar_editor_root: Node3D = null

func error_callback(p_err: int, p_extra_code: int) -> void:
	if p_err != vsk_vrm_callback_const.VRM_OK:
		var error_str: String = vsk_vrm_callback_const.get_error_string(p_err)
		
		printerr(error_str + ("code: %s" % str(p_extra_code)))
		err_dialog.set_text(error_str)
		err_dialog.popup_centered_clamped()
		
func _menu_option(p_id : int) -> void:
	match p_id:
		MENU_OPTION_CONVERT_TO_VSK_AVATAR:
			save_vrm_selection_dialog()
			return
				
	error_callback(vsk_vrm_callback_const.VRM_INVALID_MENU_OPTION, -1)

func set_owner_rec(node: Node, owner: Node):
	node.owner = owner
	for n in node.get_children():
		set_owner_rec(n, owner)

func convert_vrm(p_save_path: String) -> void:
	var err: int = -1
	if editor_plugin:
		var instance: Node3D = node.duplicate()
		instance.scene_file_path = node.scene_file_path
		if instance and typeof(instance.get(^"vrm_meta")) != TYPE_NIL:
			instance.vrm_meta.texture = null
			var avatar_root: Node3D = vsk_vrm_avatar_functions_const.convert_vrm_instance(instance)
			if avatar_root:
				avatar_root.set_owner(null)
				for n in avatar_root.get_children():
					set_owner_rec(n, avatar_root)
				if (!instance.scene_file_path.is_empty()):
					for n in instance.get_children():
						set_owner_rec(n, instance)
				var packed_scene: PackedScene = PackedScene.new()
				err = packed_scene.pack(avatar_root)
				if err & 0xffffffff == OK:
					err = ResourceSaver.save(p_save_path, packed_scene)
					var editor_filesystem = EditorPlugin.new().get_editor_interface().get_resource_filesystem()
					editor_filesystem.scan()
					if err & 0xffffffff == OK:
						return
					else:
						error_callback(vsk_vrm_callback_const.VRM_COULD_NOT_SAVE, err)
				else:
					error_callback(vsk_vrm_callback_const.VRM_COULD_NOT_PACK, err)

				avatar_root.queue_free()
			else:
				error_callback(vsk_vrm_callback_const.VRM_FAILED, err)
		else:
			error_callback(vsk_vrm_callback_const.VRM_INVALID_NODE, err)
	else:
		error_callback(vsk_vrm_callback_const.VRM_NO_EDITOR_PLUGIN, err)

func _save_file_at_path(p_path: String) -> void:
	convert_vrm(p_path)


func _is_valid_vrm_file(p_path: String) -> bool:
	if p_path.get_extension().to_lower() == VRM_EXTENSION:
		return true
		
	return false


func save_vrm_selection_dialog() -> void:
	if save_dialog:
		save_dialog.popup_centered_ratio()


func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			if save_dialog:
				save_dialog.queue_free()
				save_dialog = null
				
			if err_dialog:
				err_dialog.queue_free()
				err_dialog = null
				
			if avatar_editor_root:
				avatar_editor_root.queue_free()
				avatar_editor_root = null
				
			if editor_plugin:
				editor_plugin.remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, options)

func edit(p_node: Node) -> void:
	node = p_node

func _ready():
	if editor_plugin:
		# Save
		save_dialog = FileDialog.new()
		save_dialog.set_title("Save Avatar As...")
		save_dialog.add_filter("*.scn; Scenes");
		save_dialog.mode = FileDialog.FILE_MODE_SAVE_FILE
		save_dialog.access = FileDialog.ACCESS_FILESYSTEM
		save_dialog.connect("file_selected", Callable(self, "_save_file_at_path"))
		editor_plugin.get_editor_interface().get_viewport().add_child(save_dialog)
		
		err_dialog = AcceptDialog.new()
		editor_plugin.get_editor_interface().get_viewport().add_child(err_dialog)
		
		# Spatial
		avatar_editor_root = Node3D.new()
		avatar_editor_root.set_name("AvatarEditorRoot")

		options = MenuButton.new()
		options.set_switch_on_hover(true)
		
		editor_plugin.add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, options)
		options.set_text("VRM")
		options.set_button_icon(icon)
		options.get_popup().add_item("Convert to VSK Avatar", MENU_OPTION_CONVERT_TO_VSK_AVATAR)
		
		options.get_popup().connect("id_pressed", Callable(self, "_menu_option"))
		options.hide()

func _init(p_editor_plugin: EditorPlugin, p_icon: Texture2D):
	editor_plugin = p_editor_plugin
	icon = p_icon
