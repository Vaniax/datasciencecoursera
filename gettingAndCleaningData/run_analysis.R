# Source of data for the project:
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# This R script does the following:
# 1. Loads all relevant data and merges the training and the test sets to create one data set.

if(require("plyr")){
  print("plyr has been loaded correctly")
} else {
  print("trying to install plyr")
  install.packages("plyr")
  if(require(plyr)){
    print("plyr installed and loaded")
  } else {
    stop("could not install plyr")
  }

features <- read.table("features.txt", col.names=c("id","featureName"),stringsAsFactors = T)
trainData <- read.table("train/X_train.txt",col.names=features$featureName,check.names=F)
testData <- read.table("test/X_test.txt",col.names=features$featureName,check.names=F)

trainDataActivities <- read.table("train/y_train.txt", col.names="activity")
testDataActivities <- read.table("test/Y_test.txt", col.names="activity")

trainSubject <- read.table("train/subject_train.txt", col.names=c("subject"))
testSubject <- read.table("test/subject_test.txt", col.names=c("subject"))

X <- rbind(trainData,testData)
Y <- rbind(trainDataActivities,testDataActivities)
S <- rbind(trainSubject,testSubject)


# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
indices <- grep("-mean\\(\\)|-std\\(\\)",features[,2])
X <- X[,indices]
names(X) <- gsub("\\(|\\)","",names(X))
names(X) <- gsub("_","",names(X))


# 3. Uses descriptive activity names to name the activities in the data set and
# 4. Appropriately labels the data set with descriptive activity names.
activities <- read.table("activity_labels.txt",col.names=c("id","activity"),stringsAsFactors = T)
activities[,2] <- gsub("_","",tolower(as.character(activities[,2])))
Y[,1] = sapply(Y$activity,function(x) activities[activities==x,2])
cleanedAndMerged <- cbind(S,Y,X)


# 5. Creates a 2nd, independent tidy data set with the average of each variable for each activity and each subject.
tidyData <- ddply(cleanedAndMerged,.(activity,subject),numcolwise(mean))
write.table(tidyData,"dataSet_MeanValues.txt")


