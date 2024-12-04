# Merge and subset NE source data
# ==================================
# Apply bespoke merges, re-group subunits and limit to output entities

if (!(".logger" %in% ls(all.names = TRUE))) source("cartography/0_utils.R")
.log <- "cartography/cartography.log"

# load data ---------------------------------------------------------------

# output and merging metadata
output_merges <- readr::read_csv("cartography/proc/output_and_merges.csv")

# NE 1:10m subunits geometry
ne10_subunits <- sf::read_sf(
  file.path(
    "cartography", "src",
    "ne_10m_admin_0_map_subunits",
    "ne_10m_admin_0_map_subunits.shp"
  )
)

# NE 1:10m disputed areas geometry
ne10_disputed <- sf::read_sf(
  file.path(
    "cartography", "src",
    "ne_10m_admin_0_disputed_areas",
    "ne_10m_admin_0_disputed_areas.shp"
  )
)

.logger("source files read", .log)

# small islands and microstates -------------------------------------------

small_entities <- output_merges |>
  dplyr::filter(
    output == "Yes" &
      (output_note == "Small island(s) entity" | output_note == "Microstate") &
      (is.na(merge_group) | (!is.na(merge_group) & merge_group != "CYP"))
  )

cyp_geo <- ne10_subunits |>
  dplyr::filter(
    SU_A3 %in% output_merges$su_a3[output_merges$merge_group == "CYP"]
  ) |>
  sf::st_union() |>
  sf::st_cast("MULTIPOLYGON")

cyp_out <- tibble::tibble(cc_iso3c = "CYP") |>
  sf::st_set_geometry(cyp_geo)

small_entities_raw <- ne10_subunits |>
  dplyr::filter(SU_A3 %in% small_entities$su_a3) |>
  dplyr::select(su_a3 = SU_A3, geometry) |>
  dplyr::left_join(small_entities, by = "su_a3") |>
  dplyr::select(su_a3, entity, geometry) |>
  tidyr::nest(.by = entity) |>
  dplyr::rowwise() |>
  dplyr::mutate(
    geometry = lwgeom::st_force_polygon_cw(sf::st_combine(data))
  ) |>
  dplyr::ungroup()

small_entities_out <- small_entities_raw |>
  dplyr::select(cc_iso3c = entity) |>
  sf::st_set_geometry(small_entities_raw$geometry) |>
  rbind(cyp_out) |>
  dplyr::arrange(cc_iso3c)

# morocco and western sahara ----------------------------------------------

# create full western sahara area
esh_geo <- ne10_disputed |>
  dplyr::filter(BRK_NAME == "W. Sahara") |>
  sf::st_union()

# create tibble
esh_out <- tibble::tibble(
  output = "Yes",
  output_note = NA_character_,
  entity = "ESH",
  entity_note = NA_character_,
  merge_group = NA_character_,
  su_a3 = "SAH",
  subunit = "Western Sahara"
) |>
  sf::st_set_geometry(esh_geo) |>
  dplyr::select(su_a3, geometry, output, output_note, entity, entity_note,
                merge_group, subunit)

# get morocco
mar_raw <- ne10_subunits |>
  dplyr::filter(SU_A3 == "MAR")

# morocco polygons less full western sahara
mar_xws_polys <- sf::st_difference(
  x = mar_raw$geometry,
  y = esh_out$geometry
) |> sf::st_collection_extract("POLYGON") |>
  sf::st_cast(to = "POLYGON")

# eliminate artefacts by getting northernmost of the morocco polygons
mar_xws_geo <- tibble::tibble(id = 1:length(mar_xws_polys)) |>
  sf::st_set_geometry(mar_xws_polys) |>
  dplyr::mutate(
    bbox = purrr::map(
      .x = geometry,
      .f = sf::st_bbox
    ),
    ymax = purrr::map_dbl(
      .x = bbox,
      .f = ~.x$ymax
    )
  ) |>
  dplyr::filter(ymax == max(ymax)) |>
  dplyr::pull(geometry) |>
  sf::st_geometry()

# create tibble
mar_out <- tibble::tibble(
  output = "Yes",
  output_note = NA_character_,
  entity = "MAR",
  entity_note = NA_character_,
  merge_group = NA_character_,
  su_a3 = "MAR",
  subunit = "Morocco"
) |>
  sf::st_set_geometry(mar_xws_geo) |>
  dplyr::select(su_a3, geometry, output, output_note, entity, entity_note,
                merge_group, subunit)


# split asian russia ------------------------------------------------------

# NE subunits data splits Russia into European and Asian parts, the most
# extreme parts of Asian Russia are beyond 180 degrees. Using sf::st_union()
# on the source geometry to combine these sub-units creates strange plotting
# artefacts in {ggplot2}. Splitting Asian Russia into groups either side of
# 180-degrees resolves this.

# get asian russia
ne10_russia_asia <- ne10_subunits |>
  dplyr::filter(SU_A3 == "RUA")

# split polygons
russia_polys <- ne10_russia_asia |>
  sf::st_geometry() |>
  sf::st_cast("POLYGON")

