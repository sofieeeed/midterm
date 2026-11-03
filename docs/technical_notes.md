---
title: Technical notes
author: Sofia Dominesey
date: 2026-10-01
---

## Data
- Source: Paleobiology Database (PBDB) occurrence data via the download generator
  (https://paleobiodb.org/classic/displayDownloadGenerator).
    - Downloaded: October 20, 2026, via the PBDB download generator : https://paleobiodb.org/classic/displayDownloadGenerator 
    - Time interval: Archean through Cambrian
    - Records: 54,984 occurrences
    - Parameters: [1] "occurrence_no"    "record_type"      "reid_no"          "flags"            "collection_no"    "identified_name" 
 [7] "identified_rank"  "identified_no"    "difference"       "accepted_name"    "accepted_rank"    "accepted_no"     
[13] "early_interval"   "late_interval"    "max_ma"           "min_ma"           "reference_no"     "phylum"          
[19] "class"            "order"            "family"           "genus"            "abund_value"      "abund_unit"      
[25] "cc"               "state"            "county"           "latlng_basis"     "latlng_precision" "altitude_value"  
[31] "altitude_unit"    "geogscale"        "geogcomments"     "formation"        "geological_group" "member"          
[37] "lithdescript"     "lithology1"       "lithification1"   "minor_lithology1" "lithology2"       "lithification2"  
[43] "minor_lithology2" "environment"      "tectonic_setting" "geology_comments"
- Raw file: 54,984 occurrences, 46 columns.
- saved as pbdb_data.csv

--
## Code
- For the final draft, all the filtered code lives in the utils folder under "midterm_utils.R"
    - Cleans up pbdb.csv to pbdb_clean
        - Phylum filter 
            - Kept single celled microorganisms and simple algae (Cyanobacteria, Chlorophyta, Rhodophyta,
              Foraminifera, Radiolaria) --> 1848 rows
              - Dropped animal phyla and those with unicellular ones with too few occurrences
              - Did not include uncertain/unidentified/NA
        - Lithology grouping
            - Used lithology1 column only (lithology2 has barely any data)
            - Grouped as:  Grouped into: Carbonate, Siliciclastic, Biogenic/chemical deposits,
              Mixed carbonate/siliciclastic, Not reported, Other.
            - Grouping source: https://www.biorxiv.org/content/10.64898/2026.10.15.759295v1
        - Environment grouping
            - Grouped as: Coastal/marginal, Shallow subtidal, Reef, Deep subtidal/offshore, 
              Deep water, Non-marine, Unspecified
            - Grouping source: https://paleobiodb.org/public/tips/environtips.html
        - Age
            - `est_avg_age` = midpoint of `max_ma` and `min_ma`. This hides the full range unfortunately 
              but is a decent marker in my opinion
    - Includes sunlight theme and palette functions that I created for a previous lab
--
## Potential improvements / possible next steps
- PBDB recognizes it isn't a comprehensive record. 
- Also barely any lake data in this one, and lakes are primarily what I'm interested in on Mars
- Next time, I'd probably look specifically for a lake fossil database or microfossil database

