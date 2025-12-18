# Aksara
<img width="468" height="191" alt="aksara_logo" src="https://github.com/user-attachments/assets/92d92bf2-a33f-4e25-9e85-b6de5e309f27" />


Aksara adalah **aplikasi mobile** pembelajaran membaca berbasis **gamifikasi** yang ditujukan untuk anak dan remaja dengan kemampuan literasi dasar yang masih berkembang.  
Aplikasi ini dikembangkan menggunakan **Flutter** sebagai frontend dan **Supabase (PostgreSQL + Auth + Storage)** sebagai backend.

> Aksara membantu pengguna belajar membaca melalui permainan edukatif, visual interaktif, dan progres belajar yang terukur.


## Daftar Isi

- [Latar Belakang](#latar-belakang)
- [Fitur Utama](#fitur-utama)
- [Arsitektur Aplikasi](#arsitektur-aplikasi)
- [Teknologi Utama](#teknologi-utama)
- [Instalasi & Menjalankan Proyek](#instalasi--menjalankan-proyek)
- [Struktur Proyek](#struktur-proyek)
- [Desain Basis Data](#desain-basis-data)
- [Roadmap](#roadmap)
- [Kontribusi](#kontribusi)
- [Tim Pengembang](#tim-pengembang)
- [Lisensi](#lisensi)


## Latar Belakang

Kemampuan literasi membaca di Indonesia masih menjadi tantangan besar, terutama pada kelompok usia sekolah. Rendahnya minat baca dan akses terhadap media belajar yang menarik membuat proses belajar membaca terasa membosankan dan sulit untuk dipertahankan dalam jangka panjang.

Aksara hadir sebagai solusi pembelajaran membaca yang:

- Fokus pada **kemampuan membaca dasar** (huruf, suku kata, kata sederhana, kalimat pendek).
- Menggunakan **permainan edukatif (mini game)** sebagai media utama belajar.
- Menggabungkan **visual, audio, dan interaksi** agar proses belajar terasa ringan dan menyenangkan.
- Menyediakan **progres belajar yang terukur** sehingga pengguna, orang tua, maupun guru dapat memantau perkembangan.

Versi awal Aksara ditujukan untuk perangkat **Android dan iOS**, dengan cakupan fitur yang masih terkendali agar pengembangan dapat dilakukan secara bertahap dan terarah.


## Fitur Utama

### 🎮 Mini Game Literasi

Tiga kemampuan literasi inti yang dilatih melalui mini game:

1. **Listening**  
   Pengguna mendengarkan pelafalan huruf, kata, atau kalimat pendek, kemudian mencocokkannya dengan teks atau gambar yang benar.

2. **Writing**  
   Pengguna belajar menulis huruf atau kata dengan menggambar di layar menggunakan jari. Aplikasi dapat memberikan umpan balik visual (benar/salah) untuk membantu koordinasi visual-motorik.

3. **Reading**  
   Pengguna membaca teks sederhana lalu:
   - menghubungkannya dengan gambar yang sesuai, atau  
   - menjawab pertanyaan singkat terkait isi teks.  

Setiap mini game memberikan **poin, XP, level**, dan **badge** untuk menjaga motivasi belajar.


### 📚 Story Mode (Membaca Buku)

Fitur membaca buku menyediakan perpustakaan digital berisi bacaan tingkat dasar:

- Buku dengan level kesulitan bertahap (misalnya Level 1–5).
- **Mode audio**: teks dapat dibacakan otomatis.
- **Highlight kata** mengikuti audio untuk membantu pengguna mengikuti bacaan.
- **Kuis setelah membaca** untuk mengukur pemahaman.

Tujuannya adalah menumbuhkan minat baca sekaligus meningkatkan pemahaman teks.


### 🏠 Homepage (Dashboard Utama)

Homepage menjadi pusat navigasi pengguna, menampilkan:

- Ringkasan progres belajar harian.
- Rekomendasi misi harian (daily tasks).
- Akses cepat ke Mini Game, Buku, Leaderboard, dan Profil.
- Statistik singkat seperti jumlah XP, streak, dan level.


### 🔐 Authentication

Aksara menggunakan autentikasi berbasis **Supabase Auth** untuk:

- Registrasi akun.
- Login pengguna.
- Reset password.
- Sinkronisasi progres lintas perangkat.

Dengan autentikasi, progres belajar pengguna tersimpan aman di backend dan dapat diakses dari lebih dari satu perangkat.


### 🏆 Leaderboard

Leaderboard dirancang untuk membangun kompetisi sehat:

- Klasemen berdasarkan XP/poin.
- Dapat dibagi menjadi leaderboard harian, mingguan, dan bulanan.
- Mendukung sistem **tier** (misalnya Bronze, Silver, Gold).


### 👤 Profil Pengguna

Halaman profil menampilkan:

- Nama dan avatar/ikon profil.
- Level, total XP, dan badge yang dikumpulkan.
- Statistik belajar dan streak.
- Pengaturan dasar dan preferensi pengguna.


### 📈 Progress & Analitik

Fitur progres memungkinkan pengguna melihat:

- Perkembangan kemampuan membaca, menulis, dan listening.
- Riwayat chapter dan level yang sudah diselesaikan.
- Area yang masih lemah dan membutuhkan lebih banyak latihan.


### 📸 Scan Image

Fitur Scan Image memungkinkan pengguna:

- Memfoto dan mendigitalisasikan tulisan.
- Memisahkan tiap suku kata yang ada pada sebuah kata atau kalimat.

## Arsitektur Aplikasi

Secara garis besar, arsitektur Aksara terbagi menjadi dua lapisan utama:

### Frontend – Flutter App

- Menyajikan UI/UX interaktif untuk mini game, membaca buku, leaderboard, dan profil.
- Mengelola state aplikasi dan alur navigasi.
- Berkomunikasi dengan Supabase melalui SDK resmi.

### Backend – Supabase

- **PostgreSQL** sebagai basis data utama.
- **Auth** untuk autentikasi pengguna.
- **Storage** untuk menyimpan aset seperti gambar dan audio.
- **Row Level Security (RLS)** untuk memastikan data setiap pengguna terisolasi dan aman.
- API otomatis yang memudahkan operasi CRUD langsung dari aplikasi Flutter.


## Teknologi Utama

| Komponen        | Teknologi                    |
| -------------- | ---------------------------- |
| Framework      | Flutter (Dart)               |
| Backend        | Supabase                     |
| Database       | PostgreSQL                   |
| Media Storage  | Supabase Storage             |
| Autentikasi    | Supabase Auth                |
| Version Control| Git + GitHub                 |
| Target Platform| Android dan iOS              |


## Instalasi & Menjalankan Proyek

### 1. Clone Repository

```bash
git clone https://github.com/bimorajendraa/aksara.git
cd aksara
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Konfigurasi Environment

Buat file konfigurasi environment di:

`aksara/lib/env.dart`

Isi dengan:

```dart
class Env {
  static const supabaseUrl = 'https://YOUR-PROJECT-URL.supabase.co';
  static const supabaseAnonKey = 'YOUR-ANON-PUBLIC-KEY';
}
```

> Ganti `YOUR-PROJECT-URL` dan `YOUR-ANON-PUBLIC-KEY` dengan nilai dari project Supabase Anda.  
> Jangan commit file ini ke repository publik; tambahkan ke `.gitignore` jika diperlukan.

### 4. Menjalankan Aplikasi

```bash
flutter run
```

Untuk melihat daftar device yang tersedia:

```bash
flutter devices
```

Menjalankan pada device tertentu:

```bash
flutter run -d <device_id>
```


## Struktur Proyek

```text
aksara/
├─ android/
├─ ios/
├─ web/
├─ assets/
│  ├─ images/
│  └─ audio/
├─ lib/
│  ├─ auth/
│  │  ├─ auth_service.dart
│  │  └─ session_gate.dart
│  ├─ core/
│  │  └─ theme/
│  │     ├─ app_colors.dart
│  │     ├─ app_spacing.dart
│  │     └─ app_text_styles.dart
│  ├─ data/
│  │  └─ models/
│  │     └─ level_model.dart
│  ├─ screens/
│  │  ├─ auth/
│  │  │  ├─ already_registered_screen.dart
│  │  │  ├─ login_screen.dart
│  │  │  ├─ onboarding_screen.dart
│  │  │  └─ signup_screen.dart
│  │  ├─ book/
│  │  │  ├─ chapter_read_screen.dart
│  │  │  ├─ story_detail_screen.dart
│  │  │  └─ story_mode_screen.dart
│  │  ├─ camera/
│  │  │  └─ camera_capture_ocr_page.dart
│  │  ├─ games/
│  │  │  ├─ drag-drop/
│  │  │  │  └─ drag_drop_page.dart
│  │  │  ├─ spellbee/
│  │  │  │  ├─ spellbee.dart
│  │  │  │  └─ spellbee2.dart
│  │  │  ├─ start/
│  │  │  │  ├─ start_page.dart
│  │  │  │  ├─ start_page2.dart
│  │  │  │  ├─ start_page3.dart
│  │  │  │  └─ start_page4.dart
│  │  │  ├─ home/
│  │  │  │  ├─ home_data.dart
│  │  │  │  ├─ home_screen.dart
│  │  │  │  ├─ level_card.dart
│  │  │  │  ├─ level_screen.dart
│  │  │  │  ├─ map_canvas.dart
│  │  │  │  ├─ map_node_widget.dart
│  │  │  │  └─ node_model.dart
│  │  │  └─ profiles/
│  │  │     ├─ achievement_screen.dart
│  │  │     ├─ editalien_screen.dart
│  │  │     ├─ helpme_screen.dart
│  │  │     ├─ profile_screen.dart
│  │  │     ├─ settings_screen.dart
│  │  │     ├─ supportcontact_screen.dart
│  │  │     ├─ entry_screen.dart
│  │  │     ├─ hearthesound.dart
│  │  │     ├─ leaderboard.dart
│  │  │     ├─ practice_screen.dart
│  │  │     └─ writing_practice_screen.dart
│  ├─ utils/
│  │  ├─ hash.dart
│  │  └─ navbar_utils.dart
│  ├─ widgets/
│  │  └─ custom_floating_navbar.dart
│  ├─ env.dart
│  └─ main.dart
├─ test/
└─ pubspec.yaml
```

Struktur di atas dapat disesuaikan dengan implementasi aktual, namun memberikan gambaran umum bagi kontributor baru.


## Desain Basis Data

Tabel inti yang digunakan di Supabase antara lain:

| Tabel                  | Deskripsi                                         |
|------------------------|---------------------------------------------------|
| `akun`                 | Data akun/autentikasi pengguna                    |
| `userdetails`          | Informasi profil tambahan                         |
| `book`                 | Metadata buku                                     |
| `bookdetails`          | Isi buku per chapter/halaman                      |
| `userbookprogress`     | Progres membaca per buku                          |
| `usercompletedchapter` | Daftar chapter yang telah diselesaikan pengguna   |
| `achievement`          | Definisi pencapaian                               |
| `userachievements`     | Relasi user dengan pencapaian                     |
| `profileicons`         | Ikon profil yang tersedia                         |
| `profilebackground`    | Background profil yang tersedia                   |

Seluruh operasi data dilakukan melalui Supabase SDK dengan perlindungan RLS agar setiap pengguna hanya dapat mengakses datanya sendiri.


## Roadmap

- Penambahan variasi mini game baru.  
- Sistem tingkat kesulitan adaptif berdasarkan performa pengguna.  
- Fitur aksesibilitas tambahan (text-to-speech, image ocr, pengaturan ukuran font, dan lain-lain).  


## Kontribusi

Kontribusi sangat terbuka dalam bentuk issue, saran, maupun pull request.

Alur kontribusi yang disarankan:

1. Fork repository ini.
2. Buat branch baru untuk fitur atau perbaikan:

   ```bash
   git checkout -b feature/nama-fitur
   ```

3. Lakukan perubahan dan commit dengan pesan yang jelas:

   ```bash
   git commit -m "Deskripsi singkat perubahan"
   ```

4. Push ke branch tersebut:

   ```bash
   git push origin feature/nama-fitur
   ```

5. Buat Pull Request ke branch utama di repository ini.


## UI Design Credit
Original UI design dikembangkan oleh Tim AulNatBim (Institut Teknologi Sepuluh Nopember).

Some UI components used in the development have been modified or adjusted by the development team to fit the implementation requirements.

## Tim Pengembang

**Kelompok 2 – Mata Kuliah Teknologi Berkembang**  
Program Studi Sistem Informasi  
Institut Teknologi Sepuluh Nopember (ITS), Surabaya

- Gerald Marcell Van Rayne 			        (073)
- Burhan Shidqi Arrasyid			           (074) 
- Arya Wiraguna Dwiputra 			           (083)
- Maulana Muhammad Ad-Dzikri		           (136)
- Sandythia Lova Ramadhani Krisnaprana	     (181)
- Bimo Rajendra Widyadhana			           (210) 


## License
Proyek ini dikembangkan sebagai bagian dari tugas akademik untuk mata kuliah Emerging Technology.
Proyek ini ditujukan semata-mata untuk tujuan pembelajaran dan penelitian dalam bidang teknologi otomotif dan mobilitas.

Apabila Anda ingin menggunakan kembali atau mengadaptasi sebagian dari kode ini, mohon berikan kredit yang layak kepada pengembang dan kontributor asli.

Dokumentasi Teknis - Tim Pengembang Aksara © 2025


