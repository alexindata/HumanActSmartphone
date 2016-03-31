## run_analysis.r
## Wei Wei 2016-03-30
## this script is used to process a raw dataset into tidy data in 'tidy_avg.txt'
## analyzes the human activity data from Samsung Galaxy S II smartphone
## raw data: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

## download file folder, unzip, locate files
## Sys.time()
## [1] "2016-03-27

rm(list=ls())

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile="./webData/ucihumanactphone.zip", method="curl")
unzip("./webData/ucihumanactphone.zip", exdir="./webData")
dir("./webData")

## read data
library(data.table)
subject_test <- fread( "./webData/UCI\ HAR\ Dataset/test/subject_test.txt" )
X_test <- fread("./webData/UCI\ HAR\ Dataset/test/X_test.txt")
y_test <- fread("./webData/UCI\ HAR\ Dataset/test/y_test.txt")
subject_train <- fread("./webData/UCI\ HAR\ Dataset/train/subject_train.txt")
X_train <- fread("./webData/UCI\ HAR\ Dataset/train/X_train.txt")
y_train <- fread("./webData/UCI\ HAR\ Dataset/train/y_train.txt")
features <- fread("./webData/UCI\ HAR\ Dataset/features.txt")
activity_labels <- read.table("./webData/UCI\ HAR\ Dataset/activity_labels.txt", 
                              colClasses=c("factor", "factor") )

## merge data in test and train, X and y, assign column variable names
library(dplyr)
subject_all <- bind_rows(subject_test, subject_train)
X_all <- bind_rows(X_test, X_train)
y_all <- bind_rows(y_test, y_train)
all <- bind_cols(subject_all, y_all, X_all)
setnames(all, c("id", "activity", features$V2))

all$id <- factor(all$id)
all$activity <- factor(all$activity)
levels(all$activity) <- activity_labels$V2

## subset raw data by column variables that are the mean() and std() functions of measurements
all_mean_std <- all[, c("id", "activity", grep("-mean\\(|-std\\(", colnames(all), value=TRUE) )]

## tidy data, by the average of the variables in all_mean_std for each subject and each activity
tidy_avg <- all_mean_std %>% group_by(id, activity) %>% summarize_each(funs(mean))

## write all_mean_std, tidy_avg to txt files
write.table(format(all_mean_std, scientifi=TRUE), file="all_mean_std.txt", 
            sep=",", eol="\n", dec=".", row.names=FALSE, col.names=TRUE)
write.table(format(tidy_avg, scientific=TRUE), file="tidy_avg.txt", 
            sep=",", eol="\n", dec=".", row.names=FALSE, col.names=TRUE)








