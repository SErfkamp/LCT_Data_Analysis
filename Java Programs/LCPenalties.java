import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Locale;
import java.util.stream.Stream;

public class LCPenalties {
	
	 private String FOLDER_GLANCE;
	 private String OUTPUT_PATH;
	 private String LC_SECTION;
	 private String STRAIGHT_SECTION;
	 private String PATH_DRIVING;
	 private String IVIS_INPUTS;
	 private int DELAY_OFFSET;

	 
	 private boolean straight_penalties = false;

	
    public LCPenalties(String FOLDER_GLANCE, String LC_SECTION, String STRAIGHT_SECTION, String ONEDRIVE, String PATH_DRIVING, String IVIS_INPUTS) {
		this.FOLDER_GLANCE = FOLDER_GLANCE + "output" + File.separator + "error_corrected" + File.separator + "distance" + File.separator;
		this.LC_SECTION = LC_SECTION;
		this.STRAIGHT_SECTION = STRAIGHT_SECTION;
		
		if (straight_penalties) {
			this.OUTPUT_PATH = ONEDRIVE + "Auswertung" + File.separator + "Data Analysis" + File.separator + "straight_penalties.csv";
		} else {
			//this.OUTPUT_PATH = ONEDRIVE + "Auswertung" + File.separator + "Data Analysis" + File.separator + "offset_lc_penalties.csv";
			//this.OUTPUT_PATH = ONEDRIVE + "Auswertung" + File.separator + "Data Analysis" + File.separator + "lcend_penalties.csv";

			this.OUTPUT_PATH = ONEDRIVE + "Auswertung" + File.separator + "Data Analysis" + File.separator + "priorlc_penalties.csv";
		}
		
		this.DELAY_OFFSET = 0;

		this.PATH_DRIVING = PATH_DRIVING;
		this.IVIS_INPUTS = IVIS_INPUTS;
	}
	
	
	public void run() {

		double[] glancePenalties = new double[31];
		int[] interactionPenalties = new int[31];
		
		// iterate through every proband
		for (int i = 0; i < 31; i++) {
			
			System.out.println(i);
			
			if (i == 0) { 
		        Path outputPath = Paths.get(OUTPUT_PATH);

           		try {
           			String header = "Proband;LC;GlancePenalty;InteractionPenalty" + System.getProperty("line.separator");
					Files.write(outputPath,header.getBytes(), StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
           	}

			// iterate through penalties and push value in resultingArray
			glancePenalties = getGlancePenalties(i);
			interactionPenalties =  getInteractionPenalties(i);

			System.out.println("Done");
			writeToFile(i, glancePenalties, interactionPenalties);
		}
		
		
	}
	
	private void writeToFile(int proband, double[] glancePenalties, int[] interactionPenalties) {
		
        Path outputPath = Paths.get(OUTPUT_PATH);
		
	   // write to new file   		
	  	for(int lc = 0; lc < 18; lc++) {
	  			  		
	  		String germanLocalePenalty = DecimalFormat.getInstance(Locale.GERMANY).format(glancePenalties[lc]);
	  		
       		String outputLine = (proband+1) + ";" + (lc+1) + ";" + germanLocalePenalty + ";" + interactionPenalties[lc] + System.getProperty("line.separator");
	
            // write to new file
            try {
				Files.write(outputPath, outputLine.getBytes(), StandardOpenOption.APPEND);
			} catch (IOException e) {
				e.printStackTrace();
			}	       	
	   	}
			   	
		
	}


	public double[] getGlancePenalties(int proband) {
		
		double[][] sections = new double[18][2];
		ArrayList<double[]> glanceSections = new ArrayList<>();
		
		double[] glancePenalties = new double[18];
		
		// read lcSections File to get the area for penalties	
		
		if(straight_penalties) {
			sections = straightSection(proband+1);
		} else {
			//sections = lcSection(proband+1);
			//sections = lcEndSection(proband+1);
			sections = lcStartSection(proband+1);

		}
		glanceSections = glanceSections(proband+1);
		
		for (int i = 0; i < sections.length; i++) {
			
			// penalty for i-th lanechange
			double penalty = 0;
			
			double lcStart = sections[i][0];
			double lcEnd = sections[i][1];

			for (int j = 0; j < glanceSections.size(); j++) {
				
				double glanceStart = glanceSections.get(j)[0];
				double glanceEnd = glanceSections.get(j)[1];

				double lowerBound = lcStart; 
				double upperBound = glanceEnd;
				
				if(glanceEnd < lcStart) continue;
				if(glanceStart > lcEnd) break;
				
				
				lowerBound = Math.max(lcStart, glanceStart);
				upperBound = Math.min(glanceEnd, lcEnd);
				
				penalty += Math.round((upperBound - lowerBound) * 100d) / 100d;
				
			}
			
			glancePenalties[i] = penalty;
			
		}
		return glancePenalties;
		
	}
	
	public int[] getInteractionPenalties(int proband) {
		
		double[][] sections = new double[18][2];
		double[] interactions = getInteractionsPos(proband+1);
		
		int[] interactionPenalties = new int[18];
		
		// read lcSections File to get the area for penalties	
		
		if(straight_penalties) {
			sections = straightSection(proband+1);
		} else {
			//sections = lcSection(proband+1);
			//sections = lcEndSection(proband+1);
			sections = lcStartSection(proband+1);

		}

		
		for (int i = 0; i < sections.length; i++) {
			
			// penalty for i-th lanechange
			int penalty = 0;
			
			double secStart = sections[i][0];
			double secEnd = sections[i][1];

			for (int j = 0; j < interactions.length; j++) {
				
				double pos = interactions[j];
				
				if (pos < secStart) continue;
				if (pos > secEnd) break;
				
				penalty += 1;
				
			}
			
			interactionPenalties[i] = penalty;
			
		}
		return interactionPenalties;
		
	}
	
	private double[] getInteractionsPos(int proband) {
		
		ArrayList<Double> interactions = new ArrayList<>();
		
	    File file = new File(IVIS_INPUTS + File.separator + "IVIS Inputs - VP" + (proband) + ".csv");
	        
	        int i = 0;
	        int offset = 0;

		     try (Stream<String> lines = Files.lines(Paths.get(file.getAbsolutePath()))) {
		        	
		        	for(String s : (Iterable<String>)lines::iterator) {
		
		            	String[] line = s.split(",");  
		            	
		            	// 9080 ms is the time when probands cross the Start sign in the driving data
		            	if(line[3].equals("Start")) {
		            		offset = Integer.parseInt(line[5]) - 9080;
		            	}
		            	
		            	if(!line[3].equals("Input")) continue;

		            	try {
		            		int interactionTimestamp = Integer.parseInt(line[5]) - offset;
			            	interactions.add(getYPosFromTimestamp(interactionTimestamp, proband)[0]);		            	

		            	} catch (Exception e) {
		            		
		            	}
		            	
		        	}
		        	
		     } catch (IOException ex) {
		          	ex.printStackTrace();
		      }
		     
		//System.out.println(interactions.toString());
		        	
		return interactions.stream().mapToDouble(Double::doubleValue).toArray();
	}


	public double[][] lcSection(int proband) {
		double[][] lcSections = new double[18][2];
		
        File file = new File(LC_SECTION + File.separator + (proband) + "_wisch.txt");
        
        int i = 0;

	     try (Stream<String> lines = Files.lines(Paths.get(file.getAbsolutePath()))) {
	        	
	        	for(String s : (Iterable<String>)lines::iterator) {
	
	            	String[] line = s.split("\\s+");       
	            	
	            	lcSections[i][0] = Double.parseDouble(line[0])-DELAY_OFFSET;
	            	lcSections[i][1] = Double.parseDouble(line[1]);
	            	
	             	System.out.println(lcSections[i][0] + " - " + lcSections[i][1]);

	            	i++;
	        	}  
	        } catch (IOException ex) {
	          	ex.printStackTrace();
	        }
	     

		return lcSections;
		
	}
	
	public double[][] lcEndSection(int proband) {
		double[][] lcSections = new double[18][2];
		
        File file = new File(LC_SECTION + File.separator + (proband) + "_wisch.txt");
        
        int i = 0;

	     try (Stream<String> lines = Files.lines(Paths.get(file.getAbsolutePath()))) {
	        	
	        	for(String s : (Iterable<String>)lines::iterator) {
	
	            	String[] line = s.split("\\s+");       
	            	
	            	double sectionStart = Double.parseDouble(line[0]);
	            	double sectionFinish = Double.parseDouble(line[1]);
	            	
	            	double sectionLength = sectionFinish - sectionStart;
	            	
	            	// Penalties von den letzten 33% des Lane Change
	            	sectionStart = sectionFinish - (0.33 * sectionLength);
	            	
	            	lcSections[i][0] = sectionStart;
	            	lcSections[i][1] = sectionFinish;
	            	
	             	System.out.println(lcSections[i][0] + " - " + lcSections[i][1]);

	            	i++;
	        	}  
	        } catch (IOException ex) {
	          	ex.printStackTrace();
	        }
	     

		return lcSections;
		
	}
	
	public double[][] lcStartSection(int proband) {
		double[][] lcSections = new double[18][2];
		
        File file = new File(LC_SECTION + File.separator + (proband) + "_wisch.txt");
        
        int i = 0;

	     try (Stream<String> lines = Files.lines(Paths.get(file.getAbsolutePath()))) {
	        	
	        	for(String s : (Iterable<String>)lines::iterator) {
	
	            	String[] line = s.split("\\s+");       
	            	
	            	double sectionStart = Double.parseDouble(line[0]);
	            	double sectionFinish = Double.parseDouble(line[1]);
	            	
	            	// Penalties von 16 Meter (1 Sekunde) vor dem LC Beginn bis zum LC Beginn
	            	lcSections[i][0] = sectionStart - 16.66;
	            	lcSections[i][1] = sectionStart;
	            	
	             	System.out.println(lcSections[i][0] + " - " + lcSections[i][1]);

	            	i++;
	        	}  
	        } catch (IOException ex) {
	          	ex.printStackTrace();
	        }
	     

		return lcSections;
		
	}
	
	public double[][] straightSection(int proband) {
		double[][] straightSections = new double[18][2];
		
        File file = new File(STRAIGHT_SECTION + File.separator + (proband) + "_wisch.txt");
        
        int i = 0;

	     try (Stream<String> lines = Files.lines(Paths.get(file.getAbsolutePath()))) {
	        	
	        	for(String s : (Iterable<String>)lines::iterator) {
	
	            	String[] line = s.split("\\s+");       
	            	
	            	straightSections[i][0] = Double.parseDouble(line[0]);
	            	straightSections[i][1] = Double.parseDouble(line[1]);

	            	i++;
	        	}  
	        } catch (IOException ex) {
	          	ex.printStackTrace();
	        }
		
		return straightSections;
		
	}
	
	public ArrayList<double[]> glanceSections(int proband) {
		ArrayList<double[]> glanceSections = new ArrayList<>();
		
        File file = new File(FOLDER_GLANCE + File.separator + (proband) + ".txt");
        
        int i = 0;

	     try (Stream<String> lines = Files.lines(Paths.get(file.getAbsolutePath()))) {
	        	
	        	for(String s : (Iterable<String>)lines::iterator) {
	
	            	String[] line = s.split("\\s+");   
	            		            	
	            	double[] glance = {Double.parseDouble(line[0]), Double.parseDouble(line[1])};
	            	
	            	glanceSections.add(i, glance);

	            	i++;
	        	}  
	        } catch (IOException ex) {
	          	ex.printStackTrace();
	        }
		
		return glanceSections;
		
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
