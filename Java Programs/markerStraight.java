
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.Scanner;
import java.util.stream.Stream;


public class markerStraight {
	
	private String PATH_DRIVING;
	private String LC_SECTION;
	private String CORRECTION_FILE;
	

    public markerStraight(String PATH_DRIVING, String LC_SECTION, String CORRECTION_FILE) {
		this.PATH_DRIVING = PATH_DRIVING;
		this.LC_SECTION = LC_SECTION;
		this.CORRECTION_FILE = CORRECTION_FILE;
	}


	void run () {
		
    	System.out.println("Start markerStraight");

    	
		int probandIndex = 0;
		int straightSectionIndex = 0;
		//Probands *  Base/Wisch * No. of Sections * Start/End
		int[][][][] straightSections = new int[31][2][18][2];
		
        File[] straightSectionFiles = new File(LC_SECTION).listFiles();

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
    	
		int proband;

		File[] files = new File(PATH_DRIVING).listFiles();

	        for (File file : files) {
	        	if(!file.isFile()) continue;
	        	//output
	            Path outputPath = Paths.get(PATH_DRIVING + File.separator + "Straight_Markers" + File.separator + file.getName());

	            //current position in marker array
	            int j = 0;
	            int a = 2;
	            
	            proband = Integer.parseInt(file.getName().split("_")[0])-1;
	        	int run;
	        	if(file.getName().split("_")[1].equals("base.txt")) {
	        		run = 0;
	        	} else {
	        		run = 1;
	        	}
   	
	        	char straight_char = 'B';
	        	
	            //read file
	            try (Stream<String> lines = Files.lines(Paths.get(file.getAbsolutePath()))) {
	            	
	            	for(String s : (Iterable<String>)lines::iterator) {
    		    
	            		//System.out.println(s);
	                	String data ="";
	                	String[] line = s.split("\\s+");                	
	                	if(line[0].equals("Zeit_in_s")) {
	                		String header = "Zeit_in_s\tXpos\tYpos\tV_in_km/h\tLenkw_in_Grad\tStrecke\tMarker\tZusMarker\tXSoll" + System.getProperty("line.separator");
	                        try {
	    						Files.write(outputPath, header.getBytes(), StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
	    					} catch (IOException e) {
	    						e.printStackTrace();
	    					}                		
	                		continue;
	                	}	
	                	                	            	
	                	double y_pos = Double.parseDouble(line[2]);
	                	double lower_range = straightSections[proband][run][j][0];
	                	double upper_range = straightSections[proband][run][j][1];
	                	
	                	int currentTime = (int) (Double.parseDouble(line[0]) * 1000);
	                	
	                	if (y_pos > upper_range && j < straightSections[proband][run].length-1) {
	                		j+=1;
	                	}
	                	//System.out.println(proband + " - " + run + " - " + lower_range + " - " + y_pos + " - " + upper_range);
	                	
	                	if (run == 1) { 
	                		line[6] = "1";
	                	}
	                	
	                		
	                	if (y_pos >= lower_range && y_pos <= upper_range) {
	                		line[7] = "" + (char) (straight_char+j);

	                	} else {
	                		line[7] = "A";

	                	}

      	

	                	for(int t = 0; t < line.length; t++) {
	                		data += line[t] + "\t";
	                	}
	                	data += System.getProperty("line.separator");
	                	           	                	
	                    // write to new file
	                    try {
							Files.write(outputPath, data.getBytes(), StandardOpenOption.APPEND);
						} catch (IOException e) {
							e.printStackTrace();
						}                	
	                }
	            } catch (IOException ex) {
	              	ex.printStackTrace();
	            }

	        }
    	//iterate through all driving files and update AdditionalMarker
    	
	    System.out.println("End markerLaneChange");

    }
    
    
    
    private boolean isUsingIVIS(int timestamp, int proband, int[][] correction_values) {
		int offset = correction_values[proband][6];

    	for(int i = 0; i < 6; i+=2) {
    		int lowerBound = correction_values[proband][i]-offset;
    		int upperBound = correction_values[proband][i+1]-offset;
    		
    		if (timestamp >= lowerBound && timestamp <= upperBound) {
    			return true;
    		}
    	}    	
    	return false;
    }

}
