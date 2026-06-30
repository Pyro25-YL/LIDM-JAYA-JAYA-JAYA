extends Node2D

@onready var level_grid = $UI/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LevelGrid

@onready var level1 = level_grid.get_node("LevelButton_1")
@onready var level2 = level_grid.get_node("LevelButton_2")
@onready var level3 = level_grid.get_node("LevelButton_3")

@onready var num1 = $UI/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LevelGrid/LevelButton_1/Number
@onready var num2 = $UI/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LevelGrid/LevelButton_2/Number
@onready var num3 = $UI/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LevelGrid/LevelButton_3/Number

@onready var levels = [level1, level2, level3]
@onready var numbers = [num1, num2, num3]

@onready var back_button: TextureButton = $UI/BackButton
# Ganti sesuai path texture tombol Anda
var unlocked_button = preload("res://Assets/Img/LevelIcon.png")
var locked_button = preload("res://Assets/Img/locked.png")
var locked_number = preload("res://Assets/Img/lockIcon.png")

# Level yang sudah terbuka
var unlocked_level = 2

func _ready():
	back_button.pressed.connect(_on_back_button_pressed)
	# Set angka
	num1.texture = get_number_texture(1)
	num2.texture = get_number_texture(2)
	num3.texture = get_number_texture(3)

	update_levels()

	level1.pressed.connect(_on_level1_pressed)
	level2.pressed.connect(_on_level2_pressed)
	level3.pressed.connect(_on_level3_pressed)


func get_number_texture(number: int) -> Texture2D:
	return load("res://Assets/Img/NumAssets/%d.png" % number)


func update_levels() -> void:
	for i in range(levels.size()):
		var level_number = i + 1

		if unlocked_level >= level_number:
			levels[i].texture_normal = unlocked_button
			levels[i].disabled = false
			numbers[i].texture = get_number_texture(level_number)
		else:
			levels[i].texture_normal = locked_button
			levels[i].disabled = true
			numbers[i].texture = locked_number


func _on_level1_pressed():
	get_tree().change_scene_to_file("res://Scenes/Essay.tscn")


func _on_level2_pressed():
	get_tree().change_scene_to_file("res://Scenes/DragAndDropCoding.tscn")


func _on_level3_pressed():
	get_tree().change_scene_to_file("res://Scenes/Essay.tscn")



func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/ChapterSelect.tscn")
