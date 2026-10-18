# =====================================================================
# Perhitungan indeks spektral Sentinel-2 L2A (NDVI, NDBI, NDWI, NDCI)
# Area studi: Kabupaten Demak
# Input : B03, B04, B05, B08, B11 hasil crop (GeoTIFF, resolusi 20 m)
# Output: NDVI.tif, NDBI.tif, NDWI.tif, NDCI.tif + gambar ringkasan
# =====================================================================

# ---- 0. PENGATURAN: UBAH BAGIAN INI SAJA ----------------------------
dir_crop <- "E:/SEMESTER 5/Pemrograman Spasial/proyek ETS/"     # folder berisi B03_crop.tif, dst.
dir_out  <- "E:/SEMESTER 5/Pemrograman Spasial/proyek ETS/indeks"   # folder hasil (dibuat otomatis)

# Offset reflektansi Sentinel-2 L2A:
#   - processing baseline N0400 ke atas (cek nama file .SAFE, mis. _N0510_): 1000
#   - baseline di bawah N0400 (mis. _N0214_)                               : 0
offset <- 1000

# ---- 1. Paket --------------------------------------------------------
if (!requireNamespace("terra", quietly = TRUE)) install.packages("terra")
library(terra)

# ---- 2. Baca band hasil crop -----------------------------------------
cari <- function(kode) {
  f <- list.files(dir_crop, pattern = kode, full.names = TRUE, ignore.case = TRUE)
  f <- f[grepl("\\.tif$", f, ignore.case = TRUE)]
  if (length(f) != 1) {
    stop("Pencarian '", kode, "' menemukan ", length(f), " file: ",
         paste(basename(f), collapse = ", "))
  }
  rast(f)
}

b03 <- cari("B03")    # Green
b04 <- cari("B04")    # Red
b05 <- cari("B05")    # Red Edge 1
b08 <- cari("B8A")    # NIR (B8A, karena folder R20m tidak punya B08)
b11 <- cari("B11")    # SWIR 1

compareGeom(b03, b04, b05, b08, b11)

# ---- 3. Bersihkan NoData dan ubah ke reflektansi ---------------------
siapkan <- function(r) {
  r[r <= 0] <- NA                  # 0 / -9999 dianggap NoData
  (r - offset) / 10000             # DN -> reflektansi
}

b03 <- siapkan(b03)
b04 <- siapkan(b04)
b05 <- siapkan(b05)
b08 <- siapkan(b08)
b11 <- siapkan(b11)

# ---- 4. Hitung indeks ------------------------------------------------
ndvi <- (b08 - b04) / (b08 + b04)   # vegetasi
ndbi <- (b11 - b08) / (b11 + b08)   # lahan terbangun
ndwi <- (b03 - b08) / (b03 + b08)   # perairan
ndci <- (b05 - b04) / (b05 + b04)   # sesuai rumus yang dipakai di modul/brief

names(ndvi) <- "NDVI"
names(ndbi) <- "NDBI"
names(ndwi) <- "NDWI"
names(ndci) <- "NDCI"

indeks <- c(ndvi, ndbi, ndwi, ndci)

# ---- 5. Cek hasil ----------------------------------------------------
# Nilai wajar berada di rentang -1 sampai 1
print(global(indeks, c("min", "max", "mean"), na.rm = TRUE))

par(mfrow = c(2, 2))
plot(ndvi, main = "NDVI")
plot(ndbi, main = "NDBI")
plot(ndwi, main = "NDWI")
plot(ndci, main = "NDCI")
par(mfrow = c(1, 1))

# ---- 6. Simpan -------------------------------------------------------
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)

writeRaster(ndvi, file.path(dir_out, "NDVI.tif"), overwrite = TRUE)
writeRaster(ndbi, file.path(dir_out, "NDBI.tif"), overwrite = TRUE)
writeRaster(ndwi, file.path(dir_out, "NDWI.tif"), overwrite = TRUE)
writeRaster(ndci, file.path(dir_out, "NDCI.tif"), overwrite = TRUE)

cat("Selesai. Hasil tersimpan di:", dir_out, "\n")
