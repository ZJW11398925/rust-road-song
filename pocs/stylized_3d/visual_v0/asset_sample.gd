extends Node3D

# A bounded imported-asset fixture. The original POC scene remains the default.
const HumanScript = preload("res://human.gd")
const HUMAN: PackedScene = preload("res://human.tscn")
const WOMAN: PackedScene = preload("res://third_party/makehuman/woman_sample.glb")
const ADULT: PackedScene = preload("res://third_party/makehuman/adult_sample.glb")
const COPY: Translation = preload("res://asset_sample_strings.tres")
var player: HumanScript
var camera: Camera3D
var held: Dictionary = {}
var skeletons: Array[Skeleton3D] = []
var people: Array[HumanScript] = []
var bind_rotations: Array[Dictionary] = []
var initial_position: Vector3 = Vector3(-0.8, 0, 1.0)

func _ready() -> void:
	TranslationServer.add_translation(COPY)
	TranslationServer.set_locale("zh_CN")
	var environment: WorldEnvironment = WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color(0.16, 0.19, 0.21)
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color(0.61, 0.66, 0.70)
	environment.environment.ambient_light_energy = 0.65
	add_child(environment)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -30, 0)
	sun.light_color = Color(1.0, 0.84, 0.67)
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	sun.shadow_opacity = 0.55
	add_child(sun)
	_box(Vector3(12, 0.2, 10), Vector3(0, -0.1, 0), Color(0.37, 0.38, 0.36), true)
	_box(Vector3(12, 3.2, 0.2), Vector3(0, 1.6, -4.5), Color(0.38, 0.42, 0.43), true)
	_box(Vector3(12, 0.22, 0.28), Vector3(0, 0.11, -4.25), Color(0.23, 0.26, 0.27), false)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 7.5
	camera.position = Vector3(6, 6.2, 8)
	add_child(camera)
	camera.look_at(Vector3(0, 0.8, 0))
	camera.current = true
	player = _person(ADULT, initial_position)
	var stationary: HumanScript = _person(WOMAN, Vector3(1.0, 0, -0.4))
	stationary.visual.rotation.y = PI - 0.3
	var canvas: CanvasLayer = CanvasLayer.new()
	add_child(canvas)
	var label: Label = Label.new()
	label.position = Vector2(22, 16)
	label.text = tr("ASSET_TITLE") + "\n" + tr("ASSET_HELP")
	label.add_theme_font_size_override("font_size", 20)
	canvas.add_child(label)
	print("ASSET_IMPORTED people=", people.size(), " bones=", skeletons[0].get_bone_count(), ",", skeletons[1].get_bone_count())

func _person(asset: PackedScene, origin: Vector3) -> HumanScript:
	var person: HumanScript = HUMAN.instantiate() as HumanScript
	add_child(person)
	person.position = origin
	person.visual.rotation.y = PI
	# Keep the proven collision/movement/facing owner; hide its proxy geometry.
	for item: Node in person.visual.find_children("*", "MeshInstance3D", true, false):
		(item as MeshInstance3D).visible = false
	var model: Node3D = asset.instantiate() as Node3D
	person.visual.add_child(model)
	model.rotation.y = PI
	var matches: Array[Node] = model.find_children("*", "Skeleton3D", true, false)
	assert(matches.size() == 1, "Imported sample must retain its original rig")
	skeletons.append(matches[0] as Skeleton3D)
	people.append(person)
	var pose: Dictionary = {}
	for bone: int in range(skeletons[-1].get_bone_count()):
		pose[skeletons[-1].get_bone_name(bone)] = skeletons[-1].get_bone_pose_rotation(bone)
	bind_rotations.append(pose)
	# Reuse imported cloth diffuse/UVs; remove polished surfaces and normal noise.
	for item: Node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh: MeshInstance3D = item as MeshInstance3D
		for surface: int in range(mesh.mesh.get_surface_count()):
			var original: Material = mesh.get_active_material(surface)
			if original is StandardMaterial3D:
				var material: StandardMaterial3D = original.duplicate() as StandardMaterial3D
				material.roughness = 0.95
				material.metallic = 0.0
				material.normal_enabled = false
				mesh.set_surface_override_material(surface, material)
	return person

func _box(size: Vector3, origin: Vector3, color: Color, solid: bool) -> void:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.position = origin
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.98
	mesh.material_override = material
	add_child(mesh)
	if solid:
		var body: StaticBody3D = StaticBody3D.new()
		body.collision_layer = 1
		body.position = origin
		var shape: CollisionShape3D = CollisionShape3D.new()
		var collision: BoxShape3D = BoxShape3D.new()
		collision.size = size
		shape.shape = collision
		body.add_child(shape)
		add_child(body)

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or event.is_echo():
		return
	var key: InputEventKey = event as InputEventKey
	if key.pressed and key.physical_keycode == KEY_ESCAPE:
		get_tree().quit()
	if key.pressed and key.physical_keycode == KEY_R:
		player.position = initial_position
		player.reset_pose()
		player.visual.rotation.y = PI
		held.clear()
	if key.physical_keycode in [KEY_W, KEY_A, KEY_S, KEY_D]:
		if key.pressed:
			held[key.physical_keycode] = true
		else:
			held.erase(key.physical_keycode)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		held.clear()

func _physics_process(delta: float) -> void:
	var screen_right: Vector3 = camera.global_basis.x
	screen_right.y = 0.0
	var screen_down: Vector3 = camera.global_basis.z
	screen_down.y = 0.0
	var direction: Vector3 = screen_right.normalized() * (float(held.has(KEY_D)) - float(held.has(KEY_A)))
	direction += screen_down.normalized() * (float(held.has(KEY_S)) - float(held.has(KEY_W)))
	player.walk(direction, delta)
	# Reuse the POC gait timing, adapting only four rotations to the imported rig.
	# This is a motion probe, not a finished walk cycle or narrative performance.
	var rotations: Dictionary = {"thigh_l": player.left_leg.rotation.x,
		"thigh_r": player.right_leg.rotation.x, "upperarm_l": player.left_arm.rotation.x,
		"upperarm_r": player.right_arm.rotation.x}
	for name: String in rotations:
		var bone: int = skeletons[0].find_bone(name)
		var local_axis: Vector3 = skeletons[0].get_bone_global_rest(bone).basis.inverse() * Vector3.RIGHT
		var bind: Quaternion = bind_rotations[0][name]
		skeletons[0].set_bone_pose_rotation(bone, bind * Quaternion(local_axis.normalized(), float(rotations[name])))
