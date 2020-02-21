library(tidyverse)
library(lubridate)
library(rms)

# load in Animal data and recode/rename as necessary
Animal <- read_csv("PetPoint_byAnimal.csv") 

Agent_Tally <- Animal %>% group_by(Outcome.By) %>% summarise(n_agent=n())

 Animal <- Animal %>% 
   inner_join(Agent_Tally) %>% 
   rename(Animal.ID = Animal..) %>%
   mutate(
    Intake.Date = as.Date(parse_date_time(Intake.Date, "mdY HMS")),
    Outcome.Date = as.Date(parse_date_time(Outcome.Date, "mdY HMS")),
    Date.of.Birth = mdy(Date.of.Birth)
  ) %>%
  mutate(Intake.Age=as.numeric(Intake.Date-Date.of.Birth)/30) %>%
  mutate(Outcome.Age=as.numeric(Outcome.Date-Date.of.Birth)/30) %>%
  mutate(Returned.Intake = Intake.Subtype == "Returned Adoption") %>%
  mutate(Sick = str_detect(Intake.Condition, "Sick")) %>%
  mutate(Injured = str_detect(Intake.Condition, "Injured")) %>%
  mutate(Young = Intake.Condition == "Less Than 7 Weeks") %>%
  mutate(Domestic = str_detect(Primary.Breed, "omestic")) %>%
  mutate(Surrender = str_detect(Intake.Type, "urrender")) %>%
mutate(Intake.Site2 = case_when(Intake.Site %in% c("Grant Avenue", "Grays Ferry Avenue", "PAWS Foster Program") ~ Intake.Site, TRUE ~ "PAWS Other")) %>%
  mutate(Female.a = Gender == "Female") %>%
  mutate(Month = month.abb[month(Outcome.Date)]) %>%
  group_by(Animal.ID) %>%
  arrange(Intake.Date) %>%
  mutate(Returned.From = case_when(lead(Returned.Intake) == TRUE ~ TRUE, TRUE ~ FALSE)) %>%
  dplyr::select(Animal.ID, Species, Gender, Female.a, Intake.Age,Outcome.Age,Altered, LOS, Intake.Date, Outcome.Date, Month, Intake.Type, Intake.Subtype, Intake.Site, Intake.Site2, Intake.Condition, LOS, Outcome.Age.in.Months, Returned.Intake, Returned.From, Sick, Injured, Young, Domestic, Surrender,n_agent) %>%
  filter(year(Intake.Date) >= 2017)

describe(Animal)


Mean_Zip <- read_csv("PAWS_modeling_MGM/PAWS_return_noshow/Mean_Zip.csv")

# load in Person data and recode/rename as necessary
Person <- read_csv("PetPoint_byPerson.csv") %>%
  mutate(
    Outcome.Date = as.Date(parse_date_time(Operation.Date, "mdY HM")),
    Zip=as.numeric(Postal.Code),
    outside_philly =City !="Philadelphia" ) %>%
  left_join(Mean_Zip) %>%
  dplyr::select(Person.ID, Animal.ID, Gender, outside_philly, Median, Sex, Species, Spayed.Neutered, Age.As.Months, Outcome.Date, Outcome.Date)

describe(Person)


# Link up
join_tbl <- inner_join(Animal, Person, by = c("Animal.ID", "Outcome.Date"), suffix = c(".a", ".p")) %>%
  arrange(Animal.ID, Intake.Date, Outcome.Date) %>%
  distinct()

# Set seed for reproducible results
set.seed(290120)


# validate provides numerical checks for overfitting and allows assessment of whether parameters are kept.
# calibrate allows for visual check on model performance


frm_linear <- Returned.From ~ (Species.a + Gender.p + Intake.Site2)^2 +
  (Species.a + Gender.p + Intake.Site2) * (Female.a + Sick + Injured + outside_philly + Month + Young +LOS  + Outcome.Age.in.Months + Domestic+Surrender +Median+ n_agent) - Species.a:Domestic - Intake.Site2:Domestic - Intake.Site2:Injured - Intake.Site2:Surrender - Intake.Site2:Young - Species.a:Young

lrm_linear <- lrm(frm_linear,data=join_tbl, x = TRUE, y = TRUE) 
anova(lrm_linear)
val_linear <- validate(lrm_linear,B=200,bw=TRUE)
kept_linear <-tibble(var=colnames(attr(val_linear,"kept")),kept=apply(attr(val_linear, "kept"),2,mean)) %>% arrange(desc(kept))


frm_linear2 <- Returned.From ~  Intake.Site2+ (Species.a + Gender.p)   * (Female.a + Sick + Injured + outside_philly + Month + Young +LOS  + Outcome.Age.in.Months + Domestic+Surrender +Median+ n_agent) - Species.a:Domestic - Species.a:Young
lrm_linear2 <- lrm(frm_linear2,data=join_tbl, x = TRUE, y = TRUE) 
anova(lrm_linear2)
val_linear2 <- validate(lrm_linear2,B=200,bw=TRUE)
kept_linear2 <-tibble(var=colnames(attr(val_linear2,"kept")),kept=apply(attr(val_linear2, "kept"),2,mean)) %>% arrange(desc(kept))

