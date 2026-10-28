extends SceneTree

const TILE := Vector2i(128, 128)


func _initialize() -> void:
	var ok := true
	ok = _save_atlas_tileset("res://assets/tilesets/caatinga_128.png", Vector2i(8, 8), "res://assets/tilesets/caatinga_128.tres", true) and ok
	ok = _save_atlas_tileset("res://assets/tilesets/caatinga_paths_128.png", Vector2i(4, 4), "res://assets/tilesets/caatinga_paths_128.tres", false) and ok
	ok = _save_atlas_tileset("res://assets/tilesets/caatinga_plants_128.png", Vector2i(4, 2), "res://assets/tilesets/caatinga_plants_128.tres", false, true) and ok
	quit(0 if ok else 1)


func _save_atlas_tileset(texture_path: String, grid: Vector2i, output_path: String, border_solid: bool, plants := false) -> bool:
	var texture := load(texture_path) as Texture2D
	if texture == null:
		push_error("Textura sem importacao: %s" % texture_path)
		return false
	var tile_set := TileSet.new()
	tile_set.tile_size = TILE
	tile_set.add_custom_data_layer()
	tile_set.set_custom_data_layer_name(0, "solid")
	tile_set.set_custom_data_layer_type(0, TYPE_BOOL)
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = TILE
	tile_set.add_source(source, 0)
	for y in range(grid.y):
		for x in range(grid.x):
			source.create_tile(Vector2i(x, y))
			var blocked := (border_solid and y == 7) or (plants and ((y == 0 and x >= 2) or y == 1))
			if blocked:
				source.get_tile_data(Vector2i(x, y), 0).set_custom_data("solid", true)
	var error := ResourceSaver.save(tile_set, output_path)
	if error != OK:
		push_error("Falha ao salvar %s: %s" % [output_path, error_string(error)])
		return false
	print("TileSet salvo: %s" % output_path)
	return true
