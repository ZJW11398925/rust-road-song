extends Node3D

const HumanScript = preload("res://human.gd")
const PLAYER_START: Vector3 = Vector3(-0.75, 0.0, 6.8)
const MOTHER_START: Vector3 = Vector3(0.75, 0.0, 6.8)
const MARY_START: Vector3 = Vector3(0.0, 0.0, -1.5)
const FIRST_CAMERA: Vector3 = Vector3(0.0, 4.5, 13.0)
const RELATION_OFFSET: Vector3 = Vector3(0.0, 5.7, 6.4)
const FIRST_TARGET: Vector3 = Vector3(0.0, 1.0, 0.0)
const DRIVER_SEAT: Vector3 = Vector3(0.65, 0.95, 1.8)
const PASSENGER_SEAT: Vector3 = Vector3(-0.65, 0.95, 1.8)
const MOTHER_PATH: Array[Vector3] = [Vector3(0.75, 0.0, 2.4), Vector3(-2.55, 0.0, 2.4), Vector3(-2.55, 0.0, -0.18), Vector3(-2.28, 0.0, -0.18)]
const CONTACT_PATH: Array[Vector3] = [Vector3(-2.55, 0.0, 2.4), Vector3(-2.55, 0.0, -2.98), Vector3(-2.41, 0.0, -2.98)]
const PASSENGER_PATH: Array[Vector3] = [Vector3(-2.70, 0.0, -2.98), Vector3(-2.70, 0.0, 2.0), Vector3(-2.40, 0.0, 2.0)]
const WALL_MESH_PATHS: Array[String] = ["LeftWall/Mesh", "RightWall/Mesh", "BackWall/Mesh", "EntryLeft/Mesh", "EntryRight/Mesh", "VestibuleLeft/Mesh", "VestibuleRight/Mesh", "VestibuleBack/Mesh"]
@onready var player: HumanScript = $Player
@onready var mother: HumanScript = $Mother
@onready var mary: CharacterBody3D = $Mary
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
var assistance_requested: bool = false
var contact_valid: bool = false
var boarded: bool = false
var player_seated: bool = false
var mother_seated: bool = false
var player_climb: float = 0.0
var mother_climb: float = 0.0
var player_climb_start: Vector3 = Vector3.ZERO
var mother_climb_start: Vector3 = Vector3.ZERO
var engine_running: bool = false
var start_progress: float = 0.0
var speed: float = 0.0
var exited: bool = false
var rear_clear_z: float = 0.0
var collision_count: int = 0
var tank_collision: KinematicCollision3D = null
var player_touched: bool = false
var touch_clock: float = 0.0
var touch_contacted: bool = false
var narrative_clock: float = 0.0
var feedback_key: String = ""
var feedback_clock: float = 0.0
var camera_focus: Vector3 = FIRST_TARGET
var wall_meshes: Array[MeshInstance3D] = []
var reset_physics_pending: bool = false

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
	var keys: Dictionary = {"forward": KEY_W, "back": KEY_S, "left": KEY_A, "right": KEY_D, "interact": KEY_E, "start": KEY_F, "reset": KEY_R, "quit": KEY_ESCAPE}
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
	for action: String in ["forward", "back", "left", "right", "start"]:
		if event.is_action_pressed(action):
			held[action] = true
		elif event.is_action_released(action):
			held.erase(action)
	if event.is_action_pressed("interact"):
		_interact()
	if event.is_action_pressed("start"):
		_board_or_start()
	elif event.is_action_released("start") and not engine_running:
		start_progress = 0.0

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		input_enabled = false
		held.clear()
		start_progress = 0.0
		speed = 0.0
		if is_instance_valid(player):
			player.velocity = Vector3.ZERO
			mary.velocity = Vector3.ZERO
			show_feedback("FOCUS")
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		input_enabled = true
		held.clear()

func _physics_process(delta: float) -> void:
	if reset_physics_pending:
		_update_drive(delta)
		player.collision_layer = 4
		player.collision_mask = 3
		mother.collision_layer = 2
		mother.collision_mask = 5
		reset_physics_pending = false
		return
	if not boarded:
		var direction: Vector3 = Vector3.ZERO
		if input_enabled:
			direction.x = float(held.has("right")) - float(held.has("left"))
			direction.z = float(held.has("back")) - float(held.has("forward"))
		player.walk(direction.normalized(), delta, touch_clock <= 0.0)
		_update_player_touch(delta)
	elif not player_seated:
		player_climb = minf(player_climb + delta, 1.0)
		_climb(player, player_climb_start, DRIVER_SEAT, player_climb)
		if player_climb >= 1.0:
			player_seated = true
	if door_open:
		door_progress = minf(door_progress + delta / 1.2, 1.0)
		door.position.y = smoothstep(0.0, 1.0, door_progress) * 6.2
		if door_progress >= 0.95:
			first_reveal = true
		_update_mother(delta)
	contact_valid = _mother_hand_contact()
	_update_start(delta)
	_update_drive(delta)
	if player_seated:
		_seat(player, DRIVER_SEAT)
	if mother_seated:
		_seat(mother, PASSENGER_SEAT)
	_update_camera(delta)
	_update_wall_visibility(delta)
	_update_text(delta)

