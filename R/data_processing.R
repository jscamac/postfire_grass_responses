
# Prepares data for model
load_data <- function(file) {
read_csv(file, col_types=cols_only(
  Treatment = col_factor(c("4 Days", "8 Days", "11 Days")),
  Species = "c",
  Tribe = "c",
  Tribe_ID = "i",
  Tillers_cm2 = "d",
  Tillers_postfire = "i",
  Type = col_factor(c("C3","C4")),
  LDMC = "d")) %>%
  mutate(Treatment_ID = as.numeric(Treatment),
         Type_ID = as.numeric(Type)) %>%
    select(Treatment, Treatment_ID, Tribe, Tribe_ID, Species, Tillers_prefire = Tillers_cm2, Tillers_postfire, Type, Type_ID, LDMC)
}

