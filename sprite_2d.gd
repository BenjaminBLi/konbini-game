extends Sprite2D


func _init():
	print("Hello, world!")

func _process(delta):
	var speed = 400
	var angular_speed = PI
	var velocity = Vector2.UP.rotated(rotation) * speed
	rotation += angular_speed * delta
	position += velocity * delta
