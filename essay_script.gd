extends Node  # Pastikan Root tipe Essay sudah diubah ke Control

# ==========================================
# 1. DEKLARASI NODE UI (Sudah disesuaikan tanpa perantara 'Node')
# ==========================================
@onready var label_soal: Label = $Node/Panel/bagian_soal/Label

@onready var btn_a: TextureButton = $Node/Panel/box_jawaban/HBoxContainer/button_jawaban
@onready var btn_b: TextureButton = $Node/Panel/box_jawaban/HBoxContainer/button_jawaban2
# Gunakan tanda petik jika nama node di editor kamu memakai spasi (contoh: "button jawaban3")
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

# ==========================================
# 3. SIKLUS HIDUP UTAMA (LIFECYCLE)
# ==========================================
func _ready() -> void:
	# Paksa settingan klik agar mutlak terbaca oleh tombol batumu
	btn_a.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_b.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_c.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_d.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Hubungkan fungsi klik tombol lewat kode lambdas
	btn_a.pressed.connect(func(): _on_jawaban_terpilih("A"))
	btn_b.pressed.connect(func(): _on_jawaban_terpilih("B"))
	btn_c.pressed.connect(func(): _on_jawaban_terpilih("C"))
	btn_d.pressed.connect(func(): _on_jawaban_terpilih("D"))
	
	# Memuat bank data soal kuis
	_inisialisasi_data_dummy()
	total_soal = bank_soal.size()
	
	# Jalankan tampilan kuis pertama
	_tampilkan_soal_ke_ui(indeks_soal)

# ==========================================
# 4. MANAJEMEN DATA & LOGIKA KUIS
# ==========================================
func _inisialisasi_data_dummy() -> void:
	bank_soal = [
		{
			"pertanyaan": "BUDI MEMILIKI 14 APEL. JIKA ANTO MEMILIKI 7 APEL, BERAPA JUMLAH APEL YANG DIMILIKI BUDI DAN ANTO?",
			"A": "A. 18",
			"B": "B. 15",
			"C": "C. 15.5",
			"D": "D. 21",
			"kunci": "D"
		},
		{
			"pertanyaan": "RERUNTUHAN CANDI UTAMA MEMILIKI 4 KORIDOR, MASING-MASING KORIDOR ADA 12 RELEIF. BERAPA TOTAL RELEIF?",
			"A": "A. 48",
			"B": "B. 36",
			"C": "C. 44",
			"D": "D. 52",
			"kunci": "A"
		},
		{
			"pertanyaan": "SEORANG ARKEOLOG MENEMUKAN 80 KOIN KUNO DAN INGIN MEMBAGINYA SAMA RATA KE 5 KOTAK. ISI TIAP KOTAK?",
			"A": "A. 14",
			"B": "B. 16",
			"C": "C. 18",
			"D": "D. 20",
			"kunci": "B"
		}
	]

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
	var jawaban_benar = bank_soal[indeks_soal]["kunci"]
	
	if pilihan == jawaban_benar:
		skor_benar += 1
		print("Sistem: Jawaban Benar!")
	else:
		print("Sistem: Jawaban Salah! Kunci adalah: ", jawaban_benar)
		
	indeks_soal += 1
	
	# Beri jeda 0.3 detik biar kerasa efek kliknya sebelum ganti soal baru
	await get_tree().create_timer(0.3).timeout
	_tampilkan_soal_ke_ui(indeks_soal)

# ==========================================
# 5. TRANSISI SCENE
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
		print("Error: Gagal memuat file EvaluasiPage.tscn!")
