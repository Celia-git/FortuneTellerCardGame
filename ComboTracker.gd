extends Node

# Combo tracker keeps track of combos and emits signal when a certain amount are achieved

signal combo_streak
signal update_combo_progress

var element = ""
var stage=""
var role=""
var element_count = 0
var stage_count = 0
var role_count = 0


# Track combos: new combo found
func track(new_element, new_stage, new_role):
	track_element(new_element)
	track_stage(new_stage)
	track_role(new_role)	
		
	check_for_combo()
	emit_signal("update_combo_progress", {element:element_count, stage:stage_count, role:role_count})

func track_element(new_element):
	if (self.element == new_element) and new_element != "":
		self.element_count += 1
	elif !(self.element == new_element) and new_element != "":
		self.element_count = 1
		self.element = new_element
	else:
		self.element_count = 0
		self.element = ""
		
func track_stage(new_stage):
	if (self.stage == new_stage) and new_stage != "":
		self.stage_count += 1
	elif !(self.stage == new_stage) and new_stage != "":
		self.stage_count = 1
		self.stage = new_stage
	else:
		self.stage_count = 0
		self.stage = ""

func track_role(new_role):
	if (self.role == new_role) and new_role != "":
		self.role_count += 1
	elif !(self.role == new_role) and new_role != "":
		self.role_count = 1
		self.role = new_role
	else:
		self.role_count = 0
		self.role = ""


# Check if variables satisfy conditions for a straight combo
func check_for_combo():
	
	# Two elements
	if element_count == 2:
		emit_signal("combo_streak", "element", element, element_count)
		element_count = 0
		
	# 3 stages
	if stage_count == 3:
		emit_signal("combo_streak", "stage", stage, stage_count)
		stage_count = 0
		
	# 4 roles
	if role_count == 4:
		emit_signal("combo_streak", "role", role, role_count)
		role_count = 0
		
	
