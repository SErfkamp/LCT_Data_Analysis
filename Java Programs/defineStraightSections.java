
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


public class defineStraightSections {
	private String PATH_SIGNS;
	private String PATH_OUTPUT;
	private String CORRECTION_FILE;
	
	
    public defineStraightSections(String PATH_SIGNS, String PATH_OUTPUT, String CORRECTION_FILE) {
		super();
		this.PATH_SIGNS = PATH_SIGNS;
		this.PATH_OUTPUT = PATH_OUTPUT;
		this.CORRECTION_FILE = CORRECTION_FILE;
	}

	void run () {
    	System.out.println("Start defineStraightSections");

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
            			Integer.parseInt(cells[11]),Integer.parseInt(cells[12])};
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
        	    	
        	for (int j = 0; j < signsCurrent_base.length-1; j++) {
        	
        		if(j==0) {
        			dataBase.add(start_track_base + 150.0);
        			continue;
        		}
        		
	    		sign_pos = signsCurrent_base[j];
	    		
	        	dataBase.add(start_track_base + sign_pos - lc_start);
	    		dataBase.add(start_track_base + sign_pos + lc_end);
        		
        	}
        	
        	for (int j = 0; j < signsCurrent_wisch.length-1; j++) {
            	
        		if(j==0) {
        			dataWisch.add(start_track_wisch + 150.0);
        			continue;
        		}
        		
	    		sign_pos = signsCurrent_wisch[j];
	    		
	        	dataWisch.add(start_track_wisch + sign_pos - lc_start);
	    		dataWisch.add(start_track_wisch + sign_pos + lc_end);
        		
        	}    
        	
        	
        	dataBase.add(start_track_base + sign_pos + 100.0);	
        	dataWisch.add(start_track_wisch + sign_pos + 100.0);	

        	
        	createFileForProband(i, dataBase, "base");
        	createFileForProband(i, dataWisch, "wisch");
        }
    	System.out.println("End defineStraightSections");

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
    
}
