# Re-process and simplify shapes
# ================================
# Repair issues with raw basemap, and then create simplified versions

if (!(".logger" %in% ls(all.names = TRUE))) source("cartography/0_utils.R")
.log <- "cartography/cartography.log"

# load raw basemaps
main_entities_raw <- sf::read_sf(
  "cartography/proc/main_entities_raw.geojson"
)

small_entities_raw <- sf::read_sf(
  "cartography/proc/small_entities_raw.geojson"
)

entity_codes <- readr::read_csv(
  "entity_codes/entity_codes.csv"
)

.logger("intermediate files read", .log)

# process main entities ---------------------------------------------------

# high resolution: no simplification, use ms to repair polygons
main_entities_hires <- rmapshaper::ms_simplify(
  main_entities_raw,
  keep = 1,
  method = "dp",
  keep_shapes = TRUE,
  no_repair = FALSE,
  snap = TRUE
)

# medium resolution: reduce point density
# keep 10% of points using Douglas-Peuker algorithm
main_entities_medium <- rmapshaper::ms_simplify(
  main_entities_hires,
  keep = 0.1,
  method = "dp",
  keep_shapes = TRUE,
  no_repair = FALSE,
  snap = TRUE
)

# low resolution map for web plotting using Visvalingam algorithm
# keep 15% of medium resolution points, approx ~1% of original points
main_entities_lowres <- rmapshaper::ms_simplify(
  main_entities_medium,
  keep = 0.15,
  method = "vis",
  weighting = 0.5,
  keep_shapes = TRUE,
  no_repair = FALSE,
  snap = TRUE
)


# process small entities --------------------------------------------------

# make lowresolution map of island polygons, using un-weighted Visvalingam
# algorithm to better retain island topology, retain 15% of original points
small_entities_lowres <- rmapshaper::ms_simplify(
  small_entities_raw,
  keep = 0.125,
  method = "vis",
  weighting = 1,
  keep_shapes = TRUE,
  no_repair = FALSE,
  snap = TRUE
)


# combine geometries ------------------------------------------------------

# combine small entity and main entity geomtries
all_entities_raw <- main_entities_lowres |>
  rbind(small_entities_lowres) |>
  tidyr::nest(.by = cc_iso3c) |>
  dplyr::rowwise() |>
  dplyr::mutate(geometry = sf::st_combine(data)) |>
  dplyr::ungroup()

# produce output dataset, pass through mapshaper to do a precautionary repair
# and snap of points, force clockwise winding
all_entities_out <- all_entities_raw |>
  dplyr::select(cc_iso3c) |>
  sf::st_set_geometry(all_entities_raw$geometry) |>
  rmapshaper::ms_simplify(
    keep = 1,
    method = "dp",
    keep_shapes = TRUE,
    no_repair = FALSE,
    snap = TRUE
  ) |>
  lwgeom::st_force_polygon_cw() |>
  dplyr::left_join(
    entity_codes, by = "cc_iso3c"
  ) |>
  dplyr::select(
    cc_iso3c, cc_name_long, cc_name_short
  )

.logger("simplification processing complete", .log)

# write files -------------------------------------------------------------

if (file.exists("cartography/out/world_lowres.geojson")) {
  file.remove("cartography/out/world_lowres.geojson")
}

sf::st_write(
  sf::st_cast(all_entities_out, "MULTIPOLYGON"),
  "cartography/out/world_lowres.geojson"
)

.logger("WRITE cartography/out/world_lowres.geojson", .log)

