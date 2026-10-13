# Phantom Camera v0.11.0.3 / MIT, see LICENSE.
# Runtime excerpt: phantom_camera_3d.gd FollowMode.FRAMED and _get_framed_side_offset.
# Adaptation: explicit Camera3D/target/usable rect and candidate shot offset.
# The caller supplies the existing bilateral shot instead of a fixed follow offset.
extends RefCounted

var viewport_position: Vector2 = Vector2.ZERO
var dead_zone_width: float = 0.44
var dead_zone_height: float = 0.50
var _follow_framed_offset: Vector3 = Vector3.ZERO
var _follow_target_output_position: Vector3 = Vector3.ZERO

func reset(position: Vector3, target: Vector3) -> void:
	_follow_framed_offset = position - target
	_follow_target_output_position = position

func step(camera: Camera3D, target: Vector3, usable_rect: Rect2, candidate_position: Vector3, obscured_contact: bool = false, protect_bottom: bool = false) -> Vector3:
	viewport_position = (camera.unproject_position(target) - usable_rect.position) / usable_rect.size
	var framed_offset: Vector2 = _get_framed_side_offset()
	# Scene adaptation: an obscured car-side contact also admits horizontal motion.
	if obscured_contact:
		framed_offset.x = 1.0 if candidate_position.x > camera.global_position.x else -1.0
	# Scene adaptation: the other actor must stay above the HUD, outside the central dead zone.
	if protect_bottom:
		framed_offset.y = -1.0
	if framed_offset != Vector2.ZERO:
		# Scene adaptation: admit the bilateral candidate only on breached axes.
		_follow_framed_offset = candidate_position - target
		var target_position: Vector3 = target + _follow_framed_offset
		var current_global_position: Vector3 = camera.global_position
		var current_offset: Vector3 = current_global_position - target
		# Upstream: update stored offset and lock non-breached axes.
		if framed_offset.x == 0:
			_follow_framed_offset.x = current_offset.x
		if framed_offset.y == 0:
			_follow_framed_offset.z = current_offset.z
		if framed_offset.x == 0:
			# Keep an already admitted transition; do not interrupt it on the other axis.
			target_position.x = _follow_target_output_position.x
		if framed_offset.y == 0:
			target_position.z = _follow_target_output_position.z
		_follow_target_output_position = target_position
	else:
		_follow_framed_offset = camera.global_position - target
	return _follow_target_output_position

func _get_framed_side_offset() -> Vector2:
	var frame_out_bounds: Vector2

	if viewport_position.x < 0.5 - dead_zone_width / 2:
		# Is outside left edge
		frame_out_bounds.x = -1

	if viewport_position.y < 0.5 - dead_zone_height / 2:
		# Is outside top edge
		frame_out_bounds.y = 1

	if viewport_position.x > 0.5 + dead_zone_width / 2:
		# Is outside right edge
		frame_out_bounds.x = 1

	if viewport_position.y > 0.5001 + dead_zone_height / 2:
		# Upstream epsilon handles zero-height boundary rounding.
		frame_out_bounds.y = -1

	return frame_out_bounds
