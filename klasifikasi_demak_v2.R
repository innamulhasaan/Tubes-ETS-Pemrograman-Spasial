# =====================================================================
# Klasifikasi tutupan lahan 4 kelas berbasis indeks spektral
# Kelas: 1 Vegetasi, 2 Bangunan, 3 Perairan, 4 Awan
# Input : NDVI.tif, NDBI.tif, NDWI.tif, NDCI.tif (hasil skrip sebelumnya)
#         + B04 hasil crop (untuk syarat kecerahan pada kelas awan)
# Output: Klasifikasi_Demak.tif + Klasifikasi_Demak.png + tabel luas kelas
# =====================================================================

# ---- 0. PENGATURAN: UBAH BAGIAN INI ----------------------------------
dir_crop <- "E:/SEMESTER 5/Pemrograman Spasial/proyek ETS/cropnd"        # folder band crop
dir_idx  <- "E:/SEMESTER 5/Pemrograman Spasial/proyek ETS/indeks"  # folder NDVI.tif dst.
offset   <- 1000                                                   # sama seperti skrip indeks
versi    <- "vpembanding20"     # ganti tiap percobaan (v3, v4, ...) agar hasil lama tidak tertimpa

# THRESHOLD (nilai awal; wajib disesuaikan setelah cek histogram dan peta)
t_ndwi     <- 0.00    # NDWI di atas ini        -> perairan
t_ndvi     <- 0.30    # NDVI di atas ini        -> vegetasi
t_ndbi     <- 0.20    # NDBI di atas ini        -> bangunan (naikkan bertahap kalau lahan kering ikut merah)
t_ndci_min <- -0.05   # NDCI di antara min-max  -> kandidat awan
t_ndci_max <-  0.05
t_cerah    <- 0.25    # reflektansi B04 minimal untuk awan (awan itu terang)
pakai_cerah <- TRUE   # dipakai hanya kalau pakai_scl = FALSE
pakai_scl   <- TRUE   # TRUE = awan diambil dari SCL (kelas 8, 9, 10); butuh SCL hasil crop 20 m
min_piksel_awan <- 50 # gumpalan awan lebih kecil dari ini (piksel) dibuang; 1 = matikan filter
# (50 piksel = 2 ha; atap rumah satuan hanya beberapa piksel)

# Warna kelas (kode warna hex)
warna <- c(Vegetasi = "#2E8B3E",
           Bangunan = "#D9534F",
           Perairan = "#1F78B4",
           Awan     = "#BEBEBE")

# ---- 1. Paket --------------------------------------------------------
Sys.setenv(PROJ_LIB = system.file("proj", package = "terra"))
library(terra)

# ---- 2. Baca indeks dan B04 ------------------------------------------
ndvi <- rast(file.path(dir_idx, "NDVI.tif"))
ndbi <- rast(file.path(dir_idx, "NDBI.tif"))
ndwi <- rast(file.path(dir_idx, "NDWI.tif"))
ndci <- rast(file.path(dir_idx, "NDCI.tif"))

f_b04 <- list.files(dir_crop, pattern = "B04", full.names = TRUE, ignore.case = TRUE)
f_b04 <- f_b04[grepl("\\.tif$", f_b04, ignore.case = TRUE)]
stopifnot(length(f_b04) == 1)
b04 <- rast(f_b04)
b04[b04 <= 0] <- NA
b04 <- (b04 - offset) / 10000

compareGeom(ndvi, ndbi, ndwi, ndci, b04)

if (pakai_scl) {
  f_scl <- list.files(dir_crop, pattern = "SCL", full.names = TRUE, ignore.case = TRUE)
  f_scl <- f_scl[grepl("\\.tif$", f_scl, ignore.case = TRUE)]
  if (length(f_scl) != 1) stop("File SCL crop tidak ditemukan/ganda di ", dir_crop)
  scl <- rast(f_scl)          # nilai asli 0-11, tanpa offset
  compareGeom(ndvi, scl)
}

