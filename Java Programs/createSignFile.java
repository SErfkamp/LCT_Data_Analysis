
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.stream.Stream;


public class createSignFile {
	
	private String PATH_SIGNS;
	private String PATH_OUTPUT = "";

	static final String[] signDirections = {"Right","Center","Left"};
	int[][] lcTypes = new int[10][19];


	public createSignFile(String PATH_SIGNS, String PATH_LCT) {
		this.PATH_SIGNS = PATH_SIGNS;
		this.PATH_OUTPUT = "C:\\Users\\serfk\\Documents\\Thesis\\openDS_LCTSigns.txt";
	}

	void run () {
		
    	System.out.println("Start trackConvert");

    	
    	int[] tracks = {0, 3335, 6510, 9783, 12985, 16279, 19525, 22843, 26113, 29383};
    	double signs[][] = this.readSignsFromFile();
		// offset : difference between default track and openDS track
    	int offset;
        
			
			ArrayList<String> data = new ArrayList<String>();
				    	
	    	for (int i = 0; i < tracks.length; i++) {

    	    	if(i%2 == 0) {
    	    		//starting at 1 to skip start sign
    	    		for (int j = 1; j < signs[i].length; j++) {
    	    			
    	    			offset = 1650;
    	    			
    	    			double newSignPos = Math.round((offset-signs[i][j])*100.0)/100.0;
    	    			data.add((i+1) + ";" + newSignPos + ";" + lcTypes[i][j] + System.getProperty("line.separator"));
    	    		}
    	    	} else {
    	    		//starting at 1 to skip start sign
    	    		for (int j = 18; j > 0; j--) {
    	    			
    	    			offset = 1500;
    	    			
    	    			double newSignPos = Math.round((signs[i][19-j]-offset)*100.0)/100.0;
    	    			data.add((i+1) + ";" + newSignPos + ";" + lcTypes[i][19-j] + System.getProperty("line.separator"));
    	    		}  	    		
    	    	}
	    	}
	    	
	    	writeToNewFile(data);

    	System.out.println("End trackConvert");

    }
	
	private void writeToNewFile(ArrayList<String> data) {
		
    	Path outputPath = Paths.get(PATH_OUTPUT);
		try {
			Files.write(outputPath, "".getBytes(), StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
		} catch (IOException e1) {
			e1.printStackTrace();
		}

		
        for (int i = 0; i < data.size(); i++) {
        	String fileData = data.get(i);
        	
            try {
				Files.write(outputPath, fileData.getBytes(), StandardOpenOption.APPEND);
			} catch (IOException e) {
				e.printStackTrace();
			}
        }
		
	}
    
    private double[][] readSignsFromFile() {
    	double[][] signs = new double[10][19];
    	
        // Read LCTSign File
        // Track | LCNumber | LCType | Position

    	Path pathSigns = Paths.get(PATH_SIGNS);
    	
        try (Stream<String> lines = Files.lines(pathSigns)) {
            lines.forEach(s ->
            {        
            	int trackTemp = Integer.parseInt(s.split("\\s+")[1])-1; 
            	int signNo = Integer.parseInt(s.split("\\s+")[2]);
            	int lcType = Integer.parseInt(s.split("\\s+")[3]);
            	double pos = Double.parseDouble(s.split("\\s+")[4]); 
            	
            	signs[trackTemp][signNo] = pos;
            	lcTypes[trackTemp][signNo] = lcType;
            });
        } catch (IOException ex) {
          	ex.printStackTrace();
        }
        return signs;
    }


}