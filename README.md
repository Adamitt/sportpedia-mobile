# 🏅 SportPedia Mobile
### _“Gerbang Olahragamu. Langkah Pertama Menuju Arena.”_

---

## 👥 Anggota Kelompok
| NPM | Nama Lengkap |
|------|-----------------------------|
| 2406437376 | Chevinka Queen Cilia Sidabutar |
| 2406360312 | Ainur Fadhil |
| 2406349285 | Freya Zahra Anindyabhakti |
| 2406496006 | Angelique Natasya B.c Siagian |
| 2406351491 | Kalista Wiarta |
| 2406436000 | Ahmad Haikal Najmuddin |

---

## 📖 Deskripsi Aplikasi
**Nama Aplikasi:** SportPedia  
**Tagline:** “Gerbang Olahragamu. Langkah Pertama Menuju Arena.”  
SportPedia adalah platform edukasi olahraga berbasis web dan mobile yang menjadi “teman pertama” bagi siapa pun yang ingin mencoba cabang olahraga baru. Aplikasi ini menyajikan panduan teori, video tutorial, referensi perlengkapan, forum komunitas, dan profil progres agar pengguna dapat melangkah ke arena dengan percaya diri.

---

## 🧩 Cerita & Manfaat
- Banyak calon atlet/penggiat bingung harus mulai dari mana; SportPedia meruntuhkan hambatan itu dengan panduan satu pintu.  
- Manfaat utama:
  - 🧭 Mengurangi hambatan informasi.
  - 🧠 Membangun fondasi pengetahuan kuat.
  - 💰 Mencegah salah beli perlengkapan.
  - 💪 Meningkatkan kepercayaan diri pemula.
  - 🏃 Mendorong gaya hidup aktif.

---

## ⚙️ Fitur-Fitur Utama
1. **Beranda & Navigasi** – Hero, search bar, kategori populer, navigasi cepat, testimoni.
2. **Pustaka Olahraga** – Daftar olahraga, filter/sortir, detail lengkap, bookmark, admin page.
3. **Galeri Video** – Katalog video, filter tingkat kesulitan, komentar & rating.
4. **Gear Guide** – Checklist peralatan, deskripsi alat, rentang harga, rekomendasi merek, link e-commerce.
5. **Forum & Komunitas** – Topik diskusi, balasan, like, highlight komunitas.
6. **Profil & Perjalanan** – Profil pengguna, riwayat aktivitas, pengaturan akun.

---

## 🎯 Target Pengguna
- Individu dewasa & profesional muda yang mencari hobi baru.
- Mahasiswa/pelajar yang ingin ikut UKM olahraga.
- Orang tua yang ingin mengenalkan olahraga ke anak.
- Siapa pun yang penasaran tapi ragu memulai.

---

## 🧭 Daftar Modul SportPedia
| No | Modul | Deskripsi Singkat |
|----|-------|-------------------|
| 1 | Beranda & Navigasi | Tampilan utama dengan pencarian & highlight |
| 2 | Pustaka Olahraga | Informasi teori dan teknik dasar olahraga |
| 3 | Galeri Video | Video tutorial interaktif untuk pemula |
| 4 | Gear Guide | Panduan alat & rekomendasi merek |
| 5 | Forum & Komunitas | Ruang diskusi dan tanya jawab |
| 6 | Profil & Perjalanan | Pelacakan perkembangan olahraga pengguna |

---

## 📅 Pembagian Tugas Per-Pekan

### 🗓️ Pekan 1: Setup Proyek & Dokumentasi Awal
- **Chevinka Queen Cilia Sidabutar**
  - Mengisi deskripsi aplikasi (nama, tagline, fungsi utama).
  - Menulis bagian peran/aktor pengguna (User & Admin).
- **Ahmad Haikal Najmuddin**
  - Membuat codebase Flutter SportPedia.
  - Menyusun struktur folder.
- **Freya Zahra Anindyabhakti**
  - Menuliskan daftar modul di README.
  - Menambahkan pembagian kerja per anggota untuk tiap modul.
- **Angelique Natasya B.c Siagian**
  - Menyusun tabel anggota & NPM.
  - Menambahkan placeholder/link Figma di README.
- **Kalista Wiarta**
  - Membuat GitHub repository kelompok.
  - Menjelaskan hak akses masing-masing aktor.
- **Ainur Fadhil**
  - Menulis alur integrasi Flutter ↔ Web Service (request, validasi server, response JSON).
  - Merapikan struktur & format README.
- **Seluruh Anggota**
  - Menyamakan flow aplikasi.
  - Review README agar konsisten dengan rencana pengembangan.

### 🗓️ Pekan 2: API CRUD Fitur Utama
- **Chevinka (Beranda & Navigasi)**: API testimoni (list/create/update/delete), API kategori populer (read).
- **Freya (Pustaka Olahraga)**: API daftar olahraga (list/detail/create/update/delete).
- **Kalista (Galeri Video)**: API katalog video (list/detail).
- **Angie (Gear Guide)**: API daftar alat (list/detail).
- **Haikal (Forum)**: API forum (list/detail/create topik).
- **Fadhil (Profil & Perjalanan)**: API profil user (read/update).

### 🗓️ Pekan 3: API CRUD Fitur Pendukung & Relasi
- **Chevinka**: API search bar (olahraga & alat), API navigasi cepat (read static/menu).
- **Freya**: API filter/sortir olahraga, bookmark olahraga, admin edit olahraga.
- **Kalista**: API filter video, komentar & rating video.
- **Angie**: API filter alat, rekomendasi merek, e-commerce link.
- **Haikal**: API balasan forum, like, highlight komunitas.
- **Fadhil**: API riwayat aktivitas, pengaturan akun.
- **Kelompok**: Review & testing internal endpoint, dokumentasi endpoint (Swagger/README lanjutan), siapkan dummy data integrasi Flutter.

