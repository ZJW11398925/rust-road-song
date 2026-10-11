extends Node3D

const HumanScript = preload("res://human.gd")
const PLAYER_START: Vector3 = Vector3(-0.75, 0.0, 6.8)
const MOTHER_START: Vector3 = Vector3(0.75, 0.0, 6.8)
const FIRST_CAMERA: Vector3 = Vector3(0.0, 4.5, 13.0)
const RELATION_OFFSET: Vector3 = Vector3(0.0, 5.7, 6.4)
const FIRST_TARGET: Vector3 = Vector3(0.0, 1.0, 0.0)
const MOTHER_PATH: Array[Vector3] = [Vector3(0.75, 0.0, 2.4), Vector3(-2.28, 0.0, 2.4), Vector3(-2.28, 0.0, -0.18)]
const WALL_MESH_PATHS: Array[String] = ["LeftWall/Mesh", "RightWall/Mesh", "BackWall/Mesh", "EntryLeft/Mesh", "EntryRight/Mesh", "VestibuleLeft/Mesh", "VestibuleRight/Mesh", "VestibuleBack/Mesh"]
@onready var player: HumanScript = $Player
@onready var mother: HumanScript = $Mother
@onready var door: StaticBody3D = $Door
@onready var camera: Camera3D = $Camera3D
@onready var hint: Label = $HUD/Hint
@onready var feedback: Label = $HUD/Feedback
@onready var narrative: Label = $HUD/Narrative
var held: Dictionary = {}
var input_enabled: bool = true
var door_open: bool = false
var door_progress: float = 0.0
var first_reveal: bool = false
var mother_stage: int = 0
var mother_waypoint: int = 0
var mother_clock: float = 0.0
var reaction_count: int = 0
var player_touched: bool = false
var touch_clock: float = 0.0
var touch_contacted: bool = false
var narrative_clock: float = 0.0
var feedback_key: String = ""
var feedback_clock: float = 0.0
var camera_focus: Vector3 = FIRST_TARGET
var wall_meshes: Array[MeshInstance3D] = []

func _ready() -> void:
	var copy: Translation = load("res://strings.tres") as Translation
	TranslationServer.add_translation(copy)
	TranslationServer.set_locale("zh_CN")
	$HUD/Title.text = tr("TITLE")
	$HUD/Help.text = tr("HELP")
	for node_path: String in WALL_MESH_PATHS:
		var wall: MeshInstance3D = get_node(node_path) as MeshInstance3D
		var material: StandardMaterial3D = wall.material_override.duplicate() as StandardMaterial3D
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		wall.material_override = material
		wall_meshes.append(wall)
	_install_inputs()
	reset_experiment()

func _install_inputs() -> void:
	var keys: Dictionary = {"forward": KEY_W, "back": KEY_S, "left": KEY_A, "right": KEY_D, "interact": KEY_E, "reset": KEY_R, "quit": KEY_ESCAPE}
	for action: String in keys:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var event: InputEventKey = InputEventKey.new()
		event.physical_keycode = keys[action]
		InputMap.action_add_event(action, event)

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or event.is_echo():
		return
	if event.is_action_pressed("quit"):
		get_tree().quit()
		return
	if event.is_action_pressed("reset"):
		reset_experiment()
		return
	if not input_enabled:
		return
	for action: String in ["forward", "back", "left", "right"]:
		if event.is_action_pressed(action):
			held[action] = true
		elif event.is_action_released(action):
			held.erase(action)
	if event.is_action_pressed("interact"):
		_interact()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		input_enabled = false
		held.clear()
		if is_instance_valid(player):
			player.velocity = Vector3.ZERO
			show_feedback("FOCUS")
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		input_enabled = true
		held.clear()

func _physics_process(delta: float) -> void:
	var direction: Vector3 = Vector3.ZERO
	if input_enabled:
		direction.x = float(held.has("right")) - float(held.has("left"))
		direction.z = float(held.has("back")) - float(held.has("forward"))
	player.walk(direction.normalized(), delta, touch_clock <= 0.0)
	_update_player_touch(delta)
	if door_open:
		door_progress = minf(door_progress + delta / 1.2, 1.0)
		door.position.y = smoothstep(0.0, 1.0, door_progress) * 6.2
		if door_progress >= 0.95:
			first_reveal = true
		_update_mother(delta)
	_update_camera(delta)
	_update_wall_visibility(delta)
	_update_text(delta)

