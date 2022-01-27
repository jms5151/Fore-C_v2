# function for creating scenarios
add_scenario_levels <- function(df, scenario_levels, col_name, response_name, scenarios_df){
  for(i in scenario_levels){
    df[, col_name] <- i
    df$Response <- response_name
    df$Response_level <- i
    scenarios_df <- rbind(scenarios_df, df)
  }
  scenarios_df
}
