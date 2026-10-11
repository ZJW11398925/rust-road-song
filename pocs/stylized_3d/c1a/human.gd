extends CharacterBody3D

@export var walking_speed: float = 3.0
@export var coat_color: Color = Color(0.76, 0.58, 0.30, 1.0)
var walk_phase: float = 0.0
var reach_amount: float = 0.0
@onready var visual: Node3D = $Visual
@onready var left_arm: Node3D = $Visual/LeftUpperArm
@onready var right_arm: Node3D = $Visual/RightUpperArm
@onready var left_leg: Node3D = $Visual/LeftLeg
@onready var right_leg: Node3D = $Visual/RightLeg

func _ready() -> void:
	var coat: StandardMaterial3D = StandardMaterial3D.new()
	coat.albedo_color = coat_color
	coat.roughness = 0.95
	$Visual/Torso.material_override = coat

func walk(direction: Vector3, delta: float, turn_body: bool = true) -> void:
	var flat: Vector3 = Vector3(direction.x, 0.0, direction.z).limit_length()
	velocity.x = flat.x * walking_speed
	velocity.z = flat.z * walking_speed
	velocity.y = -0.6 if is_on_floor() else velocity.y - 18.0 * delta
	move_and_slide()
	if flat.length_squared() > 0.001 and turn_body:
		face(flat, delta, 10.0)
	var moving: bool = Vector2(velocity.x, velocity.z).length() > 0.1
	if moving:
		walk_phase += delta * 7.0
	var swing: float = sin(walk_phase) * 0.27 if moving else 0.0
	left_leg.rotation.x = swing
	right_leg.rotation.x = -swing
	right_arm.rotation.x = swing * 0.5
	left_arm.rotation.x = lerpf(-swing * 0.5, PI / 2.0, reach_amount)

func face(direction: Vector3, delta: float, rate: float = 4.0) -> void:
	if direction.length_squared() > 0.001:
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(-direction.x, -direction.z), minf(delta * rate, 1.0))

func reset_pose() -> void:
	velocity = Vector3.ZERO
	walk_phase = 0.0
	reach_amount = 0.0
	visual.rotation = Vector3.ZERO
	left_arm.rotation = Vector3.ZERO
	right_arm.rotation = Vector3.ZERO
	left_leg.rotation = Vector3.ZERO
	right_leg.rotation = Vector3.ZERO
