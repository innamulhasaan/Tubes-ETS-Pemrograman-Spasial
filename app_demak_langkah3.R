# =====================================================================
# LANGKAH 3: Web Shiny + Leaflet (memuat langkah 1 dan 2)
# Menu 1: Peta Kecamatan
# Menu 2: Klasifikasi Lahan (4 kelas) + perbandingan NDBI 0.15 vs 0.20
# Menu 3: Indeks Spektral (NDVI, NDBI, NDWI, NDCI sebagai raster gradasi)
# Menu 4: Choropleth Kecamatan (dari hasil zonal statistics, ada popup)
# Butuh: leaflet >= 2.2.0, file hasil skrip indeks dan zonal statistics
# =====================================================================

library(shiny)
library(shinydashboard)
library(leaflet)
library(sf)
library(terra)

# ---- 0. PENGATURAN: UBAH BAGIAN INI ----------------------------------
dir_idx   <- "E:/SEMESTER 5/Pemrograman Spasial/proyek ETS/indeks"
path_kec  <- file.path(dir_idx, "Demak_kec_filter.shp")
path_zs   <- file.path(dir_idx, "Zonal_Statistics_Kecamatan_Demak.csv")
kolom_kec <- "WADMKC"      # kolom nama kecamatan di shapefile

# Aturan klasifikasi (sama dengan skrip klasifikasi_demak.R)
t_ndwi <- 0.00
t_ndvi <- 0.30
t_a    <- 0.15
t_b    <- 0.20

# Resolusi tampilan peta: 1 = penuh (20 m, berat), 2 = 40 m (disarankan), 3 = 60 m
faktor_agregat <- 2

kelas_nama <- c("Vegetasi", "Bangunan", "Perairan", "Awan")
warna      <- c("#2E8B3E", "#D9534F", "#1F78B4", "#BEBEBE")
idx_nama   <- c("NDVI", "NDBI", "NDWI", "NDCI")
stat_nama  <- c("mean", "min", "max", "median", "sd")
palet_chor <- c(NDVI = "YlGn", NDBI = "YlOrRd", NDWI = "Blues", NDCI = "Purples")

# ---- 1. Pemeriksaan awal ---------------------------------------------
if (packageVersion("leaflet") < "2.2.0") {
  stop("Versi leaflet (", as.character(packageVersion("leaflet")),
       ") terlalu lama. Jalankan: install.packages('leaflet')")
}
for (p in c(path_kec, path_zs)) {
  if (!file.exists(p)) stop("File tidak ditemukan: ", p)
}

# ---- 2. Baca data (sekali saja, di luar server) ----------------------
kec <- st_read(path_kec, quiet = TRUE)
if (!kolom_kec %in% names(kec)) {
  stop("Kolom '", kolom_kec, "' tidak ada. Kolom yang tersedia: ",
       paste(names(kec), collapse = ", "))
}
kec <- st_transform(kec, 4326)
bb  <- as.numeric(st_bbox(kec))

ndvi <- rast(file.path(dir_idx, "NDVI.tif"))
ndbi <- rast(file.path(dir_idx, "NDBI.tif"))
ndwi <- rast(file.path(dir_idx, "NDWI.tif"))
ndci <- rast(file.path(dir_idx, "NDCI.tif"))

# ---- 2a. Klasifikasi dan tabel luas ----------------------------------
klasifikasi <- function(t_ndbi) {
  k <- ifel(ndwi > t_ndwi, 3,
       ifel(ndvi > t_ndvi, 1,
       ifel(ndbi > t_ndbi, 2, 1)))
  names(k) <- "kelas"
  k
}
k_a <- klasifikasi(t_a)
k_b <- klasifikasi(t_b)

ambil <- function(k) {
  f    <- freq(k)
  luas <- prod(res(k)) / 1e6            # km2 per piksel (CRS dalam meter)
  tot  <- sum(f$count)
  idx  <- match(1:4, f$value)
  cnt  <- ifelse(is.na(idx), 0, f$count[idx])
  data.frame(km2 = round(cnt * luas, 2), persen = round(100 * cnt / tot, 2))
}
a <- ambil(k_a)
b <- ambil(k_b)
tabel <- data.frame(Kelas = kelas_nama, a$km2, a$persen, b$km2, b$persen,
                    check.names = FALSE)
names(tabel) <- c("Kelas",
                  paste0("Luas km2 (NDBI>", t_a, ")"), paste0("Persen (NDBI>", t_a, ")"),
                  paste0("Luas km2 (NDBI>", t_b, ")"), paste0("Persen (NDBI>", t_b, ")"))

# ---- 2b. Raster untuk tampilan (diperkecil agar ringan) --------------
if (faktor_agregat > 1) {
  k_a <- aggregate(k_a, faktor_agregat, fun = "modal")
  k_b <- aggregate(k_b, faktor_agregat, fun = "modal")
}

