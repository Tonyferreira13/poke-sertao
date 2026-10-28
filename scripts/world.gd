class_name World
extends Node2D

signal npc_interacted(npc: Node)

const TILE_SIZE := 128
const DEFAULT_MAP_PATH := "res://data/route.json"
const NPC_SCENE := preload("res://scenes/npc.tscn")

@export var map_path: String = DEFAULT_MAP_PATH
@export var start_cell := Vector2i(10, 11)
@export_enum("down", "up", "left", "right") var start_facing := "down"

var map_width := 0
var map_height := 0

var _map_data: Dictionary = {}
var _occupied: Dictionary = {}
var _entities: Node2D
var _map_rect := Rect2i()
var _logical_map_rect := Rect2i()

@onready var ground: TileMapLayer = $Ground
@onready var plants: TileMapLayer = get_node_or_null("Plants")


func _ready() -> void:
	_load_map()
	_read_painted_map()


func _load_map() -> void:
	var text := FileAccess.get_file_as_string(map_path)
	if text.is_empty():
		push_warning("Nao foi possivel ler %s; NPCs nao serao carregados." % map_path)
		return

	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Dados invalidos em %s; NPCs nao serao carregados." % map_path)
		return

	_map_data = parsed


func _read_painted_map() -> void:
	if ground.tile_set == null:
		push_error("World/Ground esta sem TileSet. Crie/atribua um TileSet no editor.")
	elif not ground.tile_set.has_custom_data_layer_by_name("solid"):
		push_warning("O TileSet nao tem a camada de dados 'solid'; todas as celulas serao caminhaveis.")

	_map_rect = ground.get_used_rect()
	_logical_map_rect = _map_rect
	map_width = _logical_map_rect.size.x
	map_height = _logical_map_rect.size.y

	if map_width == 0 or map_height == 0:
		push_error("Nenhum tile pintado em World/Ground. Pinte o mapa no editor.")


func spawn_npcs(container: Node2D) -> void:
	_entities = container
	for entry: Variant in _map_data.get("npcs", []):
		if typeof(entry) != TYPE_DICTIONARY:
			continue

		var npc := NPC_SCENE.instantiate()
		container.add_child(npc)

		var npc_cell := _read_cell(entry.get("cell", [0, 0]))
		var npc_facing := str(entry.get("facing", "down"))
		var npc_name := str(entry.get("name", ""))
		var npc_lines := PackedStringArray()
		for line: Variant in entry.get("lines", []):
			npc_lines.append(str(line))

		npc.setup(self, npc_cell, npc_facing, npc_name, npc_lines)
		_occupied[npc_cell] = npc
		npc.interacted.connect(_on_npc_interacted)


func interact_at(target_cell: Vector2i, actor: Node) -> bool:
	var npc: Variant = _occupied.get(target_cell)
	if npc == null:
		return false
	npc.interact(actor)
	return true


func is_walkable(target_cell: Vector2i) -> bool:
	if not in_bounds(target_cell):
		return false
	if _occupied.has(target_cell):
		return false

	var tile_data := ground.get_cell_tile_data(target_cell)
	if tile_data == null:
		return false
	if tile_data.get_custom_data("solid") == true:
		return false
	if plants != null:
		var plant_data := plants.get_cell_tile_data(target_cell)
		if plant_data != null and plant_data.get_custom_data("solid") == true:
			return false
	return true


func in_bounds(target_cell: Vector2i) -> bool:
	return _logical_map_rect.has_point(target_cell)


func cell_to_world(target_cell: Vector2i) -> Vector2:
	return Vector2(
		target_cell.x * TILE_SIZE + TILE_SIZE / 2.0,
		target_cell.y * TILE_SIZE + TILE_SIZE / 2.0,
	)


func get_pixel_size() -> Vector2i:
	return _logical_map_rect.size * TILE_SIZE


func get_world_rect() -> Rect2i:
	return Rect2i(_logical_map_rect.position * TILE_SIZE, _logical_map_rect.size * TILE_SIZE)


func _read_cell(value: Variant) -> Vector2i:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2i(int(value[0]), int(value[1]))
	return Vector2i.ZERO


func _on_npc_interacted(npc: Node) -> void:
	npc_interacted.emit(npc)
