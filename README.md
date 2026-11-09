# ⚡ NetPulse - Mobile Network & Bandwidth Monitor

Aplikasi pemantauan jaringan dan pengukur bandwidth mobile yang dibangun menggunakan **Flutter** untuk mata kuliah **Mobile Computing (UTS)**.

---

## 📱 Fitur Utama Aplikasi

1. **⚡ Real-time Speed Test & Bandwidth Tester**
   * **Speedometer Gauge Animasi**: Visual meter pengukur kecepatan berbasis *CustomPainter* dengan indikator jarum dan *glow effect*.
   * **Live Bandwidth Line Chart**: Grafik area beranimasi yang menampilkan fluktuasi *throughput* (Mbps) secara *real-time*.
   * **Pengukur Latensi (Ping) & Jitter**: Menghitung *Round Trip Time (RTT)* dan variansi kestabilan paket data.
   * **Total Data Transferred**: Menghitung konsumsi kuota/paket data selama proses pengujian.

2. **🌐 Diagnostik & Informasi Jaringan (Network Info)**
   * Deteksi status koneksi otomatis: **Wi-Fi**, **Data Seluler**, atau **Offline**.
   * Identifikasi **Public IP**, **ISP Provider**, dan **Geo-Location**.
   * Pemindaian antarmuka jaringan lokal (*Local Interfaces & Private IP addresses*).
   * Fitur salin alamat IP dengan satu sentuhan (*Copy to Clipboard*).

3. **📡 Ping & Packet Loss Diagnostics Tool**
   * Pengujian ping ke berbagai host/server kustom atau preset (*Cloudflare 1.1.1.1, Google 8.8.8.8, GitHub*).
   * Statistik performa transmisi: **Min Latency**, **Avg Latency**, **Max Latency**, dan **Packet Loss (%)**.
   * Log riwayat paket transmisi dengan indikator warna kualitas koneksi (Hijau: <50ms, Kuning: <100ms, Merah: >100ms).

4. **📊 Riwayat Pengujian & Penyimpanan Lokal (Local Persistence)**
   * Seluruh hasil pengujian tersimpan secara otomatis menggunakan penyimpanan lokal.
   * Ringkasan analitik: Kecepatan tertinggi (*Best Speed*), Rata-rata (*Average Speed*), Latensi terendah, dan Total tes.
   * Fitur manajemen data lengkap (**CRUD**): Melihat detail, menghapus riwayat individual (*swipe to delete*), dan menghapus seluruh riwayat.

---

## 🛠️ Arsitektur & Teknologi

* **Framework**: Flutter 3.47+ (Dart 3.13+)
* **State Management**: Reactive Stream & Stateful Architecture
* **UI Theme**: Modern High-Tech Dark Mode (Material 3)
* **Penyimpanan Lokal**: JSON-based persistent file storage via `path_provider` (kompatibel lintas platform: Android & Linux Desktop)
* **Paket Dependensi Utama**:
  * `connectivity_plus`: Deteksi status koneksi jaringan
  * `http`: Pengujian download chunking & penarikan metadata IP publik
  * `intl`: Pemformatan tanggal dan waktu
  * `path_provider`: Akses direktori penyimpanan dokumen lokal

---

## 🚀 Cara Menjalankan Aplikasi

Masuk ke direktori proyek:
```bash
cd /home/learn/Kuliah/Semester5/MobileComputing/UTS/netpulse
```

### 1. Menjalankan di Linux Desktop (Langsung di laptop):
```bash
flutter run -d linux
```

### 2. Menjalankan di Smartphone Android:
1. Hubungkan HP Android ke laptop via kabel USB dengan mode **USB Debugging** aktif.
2. Periksa apakah perangkat terdeteksi:
   ```bash
   adb devices
   ```
3. Jalankan aplikasi:
   ```bash
   flutter run
   ```

### 3. Membangun File APK untuk Pengumpulan Tugas:
```bash
flutter build apk --release
```
File APK siap kirim akan berada di:  
`build/app/outputs/flutter-apk/app-release.apk`
