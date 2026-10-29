df <- readr::read_csv(here::here("data", "pbdb_data.csv"))

df <- df |>
  select(occurrence_no, 
         collection_no, 
         identified_name, 
         accepted_name, 
         phylum, 
         class, 
         genus, 
         early_interval, 
         max_ma, 
         min_ma, 
         formation, 
         lithology1, 
         lithology2, 
         lithdescript, 
         environment)

microbial_phylums <- df |>
  filter(phylum %in% 
           c("Cyanobacteria",        # photosynthetic bacteria
             "Chlorophyta",          # green algae
             "Foraminifera",         # single celled protists with shells
             "Rhodophyta",           # red algae
             "Dinozoa",              # more single celled algae basically
             "Radiolaria",           # single celled protists with silica skeletons (cool, right?)
             "Chytridiomycota"))    # single celled fungi

lithology <- lithology |>
  mutate(lithology1 = case_when(
    lithology1 %in% c("\"limestone\"", "\"carbonate\"", "marl", "chalk", "dolomite", "lime mudstone", "grainstone", "packstone", "wackestone", "rudstone", "floatstone", "framestone", "bafflestone", "bindstone", "\"reef rocks\"") ~ "carbonate",
    lithology1 %in% c("sandstone", "siltstone", "mudstone", "claystone", "\"shale\"", "conglomerate", "gravel", "\"siliciclastic\"") ~ "siliciclastic",
    lithology1 %in% c("marl") ~ "mixed carbonate-silicastic",
    lithology1 %in% c("chert", "phosphorite") ~ "biogenic/chemical deposits",
    lithology1 == "not reported" | is.na(lithology1) ~ "not reported",
    .default = "other"
  )) |> 
  count(lithology1) |>
  mutate(share = n / sum(n))
