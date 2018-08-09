
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.stream.Stream;
import java.util.ArrayList;
import java.util.Scanner;


public class categorizeGlances {

	
	 private String FOLDER_GLANCE;
	 private String FOLDER_DRIVING;
	 private String CORRECTION_FILE;
	 private String STRAIGHT_SECTION;
	
    public categorizeGlances(String FOLDER_GLANCE, String FOLDER_DRIVING, String CORRECTION_FILE,
			String STRAIGHT_SECTION) {
		this.FOLDER_GLANCE = FOLDER_GLANCE;
		this.FOLDER_DRIVING = FOLDER_DRIVING;
		this.CORRECTION_FILE = CORRECTION_FILE;
		this.STRAIGHT_SECTION = STRAIGHT_SECTION;
	}

	void run () {
    	System.out.println("Start categorizeGlances");

    	
    	int probandIndex = 0;
		int straightSectionIndex = 0;
		//Probands *  Base/Wisch * No. of Sections * Start/End
		int[][][][] straightSections = new int[31][2][18][2];
		
        File[] straightSectionFiles = new File(STRAIGHT_SECTION).listFiles((dir,name) -> !name.equals(".DS_Store"));

        for (File file : straightSectionFiles) {
        	
        	int run;
        	probandIndex = Integer.parseInt(""+file.getName().split("_")[0]) - 1;
        	if(file.getName().split("_")[1].equals("base.txt")) {
        		run = 0;
        	} else {
        		run = 1;
        	}

            try (Stream<String> lines = Files.lines(Paths.get(file.getAbsolutePath()))) {  
            	          
		    	for(String s : (Iterable<String>)lines::iterator) {  		        		

		        	String[] line = s.split("\\s+");
		        	
		        	straightSections[probandIndex][run][straightSectionIndex][0] = (int) Double.parseDouble(line[0]);
		        	straightSections[probandIndex][run][straightSectionIndex][1] = (int) Double.parseDouble(line[1]) + 1;
		        	
		        	straightSectionIndex++;
		    	}            		       
		    	
	        } catch (IOException ex) {
	          	ex.printStackTrace();
	        }
            
            straightSectionIndex = 0;

        }
    	
		int offsets[] = new int[31];
		int offsetIndex = 0;
		int offset, proband;
		
		Scanner scanner;
		try {
			scanner = new Scanner(new File(CORRECTION_FILE));
			scanner.useDelimiter("\r\n");
			while (scanner.hasNext()) {
			    String line = scanner.next();
			    String cells[] = line.split(";");   
			    
			    if(cells[0].equals("Proband")) continue;
			    
            	offsets[offsetIndex++] = Integer.parseInt(cells[8]);       

			}
		} catch (FileNotFoundException e1) {
			e1.printStackTrace();
		}
	
    	int startTime, endTime, duration;
    	    	
        // Iterate through files
        File[] files = new File(FOLDER_GLANCE).listFiles((dir,name) -> !name.equals(".DS_Store"));

        for (File file : files) {
        	if(!file.isFile()) continue;
        	//output
            Path outputPath = Paths.get(FOLDER_GLANCE + "categorized" + File.separator + file.getName());
            
            ArrayList<int[]> data = new ArrayList<int[]>();
            
        	proband = Integer.parseInt(""+file.getName().charAt(0))-1;
        	offset = offsets[proband];
            
            //read file
            try (Stream<String> lines = Files.lines(Paths.get(file.getAbsolutePath()))) {
            	
            	for(String s : (Iterable<String>)lines::iterator) {
            		        		
                	String header ="";
                	String[] line = s.split("\\s+");

            		//write *header to output file and continue
                	//AOI	Start_Time	End_Time	Duration
                	if(line[0].equals("AOI")) {
                		header = "AOI\tStart_Time\tEnd_Time\tDuration\tStraight_Section" + System.getProperty("line.separator");
                        try {
    						Files.write(outputPath, header.getBytes(), StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
    					} catch (IOException e) {
    						e.printStackTrace();
    					}                		
                		continue;
                	}
                	
                	startTime = Integer.parseInt(line[1]);
                	endTime = Integer.parseInt(line[2]);
                	duration = Integer.parseInt(line[3]);
                	
                	int straightSection = getTypeForGlance(startTime-offset, endTime-offset, duration, proband, straightSections);
                	int[] newLine = new int[]{startTime, endTime, duration, straightSection};
                	data.add(newLine);
                }
            	
            	for(int[] dataLine : data) {
            		String outputLine = "Tablet1\t" + dataLine[0] + "\t" + dataLine[1] + "\t" + dataLine[2]+ "\t" + dataLine[3] + System.getProperty("line.separator");
	
                    // write to new file
                    try {
    					Files.write(outputPath, outputLine.getBytes(),StandardOpenOption.APPEND);
    				} catch (IOException e) {
    					e.printStackTrace();
    				}
            	}
            	           	                	

            } catch (IOException ex) {
              	ex.printStackTrace();
            }

        }
    	System.out.println("End categorizeGlances");

    }
    
	private int getTypeForGlance(int startTime, int endTime, int duration, int proband, int[][][][] straightSections) {
		
		double[] y_positions = getYPosFromTimestamp(startTime, endTime, proband);
		double glance_start = y_positions[0];
		double glance_end = y_positions[1];
		//int track = (int) y_positions[2];
		

        for(int k = 0; k < straightSections[proband][1].length; k++) {
        	
        	int section_start = straightSections[proband][1][k][0];
        	int section_end = straightSections[proband][1][k][1];
        	
        	// if start is already too small all following section will also be too big -> return 1;
        	if(glance_start <= section_start) {
        		return 1;
        	}
            	
        	if(glance_start >= section_start && glance_start <= section_end) {
        		if (glance_end <= section_end) {
        			return 0;
        		}
        		
        		double distStraight = section_end - glance_start;
        		double distLC = glance_end - section_end;
        		
        		// if glance is longer in the straight section return it as straight section glance
        		return distStraight >= distLC ? 1 : 0;
        	}
        }
        
    	return 1;    
    	
  /*
		double glance_duration = lc_durations[proband];
			

        for(int k = 0; k < straightSections[proband][1].length; k++) {
        	
        	int section_start = straightSections[proband][1][k][0];
        	int section_end = straightSections[proband][1][k][1];
        	
    		//25% - 50% - 25% Split Start - During - End
    		double lc_start_Section_start = section_end;
    		double lc_start_Section_end = section_end + 0.25 * glance_duration;
    		
    		double lc_during_Section_start = section_end + 0.26 * glance_duration;
    		double lc_during_Section_end = section_end + 0.74 * glance_duration; 

    		double lc_end_Section_start = section_end + 0.75 * glance_duration;
    		double lc_end_Section_end = section_end + glance_duration; 
    		
//        	
//        	// if start is already too small all following section will also be too big -> return 1;
//        	if(glance_start <= section_start) {        		
//        		return 1;
//        	}
            	
        	if(glance_start >= section_start && glance_start <= section_end) {
        		if (glance_end <= section_end) {
        			return 0;
        		}
        		
        		double distStraight = section_end - glance_start;
        		double distLC = glance_end - section_end;
        		
        		// if glance is longer in the straight section return it as straight section glance
        		if (distStraight >= distLC) return 0;
        		
        		double distStart = 0.0;
        		double distDuring = 0.0;  
        		double distEnd = 0.0;
        		
        		distStart = glance_end >= lc_start_Section_end ? lc_start_Section_end - section_end : glance_end - section_end;
        		distDuring = glance_end >= lc_during_Section_end ? lc_during_Section_end - lc_during_Section_start : glance_end - section_end;
        		distEnd = glance_end >= lc_end_Section_end ? lc_end_Section_end - section_end : glance_end - section_end;     
	
   */
	}
	
	private double[] getYPosFromTimestamp(int startTime, int endTime, int proband) {
		double[] y_pos= {0.0,0.0,0.0};
		
		// Get driving file for proband
        File file = new File(FOLDER_DRIVING + File.separator + (proband+1) + "_wisch.txt");
        
        //read file
        try (Stream<String> lines = Files.lines(Paths.get(file.getAbsolutePath()))) {
        	
        	for(String s : (Iterable<String>)lines::iterator) {

            	String[] line = s.split("\\s+");            	
            	if(line[0].equals("Zeit_in_s")) continue;  
            	
            	int currentTime = (int) (Double.parseDouble(line[0]) * 1000);

            	if(startTime <= currentTime) {
            		y_pos[0] = Double.parseDouble(line[2]);
            	}
            	
            	if(endTime <= currentTime) {
            		y_pos[1] = Double.parseDouble(line[2]);
            		y_pos[2] = Double.parseDouble(line[5])-1;
            		break;
            	}            	
        	}  
        } catch (IOException ex) {
          	ex.printStackTrace();
        }
    	return y_pos;

	}

}