frm_linear3 <- Returned.From ~  Intake.Site2+ (Species.a + Gender.p)   * (Female.a + Sick + Injured + outside_philly + Young +LOS  + Outcome.Age.in.Months + Domestic+Surrender +Median+ n_agent) - Species.a:Domestic - Species.a:Young
lrm_linear3 <- lrm(frm_linear3,data=join_tbl, x = TRUE, y = TRUE) 
anova(lrm_linear3)
val_linear3 <- validate(lrm_linear3,B=200,bw=TRUE)
kept_linear3 <-tibble(var=colnames(attr(val_linear3,"kept")),kept=apply(attr(val_linear3, "kept"),2,mean)) %>% arrange(desc(kept))

frm_linear4<- Returned.From ~  Gender.p*(LOS+Sick) + Species.a*(Injured+Outcome.Age.in.Months + Median)+Domestic+n_agent+Intake.Site2 +outside_philly
lrm_linear4 <- lrm(frm_linear4,data=join_tbl, x = TRUE, y = TRUE) 

pentrace(lrm_linear4,20:50) #turns out to be 37
anova(update(lrm_linear4,penalty=37))

lrm_final <- lrm(Returned.From~Gender.p+LOS+Sick+ Domestic + n_agent+ outside_philly+ Species.a*(Injured+Outcome.Age.in.Months+I(Median/1000.0)),data=join_tbl,penalty=37,x=TRUE,y=TRUE)
val_final <-validate(lrm_final,B=200)
cal_final <- calibrate(lrm_final,B=200)

join_tbl$n_agent0<-join_tbl$n_agent-mean(join_tbl$n_agent,na.rm=TRUE)
join_tbl$Median0<-join_tbl$Median-mean(join_tbl$Median,na.rm=TRUE)
join_tbl$Age0<-join_tbl$Outcome.Age.in.Months-mean(join_tbl$Outcome.Age.in.Months,na.rm=TRUE)
join_tbl$LOS0<-join_tbl$LOS-mean(join_tbl$LOS,na.rm=TRUE)

frm_interact_agent <- Returned.From ~  n_agent0*(Gender.p + LOS0 + Sick + Domestic + 
  outside_philly + Species.a * (Injured + Age0 + 
                                  I(Median0/1000)))

lrm_intearct_agent <- lrm(frm_interact_agent,data=join_tbl,penalty=37,x=TRUE,y=TRUE)

frm_interact_agent2 <- Returned.From ~ Gender.p + LOS + Sick + Domestic + n_agent + 
  outside_philly + Species.a * (Injured + Outcome.Age.in.Months + 
                                  I(Median/1000)) +  n_agent*Sick

lrm_interact_agent2 <- lrm(frm_interact_agent2,data=join_tbl,penalty=37,x=TRUE,y=TRUE)

library(scales)

ggplot(join_tbl,aes(x=Median,y=as.numeric(Returned.From),color=Species.a,fill=Species.a))+geom_smooth(method = glm, method.args = list(family = "binomial")) +scale_y_continuous(label=percent) +xlab("Median income for zip in $") +ylab ("Returned %")
ggsave("Income + Species Return.jpg",dpi=600)


ggplot(join_tbl,aes(x=Outcome.Age.in.Months,y=as.numeric(Returned.From),color=Species.a,fill=Species.a))+geom_smooth(method = glm, method.args = list(family = "binomial")) +scale_y_continuous(label=percent) +xlab("Outcome Age in Months") +ylab ("Returned %")
ggsave("Age + Species Return.jpg",dpi=600)

ggplot(join_tbl,aes(x=LOS,y=as.numeric(Returned.From)))+geom_smooth(method = glm, method.args = list(family = "binomial")) +scale_y_continuous(label=percent) +xlab("Length of Stay in Days") +ylab ("Returned %")
ggsave("LOS Return.jpg",dpi=600)
       
ggplot(join_tbl,aes(x=n_agent,y=as.numeric(Returned.From)))+geom_smooth(method = glm, method.args = list(family = "binomial")) +scale_y_continuous(label=percent) +xlab("Volume per Agent") +ylab ("Returned %")
ggsave("Agent volume Return.jpg",dpi=600)


ggplot(join_tbl,aes(x=n_agent,y=as.numeric(Returned.From),color=Sick,fill=Sick))+geom_smooth(method = glm, method.args = list(family = "binomial")) +scale_y_continuous(label=percent) +xlab("Volume per Agent") +ylab ("Returned %")
ggsave("Agent volume Return Sick.jpg",dpi=600)
