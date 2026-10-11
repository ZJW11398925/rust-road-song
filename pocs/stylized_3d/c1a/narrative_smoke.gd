extends SceneTree

const MeetingScript = preload("res://first_meeting.gd")
const HumanScript = preload("res://human.gd")

var scene: MeetingScript
var player: HumanScript
var failures: int = 0
var checks: int = 0
var capture_dir: String = ""
var capture_index: int = 0
var frame_counter: int = 0
var door_open_frame: int = -1

func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			capture_dir = argument.trim_prefix("--capture-dir=")
	if capture_dir != "":
		var directory_error: Error = DirAccess.make_dir_recursive_absolute(capture_dir)
		check(directory_error == OK, "渲染采样目录创建")
		if directory_error != OK:
			capture_dir = ""
	call_deferred("_run")

func check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", label)
	else:
		failures += 1
		print("FAIL: ", label)

func key(code: Key, pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func frames(count: int) -> void:
	for frame_index: int in range(count):
		await physics_frame
		await process_frame
		frame_counter += 1
		if is_instance_valid(scene) and scene.door_open and door_open_frame < 0:
			door_open_frame = Engine.get_physics_frames()
		if capture_dir != "" and frame_counter % 12 == 0:
			await capture()

func capture() -> void:
	await RenderingServer.frame_post_draw
	var shot: Image = root.get_texture().get_image()
	var error: Error = shot.save_png(capture_dir.path_join("frame_%05d.png" % capture_index))
	check(error == OK, "渲染PNG采样写入")
	if error != OK:
		capture_dir = ""
	capture_index += 1

func tap(code: Key) -> void:
	key(code, true)
	await frames(2)
	key(code, false)
	await frames(2)

func walk(code: Key, count: int) -> void:
	key(code, true)
	await frames(count)
	key(code, false)
	await frames(3)

func walk_to_x(target_x: float) -> void:
	var code: Key = KEY_D if player.position.x < target_x else KEY_A
	key(code, true)
	for step: int in range(100):
		if (code == KEY_D and player.position.x >= target_x) or (code == KEY_A and player.position.x <= target_x):
			break
		await frames(1)
	key(code, false)
	await frames(3)

func entry_clear(ray_origin: Vector3, target: Vector3) -> bool:
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, target, 1)
	var hit: Dictionary = scene.get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or not [scene.get_node("Door"), scene.get_node("EntryLeft"), scene.get_node("EntryRight")].has(hit["collider"])

func player_hand_at_shell() -> bool:
	var hand: Marker3D = player.get_node("Visual/LeftUpperArm/LeftLowerArm/Hand") as Marker3D
	var body: MeshInstance3D = scene.get_node("Mary/Body") as MeshInstance3D
	var box: AABB = body.mesh.get_aabb()
	var local: Vector3 = body.to_local(hand.global_position)
	var side_distance: float = minf(absf(local.x - box.end.x), absf(local.x - box.position.x))
	print("PLAYER_CONTACT: hand=", hand.global_position, " body_local=", local, " side_face_distance=", side_distance, " reach=", player.reach_amount, " clock=", scene.touch_clock)
	return side_distance <= 0.14 and local.y >= box.position.y and local.y <= box.end.y and local.z >= box.position.z and local.z <= box.end.z

func view_clear(target: Vector3, label: String) -> bool:
	var camera: Camera3D = scene.get_node("Camera3D") as Camera3D
	var clear: bool = true
	# Render geometry, including the upper body without its own physics collider.
	for node_path: String in ["Mary/Body", "Mary/UpperBody", "EntryLeft/Mesh", "EntryRight/Mesh", "LeftWall/Mesh", "RightWall/Mesh", "VestibuleLeft/Mesh", "VestibuleRight/Mesh", "Door/Mesh"]:
		var mesh: MeshInstance3D = scene.get_node(node_path) as MeshInstance3D
		var intersection: Variant = mesh.mesh.get_aabb().intersects_segment(mesh.to_local(camera.global_position), mesh.to_local(target))
		if intersection != null:
			clear = false
			print("VIEW_BLOCKED: ", label, " by=", node_path, " camera=", camera.global_position, " target=", target)
	var size: Vector2 = camera.get_viewport().get_visible_rect().size
	var on_screen: bool = not camera.is_position_behind(target) and Rect2(Vector2(16.0, 16.0), Vector2(size.x - 32.0, size.y * 0.67 - 16.0)).has_point(camera.unproject_position(target))
	print("VIEW_SAMPLE: ", label, " screen=", camera.unproject_position(target), " clear=", clear, " above_hud=", on_screen)
	return clear and on_screen

