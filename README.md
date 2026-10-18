# Analisis Indeks Spektral dan Klasifikasi Tutupan Lahan Kabupaten Demak

Tugas Besar ETS Pemrograman Spasial A.
Pengolahan citra Sentinel-2 Level-2A dengan R untuk menghitung indeks spektral
(NDVI, NDBI, NDWI, NDCI), membuat peta klasifikasi tutupan lahan empat kelas
(vegetasi, bangunan, perairan, awan), menghitung zonal statistics per kecamatan,
dan menampilkannya dalam aplikasi web interaktif (Shiny + Leaflet).

## Area studi dan data

- **Area studi:** Kabupaten Demak, Jawa Tengah.
- **Citra satelit:** Sentinel-2 L2A dari Copernicus (tanggal akuisisi: *[14/10/2026]*).
  Band 20 m yang dipakai: B03, B04, B05, B8A (NIR), B11.
- **Batas administrasi:** layer `ADMINISTRASI_AR_KABKOTA` dan `ADMINISTRASI_AR_KECAMATAN`
  dari data RBI (Ina-Geoportal).
- Data mentah Sentinel-2 dan raster berukuran besar **tidak** disertakan di repositori
  ini karena batas ukuran file GitHub (100 MB). Unduh ulang dari sumbernya.

## Isi repositori

| Berkas | Fungsi |
|---|---|
| `hitung_indeks_demak.R` | Membaca band hasil crop, menghitung NDVI, NDBI, NDWI, NDCI |
| `klasifikasi_demak.R` | Menentukan threshold dan membuat peta klasifikasi 4 kelas |
| `zonal_kecamatan_demak.R` | Statistik (mean, min, max, median, sd) per kecamatan |
| `app_demak_langkah3.R` | Aplikasi web Shiny + Leaflet |
| `Zonal_Statistics_Kecamatan_Demak.csv` | Hasil zonal statistics |

## Urutan menjalankan

1. Siapkan band hasil crop (B03, B04, B05, B8A, B11) dan ubah path di bagian
   pengaturan tiap skrip (variabel `dir_crop`, `dir_idx`, dan sejenisnya).
2. Jalankan `hitung_indeks_demak.R`.
3. Jalankan `klasifikasi_demak.R`.
4. Jalankan `zonal_kecamatan_demak.R`.
5. Jalankan `app_demak_langkah3.R` dengan **Run App**.

## Paket R yang dibutuhkan

```r
install.packages(c("terra", "sf", "shiny", "shinydashboard", "leaflet", "raster"))
```

(`leaflet` versi 2.2.0 atau lebih baru.)

## Metode singkat

- NDVI = (NIR - Red) / (NIR + Red); NDBI = (SWIR - NIR) / (SWIR + NIR);
  NDWI = (Green - NIR) / (Green + NIR); NDCI = (RedEdge1 - Red) / (RedEdge1 + Red).
- NIR memakai B8A pada resolusi 20 m.
- Urutan klasifikasi: awan, perairan, vegetasi, bangunan. Threshold NDBI yang dipakai
  adalah 0,20 dan dibandingkan dengan 0,15 pada aplikasi web.

## Keterbatasan

- Di musim kering, lahan terbuka dan atap bangunan memiliki nilai indeks yang mirip,
  sehingga sebagian lahan terbuka dapat terbaca sebagai bangunan atau sebaliknya.
- NDCI adalah indeks klorofil dan tidak dapat memisahkan awan dari permukaan yang
  sangat terang, sehingga kelas awan dibatasi dan bernilai nol pada citra ini.

## Pembuat

*[Muhammad Innamul Hasan-5016241116]*
