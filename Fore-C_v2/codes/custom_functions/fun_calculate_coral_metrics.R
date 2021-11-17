# function to calculate colony size metrics

# source aggregate_point_values() function
source("codes/custom_functions/fun_aggregate_point_values_within_pixels.R")

calc_colony_vals <- function(df, fam, colony_metric, col_fun){
  x_spread <- df %>% spread(Family, colony_metric)
  dz <- unique(x_spread)
  aggregate_point_values(df = dz,
                         x = fam,
                         fn = col_fun)
}


