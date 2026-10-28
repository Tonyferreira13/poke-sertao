extends SceneTree

const TERRAIN_CONCEPT := "res://assets/tilesets/stage01_caatinga_concept_v4.png"
const PLANTS_CONCEPT := "res://assets/tilesets/stage01_caatinga_plants_concept_v3.png"
const TILE_SIZE := 128
const GRID_SIZE := 8


func _initialize() -> void:
	_build()


func _build() -> void:
	var terrain_source := Image.load_from_file(TERRAIN_CONCEPT)
	var plants_source := Image.load_from_file(PLANTS_CONCEPT)
	if terrain_source.is_empty() or plants_source.is_empty():
		push_error("Nao foi possivel ler as artes conceituais da Caatinga.")
		quit(1)
		return
	terrain_source.convert(Image.FORMAT_RGBA8)
	plants_source.convert(Image.FORMAT_RGBA8)

	var terrain_atlas := Image.create(TILE_SIZE * GRID_SIZE, TILE_SIZE * GRID_SIZE, false, Image.FORMAT_RGBA8)
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var rect := _grid_cell_rect(terrain_source, x, y, GRID_SIZE, GRID_SIZE, 4)
			var tile := terrain_source.get_region(rect)
			tile.resize(TILE_SIZE, TILE_SIZE, Image.INTERPOLATE_NEAREST)
			terrain_atlas.blit_rect(tile, Rect2i(Vector2i.ZERO, tile.get_size()), Vector2i(x, y) * TILE_SIZE)
	_save_png(terrain_atlas, "res://assets/tilesets/caatinga_128.png")

	var path_atlas := _build_path_atlas(terrain_atlas)
	_save_png(path_atlas, "res://assets/tilesets/caatinga_paths_128.png")

	var plants_atlas := _build_plants_atlas(plants_source)
	_save_png(plants_atlas, "res://assets/tilesets/caatinga_plants_128.png")

	print("PNG da Caatinga gerados; importe os recursos antes de montar os TileSets.")
	quit(0)


func _grid_cell_rect(image: Image, x: int, y: int, columns: int, rows: int, inset: int) -> Rect2i:
	var left := roundi(float(x) * image.get_width() / columns) + inset
	var right := roundi(float(x + 1) * image.get_width() / columns) - inset
	var top := roundi(float(y) * image.get_height() / rows) + inset
	var bottom := roundi(float(y + 1) * image.get_height() / rows) - inset
	return Rect2i(left, top, right - left, bottom - top)


func _build_path_atlas(terrain_atlas: Image) -> Image:
	var result := Image.create(TILE_SIZE * 4, TILE_SIZE * 4, false, Image.FORMAT_RGBA8)
	var dirt := terrain_atlas.get_region(Rect2i(TILE_SIZE, TILE_SIZE * 2, TILE_SIZE, TILE_SIZE))
	var width := 64
	var margin := (TILE_SIZE - width) / 2
	for mask in range(16):
		var tile := Image.create(TILE_SIZE, TILE_SIZE, false, Image.FORMAT_RGBA8)
		for y in range(TILE_SIZE):
			for x in range(TILE_SIZE):
				var inside := x >= margin and x < margin + width and y >= margin and y < margin + width
				if mask & 1 and x >= margin and x < margin + width and y < TILE_SIZE / 2:
					inside = true
				if mask & 2 and x >= TILE_SIZE / 2 and y >= margin and y < margin + width:
					inside = true
				if mask & 4 and x >= margin and x < margin + width and y >= TILE_SIZE / 2:
					inside = true
				if mask & 8 and x < TILE_SIZE / 2 and y >= margin and y < margin + width:
					inside = true
				if inside:
					var pixel := dirt.get_pixel(x, y)
					pixel.a = 1.0
					tile.set_pixel(x, y, pixel)
		result.blit_rect(tile, Rect2i(Vector2i.ZERO, tile.get_size()), Vector2i(mask % 4, floori(float(mask) / 4.0)) * TILE_SIZE)
	return result


func _build_plants_atlas(source: Image) -> Image:
	var atlas := Image.create(TILE_SIZE * 4, TILE_SIZE * 2, false, Image.FORMAT_RGBA8)
	for y in range(2):
		for x in range(4):
			var cell := source.get_region(_grid_cell_rect(source, x, y, 4, 2, 0))
			var bounds := _alpha_bounds(cell, 0.12)
			if bounds.size == Vector2i.ZERO:
				continue
			var sprite := cell.get_region(bounds)
			var scale_factor := minf(112.0 / sprite.get_width(), 112.0 / sprite.get_height())
			var new_size := Vector2i(maxi(1, roundi(sprite.get_width() * scale_factor)), maxi(1, roundi(sprite.get_height() * scale_factor)))
			sprite.resize(new_size.x, new_size.y, Image.INTERPOLATE_NEAREST)
			var destination := Vector2i(x, y) * TILE_SIZE + (Vector2i(TILE_SIZE, TILE_SIZE) - new_size) / 2
			atlas.blit_rect(sprite, Rect2i(Vector2i.ZERO, new_size), destination)
	return atlas


func _alpha_bounds(image: Image, cutoff: float) -> Rect2i:
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a >= cutoff:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	if max_x < min_x or max_y < min_y:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


func _save_png(image: Image, path: String) -> void:
	var error := image.save_png(path)
	if error != OK:
		push_error("Falha ao salvar %s: %s" % [path, error_string(error)])