siap_tampil <- function(r, lo, hi) {
  if (faktor_agregat > 1) r <- aggregate(r, faktor_agregat, fun = "mean", na.rm = TRUE)
  clamp(r, lower = lo, upper = hi, values = TRUE)
}
indeks_info <- list(
  NDVI = list(r = siap_tampil(ndvi, -0.2, 0.8),  lo = -0.2, hi = 0.8,  pal = "RdYlGn"),
  NDBI = list(r = siap_tampil(ndbi, -0.3, 0.25), lo = -0.3, hi = 0.25, pal = "YlOrRd"),
  NDWI = list(r = siap_tampil(ndwi, -0.8, 0.7),  lo = -0.8, hi = 0.7,  pal = "RdYlBu"),
  NDCI = list(r = siap_tampil(ndci, -0.2, 0.5),  lo = -0.2, hi = 0.5,  pal = "YlGnBu")
)

# Konversi raster tampilan ke RasterLayer (paket raster). Jalur ini paling lama dan
# paling stabil di leaflet; kalau raster tidak muncul di peta, biarkan TRUE.
konversi_raster <- TRUE
ke_leaflet <- function(r) {
  if (!konversi_raster) return(r)
  if (!requireNamespace("raster", quietly = TRUE)) {
    stop("Paket 'raster' belum terpasang. Jalankan: install.packages('raster')")
  }
  raster::raster(r)
}
k_a <- ke_leaflet(k_a)
k_b <- ke_leaflet(k_b)
indeks_info <- lapply(indeks_info, function(inf) { inf$r <- ke_leaflet(inf$r); inf })

pal_kelas <- colorFactor(palette = warna, domain = 1:4, na.color = "transparent")
grup_a <- paste0("NDBI > ", t_a)
grup_b <- paste0("NDBI > ", t_b)
maks_byte <- 10 * 1024 * 1024

# ---- 2c. Zonal statistics + popup ------------------------------------
zs <- read.csv(path_zs, stringsAsFactors = FALSE)
kec_zs <- merge(kec, zs, by.x = kolom_kec, by.y = "Kecamatan", all.x = TRUE)
if (anyNA(kec_zs$NDVI_mean)) {
  warning("Ada kecamatan yang namanya tidak cocok antara shapefile dan CSV zonal statistics.")
}
zs_df <- st_drop_geometry(kec_zs)

buat_popup <- function(i) {
  baris <- vapply(idx_nama, function(ix) {
    nilai <- vapply(stat_nama, function(s) zs_df[[paste0(ix, "_", s)]][i], numeric(1))
    paste0("<tr><td><b>", ix, "</b></td>",
           paste0("<td>", sprintf("%.3f", nilai), "</td>", collapse = ""), "</tr>")
  }, character(1))
  paste0("<b>Kec. ", zs_df[[kolom_kec]][i], "</b>",
         "<table class='table table-condensed' style='margin:4px 0'>",
         "<tr><th></th><th>mean</th><th>min</th><th>max</th><th>median</th><th>sd</th></tr>",
         paste(baris, collapse = ""), "</table>")
}
popup_kec <- vapply(seq_len(nrow(zs_df)), buat_popup, character(1))

# Menambah polygon choropleth + legenda ke peta (dipakai awal dan saat pilihan berubah)
tambah_chor <- function(peta, ind, stat) {
  nilai <- zs_df[[paste0(ind, "_", stat)]]
  pal_c <- colorNumeric(palet_chor[[ind]], domain = nilai, na.color = "#cccccc")
  peta %>%
    addPolygons(
      data = kec_zs, fillColor = pal_c(nilai), fillOpacity = 0.8,
      color = "white", weight = 1.5,
      label = paste0(zs_df[[kolom_kec]], ": ", sprintf("%.3f", nilai)),
      popup = popup_kec,
      highlightOptions = highlightOptions(weight = 4, bringToFront = TRUE)
    ) %>%
    addLegend(position = "bottomright", pal = pal_c, values = nilai,
              title = paste(ind, stat), layerId = "legend_chor")
}

# ---- 3. Tampilan (UI) ------------------------------------------------
ui <- dashboardPage(
  dashboardHeader(title = "Peta Demak"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Peta Kecamatan",     tabName = "m_kec",  icon = icon("map")),
      menuItem("Klasifikasi Lahan",  tabName = "m_klas", icon = icon("layer-group")),
      menuItem("Indeks Spektral",    tabName = "m_idx",  icon = icon("leaf")),
      menuItem("Choropleth Kecamatan", tabName = "m_chor", icon = icon("chart-bar"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "m_kec",
        tags$style(type = "text/css", "#peta_kec {height: calc(100vh - 80px) !important;}"),
        leafletOutput("peta_kec")
      ),
      tabItem(
        tabName = "m_klas",
        fluidRow(
          box(width = 12, title = "Klasifikasi tutupan lahan Kab. Demak",
              status = "primary", solidHeader = TRUE,
              leafletOutput("peta_klas", height = 600))
        ),
        fluidRow(
          box(width = 12, title = "Perbandingan luas per kelas",
              status = "primary", solidHeader = TRUE,
              tableOutput("tabel_klas"))
        )
      ),
      tabItem(
        tabName = "m_idx",
        fluidRow(
          box(width = 12, title = "Indeks spektral (nyalakan/matikan di kontrol layer)",
              status = "primary", solidHeader = TRUE,
              leafletOutput("peta_idx", height = 650))
        )
      ),
      tabItem(
        tabName = "m_chor",
        fluidRow(
          box(width = 12, status = "primary",
              column(4, selectInput("ind", "Indeks", choices = idx_nama, selected = "NDVI")),
              column(4, selectInput("stat", "Statistik", choices = stat_nama, selected = "mean")),
              column(4, helpText("Klik kecamatan untuk melihat seluruh statistik."))
          )
        ),
        fluidRow(
          box(width = 12, title = "Zonal statistics per kecamatan",
              status = "primary", solidHeader = TRUE,
              leafletOutput("peta_chor", height = 600))
        )
      )
    )
  )
)

