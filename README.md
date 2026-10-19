# Analisis Indeks Spektral dan Klasifikasi Tutupan Lahan Kabupaten Demak

Tugas Besar ETS Pemrograman Spasial A.
Pengolahan citra Sentinel-2 Level-2A dengan R untuk menghitung indeks spektral
(NDVI, NDBI, NDWI, NDCI), membuat peta klasifikasi tutupan lahan empat kelas
(vegetasi, bangunan, perairan, awan), menghitung zonal statistics per kecamatan,
dan menampilkannya dalam aplikasi web GIS interaktif (R Shiny + Leaflet).

## Hasil

### 1. Peta layout klasifikasi tutupan lahan

Threshold NDBI > 0,20:

![Peta tutupan lahan Kabupaten Demak, NDBI 0,20](hasil/LAYOUT_TUTUPAN_LAHAN_KABUPATEN_DEMAK_NDBI0_20.png)

Threshold NDBI > 0,15 (pembanding):

![Peta tutupan lahan Kabupaten Demak, NDBI 0,15](hasil/LAYOUT_TUTUPAN_LAHAN_KABUPATEN_DEMAK_NDBI0_15.png)

### 2. Tabel luas kelas tutupan lahan

Luas total area studi: 977,05 km².

Threshold NDBI > 0,20:

| Kelas | Luas (km²) | Persentase (%) |
| :--- | ---: | ---: |
| Vegetasi | 874,53 | 89,51 |
| Bangunan | 30,68 | 3,14 |
| Perairan | 71,84 | 7,35 |
| Awan | 0,00 | 0,00 |

Threshold NDBI > 0,15:

| Kelas | Luas (km²) | Persentase (%) |
| :--- | ---: | ---: |
| Vegetasi | 772,13 | 79,03 |
| Bangunan | 133,08 | 13,62 |
| Perairan | 71,84 | 7,35 |
| Awan | 0,00 | 0,00 |

### 3. Tabel zonal statistics per kecamatan

Statistik (mean, min, max, median, standar deviasi) tiap indeks per kecamatan.
File sumber: `hasil/ndvi.csv`, `hasil/ndbi.csv`, `hasil/ndwi.csv`, `hasil/ndci.csv`.

**NDVI**

| Kecamatan | NDVI Mean | NDVI Min | NDVI Max | NDVI Median | NDVI SD |
| :--- | ---: | ---: | ---: | ---: | ---: |
| Bonang | 0,1610 | -0,5526 | 0,7948 | 0,1855 | 0,1792 |
| Demak | 0,2416 | -0,3596 | 0,8328 | 0,2134 | 0,1133 |
| Dempet | 0,2209 | -0,5597 | 0,8324 | 0,1998 | 0,1280 |
| Gajah | 0,1951 | -0,3646 | 0,8002 | 0,1909 | 0,1204 |
| Guntur | 0,2705 | -0,2214 | 0,8381 | 0,2385 | 0,1159 |
| Karanganyar | 0,2092 | -0,5957 | 0,8327 | 0,2013 | 0,1228 |
| Karangawen | 0,2836 | -0,1064 | 0,8065 | 0,2640 | 0,1012 |
| Karangtengah | 0,1983 | -0,5578 | 0,7652 | 0,2071 | 0,1929 |
| Kebonagung | 0,2867 | -0,3883 | 0,8662 | 0,2483 | 0,1212 |
| Mijen | 0,2546 | -0,4188 | 0,7597 | 0,2422 | 0,1139 |
| Mranggen | 0,3059 | -0,1982 | 0,8536 | 0,2780 | 0,1301 |
| Sayung | 0,1100 | -0,6186 | 0,7858 | 0,1588 | 0,2876 |
| Wedung | 0,2051 | -0,5374 | 0,7995 | 0,2237 | 0,1715 |
| Wonosalam | 0,2878 | -0,3558 | 0,8359 | 0,2426 | 0,1325 |

**NDBI**

