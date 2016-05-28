## Loading relevant library for restructuring and aggregating the data
library(reshape2)

## defining the file name

filename <- "getdata_dataset.zip"

## Downloading and unzipping the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Loading activity labels alongwith features
actLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
actLabels[,2] <- as.character(actLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extracting only the data containing mean and standard deviation
featuresRequired <- grep(".*mean.*|.*std.*", features[,2])
featuresRequired.names <- features[featuresRequired,2]
featuresRequired.names = gsub('-mean', 'Mean', featuresRequired.names)
featuresRequired.names = gsub('-std', 'Std', featuresRequired.names)
featuresRequired.names <- gsub('[-()]', '', featuresRequired.names)


# Loading the training and test datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresRequired]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresRequired]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# mergeing datasets and incorporating labels
sensorData <- rbind(train, test)
colnames(sensorData) <- c("subject", "activity", featuresRequired.names)

# turn activities & subjects into factors
sensorData$activity <- factor(sensorData$activity, levels = actLabels[,1], labels = actLabels[,2])
sensorData$subject <- as.factor(sensorData$subject)

sensorData.melted <- melt(sensorData, id = c("subject", "activity"))
sensorData.mean <- dcast(sensorData.melted, subject + activity ~ variable, mean)

write.table(sensorData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)