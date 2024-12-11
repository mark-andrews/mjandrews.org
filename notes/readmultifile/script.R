library(tidyverse)

country <- c('england', 'france', 'germany', 'spain', 'italy',
             'austria', 'norway', 'sweden', 'scotland', 'ireland',
             'belgium', 'netherlands')

N <- 100

for (i in seq_along(country)) {
  
  filename <- paste0(country[i], '.csv')
  
  tibble(gender = sample(c('male', 'female'),
                         size = N,
                         replace = T),
         height = round(167 + ifelse(gender == 'male', 1, 0) * 10 + rnorm(N, mean = 0, sd = 10)),
         weight = round(-85 + 0.96 * height + rnorm(N, mean = 0, sd = 12))
  ) %>% write_csv(fs::path_join(c('country_data', filename)))
                         
}
