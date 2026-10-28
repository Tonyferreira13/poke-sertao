class_name GridPlayer
extends Node2D

signal interaction_requested(target_cell: Vector2i)

const WALK_TIME := 0.18
const RUN_TIME := 0.10
const FACING_ROWS := {
	"down": 0,
	"up": 1,
	"left": 2,
	"right": 3,
}

var world: World
var cell := Vector2i.ZERO
var facing := "down"
var input_locked := false
var moving := false

var _walk_step := 0

@onready var sprite: Sprite2D = $Sprite
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	sprite.hframes = 4
	sprite.vframes = 4
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_apply_frame(0)


func setup(world_ref: World, start_cell: Vector2i, start_facing: String) -> void:
	world = world_ref
	cell = start_cell
	facing = start_facing if FACING_ROWS.has(start_facing) else "down"
	position = world.cell_to_world(cell)
	_apply_frame(0)


func _process(_delta: float) -> void:
	if input_locked or moving:
		return

	var direction := _read_direction()
	if direction == Vector2i.ZERO:
		return

	var new_facing := _direction_to_facing(direction)
	if new_facing != facing:
		facing = new_facing
		_apply_frame(0)

	var target := cell + direction
	if not world.is_walkable(target):
		return

	_start_move(target)


func _unhandled_input(event: InputEvent) -> void:
	if input_locked or moving:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		interaction_requested.emit(cell + _facing_vector())


func set_input_locked(value: bool) -> void:
	input_locked = value
	if input_locked and not moving:
		_apply_frame(0)


func _start_move(target: Vector2i) -> void:
	moving = true
	_walk_step = (_walk_step % 3) + 1
	_apply_frame(_walk_step)

	var duration := RUN_TIME if Input.is_action_pressed("run") else WALK_TIME
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "position", world.cell_to_world(target), duration)
	tween.finished.connect(_finish_move.bind(target))


func _finish_move(target: Vector2i) -> void:
	cell = target
	moving = false
	if not _movement_held():
		_apply_frame(0)


func _apply_frame(step: int) -> void:
	var row: int = FACING_ROWS.get(facing, 0)
	sprite.frame = row * sprite.hframes + step


func _read_direction() -> Vector2i:
	if Input.is_action_pressed("move_up"):
		return Vector2i.UP
	if Input.is_action_pressed("move_down"):
		return Vector2i.DOWN
	if Input.is_action_pressed("move_left"):
		return Vector2i.LEFT
	if Input.is_action_pressed("move_right"):
		return Vector2i.RIGHT
	return Vector2i.ZERO


func _movement_held() -> bool:
	return (
		Input.is_action_pressed("move_up")
		or Input.is_action_pressed("move_down")
		or Input.is_action_pressed("move_left")
		or Input.is_action_pressed("move_right")
	)


func _facing_vector() -> Vector2i:
	match facing:
		"up":
			return Vector2i.UP
		"left":
			return Vector2i.LEFT
		"right":
			return Vector2i.RIGHT
		_:
			return Vector2i.DOWN


func _direction_to_facing(direction: Vector2i) -> String:
	if direction == Vector2i.UP:
		return "up"
	if direction == Vector2i.DOWN:
		return "down"
	if direction == Vector2i.LEFT:
		return "left"
	return "right"
