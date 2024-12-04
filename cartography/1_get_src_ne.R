# Get Natural Earth Sources
# ===========================
# Download Natural Earth vector data from Github

if (!(".logger" %in% ls(all.names = TRUE))) source("cartography/0_utils.R")
.log <- "cartography/cartography.log"


# NE 1:10m git repo files
ne10_git <- httr::GET(
  url = "https://api.github.com/repos/nvkelso/natural-earth-vector/contents/10m_cultural"
)
ne10_git_content <- httr::content(ne10_git, as = "text", encoding = "UTF-8")
ne10_git_files <- jsonlite::fromJSON(ne10_git_content)

# layers of interest
layers <- c(
  "ne_10m_admin_0_countries",
  "ne_10m_admin_0_map_subunits",
  "ne_10m_admin_0_disputed_areas"
)

file_types <- c(
  ".README.html", ".VERSION.txt", ".cpg", ".dbf", ".prj", ".shp", ".shx"
)

if (!dir.exists(file.path("cartography", "src"))) {
  dir.create(file.path("cartography", "src"))
}

for (l in layers) {

  if (!dir.exists(file.path("cartography", "src", l))) {
    dir.create(file.path("cartography", "src", l))
  }

  l_files <- paste0(l, file_types)

  l_raw <- ne10_git_files$download_url[ne10_git_files$name %in% l_files]

  for (lr in l_raw) {
    dest_file <- file.path("cartography", "src", l, basename(lr))
    download.file(
      url = lr,
      destfile = dest_file
    )
    .logger(paste("DOWNLOADED", dest_file), .log)
    if (tools::file_ext(dest_file) == "shp") {

    }

  }

}