| Kecamatan | NDBI Mean | NDBI Min | NDBI Max | NDBI Median | NDBI SD |
| :--- | ---: | ---: | ---: | ---: | ---: |
| Bonang | -0,0144 | -0,7718 | 0,3359 | 0,0756 | 0,2103 |
| Demak | 0,0785 | -0,6658 | 0,3868 | 0,1078 | 0,1160 |
| Dempet | -0,0844 | -0,8470 | 0,4021 | -0,0367 | 0,1966 |
| Gajah | -0,1446 | -0,8054 | 0,3698 | -0,0731 | 0,2541 |
| Guntur | 0,0662 | -0,6644 | 0,4323 | 0,0947 | 0,1083 |
| Karanganyar | -0,0497 | -0,8799 | 0,4148 | 0,0150 | 0,1988 |
| Karangawen | 0,0882 | -0,3135 | 0,5140 | 0,0968 | 0,0804 |
| Karangtengah | -0,0149 | -0,7397 | 0,4991 | 0,0512 | 0,1979 |
| Kebonagung | 0,0498 | -0,6464 | 0,4366 | 0,0871 | 0,1125 |
| Mijen | 0,0663 | -0,4235 | 0,3293 | 0,0763 | 0,0849 |
| Mranggen | 0,0671 | -0,5275 | 0,5527 | 0,0834 | 0,1046 |
| Sayung | -0,1734 | -0,8092 | 0,4655 | -0,1589 | 0,2290 |
| Wedung | -0,0670 | -0,8093 | 0,3719 | 0,0038 | 0,1939 |
| Wonosalam | 0,0330 | -0,6544 | 0,4987 | 0,0729 | 0,1237 |

**NDWI**

| Kecamatan | NDWI Mean | NDWI Min | NDWI Max | NDWI Median | NDWI SD |
| :--- | ---: | ---: | ---: | ---: | ---: |
| Bonang | -0,2006 | -0,7048 | 0,6198 | -0,2728 | 0,2245 |
| Demak | -0,3205 | -0,7319 | 0,4229 | -0,3225 | 0,1005 |
| Dempet | -0,2652 | -0,7396 | 0,6615 | -0,2625 | 0,1388 |
| Gajah | -0,2389 | -0,7073 | 0,4653 | -0,2586 | 0,1455 |
| Guntur | -0,3460 | -0,7373 | 0,3237 | -0,3422 | 0,0949 |
| Karanganyar | -0,2614 | -0,7173 | 0,7049 | -0,2817 | 0,1374 |
| Karangawen | -0,3552 | -0,7219 | 0,0597 | -0,3438 | 0,0808 |
| Karangtengah | -0,2343 | -0,6854 | 0,6300 | -0,2862 | 0,2233 |
| Kebonagung | -0,3829 | -0,7621 | 0,4078 | -0,3794 | 0,0939 |
| Mijen | -0,3236 | -0,6837 | 0,4835 | -0,3332 | 0,1126 |
| Mranggen | -0,3634 | -0,7561 | 0,0904 | -0,3499 | 0,1008 |
| Sayung | -0,0798 | -0,6859 | 0,6680 | -0,1677 | 0,3241 |
| Wedung | -0,2346 | -0,7002 | 0,6360 | -0,3043 | 0,2020 |
| Wonosalam | -0,3636 | -0,7340 | 0,4068 | -0,3577 | 0,1034 |

**NDCI**

| Kecamatan | NDCI Mean | NDCI Min | NDCI Max | NDCI Median | NDCI SD |
| :--- | ---: | ---: | ---: | ---: | ---: |
| Bonang | 0,0899 | -0,0644 | 0,3823 | 0,0816 | 0,0431 |
| Demak | 0,0990 | -0,1126 | 0,4351 | 0,0868 | 0,0475 |
| Dempet | 0,1151 | -0,1297 | 0,4696 | 0,1083 | 0,0439 |
| Gajah | 0,1114 | -0,1198 | 0,4340 | 0,1051 | 0,0402 |
| Guntur | 0,1069 | -0,1673 | 0,4932 | 0,0953 | 0,0466 |
| Karanganyar | 0,1053 | -0,1047 | 0,4615 | 0,0989 | 0,0393 |
| Karangawen | 0,1110 | -0,1489 | 0,4472 | 0,1020 | 0,0427 |
| Karangtengah | 0,0979 | -0,1088 | 0,3971 | 0,0878 | 0,0511 |
| Kebonagung | 0,1155 | -0,2144 | 0,5369 | 0,0992 | 0,0550 |
| Mijen | 0,1024 | -0,1000 | 0,4214 | 0,0938 | 0,0431 |
| Mranggen | 0,1197 | -0,1490 | 0,4733 | 0,1046 | 0,0571 |
| Sayung | 0,0931 | -0,1958 | 0,4044 | 0,0855 | 0,0746 |
| Wedung | 0,1020 | -0,1703 | 0,4354 | 0,0950 | 0,0493 |
| Wonosalam | 0,1170 | -0,1027 | 0,5141 | 0,0993 | 0,0577 |

