class_name FloatText
extends RichTextLabel

var lifetime : float = 3
var float_dir : Vector2 = Vector2(0,-1)
var float_speed : float = 0.5
var primed : bool = false


func _process(delta: float) -> void:
	if not primed:
		return

	lifetime -= delta
	global_position += float_dir * float_speed * delta

	if lifetime < 0:
		queue_free()


func prime_text(message : String, position : Vector2, radius : float = 0, time : float = 3, dir : Vector2 = Vector2(0,-1), speed : float = 10, color : Color = Color.WHITE, size : int = 16):
	text = message
	
	if radius > 0:
		global_position = Vector2(position.x+(randf_range(-radius,radius)), position.y+(randf_range(-radius,radius)))
	else:
		global_position = position
	
	lifetime = time

	float_dir = dir.normalized()

	float_speed = speed

	add_theme_color_override("default_color", color)

	add_theme_font_size_override("normal_font_size", size)

	primed = true

	return