func _update_wall_visibility(delta: float) -> void:
	var mother_hand: Marker3D = mother.get_node("Visual/LeftUpperArm/LeftLowerArm/Hand") as Marker3D
	var targets: Array[Vector3] = [player.global_position + Vector3(0.0, 0.45, 0.0), player.global_position + Vector3(0.0, 0.9, 0.0), player.global_position + Vector3(0.0, 1.65, 0.0), mother.global_position + Vector3(0.0, 0.9, 0.0), mother_hand.global_position, $Mary/Body.global_position, $Mary/Anomaly.global_position]
	var response: float = 1.0 - exp(-delta * 10.0)
	for wall: MeshInstance3D in wall_meshes:
		var blocking: bool = false
		if first_reveal:
			var origin: Vector3 = wall.to_local(camera.global_position)
			for target: Vector3 in targets:
				if wall.mesh.get_aabb().intersects_segment(origin, wall.to_local(target)) != null:
					blocking = true
					break
		var material: StandardMaterial3D = wall.material_override as StandardMaterial3D
		var color: Color = material.albedo_color
		color.a = lerpf(color.a, 0.12 if blocking else 1.0, response)
		material.albedo_color = color

func _update_camera(delta: float) -> void:
	var car_focus: Vector3 = $Mary.global_position + Vector3(0.0, 1.1, 0.3)
	var mother_focus: Vector3 = mother.global_position + Vector3(0.0, 1.1, 0.0)
	var relation_focus: Vector3 = car_focus.lerp(mother_focus, 0.52)
	var shared_focus: Vector3 = relation_focus.lerp(player.global_position + Vector3(0.0, 1.1, 0.0), 0.52)
	var wanted_focus: Vector3 = FIRST_TARGET.lerp(shared_focus, door_progress)
	var spread: float = maxf(player.global_position.distance_to(relation_focus) - 5.0, 0.0)
	var distance_scale: float = 1.0 + minf(spread * 0.06, 0.3)
	var wanted_position: Vector3 = FIRST_CAMERA.lerp(wanted_focus + RELATION_OFFSET * distance_scale, door_progress)
	wanted_position.x = lerpf(FIRST_CAMERA.x, clampf(player.position.x * 2.0 - 1.0, -5.2, 5.2), door_progress)
	var response: float = 1.0 - exp(-delta * 2.2)
	camera_focus = camera_focus.lerp(wanted_focus, response)
	camera.position = camera.position.lerp(wanted_position, response)
	camera.look_at(camera_focus, Vector3.UP)

func _update_mother(delta: float) -> void:
	mother_clock += delta
	if mother_stage == 0:
		mother.walk(Vector3.ZERO, delta)
		if first_reveal:
			mother_stage = 1
			mother_clock = 0.0
	elif mother_stage == 1:
		var difference: Vector3 = MOTHER_PATH[mother_waypoint] - mother.position
		difference.y = 0.0
		if difference.length() < 0.07:
			mother_waypoint += 1
			if mother_waypoint == MOTHER_PATH.size():
				mother_stage = 2
				mother_clock = 0.0
				mother.walk(Vector3.ZERO, delta)
				return
			difference = MOTHER_PATH[mother_waypoint] - mother.position
		mother.walk(difference.normalized(), delta)
	elif mother_stage == 2:
		mother.walk(Vector3.ZERO, delta, false)
		mother.face(Vector3.RIGHT, delta, 5.0)
		if mother_clock > 0.7:
			mother_stage = 3
			mother_clock = 0.0
	elif mother_stage == 3:
		mother.walk(Vector3.ZERO, delta, false)
		mother.reach_amount = move_toward(mother.reach_amount, 1.0, delta * 1.6)
		mother.pose_reach($Mary/Anomaly/EdgeStart.global_position, mother.reach_amount)
		if mother.reach_amount >= 1.0:
			mother_stage = 4
			mother_clock = 0.0
			reaction_count += 1
			narrative.text = tr("MOTHER")
			narrative_clock = 4.5
	elif mother_stage == 4:
		mother.walk(Vector3.ZERO, delta, false)
		var edge_start: Vector3 = $Mary/Anomaly/EdgeStart.global_position
		var edge_end: Vector3 = $Mary/Anomaly/EdgeEnd.global_position
		mother.pose_reach(edge_start.lerp(edge_end, smoothstep(0.0, 1.0, minf(mother_clock / 1.3, 1.0))), 1.0)
		if mother_clock > 1.65:
			mother_stage = 5
			mother_clock = 0.0
	elif mother_stage == 5:
		mother.reach_amount = move_toward(mother.reach_amount, 0.0, delta * 1.8)
		mother.walk(Vector3.ZERO, delta, false)
		if mother.reach_amount <= 0.0:
			mother_stage = 6
	else:
		mother.walk(Vector3.ZERO, delta, false)

