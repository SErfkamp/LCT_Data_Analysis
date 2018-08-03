package categorize_glances;




import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.stream.Stream;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;


public class categorizeGlances {

	
	static final String FOLDER_GLANCE = "C:\\Users\\serfk\\Documents\\Thesis\\Daten\\Eye_tracking\\Corrected\\output\\error_corrected";
	static final String FOLDER_DRIVING = "C:\\Users\\serfk\\Documents\\Thesis\\Daten\\Driving";
	static final String CORRECTION_FILE = "C:\\Users\\serfk\\Documents\\Thesis\\Data Analysis\\correction_values.csv";
	static final String STRAIGHT_SECTION =	"C:\\Users\\serfk\\Documents\\Thesis\\Daten\\Straight_Sections";
	
	public static void main(String[] args) 
    {   
    	categorizeGlances obj = new categorizeGlances();
    	
    	obj.run();
    }
	
    void run () {
		int trackIndex = 0;
		int straightSectionIndex = 0;
		//Tracks * No. of Sections * Start/End
		int[][][] straightSections = new int[10][18][2];
		
        File[] straightSectionFiles = new File(STRAIGHT_SECTION).listFiles();

        for (File file : straightSectionFiles) {
        	
        	trackIndex = Integer.parseInt(""+file.getName().split("\\.")[0]) - 1;

            try (Stream<String> lines = Files.lines(Paths.get(file.getAbsolutePath()))) {  
            	          
		    	for(String s : (Iterable<String>)lines::iterator) {  		        		

		        	String[] line = s.split("\\s+");
		        	
		        	straightSections[trackIndex][straightSectionIndex][0] = (int) Double.parseDouble(line[0]);
		        	straightSections[trackIndex][straightSectionIndex][1] = (int) Double.parseDouble(line[1]) + 1;
		        	
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
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
	
    	int startTime, endTime, duration, prevStartTime, prevEndTime, prevDuration;
    	    	
        // Iterate through files
        File[] files = new File(FOLDER_GLANCE).listFiles();

        for (File file : files) {
        	if(!file.isFile()) continue;
        	//output
            Path outputPath = Paths.get(FOLDER_GLANCE + "\\categorized\\" + file.getName());
            
            int i = startTime = endTime = duration = 0;
            ArrayList<int[]> data = new ArrayList<int[]>();
            
            String fileName = file.getName();
            
        	proband = Integer.parseInt(""+file.getName().charAt(0));
        	offset = offsets[proband-1];
            
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
                	i++;
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
    }

    // super inefficient ;_; - I know
	private int getTypeForGlance(int startTime, int endTime, int duration, int proband, int[][][] straightSections) {
		
		// Iterate through files
        File file = new File(FOLDER_DRIVING + "\\" + proband + "_wisch.txt");
                
        //read file
        try (Stream<String> lines = Files.lines(Paths.get(file.getAbsolutePath()))) {
        	
        	for(String s : (Iterable<String>)lines::iterator) {
        		   		        		
            	String[] line = s.split("\\s+");            	
            	if(line[0].equals("Zeit_in_s")) continue;  
            	
            	int track = Integer.parseInt(line[5])-1;
            	int currentTime = (int) (Double.parseDouble(line[0]) * 1000);
            	double y_pos = Double.parseDouble(line[2]);

            	if(startTime <= currentTime) {
                	
                	for(int k = 0; k < straightSections[track].length; k++) {
                    	if(y_pos <= straightSections[track][k][0]) break;
                    	
                    	if(y_pos >= straightSections[track][k][0] && y_pos <= straightSections[track][k][1]) {
                    		return 1;
                    	}
                    	
                	}	
                	return 0;
            	}
            	
        	}       		           	                	
        } catch (IOException ex) {
          	ex.printStackTrace();
        }
        
    	return 0;        
	}
}
