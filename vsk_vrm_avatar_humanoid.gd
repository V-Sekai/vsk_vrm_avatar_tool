@tool
extends RefCounted

const humanoid_data_const = preload("res://addons/vsk_avatar/humanoid_data.gd")

const humanoid_name_mappings = {
	"hips":"hips_bone_name",
	"leftUpperLeg":"thigh_left_bone_name",
	"rightUpperLeg":"thigh_right_bone_name",
	"leftLowerLeg":"shin_left_bone_name",
	"rightLowerLeg":"shin_right_bone_name",
	"leftFoot":"foot_left_bone_name",
	"rightFoot":"foot_right_bone_name",
	"spine":"spine_bone_name",
	"chest":"chest_bone_name",
	"neck":"neck_bone_name",
	"head":"head_bone_name",
	"leftShoulder":"shoulder_left_bone_name",
	"rightShoulder":"shoulder_right_bone_name",
	"leftUpperArm":"upper_arm_left_bone_name",
	"rightUpperArm":"upper_arm_right_bone_name",
	"leftLowerArm":"forearm_left_bone_name",
	"rightLowerArm":"forearm_right_bone_name",
	"leftHand":"hand_left_bone_name",
	"rightHand":"hand_right_bone_name",
	"leftToes":"toe_left_bone_name",
	"rightToes":"toe_right_bone_name",
	
	"leftThumbProximal":"thumb_proximal_left_bone_name",
	"leftThumbIntermediate":"thumb_intermediate_left_bone_name",
	"leftThumbDistal":"thumb_distal_left_bone_name",
	
	"leftIndexProximal":"index_proximal_left_bone_name",
	"leftIndexIntermediate":"index_intermediate_left_bone_name",
	"leftIndexDistal":"index_distal_left_bone_name",
	
	"leftMiddleProximal":"middle_proximal_left_bone_name",
	"leftMiddleIntermediate":"middle_intermediate_left_bone_name",
	"leftMiddleDistal":"middle_distal_left_bone_name",
	
	"leftRingProximal":"ring_proximal_left_bone_name",
	"leftRingIntermediate":"ring_intermediate_left_bone_name",
	"leftRingDistal":"ring_distal_left_bone_name",
	
	"leftLittleProximal":"little_proximal_left_bone_name",
	"leftLittleIntermediate":"little_intermediate_left_bone_name",
	"leftLittleDistal":"little_distal_left_bone_name",
	
	"rightThumbProximal":"thumb_proximal_right_bone_name",
	"rightThumbIntermediate":"thumb_intermediate_right_bone_name",
	"rightThumbDistal":"thumb_distal_right_bone_name",
	
	"rightIndexProximal":"index_proximal_right_bone_name",
	"rightIndexIntermediate":"index_intermediate_right_bone_name",
	"rightIndexDistal":"index_distal_right_bone_name",
	
	"rightMiddleProximal":"middle_proximal_right_bone_name",
	"rightMiddleIntermediate":"middle_intermediate_right_bone_name",
	"rightMiddleDistal":"middle_distal_right_bone_name",
	
	"rightRingProximal":"ring_proximal_right_bone_name",
	"rightRingIntermediate":"ring_intermediate_right_bone_name",
	"rightRingDistal":"ring_distal_right_bone_name",
	
	"rightLittleProximal":"little_proximal_right_bone_name",
	"rightLittleIntermediate":"little_intermediate_right_bone_name",
	"rightLittleDistal":"little_distal_right_bone_name",
}

static func convert_vrm_humanoid_data_to_vsk_humanoid_data(p_dictionary: Dictionary) -> HumanoidData:
	var humanoid_data: HumanoidData = humanoid_data_const.new()
	
	for key in humanoid_name_mappings.keys():
		if p_dictionary.has(key):
			humanoid_data.set(humanoid_name_mappings[key], p_dictionary[key])
	
	return humanoid_data
