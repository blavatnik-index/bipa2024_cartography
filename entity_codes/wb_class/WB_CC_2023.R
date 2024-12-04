
# read income classifications
wbcc_raw <- readxl::read_excel(
  "entity_codes/wb_class/CLASS.xlsx", sheet = "List of economies"
)

# process income classifications
wbcc_proc <- wbcc_raw |>
  janitor::clean_names() |>
  # remove economies without classification (Venezuela)
  tidyr::drop_na(income_group) |>
  # convert country codes, create numeric version for ordering,
  # set reference year
  dplyr::mutate(
    cc_iso3c = dplyr::if_else(code == "XKX", "XKK", code),
    income_group_num = dplyr::case_match(
      income_group,
      "High income" ~ 4, "Upper middle income" ~ 3,
      "Lower middle income" ~ 2, "Low income" ~ 1
    ),
    ref_year = 2023
  )|>
  dplyr::select(cc_iso3c, ref_year, income_group, income_group_num) |>
  # remove channel islands group and replace with individual rows for each
  # geographic entry
  dplyr::filter(cc_iso3c != "CHI") |>
  dplyr::add_row(
    cc_iso3c = c("JEY", "GGY"),
    ref_year = 2023,
    income_group = rep("High income", 2),
    income_group_num = rep(4, 2),
  ) |>
  dplyr::arrange(cc_iso3c)


# write output dataset - wide format object do not check conformity
readr::write_excel_csv(wbcc_proc, "entity_codes/entity_wb_classification23.csv")
