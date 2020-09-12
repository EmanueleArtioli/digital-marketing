## Active Customers

actives <- df_1_cli_fid_clean[df_1_cli_fid_clean$LAST_STATUS_FID == 1, "ID_CLI"]

##  Customer Base Grouping

actives.grouped <- df_7_tic_clean_final[df_7_tic_clean_final$ID_CLI %in% actives, ] %>% group_by(ID_CLI) %>% summarise(
  RECENCY <- max(TIC_DATETIME),
  FREQUENCY <- n(),
  MONETARY_VALUE <- sum(IMPORTO_LORDO),
  DISCOUNT <- sum(SCONTO)
)

rfm <- data.frame("ID_CLI" = actives.grouped$ID_CLI, 
                  "recency" = actives.grouped$`RECENCY <- max(TIC_DATETIME)`, 
                  "frequency" = actives.grouped$`FREQUENCY <- n()`, 
                  "mon.value" = actives.grouped$`MONETARY_VALUE <- sum(IMPORTO_LORDO)` - actives.grouped$`DISCOUNT <- sum(SCONTO)`)
summary(rfm)

subranges <- function(x, stop1, stop2) {
  if(x < stop1) return("LOW")
  if(x < stop2) return("MEDIUM")
  return("HIGH")
}
rfm$recency <- apply(as.matrix(rfm$recency), 1, subranges,  # setting as.matrix() to avoid compiling error
                     stop1 = quantile(rfm$recency, .33, type = 1),
                     stop2 = quantile(rfm$recency, .67, type = 1)) %>% factor(levels = c("LOW", "MEDIUM", "HIGH"), ordered = TRUE) # high recency is desirable
rfm$frequency <- apply(as.matrix(rfm$frequency), 1, subranges,
                       stop1 = quantile(rfm$frequency, .33, type = 1),
                       stop2 = quantile(rfm$frequency, .67, type = 1)) %>% factor(levels = c("LOW", "MEDIUM", "HIGH"), ordered = TRUE)
rfm$mon.value <- apply(as.matrix(rfm$mon.value), 1, subranges,
                       stop1 = quantile(rfm$mon.value, .33, type = 1),
                       stop2 = quantile(rfm$mon.value, .67, type = 1)) %>% factor(levels = c("LOW", "MEDIUM", "HIGH"), ordered = TRUE)

loyalty <- function(x) {
  x <- as.matrix(x)
  if(x[2] == "HIGH") { # setting x as a matrix to avoid "Error in if (x$frequency == "HIGH") { : argument is of length zero"
    if(x[3] != "LOW") return("TOP")
    else return("LEAVING-TOP")
  }
  if(x[2] == "MEDIUM") {
    if(x[3] != "LOW") return("ENGAGED")
    else return("LEAVING")
  }
  if(x[3] != "LOW") return("ONE-TIMER")
  else return("LEAVING")
}

rfm$loyalty <- apply(rfm, 1, loyalty) %>% factor(levels = c("ONE-TIMER", "LEAVING", "ENGAGED", "LEAVING-TOP", "TOP"), ordered = TRUE)

rfm.class <- function(x) {
  x <- as.matrix(x)
  if(x[4] == "HIGH") {
    if(x[5] == "TOP") return("DIAMOND")
    if(x[5] == "LEAVING-TOP") return("GOLD")
    if(x[5] == "ENGAGED") return("SILVER")
    if(x[5] == "LEAVING") return("BRONZE")
    else return("COPPER")
  }
  if(x[4] == "MEDIUM") {
    if(x[5] == "TOP") return("GOLD")
    if(x[5] == "LEAVING-TOP") return("SILVER")
    if(x[5] == "ENGAGED") return("BRONZE")
    if(x[5] == "LEAVING") return("COPPER")
    else return("TIN")
  }
  if(x[5] == "TOP") return("SILVER")
  if(x[5] == "LEAVING-TOP") return("BRONZE")
  if(x[5] == "ENGAGED") return("COPPER")
  if(x[5] == "LEAVING") return("TIN")
  else return("CHEAP")
}

rfm$class <- apply(rfm, 1, rfm.class) %>% factor(levels = c("CHEAP", "TIN", "COPPER", "BRONZE", "SILVER", "GOLD", "DIAMOND"), ordered = TRUE)

summary(rfm)