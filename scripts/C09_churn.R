churn_df <- df_7_tic_clean_final %>%
  group_by(ID_CLI) %>%
  summarise(NUM_PURCHASES = n(),
            MAX_DATE = max(TIC_DATE),
            MIN_DATE = min(TIC_DATE)) %>%
  mutate(AVG_PURCH_DAYS = as.numeric(difftime(today(), MIN_DATE, unit="days")/NUM_PURCHASES)) %>% # this is the actual fidelity score
  ungroup() %>%
  as.data.frame()
churn_df %>% head()

timescale <- floor(quantile(churn_df$AVG_PURCH_DAYS, 0.9)) #90% of the customers are not churners

churn_df <- churn_df %>%
  mutate(CHURNER = factor(floor(AVG_PURCH_DAYS / timescale)))
churn_df %>% summary()