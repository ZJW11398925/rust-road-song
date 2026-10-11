extends Node3D

const WALK_SPEED: float = 3.0
const DRIVE_SPEED: float = 3.2
const CAMERA_OFFSET: Vector3 = Vector3(10.0, 13.0, 16.0)
var person: CharacterBody3D
var tank: CharacterBody3D
var tank_collision: KinematicCollision3D = null
var door: StaticBody3D
var camera: Camera3D
var status: Label
var hint: Label
var message: Label
var driving: bool = false
var door_open: bool = false
var exited: bool = false
var profile: int = 1
var speed: float = 0.0
var feedback_key: String = "START"
var feedback_time: float = 4.0
var input_enabled: bool = true
var held: Dictionary = {}

func _ready() -> void:
	var copy: Translation = load("res://strings.tres") as Translation
	TranslationServer.add_translation(copy)
	TranslationServer.set_locale("zh_CN")
	_install_inputs()
	_build_space()
	reset_scene(1)

func _install_inputs() -> void:
	var keys: Dictionary = {"forward": KEY_W, "back": KEY_S, "left": KEY_A, "right": KEY_D, "interact": KEY_E, "reset": KEY_R, "profile_one": KEY_1, "profile_two": KEY_2, "quit": KEY_ESCAPE}
	for action: String in keys:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var event: InputEventKey = InputEventKey.new()
		event.physical_keycode = keys[action]
		InputMap.action_add_event(action, event)

func _material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	return material

func _box(parent: Node3D, size: Vector3, center: Vector3, color: Color, solid: bool = true) -> void:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var shape: BoxMesh = BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.material_override = _material(color)
	mesh.position = center
	parent.add_child(mesh)
	if solid:
		var collision: CollisionShape3D = CollisionShape3D.new()
		var box: BoxShape3D = BoxShape3D.new()
		box.size = size
		collision.shape = box
		collision.position = center
		parent.add_child(collision)

func _wall(node_name: String, size: Vector3, center: Vector3, color: Color) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = node_name
	add_child(body)
	_box(body, size, center, color)
	return body

