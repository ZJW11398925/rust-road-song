extends SceneTree

const GarageScript = preload("res://garage.gd")
var garage: GarageScript
var failures: int = 0
var capture_dir: String = ""
var capture_index: int = 0
var frame_counter: int = 0
var active_keys: Dictionary = {}

func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			capture_dir = argument.trim_prefix("--capture-dir=")
	call_deferred("_run")

func _check(condition: bool, label: String) -> void:
	print(("PASS " if condition else "FAIL ") + label)
	if not condition:
		failures += 1

func _key(code: Key, pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	if pressed:
		active_keys[code] = true
	else:
		active_keys.erase(code)

func _release() -> void:
	for code: Key in active_keys.keys():
		_key(code, false)

func _frames(count: int) -> void:
	for index: int in count:
		await physics_frame
		await process_frame
		frame_counter += 1
		if capture_dir != "" and frame_counter % 12 == 0:
			await _capture()

func _capture() -> void:
	if capture_dir == "":
		return
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(capture_dir.path_join("frame_%05d.png" % capture_index))
	if error != OK:
		_check(false, "capture save error %d" % error)
		capture_dir = ""
	capture_index += 1

func _tap(code: Key) -> void:
	_key(code, true)
	await _frames(2)
	_key(code, false)
	await _frames(2)

func _walk_to(target: Vector3) -> bool:
	for attempt: int in 360:
		var offset: Vector3 = target - garage.person.position
		offset.y = 0.0
		if offset.length() < 0.30:
			_release()
			await _frames(2)
			return true
		var right: Vector3 = garage.camera.global_basis.x
		right.y = 0.0
		right = right.normalized()
		var forward: Vector3 = -garage.camera.global_basis.z
		forward.y = 0.0
		forward = forward.normalized()
		var horizontal: float = offset.dot(right)
		var vertical: float = offset.dot(forward)
		var desired: Dictionary = {}
		if absf(horizontal) > 0.18:
			desired[KEY_D if horizontal > 0.0 else KEY_A] = true
		if absf(vertical) > 0.18:
			desired[KEY_W if vertical > 0.0 else KEY_S] = true
		for code: Key in [KEY_W, KEY_S, KEY_A, KEY_D]:
			if desired.has(code) != active_keys.has(code):
				_key(code, desired.has(code))
		await _frames(3)
	_release()
	return false

func _board() -> void:
	_check(await _walk_to(Vector3(-3.1, 0.05, 1.0)), "real input reaches left boarding side")
	await _tap(KEY_E)
	_check(garage.driving and not garage.person.visible, "one enter changes control without inspection unlock")

func _run() -> void:
	var main_path: String = ProjectSettings.get_setting("application/run/main_scene", "")
	var scene_error: Error = change_scene_to_file(main_path)
	if scene_error != OK:
		_check(false, "configured main scene loads")
		quit(1)
		return
	await scene_changed
	garage = current_scene as GarageScript
	_check(tr("TITLE") == "C0 空间与操作实验 · 方块占位", "central Translation registered and Chinese title resolves")
	await _frames(6)
	if capture_dir != "":
		DirAccess.make_dir_recursive_absolute(capture_dir)
		await _capture()
	_check(not garage.driving and not garage.door_open, "initial person and closed solid door")
	await _tap(KEY_E)
	_check(garage.feedback_key == "FAR" and garage.message.text != "", "far action produces visible feedback")
	var start: Vector3 = garage.person.position
	_key(KEY_W, true)
	await _frames(20)
	_release()
	await _frames(2)
	_check(garage.person.position.distance_to(start) > 0.5, "mapped input moves during SceneTree physics lifecycle")
	# RED baseline fails here for the intended absent movement; avoid waiting through all routes.
	if garage.person.position.distance_to(start) <= 0.5:
		print("C0_SMOKE_RED missing movement")
		quit(1)
		return
	await _tap(KEY_R)
	_check(await _walk_to(Vector3(-3.2, 0.05, 0.5)), "walk to first distinct side")
	_check(await _walk_to(Vector3(-3.2, 0.05, 5.3)), "walk around rear clearance")
	_check(await _walk_to(Vector3(3.2, 0.05, 5.3)), "cross behind tank without overlap")
	_check(await _walk_to(Vector3(3.2, 0.05, 0.5)), "walk to second side / spatial reference")
	_check(not garage.driving and not garage.door_open, "spatial reference changes no mechanical state")
	await _tap(KEY_E)
	_check(garage.driving, "enter from second side")
	await _tap(KEY_E)
	_check(garage.driving, "repeat E cannot dismount")
	await _tap(KEY_R)
	await _board()
	_key(KEY_W, true)
	await _frames(210)
	_release()
	await _frames(2)
	_check(garage.tank.position.z > -7.4 and not garage.exited, "closed door physically stops early-board driving")
	_check(garage.feedback_key == "COLLISION", "closed door collision feedback visible")
	await _tap(KEY_E)
	_check(garage.door_open, "early-board route can open door while driving")
	_check(not garage.door.visible, "opened placeholder slab no longer occludes tank composition")
	await _tap(KEY_E)
	_check(garage.door_open and garage.driving, "repeat open stays open with no exit control")
	_key(KEY_W, true)
	await _frames(175)
	_release()
	await _frames(2)
	_check(garage.exited and garage.tank.position.z < -14.0, "low-speed input drives fully through exit")
	var exit_position: Vector3 = garage.tank.position
	var exit_heading: float = garage.tank.rotation.y
	_key(KEY_W, true)
	_key(KEY_A, true)
	await _frames(180)
	_release()
	await _frames(2)
	_check(garage.tank.position.distance_to(exit_position) < 0.05 and absf(garage.speed) < 0.01, "POC ending bounds continued throttle without leaving floor / camera")
	_check(absf(garage.tank.rotation.y - exit_heading) < 0.01, "POC ending ignores continued turn")
	await _tap(KEY_R)
	_check(not garage.driving and not garage.door_open and not garage.exited and garage.person.visible, "R restores identical initial scene")
	_check(garage.door.visible and garage.door.position == Vector3.ZERO, "reset restores visible closed door slab")
	_check(await _walk_to(Vector3(-2.8, 0.05, -6.0)), "walking can approach closed exit")
	await _tap(KEY_E)
	_check(garage.door_open, "door placeholder also available walking")
	await _tap(KEY_E)
	_check(garage.door_open, "walking repeat open never closes")
	# Owner L5 reproduction: profile 2, oblique input into closed front wall/door.
	await _tap(KEY_2)
	await _board()
	_key(KEY_W, true)
	_key(KEY_A, true)
	await _frames(45)
	_key(KEY_A, false)
	var tank_contact: bool = false
	for contact_wait: int in 240:
		await _frames(3)
		if garage.tank_collision != null and absf(garage.tank_collision.get_normal().y) < 0.6:
			tank_contact = true
		if tank_contact:
			break
	_check(tank_contact and garage.feedback_key == "COLLISION", "profile 2 real W+A then W reaches oblique solid obstacle with visible feedback")
	var contact_x: float = garage.tank.position.x
	var contact_heading: float = garage.tank.rotation.y
	await _frames(180)
	var lateral_drift: float = absf(garage.tank.position.x - contact_x)
	print("C0_COLLISION_REPRO heading=%.4f contact_x=%.4f final_x=%.4f drift=%.4f" % [contact_heading, contact_x, garage.tank.position.x, lateral_drift])
	_check(tank_contact and lateral_drift < 0.08, "holding W against oblique obstacle must not cause automatic lateral tank slide (<0.08m)")
	_release()
	await _frames(2)
	var recovery_start: Vector3 = garage.tank.position
	var reverse_direction: Vector3 = garage.tank.global_basis.z
	_key(KEY_S, true)
	await _frames(60)
	_release()
	await _frames(2)
	var recovery_offset: Vector3 = garage.tank.position - recovery_start
	_check(recovery_offset.dot(reverse_direction) > 0.3 and garage.tank_collision == null and absf(recovery_offset.y) < 0.03 and absf(garage.tank.rotation.y - contact_heading) < 0.01, "real S reverses >0.3m, releases collision, preserves floor height and heading")
	await _frames(70)
	var restart_position: Vector3 = garage.tank.position
	_key(KEY_W, true)
	await _frames(45)
	_release()
	await _frames(2)
	_check((garage.tank.position - restart_position).dot(-reverse_direction) > 0.3 and garage.tank_collision == null, "fresh W advances again after reverse recovery without freezing")
	_release()
	await _frames(2)
	await _tap(KEY_1)
	await _board()
	_key(KEY_W, true)
	await _frames(15)
	var instant_speed: float = garage.speed
	_release()
	await _frames(3)
	_check(absf(garage.speed) < 0.01, "profile 1 stops immediately")
	await _tap(KEY_2)
	_check(garage.profile == 2 and not garage.driving and garage.tank.position.distance_to(Vector3(0.0, 0.05, 1.0)) < 0.1, "profile key resets same initial conditions")
	await _board()
	_key(KEY_W, true)
	await _frames(15)
	var gradual_speed: float = garage.speed
	_check(instant_speed > gradual_speed and gradual_speed > 0.0, "profile 2 slight acceleration differs under identical input")
	_key(KEY_A, true)
	await _frames(15)
	_key(KEY_A, false)
	_check(absf(garage.tank.rotation.y) > 0.01 and absf(garage.tank.rotation.y) < 0.25, "profile 2 limited turn responds")
	var release_position: Vector3 = garage.tank.position
	var release_heading: float = garage.tank.rotation.y
	_key(KEY_W, false)
	_key(KEY_A, true)
	await _frames(60)
	_key(KEY_A, false)
	var release_offset: Vector3 = garage.tank.position - release_position
	var release_drift: float = Vector2(release_offset.x, release_offset.z).length()
	print("C0_RELEASE_REPRO drift=%.4f speed=%.4f heading_delta=%.4f" % [release_drift, garage.speed, garage.tank.rotation.y - release_heading])
	_check(absf(garage.speed) < 0.01 and release_drift < 0.01 and absf(garage.tank.rotation.y - release_heading) < 0.01, "profile 2 released throttle stops immediately; held steering causes no drift or turn for 60 frames")
	await _frames(10)
	_check(absf(garage.speed) < 0.01, "profile 2 remains stopped without throttle")
	_key(KEY_W, true)
	await _frames(12)
	var switch_position: Vector3 = garage.tank.position
	var switch_reverse: Vector3 = garage.tank.global_basis.z
	_key(KEY_W, false)
	_key(KEY_S, true)
	await _frames(3)
	_check(garage.speed < 0.0 and (garage.tank.position - switch_position).dot(switch_reverse) >= -0.001, "real W to S direction switch never continues old forward travel")
	_release()
	await _frames(2)
	_key(KEY_W, true)
	await _frames(12)
	garage.propagate_notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	var focus_position: Vector3 = garage.tank.position
	await _frames(20)
	_check(garage.tank.position.distance_to(focus_position) < 0.05 and garage.held.is_empty(), "injected focus-loss notification clears motion and held keys (not OS focus evidence)")
	garage.propagate_notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	await _frames(12)
	_check(garage.tank.position.distance_to(focus_position) < 0.05, "stale held key never restarts after injected focus-in")
	_release()
	await _frames(3)
	_key(KEY_W, true)
	await _frames(20)
	_check(garage.tank.position.distance_to(focus_position) > 0.05, "fresh movement press after injected focus-in responds")
	_release()
	await _frames(3)
	await _tap(KEY_R)
	_check(garage.person.position.distance_to(Vector3(-4.0, 0.05, 6.0)) < 0.1, "reset after focus safety")
	print("C0_SMOKE_RESULT failures=%d captures=%d" % [failures, capture_index])
	quit(0 if failures == 0 else 1)
