#Download and upzip data
data_link <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
if(!file.exists('getdata_projectfiles_UCI HAR Dataset.zip')){
        download.file(data_link, destfile = 'data.zip', method = 'curl')
}
if(!file.exists('UCI HAR Dataset')){
        unzip('data.zip')
}

# Load Packages
## dplyr

#check if dplyr is installed. If installed, load the library. If not, install the dplyr package then load it:
if (!require(dplyr)) {
        install.packages('dplyr', dependencies = TRUE)
        library(dplyr)
}

## stringi 

if (!require(stringi)) {
        install.packages('stringi', dependencies = TRUE)
        library(stringi)
}
## knitr 

if (!require(rmarkdown)) {
        install.packages('rmarkdown', dependencies = TRUE)
        library(rmarkdown)
}

# Import and process data
## Features

#Read features.txt file but skip the first column (including numbers) and import the second column as variable Feature
feature <- read.csv('./UCI HAR Dataset/features.txt', header = FALSE,
                    sep = '', colClasses = c('NULL','character'), col.names = c('NULL','Feature'))

## Feature Information:

feature_info <- readLines('./UCI HAR Dataset/features_info.txt')
#Grab lines with pattern such as std(): standard deviation
#the regrex "^f|^t|[()]:|Mean$' identify any lines start with f, t, including '():', or ends with Mean
info <- grep('^f|^t|[()]:|Mean$',feature_info, value = TRUE)
info <- strsplit(info, '(): ', fixed = TRUE)
feature.description <- data.frame(matrix(ncol=2, nrow = length(info)))
for (i in 1:length(info)) {feature.description[i, ] <- c(info[[i]][1],info[[i]][2])}
colnames(feature.description) <- c('abbreviation','description')
#Using stringi package to filled in the NA cell in description column
#Stringi package helps to avoid multiple gsub() functions and much faster compared to gsubfn()
for (i in 1:nrow(feature.description)) {
        if(is.na(feature.description[i,2])) {
                feature.description[i,2] <-
                        stri_replace_all_regex(feature.description[i,1],
                        c('^t', '^f', 'tBody', 'freq', 'Acc', 'Gyro', 'Mag', '[()]'),
                        c('Time', 'Frequency', 'TimeBody', 'Frequency',
                        'Accelerometer', 'Gryoscope', 'Magnitute',''), vectorize = FALSE)
        }
}
#Take a look at the feature information
paged_table(feature.description)


## Activity labels
#Read and load activity_labels.txt into 2 columns
#The first column is the code identifier (Act_code) for the corresponding activity in second column (Activity)
activity_label <- read.csv('./UCI HAR Dataset/activity_labels.txt',
                           sep = '', header = FALSE, col.names = c('Act_code', 'Activity'))

## X and y

#Read and load data from X_test.txt and X_train.txt into data frames and combine into data frame called x
#Use data from feature data frame as column names
x_test <- read.csv('./UCI HAR Dataset/test/X_test.txt',
                   sep ='', header = FALSE)
x_train <- read.csv('./UCI HAR Dataset/train/X_train.txt',
                    sep ='', header = FALSE)
x <- rbind(x_test,x_train)
colnames(x) <- feature[[1]]

y_test <- read.csv('./UCI HAR Dataset/test/y_test.txt',
                   sep ='', header = FALSE, col.names = 'Act_code')
y_train <- read.csv('./UCI HAR Dataset/train/y_train.txt',
                    sep ='', header = FALSE, col.names = 'Act_code')
y <- rbind(y_test,y_train)

## Subject
subject_test <- read.csv('./UCI HAR Dataset/test/subject_test.txt',
                         sep ='', header = FALSE, col.names = 'Subject')
subject_train <- read.csv('./UCI HAR Dataset/train/subject_train.txt',
                          sep ='', header = FALSE, col.names = 'Subject')
subject <- rbind(subject_test, subject_train)

##Filter and cleaning up
#Grab only columns for mean and standard deviation in x data set
#First create a regrex that would get either one of : mean, std, Mean, Std
mean_std <- '[Mm][e][a][n]|[Ss][t][d]'
#Using grep to get column names containing mean_std regex
x <- x %>% select(grep(mean_std, names(x)))
#Changing denotation to full description based on feature_info.txt
find_list <- c('[()]','^t', '^f', 'tBody', '[Ff]req$', 'Acc', 'Gyro', 'Mag','std','mad','arCoeff','sma', 'iqr','BodyBody')
replace_list <-  c('','Time', 'Frequency', 'TimeBody', 'Frequency', 'Accelerometer', 'Gryoscope', 'Magnitute',
                   'StandardDeviation', 'Median', 'AutoregressionCoefficient', 'SignalMagnituteArea',
                   'InterquartileRange','Body')
#check if the length of find_list and replace_list are the same. If yes, initiate the for loop
if(length(find_list)==length(replace_list)) {
        for (i in 1:length(colnames(x))) {
                colnames(x)[i] <- stri_replace_all_regex(colnames(x)[i],
                                find_list, replace_list, vectorize = FALSE)
        }
}

#Matching y data set by look up the activity_label data set using the Act_code (as key) and Activity (as value)
#Many methods to do this
#Method 1:
y$Activity <- activity_label[y$Act_code, 2]
#Method 2:
#y$Activity <- full_join(y, activity_label, by = 'Act_code')

#Combine data sets x, y and subject into one single data set called combined_data
combined_data <- cbind(subject, y$Activity, x)
colnames(combined_data)[2] <- 'Activity'
#View head of combined_data
paged_table(head(combined_data))
#Write to disk
write.csv(combined_data,'combined_data.csv', row.names = F)
#Tidy dataset:
tidy_dataset <- combined_data %>% group_by(Subject, Activity) %>% summarize_all(funs(mean))
#View head of tidy_dataset
paged_table(head(tidy_dataset))
#Write to disk
write.csv(tidy_dataset,'tidy_data.csv', row.names = F)

#Basic information about data sets
#get all existed data frames in the global environments:
data_sets <- Filter(function(x) is(x, "data.frame"), mget(ls()))
#print out basic information of all the data set
for (i in 1:length(data_sets)) {
        cat(names(data_sets)[i],': Data frame with', nrow(data_sets[[i]]), 'rows', 'and',
            ncol(data_sets[[i]]),'columns\n')
}

