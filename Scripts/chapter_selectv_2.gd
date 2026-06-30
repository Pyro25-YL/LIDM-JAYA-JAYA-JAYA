extends Control

@export var btn_back: TextureButton
@export var btn_chapter_1: TextureButton
@export var btn_chapter_2: TextureButton
@export var btn_chapter_3: TextureButton
@export var btn_chapter_4: TextureButton


func _ready() -> void:
	var semua_tombol = [
		btn_back, btn_chapter_1, btn_chapter_2, btn_chapter_3, btn_chapter_4
	]
	
	for tombol in semua_tombol:
		if is_instance_valid(tombol):
			tombol.mouse_filter = Control.MOUSE_FILTER_PASS
			
			if tombol.texture_normal and not tombol.texture_click_mask:
				var gambar = tombol.texture_normal.get_image()
				if gambar.is_compressed():
					gambar.decompress()
				var bitmap = BitMap.new()
				bitmap.create_from_image_alpha(gambar)
				tombol.texture_click_mask = bitmap


func _on_btn_back_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_texture_button_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/LevelMenu.tscn")


func _on_texture_button_2_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/LevelMenu.tscn")


func _on_texture_button_3_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/LevelMenu.tscn")


func _on_texture_button_4_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/LevelMenu.tscn")
