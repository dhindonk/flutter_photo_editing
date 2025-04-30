class TheoryInfo {
  static Map<String, String> getInfo(String filterType) {
    return _theories[filterType] ??
        {
          'title': 'Info tidak tersedia',
          'description': 'Informasi tentang filter ini belum tersedia.'
        };
  }

  static final Map<String, Map<String, String>> _theories = {
    'grayscale': {
      'title': 'Grayscale',
      'description': '''
Konversi citra RGB ke Grayscale mengurangi jumlah informasi warna dengan mengubah citra RGB (3 channel) menjadi citra abu-abu (1 channel). 

Formula:
Gray = 0.299R + 0.587G + 0.114B

Dimana R, G, dan B adalah nilai komponen Red, Green, dan Blue dari pixel. Koefisien berbeda berdasarkan sensitivitas mata manusia terhadap warna.

Aplikasi:
- Preprocessing untuk banyak algoritma pengolahan citra
- Mengurangi kompleksitas komputasi
- Deteksi tepi dan bentuk
''',
    },
    'binary': {
      'title': 'Citra Biner',
      'description': '''
Konversi citra ke format biner (hitam putih) melalui proses thresholding. Setiap pixel akan bernilai 0 (hitam) atau 255 (putih) berdasarkan nilai ambang batas (threshold).

Formula:
Pixel(x,y) = 255 jika Pixel(x,y) > threshold
           = 0 jika Pixel(x,y) ≤ threshold

Dimana threshold adalah nilai ambang yang ditentukan (biasanya 128 untuk rentang 0-255).

Aplikasi:
- Segmentasi objek
- OCR (Optical Character Recognition)
- Deteksi bentuk sederhana
''',
    },
    'brightness': {
      'title': 'Brightness',
      'description': '''
Brightness adalah pengaturan kecerahan citra dengan menambah atau mengurangi nilai setiap komponen RGB dari pixel.

Formula:
R' = R + amount
G' = G + amount
B' = B + amount

Dimana amount adalah nilai penambahan/pengurangan kecerahan (-255 sampai 255).

Aplikasi:
- Koreksi citra yang terlalu gelap/terang
- Menyesuaikan kondisi pencahayaan
- Meningkatkan visibilitas detail
''',
    },
    'contrast': {
      'title': 'Contrast',
      'description': '''
Contrast adalah pengaturan rentang nilai intensitas dalam citra untuk meningkatkan perbedaan antara objek dan latar belakang.

Formula:
factor = (259 * (amount + 255)) / (255 * (259 - amount))
R' = factor * (R - 128) + 128
G' = factor * (G - 128) + 128
B' = factor * (B - 128) + 128

Dimana amount adalah nilai perubahan contrast (-255 sampai 255).

Aplikasi:
- Meningkatkan keterbacaan detil citra
- Memisahkan objek yang memiliki intensitas hampir sama
- Perbaikan kualitas citra medis
''',
    },
    'histogram_equalization': {
      'title': 'Histogram Equalization',
      'description': '''
Histogram Equalization adalah teknik untuk meningkatkan kontras citra dengan meratakan distribusi nilai intensitas.

Langkah-langkah:
1. Hitung histogram citra
2. Hitung CDF (Cumulative Distribution Function)
3. Normalisasi CDF ke rentang 0-255
4. Petakan setiap nilai intensitas ke nilai baru berdasarkan CDF

Aplikasi:
- Meningkatkan kontras secara otomatis
- Memperbaiki citra dengan distribusi intensitas yang sempit
- Preprocessing untuk deteksi tepi dan fitur
''',
    },
    'mean_filter': {
      'title': 'Mean Filter',
      'description': '''
Mean Filter (Filter Rerata) adalah teknik penghalusan citra dengan mengganti nilai setiap pixel dengan nilai rata-rata pixel di sekitarnya.

Formula:
g(x,y) = (1/m*n) * Σ f(i,j)

Dimana m*n adalah ukuran kernel, dan f(i,j) adalah nilai pixel tetangga.

Aplikasi:
- Mengurangi noise acak
- Penghalusan citra
- Denoising untuk preprocessing
''',
    },
    'median_filter': {
      'title': 'Median Filter',
      'description': '''
Median Filter adalah teknik penghalusan citra dengan mengganti nilai setiap pixel dengan nilai median (nilai tengah) dari pixel di sekitarnya.

Langkah-langkah:
1. Pilih kernel (ukuran tetangga, misalnya 3x3)
2. Urutkan nilai pixel dalam kernel
3. Ambil nilai tengah (median) dari urutan tersebut

Aplikasi:
- Menghilangkan noise "salt and pepper"
- Menjaga tepi dan detail saat penghalusan
- Preprocessing untuk segmentasi
''',
    },
    'convolution': {
      'title': 'Konvolusi',
      'description': '''
Konvolusi adalah operasi matematika yang menggabungkan dua fungsi untuk menghasilkan fungsi ketiga. Dalam pengolahan citra, konvolusi dilakukan antara citra dan kernel.

Formula:
g(x,y) = Σ Σ f(i,j) * h(x-i, y-j)

Dimana f adalah citra input, h adalah kernel konvolusi.

Aplikasi:
- Dasar untuk berbagai filter (blur, sharpen, edge detection)
- Feature extraction
- Deteksi pola dan bentuk
''',
    },
    'sobel': {
      'title': 'Sobel Edge Detection',
      'description': '''
Sobel Edge Detection adalah algoritma deteksi tepi yang menggunakan dua kernel 3x3 untuk mendapatkan gradien horizontal (Gx) dan vertikal (Gy).

Kernel Sobel:
Gx = [[-1, 0, 1],
      [-2, 0, 2],
      [-1, 0, 1]]

Gy = [[-1, -2, -1],
      [0, 0, 0],
      [1, 2, 1]]

Magnitude = √(Gx² + Gy²)

Aplikasi:
- Deteksi tepi dan kontur
- Segmentasi objek
- Feature extraction untuk visi komputer
''',
    },
    'prewitt': {
      'title': 'Prewitt Edge Detection',
      'description': '''
Prewitt Edge Detection adalah algoritma deteksi tepi yang mirip dengan Sobel tetapi menggunakan kernel 3x3 yang berbeda.

Kernel Prewitt:
Gx = [[-1, 0, 1],
      [-1, 0, 1],
      [-1, 0, 1]]

Gy = [[-1, -1, -1],
      [0, 0, 0],
      [1, 1, 1]]

Magnitude = √(Gx² + Gy²)

Aplikasi:
- Deteksi tepi vertikal dan horizontal
- Identifikasi batas objek
- Preprocessing untuk segmentasi
''',
    },
    'translation': {
      'title': 'Translasi',
      'description': '''
Translasi adalah transformasi geometris yang memindahkan setiap pixel citra sepanjang arah vektor tertentu.

Formula:
x' = x + dx
y' = y + dy

Dimana (x,y) adalah koordinat original, (x',y') adalah koordinat baru, dan (dx,dy) adalah vektor translasi.

Aplikasi:
- Repositioning objek dalam citra
- Animasi dan efek visual
- Registration (penyelarasan) citra
''',
    },
    'rotation': {
      'title': 'Rotasi',
      'description': '''
Rotasi adalah transformasi geometris yang memutar setiap pixel citra mengelilingi titik pusat dengan sudut tertentu.

Formula:
x' = x*cos(θ) - y*sin(θ)
y' = x*sin(θ) + y*cos(θ)

Dimana (x,y) adalah koordinat original, (x',y') adalah koordinat baru, dan θ adalah sudut rotasi.

Aplikasi:
- Koreksi orientasi citra
- Transformasi perspektif
- Alignment objek untuk analisis
''',
    },
    'scaling': {
      'title': 'Scaling',
      'description': '''
Scaling adalah transformasi geometris yang mengubah ukuran citra dengan faktor penskalaan.

Formula:
x' = x * sx
y' = y * sy

Dimana (x,y) adalah koordinat original, (x',y') adalah koordinat baru, dan sx,sy adalah faktor penskalaan.

Aplikasi:
- Resize citra
- Zoom in/out
- Normalisasi ukuran untuk analisis
''',
    },
    'erosion': {
      'title': 'Erosi',
      'description': '''
Erosi adalah operasi morfologi dasar yang "mengikis" batas objek dalam citra biner. Objek akan menyusut dan lubang akan membesar.

Formula:
A⊖B = {z | (B)z ⊆ A}

Dimana A adalah citra input dan B adalah structuring element.

Aplikasi:
- Menghilangkan noise kecil
- Memisahkan objek yang terhubung
- Memperhalus batas objek
''',
    },
    'dilation': {
      'title': 'Dilasi',
      'description': '''
Dilasi adalah operasi morfologi dasar yang "memperluas" batas objek dalam citra biner. Objek akan membesar dan lubang akan menyusut.

Formula:
A⊕B = {z | (B̂)z ∩ A ≠ ∅}

Dimana A adalah citra input dan B adalah structuring element.

Aplikasi:
- Menyambung area yang terpisah
- Menutup lubang kecil
- Memperbesar objek untuk analisis
''',
    },
    'opening': {
      'title': 'Opening',
      'description': '''
Opening adalah operasi morfologi yang terdiri dari Erosi diikuti Dilasi. Opening cenderung menghilangkan titik-titik kecil (noise) dan memperhalus kontur.

Formula:
A∘B = (A⊖B)⊕B

Aplikasi:
- Menghilangkan noise
- Memisahkan objek yang hampir terhubung
- Ekstraksi fitur spesifik
''',
    },
    'closing': {
      'title': 'Closing',
      'description': '''
Closing adalah operasi morfologi yang terdiri dari Dilasi diikuti Erosi. Closing cenderung mengisi lubang kecil dalam objek dan menghubungkan objek yang berdekatan.

Formula:
A•B = (A⊕B)⊖B

Aplikasi:
- Menutup lubang kecil
- Menghubungkan objek yang terpisah
- Memperhalus kontur objek
''',
    },
  };
}
