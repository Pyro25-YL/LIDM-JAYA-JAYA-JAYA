extends Node2D

# -- prepare the variable --
# Panel Button
@onready var btn_back: TextureButton = $Node/Panel/Button_menu
@onready var btn_retest: TextureButton = $Node/Panel/Button_Retest

# Panel Nilai
@onready var label_jawaban_benar: Label = $Node/Panel/container_jawaban/Jawaban_benar/Skor_nilai
@onready var label_jawaban_salah: Label = $Node/Panel/container_jawaban/Jawaban_salah/Skor_nilai

#panel mentor
@onready var performa: Label = $Node/Panel/Performa/Skor_nilai
@onready var respon_mentor: Label = $Node/Panel/Respon_mentor/komentar

# -- VARIABLE UNTUK SOAL --
var jawaban_benar: int = 0
var jawaban_salah: int = 0
var total_soal: int = 0
var performa_sebelumnya: float = 60.0

#untuk API
const API_URL = "https://your-api-endpoint.com/api/hasil"

# -- LOGIC GAME --
# set up semua button
func _ready() -> void:
	_button_settings()
	await _muat_data()
	
func input_hasil_pengguna(benar: int, total: int, performa_lama: float) -> void:
	jawaban_benar = benar
	jawaban_salah = total - benar
	total_soal = total
	performa_sebelumnya = performa_lama

# ==========================================
# 5. LOAD DATA (API atau DUMMY)
# ==========================================
func _muat_data() -> void:
	var http = HTTPRequest.new()
	add_child(http)
	
	# Coba koneksi ke API
	var error = http.request(API_URL)
	
	if error != OK:
		print("Sistem: Gagal konek API, pakai data dummy.")
		_gunakan_data_dummy()
		http.queue_free()
		return
	
	# Tunggu response API dengan timeout 5 detik
	var hasil = await _tunggu_response_dengan_timeout(http, 5.0)
	http.queue_free()
	
	if hasil == null:
		print("Sistem: API timeout, pakai data dummy.")
		_gunakan_data_dummy()
		return
	
	var response_code = hasil[1]
	var body = hasil[3]
	
	if response_code == 200:
		print("Sistem: Data berhasil dimuat dari API.")
		_parse_data_api(body)
	else:
		print("Sistem: API error code ", response_code, ", pakai data dummy.")
		_gunakan_data_dummy()

# Helper: tunggu response HTTP dengan batas waktu
func _tunggu_response_dengan_timeout(http: HTTPRequest, timeout: float) -> Array:
	var timer = get_tree().create_timer(timeout)
	var selesai = false
	var hasil_response = null
	
	http.request_completed.connect(func(result, code, headers, body):
		selesai = true
		hasil_response = [result, code, headers, body]
	)
	
	while not selesai:
		if timer.time_left <= 0:
			return []  # timeout
		await get_tree().process_frame
	
	return hasil_response if hasil_response else []

# ==========================================
# 6. PARSE DATA API
# Format JSON yang diharapkan dari API:
# { "benar": 22, "salah": 3, "total": 25, "performa_lama": 60.0 }
# ==========================================
func _parse_data_api(body: PackedByteArray) -> void:
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result != OK:
		print("Sistem: Gagal parse JSON, pakai data dummy.")
		_gunakan_data_dummy()
		return
	
	var data = json.get_data()
	jawaban_benar     = data.get("benar", jawaban_benar)
	jawaban_salah     = data.get("salah", jawaban_salah)
	total_soal        = data.get("total", total_soal)
	performa_sebelumnya = data.get("performa_lama", performa_sebelumnya)
	
	_tampilkan_ke_ui()

# ==========================================
# 7. DATA DUMMY (fallback)
# ==========================================
func _gunakan_data_dummy() -> void:
	# Jika data sudah dikirim dari Essay.gd, pakai itu
	# Jika belum (misal scene dibuka langsung), pakai nilai default
	if total_soal == 0:
		jawaban_benar = 22
		jawaban_salah = 3
		total_soal = 25
		performa_sebelumnya = 60.0
	
	_tampilkan_ke_ui()

# ==========================================
# 8. TAMPILKAN KE UI
# ==========================================
func _tampilkan_ke_ui() -> void:
	var persen_benar: float = (float(jawaban_benar) / float(total_soal)) * 100.0
	var selisih_performa: float = persen_benar - performa_sebelumnya
	
	# Isi label presentase
	label_presentase.text = str(int(persen_benar)) + "%"
	
	# Isi label skor
	label_jawaban_benar.text = str(jawaban_benar) + " / " + str(total_soal)
	label_jawaban_salah.text = str(jawaban_salah) + " / " + str(total_soal)
	
	# Isi label performa
	if selisih_performa > 0:
		performa.text = str(int(selisih_performa)) + "% MENINGKAT"
		performa.modulate = Color(0.2, 0.9, 0.2)  # hijau
	elif selisih_performa < 0:
		performa.text = str(int(abs(selisih_performa))) + "% MENURUN"
		performa.modulate = Color(0.9, 0.2, 0.2)  # merah
	else:
		performa.text = "SAMA SEPERTI SEBELUMNYA"
		performa.modulate = Color(1, 1, 1)
	
	# Isi komentar mentor
	respon_mentor.text = _generate_komentar_mentor(persen_benar)

# ==========================================
# 9. KOMENTAR MENTOR OTOMATIS
# ==========================================
func _generate_komentar_mentor(persen: float) -> String:
	if persen >= 90:
		return "Luar biasa! Kamu menguasai materi ini dengan sangat baik. Pertahankan semangat belajarmu!"
	elif persen >= 70:
		return "Bagus! Nilaimu sudah cukup baik. Pelajari lagi soal yang salah agar makin sempurna."
	elif persen >= 50:
		return "Cukup baik, tapi masih ada ruang untuk berkembang. Jangan menyerah, coba lagi!"
	else:
		return "Jangan patah semangat! Pelajari kembali materinya dan coba ulangi tesnya. Kamu pasti bisa!"

# ==========================================
# 10. BUTTON SETTINGS
# ==========================================
func _button_settings() -> void:
	btn_back.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_retest.mouse_filter = Control.MOUSE_FILTER_STOP
	
	btn_back.pressed.connect(_on_btn_back_pressed)
	btn_retest.pressed.connect(_on_btn_retest_pressed)

func _on_btn_back_pressed() -> void:
	var main_scene = load("res://Scenes/MainScreen.tscn")  # Sesuaikan path
	if main_scene:
		get_tree().change_scene_to_packed(main_scene)
	else:
		print("Error: Gagal memuat MainScreen.tscn")

func _on_btn_retest_pressed() -> void:
	var essay_scene = load("res://Scenes/Essay.tscn")  # Sesuaikan path
	if essay_scene:
		get_tree().change_scene_to_packed(essay_scene)
	else:
		print("Error: Gagal memuat Essay.tscn")
