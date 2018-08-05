package straight_section_performance;


import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.stream.Stream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Scanner;


public class straightSectionPerformance {
	
	static final String PATH_SIGNS = "C:\\Users\\serfk\\Documents\\Thesis\\LCTa - ISO26022\\LCTSigns.txt";
	static final String PATH_DRIVING = "C:\\Users\\serfk\\Documents\\Thesis\\Daten\\Driving";
	static final String STRAIGHT_SECTION =	"C:\\Users\\serfk\\Documents\\Thesis\\Daten\\Straight_Sections";
	static final String CORRECTION_FILE = "C:\\Users\\serfk\\Documents\\Thesis\\Data Analysis\\correction_values.csv";

	public static void main(String[] args) 
    {   
    	straightSectionPerformance obj = new straightSectionPerformance();
    	
    	obj.run();
    }
    
    void run () {
    	
		int probandIndex = 0;
		int straightSectionIndex = 0;
		//Probands *  Base/Wisch * No. of Sections * Start/End
		int[][][][] straightSections = new int[31][2][18][2];
		
        File[] straightSectionFiles = new File(STRAIGHT_SECTION).listFiles();

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
    	
    	// Read correction values file
		int usingTimestamps[][] = new int[31][7];
		int timestampIndex = 0;
		int proband;
		
		Scanner scanner;
		try {
			scanner = new Scanner(new File(CORRECTION_FILE));
			scanner.useDelimiter("\r\n");
			while (scanner.hasNext()) {
			    String line = scanner.next();
			    String cells[] = line.split(";");   
			    
			    if(cells[0].equals("Proband")) continue;
			    
            	usingTimestamps[timestampIndex++] = new int[] {
            			//start_1 , end_1
            			Integer.parseInt(cells[2]),	Integer.parseInt(cells[3]),
            			//start_2 , end_2
            			Integer.parseInt(cells[4]), Integer.parseInt(cells[5]),
            			//start_3 , end_3
            			Integer.parseInt(cells[6]),Integer.parseInt(cells[7]),
            			//offset
            			Integer.parseInt(cells[8])};
			}
		} catch (FileNotFoundException e1) {
			e1.printStackTrace();
		}
		
		File[] files = new File(PATH_DRIVING).listFiles();

	        for (File file : files) {
	        	if(!file.isFile()) continue;
	        	//output
	            Path outputPath = Paths.get(PATH_DRIVING + "\\Driving_Straight\\" + file.getName());

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
	                	System.out.println(proband + " - " + run + " - " + lower_range + " - " + y_pos + " - " + upper_range);
	                	
	                	if (run == 0 || isUsingIVIS(currentTime, proband, usingTimestamps)) { 
	                		
		                	if (y_pos >= lower_range && y_pos <= upper_range) {
		                		line[7] = "B";
		                	} else {
		                		line[7] = "C";
		                	}
 	
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
