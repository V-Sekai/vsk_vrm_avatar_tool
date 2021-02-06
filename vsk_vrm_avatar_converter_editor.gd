tool
extends Node

const vsk_vrm_avatar_functions_const = preload("vsk_vrm_avatar_functions.gd")
const vsk_avatar_definition_editor_const = preload("res://addons/vsk_avatar/vsk_avatar_definition_editor.gd")
const ik_pose_fixer_const = preload("res://addons/vsk_avatar/ik_pose_fixer.gd")
const rotation_fixer_const = preload("res://addons/vsk_avatar/rotation_fixer.gd")
const external_transform_fixer_const = preload("res://addons/vsk_avatar/external_transform_fixer.gd")
const avatar_callback_const = preload("res://addons/vsk_avatar/avatar_callback.gd")

const VRM_EXTENSION = "vrm"

var file_load_path: String = ""

var editor_interface: EditorInterface = null

var err_dialog : AcceptDialog = null

var save_dialog : FileDialog = null
var open_dialog: FileDialog = null

# Hack to deal with the fact that IK correction must be done in the scene tree currently
var avatar_editor_root: Spatial = null

func error_callback(p_err: int) -> void:
	if p_err != avatar_callback_const.AVATAR_OK:
		var error_string: String = avatar_callback_const.get_error_string(p_err)
		
		printerr(error_string)
		err_dialog.set_text(error_string)
		err_dialog.popup_centered_minsize()

func convert_vrm(p_load_path, p_save_path: String) -> void:
	if ResourceLoader.exists(p_load_path):
		var vrm_packed_scene: PackedScene = ResourceLoader.load(p_load_path)
		if vrm_packed_scene:
			var instance: Spatial = vrm_packed_scene.instance()
			if instance:
				var root: Node = editor_interface.get_edited_scene_root()
				
				var avatar_root: Spatial = vsk_vrm_avatar_functions_const.convert_vrm_instance(
					instance, 
					root
				)
				if avatar_root:
					var packed_scene: PackedScene = PackedScene.new()
					
					packed_scene.pack(avatar_root)
					var err = ResourceSaver.save(p_save_path, packed_scene)

					printerr("Convert_vrm error code: %s" % str(err))

					avatar_root.queue_free()
				else:
					printerr("Could not load 'VSKVRMAvatarConverter'")


func _save_file_at_path(p_path: String) -> void:
	convert_vrm(file_load_path, p_path)


func _is_valid_vrm_file(p_path: String) -> bool:
	if p_path.get_extension().to_lower() == VRM_EXTENSION:
		return true
		
	return false


func save_vrm_selection_dialog() -> void:
	if save_dialog:
		save_dialog.popup_centered_ratio()


func _open_dialog_file_selected(p_path: String) -> void:
	if _is_valid_vrm_file(p_path):
		file_load_path = p_path
		save_vrm_selection_dialog()


func open_vrm_selection_dialog() -> void:
	if open_dialog:
		open_dialog.popup_centered_ratio()


func import_vrm_file(_variant) -> void:
	open_vrm_selection_dialog()


func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			if open_dialog:
				open_dialog.queue_free()
				open_dialog = null
				
			if save_dialog:
				save_dialog.queue_free()
				save_dialog = null
				
			if err_dialog:
				err_dialog.queue_free()
				err_dialog = null
				
			if avatar_editor_root:
				avatar_editor_root.queue_free()
				avatar_editor_root = null

func _ready():
	if editor_interface:
		# Open
		open_dialog = FileDialog.new()
		open_dialog.set_title("Open VRM file")
		open_dialog.add_filter("*.%s ; VRM files" % VRM_EXTENSION)
		open_dialog.mode = FileDialog.MODE_OPEN_FILE
		open_dialog.connect("file_selected", self, "_open_dialog_file_selected")
		editor_interface.get_editor_viewport().add_child(open_dialog)
		
		# Save
		save_dialog = FileDialog.new()
		save_dialog.set_title("Save Avatar As...")
		save_dialog.add_filter("*.%s;%s" % [vsk_avatar_definition_editor_const.OUTPUT_SCENE_EXTENSION, vsk_avatar_definition_editor_const.OUTPUT_SCENE_EXTENSION.to_upper()]);
		save_dialog.mode = FileDialog.MODE_SAVE_FILE
		save_dialog.access = FileDialog.ACCESS_FILESYSTEM
		save_dialog.connect("file_selected", self, "_save_file_at_path")
		editor_interface.get_editor_viewport().add_child(save_dialog)
		
		err_dialog = AcceptDialog.new()
		editor_interface.get_editor_viewport().add_child(err_dialog)
		
		# Spatial
		avatar_editor_root = Spatial.new()
		avatar_editor_root.set_name("AvatarEditorRoot")

func assign_editor_interface(p_editor_interface: EditorInterface):
	editor_interface = p_editor_interface
