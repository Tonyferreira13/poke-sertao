class_name Npc
extends Node2D

signal interacted(npc: Node)

const FACING_ROWS := {
	"down": 0,
	"up": 1,
	"left": 2,
	"right": 3,
}

var world: World
var cell := Vector2i.ZERO
var facing := "down"
var display_name := ""
var lines: PackedStringArray = []

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	sprite.hframes = 3
	sprite.vframes = 4
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_apply_frame()


func setup(
	world_ref: World,
	start_cell: Vector2i,
	start_facing: String,
	npc_name: String,
	npc_lines: PackedStringArray,
) -> void:
	world = world_ref
	cell = start_cell
	facing = start_facing if FACING_ROWS.has(start_facing) else "down"
	display_name = npc_name
	lines = npc_lines
	position = world.cell_to_world(cell)
	_apply_frame()


func interact(actor: Node) -> void:
	_face_towards(actor.cell)
	interacted.emit(self)


func _face_towards(target: Vector2i) -> void:
	var delta := target - cell
	if abs(delta.x) > abs(delta.y):
		facing = "right" if delta.x > 0 else "left"
	elif delta.y != 0:
		facing = "down" if delta.y > 0 else "up"
	_apply_frame()


func _apply_frame() -> void:
	var row: int = FACING_ROWS.get(facing, 0)
	sprite.frame = row * sprite.hframes
