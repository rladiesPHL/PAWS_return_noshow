library(tidyverse)
library(lubridate)
library(rms)

#load in Animal data and recode/rename as necessary
Animal <- read_csv("PetPoint_byAnimal.csv") %>%
  rename(Animal.ID = Animal..) %>%
  mutate(
    Intake.Date = as.Date(parse_date_time(Intake.Date, "mdY HMS")),
    Outcome.Date = as.Date(parse_date_time(Outcome.Date, "mdY HMS")),
    Date.of.Birth = mdy(Date.of.Birth)
  ) %>%
  mutate(Returned.Intake = Intake.Subtype == "Returned Adoption") %>%
  mutate(Sick = str_detect(Intake.Condition, "Sick")) %>%
  mutate(Injured = str_detect(Intake.Condition, "Injured")) %>%
  mutate("Young" = Intake.Condition == "Less Than 7 Weeks") %>%
  mutate(Intake.Site2 = case_when(Intake.Site %in% c("Grant Avenue", "Grays Ferry Avenue", "PAWS Foster Program") ~ Intake.Site, TRUE ~ "PAWS Other")) %>%
  mutate(Female.a = Gender == "Female") %>%
  mutate(Month = month.abb[month(Outcome.Date)]) %>%
  group_by(Animal.ID) %>%
  arrange(Intake.Date) %>%
  mutate(Returned.From = case_when(lead(Returned.Intake) == TRUE ~ TRUE, TRUE ~ FALSE)) %>%
  dplyr::select(Animal.ID, Species, Gender, Female.a, Altered, LOS, Intake.Date, Outcome.Date, Month, Intake.Type, Intake.Subtype, Intake.Site, Intake.Site2, Intake.Condition, LOS, Outcome.Age.in.Months, Returned.Intake, Returned.From, Sick, Injured, Young) %>%
  filter(year(Intake.Date) >= 2017)

describe(Animal)



#load in Person data and recode/rename as necessary
Person <- read_csv("PetPoint_byPerson.csv") %>%
  mutate(
    Outcome.Date = as.Date(parse_date_time(Operation.Date, "mdY HM"))
  ) %>%
  mutate(outside_philly = City != "Philadelphia") %>%
  dplyr::select(Person.ID, Animal.ID, Gender, City, City.Alias, outside_philly, Postal.Code, Sex, Species, Spayed.Neutered, Age.As.Months, Outcome.Date, Outcome.Date)

describe(Person)


#Link up
join_tbl <- inner_join(Animal, Person, by = c("Animal.ID", "Outcome.Date"), suffix = c(".a", ".p")) %>%
  arrange(Animal.ID, Intake.Date, Outcome.Date) %>%
  distinct()

#Set seed for reproducible results
set.seed(290120)


#validate provides numerical checks for overfitting and allows assessment of whether parameters are kept.
#calibrate allows for visual check on model performance

frm_all <- Returned.From ~ (Species.a + Gender.p) * (Female.a + Sick + Injured + outside_philly + Month + Young) + Species.a * Gender.p + rcs(LOS) + rcs(Outcome.Age.in.Months) + Species.a %ia% rcs(LOS) + Species.a %ia% rcs(Outcome.Age.in.Months)
lrm_all <- lrm(frm_all, join_tbl, x = TRUE, y = TRUE)
val_all <- validate(lrm_all, bw = TRUE, B = 200)
cal_all <- calibrate(lrm_all, B = 200)
summary(attr(val_all, "kept"))

frm_cut_interact <- Returned.From ~ Species.a + Gender.p + Female.a + Sick + Injured + outside_philly + Month + Young + rcs(LOS) + rcs(Outcome.Age.in.Months, 4) + Species.a %ia% rcs(LOS) + Species.a %ia% rcs(Outcome.Age.in.Months, 4)
lrm_cut_interact <- lrm(frm_cut_interact, join_tbl, x = TRUE, y = TRUE)
val_cut_interact <- validate(lrm_cut_interact, bw = TRUE, B = 200)
cal_cut_interact <- calibrate(lrm_cut_interact, B = 200)
summary(attr(val_cut_interact, "kept"))

frm_limit_25 <- Returned.From ~ Species.a + Gender.p + Sick + outside_philly + Month + rcs(LOS) + rcs(Outcome.Age.in.Months, 4) + Species.a %ia% rcs(LOS) + Species.a %ia% rcs(Outcome.Age.in.Months, 4)
lrm_limit_25 <- lrm(frm_limit_25, join_tbl, x = TRUE, y = TRUE)
val_limit_25 <- validate(lrm_limit_25, bw = TRUE, B = 200)
cal_limit_25 <- calibrate(lrm_limit_25, B = 200)
summary(attr(val_limit_25, "kept"))

anova(lrm_limit_25)

frm_limit_NL <- Returned.From ~ Species.a + Gender.p + Sick + outside_philly + Month + rcs(LOS) + Outcome.Age.in.Months + Species.a %ia% rcs(LOS) + Species.a * Outcome.Age.in.Months
lrm_limit_NL <- lrm(frm_limit_NL, join_tbl, x = TRUE, y = TRUE)
val_limit_NL <- validate(lrm_limit_NL, bw = TRUE, B = 200)
cal_limit_NL <- calibrate(lrm_limit_NL, B = 200)
summary(attr(val_limit_NL, "kept"))

frm_limit_final <- Returned.From ~ Species.a + Gender.p + Sick + LOS + Outcome.Age.in.Months + Species.a * Outcome.Age.in.Months
lrm_limit_final <- lrm(frm_limit_final, join_tbl, x = TRUE, y = TRUE)
val_limit_final <- validate(lrm_limit_final, bw = TRUE, B = 200)
cal_limit_final <- calibrate(lrm_limit_final, B = 200)
summary(attr(val_limit_final, "kept"))

dd <- datadist(join_tbl)
options(datadist = "dd")
nomogram(lrm_limit_final, fun = plogis)


ggplot(join_tbl, aes(x = Outcome.Age.in.Months, y = as.numeric(Returned.From), color = Species.a)) + geom_smooth(method = "glm", method.args = list(family = "binomial"))
ggplot(join_tbl, aes(x = LOS, y = as.numeric(Returned.From), color = Species.a)) + geom_smooth(method = "glm", method.args = list(family = "binomial"))
ggplot(join_tbl, aes(x = LOS, y = as.numeric(Returned.From))) + geom_smooth(method = "glm", method.args = list(family = "binomial"))






drop1(glm(frm, final_table, family = "binomial"))
drop1(glm(frm2, final_table, family = "binomial"))
drop1(glm(frm3, final_table, family = "binomial"))

frm4 <- Returned.From ~ Species.a + rcs(Outcome.Age.in.Months) + Species.a %ia% rcs(Outcome.Age.in.Months) + Species.a * injured + female.a + Gender.p + rcs(LOS) + sick + injured + rcs(Outcome.Age.in.Months) + outside_philly + month
frm5 <- Returned.From ~ Species.a + rcs(Outcome.Age.in.Months) + Species.a * injured + LOS + sick

lrm5 <- lrm(frm5, final_table1, x = TRUE, y = TRUE)

ggplot(join_tbl, aes(x = Outcome.Age.in.Months, y = as.numeric(Returned.From), color = Species.a)) + geom_smooth(method = "glm", method.args = list(family = "binomial"))

ggplot(join_tbl, aes(x = LOS, y = as.numeric(Returned.From))) + geom_smooth(method = "glm", method.args = list(family = "binomial"))