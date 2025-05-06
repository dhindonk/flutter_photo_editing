# Photo Editing App

Aplikasi editor foto sederhana untuk membantu praktikum pengolahan citra digital dalam mengimplementasikan materi-materi yang telah dipelajari.

## Demo

Berikut adalah beberapa tampilan demo dari aplikasi:

<p align="center">
  <img src="assets/demo/pc_1.png" alt="Demo 1" width="300"/>
  <img src="assets/demo/pc_2.png" alt="Demo 2" width="300"/>
  <img src="assets/demo/pc_3.png" alt="Demo 3" width="300"/>
  <img src="assets/demo/pc_4.png" alt="Demo 4" width="300"/>
  <img src="assets/demo/pc_5.png" alt="Demo 5" width="300"/>
</p>

## Tentang Aplikasi

Photo Editing App adalah aplikasi yang dirancang untuk membantu mahasiswa dan asisten praktikum dalam mengimplementasikan konsep-konsep pengolahan citra digital yang telah dipelajari. Aplikasi ini berfungsi sebagai alat praktis untuk memahami dan mengaplikasikan materi-materi seperti:

- Pengolahan citra dasar (filtering, thresholding, dll)
- Operasi citra (flip, rotate, crop, dll)
- Penggunaan algoritma pengolahan citra (seperti grayscale, brightness, contrast, dll)
- Penggunaan demo mode untuk melihat contoh-contoh penerapan algoritma pengolahan citra

## Fitur Utama

- **Editor Foto**: Unggah foto dari galeri atau ambil foto baru menggunakan kamera
- **Filter Dasar**: Terapkan berbagai filter seperti grayscale, brightness, contrast, dll
- **Manipulasi Citra**: Lakukan operasi dasar seperti flip, rotate, crop, dll
- **Demo Mode**: Fitur yang menggabungkan semua operasi yang ada, ini merupakan versi beta nya 
- **Simpan Hasil**: Simpan hasil edit ke penyimpanan perangkat

## Cara Penggunaan

1. **Halaman Utama**: Pilih foto dari galeri atau ambil foto baru menggunakan kamera
2. **Edit Foto**: Pilih filter atau efek yang ingin diterapkan pada foto
3. **Demo**: Akses halaman demo untuk melihat contoh-contoh algoritma pengolahan citra
4. **Simpan**: Simpan hasil editan ke penyimpanan perangkat

## Persyaratan Sistem

- Perangkat dengan sistem operasi Android 5.0+
- Ruang penyimpanan yang cukup untuk menyimpan foto hasil edit
- Akses ke kamera dan galeri foto

## Cara Berkontribusi

Kami sangat menghargai kontribusi Anda untuk pengembangan aplikasi ini. Berikut adalah panduan untuk berkontribusi:

### Branching Strategy

1. **main**: Branch utama untuk production
2. **develop**: Branch pengembangan utama
3. **feature/**: Branch untuk pengembangan fitur baru (contoh: `feature/brightness-adjustment`)
4. **fix/**: Branch untuk perbaikan bug (contoh: `fix/crash-on-save`)
5. **docs/**: Branch untuk perubahan dokumentasi (contoh: `docs/api-documentation`)

### Langkah-langkah Kontribusi

1. Fork repository ini
2. Clone fork repository ke local
3. Buat branch baru sesuai dengan fitur/perbaikan yang akan dikerjakan
4. Lakukan perubahan yang diperlukan
5. Commit perubahan dengan mengikuti konvensi commit
6. Push ke repository fork Anda
7. Buat Pull Request ke branch `develop`

### Konvensi Commit

Kami menggunakan konvensi commit berikut untuk menjaga kerapihan history:

- `feat: <pesan>` - Penambahan fitur baru (contoh: `feat: menambah filter sepia`)
- `fix: <pesan>` - Perbaikan bug (contoh: `fix: crash saat menyimpan gambar`)
- `docs: <pesan>` - Perubahan dokumentasi (contoh: `docs: update README`)
- `style: <pesan>` - Perubahan format kode (contoh: `style: format kode menggunakan dartfmt`)
- `refactor: <pesan>` - Refactoring kode (contoh: `refactor: optimasi proses filter`)
- `test: <pesan>` - Penambahan atau modifikasi test (contoh: `test: menambah unit test untuk ImageProcessor`)
- `chore: <pesan>` - Perubahan maintenance (contoh: `chore: update dependencies`)

### Pull Request

- Pastikan kode sudah ditest dengan baik
- Berikan deskripsi yang jelas tentang perubahan yang dilakukan
- Sertakan screenshot jika ada perubahan UI
- Pastikan tidak ada konflik dengan branch `develop`
- Tag maintainer untuk review

### Setup Development

1. Install Flutter (versi terbaru)
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi:
   ```bash
   flutter run
   ```

Jika Anda memiliki pertanyaan atau kendala, jangan ragu untuk membuat issue baru di repository ini.

## Kontak

Jika Anda memiliki pertanyaan atau masukan, silakan hubungi kami melalui email: [mfahdin12@gmail.com]

---

Dikembangkan sebagai bagian dari pembelajaran Praktikum Pengolahan Citra Digital 2025.
