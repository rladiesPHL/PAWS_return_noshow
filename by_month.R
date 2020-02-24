data$Intake.Date.Month <- paste(year(data$Intake.Date), month(data$Intake.Date), sep=".")
data <- filter(data, Intake.Date > "2017-12-31" & Intake.Date < "2020-01-01")
df <- as.data.frame(table(data$Intake.Date.Month, data$Intake.Type))
df <- rename(df, "Year.Month" = "Var1", "Intake.Type" = "Var2")

df$Year.Month <- factor(df$Year.Month, levels = c("2018.1", "2018.2", "2018.3", "2018.4", "2018.5", "2018.6", "2018.7", "2018.8", "2018.9", "2018.10", "2018.11", "2018.12",
                                                  "2019.1", "2019.2", "2019.3", "2019.4", "2019.5", "2019.6", "2019.7", "2019.8", "2019.9", "2019.10", "2019.11", "2019.12"))

ggplot(df, aes(x=Year.Month, y=Freq, color = Intake.Type)) + geom_point() + ylab("Number of Animals")
