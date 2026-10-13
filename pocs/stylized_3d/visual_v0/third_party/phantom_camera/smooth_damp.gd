# 摘录 ramokz/phantom-camera v0.11.0.3，MIT，许可见同目录LICENSE。
# 上游 phantom_camera_3d.gd::_smooth_damp；只改缩进与 INF 为最大速度。
# 其余为当前V0的Vector3调用适配；不是完整Phantom Camera插件。
extends RefCounted

var velocity: Vector3 = Vector3.ZERO
var maximum_speed: float = INF

func reset() -> void:
	velocity = Vector3.ZERO

func step(current: Vector3, target: Vector3, damping_time: float, delta: float, speed_limit: float) -> Vector3:
	if delta <= 0.0:
		return current
	maximum_speed = speed_limit
	var output: Vector3 = current
	for axis: int in range(3):
		output[axis] = _smooth_damp(target[axis], current[axis], axis, velocity[axis], _set_velocity, damping_time, delta)
	return output

func _set_velocity(index: int, value: float) -> void:
	velocity[index] = value

func _smooth_damp(target_axis: float, self_axis: float, index: int, current_velocity: float, set_velocity: Callable, damping_time: float, delta: float) -> float:
	damping_time = maxf(0.0001, damping_time)
	var omega: float = 2 / damping_time
	var x: float = omega * delta
	var exponential: float = 1 / (1 + x + 0.48 * x * x + 0.235 * x * x * x)
	var diff: float = self_axis - target_axis
	var _target_axis: float = target_axis

	var max_change: float = maximum_speed * damping_time
	diff = clampf(diff, -max_change, max_change)
	target_axis = self_axis - diff

	var temp: float = (current_velocity + omega * diff) * delta
	set_velocity.call(index, (current_velocity - omega * temp) * exponential)
	var output: float = target_axis + (diff + temp) * exponential

	## To prevent overshooting
	if (_target_axis - self_axis > 0.0) == (output > _target_axis):
		output = _target_axis
		set_velocity.call(index, (output - _target_axis) / delta)

	return output
