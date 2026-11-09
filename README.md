<p align="center">
  <img src="assets/images/netpulse_logo.jpg" alt="NetPulse Logo" width="160" style="border-radius: 36px; border: 1px solid #E4E4E7;" />
</p>

<h1 align="center">⚡ NetPulse</h1>

<p align="center">
  <strong>Mobile Network Telemetry & Real-Time Bandwidth Monitor</strong><br>
  <em>Dibuat untuk Tugas Ujian Tengah Semester (UTS) — Mata Kuliah Mobile Computing (Semester 5)</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.47.9-02569B?logo=flutter&logoColor=white" alt="Flutter Version" />
  <img src="https://img.shields.io/badge/Dart-3.13.7-0175C2?logo=dart&logoColor=white" alt="Dart Version" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Linux-3DDC84?logo=android&logoColor=white" alt="Platform Support" />
  <img src="https://img.shields.io/badge/Theme-White%20Album%20Minimalist-18181B" alt="Theme Minimalist" />
  <img src="https://img.shields.io/badge/Tests-100%25%20Passing-success" alt="Tests Status" />
</p>

---

## 📖 Tentang Aplikasi

**NetPulse** adalah aplikasi *mobile network diagnostics* dan pemantau *bandwidth throughput* yang dirancang dengan mengedepankan prinsip fundamental **Mobile Computing**: efisiensi penggunaan sumber daya perangkat bergerak, adaptasi terhadap fluktuasi jaringan nirkabel, serta abstraksi antarmuka tingkat rendah (*kernel socket interfaces*).

Antarmuka aplikasi mengadopsi estetika **The Beatles — White Album**: desain monokromatik berbasis putih bersih (*pure white & crisp off-white*), tipografi berkontras tinggi (*matte charcoal*), serta bebas dari polusi visual yang berlebihan (*zero clutter*).

---

## 📱 Fitur Utama Aplikasi

### 1. ⚡ Real-Time Speed Test & Bandwidth Engine
* **Speedometer Gauge Minimalis**: Visualisasi busur meteran $240^\circ$ berbasis `CustomPainter` dengan jarum penunjuk berpresisi tinggi.
* **Live Bandwidth Line Chart**: Kurva *Cubic Bezier* interaktif yang menampilkan fluktuasi *throughput* sesaat per jendela waktu 150 ms.
* **Pengukur Latensi (Ping) & Jitter**: Mengukur *Round-Trip Time (RTT)* dan variansi kestabilan paket data berdasarkan standar IETF.
* **Data Usage Counter**: Melacak total konsumsi kuota data (MB) selama pengujian berlangsung.

### 2. 🌐 Diagnostik Jaringan & Antarmuka Kernel (Network Info)
* **Deteksi Status Koneksi**: Mengidentifikasi transisi jaringan **Wi-Fi**, **Data Seluler (LTE/5G)**, atau **Offline**.
* **Identifikasi Publik**: Mengambil alamat **Public IP**, **Nama Operator / ISP**, serta **Geo-Location**.
* **Inspeksi Antarmuka Linux Kernel**: Membaca antarmuka jaringan fisik perangkat (`wlan0` untuk Wi-Fi, `rmnet_data` untuk modem seluler).
* **One-Tap Copy**: Menyalin alamat IP publik maupun lokal ke *clipboard* dengan satu sentuhan.

### 3. 📡 Alat Diagnostik Ping & Packet Loss
* **Pengujian Host Fleksibel**: Pengujian latensi ke server kustom maupun *preset chips* (*Cloudflare 1.1.1.1, Google 8.8.8.8, GitHub*).
* **Ringkasan Statistik**: Menghitung **Min Latency**, **Avg Latency**, **Max Latency**, dan persentase **Packet Loss (%)**.
* **Transmission Log**: Log riwayat transmisi paket dengan lencana status konektivitas.

### 4. 📊 Riwayat Pengujian Persisten (CRUD)
* **Penyimpanan Lokal Mandiri**: Seluruh riwayat pengujian tersimpan secara persisten dalam format dokumen JSON di *app internal storage*.
* **Ringkasan Analitik**: Menampilkan performa terbaik (*Best Speed*), kecepatan rata-rata (*Avg Speed*), serta latensi terendah.
* **Manajemen Data Lengkap (CRUD)**:
  * **Create**: Menyimpan hasil pengujian otomatis saat tes selesai.
  * **Read**: Menampilkan daftar riwayat terurut dari yang terbaru.
  * **Delete**: Menghapus catatan individual menggunakan gestur *Swipe-to-Dismiss*.
  * **Clear All**: Menghapus seluruh data pengujian dengan dialog konfirmasi.

---

## 🔬 Arsitektur Teknis & Low-Level Mobile Computing

NetPulse menerapkan arsitektur **3-Tier Separation of Concerns**:

