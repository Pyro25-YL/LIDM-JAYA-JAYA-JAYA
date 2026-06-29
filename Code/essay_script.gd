extends Node

# ==========================================
# 1. DEKLARASI NODE UI
# ==========================================
@onready var label_soal: Label = $Node/Panel/bagian_soal/list_soal
@onready var label_presentase: Label = $Node/Panel/Presentase/Skor_nilai

@onready var btn_a: TextureButton = $Node/Panel/box_jawaban/HBoxContainer/button_jawaban
@onready var btn_b: TextureButton = $Node/Panel/box_jawaban/HBoxContainer/button_jawaban2
@onready var btn_c: TextureButton = $Node/Panel/box_jawaban/HBoxContainer2/button_jawaban3
@onready var btn_d: TextureButton = $Node/Panel/box_jawaban/HBoxContainer2/button_jawaban4

@onready var label_a: Label = $Node/Panel/box_jawaban/HBoxContainer/button_jawaban/Label
@onready var label_b: Label = $Node/Panel/box_jawaban/HBoxContainer/button_jawaban2/Label
@onready var label_c: Label = $Node/Panel/box_jawaban/HBoxContainer2/button_jawaban3/Label
@onready var label_d: Label = $Node/Panel/box_jawaban/HBoxContainer2/button_jawaban4/Label

# ==========================================
# 2. VARIABEL SISTEM KUIS
# ==========================================
var bank_soal: Array = []
var indeks_soal: int = 0
var skor_benar: int = 0
var total_soal: int = 0
var soal_sudah_dimuat: bool = false

# Format JSON yang diharapkan dari API GET soal:
# [
#   {
#     "pertanyaan": "ISI SOAL",
#     "A": "A. PILIHAN A",
#     "B": "B. PILIHAN B",
#     "C": "C. PILIHAN C",
#     "D": "D. PILIHAN D",
#     "kunci": "A"
#   }, ...
# ]
const API_URL = "https://your-api-endpoint.com/api/soal"

# Format JSON yang dikirim ke API POST jawaban:
# {
#   "nomor_soal": 1,
#   "pertanyaan": "ISI SOAL",
#   "jawaban_dipilih": "A",
#   "jawaban_benar": "D",
#   "adalah_benar": false
# }
const API_KIRIM_JAWABAN_URL = "https://your-api-endpoint.com/api/jawaban"

# ==========================================
# 3. LIFECYCLE
# ==========================================
func _ready() -> void:
	_setup_tombol()
	_nonaktifkan_tombol_jawaban()
	_kosongkan_tampilan()
	await _muat_soal_dari_api()

# ==========================================
# 4. SETUP TOMBOL
# ==========================================
func _setup_tombol() -> void:
	btn_a.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_b.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_c.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_d.mouse_filter = Control.MOUSE_FILTER_STOP

	btn_a.pressed.connect(func(): _on_jawaban_terpilih("A"))
	btn_b.pressed.connect(func(): _on_jawaban_terpilih("B"))
	btn_c.pressed.connect(func(): _on_jawaban_terpilih("C"))
	btn_d.pressed.connect(func(): _on_jawaban_terpilih("D"))

func _aktifkan_tombol_jawaban() -> void:
	btn_a.disabled = false
	btn_b.disabled = false
	btn_c.disabled = false
	btn_d.disabled = false

func _nonaktifkan_tombol_jawaban() -> void:
	btn_a.disabled = true
	btn_b.disabled = true
	btn_c.disabled = true
	btn_d.disabled = true

# ==========================================
# 5. LOAD SOAL DARI API DENGAN FALLBACK DUMMY
# ==========================================
func _muat_soal_dari_api() -> void:
	label_soal.text = "Memuat soal..."

	var http = HTTPRequest.new()
	add_child(http)

	var error = http.request(API_URL)

	if error != OK:
		print("Sistem: Gagal mengirim request API (error: ", error, "), pakai data dummy.")
		http.queue_free()
		_gunakan_data_dummy()
		return

	var hasil = await _tunggu_response_dengan_timeout(http, 5.0)
	http.queue_free()

	if hasil == null or hasil.is_empty():
		print("Sistem: API timeout atau tidak merespons, pakai data dummy.")
		_gunakan_data_dummy()
		return

	var response_code = hasil[1]
	var body: PackedByteArray = hasil[3]

	if response_code == 200:
		print("Sistem: Soal berhasil dimuat dari API.")
		_parse_soal_dari_api(body)
	else:
		print("Sistem: API merespons kode ", response_code, ", pakai data dummy.")
		_gunakan_data_dummy()

# ==========================================
# 6. HELPER TIMEOUT
# ==========================================
func _tunggu_response_dengan_timeout(http: HTTPRequest, timeout: float) -> Array:
	var hasil_response: Array = []
	var selesai: bool = false

	http.request_completed.connect(func(result, code, headers, body):
		hasil_response = [result, code, headers, body]
		selesai = true
	)

	var waktu: float = 0.0
	while not selesai:
		await get_tree().process_frame
		waktu += get_process_delta_time()
		if waktu >= timeout:
			print("Sistem: Timeout setelah ", timeout, " detik.")
			return []

	return hasil_response

# ==========================================
# 7. PARSE JSON DARI API
# ==========================================
func _parse_soal_dari_api(body: PackedByteArray) -> void:
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())

	if parse_result != OK:
		print("Sistem: Gagal parse JSON dari API, pakai data dummy.")
		_gunakan_data_dummy()
		return

	var data = json.get_data()

	if typeof(data) != TYPE_ARRAY or data.is_empty():
		print("Sistem: Format data API tidak valid, pakai data dummy.")
		_gunakan_data_dummy()
		return

	for soal in data:
		if not ("pertanyaan" in soal and "A" in soal and "B" in soal \
				and "C" in soal and "D" in soal and "kunci" in soal):
			print("Sistem: Struktur soal dari API tidak lengkap, pakai data dummy.")
			_gunakan_data_dummy()
			return

	bank_soal = data
	_mulai_kuis()