# calculate splits
#   1. get bbox of each polygon
#   2. identify polygons west of 0 degrees
#   3. nest and combine polygons into two sets
#   4. add metadata
russia_asia_df <- tibble::tibble(id = 1:length(russia_polys)) |>
  sf::st_set_geometry(russia_polys) |>
  dplyr::mutate(
    bbox = purrr::map(
      .x = geometry,
      .f = sf::st_bbox
    ),
    xmax = purrr::map_dbl(
      .x = bbox,
      .f = ~.x$xmax
    ),
    west = xmax < 0
  ) |>
  tidyr::nest(.by = west) |>
  dplyr::rowwise() |>
  dplyr::mutate(
    geometry = sf::st_combine(data)
  ) |>
  dplyr::ungroup() |>
  dplyr::mutate(
    output = "Yes",
    output_note = NA_character_,
    entity = "RUS",
    entity_note = dplyr::if_else(
      west,
      "Russia (Asian part, past 180-degrees)",
      "Russia (Asian part, before 180-degrees)"
    ),
    merge_group = dplyr::if_else(west, NA_character_, "RUS_RU"),
    su_a3 = dplyr::if_else(west, "RUW", "RUA"),
    subunit = "Russia"
  ) |>
  dplyr::select(su_a3, geometry, output, output_note, entity, entity_note,
                merge_group, subunit)

# reapply geometry (row-wise mutation causes tibble to drop sf class)
russia_asia_df <- russia_asia_df |>
  sf::st_set_geometry(russia_asia_df$geometry)

# get eastern part
russia_asia_east <- russia_asia_df |>
  dplyr::filter(su_a3 == "RUA")

# get western part
russia_asia_west <- russia_asia_df |>
  dplyr::filter(su_a3 == "RUW")


# merge contiguous territories --------------------------------------------

# get merging groups meta
merge_groups <- output_merges |>
  dplyr::filter(!is.na(merge_group) & merge_group != "CYP")

# merge geometries
#   1. get merging groups geometries
#   2. swap out asian russia with set excluding western portion
#   3. merge geometries with sf::st_union()
merge_raw <- ne10_subunits |>
  dplyr::filter(SU_A3 %in% merge_groups$su_a3) |>
  dplyr::select(su_a3 = SU_A3, geometry) |>
  dplyr::left_join(merge_groups, by = "su_a3") |>
  dplyr::filter(su_a3 != "RUA") |>
  rbind(russia_asia_east) |>
  dplyr::select(su_a3, merge_group, geometry) |>
  tidyr::nest(.by = merge_group) |>
  dplyr::rowwise() |>
  dplyr::mutate(
    geometry = sf::st_union(data)
  ) |>
  dplyr::ungroup()

# create output data set
#   1. reset geometry (rowwise mutation causes tibble to drop sf class)
#   2. add metadata
merge_out <- merge_raw |>
  dplyr::select(merge_group) |>
  sf::st_set_geometry(merge_raw$geometry) |>
  dplyr::mutate(
    output = "Yes",
    output_note = NA_character_,
    entity = gsub("_.*", "", merge_group),
    entity_note = NA_character_,
    su_a3 = entity,
    subunit = NA_character_
  ) |>
  dplyr::select(su_a3, geometry, output, output_note, entity, entity_note,
                merge_group, subunit)

# output entities ---------------------------------------------------------

# units to output without merging
singular_units <- output_merges |>
  dplyr::filter(
    output == "Yes" & entity != "MAR" & entity != "ESH" &
      ((output_note != "Small island(s) entity" & output_note != "Microstate") |
         is.na(output_note)) &
      is.na(merge_group)
  )

# singular units geometries
singular_raw <- ne10_subunits |>
  dplyr::filter(SU_A3 %in% singular_units$su_a3) |>
  dplyr::select(su_a3 = SU_A3, geometry) |>
  dplyr::left_join(singular_units, by = "su_a3")

# bind all geometries and combine geometries into singular set for each entity
main_entities <- singular_raw |>
  rbind(esh_out, mar_out, russia_asia_west, merge_out) |>
  tidyr::nest(.by = entity) |>
  dplyr::rowwise() |>
  dplyr::mutate(
    geometry = lwgeom::st_force_polygon_cw(sf::st_combine(data))
  ) |>
  dplyr::ungroup()

# create output
main_entities_out <- main_entities |>
  dplyr::select(cc_iso3c = entity) |>
  sf::st_set_geometry(main_entities$geometry) |>
  dplyr::arrange(cc_iso3c)

.logger("merges and output processing complete", .log)

# delete existing geojson file
if (file.exists("cartography/proc/main_entities_raw.geojson")) {
  file.remove("cartography/proc/main_entities_raw.geojson")
}
if (file.exists("cartography/proc/small_entities_raw.geojson")) {
  file.remove("cartography/proc/small_entities_raw.geojson")
}

# output raw geojson objects
sf::st_write(
  main_entities_out,
  "cartography/proc/main_entities_raw.geojson",
  append = FALSE
)

.logger("WRITE cartography/proc/main_entities_raw.geojson", .log)

# output raw geojson objects
sf::st_write(
  small_entities_out,
  "cartography/proc/small_entities_raw.geojson",
  append = FALSE
)

.logger("WRITE cartography/proc/small_entities_raw.geojson", .log)