func _board_or_start() -> void:
	if boarded:
		assistance_requested = true
		if not engine_running and not contact_valid:
			show_feedback("NO_CONTACT")
		return
	if not door_open or player.global_position.distance_to($Mary/BoardStep.global_position) > 1.0:
		show_feedback("BOARD_FAR")
		return
	boarded = true
	assistance_requested = true
	touch_clock = 0.0
	player.reach_amount = 0.0
	player_climb_start = player.global_position
	player.velocity = Vector3.ZERO
	player.collision_layer = 0
	player.collision_mask = 0
	# Boarding keypress cannot silently become a sustained crank attempt.
	held.clear()
	show_feedback("BOARDED")

func _update_start(delta: float) -> void:
	if not boarded or not player_seated or engine_running or not input_enabled or not held.has("start"):
		return
	if not contact_valid:
		start_progress = 0.0
		show_feedback("NO_CONTACT")
		return
	start_progress = minf(start_progress + delta, 1.2)
	show_feedback("CRANKING")
	if start_progress >= 1.2:
		engine_running = true
		mother_stage = 9
		mother_clock = 0.0
		show_feedback("RUNNING")

func _mother_hand_contact() -> bool:
	if mother_stage != 8 or engine_running:
		return false
	var hand: Marker3D = mother.get_node("Visual/LeftUpperArm/LeftLowerArm/Hand") as Marker3D
	return hand.global_position.distance_to($Mary/StartContact.global_position) <= 0.14

func _follow_mother_path(path: Array[Vector3], delta: float) -> bool:
	var difference: Vector3 = path[mother_waypoint] - mother.position
	difference.y = 0.0
	if difference.length() < 0.035:
		mother_waypoint += 1
		if mother_waypoint >= path.size():
			mother.walk(Vector3.ZERO, delta)
			return true
		difference = path[mother_waypoint] - mother.position
		difference.y = 0.0
	mother.walk(difference.normalized(), delta)
	return false

func _update_mother(delta: float) -> void:
	mother_clock += delta
	# A reasonable early attempt interrupts the optional old-edge performance.
	if assistance_requested and mother_stage < 7 and first_reveal:
		mother_stage = 7
		mother_waypoint = 0
		# Already inside the left aisle? Do not send her back past the player.
		if mother.position.x < -2.0:
			mother_waypoint = 1
		mother.reach_amount = 0.0
		mother_clock = 0.0
	match mother_stage:
		0:
			mother.walk(Vector3.ZERO, delta)
			if first_reveal:
				mother_stage = 1
				mother_clock = 0.0
		1:
			if _follow_mother_path(MOTHER_PATH, delta):
				mother_stage = 2
				mother_clock = 0.0
		2:
			mother.walk(Vector3.ZERO, delta, false)
			mother.face(Vector3.RIGHT, delta, 5.0)
			if mother_clock > 0.7:
				mother_stage = 3
				mother_clock = 0.0
		3:
			mother.walk(Vector3.ZERO, delta, false)
			mother.reach_amount = move_toward(mother.reach_amount, 1.0, delta * 1.6)
			mother.pose_reach($Mary/Anomaly/EdgeStart.global_position, mother.reach_amount)
			if mother.reach_amount >= 1.0:
				mother_stage = 4
				mother_clock = 0.0
				reaction_count += 1
				narrative.text = tr("MOTHER")
				narrative_clock = 4.5
		4:
			mother.walk(Vector3.ZERO, delta, false)
			var edge_start: Vector3 = $Mary/Anomaly/EdgeStart.global_position
			var edge_end: Vector3 = $Mary/Anomaly/EdgeEnd.global_position
			mother.pose_reach(edge_start.lerp(edge_end, smoothstep(0.0, 1.0, minf(mother_clock / 1.3, 1.0))), 1.0)
			if mother_clock > 1.65:
				mother_stage = 5
		5:
			mother.reach_amount = move_toward(mother.reach_amount, 0.0, delta * 1.8)
			mother.walk(Vector3.ZERO, delta, false)
			if mother.reach_amount <= 0.0:
				mother_stage = 7
				mother_waypoint = 1
		7:
			if _follow_mother_path(CONTACT_PATH, delta):
				mother_stage = 8
				mother_clock = 0.0
		8:
			mother.walk(Vector3.ZERO, delta, false)
			mother.face(Vector3.RIGHT, delta, 10.0)
			mother.reach_amount = move_toward(mother.reach_amount, 1.0, delta * 2.0)
			mother.pose_reach($Mary/StartContact.global_position, mother.reach_amount)
		9:
			mother.walk(Vector3.ZERO, delta, false)
			mother.reach_amount = move_toward(mother.reach_amount, 0.0, delta * 3.0)
			if mother.reach_amount <= 0.0:
				mother_stage = 10
				mother_waypoint = 0
		10:
			if _follow_mother_path(PASSENGER_PATH, delta):
				mother_stage = 11
				mother_climb_start = mother.global_position
				mother.collision_layer = 0
				mother.collision_mask = 0
		11:
			mother_climb = minf(mother_climb + delta, 1.0)
			_climb(mother, mother_climb_start, PASSENGER_SEAT, mother_climb)
			if mother_climb >= 1.0:
				mother_stage = 12
				mother_seated = true

