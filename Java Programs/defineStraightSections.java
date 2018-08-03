package define_straight_sections;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Stream;


public class defineStraightSections {
	static final String PATH_SIGNS = "C:\\Users\\serfk\\Documents\\Thesis\\LCTa - ISO26022\\LCTSigns.txt";
	static final String PATH_OUTPUT = "C:\\Users\\serfk\\Documents\\Thesis\\Daten\\Straight_Sections";
	
	public static void main(String[] args) 
    {   
    	defineStraightSections obj = new defineStraightSections();
    	
    	obj.run();
    }
    
    void run () {
    	
    	int[] tracks = {0, 3335, 6510, 9783, 12985, 16279, 19525, 22843, 26113, 29383};
  	
    	List<String[]> signs = new ArrayList<String[]>();
    	
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
        for(int i = 0; i < tracks.length; i++) {
        	Path outputPath = Paths.get(PATH_OUTPUT, ""+ (i+1) + ".txt");
			try {
				Files.write(outputPath, "".getBytes(), StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}

			
            for (int j = 0; j < markerRange[i].size()-1; j+=2) {
            	String data = Math.round(markerRange[i].get(j) * 100) / 100.0  +"\t" + Math.round(markerRange[i].get(j+1) * 100) / 100.0  + System.getProperty("line.separator");
            	
                try {
					Files.write(outputPath, data.getBytes(), StandardOpenOption.APPEND);
				} catch (IOException e) {
					e.printStackTrace();
				}
            }
        }

        
        System.out.println(markerRange.toString());

    };
}