func reset() -> void:
	door_open_frame = -1
	await tap(KEY_R)
	await frames(4)

func mother_snapshot(label: String) -> void:
	var mother: HumanScript = scene.get_node("Mother") as HumanScript
	var hand: Marker3D = mother.get_node("Visual/LeftUpperArm/LeftLowerArm/Hand") as Marker3D
	var contact: Marker3D = scene.get_node("Mary/Panel/Contact") as Marker3D
	var elapsed: float = float(Engine.get_physics_frames() - door_open_frame) / float(Engine.physics_ticks_per_second)
	print("MOTHER_STATE: ", label, " from_open_s=", elapsed, " stage=", scene.mother_stage, " clock=", scene.mother_clock, " reach=", mother.reach_amount, " hand_distance=", hand.global_position.distance_to(contact.global_position))

func wait_for_mother(label: String) -> bool:
	mother_snapshot(label + " begin")
	# Bound the whole opening-to-contact journey, not an unbounded state wait.
	# 10.58m / 1.25m/s + door 1.14s + pause .55s + turn .8s + reach .625s is about 11.58s.
	var deadline: int = door_open_frame + int(ceil(12.0 * float(Engine.physics_ticks_per_second)))
	while scene.mother_stage < 4 and Engine.get_physics_frames() < deadline:
		await frames(1)
	mother_snapshot(label + " end")
	return scene.mother_stage == 4

func open_and_enter() -> void:
	await walk(KEY_W, 25)
	await tap(KEY_E)
	await frames(95)
	await walk(KEY_W, 110)

