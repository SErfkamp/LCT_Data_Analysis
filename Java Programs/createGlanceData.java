package create_glance_data;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.stream.Stream;


public class createGlanceData {



	
	static final String FOLDER_GLANCE = "C:\\Users\\serfk\\Documents\\Thesis\\Daten\\Eye_tracking\\Corrected\\";
	
	public static void main(String[] args) 
    {   
    	createGlanceData obj = new createGlanceData();
    	
    	obj.run();
    }
	
    void run () {
    	
    	// Iterate through raw glance data and check for newGlance == 1
    	// Iterate as long as it is 1, save into file once it is == 0, save Start Time and End Time and Duration
    	
    	
    	int startTime, currTime, prevTime, newTablet, prevTablet;
    	startTime = currTime = prevTime = newTablet = prevTablet = 0;
    	
        // Iterate through files
        File[] files = new File(FOLDER_GLANCE).listFiles();

        for (File file : files) {
        	if(!file.isFile()) continue;
        	//output
            Path outputPath = Paths.get(FOLDER_GLANCE + "\\output\\" + file.getName());
            
            //read file
            try (Stream<String> lines = Files.lines(Paths.get(file.getAbsolutePath()))) {
            	
            	for(String s : (Iterable<String>)lines::iterator) {
            		        		
                	String data ="";
                	String[] line = s.split("\\s+");

            		//write header to output file and continue
                	//AOI	Start_Time	End_Time	Duration
                	if(line[0].equals("rec_time")) {
                		data = "AOI\tStart_Time\tEnd_Time\tDuration" + System.getProperty("line.separator");
                        try {
    						Files.write(outputPath, data.getBytes());
    					} catch (IOException e) {
    						e.printStackTrace();
    					}
                		
                		continue;
                	}
                	
                	try {
                    	newTablet = Integer.parseInt(line[5]);
                    	currTime = Integer.parseInt(line[0]);

                	} catch (Exception cep) {
                    	System.out.println("WTF");
                    	System.out.println("Filename:" + outputPath);
               		
                	}
                	
                	if(newTablet == 1 && prevTablet == 0) {
                		startTime = Math.round((currTime + prevTime)/2) > 50 ? currTime - 30 : Math.round((currTime+prevTime)/2);
                	}
                	
                	//if glance ended, save glance to output
                	if(newTablet == 0 && prevTablet == 1) {
                		int endTime = Math.round((currTime+prevTime)/2) > 50 ? prevTime - 30 : Math.round((currTime+prevTime)/2);
                		int duration = endTime-startTime;
                		
                		if(duration > 0) {
                    		data = "Tablet1\t" + startTime +"\t" + endTime+ "\t" + duration + System.getProperty("line.separator");                			
                		}
                		
                        try {
    						Files.write(outputPath, data.getBytes(), StandardOpenOption.APPEND);
    					} catch (IOException e) {
    						e.printStackTrace();
    					}
                	}

                	prevTablet = newTablet;
                	prevTime = currTime;

                }
            } catch (IOException ex) {
            	System.out.println("Filename:" + outputPath);

              	ex.printStackTrace();
            }

        }
    };
}
