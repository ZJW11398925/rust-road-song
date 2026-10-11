extends Node3D

const HumanScript = preload("res://human.gd")

const PLAYER_START: Vector3 = Vector3(-0.75, 0.0, 6.8)
const MOTHER_START: Vector3 = Vector3(0.75, 0.0, 6.8)
const FIRST_CAMERA: Vector3 = Vector3(0.0, 4.5, 13.0)
const RELATION_OFFSET: Vector3 = Vector3(0.0, 6.3, 7.0)
const FIRST_TARGET: Vector3 = Vector3(0.0, 1.0, 0.0)
const MOTHER_PATH: Array[Vector3] = [Vector3(0.75, 0.0, 2.4), Vector3(-2.35, 0.0, 2.4), Vector3(-2.35, 0.0, -0.68)]
@onready var player: HumanScript = $Player
@onready var mother: HumanScript = $Mother
@onready var door: StaticBody3D = $Door
@onready var camera: Camera3D = $Camera3D
@onready var panel: Node3D = $Mary/Panel
@onready var hint: Label = $HUD/Hint
@onready var feedback: Label = $HUD/Feedback
@onready var narrative: Label = $HUD/Narrative
@onready var end_label: Label = $HUD/End
var held: Dictionary = {}
var input_enabled: bool = true
var door_open: bool = false
var door_progress: float = 0.0
var first_reveal: bool = false
var mother_stage: int = 0
var mother_waypoint: int = 0
var mother_clock: float = 0.0
var player_touched: bool = false
var touch_clock: float = 0.0
var touch_contacted: bool = false
var narrative_clock: float = 0.0
var feedback_key: String = ""
var feedback_clock: float = 0.0
var camera_focus: Vector3 = FIRST_TARGET

func _ready() -> void:
	var copy: Translation = load("res://strings.tres") as Translation
	TranslationServer.add_translation(copy)
	TranslationServer.set_locale("zh_CN")
	$HUD/Title.text = tr("TITLE")
	$HUD/Help.text = tr("HELP")
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
	# The gesture turns only the local pose; WASD still moves the body throughout.
	player.walk(direction.normalized(), delta, touch_clock <= 0.0)
	_update_player_touch(delta)
	if door_open:
		door_progress = minf(door_progress + delta / 1.2, 1.0)
		door.position.y = smoothstep(0.0, 1.0, door_progress) * 6.2
		if door_progress >= 0.95:
			first_reveal = true
		_update_mother(delta)
	_update_camera(delta)
	_update_text(delta)

func _update_camera(delta: float) -> void:
	# Frame the existing relationship, not which side of a boundary the player crossed.
	var car_focus: Vector3 = $Mary.global_position + Vector3(0.0, 1.1, 0.3)
	var mother_focus: Vector3 = mother.global_position + Vector3(0.0, 1.1, 0.0)
	var relation_focus: Vector3 = car_focus.lerp(mother_focus, 0.62)
	# Share the actual space with the player instead of capping their allowance.
	var shared_focus: Vector3 = relation_focus.lerp(player.global_position + Vector3(0.0, 1.1, 0.0), 0.6)
	var wanted_focus: Vector3 = FIRST_TARGET.lerp(shared_focus, door_progress)
	var spread: float = maxf(player.global_position.distance_to(relation_focus) - 5.0, 0.0)
	var distance_scale: float = 1.0 + minf(spread * 0.06, 0.3)
	var wanted_position: Vector3 = FIRST_CAMERA.lerp(wanted_focus + RELATION_OFFSET * distance_scale, door_progress)
	# Keep the camera inside the walls and on the approaching player's side.
	# This changes continuously with position; crossing a region never switches shots.
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
			else:
				difference = MOTHER_PATH[mother_waypoint] - mother.position
		mother.walk(difference.normalized(), delta)
	elif mother_stage == 2:
		mother.walk(Vector3.ZERO, delta)
		if mother_clock > 0.55:
			mother_stage = 3
			mother_clock = 0.0
	elif mother_stage == 3:
		mother.walk(Vector3.ZERO, delta, false)
		mother.face(Vector3.RIGHT, delta, 4.0)
		# Separate the turn from the reach so this one gesture has a readable pause.
		if mother_clock > 0.8:
			mother.reach_amount = move_toward(mother.reach_amount, 1.0, delta * 1.6)
		if mother.reach_amount >= 1.0:
			mother_stage = 4
			panel.rotation.z = -0.018
			# This is experimental copy, not a new story decision.
			narrative.text = tr("MOTHER")
			narrative_clock = 4.5
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
	# Either side uses the same gesture and still requires real shell contact.
	if not touch_contacted and player.reach_amount >= 0.98 and _player_hand_on_body():
		touch_contacted = true
		player_touched = true
		show_feedback("TOUCH")
		narrative.text = tr("TOUCH")
		narrative_clock = 4.5
		end_label.text = tr("END")
	touch_clock = maxf(touch_clock - delta, 0.0)
	if touch_clock <= 0.0 and not touch_contacted:
		show_feedback("TOUCH_MISS")

func _player_hand_on_body() -> bool:
	var hand: Marker3D = player.get_node("Visual/LeftUpperArm/LeftLowerArm/Hand") as Marker3D
	var body: MeshInstance3D = $Mary/Body
	var bounds: AABB = body.mesh.get_aabb()
	var hand_local: Vector3 = body.to_local(hand.global_position)
	var shell_x: float = bounds.end.x if player.position.x > $Mary.position.x else bounds.position.x
	var shell_point: Vector3 = Vector3(shell_x, clampf(hand_local.y, bounds.position.y, bounds.end.y), clampf(hand_local.z, bounds.position.z, bounds.end.z))
	return hand.global_position.distance_to(body.to_global(shell_point)) <= 0.14

func _near_door() -> bool:
	return absf(player.position.x) < 1.9 and absf(player.position.z - 4.0) < 1.65

func _near_touch() -> bool:
	var body: MeshInstance3D = $Mary/Body
	var bounds: AABB = body.mesh.get_aabb()
	var local: Vector3 = body.to_local(player.global_position)
	var shell_x: float = bounds.end.x if local.x > 0.0 else bounds.position.x
	var horizontal: Vector2 = Vector2(local.x - shell_x, local.z - clampf(local.z, bounds.position.z, bounds.end.z))
	return absf(local.x) > bounds.end.x and horizontal.length() < 1.55

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
	player_touched = false
	touch_clock = 0.0
	touch_contacted = false
	narrative_clock = 0.0
	feedback_key = ""
	feedback_clock = 0.0
	camera_focus = FIRST_TARGET
	panel.rotation.z = 0.025
	narrative.text = ""
	feedback.text = ""
	end_label.text = ""
	camera.position = FIRST_CAMERA
	camera.look_at(FIRST_TARGET, Vector3.UP)