func _run() -> void:
	var main_path: String = str(ProjectSettings.get_setting("application/run/main_scene"))
	check(main_path == "res://first_meeting.tscn", "正式main scene入口")
	change_scene_to_file(main_path)
	await frames(8)
	scene = current_scene as MeetingScript
	player = scene.get_node("Player") as HumanScript
	check(scene.is_inside_tree() and player.is_on_floor(), "正式SceneTree生命周期与落地")
	check(scene.get_node("Mother").is_visible_in_tree() and scene.get_node("Mary").is_visible_in_tree(), "母亲/玛丽实际同场，未spawn")
	check(not scene.door_open and not scene.first_reveal, "门前初态未首见")
	var ray_start: Vector3 = scene.get_node("Camera3D").global_position
	var ray_end: Vector3 = scene.get_node("Mary/Body").global_position
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_start, ray_end, 1)
	var hit: Dictionary = scene.get_world_3d().direct_space_state.intersect_ray(query)
	check(not hit.is_empty() and hit["collider"] == scene.get_node("Door"), "实体门实际遮挡初始镜头到车体")
	await tap(KEY_E)
	check(scene.feedback_key == "FAR" and not scene.get_node("HUD/Feedback").text.is_empty(), "远处E给玩家可见反馈")
	var initial: Vector3 = player.position
	await walk(KEY_W, 20)
	check(initial.z - player.position.z > 0.55, "真实W键推动人物水平运动")
	if initial.z - player.position.z <= 0.55:
		print("RESULT: ", checks, " checks / ", failures, " failures; movement RED stopped after semantic failure")
		quit(1)
		return
	await walk(KEY_W, 65)
	check(player.position.z > 4.35, "闭门实体阻止穿越")
	await tap(KEY_E)
	await frames(12)
	check(scene.door_progress > 0.0 and scene.door_progress < 1.0 and not scene.first_reveal, "实体门逐渐打开而非瞬间删车/门")
	var opening_position: Vector3 = player.position
	await walk(KEY_D, 5)
	check(player.position.x - opening_position.x > 0.15, "开门显露期间保留玩家控制")
	await walk(KEY_A, 5)
	await frames(95)
	check(scene.door_open and scene.first_reveal, "就近E打开门并首见，非检查前置")
	check(scene.get_node("Door").position.y > 4.0, "打开后的实体门离开入口")
	await tap(KEY_E)
	check(scene.door_open, "重复E不关闭门")
	await walk(KEY_W, 90)
	check(player.position.z < 2.0, "真实输入从门外进入")
	await walk_to_x(3.1)
	await walk(KEY_W, 54)
	check(player.position.x >= 3.0 and player.position.z < 0.0, "自由先到右边，不等母亲动作")
	await tap(KEY_E)
	check(scene.touch_clock > 0.0 and not scene.player_touched, "远侧E仅启动手势，不以就近半径判完成")
	await frames(50)
	check(not scene.player_touched and scene.feedback_key == "TOUCH_MISS" and not scene.get_node("HUD/Feedback").text.is_empty(), "远侧手够不到车壳，不成功且有可见反馈")
	await walk_to_x(2.28)
	await tap(KEY_E)
	check(scene.touch_clock > 0.0 and not scene.player_touched, "走近后E先启动新手势")
	await frames(25)
	check(scene.player_touched and scene.touch_contacted and player_hand_at_shell(), "玩家手实际触壳后才完成触碰")
	await frames(25)
	var first_mother_complete: bool = await wait_for_mother("first right-side/untended")
	var mother: HumanScript = scene.get_node("Mother") as HumanScript
	check(first_mother_complete, "未看细节不阻塞母亲走/停/转身/搭扶（从开门起12秒有界）")
	check(mother.global_position.distance_to(Vector3(-2.35, 0.0, -0.68)) < 0.18, "母亲在车侧实际停下")
	check((-mother.get_node("Visual").global_basis.z).dot(Vector3.RIGHT) > 0.98, "母亲转向车而非面向玩家")
	var hand: Marker3D = mother.get_node("Visual/LeftUpperArm/LeftLowerArm/Hand") as Marker3D
	var contact: Marker3D = scene.get_node("Mary/Panel/Contact") as Marker3D
	check(hand.global_position.distance_to(contact.global_position) < 0.14, "母亲手与侧板真实空间接触关系")
	var camera: Camera3D = scene.get_node("Camera3D") as Camera3D
	check(entry_clear(camera.global_position, hand.global_position), "开门后车内动作镜头到母亲手不被入口墙或门遮挡")
	check(entry_clear(camera.global_position, scene.get_node("Mary/Body").global_position), "开门后车内动作镜头到玛丽不被入口墙或门遮挡")
	check(entry_clear(MeetingScript.FIRST_CAMERA, hand.global_position), "首见构图到搭扶手不被入口墙或门遮挡")
	check(entry_clear(MeetingScript.FIRST_CAMERA, scene.get_node("Mary/Body").global_position), "首见构图到玛丽不被入口墙或门遮挡")
	var mother_head: Vector3 = mother.global_position + Vector3(0.0, 1.65, 0.0)
	var head_screen: Vector2 = camera.unproject_position(mother_head)
	var hand_screen: Vector2 = camera.unproject_position(hand.global_position)
	# Projection uses the stretched viewport, not the headless 64x64 window surface.
	var visible_size: Vector2 = camera.get_viewport().get_visible_rect().size
	print("CAMERA_SCREEN: head=", head_screen, " hand=", hand_screen, " viewport=", visible_size, " window_surface=", root.size, " camera=", camera.global_position)
	check(not camera.is_position_behind(mother_head) and Rect2(Vector2(16.0, 16.0), Vector2(visible_size.x - 32.0, visible_size.y * 0.67 - 16.0)).has_point(head_screen), "母亲头部在当前可见画面内，非面部特写")
	check(not camera.is_position_behind(hand.global_position) and Rect2(Vector2(16.0, 16.0), Vector2(visible_size.x - 32.0, visible_size.y * 0.67 - 16.0)).has_point(hand_screen), "搭手接触在画面内且不落入底部操作面板")
	# The contact pose is held in the same real-input journey for inspectable frames.
	await frames(90)
	var mother_before: Vector3 = mother.position
	await walk(KEY_S, 85)
	var away: Vector3 = player.position
	await walk(KEY_W, 85)
	check(away.z - player.position.z > 2.0 and mother.position.distance_to(mother_before) < 0.02, "触碰后走开并回返，控制不锁")
	await reset()
	check(not scene.door_open and not scene.first_reveal and not scene.player_touched and scene.mother_stage == 0, "R恢复完整实验初态")
	check(player.position.distance_to(Vector3(-0.75, 0.0, 6.8)) < 0.08, "R恢复门外位置")
	await open_and_enter()
	await walk_to_x(2.28)
	await walk(KEY_W, 50)
	await tap(KEY_E)
	await frames(50)
	check(scene.player_touched and scene.touch_contacted and scene.mother_stage < 4, "真实手触壳的先触碰路径无需等待母亲动作完成")
	await walk(KEY_S, 95)
	check(await wait_for_mother("touch-first then leave"), "走开/未看母亲仍完成，非隐藏解锁（12秒有界）")
	await walk(KEY_W, 95)
	check(scene.touch_clock == 0.0 and player.reach_amount < 0.05, "回返前旧手势已结束")
	await tap(KEY_E)
	check(scene.touch_clock > 0.0 and not scene.touch_contacted and scene.feedback_key == "REACH", "回返E启动本次新手势，非sticky已触碰状态")
	await frames(25)
	check(scene.touch_contacted and scene.feedback_key == "TOUCH" and player_hand_at_shell(), "回返手重新抬起并实际触壳")
	await frames(25)
	await reset()
	await open_and_enter()
	await walk_to_x(2.28)
	await walk(KEY_W, 50)
	await tap(KEY_E)
	var reach_start: Vector3 = player.position
	await walk(KEY_D, 22)
	await frames(35)
	check(player.position.x - reach_start.x > 0.8, "伸手期间WASD继续响应且朝车姿态不锁位")
	check(not scene.player_touched and scene.feedback_key == "TOUCH_MISS" and not scene.get_node("HUD/Feedback").text.is_empty(), "触壳前移开导致失败，且有可见反馈")
	await reset()
	await open_and_enter()
	await walk(KEY_A, 76)
	await walk(KEY_W, 65)
	check(player.position.x < -2.0 and player.position.z < 0.0, "真实输入也可自由接近车身左侧")
	await walk(KEY_S, 95)
	check(await wait_for_mother("left-side then leave"), "先左侧再走开不阻塞母亲动作（12秒有界）")
	await walk(KEY_W, 95)
	var forward_x: float = player.position.x
	await walk(KEY_W, 8)
	check(absf(player.position.x - forward_x) < 0.03, "构图变化不重映射W输入方向")
	key(KEY_W, true)
	await frames(8)
	scene.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	var focus_position: Vector3 = player.position
	await frames(20)
	check(player.position.distance_to(focus_position) < 0.03 and scene.held.is_empty(), "失焦通知清held且停止，不代表OS焦点已验")
	scene.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	await frames(15)
	check(player.position.distance_to(focus_position) < 0.03, "恢复不消费旧按键")
	key(KEY_W, false)
	await walk(KEY_S, 12)
	check(player.position.z - focus_position.z > 0.25, "恢复后新真实键响应")
	key(KEY_W, true)
	await frames(4)
	await reset()
	key(KEY_W, false)
	var reset_position: Vector3 = player.position
	await frames(15)
	check(player.position.distance_to(reset_position) < 0.03 and scene.held.is_empty(), "重置清输入且不漏旧键")
	# Same real keyboard journey: a still player must not leave mother's walk unframed.
	await reset()
	await walk(KEY_W, 25)
	await tap(KEY_E)
	await frames(150)
	var still_position: Vector3 = player.position
	var walking_camera: Vector3 = camera.global_position
	check(await wait_for_mother("camera stationary observer"), "门口静止观察者不阻塞母亲动作")
	await frames(120)
	print("CAMERA_MOTHER: from=", walking_camera, " to=", camera.global_position, " player=", player.position)
	check(player.position.distance_to(still_position) < 0.02 and camera.global_position.distance_to(walking_camera) > 0.6, "玩家静止时构图仍随母亲走向车身，不靠玩家区域触发")
	# Enter through the open doorway before moving laterally behind its wall.
	await walk(KEY_W, 55)
	await walk_to_x(3.1)
	await frames(120)
	var boundary_before: Vector3 = camera.global_position
	var before_z: float = player.position.z
	await walk(KEY_W, 12)
	await frames(120)
	print("CAMERA_BOUNDARY: z=", before_z, " -> ", player.position.z, " distance=", camera.global_position.distance_to(boundary_before))
	check(before_z > 2.5 and player.position.z < 2.5, "真实W路线跨过旧切镜边界")
	check(camera.global_position.distance_to(boundary_before) < 1.0, "跨旧边界只作连续小幅构图调整，没有区域切镜")
	var boundary_inside: Vector3 = camera.global_position
	await walk(KEY_S, 12)
	await frames(120)
	check(camera.global_position.distance_to(boundary_inside) < 1.0, "反复回跨旧边界不反复切换视角")
	await reset()
	check(camera.global_position.distance_to(MeetingScript.FIRST_CAMERA) < 0.001, "镜头重置回实际门前构图")
	# Reproduce the second human playtest through the same real keyboard path.
	await open_and_enter()
	await walk_to_x(3.1)
	await frames(120)
	check(view_clear(player.global_position + Vector3(0.0, 0.9, 0.0), "right entry"), "右侧入口玩家躯干不被前景墙或车体遮挡且在操作面板上方")
	await walk(KEY_S, 20)
	await walk_to_x(5.1)
	await frames(120)
	check(view_clear(player.global_position + Vector3(0.0, 0.9, 0.0), "right entry wall"), "入口墙旁横向走动时玩家躯干仍可见")
	await walk(KEY_S, 45)
	check(player.position.z < 3.7, "入口低墙的可见几何与碰撞匹配，不能穿墙离场")
	await walk(KEY_W, 25)
	await walk_to_x(3.1)
	await walk_to_x(2.28)
	await walk(KEY_W, 50)
	await frames(120)
	check(view_clear(player.global_position + Vector3(0.0, 0.9, 0.0), "right body"), "右侧靠车玩家躯干不被车体或墙遮挡")
	await tap(KEY_E)
	await frames(25)
	check(scene.touch_contacted and player_hand_at_shell(), "右侧原有实际触壳路径保留")
	await reset()
	await open_and_enter()
	await walk_to_x(-2.28)
	await walk(KEY_W, 35)
	await frames(120)
	check(view_clear(player.global_position + Vector3(0.0, 0.9, 0.0), "left body"), "左侧靠车玩家躯干不被车体或墙遮挡")
	await tap(KEY_E)
	await frames(25)
	print("LEFT_TOUCH: player=", player.position, " feedback=", scene.feedback_key, " touched=", scene.player_touched)
	check(scene.touch_contacted and scene.player_touched and player_hand_at_shell(), "左侧同一合理触碰也需实际手触壳，不强制右侧")
	await frames(30)
	var left_departure: Vector3 = player.position
	# Mother can physically occupy this same aisle; sidestep her before leaving.
	await walk(KEY_A, 22)
	await walk(KEY_S, 55)
	print("LEFT_DEPARTURE: from=", left_departure, " to=", player.position, " mother=", mother.position)
	check(player.position.z - left_departure.z > 2.5 and left_departure.x - player.position.x > 0.8 and not scene.held.has("left") and not scene.held.has("back") and scene.player_touched, "左侧触碰后绕过母亲实际自由离开且不残留按键")
	await reset()
	check(not scene.player_touched and not scene.touch_contacted, "双侧触碰后的重置清状态")
	print("RESULT: ", checks, " checks / ", failures, " failures")
	quit(0 if failures == 0 else 1)
