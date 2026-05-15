extends Control

signal resume_pressed
signal restart_pressed

@onready var _resume_btn: Button = $Center/Panel/VBox/ResumeBtn
@onready var _restart_btn: Button = $Center/Panel/VBox/RestartBtn


func _ready() -> void:
	_resume_btn.pressed.connect(func() -> void: resume_pressed.emit())
	_restart_btn.pressed.connect(func() -> void: restart_pressed.emit())
