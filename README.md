# Getting and Cleaning Data Course Project - Quynh Huong Dau
This repository is a for Getting and Cleaning Data course project.

### Dataset
The dataset used for analysis is Human Activity Recognition Using Smartphones that was downloaded to **data.zip** file and unzipped to the folder named **'UCI HAR Dataset'**

### Files:
1. **Codebook.md** shows step by step data accquiring, analysis as well as varible descriptions.
        **Codeboook.html** include the commands and the outputs, knitted from **Codebook.md**
2. **_run_analysis.R_** is the script file that:
        - Merges the training and the test sets to create one data set.
        - Extracts only the measurements on the mean and standard deviation for each measurement.
        - Uses descriptive activity names to name the activities in the data set
        - Appropriately labels the data set with descriptive variable names.
        - From the data set in step 4, creates a second, independent tidy data set with the average of each variable
        for each activity and each subject
3. **combined_data.csv** is combined, tidied-up and transformed data from *training* and *test* datasets
4. **tidy_data.csv** is summarized data with average value of each variable for each activity and each subject.


