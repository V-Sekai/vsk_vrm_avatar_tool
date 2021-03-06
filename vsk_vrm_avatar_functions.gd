tool
extends Node

const vrm_toplevel_const = preload("res://addons/vrm/vrm_toplevel.gd")

const vsk_avatar_definition_const = preload("res://addons/vsk_avatar/vsk_avatar_definition.gd")
const vsk_avatar_definition_runtime_const = preload("res://addons/vsk_avatar/vsk_avatar_definition_runtime.gd")

const node_util_const = preload("res://addons/gdutil/node_util.gd")
const bone_lib_const = preload("res://addons/vsk_avatar/bone_lib.gd")

const humanoid_data_const = preload("res://addons/vsk_avatar/humanoid_data.gd")

const vsk_vrm_avatar_humanoid_const = preload("res://addons/vsk_vrm_avatar_tool/vsk_vrm_avatar_humanoid.gd")

static func recursively_reassign_owner(p_instance: Node, p_owner: Node) -> void:
	if p_instance != p_owner:
		p_instance.set_owner(p_owner)
		
	for child in p_instance.get_children():
		recursively_reassign_owner(child, p_owner)

static func get_first_person_bone_id(p_skeleton: Skeleton, p_humanoid_data: Resource) -> int:
	if p_skeleton and p_humanoid_data is humanoid_data_const:
		var head_name: String = p_humanoid_data.get("head_bone_name")
		return p_skeleton.find_bone(head_name) 
	else:
		return -1

static func convert_vrm_instance(p_vrm_instance: Spatial, p_root: Node) -> Spatial:
	var vsk_avatar_root: Spatial = null
	
	if p_vrm_instance.get_script() == vrm_toplevel_const:
		var vrm_meta = p_vrm_instance.vrm_meta
		if vrm_meta:
			var humanoid_bone_mapping: Dictionary  = vrm_meta.humanoid_bone_mapping
			var eye_offset: Vector3  = vrm_meta.eye_offset
			
			var skeleton: Skeleton = p_vrm_instance.get_node_or_null(p_vrm_instance.vrm_skeleton)
			if skeleton:
				vsk_avatar_root = Spatial.new()
				vsk_avatar_root.set_name("Avatar")
				vsk_avatar_root.set_script(vsk_avatar_definition_const)
				
				vsk_avatar_root.set_owner(null)
				
				vsk_avatar_root.add_child(p_vrm_instance)
				p_vrm_instance.set_owner(vsk_avatar_root)
				
				# Skeleton Path
				var skeleton_path: NodePath = vsk_avatar_root.get_path_to(skeleton)
				
				vsk_avatar_root.set_skeleton_path(skeleton_path)
				
				var humanoid_data: Resource = vsk_vrm_avatar_humanoid_const.convert_vrm_humanoid_data_to_vsk_humanoid_data(\
				humanoid_bone_mapping)
				
				# Humanoid Data
				vsk_avatar_root.set_humanoid_data(humanoid_data)
				
				var fp_global_transform: Transform = Transform()
				
				var fp_bone_id: int = get_first_person_bone_id(skeleton, humanoid_data)
				if fp_bone_id != -1:
					fp_global_transform = node_util_const.get_relative_global_transform(vsk_avatar_root, skeleton)\
					* bone_lib_const.get_bone_global_rest_transform(fp_bone_id, skeleton)\
					* Transform(Basis(), eye_offset)
				
				# Eye position
				var eye_node: Position3D = Position3D.new()
				vsk_avatar_root.add_child(eye_node)
				eye_node.set_name("EyePosition")
				eye_node.set_owner(vsk_avatar_root)
				eye_node.rotate_y(PI)
				eye_node.transform *= fp_global_transform
				vsk_avatar_root.set_eye_transform_path(vsk_avatar_root.get_path_to(eye_node))
				
				# Use the VRM preview texture if it exists
				if vrm_meta.texture:
					vsk_avatar_root.editor_properties.vskeditor_preview_type = "Texture"
					vsk_avatar_root.editor_properties.vskeditor_preview_texture = vrm_meta.texture
				
				p_vrm_instance.rotate_y(PI)
			
			
	return vsk_avatar_root