func _climb(person: HumanScript, from: Vector3, seat: Vector3, progress: float) -> void:
	# Visible local greybox step: rise outside the shell before moving inwards.
	var raised: Vector3 = from + Vector3(0.0, 0.95, 0.0)
	person.global_position = from.lerp(raised, smoothstep(0.0, 1.0, progress * 2.5)) if progress < 0.4 else raised.lerp(mary.to_global(seat), smoothstep(0.0, 1.0, (progress - 0.4) / 0.6))
	person.face(Vector3.RIGHT, 1.0, 1.0)
	person.reset_pose()
	person.visual.rotation.y = PI

func _seat(person: HumanScript, offset: Vector3) -> void:
	person.global_position = mary.to_global(offset)
	person.rotation.y = mary.rotation.y
	person.pose_seated()

func _update_drive(delta: float) -> void:
	var drive_axis: float = float(held.has("forward")) - float(held.has("back")) if input_enabled else 0.0
	var turn_axis: float = float(held.has("right")) - float(held.has("left")) if input_enabled else 0.0
	var drive_ready: bool = engine_running and player_seated and mother_seated and not exited and input_enabled
	if drive_axis != 0.0 and boarded and not drive_ready and not exited:
		show_feedback("WAIT_MOTHER" if engine_running else "ENGINE_OFF")
	var target_speed: float = drive_axis * 3.0 if drive_ready else 0.0
	if target_speed == 0.0:
		speed = 0.0
	else:
		if speed * target_speed < 0.0:
			speed = 0.0
		speed = move_toward(speed, target_speed, delta * 2.6)
	if absf(speed) > 0.05:
		var old_rotation: float = mary.rotation.y
		mary.rotation.y += turn_axis * 0.40 * delta * signf(speed)
		# Check rotation overlaps, but do not mistake floor support for a wall.
		var rotation_probe: KinematicCollision3D = KinematicCollision3D.new()
		if turn_axis != 0.0 and mary.test_move(mary.global_transform, Vector3.ZERO, rotation_probe, 0.001, true, 8):
			for index: int in range(rotation_probe.get_collision_count()):
				if absf(rotation_probe.get_normal(index).y) < 0.6:
					mary.rotation.y = old_rotation
					speed = 0.0
					collision_count += 1
					show_feedback("COLLISION")
					break
	mary.velocity = mary.global_basis.z * speed
	mary.velocity.y = -0.4
	# C0 experience: floor support must not project horizontal motion along walls.
	mary.move_and_collide(Vector3(0.0, mary.velocity.y * delta, 0.0))
	tank_collision = mary.move_and_collide(Vector3(mary.velocity.x, 0.0, mary.velocity.z) * delta)
	if tank_collision != null:
		speed = 0.0
		mary.velocity = Vector3.ZERO
		collision_count += 1
		show_feedback("COLLISION")
	# All physical hull/base corners, plus the outward boarding step, must clear.
	rear_clear_z = INF
	for x: float in [-1.98, 1.81]:
		for z: float in [-2.7, 2.7]:
			rear_clear_z = minf(rear_clear_z, mary.to_global(Vector3(x, 0.0, z)).z)
	if drive_ready and rear_clear_z > 4.2:
		exited = true
		speed = 0.0
		mary.velocity = Vector3.ZERO
		held.clear()
		show_feedback("EXITED")

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
	var car_focus: Vector3 = mary.global_position + Vector3(0.0, 1.1, 0.3)
	var mother_focus: Vector3 = mother.global_position + Vector3(0.0, 1.1, 0.0)
	var relation_focus: Vector3 = car_focus.lerp(mother_focus, 0.52)
	var shared_focus: Vector3 = relation_focus.lerp(player.global_position + Vector3(0.0, 1.1, 0.0), 0.52)
	var wanted_focus: Vector3 = FIRST_TARGET.lerp(shared_focus, door_progress)
	var spread: float = maxf(player.global_position.distance_to(relation_focus) - 5.0, 0.0)
	var wanted_position: Vector3 = FIRST_CAMERA.lerp(wanted_focus + RELATION_OFFSET * (1.0 + minf(spread * 0.06, 0.3)), door_progress)
	wanted_position.x = lerpf(FIRST_CAMERA.x, clampf(player.position.x * 2.0 - 1.0, -5.2, 5.2), door_progress)
	if boarded:
		wanted_focus = mary.global_position + Vector3(0.0, 1.3, 0.5)
		wanted_position = wanted_focus + Vector3(-5.0, 6.5, -7.6)
	var response: float = 1.0 - exp(-delta * 2.2)
	camera_focus = camera_focus.lerp(wanted_focus, response)
	camera.position = camera.position.lerp(wanted_position, response)
	camera.look_at(camera_focus, Vector3.UP)

