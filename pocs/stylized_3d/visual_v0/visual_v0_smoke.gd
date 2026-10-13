extends SceneTree

var stage: Node3D
var failures: int = 0
var checks: int = 0
var frames: int = 0
var capture_dir: String = ""

func _initialize() -> void:
	root.focus_entered.connect(func() -> void: print("WINDOW_FOCUS_IN frames=", frames))
	root.focus_exited.connect(func() -> void: print("WINDOW_FOCUS_OUT frames=", frames))
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
		print("INPUT_DIAGNOSTIC enabled=", stage.get("input_enabled"), " held=", stage.get("held"), " player=", (stage.get_node("Player") as CharacterBody3D).position, " feedback=", stage.get("feedback_key"), " frames=", frames)
	else:
		print("PASS ", label)

# Inputs retain the current greybox's world X/Z walking convention. No teleport.
func _travel(axis: String, goal: float, limit: int = 240) -> void:
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
	_check(absf(actual - goal) < 0.16, "real walking " + axis + "=" + str(goal))

func _capture(label: String) -> void:
	if capture_dir.is_empty():
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var picture: Image = root.get_texture().get_image()
	_check(not picture.is_empty() and picture.get_width() >= 640, "rendered " + label)
	if not picture.is_empty():
		_check(picture.save_png(capture_dir.path_join(label + ".png")) == OK, "PNG " + label)

func _enter() -> void:
	await _travel("z", 5.5)
	await _tap(KEY_E)
	await _wait(75)
	_check(bool(stage.get("first_reveal")), "real E door reveals Mary")
	await _travel("z", 2.4)

func _board() -> void:
	await _travel("x", -2.4)
	await _travel("z", 0.5)
	await _tap(KEY_F)
	_check(bool(stage.get("boarded")), "near step F boards")
	await _wait(65)
	_check(bool(stage.get("player_seated")), "player visibly finishes climb")

func _contact() -> void:
	for tick: int in range(500):
		if bool(stage.get("contact_valid")):
			break
		await _wait(1)
	var hand: Marker3D = stage.get_node("Mother/Visual/LeftUpperArm/LeftLowerArm/Hand") as Marker3D
	var target: Marker3D = stage.get_node("Mary/StartContact") as Marker3D
	_check(bool(stage.get("contact_valid")) and hand.global_position.distance_to(target.global_position) <= 0.14, "power requires actual mother hand within .14m")

func _start() -> bool:
	_key(KEY_F, true)
	await _wait(80)
	_key(KEY_F, false)
	await _wait(2)
	_check(bool(stage.get("engine_running")), "held F starts with actual power on first powered attempt")
	return bool(stage.get("engine_running"))

func _seat_mother() -> void:
	var mary: CharacterBody3D = stage.get_node("Mary") as CharacterBody3D
	var held_position: Vector3 = mary.position
	_key(KEY_W, true)
	await _wait(10)
	_key(KEY_W, false)
	_check(mary.position.distance_to(held_position) < 0.02 and stage.get("feedback_key") == "WAIT_MOTHER", "physical unseated mother brakes early driving with feedback")
	for tick: int in range(450):
		if bool(stage.get("mother_seated")):
			break
		await _wait(1)
	_check(bool(stage.get("mother_seated")), "mother walks outside solid car and visibly climbs to seat")
	var hand: Marker3D = stage.get_node("Mother/Visual/LeftUpperArm/LeftLowerArm/Hand") as Marker3D
	var target: Marker3D = stage.get_node("Mary/StartContact") as Marker3D
	_check(hand.global_position.distance_to(target.global_position) > 0.5, "running engine no longer needs mother hand on contact")
	_check((stage.get_node("Player") as Node3D).visible and (stage.get_node("Mother") as Node3D).visible, "both occupants remain visible")

