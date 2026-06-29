extends Panel

# Mengecek apakah objek yang lewat di atas panel ini valid
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if typeof(data) == TYPE_DICTIONARY and data.has("node_asli"):
		return true
	return false

# Mengeksekusi DUPLIKASI objek saat mouse dilepas
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var node_asli = data["node_asli"]
	
	# 1. Buat duplikat dari node asli beserta seluruh anak-anaknya (hierarki)
	var node_duplikat = node_asli.duplicate()
	
	# 2. Masukkan node hasil duplikat tersebut ke panel tujuan ini
	add_child(node_duplikat)
	
	# 3. Atur posisinya agar sesuai dengan lokasi mouse saat dilepas
	node_duplikat.position = at_position