### 🗓️ Pekan 4: Integrasi API, Sinkronisasi & Debugging
- **Chevinka**: Integrasi API ke UI home/search/kategori populer/testimoni, sinkronisasi tampilan dengan modul lain.
- **Freya**: Integrasi API ke UI pustaka olahraga (list/detail/filter/bookmark), sinkronisasi dengan bookmark/forum/gear.
- **Kalista**: Integrasi API ke UI galeri video (list/detail/filter/komentar/rating), sinkronisasi dengan pustaka & forum.
- **Angie**: Integrasi API ke UI gear guide (alat/rekomendasi/e-commerce), sinkronisasi dengan pustaka & home.
- **Haikal**: Integrasi API ke UI forum (diskusi/balasan/like/highlight), sinkronisasi dengan pustaka, video, profil.
- **Fadhil**: Integrasi API ke UI profil, riwayat aktivitas, pengaturan akun; sinkronisasi dengan seluruh modul.
- **Kelompok**: Debugging error integrasi (API & Flutter), uji coba end-to-end (login → olahraga → video → gear → forum → profil), review bersama & refactor bila perlu.

### 🗓️ Pekan 5: Validasi, Finalisasi, & Presentasi
- **Chevinka**: Validasi home, search, testimoni, navigasi.
- **Freya**: Validasi pustaka olahraga (list/detail/filter/bookmark/admin edit).
- **Kalista**: Validasi galeri video (tampil/filter/komentar/rating).
- **Angie**: Validasi gear guide (alat, rentang harga, rekomendasi merek, link e-commerce).
- **Haikal**: Validasi forum (topik, balasan, like, highlight komunitas).
- **Fadhil**: Validasi profil & perjalanan olahraga (profil, riwayat, pengaturan akun).
- **Kelompok**: Integrasi akhir & uji coba end-to-end final, finalisasi dokumentasi (README, API, diagram alur), buffer bug fixing & revisi minor, persiapan presentasi/demo ke dosen/klien.

---

## Peran atau Aktor Pengguna Aplikasi
Aplikasi SportPedia melibatkan tiga jenis aktor utama, masing-masing dengan peran dan hak akses berbeda untuk memastikan pengalaman penggunaan yang optimal.

### 1. Pengguna Umum (User)
Aktor yang menggunakan aplikasi untuk mencari informasi seputar olahraga.
Akses & Hak:
Melihat daftar olahraga, detail pustaka, video, dan daftar perlengkapan.
Menggunakan fitur pencarian, filter, dan sort.
Melihat forum diskusi tanpa membuat topik.
Membuat akun baru dan melakukan login.
Mengakses profil pribadi.

### 2. Admin
Aktor yang memiliki akses penuh untuk mengelola konten platform.
Akses & Hak:
CRUD olahraga di modul Pustaka Olahraga.
Mengelola daftar alat pada modul Gear Guide.
Mengedit katalog video (menambah data, menghapus data, tagging).
Mengelola testimoni pengguna.
Menghapus diskusi atau komentar tidak pantas di forum.
Review dan maintenance seluruh konten.

---

## Alur Pengintegrasian dengan Web Service
(Integrasi dengan Web App Proyek Tengah Semester)
Proyek SportPedia menggunakan arsitektur client–server, di mana aplikasi Flutter bertindak sebagai client, dan web app Proyek Tengah Semester bertindak sebagai RESTful API server.
Alur Integrasi Utama:

### 1. Client Request
Flutter akan melakukan HTTP request (GET, POST, PUT, DELETE) untuk mengakses server.
Setiap modul memiliki endpoint masing-masing, seperti:
/api/olahraga/
/api/video/
/api/perlengkapan/
/api/forum/
/api/user/
Request ini difasilitasi menggunakan:
http package (untuk request umum),
CookieRequest (untuk request membutuhkan session login).

### 2. Web Service Processing
Server (Django/Python dari proyek tengah semester) akan:
Menerima request dari Flutter
Memvalidasi input
Mengolah query ke database
Mengembalikan data dalam format JSON

### 3. Response ke Client
Flutter akan menerima response berupa:
Data JSON (daftar olahraga, alat, video, forum, dsb.)
Status Code (200 OK, 400 Bad Request, 401 Unauthorized, 404 Not Found, dsb.)
Session cookie untuk mempertahankan status login.
Flutter kemudian melakukan:
Parsing JSON → menjadi model Dart
Menampilkan data ke UI
Menyimpan sebagian data ke state management (provider/login state)
Contoh Alur Integrasi (Pustaka Olahraga):
Pengguna membuka halaman Pustaka → Flutter mengirim GET /api/olahraga/.
Server mengembalikan JSON list olahraga.
Flutter parsing JSON → model Olahraga.
User menekan 1 item → Flutter GET /api/olahraga/{id}.
User bookmark → Flutter POST /api/bookmark/.

Tujuan Integrasi
Menyambungkan aplikasi mobile dengan database & fitur yang sudah dibuat.
Memastikan UI Flutter selalu sinkron dengan data server.
Memanfaatkan seluruh API CRUD dari Proyek Tengah Semester.

## Link Figma (UI/UX Design)
Link Figma:
https://www.figma.com/file/8EefBJOriHpUdaWKzYXzsz?locale=en&type=design