func _build_space() -> void:
	var environment: WorldEnvironment = WorldEnvironment.new()
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.08, 0.10, 0.12)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.8, 0.84, 0.9)
	env.ambient_light_energy = 0.7
	environment.environment = env
	add_child(environment)
	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55.0, -25.0, 0.0)
	light.light_energy = 1.3
	add_child(light)
	_wall("Floor", Vector3(24.0, 0.4, 38.0), Vector3(0.0, -0.2, -5.0), Color(0.28, 0.31, 0.34))
	_wall("LeftWall", Vector3(0.5, 3.4, 20.0), Vector3(-10.0, 1.7, 0.0), Color(0.36, 0.38, 0.40))
	_wall("RightWall", Vector3(0.5, 3.4, 20.0), Vector3(10.0, 1.7, 0.0), Color(0.36, 0.38, 0.40))
	_wall("BackWall", Vector3(20.0, 0.65, 0.5), Vector3(0.0, 0.325, 10.0), Color(0.36, 0.38, 0.40))
	_wall("ExitLeft", Vector3(7.6, 3.4, 0.5), Vector3(-6.2, 1.7, -10.0), Color(0.36, 0.38, 0.40))
	_wall("ExitRight", Vector3(7.6, 3.4, 0.5), Vector3(6.2, 1.7, -10.0), Color(0.36, 0.38, 0.40))
	door = _wall("Door", Vector3(4.8, 3.4, 0.4), Vector3(0.0, 1.7, -10.0), Color(0.47, 0.38, 0.25))
	tank = CharacterBody3D.new()
	tank.name = "Tank"
	add_child(tank)
	_box(tank, Vector3(3.8, 1.6, 5.8), Vector3(0.0, 0.9, 0.0), Color(0.42, 0.47, 0.38))
	_box(tank, Vector3(2.1, 0.9, 2.5), Vector3(0.0, 2.1, -0.5), Color(0.48, 0.51, 0.40), false)
	_box(tank, Vector3(0.3, 0.3, 2.6), Vector3(0.0, 2.1, -2.4), Color(0.36, 0.4, 0.31), false)
	for side: float in [-1.0, 1.0]:
		_box(tank, Vector3(0.45, 0.9, 5.7), Vector3(side * 1.9, 0.5, 0.0), Color(0.17, 0.19, 0.19), false)
	person = CharacterBody3D.new()
	person.name = "Person"
	add_child(person)
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.75
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = capsule
	collision.position.y = 0.875
	person.add_child(collision)
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var capsule_mesh: CapsuleMesh = CapsuleMesh.new()
	capsule_mesh.radius = 0.35
	capsule_mesh.height = 1.75
	mesh.mesh = capsule_mesh
	mesh.position.y = 0.875
	mesh.material_override = _material(Color(0.84, 0.62, 0.28))
	person.add_child(mesh)
	var reference: Node3D = Node3D.new()
	reference.name = "InspectionReference"
	reference.position = Vector3(3.2, 0.02, 0.5)
	add_child(reference)
	_box(reference, Vector3(0.85, 0.025, 0.85), Vector3.ZERO, Color(0.38, 0.40, 0.41), false)
	camera = Camera3D.new()
	camera.name = "Camera3D"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 23.0
	camera.current = true
	add_child(camera)
	var ui: CanvasLayer = CanvasLayer.new()
	ui.name = "HUD"
	add_child(ui)
	var panel: ColorRect = ColorRect.new()
	panel.color = Color(0.04, 0.05, 0.07, 0.9)
	panel.position = Vector2(14.0, 638.0)
	panel.size = Vector2(1250.0, 150.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(panel)
	var title: Label = _label(ui, Vector2(28.0, 644.0), 24)
	title.text = tr("TITLE")
	var help: Label = _label(ui, Vector2(28.0, 676.0), 19)
	help.text = tr("HELP")
	status = _label(ui, Vector2(28.0, 704.0), 19)
	hint = _label(ui, Vector2(28.0, 730.0), 19)
	message = _label(ui, Vector2(28.0, 756.0), 19)
	message.modulate = Color(1.0, 0.82, 0.47)

func _label(parent: Node, pos: Vector2, font_size: int) -> Label:
	var label: Label = Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label

func reset_scene(next_profile: int = 1) -> void:
	_clear_input()
	profile = next_profile
	driving = false
	door_open = false
	exited = false
	speed = 0.0
	person.position = Vector3(-4.0, 0.05, 6.0)
	person.velocity = Vector3.ZERO
	person.visible = true
	person.collision_layer = 1
	person.collision_mask = 1
	tank.position = Vector3(0.0, 0.05, 1.0)
	tank.rotation = Vector3.ZERO
	tank.velocity = Vector3.ZERO
	tank_collision = null
	door.position = Vector3.ZERO
	door.visible = true
	_feedback("START", 4.0)
	_update_camera()

func _clear_input() -> void:
	held.clear()
	if is_instance_valid(person):
		person.velocity = Vector3.ZERO
	if is_instance_valid(tank):
		tank.velocity = Vector3.ZERO
	speed = 0.0

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		input_enabled = false
		_clear_input()
		_feedback("FOCUS", 4.0)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		input_enabled = true

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key: InputEventKey = event as InputEventKey
	if key.echo:
		return
	if not input_enabled:
		return
	for action: String in ["forward", "back", "left", "right"]:
		if event.is_action(action):
			if not key.pressed:
				held.erase(action)
			else:
				held[action] = true
	if not key.pressed:
		return
	if event.is_action_pressed("quit"):
		get_tree().quit()
	elif event.is_action_pressed("reset"):
		reset_scene(profile)
	elif event.is_action_pressed("profile_one"):
		reset_scene(1)
	elif event.is_action_pressed("profile_two"):
		reset_scene(2)
	elif event.is_action_pressed("interact"):
		_interact()

func _axis(negative: String, positive: String) -> float:
	return float(held.has(positive)) - float(held.has(negative))

func _near_door() -> bool:
	var pos: Vector3 = tank.position if driving else person.position
	return absf(pos.z + 10.0) < 5.2 and absf(pos.x) < 3.0

func _near_tank() -> bool:
	var pos: Vector3 = person.position - tank.position
	return minf(pos.distance_to(Vector3(-2.8, 0.0, 0.0)), pos.distance_to(Vector3(2.8, 0.0, 0.0))) < 1.7

func _interact() -> void:
	if _near_door():
		if not door_open:
			door_open = true
			door.position.y = 4.0
			door.visible = false
		_feedback("OPEN")
	elif not driving and _near_tank():
		driving = true
		person.visible = false
		person.collision_layer = 0
		person.collision_mask = 0
		_clear_input()
	elif driving:
		_feedback("DRIVE_NEAR")
	else:
		_feedback("FAR")

func _physics_process(delta: float) -> void:
	feedback_time = maxf(0.0, feedback_time - delta)
	var body: CharacterBody3D = tank if driving else person
	if not driving:
		var forward: Vector3 = -camera.global_basis.z
		forward.y = 0.0
		forward = forward.normalized()
		var right: Vector3 = camera.global_basis.x
		right.y = 0.0
		right = right.normalized()
		var motion: Vector3 = right * _axis("left", "right") + forward * _axis("back", "forward")
		body.velocity = motion.limit_length() * WALK_SPEED
	else:
		var target_speed: float = 0.0 if exited else _axis("back", "forward") * DRIVE_SPEED
		if profile == 1:
			speed = target_speed
		elif target_speed == 0.0:
			speed = 0.0
		else:
			if speed * target_speed < 0.0:
				speed = 0.0
			speed = move_toward(speed, target_speed, 2.6 * delta)
		var turn: float = 0.0 if exited else _axis("left", "right")
		if absf(speed) > 0.05:
			tank.rotation.y -= turn * (1.0 if profile == 1 else 0.48) * delta * signf(speed)
		body.velocity = -tank.global_basis.z * speed
	body.velocity.y = -0.4
	if driving:
		# Keep floor support independent: a horizontal obstacle must not project travel sideways.
		tank.move_and_collide(Vector3(0.0, body.velocity.y * delta, 0.0))
		tank_collision = tank.move_and_collide(Vector3(body.velocity.x, 0.0, body.velocity.z) * delta)
		if tank_collision != null:
			speed = 0.0
			tank.velocity = Vector3.ZERO
			_feedback("COLLISION", 0.3)
	else:
		body.move_and_slide()
		if body.get_slide_collision_count() > 0:
			for index: int in body.get_slide_collision_count():
				if absf(body.get_slide_collision(index).get_normal().y) < 0.6:
					_feedback("COLLISION", 0.3)
	if driving and tank.position.z < -14.0 and not exited:
		exited = true
		_clear_input()
		_feedback("EXITED", 60.0)
	_update_camera()
	status.text = tr("DRIVE" if driving else "WALK") + " · " + tr("P1" if profile == 1 else "P2")
	hint.text = tr("OPEN" if door_open else "DOOR_HINT") if _near_door() else (tr("BOARD_HINT") if not driving and _near_tank() else "")
	message.text = tr(feedback_key) if feedback_time > 0.0 else ""

func _update_camera() -> void:
	var target: Vector3 = tank.position if driving else person.position
	target.x = clampf(target.x * 0.35, -2.0, 2.0)
	target.z = clampf(target.z * 0.5 - 3.0, -9.0, 0.0)
	target.y = 0.5
	camera.position = target + CAMERA_OFFSET
	camera.look_at(target, Vector3.UP)

func _feedback(key: String, duration: float = 2.5) -> void:
	feedback_key = key
	feedback_time = duration