func _reset_check() -> void:
	await _tap(KEY_R)
	await _wait(5)
	var mary: CharacterBody3D = stage.get_node("Mary") as CharacterBody3D
	var player: CharacterBody3D = stage.get_node("Player") as CharacterBody3D
	var mother: CharacterBody3D = stage.get_node("Mother") as CharacterBody3D
	_check(mary.position.distance_to(Vector3(0, 0, -1.5)) < 0.1 and absf(mary.rotation.y) < 0.001, "R restores car transform")
	_check(player.position.distance_to(Vector3(-0.75, 0, 6.8)) < 0.1 and mother.position.distance_to(Vector3(0.75, 0, 6.8)) < 0.1, "R restores both people")
	_check(not bool(stage.get("boarded")) and not bool(stage.get("engine_running")) and not bool(stage.get("mother_seated")) and not bool(stage.get("exited")), "R clears seating engine departure")
	_check(float(stage.get("start_progress")) == 0.0 and (stage.get("held") as Dictionary).is_empty() and int(stage.get("mother_stage")) == 0, "R clears input progress and mother route")
	_check(player.visible and mother.visible and player.collision_layer == 4 and mother.collision_layer == 2, "R restores visible solid people")
	_check((stage.get_node("Camera3D") as Camera3D).position.distance_to(Vector3(0, 4.5, 13)) < 0.1, "R restores camera")
	_check(((stage.get_node("EntryLeft/Mesh") as MeshInstance3D).material_override as StandardMaterial3D).albedo_color.a > 0.99, "R restores wall opacity")

func _finish_failed() -> void:
	print("VISUAL_V0_SMOKE checks=", checks, " failures=", failures, " frames=", frames)
	quit(1)

