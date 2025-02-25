library(tidyverse)
library(yaml)
library(readxl)

# The data read in from the Rds is a list of lists of lists of strings.
# Those strings are supposed to be yaml strings, although some are ill-formed.
# We this lists of lists of lists to be a data frame, ignored the mangled/ill-formed responses.
# We also remove the numerical ratings that are not '0', '1', '2', or '1,2' (or '1, 2', which we merge with '1,2').

# try to parse the string; return NA if it fails
# we are using a YAML parser here because the json parser fails more often
# This is often because the JSON is ill-formed in some way, e.g. single instead of 
# double quotes.
# Because YAML and JSON are similar in some ways, the YAML parser will succeed 
# sometimes where the JSON fails.
yaml_parse_or_na <- function(x) {
  tryCatch(
    yaml.load(x),
    error = function(e) NA
  )
}

llm_results <- readRDS('llama3.3_2024_12_30.Rds') |> 
  map(~set_names(., nm = str_c('iteration_', seq(length(.))))) |> 
  unlist(recursive = FALSE) |> 
  map(~set_names(., nm = str_c('response_', seq(length(.))))) |> 
  unlist() |> 
  enframe() |> 
  mutate(value = map(value, yaml_parse_or_na)) |>
  # remove the ill-formed responses
  filter(map_lgl(value, ~length(.) == 2)) |> 
  filter(map_lgl(value, ~all(names(.) == c('reasoning', 'answer')))) |> 
  # unnest wide the yaml parsed string, parsed into 'reasoning and 'answer'
  unnest_wider(col = value) |> 
  mutate(answer = as.character(answer)) |> 
  separate_wider_delim(
    cols  = name,
    delim = ".", 
    # We only keep "task", "iter_num", and "resp_num";
    # `NA` means "skip/ignore" that part.
    names = c('topic', 'iteration', 'response')
  ) |> 
  mutate(iteration = str_remove(iteration, 'iteration_'),
         response = str_remove(response, 'response_')) |> 
  mutate(across(c(iteration, response), as.numeric)) |> 
  filter(answer %in% c('0', '1', '2', '1,2', '1, 2')) |> 
  mutate(answer = case_when(
    answer == '1, 2' ~ '1,2',
    TRUE ~ answer
  )) |> 
  select(topic, iteration, item = response, llm_rating = answer, reasoning)

# proportion of LLM responses that are usable; total is 4 (topic) by 10 (iterations) of 409 item per each topic
proportion_of_usable_responses <- nrow(llm_results) / (4 * 10 * 409)

# Evaluation -------------------------------------------------------------

fname <- "study_1_qualitative_coding_disc_con_xlsx"
topics <- c("self-other", "harm", "stigma", "miss") 
topics <- topics |> set_names(topics)

# For each of the items in each of the topics, get the rating by each of the two human raters
# A data frame with four columns: topic, item, human_rater, human_rating
data_df <- map(topics, ~ read_excel(fname, sheet = .) |>
  rowid_to_column(var = "item") |>
  select(item, wg = WG, ra = RA) |>
  mutate(across(c(wg, ra), as.character))) |>
  bind_rows(.id = "topic") |>
  pivot_longer(cols = c(ra, wg), names_to = "human_rater", values_to = "human_rating") |>
  mutate(human_rating = case_when(
    human_rating == "1 and 2" ~ "1,2",
    TRUE ~ human_rating
  ))

# For each item in each topic on each iteration is the LLM rating equal to
# either of the two human raters' ratings
llm_accuracy <- data_df |>
  left_join(llm_results, by = c("topic", "item"), relationship = "many-to-many") |> 
  select(topic, item, iteration, human_rater, human_rating, llm_rating) |> 
  mutate(accuracy = human_rating == llm_rating) |>
  drop_na() 


# For each item in each topic, are the two raters' rating identical
inter_rater_accuracy <- data_df |>
  pivot_wider(names_from = human_rater, values_from = human_rating) |>
  mutate(accuracy = ra == wg)
