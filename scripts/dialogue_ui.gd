extends Control

signal closed

@onready var panel: PanelContainer = $Panel
@onready var speaker_label: Label = $Panel/Margin/VBox/Speaker
@onready var text_label: Label = $Panel/Margin/VBox/Text
@onready var indicator: Label = $Indicator

var _lines: PackedStringArray = []
var _index := 0
var _active := false


func _ready() -> void:
	panel.hide()
	indicator.hide()


func show_dialogue(speaker: String, lines: PackedStringArray) -> void:
	if lines.is_empty():
		return

	_lines = lines
	_index = 0
	_active = true
	speaker_label.text = speaker
	speaker_label.visible = not speaker.is_empty()
	panel.show()
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_advance()


func _advance() -> void:
	_index += 1
	if _index >= _lines.size():
		_close()
	else:
		_refresh()


func _refresh() -> void:
	text_label.text = _lines[_index]
	indicator.visible = true


func _close() -> void:
	_active = false
	panel.hide()
	indicator.hide()
	_lines = PackedStringArray()
	closed.emit()