```
┌────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                   │
│   • SpeedTestScreen    • NetworkInfoScreen             │
│   • PingToolScreen     • HistoryScreen                 │
│   • SpeedometerGauge   • LiveBandwidthChart            │
└───────────────────────────▲────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│                      SERVICE LAYER                     │
│   • SpeedTestService : Non-blocking HTTP Stream Chunk  │
│   • NetworkService   : ICMP/TCP Ping, Kernel Interfaces│
│   • StorageService   : Persistent JSON File Storage    │
└───────────────────────────▲────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│                    DATA / MODEL LAYER                  │
│   • TestResult (Model & JSON Serialization)            │
│   • NetworkInfoData & PingResult                       │
└────────────────────────────────────────────────────────┘
```

### 📐 Formulasi Matematika yang Digunakan:

1. **Throughput Bandwidth (Mbps):**
   $$\text{Throughput (Mbps)} = \frac{\Delta \text{Bytes} \times 8}{\Delta t \text{ (detik)} \times 1.000.000}$$
   *Dihitung secara bertahap setiap $\Delta t \ge 150 \text{ ms}$ menggunakan `http.ByteStream` untuk menjaga kelancaran 60 FPS pada UI.*

2. **Jitter (Variansi Kestabilan Latensi - RFC 3550):**
   $$\text{Jitter} = \frac{1}{N - 1} \sum_{i=1}^{N - 1} |RTT_{i+1} - RTT_i|$$

3. **Packet Loss Rate (%):**
   $$\text{Packet Loss} = \left( \frac{\text{Paket Dikirim} - \text{Paket Diterima}}{\text{Paket Dikirim}} \right) \times 100\%$$

---

## 📂 Struktur Direktori Proyek

```text
netpulse/
├── android/                 # Konfigurasi native Android & Launcher Mipmap Icons
├── assets/
│   └── images/              # Logo aplikasi (netpulse_logo.jpg & logo.svg)
├── lib/
│   ├── main.dart            # Titik masuk utama aplikasi (Entry Point)
│   ├── models/
│   │   └── test_result.dart # Model data riwayat pengujian
│   ├── screens/
│   │   ├── history_screen.dart          # Layar riwayat & analitik CRUD
│   │   ├── main_navigation_screen.dart  # Bottom navigation controller
│   │   ├── network_info_screen.dart     # Layar inspeksi antarmuka & IP
│   │   ├── ping_tool_screen.dart        # Layar alat uji ping & packet loss
│   │   └── speed_test_screen.dart       # Layar utama speedometer & chart
│   ├── services/
│   │   ├── network_service.dart         # Service inspeksi koneksi & ping
│   │   ├── speed_test_service.dart      # Engine download stream chunking
│   │   └── storage_service.dart         # Service persistensi file JSON lokal
│   ├── theme/
│   │   └── app_theme.dart               # Tema minimalis White Album (Light)
│   └── widgets/
│       ├── live_bandwidth_chart.dart    # CustomPainter grafik kurva Bezier
│       ├── speedometer_gauge.dart       # CustomPainter dial meteran 240°
│       └── stat_badge.dart              # Komponen metrik ringkas
├── test/
│   └── widget_test.dart     # Smoke test & automated widget verification
├── pubspec.yaml             # Manajemen dependensi pustaka
└── README.md                # Dokumentasi proyek
```

---

## 🚀 Panduan Menjalankan & Membangun Aplikasi

### Prasyarat:
* Flutter SDK $\ge$ 3.24.0
* Java OpenJDK 21
* Android SDK (API 34/35)

### 1. Menjalankan di Mode Debug (Smartphone Android)
Hubungkan ponsel cerdas Android Anda dengan mengaktifkan opsi **USB Debugging**, lalu jalankan:
```bash
flutter run
```

### 2. Menjalankan di Linux Desktop (Tanpa HP)
```bash
flutter run -d linux
```

### 3. Membangun File APK Rilis (Standalone Release APK)
Untuk keperluan pengumpulan tugas atau instalasi mandiri:
```bash
flutter build apk --release
```
*File APK siap pakai berlokasi di:*  
`build/app/outputs/flutter-apk/app-release.apk`

### 4. Membangun APK Ramping (Split ABI per Arsitektur)
Jika menginginkan ukuran berkas yang lebih kecil (~15–20 MB per prosesor):
```bash
flutter build apk --split-per-abi
```

---

## 🧪 Pengujian & Verifikasi Mutu Kode

Seluruh basis kode telah diverifikasi bebas dari peringatan sintaks dan lulus uji otomatis:

```bash
flutter analyze   # Hasil: No issues found!
flutter test      # Hasil: All tests passed!
```

---

## 👤 Pengembang Proyek

* **Nama Mahasiswa**: Alireza
* **Repositori GitHub**: [github.com/alirezanose/netpulse](https://github.com/alirezanose/netpulse)
* **Mata Kuliah**: Mobile Computing (Semester 5)
* **Karya**: Ujian Tengah Semester (UTS)