func _interact() -> void:
	if not door_open and _near_door():
		door_open = true
		show_feedback("OPEN")
	elif door_open and _near_touch():
		touch_clock = 0.8
		touch_contacted = false
		show_feedback("REACH")
	elif door_open and _near_door():
		show_feedback("OPEN")
	else:
		show_feedback("FAR")

func _update_player_touch(delta: float) -> void:
	var attempting: bool = touch_clock > 0.0
	player.reach_amount = move_toward(player.reach_amount, 1.0 if attempting else 0.0, delta * 4.0)
	if not attempting:
		return
	player.face(Vector3.LEFT if player.position.x > $Mary.position.x else Vector3.RIGHT, delta, 10.0)
	if not touch_contacted and player.reach_amount >= 0.98 and _player_hand_on_body():
		touch_contacted = true
		player_touched = true
		show_feedback("TOUCH")
		# Contact changes only this gesture, never mechanical state or stage completion.
	touch_clock = maxf(touch_clock - delta, 0.0)
	if touch_clock <= 0.0 and not touch_contacted:
		show_feedback("TOUCH_MISS")

func _player_hand_on_body() -> bool:
	var hand: Marker3D = player.get_node("Visual/LeftUpperArm/LeftLowerArm/Hand") as Marker3D
	var local: Vector3 = $Mary.to_local(hand.global_position)
	var shell_x: float = 1.6 if player.position.x > $Mary.position.x else -1.6
	var shell_point: Vector3 = Vector3(shell_x, clampf(local.y, 0.1, 1.55), clampf(local.z, -2.7, 2.7))
	# Left aperture contains bridges at reach height; touching a void is not contact.
	if shell_x < 0.0 and local.z > -0.16 and local.z < 1.16 and local.y > 0.96 and local.y < 1.40:
		return false
	return hand.global_position.distance_to($Mary.to_global(shell_point)) <= 0.14

func _near_door() -> bool:
	return absf(player.position.x) < 1.9 and absf(player.position.z - 4.0) < 1.65

func _near_touch() -> bool:
	var local: Vector3 = $Mary.to_local(player.global_position)
	var horizontal: Vector2 = Vector2(absf(local.x) - 1.6, local.z - clampf(local.z, -2.7, 2.7))
	return absf(local.x) > 1.6 and horizontal.length() < 1.55

func _update_text(delta: float) -> void:
	hint.text = tr("DOOR_HINT") if not door_open and _near_door() else (tr("TOUCH_HINT") if door_open and _near_touch() else "")
	feedback_clock = maxf(feedback_clock - delta, 0.0)
	feedback.text = tr(feedback_key) if feedback_clock > 0.0 else ""
	narrative_clock = maxf(narrative_clock - delta, 0.0)
	if narrative_clock <= 0.0:
		narrative.text = ""

func show_feedback(copy_key: String) -> void:
	feedback_key = copy_key
	feedback_clock = 3.0
	feedback.text = tr(copy_key)

func reset_experiment() -> void:
	held.clear()
	for wall: MeshInstance3D in wall_meshes:
		var material: StandardMaterial3D = wall.material_override as StandardMaterial3D
		var color: Color = material.albedo_color
		color.a = 1.0
		material.albedo_color = color
	player.position = PLAYER_START
	mother.position = MOTHER_START
	player.reset_pose()
	mother.reset_pose()
	door_open = false
	door_progress = 0.0
	door.position.y = 0.0
	first_reveal = false
	mother_stage = 0
	mother_waypoint = 0
	mother_clock = 0.0
	reaction_count = 0
	player_touched = false
	touch_clock = 0.0
	touch_contacted = false
	narrative_clock = 0.0
	feedback_key = ""
	feedback_clock = 0.0
	camera_focus = FIRST_TARGET
	narrative.text = ""
	feedback.text = ""
	camera.position = FIRST_CAMERA
	camera.look_at(FIRST_TARGET, Vector3.UP)