# ==========================================
# 8. DATA DUMMY (fallback)
# ==========================================
func _gunakan_data_dummy() -> void:
	print("Sistem: Menggunakan data dummy.")
	bank_soal = [
		{
			"pertanyaan": "BUDI MEMILIKI 14 APEL. JIKA ANTO MEMILIKI 7 APEL, 
			BERAPA JUMLAH APEL YANG DIMILIKI BUDI DAN ANTO?",
			"A": "A. 18",
			"B": "B. 15",
			"C": "C. 15.5",
			"D": "D. 21",
			"kunci": "D"
		},
		{
			"pertanyaan": "RERUNTUHAN CANDI UTAMA MEMILIKI 4 KORIDOR, 
			MASING-MASING KORIDOR ADA 12 RELEIF. BERAPA TOTAL RELEIF?",
			"A": "A. 48",
			"B": "B. 36",
			"C": "C. 44",
			"D": "D. 52",
			"kunci": "A"
		},
		{
			"pertanyaan": "SEORANG ARKEOLOG MENEMUKAN 80 KOIN KUNO DAN INGIN MEMBAGINYA SAMA RATA KE 5 KOTAK.
			 ISI TIAP KOTAK?",
			"A": "A. 14",
			"B": "B. 16",
			"C": "C. 18",
			"D": "D. 20",
			"kunci": "B"
		}
	]
	_mulai_kuis()

# ==========================================
# 9. MULAI KUIS SETELAH DATA SIAP
# ==========================================
func _mulai_kuis() -> void:
	total_soal = bank_soal.size()
	indeks_soal = 0
	skor_benar = 0
	_aktifkan_tombol_jawaban()
	_tampilkan_soal_ke_ui(indeks_soal)

# ==========================================
# 10. TAMPILAN & LOGIKA KUIS
# ==========================================
func _kosongkan_tampilan() -> void:
	label_soal.text = "Memuat soal..."
	label_a.text = ""
	label_b.text = ""
	label_c.text = ""
	label_d.text = ""

func _tampilkan_soal_ke_ui(indeks: int) -> void:
	if indeks < bank_soal.size():
		var data_sekarang = bank_soal[indeks]
		label_soal.text = data_sekarang["pertanyaan"]
		label_a.text = data_sekarang["A"]
		label_b.text = data_sekarang["B"]
		label_c.text = data_sekarang["C"]
		label_d.text = data_sekarang["D"]
	else:
		_selesai_kuis()

func _on_jawaban_terpilih(pilihan: String) -> void:
	_kosongkan_tampilan()
	_nonaktifkan_tombol_jawaban()

	var kunci = bank_soal[indeks_soal]["kunci"]

	if pilihan == kunci:
		skor_benar += 1
		print("Sistem: Jawaban Benar!")
	else:
		print("Sistem: Jawaban Salah! Kunci adalah: ", kunci)

	# Kirim jawaban ke API di background (tidak memblokir kuis)
	_kirim_jawaban_ke_api(indeks_soal + 1, pilihan, kunci)

	indeks_soal += 1

	await get_tree().create_timer(0.3).timeout
	_aktifkan_tombol_jawaban()
	_tampilkan_soal_ke_ui(indeks_soal)

# ==========================================
# 11. KIRIM JAWABAN KE API (BACKGROUND)
# ==========================================
func _kirim_jawaban_ke_api(nomor: int, pilihan: String, kunci: String) -> void:
	var http = HTTPRequest.new()
	add_child(http)

	var payload = JSON.stringify({
		"nomor_soal": nomor,
		"pertanyaan": bank_soal[nomor - 1]["pertanyaan"],
		"jawaban_dipilih": pilihan,
		"jawaban_benar": kunci,
		"adalah_benar": pilihan == kunci
	})

	var headers = ["Content-Type: application/json"]
	var error = http.request(API_KIRIM_JAWABAN_URL, headers, HTTPClient.METHOD_POST, payload)

	if error != OK:
		print("Sistem: Gagal kirim jawaban soal ", nomor, ", kuis tetap lanjut.")
		http.queue_free()
		return

	# Tunggu response tapi TIDAK memblokir kuis
	var hasil = await _tunggu_response_dengan_timeout(http, 3.0)
	http.queue_free()

	if hasil == null or hasil.is_empty():
		print("Sistem: Timeout kirim jawaban soal ", nomor, ", kuis tetap lanjut.")
		return

	var response_code = hasil[1]
	if response_code == 200:
		print("Sistem: Jawaban soal ", nomor, " berhasil dikirim ke API.")
	else:
		print("Sistem: Gagal kirim jawaban soal ", nomor, ", kode: ", response_code, ", kuis tetap lanjut.")

# ==========================================
# 12. TRANSISI KE SCENE EVALUASI
# ==========================================
func _selesai_kuis() -> void:
	print("Sistem: Kuis Selesai! Skor Benar: ", skor_benar, " dari ", total_soal)

	var evaluasi_scene = load("res://Scenes/Evaluasi&Penilaian.tscn")
	if evaluasi_scene:
		var evaluasi_instance = evaluasi_scene.instantiate()
		get_tree().root.add_child(evaluasi_instance)

		if evaluasi_instance.has_method("input_hasil_pengguna"):
			evaluasi_instance.input_hasil_pengguna(skor_benar, total_soal, 60.0)

		queue_free()
	else:
		print("Error: Gagal memuat file Evaluasi&Penilaian.tscn!")