func _interact() -> void:
	if not door_open and _near_door():
		door_open = true
		show_feedback("OPEN")
	elif not boarded and door_open and _near_touch():
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
	player.face(Vector3.LEFT if player.position.x > mary.position.x else Vector3.RIGHT, delta, 10.0)
	if not touch_contacted and player.reach_amount >= 0.98 and _player_hand_on_body():
		touch_contacted = true
		player_touched = true
		show_feedback("TOUCH")
	touch_clock = maxf(touch_clock - delta, 0.0)
	if touch_clock <= 0.0 and not touch_contacted:
		show_feedback("TOUCH_MISS")

func _player_hand_on_body() -> bool:
	var hand: Marker3D = player.get_node("Visual/LeftUpperArm/LeftLowerArm/Hand") as Marker3D
	var local: Vector3 = mary.to_local(hand.global_position)
	var shell_x: float = 1.6 if player.position.x > mary.position.x else -1.6
	var shell_point: Vector3 = Vector3(shell_x, clampf(local.y, 0.1, 1.55), clampf(local.z, -2.7, 2.7))
	if shell_x < 0.0 and local.z > -0.16 and local.z < 1.16 and local.y > 0.96 and local.y < 1.40:
		return false
	return hand.global_position.distance_to(mary.to_global(shell_point)) <= 0.14

func _near_door() -> bool:
	return absf(player.position.x) < 1.9 and absf(player.position.z - 4.0) < 1.65

func _near_touch() -> bool:
	var local: Vector3 = mary.to_local(player.global_position)
	var horizontal: Vector2 = Vector2(absf(local.x) - 1.6, local.z - clampf(local.z, -2.7, 2.7))
	return absf(local.x) > 1.6 and horizontal.length() < 1.55

func _update_text(delta: float) -> void:
	if boarded:
		hint.text = tr("DRIVE_HINT") if engine_running else (tr("START_HINT") + " " + str(roundi(start_progress / 1.2 * 100.0)) + "%")
	else:
		hint.text = tr("DOOR_HINT") if not door_open and _near_door() else (tr("TOUCH_HINT") if door_open and _near_touch() else "")
		if door_open and player.global_position.distance_to($Mary/BoardStep.global_position) <= 1.0:
			hint.text += " · " + tr("BOARD_HINT")
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
	input_enabled = true
	for wall: MeshInstance3D in wall_meshes:
		var material: StandardMaterial3D = wall.material_override as StandardMaterial3D
		var color: Color = material.albedo_color
		color.a = 1.0
		material.albedo_color = color
	mary.position = MARY_START
	mary.rotation = Vector3.ZERO
	mary.velocity = Vector3.ZERO
	player.position = PLAYER_START
	mother.position = MOTHER_START
	player.rotation = Vector3.ZERO
	mother.rotation = Vector3.ZERO
	player.visible = true
	mother.visible = true
	player.collision_layer = 0
	player.collision_mask = 0
	mother.collision_layer = 0
	mother.collision_mask = 0
	reset_physics_pending = true
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
	assistance_requested = false
	contact_valid = false
	boarded = false
	player_seated = false
	mother_seated = false
	player_climb = 0.0
	mother_climb = 0.0
	player_climb_start = Vector3.ZERO
	mother_climb_start = Vector3.ZERO
	engine_running = false
	start_progress = 0.0
	speed = 0.0
	exited = false
	rear_clear_z = -4.2
	collision_count = 0
	tank_collision = null
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
