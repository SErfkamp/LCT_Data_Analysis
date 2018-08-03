package straight_section_marker;



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


public class StraightMarker {
	
	static final String PATH_SIGNS = "C:\\Users\\serfk\\Documents\\Thesis\\LCTa - ISO26022\\LCTSigns.txt";
	static final String PATH_DRIVING = "C:\\Users\\serfk\\Documents\\Thesis\\Daten\\Driving";
	static final String CORRECTION_FILE = "C:\\Users\\serfk\\Documents\\Thesis\\Data Analysis\\correction_values.csv";

	public static void main(String[] args) 
    {   
    	StraightMarker obj = new StraightMarker();
    	
    	obj.run();
    }
    
    void run () {
    	
    	int[] tracks = {0, 3335, 6510, 9783, 12985, 16279, 19525, 22843, 26113, 29383};
  	
    	List<String[]> signs = new ArrayList<String[]>();
    	
    	
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
	
    	
        // Read LCTSign File
        // Track | LCNumber | LCType | Position
    	Path pathSigns = Paths.get(PATH_SIGNS);
        try (Stream<String> lines = Files.lines(pathSigns)) {
            lines.forEach(s ->
            {
            	signs.add(Arrays.copyOfRange(s.split("\\s+"), 1, 5));
            });
        } catch (IOException ex) {
          	ex.printStackTrace();
        }
        
        // Create List of Marker positions        
        ArrayList<Double>[] markerRange = (ArrayList<Double>[]) new ArrayList[10];
        
        for (int i = 0; i < tracks.length; i++) {
        	
        	int start_track = tracks[i];
        	ArrayList<Double> range = new ArrayList<Double>();
        	
        	for (String s[] : signs) {
        		
        		if(Integer.parseInt(s[0]) == i+1) {
        			
            		if(Integer.parseInt(s[1]) == 0) {
            			range.add(start_track + 150.0);
            			continue;
            		}
        			
            		double sign_pos = Double.parseDouble(s[3]);
                	range.add(start_track + sign_pos - 20);
            		range.add(start_track + sign_pos + 20);
    
        		} else {
        			continue;
        		}
        		
        	} 
        	
        	markerRange[i] = range;       	
        }
        
        for(int i = 0; i < markerRange.length; i++) {
        	System.out.println(markerRange[i].toString());
        }
        
        // Update Files
        
        // Iterate through files
        List<String> results = new ArrayList<String>();

        File[] files = new File(PATH_DRIVING).listFiles();

        for (File file : files) {
        	if(!file.isFile()) continue;
        	//output
            Path outputPath = Paths.get(PATH_DRIVING + "\\Driving_Straight\\" + file.getName());
            
            

            //current position in marker array
            int j = 0;
            int a = 2;
            
            proband = Integer.parseInt(file.getName().split("_")[0]);
            
        	//get track for file
            //read file
            try (Stream<String> lines = Files.lines(Paths.get(file.getAbsolutePath()))) {
            	
            	for(String s : (Iterable<String>)lines::iterator) {
            		    
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
                		
                		                	
                	int track = Integer.parseInt(line[5])-1;
                	
                	double y_pos = Double.parseDouble(line[2]);
                	double marker_pos = markerRange[track].get(j);
                	
                	if(y_pos > marker_pos && j < markerRange[track].size()-1) {
                		j++;
                		if (j%2==0) a++;
                	}
                	
                	int currentTime = (int) (Double.parseDouble(line[0]) * 1000);
                	             	
                	if (isUsingIVIS(currentTime, proband, usingTimestamps) || file.getName().split("_")[1].equals("base.txt")) {                		
	                	
	                	if(y_pos <= marker_pos && (j%2==1)) {
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
