extends SceneTree

var stage: Node3D
var failures: int = 0
var checks: int = 0
var frames: int = 0
var capture_dir: String = ""

func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="):
			capture_dir = arg.trim_prefix("--capture-dir=")
	call_deferred("_run")

func _key(code: Key, pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func _wait(count: int) -> void:
	for index: int in range(count):
		await physics_frame
		frames += 1

func _tap(code: Key) -> void:
	_key(code, true)
	await _wait(1)
	_key(code, false)
	await _wait(1)

func _check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FAIL ", label)
	else:
		print("PASS ", label)

# All travel uses real key events. This helper never relocates the body.
func _travel(axis: String, goal: float, limit: int = 160) -> void:
	var body: CharacterBody3D = stage.get_node("Player") as CharacterBody3D
	var difference: float = goal - (body.position.x if axis == "x" else body.position.z)
	var code: Key = (KEY_D if difference > 0.0 else KEY_A) if axis == "x" else (KEY_S if difference > 0.0 else KEY_W)
	_key(code, true)
	for tick: int in range(limit):
		await _wait(1)
		var current: float = body.position.x if axis == "x" else body.position.z
		if absf(current - goal) < 0.07:
			break
	_key(code, false)
	await _wait(2)
	var actual: float = body.position.x if axis == "x" else body.position.z
	_check(absf(actual - goal) < 0.15, "key travel " + axis + "=" + str(goal))

func _capture(label: String) -> void:
	if capture_dir.is_empty():
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var picture: Image = root.get_texture().get_image()
	_check(not picture.is_empty() and picture.get_width() >= 640, "rendered image " + label)
	if not picture.is_empty():
		_check(picture.save_png(capture_dir.path_join(label + ".png")) == OK, "PNG " + label)

func _run() -> void:
	if not capture_dir.is_empty():
		_check(DisplayServer.get_name() != "headless", "capture uses visible rendering")
		_check(DirAccess.make_dir_recursive_absolute(capture_dir) == OK, "capture directory")
	var packed: PackedScene = load("res://anomaly.tscn") as PackedScene
	stage = packed.instantiate() as Node3D
	root.add_child(stage)
	current_scene = stage
	await _wait(12)
	var player: CharacterBody3D = stage.get_node("Player") as CharacterBody3D
	await _capture("01-entry")
	await _tap(KEY_E)
	_check(stage.get("feedback_key") == "FAR", "distant interaction has visible feedback")
	_check(not bool(stage.get("door_open")), "distant action does not open door")
	await _travel("z", 5.5)
	await _tap(KEY_E)
	await _wait(75)
	_check(bool(stage.get("first_reveal")), "door reveal restores free entry")
	# Walk in, ignore the detail, return to the threshold, and enter again.
	await _travel("z", 2.4)
	await _travel("z", 3.4)
	_check(not bool(stage.get("player_touched")), "ignoring detail does not synthesize contact")
	# The mother remains solid. Approach around her outside shoulder.
	await _travel("x", -3.10)
	await _travel("z", -1.0)
	await _travel("x", -2.30)
	_check(int(stage.get("mother_stage")) < 4, "early touch precedes mother reaction")
	_check((stage.get_node("HUD/Narrative") as Label).text.is_empty(), "early touch needs no past-state line")
	await _tap(KEY_E)
	await _wait(35)
	_check(bool(stage.get("player_touched")), "left hand physically reaches shell")
	var left_position: Vector3 = player.position
	_key(KEY_A, true)
	await _wait(14)
	_key(KEY_A, false)
	_check(player.position.x < left_position.x - 0.4, "continued movement after first touch")
	for tick: int in range(260):
		if int(stage.get("mother_stage")) >= 4:
			break
		await _wait(1)
	_check(int(stage.get("reaction_count")) == 1, "mother reaction occurs once")
	_check(float(stage.get("narrative_clock")) > 0.0, "one past-state line is present")
	var hand: Marker3D = stage.get_node("Mother/Visual/LeftUpperArm/LeftLowerArm/Hand") as Marker3D
	var edge_start: Vector3 = (stage.get_node("Mary/Anomaly/EdgeStart") as Marker3D).global_position
	var edge_end: Vector3 = (stage.get_node("Mary/Anomaly/EdgeEnd") as Marker3D).global_position
	_check(hand.global_position.distance_to(edge_start) < 0.12, "mother hand reaches actual old edge")
	var hand_start: Vector3 = hand.global_position
	await _capture("02-old-edge-and-reaction")
	var before_dialogue: Vector3 = player.position
	_key(KEY_S, true)
	await _wait(12)
	_key(KEY_S, false)
	_check(player.position.z > before_dialogue.z + 0.35, "movement during dialogue")
	await _wait(65)
	_check(hand.global_position.distance_to(hand_start) > 0.15, "mother hand moves along edge")
	_check(hand.global_position.distance_to(edge_end) < 0.12, "sweep stays at old lip endpoint")
	await _capture("03-edge-sweep")
	await _wait(65)
	_check(int(stage.get("mother_stage")) == 6, "mother retracts once and returns to rest")
	_check(hand.global_position.y < 1.0, "hand physically returns below shoulder")
	await _capture("04-hand-retracted")
	# Avoid the mother and the shell by going around the front. No side gate.
	await _travel("z", 2.5)
	await _travel("x", 2.30)
	await _travel("z", -1.0)
	await _tap(KEY_E)
	_check(float(stage.get("touch_clock")) > 0.0, "right-side input starts a fresh touch attempt")
	await _wait(35)
	var player_hand: Marker3D = player.get_node("Visual/LeftUpperArm/LeftLowerArm/Hand") as Marker3D
	var mary: Node3D = stage.get_node("Mary") as Node3D
	var right_hand_local: Vector3 = mary.to_local(player_hand.global_position)
	var right_shell_point: Vector3 = mary.to_global(Vector3(1.6, clampf(right_hand_local.y, 0.1, 1.55), clampf(right_hand_local.z, -2.7, 2.7)))
	_check(bool(stage.get("touch_contacted")) and player.position.x > mary.position.x and right_hand_local.x > 0.0 and player_hand.global_position.distance_to(right_shell_point) <= 0.14, "right-side shell touch uses real hand contact")
	var right_position: Vector3 = player.position
	_key(KEY_D, true)
	await _wait(10)
	_key(KEY_D, false)
	_check(player.position.x > right_position.x + 0.25, "second touch also retains control")
	_check(int(stage.get("reaction_count")) == 1, "return and repeated contact do not replay reaction")
	await _capture("05-other-side")
	_key(KEY_S, true)
	await _wait(3)
	stage.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await _wait(3)
	_check((stage.get("held") as Dictionary).is_empty(), "focus-out clears held keys")
	_check(not bool(stage.get("input_enabled")), "focus-out suspends movement")
	_key(KEY_S, false)
	stage.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	_check(bool(stage.get("input_enabled")), "focus-in restores control")
	var recovered: Vector3 = player.position
	_key(KEY_S, true)
	await _wait(10)
	_key(KEY_S, false)
	_check(player.position.z > recovered.z + 0.25, "fresh input works after focus-in")
	await _tap(KEY_R)
	await _wait(10)
	_check(player.position.distance_to(Vector3(-0.75, 0.0, 6.8)) < 0.1, "R returns player to initial position")
	_check(not bool(stage.get("door_open")) and not bool(stage.get("player_touched")), "R clears reveal and touch")
	_check(int(stage.get("reaction_count")) == 0 and int(stage.get("mother_stage")) == 0, "R restores single-reaction state")
	_check((stage.get_node("HUD/Narrative") as Label).text.is_empty(), "R clears past-state line")
	await _capture("06-reset")
	print("C1B_SMOKE checks=", checks, " failures=", failures, " frames=", frames)
	if failures > 0:
		quit(1)
		return
	print("C1B_SMOKE ESC_INPUT_SENT")
	_key(KEY_ESCAPE, true)
	await _wait(3)
	print("FAIL Escape did not exit from real input")
	quit(1)
