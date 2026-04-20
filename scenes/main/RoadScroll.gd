extends Node2D

# Draws scrolling lane dashes so forward motion reads clearly (runner feel).

var _scroll: float = 0.0

func _process(delta: float) -> void:
	if not GameManager.is_game_running:
		return
	var cam: Camera2D = get_parent().get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		cam = get_viewport().get_camera_2d()
	if cam:
		global_position = Vector2(cam.global_position.x, 1192.0)
	_scroll = fposmod(_scroll + GameManager.speed * delta * 1.15, 130.0)
	queue_redraw()

func _draw() -> void:
	var left := -460.0
	var right := 460.0
	var x := left
	while x < right:
		var lx: float = x + _scroll
		var seg_end: float = minf(lx + 58.0, right + _scroll)
		if lx < right and seg_end > lx:
			draw_line(Vector2(lx, 0.0), Vector2(seg_end, 0.0), Color(0.93, 0.89, 0.78, 0.9), 4.0)
		x += 128.0
