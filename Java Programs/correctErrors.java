
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.stream.Stream;
import java.util.ArrayList;


public class correctErrors {

	
	private String FOLDER_GLANCE;
	private int THRESHOLD; //threshold in ms 
	
	
	public correctErrors(String FOLDER_GLANCE, int THRESHOLD) {
		this.FOLDER_GLANCE = FOLDER_GLANCE;
		this.THRESHOLD = THRESHOLD;
	}

    void run () {
    	
    	// Iterate through created glance data and check for gaps that are too small
    	// Check if Glances are longer than Threshold to filter unrealistic values
    	
    	System.out.println("Start correctErrors");

    	
    	int startTime, endTime, prevEndTime;
    	    	
        // Iterate through files
        File[] files = new File(FOLDER_GLANCE).listFiles((dir,name) -> !name.equals(".DS_Store"));
        

        for (File file : files) {
        	if(!file.isFile()) continue;
        	//output
            Path outputPath = Paths.get(FOLDER_GLANCE + "error_corrected" + File.separator + file.getName());
            
            int i = startTime = endTime = prevEndTime = 0;
            ArrayList<int[]> data = new ArrayList<int[]>();
            
            //read file
            try (Stream<String> lines = Files.lines(Paths.get(file.getAbsolutePath()))) {
            	
            	for(String s : (Iterable<String>)lines::iterator) {
            		        		
                	String header ="";
                	String[] line = s.split("\\s+");

            		//write header to output file and continue
                	//AOI	Start_Time	End_Time	Duration
                	if(line[0].equals("AOI")) {
                		header = "AOI\tStart_Time\tEnd_Time\tDuration" + System.getProperty("line.separator");
                        try {
    						Files.write(outputPath, header.getBytes());
    					} catch (IOException e) {
    						e.printStackTrace();
    					}                		
                		continue;
                	}
                	
                	startTime = Integer.parseInt(line[1]);
                	endTime = Integer.parseInt(line[2]);
                	// if difference between current start time and old end time is smaller than threshold 
                	// combine these two lines and write to file
                	if(startTime - prevEndTime < THRESHOLD && i >= 1) {
                		int earliestStart = data.get(i-1)[0];
                		
                		int[] newLine = new int[]{earliestStart, endTime, endTime - earliestStart};
                		
                		data.set(i-1, newLine);
                	} else {
                		// If glance is not connected to previous add it to data
                		
                		int[] newLine = new int[]{startTime, endTime, endTime - startTime};

                		data.add(newLine);                		
                		i++;
                	}
          	
                	prevEndTime = endTime;

                }
            	
            	for(int[] dataLine : data) {
            		if(dataLine[2] > THRESHOLD) {
                		String outputLine = "Tablet1\t" + dataLine[0] + "\t" + dataLine[1] + "\t" + dataLine[2] + System.getProperty("line.separator");
  		
	                    // write to new file
	                    try {
	    					Files.write(outputPath, outputLine.getBytes(),StandardOpenOption.APPEND);
	    				} catch (IOException e) {
	    					e.printStackTrace();
	    				}
                	
            		}
            	}
            	           	                	

            } catch (IOException ex) {
              	ex.printStackTrace();
            }

        }
    	System.out.println("End correctErrors");
    }
}
