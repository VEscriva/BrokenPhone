url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
name = "proj.zip"
download.file(url, dest = name)  #data download

proj.data<-unzip(name)
View(proj.data) #to see the files in the downloaded data
test.data<-read.table(proj.data[15], header = FALSE) #table of just test data
proj.tests.label <-read.table(proj.data[16])  #labels  (metadata)
proj.tests.sub <-read.table(proj.data[14])    #subjects
colnames(proj.tests.label) <- "labels"
colnames(proj.tests.sub) <- "subjects"



features <- read.table(proj.data[2])  #column heads

colnames(test.data) <- features[, 2]     #applying headers

bound.test <-cbind(proj.tests.label, proj.tests.sub)  #binding metadata
test.bound <- cbind(bound.test, test.data)   #ordered to get metadata first

train.data<-read.table(proj.data[27]) #table of just training data
colnames(train.data) <- features[, 2]  #applying headers

proj.train.label <-read.table(proj.data[26])  #metadata
proj.train.sub <-read.table(proj.data[28])
colnames(proj.train.label) <- "labels"
colnames(proj.train.sub) <- "subjects"

bound.train <-cbind(proj.train.label, proj.train.sub)  #binding metadata
train.bound <- cbind(bound.train, train.data)   #binding ordered to get metadata first

total.data<- rbind(train.bound, test.bound) total #dataset


valid_column_names <- make.names(names=names(total.data), unique=TRUE, allow_ = TRUE)  #make names readable for select
names(total.data) <- valid_column_names

reduced.data <- select(total.data, contains("mean"), contains("std"), contains("labels"), contains("subjects")) #select means and standard dev
> View(reduced.data)


lab.short.data <- reduced.data %>% mutate(activity = ifelse(labels == 1, "WALKING", #messy way of defining activities with labels
                                                            ifelse(labels==3, "WALKING_DOWNSTAIRS", #I excluded STANDING and WALKING_UPSTAIRS
                                                                   ifelse(labels==5, "STANDING", "LAYING")))) #with no entires, they only murkied the water down stream

concise.data <- select(lab.short.data, -labels)

melty.data<- melt(concise.data, id=c( "activity", "subjects"), na.rm=TRUE)

crunchy.data <- tidied <- dcast(melty.data, subjects + activity ~ variable, mean)
View(crunchy.data)
