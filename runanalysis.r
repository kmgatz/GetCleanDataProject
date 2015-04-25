'Karen Gatz project gor getting & cleaning data'
library("data.table")
library("dplyr")
library(reshape2)

readInData <- function(datafile) {
  tmpData <- read.table(datafile)
  retData <- data.table(tmpData)
}

' read and merge Subject test and train'
testdatafile <- paste(getwd(),"test","subject_test.txt",sep = "/")
testSubject <- readInData(file.path(testdatafile))

traindatafile <- paste(getwd(),"train","subject_train.txt",sep = "/")
trainSubject <- readInData(file.path(traindatafile))
dtSubject <- rbind(trainSubject,testSubject)
setnames(dtSubject, "V1", "subject")

' read and merge Y test and train'
testdatafile <- paste(getwd(),"test","Y_test.txt",sep = "/")
testY <- readInData(file.path(testdatafile))

traindatafile <- paste(getwd(),"train","Y_train.txt",sep = "/")
trainY <- readInData(file.path(traindatafile))

dtY <- rbind(trainY,testY)
setnames(dtY,"V1","activityNum")

' read and merge X test and train'
testdatafile <- paste(getwd(),"test","X_test.txt",sep = "/")
testX <- readInData(file.path(testdatafile))

traindatafile <- paste(getwd(),"train","X_train.txt",sep = "/")
trainX <- readInData(file.path(traindatafile))

dtX <- rbind(trainX,testX)

' merge subject, Y and X together'
dtTemp <- cbind(dtSubject, dtY)
dtAll <- cbind(dtTemp, dtX)
setkey(dtAll,subject, activityNum)

' extract only mean and stdev from features.txt description'
featurefile <- paste(getwd(),"features.txt",sep = "/")
dtFeatures <- fread(file.path(featurefile))
setnames(dtFeatures, names(dtFeatures), c("featureNum", "featureName"))
dtFeatures <- dtFeatures[grepl("mean\\(\\)|std\\(\\)",featureName)]

' use descriptive labels'
activityFile <- paste(getwd(),"activity_labels.txt",sep = "/")
dtActivityNames <- fread(file.path(activityFile))
setnames(dtActivityNames, names(dtActivityNames), c("activityNum", "activityName"))
dtAll <- merge(dtAll, dtActivityNames, by="activityNum", all.x=TRUE)
setkey(dtAll, subject, activityNum, activityName)

'subset variables'
subCriteria <- c(key(dt), dtFeatures$featureCode)
dtSub <- dtAll[, subCriteria, with=FALSE]

'process mean by groups and output answer file'
dtAnswer <- aggregate(dtAll$value, list(subject = dtAll$subject,activity = dtAll$activityName), mean)
outputFile <- paste(getwd(),"karengatz.txt",sep = "/")
write.csv(dtAnswer, file = outputFile)
