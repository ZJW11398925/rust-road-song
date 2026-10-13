extends SceneTree

var failures: int = 0
var checks: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, title: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("ASSET_FAIL " + title)

func _key(code: Key, pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func _frames(count: int) -> void:
	for frame: int in range(count):
		await physics_frame

func _standing_pose(stage: Node3D) -> void:
	for rig: Skeleton3D in stage.skeletons:
		var head: Vector3 = rig.to_global(rig.get_bone_global_pose(rig.find_bone("head")).origin)
		_check(head.y > 1.3 and head.y < 2.1, "head at standing height")
		for name: String in ["foot_l", "foot_r"]:
			var foot: Vector3 = rig.to_global(rig.get_bone_global_pose(rig.find_bone(name)).origin)
			_check(foot.y > -0.1 and foot.y < 0.3, "standing foot near floor " + name)

func _capture(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var output: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="):
			output = arg.trim_prefix("--capture-dir=")
	if not output.is_empty():
		_check(root.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK, "capture " + name)

func _run() -> void:
	var stage: Node3D = load("res://asset_sample.tscn").instantiate() as Node3D
	root.add_child(stage)
	await _frames(12)
	_standing_pose(stage)
	_check(stage.people.size() == 2, "two imported people")
	for rig: Skeleton3D in stage.skeletons:
		_check(rig.get_bone_count() == 53, "library rig retained")
		for name: String in ["head", "thigh_l", "thigh_r", "upperarm_l", "upperarm_r"]:
			_check(rig.find_bone(name) >= 0, "mapped bone " + name)
	await _capture("01_normal_distance")
	var start: Vector3 = stage.player.position
	var before: Vector2 = stage.camera.unproject_position(start)
	_key(KEY_A, true)
	await _frames(12)
	await _capture("02_walking")
	await _frames(12)
	_key(KEY_A, false)
	await _frames(2)
	var after: Vector2 = stage.camera.unproject_position(stage.player.position)
	_check(after.x < before.x - 20, "A moves screen-left")
	_check(stage.player.position.distance_to(start) > 0.9, "physics movement")
	_key(KEY_D, true)
	await _frames(24)
	_key(KEY_D, false)
	await _frames(2)
	_check(stage.camera.unproject_position(stage.player.position).x > after.x + 20, "D moves screen-right")
	_key(KEY_R, true)
	_key(KEY_R, false)
	await _frames(3)
	_standing_pose(stage)
	_check(stage.player.position.distance_to(stage.initial_position) < 0.03, "reset position")
	_check(stage.player.velocity.length() < 1.0, "reset motion")
	stage.camera.size = 5.0
	await _frames(2)
	await _capture("03_detail_diagnostic")
	print("ASSET_SMOKE checks=", checks, " failures=", failures)
	quit(1 if failures > 0 else 0)
