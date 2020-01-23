# Data Codebook  
## Return Data  
Return data is from PetPoint which records animal intake and outcome process. It stores the information for both animal and adopter, which correspond to the following two datasets _PetPoint_byAnimal.csv_ and _PetPoint_byPerson.csv_ respectively. The datasets include the records for past 2 years (1/15/2018-1/15/2020). 

### PetPoint_byAnimal.csv  
* **Animal..** : a unique ID    
* **ARN** : NA    
* **Species** : Cat vs Dog    
* **Primary.Breed** : primary breed of animal  
* **Colors** : animal color  
* **Gender** : animal gender  
* **Altered** : whether animal's current status is spayed/neutered..  
* **Pre.Altered** : whether animal was spayed/neutered before coming to shelter  
* **Chip.Provider** : chip provider  
* **Danger** : Yes or No  
* **Danger.Reason** : Why the animal is labeled as danger (Yes)  
* **Date.of.Birth** : date of birth for animal  
* **Intake.Age** : age at intake (format y m d)  
* **Intake.By** : Person responsible to register intake  
* **Intake.Date** : format timestamp for intake date  
* **Intake.Type** : main category for how animal arrived at PAWS. Eg. Transfer in, Return, Owner/Guardian Surrender, Stray, etc.  
* **Intake.Subtype** : additional details for how animal arrived at PAWS  
* **Intake.Reason** : reason why animal was surrendered or arrived at PAWS  
* **Intake.Site** : PAWS location where intake occurred  
* **Intake.Location** : Within a Intake.Site, location where an animal was placed at intake (e.g. Maternity is for very young kittens and pregnant cats, Cat Room is for regular cats with no special conditions, Isolation is for cats with contagious diseases, Kennel - Holding is dog kennels waiting for staff evaluation)  
* **Intake.Sublocation** : NA  
* **Intake.Jurisdiction** : intake site address  
* **Intake.Condition** : animal intake condition (eg. Healthy, Sick, Ringworms, etc)  
* **Intake.Agency** : agency that transferred animal to PAWS (this variable can be removed, not relevant)  
* **Agency.Member** : agency staff member name  (this variable can be removed, not relevant)  
* **Agency.Member.Phone** : agency staff member's phone number  (this variable can be removed, not relevant)  
* **Agency.Address** : agency address  
* **Outcome.Age** : age of animal when left PAWS (format y m d)  
* **Outcome.Age.in.Months** : animal age in month when left PAWS  
* **Outcome.Date** : date that animal left PAWS  
* **Outcome.By** : PAWS Staff member who released the animal   
* **Outcome.Type** : main category for how animal left PAWS  
* **Outcome.Subtype** : additional details for how animal left PAWS  
* **Outcome.Site** : location from where animal left PAWS  
* **Outcome.Location** : detail location at outcome.site, similar to Intake.Location.  
* **Outcome.Sublocation** : NA  
* **Outcome.Jurisdiction** : NA  
* **Transfer.Out.Reason** : NA  
* **Outcome.Agency** : NA  
* **Released.By** : PAWS personnel who released the animal  
* **Release.Date** : time to release (format timestamp)  
* **LOS** : Length of stay (days)  

### PetPoint_byPerson.csv   
* **Person.ID** : unique id for adopter (de-identified)  
* **Person.Creation.Date** : time stamp for creating the person in PetPoint (_note - application could have been submitted before this date_)  
* **Gender** : adopter gender  
* **City** : city of adopter address  
* **City.Alias** : alias for city  
* **Province.Abbr** : state abbreviation of adopter address  
* **Postal.Code** : postal code of adopter address  
* **Contact.By.Address** : can adopter reached by mail?  
* **Jurisdiction** : NA  
* **County** : county of adopter address  
* **Contact.By.Phone** : can adopter reached by phone?  
* **Contact.By.Email** : can adopter reached by email?  
* **Operation.Type** : type of operation (eg. Adoption, ….)  
* **Operation.Subtype** : PAWS location where adoption occurred  
* **Operation.Date** : time stamp for adoption  
* **Operation.By** : PAWS personnel id who handled the operation  
* **Animal.ID** : animal unique id (can be used as foreign key for PetPoint_byAnimal.csv)  
* **ARN** : NA  
* **PetID** : this column can be ignored. It is where reference numbers are added  
* **Species** : type of animal (cat vs dog)  
* **Date.Of.Birth** : time stamp of date of birth for animal  
* **Microchip.Issuer** : Microchip Issuer  
* **Location** : the location of operation  
* **Site** : the site of operation  
* **Primary.Breed** : primary breed of animal  
* **Secondary.Breed** : secondary breed of animal  
* **Sex** : animal sex (F vs. M)  
* **Primary.Colour** : animal color  
* **Spayed.Neutered** : is animal sprayed? (Y vs N)  
* **Age.As.Months** : age of animal in month  
* **Body.Weight** : body weight of animal  
* **Body.Weight.Unit** : body weight unit of animal  
* **Opt.In.Consent.Subject..Opt.In** : consent columns can be ignored since PAWS don't use any of the consent functions.   
* **Consent.for.Opt.In** : consent columns can be ignored since PAWS don't use any of the consent functions.  
* **Consent.Opt.In.Created.In** : consent columns can be ignored since PAWS don't use any of the consent functions.  
* **Consent.Opt.In.Created.By** : consent columns can be ignored since PAWS don't use any of the consent functions.  
* **Consent.Opt.In.Created.Date.Time** : consent columns can be ignored since PAWS don't use any of the consent functions.  
* **Opt.In.Consent.Subject..Email** : NA  
* **Consent.for.Email** : NA  
* **Consent.Email.Created.In** : NA  
* **Consent.Email.Created.By** : NA  
* **Consent.Email.Created.Date.Time** : NA  
* **Opt.In.Consent.Subject..Mail** : consent columns can be ignored since PAWS don't use any of the consent functions.  
* **Consent.for.Mail** : consent columns can be ignored since PAWS don't use any of the consent functions.  
* **Consent.Mail.Created.In** : consent columns can be ignored since PAWS don't use any of the consent functions.  
* **Consent.Mail.Created.By** : consent columns can be ignored since PAWS don't use any of the consent functions.  
* **Consent.Mail.Created.Date.Time** : consent columns can be ignored since PAWS don't use any of the consent functions.  