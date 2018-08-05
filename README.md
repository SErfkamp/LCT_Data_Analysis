# LCT Data Analysis

Files in this repository help me analyzing driving performance data.
Steps to use these scripts.

1. Format driving data.
   - Open the initial driving files. Delete all lines where the track number is 0 or 77. There are some at the start and some at the end of the file. You can write a simple script to do this. 
   - Use the convert.exe that is provided to convert the data for the LCTa tool. 
   - Put all driving files in 1 folder and rename them to X_treatment where X is the probands number. E.g. 1_base.txt, 1_wisch.txt
   - As I only cared about the "wisch" gestures I just put the according baseline file into the same folder. If you are looking at more than one treatment, create more folders with the different treatments.
   - You can find the correct baseline using the timestamp of the "changing date" of your operating system. The baselines were driven before the treatment.
   - In the end you should have one folder of driving data. 
2. Prepare Glance data. 
   - The issue with the glance data is, that the Dikablis software didn't categorize them correctly. So we have to help.
   - Put all CSV files into one folder. Again I only cared about the wisch data so either rename them so you know which treatment is ment or put them in 2 different folders.
3. Correct Glance data.
   - Open RStudio and the script "eye_tracking_check_for_correctness.R".
   - The first part of the file line 1 - 97 will later create our new corrected csv files.
   - The second part of the file line 102 - end is used to find those X and Y coordinates where the system should have detected a glance on the tablet but didn't.
   - State the path to the CSV files folder: line 106
   - Paste in a file name of a file that you want to correct. 
   - Run lines 102 - end of the script. A plot should appear showing the glances' positions in a coordinate system. The blue lines should now be adjusted accordingly to correctly categorize the glances.
   - adjust the values and store the information in the "correction_values.csv" (not yet in this Repo)
   - If you are done, specify the input paths and output folder in line 2-4 
4. Use the "createGlanceData.java" program to create new glance files for the data. 
   - Specify the input path to the folder of the just created files in R.
   - Specify the output folder.
5. Use the "correctGlanceData.java" program to merge short glances and filter our too short glances.Adjust input / output folders accordingly.
6. Next, we want to categorize wich glance was during a lane change and which one was during a straight section. 
   - For this, update the correction_values.csv to include columns for individual start and end meters and specify the tracks that the proband was driving.
   - To get the individual start and end values. Load the driving data from earlier into the Analyzer tool. And run the ISO analysis.
   - Hover over the lane change begins and ends and calculate the distance to the sign. Put these values in the correction_values.csv
   - Before we categorize the glances, we have to run the "defineStraightSections.java" which basically does what its name is. It creates files for each individual proband that specifies the start and end points of each straight section.
7. Run the categorizeGlances.java
   - Finally we can run the categorizeGlances.java file. The output will be correct glance files that show if a glance was during a straight section or during a lane change. 
8. I did not automate to reformat the output of the LCTA files. Open them in Excel and do the reformatting. Or otherwise change the eye_glance.R script to your needs.
8. Using "eye_glance.R" will give you a quick start to read the data and combine it with everything.
