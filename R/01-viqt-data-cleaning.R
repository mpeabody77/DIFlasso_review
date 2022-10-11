library(tidyverse)

# data files ####
viqt_raw <-
  read_delim(file = '../raw-data/VIQT_data.csv') %>%
  mutate(row_id = row_number())
viqt_ans <-
  read_csv(file = '../raw-data/VIQT_answers.csv') %>%
  select(-words)

viqt_correct <-
  viqt_raw %>%
  select(row_id, score_right)
viqt_demo <-
  viqt_raw %>%
  select(row_id, education, urban, gender, engnat, age, country)
# reshape and score ####
viqt_scored <-
  viqt_raw %>%
  select(row_id, contains("Q")) %>%
  pivot_longer(-row_id) %>%
  rename(item = name) %>%
  left_join(viqt_ans) %>%
  mutate(graded = ifelse(value == ans, 1, 0)) %>%
  select(row_id, item, graded) %>%
  pivot_wider(names_from = item, values_from = graded)

# check that the new scored values match score_right ####
viqt_scored %>%
  add_column(
    total_score = {
      viqt_scored %>%
      select(-row_id) %>%
      rowSums() 
    }
  ) %>% 
  left_join(viqt_correct) %>%
  filter(total_score != score_right) # zero, all total scores match raw data

# rejoin demo data to scored data ####
viqt_scored_demo <-
  viqt_scored %>%
  left_join(viqt_demo)
  
# save data ####
viqt_scored_demo %>%
  write_csv(file = "../clean-data/viqt_clean.csv")
