#Coursera R Programming Assignment 3 Hospital outcome data 30 day death rate after treatment

import.tables <- function() {
  #read the csv (assumes already downloaded) and identify NAs
  #normally not called directly but within other functions
  careData <<- read.csv("outcome-of-care-measures.csv", colClasses = "character",
                        na.strings=c("Not Available","number of cases is too small (fewer than 25) to reliably tell how well the hospital is performing"))
  outcomes <<- c("heart attack", "heart failure", "pneumonia")
  #The 3 fields for the data we need from the table, in the same order as the corresponding outcomes
  fields <<- c("Hospital.30.Day.Death..Mortality..Rates.from.Heart.Attack",
               "Hospital.30.Day.Death..Mortality..Rates.from.Heart.Failure",
               "Hospital.30.Day.Death..Mortality..Rates.from.Pneumonia")
}
best <- function(state, outcome) {
  ## Read outcome data

  ## Check that state and outcome are valid
  ## Return hospital name in that state with lowest 30-day death rate

  #This healthy care file uses many different character descriptions of when the data is not available,
  #I filtered just a few of them.

  if (!is.element(state, unique(careData$State))) stop ("invalid state") #check state is valid
  if (!is.element(outcome, outcomes)) stop ("invalid outcome") #check outcome is valid

  outcome_index = match(outcome, outcomes); #stores which outcome (in the list) we have

  #dump all the records from other states and all the outcome fields we don't need
  #We're left with just 2 fields: Hospital.Name and the "outcome"
  #We still have "Not Available" values in our 2nd field
  careData <- careData[careData$State == state,][,c("Hospital.Name",fields[outcome_index])]
  careData <- na.omit(careData) #or: careData <- careData[complete.cases(careData),]
  careData[,2] <- as.numeric(careData[,2]) #if we don't do this, the field will sort as character
  careData[ order(careData[,2], careData[,1]), ][1,1]
}

rankhospital <- function(state, outcome, num = "best") {
  ## Read outcome data

  ## Check that state and outcome are valid
  ## Return hospital name in that state with the given rank
  ## 30-day death rate

  if (!is.element(state, unique(careData$State))) stop ("invalid state") #check state is valid
  if (!is.element(outcome, outcomes)) stop ("invalid outcome") #check outcome is valid

  outcome_index = match(outcome, outcomes); #stores which outcome (in the list) we have

  #dump all the records from other states and all the outcome fields we don't need
  #We're left with just 2 fields: Hospital.Name and the "outcome"
  careData <- careData[careData$State == state,][,c("Hospital.Name",fields[outcome_index])] #2 fields
  careData <- na.omit(careData) #or: careData <- careData[complete.cases(careData),]
  careData[,2] <- as.numeric(careData[,2]) #if we don't do this, the field will sort as character
  rawOut <- careData[ order(careData[,2], careData[,1]), ]
  if (is.numeric(num)) return (rawOut[num,1])
  if (num == "best") return (rawOut[1,1])
  if (num == "worst") return (rawOut[nrow(rawOut),1])
}

rankall <- function(outcome, num = "best") {
  ## Read outcome data

  ## return all hospital mortality rates for that income, sorted by ascending mortality then by Hospital.Name

  ddply.state <- function(df) {
    #for each subset passed from ddply, sort and return the indexed record specified by num in parent.frame
    #num might be "best" or "worst" or an integer value

    df.ordered <- df[ order(df[,3], df[,1]), ]
    if (is.numeric(num)) return (df.ordered[num,1])
    if (num == "best") return (df.ordered[1,1])
    if (num == "worst") return (df.ordered[nrow(df),1])
    df.ordered[1,1]
  }

  require(plyr)
  import.tables()

  if (!is.element(outcome, outcomes)) stop ("invalid outcome") #check outcome is valid

  outcome_index = match(outcome, outcomes); #stores which outcome (in the list) we have

  #We're left with just 3 fields: Hospital.Name, State and the "outcome"
  careData <- careData[,c("Hospital.Name","State", fields[outcome_index])]
  careData <- na.omit(careData) #or: careData <- careData[complete.cases(careData),]
  careData[,3] <- as.numeric(careData[,3]) #if we don't do this, the field will sort as character
  #careData all ready but unsorted, we use ddply() to split the data by state and from each state take the
  #hospital with num indexed mortality for each state (i.e. if num=5 take 5th lowest / best mortality)
  rawOut <- ddply(careData, colnames(careData)[2], function(df) ddply.state(df))
  out <- data.frame(rawOut[,2],rawOut[,1])
  colnames(out) <- c("hospital","state")
  out
}