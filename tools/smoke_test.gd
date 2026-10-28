extends SceneTree

var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if condition:
		print("OK   ", message)
	else:
		_failures += 1
		printerr("FAIL ", message)


func _run() -> void:
	for action in ["move_up", "move_down", "move_left", "move_right", "run", "interact"]:
		_check(InputMap.has_action(action), "acao existe: %s" % action)
	_check(
		InputMap.action_get_events("move_up").size() == 2,
		"move_up tem duas teclas (W e seta)",
	)

	var scene: PackedScene = load("res://scenes/main.tscn")
	var main: Node = scene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var world: World = main.get_node("World")
	var player: GridPlayer = main.get_node("Entities/Player")
	var dialogue: Control = main.get_node("UI/Dialogue")

	_check(world.map_width == 32 and world.map_height == 22, "mapa 32x22 carregado")
	_check(world.start_cell == Vector2i(10, 11), "celula inicial correta")
	_check(world.is_walkable(world.start_cell), "inicio caminhavel")
	_check(not world.is_walkable(Vector2i(0, 0)), "borda bloqueada")
	_check(world.is_walkable(Vector2i(4, 4)), "grama seca caminhavel")

	var ground: TileMapLayer = main.get_node("World/Ground")
	_check(ground.tile_set != null, "tileset do cenario montado")
	_check(ground.tile_set.tile_size == Vector2i(128, 128), "grid logico do tileset em 128x128")
	_check(
		ground.get_used_cells().size() == 32 * 22,
		"cenario completo com 704 tiles",
	)
	var atlas := ground.tile_set.get_source(0) as TileSetAtlasSource
	_check(atlas != null and atlas.get_tiles_count() == 64, "atlas Caatinga com 64 tiles")
	_check(
		atlas != null and atlas.texture_region_size == Vector2i(128, 128),
		"regiao do atlas em 128x128",
	)
	_check(
		atlas != null and atlas.texture != null and atlas.texture.get_width() == 1024,
		"atlas 1024x1024 (64 tiles de 128x128)",
	)

	_check(player.cell == world.start_cell, "player na celula inicial")
	_check(
		player.position == world.cell_to_world(world.start_cell),
		"player alinhado ao grid",
	)
	var sprite: Sprite2D = player.get_node("Sprite")
	_check(
		sprite.texture.get_width() == 256 and sprite.texture.get_height() == 384,
		"folha do player 256x384 (4x4 quadros de 64x96)",
	)
	_check(sprite.hframes == 4 and sprite.vframes == 4, "recorte 4x4 do player")

	var start_cell := player.cell
	Input.action_press("move_up")
	await create_timer(0.55).timeout
	Input.action_release("move_up")
	await create_timer(0.25).timeout
	_check(player.cell.y < start_cell.y, "andou para cima")
	_check(not player.moving, "parou apos soltar")
	_check(
		player.position == world.cell_to_world(player.cell),
		"player voltou ao centro da celula",
	)

	# colisao com pedra da borda: player em (1,1) tenta ir para a esquerda em (0,1) = rocha
	player.cell = Vector2i(1, 1)
	player.position = world.cell_to_world(player.cell)
	player.facing = "left"
	Input.action_press("move_left")
	await create_timer(0.35).timeout
	Input.action_release("move_left")
	await create_timer(0.25).timeout
	_check(player.cell == Vector2i(1, 1), "colisao com pedra da borda bloqueia movimento")

	# dialogo com Dona Zefa em (14,7): player em (14,8) virado para cima
	player.cell = Vector2i(14, 8)
	player.position = world.cell_to_world(player.cell)
	player.facing = "up"
	player.interaction_requested.emit(Vector2i(14, 7))
	await process_frame
	_check(dialogue.get_node("Panel").visible, "dialogo abriu")
	_check(player.input_locked, "player travado durante dialogo")

	dialogue._advance()
	dialogue._advance()
	await process_frame
	_check(not dialogue.get_node("Panel").visible, "dialogo fechou")
	_check(not dialogue.get_node("Indicator").visible, "indicador sumiu")
	_check(not player.input_locked, "player liberado apos dialogo")

	print("")
	if _failures == 0:
		print("SMOKE TEST: tudo certo")
		quit(0)
	else:
		printerr("SMOKE TEST: %d falha(s)" % _failures)
		quit(1)