func _run() -> void:
	if not capture_dir.is_empty():
		_check(DisplayServer.get_name() != "headless", "capture uses visible rendering")
		_check(DirAccess.make_dir_recursive_absolute(capture_dir) == OK, "capture directory")
	var actual_main: String = str(ProjectSettings.get_setting("application/run/main_scene"))
	_check(actual_main == "res://visual_v0.tscn", "actualMainScene is visual_v0")
	var packed: PackedScene = load(actual_main) as PackedScene
	stage = packed.instantiate() as Node3D
	root.add_child(stage)
	current_scene = stage
	await _wait(12)
	var mary: CharacterBody3D = stage.get_node("Mary") as CharacterBody3D
	var player: CharacterBody3D = stage.get_node("Player") as CharacterBody3D
	await _tap(KEY_F)
	_check(stage.get("feedback_key") == "BOARD_FAR" and not bool(stage.get("boarded")), "distant F has feedback and no board")
	_key(KEY_W, true)
	await _wait(4)
	_key(KEY_W, false)
	_check(mary.position.distance_to(Vector3(0, 0, -1.5)) < 0.1, "walking keys cannot drive before boarding")
	await _enter()
	await _capture("01-first-reveal")
	await _board()
	_check(not bool(stage.get("player_touched")), "early route ignores anomaly and touch")
	_check(not bool(stage.get("contact_valid")), "early arrival precedes contact")
	_key(KEY_W, true)
	await _wait(8)
	_key(KEY_W, false)
	_check(stage.get("feedback_key") == "ENGINE_OFF" and float(stage.get("speed")) == 0.0, "pre-engine W reports mechanical stop")
	_key(KEY_F, true)
	await _wait(8)
	_check(stage.get("feedback_key") == "NO_CONTACT" and float(stage.get("start_progress")) == 0.0, "early F gives unsteady contact cause")
	_key(KEY_F, false)
	await _wait(2)
	await _contact()
	await _capture("04-assistance-contact")
	_key(KEY_F, true)
	await _wait(30)
	_check(float(stage.get("start_progress")) > 0.3 and not bool(stage.get("engine_running")), "powered partial hold accumulates only current attempt")
	_key(KEY_F, false)
	await _wait(2)
	_check(float(stage.get("start_progress")) == 0.0, "release F stops and clears incomplete crank")
	_key(KEY_F, true)
	await _wait(20)
	# Explicit logical notification probe, not OS focus evidence.
	stage.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await _wait(2)
	_check((stage.get("held") as Dictionary).is_empty() and float(stage.get("start_progress")) == 0.0 and not bool(stage.get("input_enabled")), "logical focus probe clears crank and held input")
	_key(KEY_F, false)
	stage.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	_key(KEY_F, true)
	await _wait(20)
	_check(float(stage.get("start_progress")) > 0.2, "fresh F resumes after logical focus recovery")
	await _reset_check()
	_key(KEY_F, false)
	# Late first attempt: real walking around both sides, without narrative gates.
	await _enter()
	await _travel("x", -3.10)
	await _travel("z", -1.0)
	await _travel("x", -2.30)
	await _tap(KEY_E)
	await _wait(35)
	_check(bool(stage.get("touch_contacted")), "real E left-side hand contact")
	await _capture("02-left-touch")
	await _travel("x", -3.10)
	await _travel("z", 2.4)
	await _travel("x", 2.30)
	await _travel("z", -1.0)
	await _tap(KEY_E)
	await _wait(35)
	_check(bool(stage.get("touch_contacted")) and player.position.x > 0.0, "real E right-side hand contact")
	await _capture("03-right-touch")
	await _travel("z", 2.4)
	await _board()
	await _contact()
	if not await _start():
		_finish_failed()
		return
	await _seat_mother()
	var before: Vector3 = mary.position
	var camera_before: Vector3 = (stage.get_node("Camera3D") as Camera3D).position
	_key(KEY_W, true)
	await _wait(25)
	_key(KEY_W, false)
	await _wait(2)
	var stopped: Vector3 = mary.position
	_check(stopped.z > before.z + 0.1, "W accelerates Mary toward +Z")
	_check(float(stage.get("speed")) == 0.0, "release W clears speed immediately")
	await _wait(10)
	_check(mary.position.distance_to(stopped) < 0.015, "release W produces no coasting")
	_key(KEY_S, true)
	await _wait(15)
	_key(KEY_S, false)
	await _wait(2)
	_check(mary.position.z < stopped.z - 0.03 and float(stage.get("speed")) == 0.0, "real S reverses and release stops")
	_check((stage.get_node("Camera3D") as Camera3D).position.distance_to(camera_before) > 0.1, "drive camera follows smoothly")
	_check(player.global_position.distance_to(mary.to_global(Vector3(0.65, 0.95, 1.8))) < 0.03, "driver follows car in seat")
	_key(KEY_W, true)
	_key(KEY_D, true)
	await _wait(50)
	_key(KEY_D, false)
	await _wait(140)
	_check(int(stage.get("collision_count")) > 0 and float(stage.get("speed")) == 0.0, "real turned car strikes door frame and stops same frame")
	var impact: Vector3 = mary.position
	await _wait(15)
	_check(mary.position.distance_to(impact) < 0.025, "held forward at frame does not slide sideways")
	_key(KEY_W, false)
	await _reset_check()
	# Final touch-free route proves successful start does not depend on either side.
	await _enter()
	await _board()
	await _contact()
	_check(not bool(stage.get("player_touched")), "final route has no touch requirement")
	if not await _start():
		_finish_failed()
		return
	await _seat_mother()
	_key(KEY_W, true)
	await _wait(25)
	stage.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await _wait(2)
	var focus_stop: Vector3 = mary.position
	await _wait(5)
	_check(float(stage.get("speed")) == 0.0 and mary.position.distance_to(focus_stop) < 0.015, "logical focus probe stops driving")
	_key(KEY_W, false)
	stage.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	_key(KEY_W, true)
	for tick: int in range(380):
		await _wait(1)
		if bool(stage.get("exited")):
			break
	_key(KEY_W, false)
	_check(bool(stage.get("exited")) and float(stage.get("rear_clear_z")) > 4.2, "entire rotated vehicle clears door before end")
	_check(mary.position.z < 11.0 and absf(mary.position.y) < 0.1 and float(stage.get("speed")) == 0.0, "short departure ends on supported outside floor")
	_check((stage.get_node("Mother") as Node3D).global_position.distance_to(mary.to_global(Vector3(-0.65, 0.95, 1.8))) < 0.03, "mother travels with Mary")
	await _capture("05-outside-parked")
	await _reset_check()
	print("VISUAL_V0_SMOKE checks=", checks, " failures=", failures, " frames=", frames)
	if failures > 0:
		quit(1)
		return
	print("VISUAL_V0_SMOKE ESC_INPUT_SENT")
	_key(KEY_ESCAPE, true)
	await _wait(3)
	print("FAIL Escape did not exit via actual input")
	quit(1)
