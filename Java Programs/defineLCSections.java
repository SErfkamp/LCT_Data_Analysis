
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Scanner;
import java.util.stream.Stream;


public class defineLCSections {
	private String PATH_SIGNS;
	private String PATH_OUTPUT;
	private String CORRECTION_FILE;	
	private String PATH_DRIVING;
	
    public defineLCSections(String PATH_SIGNS, String PATH_OUTPUT, String CORRECTION_FILE, String PATH_DRIVING) {
		super();
		this.PATH_SIGNS = PATH_SIGNS;
		this.PATH_OUTPUT = PATH_OUTPUT;
		this.CORRECTION_FILE = CORRECTION_FILE;
		this.PATH_DRIVING = PATH_DRIVING;
	}

	void run () {
    	System.out.println("Start defineLCSections");

    	int[] tracks = {0, 3335, 6510, 9783, 12985, 16279, 19525, 22843, 26113, 29383};
  	
    	double signs[][] = new double[10][19];
    	
    	
    	// Read correction values file
		int correction_values[][] = new int[31][7];
		int proband;
		
		Scanner scanner;
		try {
			scanner = new Scanner(new File(CORRECTION_FILE));
			scanner.useDelimiter("\r\n");
			while (scanner.hasNext()) {
			    String line = scanner.next();
			    String cells[] = line.split(";");   
			    
			    if(cells[0].equals("Proband")) continue;
			    
			    proband = Integer.parseInt(cells[0])-1;
			    
            	correction_values[proband] = new int[] {
            			//LC_start , LC_end
            			Integer.parseInt(cells[9]),Integer.parseInt(cells[10]),
            			//track_base, track_wisch
            			Integer.parseInt(cells[11]),Integer.parseInt(cells[12]),
            			
            			//start_1, end_1
            			Integer.parseInt(cells[2]),Integer.parseInt(cells[3]),
            	
		    			//start_2, end_2
		    			Integer.parseInt(cells[4]),Integer.parseInt(cells[5]),
		    			
		    			//start_3, end_3
		    			Integer.parseInt(cells[6]),Integer.parseInt(cells[7])};
		            	
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
            	int trackTemp = Integer.parseInt(s.split("\\s+")[1])-1; 
            	int signNo = Integer.parseInt(s.split("\\s+")[2]);
            	//int lcType = Integer.parseInt(s.split("\\s+")[3]);
            	double pos = Double.parseDouble(s.split("\\s+")[4]); 
            	
            	signs[trackTemp][signNo] = pos;
            });
        } catch (IOException ex) {
          	ex.printStackTrace();
        }
        
        
        for (int i = 0; i < correction_values.length ; i++) {
        	
        	ArrayList<Double> range = new ArrayList<Double>();
        	
        	int lc_start = correction_values[i][0];
        	int lc_end = correction_values[i][1];
        	
        	int track_base = correction_values[i][2]-1;
        	int track_wisch = correction_values[i][3]-1;
        	
        	int start_track_base = tracks[track_base];
        	int start_track_wisch = tracks[track_wisch];
        	
        	double sign_pos = 0.0;

        	double[] signsCurrent_base = signs[track_base];
        	double[] signsCurrent_wisch = signs[track_wisch];
        	
        	ArrayList<Double> dataBase = new ArrayList<Double>();
        	ArrayList<Double> dataWisch = new ArrayList<Double>();;
        	    	
        	for (int j = 1; j < signsCurrent_base.length; j++) {
        		
	    		sign_pos = signsCurrent_base[j];
	    		
	        	dataBase.add(start_track_base + sign_pos - lc_start);
	    		dataBase.add(start_track_base + sign_pos + lc_end);
        		
        	}
        	
        	for (int j = 1; j < signsCurrent_wisch.length; j++) {
            	     		
	    		sign_pos = signsCurrent_wisch[j];
	    		
	        	dataWisch.add(start_track_wisch + sign_pos - lc_start);
	    		dataWisch.add(start_track_wisch + sign_pos + lc_end);
        		
        	}    
        	
        	
        	dataBase.add(start_track_base + sign_pos + 100.0);	
        	dataWisch.add(start_track_wisch + sign_pos + 100.0);	

        	
        	createFileForProband(i, dataBase, "base");
        	createFileForProband(i, dataWisch, "wisch");
        }
    	System.out.println("End defineLCSections");

    }
    
    private void createFileForProband(int proband, ArrayList<Double> data, String run) {
        // write to files
    	Path outputPath = Paths.get(PATH_OUTPUT, ""+ (proband+1) + "_" + run + ".txt");
		try {
			Files.write(outputPath, "".getBytes(), StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
		} catch (IOException e1) {
			e1.printStackTrace();
		}

		
        for (int j = 0; j < data.size()-1; j+=2) {
        	String fileData = data.get(j) +"\t" + data.get(j+1)  + System.getProperty("line.separator");
        	
            try {
				Files.write(outputPath, fileData.getBytes(), StandardOpenOption.APPEND);
			} catch (IOException e) {
				e.printStackTrace();
			}
        }
    }
    
    
	private double[] getYPosFromTimestamp(int startTime, int proband) {
		double[] y_pos= {0.0,0.0};
		
		boolean start = true;
		
		// Get driving file for proband
        File file = new File(PATH_DRIVING + File.separator + (proband) + "_wisch.txt");
        
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
          	
        	}  
        } catch (IOException ex) {
          	ex.printStackTrace();
        }
        //System.out.println("getYPosFromTimestamp: " + y_pos[0] + " -- " + y_pos[1]);
    	return y_pos;

	}
    
}
