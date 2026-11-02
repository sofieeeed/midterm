# midterm_utils.R
# Loads PBDB data and applies all cleaning and grouping used across notebooks.

library(dplyr)

df <- readr::read_csv(here::here("data", "pbdb_data.csv"), show_col_types = FALSE)

df <- df |>
  select(occurrence_no, collection_no, identified_name, accepted_name,
         phylum, class, genus, early_interval, max_ma, min_ma,
         formation, lithology1, lithology2, lithdescript, environment)

# keep microbial life and simple algae
microbial_phylums <- df |>
  filter(phylum %in% c("Cyanobacteria",   # photosynthetic bacteria
                       "Chlorophyta",     # green algae
                       "Foraminifera",    # single celled protists with shells
                       "Rhodophyta",      # red algae
                       "Radiolaria"))     # single celled protists with silica skeletons

# lithology grouping
pbdb_clean <- microbial_phylums |>
  mutate(lithology1 = case_when(
    lithology1 %in% c("\"limestone\"", "\"carbonate\"", "chalk", "dolomite", "lime mudstone",
                      "grainstone", "packstone", "wackestone", "rudstone", "floatstone",
                      "framestone", "bafflestone", "bindstone", "\"reef rocks\"") ~ "Carbonate",
    lithology1 %in% c("sandstone", "siltstone", "mudstone", "claystone",
                      "\"shale\"", "conglomerate", "gravel", "\"siliciclastic\"") ~ "Siliciclastic",
    lithology1 %in% c("marl") ~ "mixed carbonate-siliciclastic",
    lithology1 %in% c("chert", "phosphorite") ~ "Biogenic/chemical deposits",
    lithology1 == "not reported" | is.na(lithology1) ~ "Not reported",
    .default = "other"
  )) |>
  # environment grouping based on: https://paleobiodb.org/public/tips/environtips.html
  mutate(env_group = case_when(
    environment %in% c("peritidal", "lagoonal", "paralic indet.", "delta front",
                       "prodelta", "deltaic indet.", "foreshore", "shoreface",
                       "transition zone/lower shoreface", "coastal indet.",
                       "marginal marine indet.") ~ "Coastal/marginal",
    environment %in% c("open shallow subtidal", "lagoonal/restricted shallow subtidal",
                       "shallow subtidal indet.", "sand shoal") ~ "Shallow subtidal",
    environment %in% c("reef, buildup or bioherm", "intrashelf/intraplatform reef",
                       "platform/shelf-margin reef", "Slope/ramp reef",
                       "perireef or subreef") ~ "Reef",
    environment %in% c("deep subtidal ramp", "deep subtidal shelf", "deep subtidal indet.",
                       "offshore", "offshore ramp", "offshore shelf",
                       "offshore indet.") ~ "Deep subtidal/offshore",
    environment %in% c("slope", "submarine fan", "basinal (carbonate)",
                       "basinal (siliciclastic)", "basinal (siliceous)",
                       "deep-water indet.") ~ "Deep water",
    environment %in% c("terrestrial indet.", "glacial") ~ "Non-marine",
    .default = "Unspecified"
  )) |>
  # midpoint age; note: hides the full age range, some ranges are huge
  mutate(est_avg_age = (max_ma + min_ma) / 2)

# color palette
sunlight_pal <- list(
  bg = "#EFECEA",
  bg_light = "#F5F3F2",
  bg_dark = "#E5E2E0",       # added back, the caption box needs this
  text_main = "#635F5D",
  text_light = "#8E8883",
  line_white = "#FFFFFF",
  line_grey = "#C0C0BB",
  main_yellow = "#E3BA22",
  main_orange = "#E6842A",
  main_blue = "#137B80",
  main_purp = "#8E6C8A",
  money = "#5C8100"
)
