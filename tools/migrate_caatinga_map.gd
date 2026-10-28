extends SceneTree

const SCENE_PATH := "res://scenes/main.tscn"
const MAP_SIZE := Vector2i(32, 22)
const START := Vector2i(10, 11)
const NPC_CELL := Vector2i(14, 7)


func _initialize() -> void:
	call_deferred("_migrate")


func _migrate() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	var main := packed.instantiate()
	root.add_child(main)
	await process_frame
	var world: Node2D = main.get_node("World")
	var ground: TileMapLayer = world.get_node("Ground")
	var paths := _ensure_layer(world, main, "Paths", "res://assets/tilesets/caatinga_paths_128.tres")
	var plants := _ensure_layer(world, main, "Plants", "res://assets/tilesets/caatinga_plants_128.tres")
	ground.tile_set = load("res://assets/tilesets/caatinga_128.tres")
	ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ground.clear()
	paths.clear()
	plants.clear()
	var path_cells := _make_path()

	for y in range(MAP_SIZE.y):
		for x in range(MAP_SIZE.x):
			var cell := Vector2i(x, y)
			if _is_boundary(cell):
				ground.set_cell(cell, 0, Vector2i((x * 3 + y * 5) % 8, 7))
				continue
			var variant := (x * 3 + y * 5) % 8
			ground.set_cell(cell, 0, Vector2i(variant, 0))
			if x >= 24 and x <= 28 and y >= 3 and y <= 6:
				ground.set_cell(cell, 0, Vector2i((x + y) % 8, 2))
			if path_cells.has(cell):
				paths.set_cell(cell, 0, _path_coords(cell, path_cells))
			elif _plant_spot(cell):
				var sprite_id := (x * 5 + y * 3) % 8
				plants.set_cell(cell, 0, Vector2i(sprite_id % 4, floori(float(sprite_id) / 4.0)))

	var error := packed.pack(main)
	if error == OK:
		error = ResourceSaver.save(packed, SCENE_PATH)
	print("Mapa Caatinga pronto: grade %dx%d, %d caminhos conectados, %d plantas e borda de pedra." % [MAP_SIZE.x, MAP_SIZE.y, paths.get_used_cells().size(), plants.get_used_cells().size()])
	print("Cena salva: %s" % error_string(error))
	quit(0 if error == OK else 1)


func _make_path() -> Dictionary:
	var cells: Dictionary = {}
	for x in range(4, 28):
		cells[Vector2i(x, 11)] = true
	for y in range(4, 19):
		cells[Vector2i(15, y)] = true
	for y in range(7, 12):
		cells[Vector2i(14, y)] = true
	for x in range(8, 16):
		cells[Vector2i(x, 7)] = true
	return cells


func _path_coords(cell: Vector2i, cells: Dictionary) -> Vector2i:
	var mask := 0
	if cells.has(cell + Vector2i.UP):
		mask |= 1
	if cells.has(cell + Vector2i.RIGHT):
		mask |= 2
	if cells.has(cell + Vector2i.DOWN):
		mask |= 4
	if cells.has(cell + Vector2i.LEFT):
		mask |= 8
	return Vector2i(mask % 4, floori(float(mask) / 4.0))


func _is_boundary(cell: Vector2i) -> bool:
	return cell.x == 0 or cell.y == 0 or cell.x == MAP_SIZE.x - 1 or cell.y == MAP_SIZE.y - 1


func _plant_spot(cell: Vector2i) -> bool:
	if cell.x < 2 or cell.y < 2 or cell.x >= MAP_SIZE.x - 2 or cell.y >= MAP_SIZE.y - 2:
		return false
	if abs(cell.x - START.x) <= 1 and abs(cell.y - START.y) <= 1:
		return false
	if abs(cell.x - NPC_CELL.x) <= 1 and abs(cell.y - NPC_CELL.y) <= 1:
		return false
	if (cell.x >= 24 and cell.x <= 28 and cell.y >= 3 and cell.y <= 6):
		return false
	if _make_path().has(cell):
		return false
	return (cell.x * 7 + cell.y * 11) % 13 == 0


func _ensure_layer(parent: Node2D, scene_root: Node, layer_name: String, tileset_path: String) -> TileMapLayer:
	var layer := parent.get_node_or_null(layer_name) as TileMapLayer
	if layer == null:
		layer = TileMapLayer.new()
		layer.name = layer_name
		layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		parent.add_child(layer)
		layer.owner = scene_root
	layer.tile_set = load(tileset_path)
	return layer
