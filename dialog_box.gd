extends Control

signal dialog_finished

@onready var label = $Panel/Label

var dialog_lines: Array = []
var current_line: int = 0
var active: bool = false

var char_index: int = 0
var typing_speed: float = 0.03 
var typing: bool = false

func show_dialog(lines: Array):
	print("show_dialog called with lines: ", lines)
	dialog_lines = lines
	current_line = 0
	active = true
	visible = true
	# Also make the panel visible
	$Panel.visible = true
	print("Dialog box and panel set to visible and active")
	print("Panel position: ", $Panel.position)
	print("Panel size: ", $Panel.size)
	_start_line()

func _start_line():
	if current_line < dialog_lines.size():
		char_index = 0
		label.text = ""
		typing = true
		_type_character()
	else:
		_end_dialog()   

func _type_character():
	if not typing:
		return
	
	if char_index < dialog_lines[current_line].length():
		label.text += dialog_lines[current_line][char_index]
		char_index += 1
		await get_tree().create_timer(typing_speed).timeout
		_type_character()
	else:
		typing = false  

func _unhandled_input(event):
	if not active:
		return
	
	if event.is_action_pressed("ui_accept"):
		if typing:
			label.text = dialog_lines[current_line]
			typing = false
		else:
			current_line += 1
			_start_line()

func _end_dialog():
	active = false
	visible = false
	emit_signal("dialog_finished")
