extends Node2D

@onready var world: World = $World
@onready var player: GridPlayer = $Entities/Player
@onready var dialogue: Control = $UI/Dialogue
@onready var hint: Label = $UI/Hint
@onready var hint_bg: ColorRect = $UI/HintBG


func _ready() -> void:
	world.spawn_npcs($Entities)
	player.setup(world, world.start_cell, world.start_facing)
	_configure_camera()

	world.npc_interacted.connect(_on_npc_interacted)
	player.interaction_requested.connect(_on_player_interaction)
	dialogue.closed.connect(_on_dialogue_closed)

	_fade_hint_later()


func _configure_camera() -> void:
	var rect := world.get_world_rect()
	player.camera.limit_left = rect.position.x
	player.camera.limit_top = rect.position.y
	player.camera.limit_right = rect.end.x
	player.camera.limit_bottom = rect.end.y
	player.camera.position_smoothing_enabled = false
	player.camera.make_current()


func _on_player_interaction(target_cell: Vector2i) -> void:
	if world.interact_at(target_cell, player):
		player.set_input_locked(true)


func _on_npc_interacted(npc: Npc) -> void:
	dialogue.show_dialogue(npc.display_name, npc.lines)


func _on_dialogue_closed() -> void:
	player.set_input_locked(false)


func _fade_hint_later() -> void:
	await get_tree().create_timer(9.0).timeout
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(hint, "modulate:a", 0.0, 1.0)
	tween.tween_property(hint_bg, "modulate:a", 0.0, 1.0)
