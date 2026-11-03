# midterm_utils.R
# Loads PBDB data and applies all cleaning and grouping used across notebooks.

library(dplyr)
library(showtext)
library(ggtext)

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
  mutate(lithology_group = case_when(
    lithology1 %in% c("\"limestone\"", "\"carbonate\"", "chalk", "dolomite", "lime mudstone",
                      "grainstone", "packstone", "wackestone", "rudstone", "floatstone",
                      "framestone", "bafflestone", "bindstone", "\"reef rocks\"") ~ "Carbonate",
    lithology1 %in% c("sandstone", "siltstone", "mudstone", "claystone",
                      "\"shale\"", "conglomerate", "gravel", "\"siliciclastic\"") ~ "Siliciclastic",
    lithology1 %in% c("marl") ~ "Mixed carbonate-siliciclastic",
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

# add fonts
# georgia in windows, libre franklin is close enough hopefully
font_add_google("Libre Franklin", "franklin", regular.wt = 400, bold.wt = 600)
font_add("georgia",
         regular    = "georgia.ttf",
         bold       = "georgiab.ttf",
         italic     = "georgiai.ttf",
         bolditalic = "georgiaz.ttf")
showtext_auto()
showtext_opts(dpi = 96)

main_font <- "franklin"
sub_font  <- "georgia"

# styleguide uses px as unit, ggplot uses pt and linewidth. dpi is 100 so a 650px (standard post in stylegiuide) graphic = 6.5in for easy conversions
dpi <- 100
px_pt <- function(px) px * 72 / dpi
# px -> linewidth
px_lw <- function(px) px * (96 / dpi) / .pt
# px -> size for annotate/geom_text (which is in mm)
px_mm <- function(px) px_pt(px) / .pt

sunlight <- function () {
  main_font = "franklin"
  sub_font = "georgia"
  
  theme_minimal() %+replace%
    theme(
      # backgrounds
      plot.background = element_rect(fill = sunlight_pal$bg,
                                     color = sunlight_pal$line_grey,
                                     linewidth = px_lw(1)),
      panel.background = element_rect(fill = sunlight_pal$bg,
                                      color = NA),
      
      # grids
      panel.grid.major = element_line(color = sunlight_pal$line_white,
                                      linewidth = px_lw(1)),
      panel.grid.minor = element_blank(),
      axis.ticks       = element_blank(),
      axis.line        = element_blank(),
      
      # text
      # title/headers
      # title + subtitle in ONE box bc seperately it was beoing weird
      plot.title = element_textbox_simple(family = main_font,
                                          size = px_pt(20),
                                          color = sunlight_pal$text_main,
                                          fill = sunlight_pal$bg_light,
                                          width = unit(1, "npc"),
                                          padding = margin(22, 22, 22, 22),
                                          margin = margin(0, 0, 22, 0)),
      plot.subtitle = element_blank(),
      # caption
      plot.caption = element_textbox_simple(family = sub_font,
                                            size = px_pt(8),
                                            color = sunlight_pal$text_light,
                                            fill = sunlight_pal$bg_dark,
                                            halign = 0,
                                            padding = margin(8, 12, 8, 12),
                                            margin = margin(t = 22)),
      # axes
      axis.text    = element_text(family = main_font,
                                  face = "bold",
                                  size = px_pt(12),
                                  color = sunlight_pal$text_main),
      axis.text.x  = element_text(margin = margin(t = 5)),
      axis.text.y  = element_text(margin = margin(r = 5),
                                  hjust = 1),
      axis.title   = element_text(family = main_font,
                                  size = px_pt(12),
                                  color = sunlight_pal$text_main),
      axis.title.x = element_text(margin = margin(t = 22)),
      axis.title.y = element_text(margin = margin(r = 22),
                                  angle = 90),
      
      plot.title.position   = "plot",
      plot.caption.position = "plot",
      plot.margin = margin(22, 22, 0, 22)
    )
}