## Aplikasi web GIS (R Shiny + Leaflet)

Aplikasi `app.R` memiliki empat menu: Peta Kecamatan, Klasifikasi Lahan
(perbandingan NDBI 0,15 dan 0,20), Indeks Spektral, dan Choropleth Kecamatan
(zonal statistics dengan popup).

**Cara menjalankan**

1. Dari RStudio: clone atau unduh repositori ini, jadikan folder repositori sebagai
   working directory, buka `app.R`, lalu klik **Run App**.
2. Langsung dari GitHub (tanpa mengunduh manual):

```r
install.packages(c("shiny", "shinydashboard", "leaflet", "sf", "terra", "raster"))
shiny::runGitHub("NAMA-REPO", "USERNAME-GITHUB")
```

Aplikasi membaca data ringan dari folder `data/`, jadi tidak perlu data Sentinel-2 mentah.
Peta dasar diambil online, sehingga butuh koneksi internet.

## Data dan metode

- **Area studi:** Kabupaten Demak, Jawa Tengah.
- **Citra satelit:** Sentinel-2 L2A dari Copernicus (tanggal akuisisi: *[isi tanggal]*).
  Band 20 m yang dipakai: B03, B04, B05, B8A (NIR), B11.
- **Batas administrasi:** layer `ADMINISTRASI_AR_KABKOTA` dan `ADMINISTRASI_AR_KECAMATAN`
  dari data RBI (Ina-Geoportal).
- NDVI = (NIR - Red) / (NIR + Red); NDBI = (SWIR - NIR) / (SWIR + NIR);
  NDWI = (Green - NIR) / (Green + NIR); NDCI = (RedEdge1 - Red) / (RedEdge1 + Red).
- Urutan klasifikasi: awan, perairan, vegetasi, bangunan.
- Data mentah Sentinel-2 dan raster besar tidak disertakan karena batas ukuran file GitHub
  (100 MB).

## Isi repositori

| Berkas / folder | Fungsi |
| :--- | :--- |
| `hitung_indeks_demak.R` | Menghitung NDVI, NDBI, NDWI, NDCI dari band hasil crop |
| `klasifikasi_demak.R` | Threshold dan peta klasifikasi 4 kelas |
| `zonal_kecamatan_demak.R` | Statistik per kecamatan |
| `siapkan_data_app.R` | Membuat data ringan untuk aplikasi web |
| `app.R` | Aplikasi web R Shiny + Leaflet |
| `data/` | Data ringan: klasifikasi, indeks 60 m, batas kecamatan, CSV zonal statistics |
| `hasil/` | Peta layout dan tabel zonal statistics |

## Keterbatasan

- Di musim kering, lahan terbuka dan atap bangunan memiliki nilai indeks yang mirip,
  sehingga sebagian lahan terbuka dapat terbaca sebagai bangunan atau sebaliknya.
  Threshold NDBI 0,20 bersifat ketat, sehingga luas bangunan kemungkinan terlalu kecil.
- NDCI adalah indeks klorofil dan tidak dapat memisahkan awan dari permukaan yang
  sangat terang, sehingga kelas awan bernilai nol pada citra ini.

## Pembuat

Kelompok 8:

1. Andika Haria Wicaksono (5016241104)
2. Muhammad Innamul Hasan (5016241116)
