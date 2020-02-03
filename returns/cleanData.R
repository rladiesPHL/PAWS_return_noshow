library(tidyverse)
library(lubridate)
library(funModeling)

################# clean byAnimal ########################
PetPoint_byAnimal = read_delim("Data/PetPoint_byAnimal.csv", delim=",")

# remove columns have single value
PetPoint_byAnimal = PetPoint_byAnimal %>% 
        select_if(function(x){length(unique(x)) > 1})

# # check each column possible values
# column_exp = lapply(
#         colnames(PetPoint_byAnimal),
#         function(x){
#                 head(unique(PetPoint_byAnimal %>% pull(x)))
#         }
# )
# names(column_exp) = colnames(PetPoint_byAnimal)
# 
# column_unique_value_n = lapply(
#         colnames(PetPoint_byAnimal),
#         function(x){
#                 length(unique(PetPoint_byAnimal %>% pull(x)))
#         }
# )
# names(column_unique_value_n) = colnames(PetPoint_byAnimal)

# remove other columns containing repeative information, unknown info
PetPoint_byAnimal = PetPoint_byAnimal %>% 
        select(-contains("Agency"), -ARN, -Released.By, -Release.Date, -Outcome.Age, -LOS, -Intake.Age, -Outcome.Age.in.Months) 

# fix column name
PetPoint_byAnimal = PetPoint_byAnimal %>% 
        dplyr::rename(Animal.ID=Animal..)

# fix missing data
PetPoint_byAnimal = PetPoint_byAnimal %>% mutate(Gender=ifelse(Gender=="Unknown", NA, Gender))
PetPoint_byAnimal = PetPoint_byAnimal %>% mutate(Altered=ifelse(Altered=="Unknown", NA, Altered))

# column type fix (factors, Dates)
PetPoint_byAnimal = PetPoint_byAnimal %>% 
        mutate_if(function(x){length(unique(x)) <=10}, as.factor) %>% 
        mutate_at(vars(contains("Date")), function(x){parse_date_time(x, c("%m/%d/%Y", "%m/%d/%Y %H:%M:%S %p"), tz=Sys.timezone(location = TRUE))}) %>%
        mutate(Intake.Date=floor_date(Intake.Date, unit="minute")) %>% 
        mutate(Outcome.Date=floor_date(Outcome.Date, unit="minute")) %>% 
        mutate(Date.of.Birth=as.Date(Date.of.Birth))

# recalculate intake outcome age in month and LOS in day
PetPoint_byAnimal = PetPoint_byAnimal %>% 
        mutate(Intake.Age.in.Months=round(as.numeric(as.Date(Intake.Date)-Date.of.Birth)/30)) %>% 
        mutate(Outcome.Age.in.Months=round(as.numeric(as.Date(Outcome.Date)-Date.of.Birth)/30)) %>% 
        mutate(LOS=as.numeric(as.Date(Outcome.Date)-as.Date(Intake.Date)))


################## clean byPerson ####################
PetPoint_byPerson = read_delim("Data/PetPoint_byPerson.csv", delim=",")

# remove columns have single value
PetPoint_byPerson = PetPoint_byPerson %>% 
        select_if(function(x){length(unique(x)) > 1})

# # check each column possible values
# column_exp = lapply(
#         colnames(PetPoint_byPerson),
#         function(x){
#                 head(unique(PetPoint_byPerson %>% pull(x)))
#         }
# )
# names(column_exp) = colnames(PetPoint_byPerson)
# 
# column_unique_value_n = lapply(
#         colnames(PetPoint_byPerson),
#         function(x){
#                 length(unique(PetPoint_byPerson %>% pull(x)))
#         }
# )
# names(column_unique_value_n) = colnames(PetPoint_byPerson)

# remove repeative and unknown information
PetPoint_byPerson = PetPoint_byPerson %>% 
        select(-contains("Consent")) %>% 
        select(-City.Alias,-Jurisdiction,-Age.As.Months,-Person.Creation.Date,-ARN,-PetID)

PetPoint_byPerson = PetPoint_byPerson %>% 
        select(-Microchip.Issuer,-Location,-Site,-Primary.Breed,-Secondary.Breed,-Sex, -Primary.Colour,-Spayed.Neutered)

# rename Gender, Operation.* 
PetPoint_byPerson = PetPoint_byPerson %>% 
        dplyr::rename(Person.Gender=Gender) %>% 
        dplyr::rename(Outcome.Subtype=Operation.Subtype, Outcome.Date=Operation.Date) %>% 
        select(-Operation.By)

# fix Body.Weight
PetPoint_byPerson = PetPoint_byPerson %>% 
        mutate(Body.Weight=ifelse(Body.Weight==0,NA,Body.Weight)) %>% 
        mutate(Body.Weight=ifelse(is.na(Body.Weight.Unit),NA,Body.Weight))

# convert missing data
PetPoint_byPerson = PetPoint_byPerson %>% 
        mutate(Person.Gender=gsub(" ","",Person.Gender)) %>% 
        mutate(Person.Gender=ifelse(Person.Gender=="0", NA, Person.Gender))

# fix variable type
PetPoint_byPerson = PetPoint_byPerson %>%
        mutate_if(function(x){length(unique(x)) <=10}, as.factor) %>% 
        mutate_at(vars(contains("Date")), function(x){parse_date_time(x, c("%m/%d/%Y %H:%M %p", "%m/%d/%Y %H:%M %p"))}) %>% 
        mutate(Date.Of.Birth=as.Date(Date.Of.Birth)) %>% 
        dplyr::rename(Date.of.Birth=Date.Of.Birth)
PetPoint_byPerson = PetPoint_byPerson %>% 
        mutate(Postal.Code=as.character(Postal.Code))


######################## join tables ###########################
PetPoint = full_join(
        PetPoint_byAnimal %>% 
                mutate(Outcome.Date=format(as.POSIXct(Outcome.Date), "%m/%d/%Y %H:%M")),
        PetPoint_byPerson %>% 
                mutate(Outcome.Date=format(as.POSIXct(Outcome.Date), "%m/%d/%Y %H:%M"))
) %>% mutate(Outcome.Date=parse_date_time(Outcome.Date,"%m/%d/%Y %H:%M",tz=Sys.timezone(location = TRUE))) 

# remove variables with more than 50% missing value
var_keep = df_status(PetPoint) %>% tbl_df %>% 
        filter(p_na < 50) %>% pull(variable)
PetPoint = PetPoint[var_keep]

save(PetPoint, PetPoint_byAnimal, PetPoint_byPerson, file="Data/PetPoint_data.Rdata")
