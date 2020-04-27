library(dplyr)
library(readr)
library(stringr)
library(knitr)

# load file
byAnimal <- read_csv("PetPoint_byAnimal.csv")

# creating a table with percentages of returned adoptions by staff
# returned adoptions by Staff:
byStaff <- byAnimal %>%
        mutate(Returned.Intake = Intake.Subtype == "Returned Adoption") %>%
        select(Returned.Intake, Released.By) %>%
        group_by(Released.By) %>%
        summarise(total_returned = sum (Returned.Intake == TRUE),
                  total_adoptions = n(),
                  freq_returned_adoptions = sum (Returned.Intake == TRUE) / n()
                  ) %>%
        arrange(desc(total_adoptions) ,total_returned ,freq_returned_adoptions )

######################################################################## 

# data set for applying a machine learning package

ml_byStaff  <- read_csv("PetPoint_byAnimal.csv") %>%
        # clean a few things
        rename(Animal.ID = Animal..) %>%
        mutate(Returned.Intake = Intake.Subtype == "Returned Adoption") %>%
        # prepare to pivot
        mutate(n = 1) %>%
        # pivot wide
        pivot_wider(names_from = Released.By, names_prefix = "released_", values_from = n, values_fill = list(n = 0)) %>%
        # remove spaces from names
        dplyr::rename_all(list(~make.names(.)))  %>%
        # create the data set
        dplyr::select(Returned.Intake , starts_with("released_"))

# results interesting but not necessarily helpful

