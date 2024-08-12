# # data source: https://www.kaggle.com/datasets/rmisra/news-category-dataset?resource=download
# data <- jsonlite::stream_in(file("./data/News_Category_Dataset_v3.jsonl"))
# data <- tibble::as_tibble(data)
# data$date <- lubridate::ymd(data$date)
# data$id <- 1:nrow(data)
# saveRDS(data, "data/data.rds")

source("scroll.R")
