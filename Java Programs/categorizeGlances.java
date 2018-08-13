
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
	 
	 private int[] lc_durations;
	
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
		lc_durations = new int[31];
		
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
			    
            	lc_durations[offsetIndex] = Integer.parseInt(cells[14]);
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
            
            ArrayList<String[]> data = new ArrayList<String[]>();
            
        	proband = Integer.parseInt(file.getName().split("\\.")[0]) - 1;
        	offset = offsets[proband];
            
            //read file
            try (Stream<String> lines = Files.lines(Paths.get(file.getAbsolutePath()))) {
            	
            	for(String s : (Iterable<String>)lines::iterator) {
            		        		
                	String header ="";
                	String[] line = s.split("\\s+");

            		//write *header to output file and continue
                	//AOI	Start_Time	End_Time	Duration
                	if(line[0].equals("AOI")) {
                		header = "AOI\tStart_Time\tEnd_Time\tDuration\tStraight_Section\tLC_Start\tLC_During\tLC_end" + System.getProperty("line.separator");
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
                	double[] category = getTypeForGlance(startTime-offset, endTime-offset, duration, proband, straightSections);
                	String[] newLine = new String[]{""+startTime, ""+endTime, ""+duration, ""+category[0], ""+category[1], ""+category[2], ""+category[3]};
                	data.add(newLine);
                }
            	
            	for(String[] dataLine : data) {
            		String outputLine = "Tablet1\t" + dataLine[0] + "\t" + dataLine[1] + "\t" + dataLine[2]+ "\t" 
            				+ dataLine[3] + "\t" + dataLine[4] + "\t" + dataLine[5] + "\t" + dataLine[6]
            						+ System.getProperty("line.separator");
            				
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
	
    
	private double[] getTypeForGlance(int startTime, int endTime, int duration, int proband, int[][][][] straightSections) {
		
		// 0: distance Straight, 1: dist. LC Start, 2: dist. LC During, 3: dist. LC End
		double[] result = new double[4];

		double[] y_positions = getYPosFromTimestamp(startTime, endTime, proband);
		double glance_start = y_positions[0];
		double glance_end = y_positions[1];
						
		int lc_duration = lc_durations[proband];
		
		System.out.println("Proband" + " - " + proband+1 + " - LC Duration: " + lc_duration + " -  G_S: " + glance_start + " -  G_E: " + glance_end);


        for(int k = 0; k < straightSections[proband][1].length; k++) {
        	
        	int straight_start = straightSections[proband][1][k][0];
        	int straight_end = straightSections[proband][1][k][1];
        	
    		System.out.println("Section" + " - S:" + straight_start + " - E: " + straight_end);
        	
        	// Glance not in relevant area -> continue
        	if(glance_start > straight_end + lc_duration || glance_end < straight_start) continue;  
        	
        	// bounds for the 4 possible sections
        	double lowerBound = straight_start;
        	double upperBound = straight_end;
        	
        	//iterate through all 4 possible sections: straight, lc_start, lc_during, lc_end
        	for (int i = 0; i < 4; i++) {
        		double upperValue;
        		double lowerValue;
        		
        		if(glance_start <= upperBound && glance_end >= lowerBound) {
        			
            		if (glance_end > upperBound) {
            			upperValue = upperBound;
            		} else {
            			upperValue = glance_end;
            		}
            		
            		if(glance_start < lowerBound) {
            			lowerValue = lowerBound;
            		} else {
            			lowerValue = glance_start;
            		}
            		
            		//System.out.println("Values: " + lowerValue + " - " + upperValue);
            		
            		result[i] = Math.round(Math.abs(upperValue - lowerValue)*100d)/100d;
        		}      	
				
        		lowerBound = i == 0? straight_end : 
        					 i == 1? straight_end + 0.25 * lc_duration : 
        					 straight_end + 0.75 * lc_duration;
        		
        		upperBound = i == 0? lowerBound + 0.25 * lc_duration : 
					 		 i == 1? lowerBound + 0.5 * lc_duration : 
					 			 lowerBound + 0.25 * lc_duration;
        		
        		//System.out.println("Bounds : -" + lowerBound + " - " + upperBound);

			}
        }
        
        return result;
	}
        	
        	/*
        	
        	if(glance_start < straight_start && glance_end > straight_start && glance_end < straight_end) {
        		distStraight += Math.abs(glance_end - straight_start);
        	}
        	
        	if(glance_start > straight_start) {
        		if(glance_end > straight_end) {
        			distStraight += Math.abs(straight_end - glance_start);
        		} else {
        			distStraight += glance_duration;
        		}
        	}
        	
        	if(glance_start > straight_end) {
        		if(glance_start < lc_start_end) {
        			if (glance_end >= lc_start_end) {
            			distLCStart += Math.abs(lc_start_end - straight_end);
        			} else {
        				distLCStart += Math.abs(glance_end - glance_start);
        			}
        		}
        		
        		if(glance_end >= lc_start)
        	}
        	
        	if(glance_start >= straight_start && glance_end <= straight_end) {
        		distStraight += glance_duration;
        	}
        	
        	if(glance)
        	
    		double distStraight = straight_end - glance_start;
    		double distLC = glance_end - straight_end;
    		double distLCStart = glance_end - straight_end;
    		double distLCDuring = glance_end - straight_end;
    		double distLCEnd = glance_end - straight_end;

    		
    		
    		
    		

        	
        	// if start is already too small all following section will also be too big -> return 1;
        	if(glance_start <= straight_start) {
        		result[0] = 1;
        		return 1;
        	}
            	
        	if(glance_start >= straight_start && glance_start <= straight_end) {
        		if (glance_end <= straight_end) {
        			return 0;
        		}
        		
        		double distStraight = straight_end - glance_start;
        		double distLC = glance_end - straight_end;
        		
        		// if glance is longer in the straight section return it as straight section glance
        		return distStraight >= distLC ? 1 : 0;
        	}
        	prevSection_start = straight_start;
        	prevSection_end = straight_end;
        }
        
    	return 1;    
    	
  
		double glance_duration = lc_durations[proband];
			

        for(int k = 0; k < straightSections[proband][1].length; k++) {
        	
        	int section_start = straightSections[proband][1][k][0];
        	int section_end = straightSections[proband][1][k][1];
        	
    		
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
	
	private double[] getYPosFromTimestamp(int startTime, int endTime, int proband) {
		double[] y_pos= {0.0,0.0,0.0};
		
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
            		y_pos[2] = Double.parseDouble(line[5])-1;
            		break;
            	}            	
        	}  
        } catch (IOException ex) {
          	ex.printStackTrace();
        }
        System.out.println("getYPosFromTimestamp: " + y_pos[0] + " -- " + y_pos[1]);
    	return y_pos;

	}

}
