class_name CodeBlock
extends Panel

@export var tipe_blok: String = "base_block"
var blok_selanjutnya: CodeBlock = null

func _get_drag_data(at_position: Vector2) -> Variant:
	var drag_data = {
		"tipe": "kode_blok",
		"node_asli": self 
	}
	
	var preview = Control.new()
	var kotak_preview = ColorRect.new()
	
	kotak_preview.size = self.size 
	kotak_preview.color = Color(0.2, 0.5, 0.8, 0.6)
	
	preview.add_child(kotak_preview)
	kotak_preview.position = -kotak_preview.size / 2 
	
	set_drag_preview(preview)
	
	return drag_data


func eksekusi() -> void:
	print("Mengeksekusi blok: ", tipe_blok)
	_jalankan_logika_inti()
	
	if blok_selanjutnya != null:
		blok_selanjutnya.eksekusi()

func _jalankan_logika_inti() -> void:
	pass


func _on_button_button_up() -> void:
	self.queue_free()
