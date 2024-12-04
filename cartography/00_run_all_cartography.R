

callr::rscript("cartography/1_get_src_ne.R")
callr::rscript("cartography/2_proc_merges_output.R")
callr::rscript("cartography/3_proc_simplify.R")

cat(
  "R cartography processing complete, now finalise via the command line:",
  paste0("$ cd ", getwd(),"/cartography"),
  "$ geo2topo -q 1e5 -o world_lowres.topojson countries=world_lowres.geojson",
  sep = "\n"
)
