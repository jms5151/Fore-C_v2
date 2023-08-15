# supplemental table of top genus/species
source("codes/initial_survey_formatting.R")

noaa <- rbind(esd0812[, c('Region', 'Family', 'Genus', 'Taxonname')],
              esd1317[, c('Region', 'Family', 'Genus', 'Taxonname')])
colnames(noaa)[4] <- 'Species'  

guam$Region <- 'Guam'

hicordis$Species <- gsub('_', ' ', hicordis$Species)

x <- bind_rows(list(noaa, guam[,colnames(noaa)], hicordis[,colnames(noaa)])) 

x$Species <- gsub('.*sp$|.*species|.*sp.', 'NA', x$Species)

region_family_totals <- x %>% group_by(Region, Family) %>% summarise(N = length(Family)) %>% na.omit()
region_genus_totals <- x %>% group_by(Region, Genus) %>% summarise(N = length(Genus)) %>% na.omit()

top_genera <- x %>% 
  group_by(Region, Family, Genus) %>%
  count(Genus) %>% 
  top_n(3) %>%
  na.omit() %>%
  left_join(region_family_totals) %>%
  mutate(Genus_prop = round(n/N * 100)) %>%
  filter(Genus_prop > 5)

top_species <- x %>% 
  group_by(Region, Genus) %>%
  count(Species) %>% 
  top_n(3) %>%
  na.omit() %>%
  left_join(region_genus_totals) %>%
  mutate(Species_prop = round(n/N * 100)) %>%
  right_join(top_genera[,c('Region', 'Family', 'Genus', 'Genus_prop')]) %>%
  arrange(desc(Region, Family, Genus_prop, Species_prop))