# ---- 3. Bantu menentukan threshold: lihat sebaran nilai --------------
# Reset grafik lama dan buka jendela gambar tersendiri (menghindari error
# "figure margins too large" saat panel Plots RStudio terlalu kecil)
graphics.off()
if (.Platform$OS.type == "windows") windows(width = 10, height = 8)
par(mfrow = c(2, 2), mar = c(3, 3, 2, 1))
hist(ndvi, breaks = 60, main = "NDVI", xlab = "")
hist(ndbi, breaks = 60, main = "NDBI", xlab = "")
hist(ndwi, breaks = 60, main = "NDWI", xlab = "")
hist(ndci, breaks = 60, main = "NDCI", xlab = "")
par(mfrow = c(1, 1), mar = c(5.1, 4.1, 4.1, 2.1))

# Persen area yang NDBI-nya di atas beberapa threshold: bandingkan dengan TCI,
# pilih angka yang membuat 'bangunan' hanya permukiman/jalan/kawasan industri
for (th in c(0.05, 0.10, 0.15, 0.20, 0.25, 0.30)) {
  cat("t_ndbi =", th, "-> NDBI di atas threshold:",
      round(100 * global(ndbi > th, "mean", na.rm = TRUE)[1, 1], 1), "% area\n")
}

# ---- 4. Aturan klasifikasi (urutan = prioritas) ----------------------
# Awan > Perairan > Vegetasi > Bangunan.
# Piksel yang tidak memenuhi satu pun aturan (mis. lahan terbuka/sawah kering)
# dimasukkan ke vegetasi (lahan non-terbangun) agar bangunan tidak berlebihan.
# Jelaskan di laporan bahwa kelas vegetasi mencakup lahan pertanian dan lahan terbuka.
if (pakai_scl) {
  syarat_awan <- scl %in% c(8, 9, 10)     # awan medium, awan tinggi, cirrus tipis
} else if (pakai_cerah) {
  syarat_awan <- (ndci >= t_ndci_min) & (ndci <= t_ndci_max) & (b04 >= t_cerah)
} else {
  syarat_awan <- (ndci >= t_ndci_min) & (ndci <= t_ndci_max)
}

# Buang gumpalan "awan" kecil: awan asli membentuk area luas, atap rumah hanya beberapa piksel
if (min_piksel_awan > 1) {
  awan_mentah <- ifel(is.na(syarat_awan), 0, syarat_awan)
  p  <- patches(awan_mentah, directions = 8, zeroAsNA = TRUE)
  fp <- freq(p)
  besar <- if (is.null(fp) || nrow(fp) == 0) numeric(0) else fp$value[fp$count >= min_piksel_awan]
  if (length(besar) == 0) {
    # tidak ada gumpalan awan yang cukup besar -> kelas awan kosong
    syarat_awan <- awan_mentah * 0
    cat("Tidak ada gumpalan awan >=", min_piksel_awan, "piksel; kelas awan = 0\n")
  } else {
    syarat_awan <- ifel(is.na(p), 0, ifel(p %in% besar, 1, 0))
  }
}

kelas <- ifel(syarat_awan, 4,
              ifel(ndwi > t_ndwi, 3,
                   ifel(ndvi > t_ndvi, 1,
                        ifel(ndbi > t_ndbi, 2,
                             1))))

kelas <- mask(kelas, ndvi)          # area di luar kabupaten tetap kosong
names(kelas) <- "Kelas"

levels(kelas) <- data.frame(id = 1:4, kelas = names(warna))
coltab(kelas) <- data.frame(value = 1:4, col = unname(warna))

# ---- 5. Cek hasil ----------------------------------------------------
plot(kelas, main = "Klasifikasi Tutupan Lahan Kab. Demak")

tabel <- freq(kelas)
tabel$persen   <- round(100 * tabel$count / sum(tabel$count), 2)
tabel$luas_km2 <- round(tabel$count * prod(res(kelas)) / 1e6, 2)   # asumsi CRS meter (UTM)
print(tabel)

# ---- 6. Simpan -------------------------------------------------------
writeRaster(kelas, file.path(dir_idx, paste0("Klasifikasi_Demak_", versi, ".tif")),
            overwrite = TRUE, datatype = "INT1U")

png(file.path(dir_idx, paste0("Klasifikasi_Demak_", versi, ".png")), width = 1600, height = 1200, res = 200)
plot(kelas, main = "Klasifikasi Tutupan Lahan Kab. Demak")
dev.off()

cat("Selesai. Hasil tersimpan di:", dir_idx, "\n")