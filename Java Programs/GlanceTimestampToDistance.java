import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Scanner;
import java.util.stream.Stream;

public class GlanceTimestampToDistance {
	
	
	 private String FOLDER_GLANCE;
	 private String FOLDER_DRIVING;
	 private String CORRECTION_FILE;
	 private String LC_SECTION;
	 
	 private int[] lc_durations;
	
   public GlanceTimestampToDistance(String FOLDER_GLANCE, String FOLDER_DRIVING, String CORRECTION_FILE,
			String LC_SECTION) {
		this.FOLDER_GLANCE = FOLDER_GLANCE + "output" + File.separator + "error_corrected" + File.separator;
		this.FOLDER_DRIVING = FOLDER_DRIVING;
		this.CORRECTION_FILE = CORRECTION_FILE;
		this.LC_SECTION = LC_SECTION;
	}
  
   
   public void run() {
	   	System.out.println("Start GlanceTimestampToDistance");

	   // iterate through glance files
       File[] files = new File(FOLDER_GLANCE).listFiles((dir,name) -> !name.equals(".DS_Store"));
       

       for (File file : files) {
    	   
    	   if(!file.isFile()) continue;
    	       	   
    	   int proband = Integer.parseInt(""+file.getName().split("\\.")[0]) - 1;
    	   int offsets[] = getOffsets(); 

           Path outputPath = Paths.get(FOLDER_GLANCE + "distance" + File.separator + file.getName());
           
           ArrayList<double[]> data = new ArrayList<>();
           
           //read file
           try (Stream<String> lines = Files.lines(Paths.get(file.getAbsolutePath()))) {
           	
           	for(String s : (Iterable<String>)lines::iterator) {
           		        		
               	String[] line = s.split("\\s+");

               	if(line[0].equals("AOI")) { 
               		Files.write(outputPath,"".getBytes(), StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
               		continue;
               	}
               	
            	int startTime = Integer.parseInt(line[1]) - offsets[proband];
            	int endTime = Integer.parseInt(line[2]) - offsets[proband];
            	
            	data.add(getYPosFromTimestamp(startTime, endTime, proband));

           	}
           	
           	writeNewFile(data, outputPath);

           } catch (IOException ex) {
             	ex.printStackTrace();
           }

       }
   	System.out.println("End GlanceTimestampToDistance");
   }
   
   public int[] getOffsets() {
	   	int[] offsets = new int[31];
	   	
			Scanner scanner;
			try {
				scanner = new Scanner(new File(CORRECTION_FILE));
				scanner.useDelimiter("\r\n");
				while (scanner.hasNext()) {
				    String line = scanner.next();
				    String cells[] = line.split(";");   
				    
				    if(cells[0].equals("Proband")) continue;
				    				    
				    int proband = Integer.parseInt(cells[0])-1;
				    offsets[proband] = Integer.parseInt(cells[8]);

				}
			} catch (FileNotFoundException e1) {
				e1.printStackTrace();
			}
			
			return offsets;
	   }
	   

   
   // write to new file
   public void writeNewFile(ArrayList<double[]> data, Path outputPath) {
	  	for(double[] dataLine : data) {
	  		
       		String outputLine = dataLine[0] + "\t" + dataLine[1] + System.getProperty("line.separator");
	
            // write to new file
            try {
				Files.write(outputPath, outputLine.getBytes(), StandardOpenOption.APPEND);
			} catch (IOException e) {
				e.printStackTrace();
			}	       	
	   	}
	   	
	   
   }
   
	private double[] getYPosFromTimestamp(int startTime, int endTime, int proband) {
		double[] y_pos= {0.0,0.0};
		
		boolean start = true;
		
		// Get driving file for proband
        File file = new File(FOLDER_DRIVING + File.separator + (proband+1) + "_wisch.txt");
        
        //read file
        try (Stream<String> lines = Files.lines(Paths.get(file.getAbsolutePath()))) {
        	
        	for(String s : (Iterable<String>)lines::iterator) {

            	String[] line = s.split("\\s+");            	
            	if(line[0].equals("Zeit_in_s")) continue;  
            	
            	int currentTime = (int) (Double.parseDouble(line[0]) * 1000);

            	if(startTime <= currentTime && start) {
            		start = false;
            		y_pos[0] = Double.parseDouble(line[2]);
            	}
            	
            	if(endTime <= currentTime) {
            		y_pos[1] = Double.parseDouble(line[2]);
            		break;
            	}            	
        	}  
        } catch (IOException ex) {
          	ex.printStackTrace();
        }
        //System.out.println("getYPosFromTimestamp: " + y_pos[0] + " -- " + y_pos[1]);
    	return y_pos;

	}
}
