## Download dataset
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if (!file.exists("./data")) dir.create("./data")
download.file(url, destfile = file.path("./data/", basename(url)))

## Unzip dataset
unzip(file.path("./data/", basename(url)), exdir = "./data")
data.dir <- "./data/UCI HAR Dataset/"   

## 1. Merges the training and the test sets to create one data set.
features <- read.table(file.path(data.dir, "features.txt"), colClasses = c(NA, "character"))[,2]

# Read the training dataset
subjec_train <- read.table(file.path(data.dir, "train/subject_train.txt"), col.names = "ID")
y_train <- read.table(file.path(data.dir, "train/y_train.txt"), col.names = "Activity",colClasses = "factor")
x_train <- read.table(file.path(data.dir, "train/x_train.txt"), col.names = features, check.names = FALSE)
train <- cbind(subject_train, y_train, x_train)

# Read the test dataset
subject_test <- read.table(file.path(data.dir, "test/subject_test.txt"), col.names = "ID")
x_test <- read.table(file.path(data.dir, "test/x_test.txt"), col.names = features, check.names = FALSE)
y_test <- read.table(file.path(data.dir, "test/y_test.txt"), col.names = "Activity", colClasses = "factor")
test <- cbind(subject_test, y_test, x_test)

data <- rbind(train, test)
#colnames(data) <- features

## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
mean_std <- grep("*mean\\(\\)*|*std\\(\\)*", features)
data.mean_std <- data[, c(1,2,mean_std+2)]

## 3. Uses descriptive activity names to name the activities in the data set
activity_lable <- read.table(file.path(data.dir, "activity_labels.txt"))
levels(data.mean_std$Activity) <- activity_lable$V2

## 4. Appropriately labels the data set with descriptive variable names.
colnames(data.mean_std)<- gsub("*\\(\\)*", "", colnames(data.mean_std))
colnames(data.mean_std)<- gsub("(t|f)(Body|Gravity)(Body|*)", "\\1.\\2.", colnames(data.mean_std))

## 5. From the data set in step 4, creates a second, independent tidy data set with the average 
###    of each variable for each activity and each subject.
tidy <- ddply(data.mean_std, .(ID, Activity), numcolwise(mean))
write.table(tidy, file="./tidy.csv", quote = FALSE)