# ---- 4. Server -------------------------------------------------------
server <- function(input, output, session) {

  basemap <- function(peta) {
    peta %>%
      addTiles(group = "OpenStreetMap") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "Esri.WorldImagery")
  }

  # Menu 1: batas kecamatan
  output$peta_kec <- renderLeaflet({
    leaflet(kec) %>%
      basemap() %>%
      addPolygons(
        color = "white", weight = 1.5, fillColor = "#4C9F70", fillOpacity = 0.3,
        label = kec[[kolom_kec]],
        highlightOptions = highlightOptions(weight = 4, fillOpacity = 0.5,
                                            bringToFront = TRUE),
        group = "Kecamatan"
      ) %>%
      addLayersControl(
        baseGroups    = c("OpenStreetMap", "Esri.WorldImagery"),
        overlayGroups = c("Kecamatan"),
        options = layersControlOptions(collapsed = TRUE)
      )
  })

  # Menu 2: klasifikasi
  output$peta_klas <- renderLeaflet({
    leaflet() %>%
      basemap() %>%
      fitBounds(bb[1], bb[2], bb[3], bb[4]) %>%
      addRasterImage(k_a, colors = pal_kelas, opacity = 0.85, method = "ngb",
                     group = grup_a, maxBytes = maks_byte) %>%
      addRasterImage(k_b, colors = pal_kelas, opacity = 0.85, method = "ngb",
                     group = grup_b, maxBytes = maks_byte) %>%
      addPolygons(data = kec, fill = FALSE, color = "white", weight = 1.2,
                  label = kec[[kolom_kec]], group = "Kecamatan") %>%
      addLayersControl(
        baseGroups    = c("OpenStreetMap", "Esri.WorldImagery"),
        overlayGroups = c(grup_a, grup_b, "Kecamatan"),
        options = layersControlOptions(collapsed = FALSE)
      ) %>%
      hideGroup(grup_a) %>%
      addLegend(position = "bottomright", colors = warna, labels = kelas_nama,
                title = "Kelas tutupan lahan", opacity = 0.9)
  })
  output$tabel_klas <- renderTable(tabel, striped = TRUE, bordered = TRUE, digits = 2)

  # Menu 3: indeks spektral
  output$peta_idx <- renderLeaflet({
    peta <- leaflet() %>%
      basemap() %>%
      fitBounds(bb[1], bb[2], bb[3], bb[4])

    for (nm in names(indeks_info)) {
      inf <- indeks_info[[nm]]
      # margin kecil (0.01) agar nilai yang tepat di batas tidak dianggap di luar skala
      # akibat pembulatan float raster
      pal <- colorNumeric(inf$pal, domain = c(inf$lo - 0.01, inf$hi + 0.01),
                          na.color = "transparent")
      peta <- peta %>%
        addRasterImage(inf$r, colors = pal, opacity = 0.85,
                       group = nm, maxBytes = maks_byte) %>%
        addLegend(position = "bottomleft", pal = pal, values = c(inf$lo, inf$hi),
                  title = nm, group = nm)
    }

    peta %>%
      addPolygons(data = kec, fill = FALSE, color = "white", weight = 1.2,
                  label = kec[[kolom_kec]], group = "Kecamatan") %>%
      addLayersControl(
        baseGroups    = c("OpenStreetMap", "Esri.WorldImagery"),
        overlayGroups = c(idx_nama, "Kecamatan"),
        options = layersControlOptions(collapsed = FALSE)
      ) %>%
      hideGroup(c("NDBI", "NDWI", "NDCI"))      # awalnya hanya NDVI yang tampil
  })

  # Menu 4: choropleth
  output$peta_chor <- renderLeaflet({
    leaflet() %>%
      basemap() %>%
      fitBounds(bb[1], bb[2], bb[3], bb[4]) %>%
      addLayersControl(
        baseGroups = c("OpenStreetMap", "Esri.WorldImagery"),
        options = layersControlOptions(collapsed = TRUE)
      ) %>%
      tambah_chor("NDVI", "mean")
  })

  observeEvent(list(input$ind, input$stat), {
    leafletProxy("peta_chor") %>%
      clearShapes() %>%
      removeControl("legend_chor") %>%
      tambah_chor(input$ind, input$stat)
  }, ignoreInit = TRUE)
}

shinyApp(ui, server)
