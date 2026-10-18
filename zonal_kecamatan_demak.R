# =====================================================================
# Zonal statistics per kecamatan: NDVI, NDBI, NDWI, NDCI
# Statistik: mean, min, max, median, sd
# Output   : tabel 1 baris per kecamatan (tampil di Console + file CSV)
# =====================================================================

# ---- 0. PENGATURAN: UBAH BAGIAN INI ----------------------------------
dir_idx  <- "E:/SEMESTER 5/Pemrograman Spasial/proyek ETS/indeks"   # folder NDVI.tif dst.

# Sumber batas kecamatan: pilih SALAH SATU
# (a) langsung dari geodatabase RBI hasil unduhan
pakai_gdb <- TRUE
path_gdb  <- "E:/SEMESTER 5/Pemrograman Spasial/proyek ETS/Demak/KAB DEMAK/2022_RBI25K_KAB_DEMAK_KUGI50_20221231.gdb"
layer_kec <- "ADMINISTRASI_AR_KECAMATAN"
# (b) shapefile kecamatan yang sudah kamu ekspor dari QGIS
path_shp  <- "E:/SEMESTER 5/Pemrograman Spasial/proyek ETS/Demak_kec.shp"

# Nama kolom di tabel atribut (cek di QGIS; skrip akan menampilkan nama kolom)
kolom_kab <- "WADMKK"     # nama kabupaten
kolom_kec <- "WADMKC"     # nama kecamatan
kab_nama  <- "Demak"

# ---- 1. Paket --------------------------------------------------------
Sys.setenv(PROJ_LIB = system.file("proj", package = "terra"))
library(terra)

# ---- 2. Baca indeks --------------------------------------------------
ndvi <- rast(file.path(dir_idx, "NDVI.tif"))
ndbi <- rast(file.path(dir_idx, "NDBI.tif"))
ndwi <- rast(file.path(dir_idx, "NDWI.tif"))
ndci <- rast(file.path(dir_idx, "NDCI.tif"))
indeks <- c(ndvi, ndbi, ndwi, ndci)
names(indeks) <- c("NDVI", "NDBI", "NDWI", "NDCI")

# ---- 3. Baca batas kecamatan -----------------------------------------
kec <- if (pakai_gdb) vect(path_gdb, layer = layer_kec) else vect(path_shp)

cat("Nama kolom di layer kecamatan:\n"); print(names(kec))
if (!all(c(kolom_kab, kolom_kec) %in% names(kec))) {
  stop("Kolom '", kolom_kab, "' atau '", kolom_kec,
       "' tidak ada. Sesuaikan kolom_kab / kolom_kec dengan daftar di atas.")
}

# Hanya kecamatan di Kab. Demak
atr <- as.data.frame(kec)
kec <- kec[toupper(atr[[kolom_kab]]) == toupper(kab_nama), ]
if (nrow(kec) == 0) stop("Tidak ada kecamatan untuk kabupaten '", kab_nama, "'. Cek penulisan nilai kolom.")

# Satu poligon per kecamatan (kalau satu kecamatan terpecah jadi beberapa bagian)
kec <- aggregate(kec, by = kolom_kec)

# Samakan CRS dengan raster
kec <- project(kec, crs(indeks))
cat("Jumlah kecamatan:", nrow(kec), "\n")

# ---- 4. Zonal statistics ---------------------------------------------
fungsi <- c(mean = "mean", min = "min", max = "max", median = "median", sd = "sd")

hasil <- data.frame(Kecamatan = as.data.frame(kec)[[kolom_kec]])

for (nm in names(fungsi)) {
  z <- zonal(indeks, kec, fun = fungsi[[nm]], na.rm = TRUE)
  colnames(z) <- paste0(colnames(z), "_", nm)
  hasil <- cbind(hasil, z)
}

# Urutkan kolom: per indeks (mean, min, max, median, sd)
urutan <- as.vector(sapply(c("NDVI", "NDBI", "NDWI", "NDCI"),
                           function(i) paste0(i, "_", names(fungsi))))
hasil <- hasil[, c("Kecamatan", urutan)]
hasil[, -1] <- round(hasil[, -1], 4)
hasil <- hasil[order(hasil$Kecamatan), ]

# ---- 5. Tampilkan dan simpan -----------------------------------------
options(width = 200)
print(hasil, row.names = FALSE)

write.csv(hasil, file.path(dir_idx, "Zonal_Statistics_Kecamatan_Demak.csv"),
          row.names = FALSE)

# Simpan juga batas kecamatan hasil filter (berguna untuk peta di QGIS)
writeVector(kec, file.path(dir_idx, "Demak_kec_filter.shp"), overwrite = TRUE)

cat("Selesai. Tabel tersimpan di:", dir_idx, "\n")
