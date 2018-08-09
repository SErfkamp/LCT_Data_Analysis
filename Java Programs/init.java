import java.io.File;

public class init {
	
	static final String HOME = System.getProperty("user.home") + File.separator;
	static final String ONEDRIVE = HOME + "OneDrive" + File.separator + "Thesis" + File.separator;
	
	static final String PATH_SIGNS = ONEDRIVE + "Auswertung" + File.separator + 
			"LCTa - ISO26022" + File.separator + "LCTSigns.txt";
	
	static final String PATH_DRIVING = ONEDRIVE + "Auswertung" + File.separator + 
			"Daten" + File.separator + "Driving";
			
			
	static final String STRAIGHT_SECTION = ONEDRIVE + "Auswertung" + File.separator + 
			"Daten" + File.separator + "Straight_Sections";
				
	static final String CORRECTION_FILE = ONEDRIVE + "Auswertung" + File.separator + 
			"Data Analysis" + File.separator + "correction_values.csv";
			
	static final String FOLDER_GLANCE = ONEDRIVE + "Auswertung" + File.separator + 
			"Daten" + File.separator + "Eye_tracking" + File.separator + "Corrected" + File.separator;
			
			
	static final String PATH_LCT = HOME + File.separator + "opends45" + File.separator +
			"assets" + File.separator + "DrivingTasks" + File.separator + "Projects" + 
			File.separator + "LaneChangeTest" + File.separator;
	
//	static final String PATH_SIGNS = "C:\\Users\\serfk\\OneDrive\\Thesis\\Auswertung\\LCTa - ISO26022\\LCTSigns.txt";
//	static final String PATH_DRIVING = "C:\\Users\\serfk\\OneDrive\\Thesis\\Auswertung\\Daten\\Driving";
//	static final String STRAIGHT_SECTION =	"C:\\\\Users\\\\serfk\\\\OneDrive\\\\Thesis\\\\Auswertung\\\\Daten\\\\Straight_Sections";
//	static final String CORRECTION_FILE = "C:\\Users\\serfk\\OneDrive\\Thesis\\Auswertung\\Data Analysis\\correction_values.csv";
//	static final String FOLDER_GLANCE = "C:\\Users\\serfk\\OneDrive\\Thesis\\Auswertung\\Daten\\Eye_tracking\\Corrected\\";
//	static final String PATH_LCT = "C:\\Users\\serfk\\Documents\\Thesis\\opends45\\assets\\DrivingTasks\\Projects\\LaneChangeTest\\";
	
	
	static final int THRESHOLD = 199; //threshold in ms 


	
	public static void main(String[] args) {
		
		System.out.println(HOME);
		System.out.println(FOLDER_GLANCE);
		System.out.println(STRAIGHT_SECTION);
		System.out.println(PATH_DRIVING);
		System.out.println(PATH_LCT);
		System.out.println(PATH_SIGNS);
		System.out.println(CORRECTION_FILE);


		
    	createGlanceData obj1 = new createGlanceData(FOLDER_GLANCE);    	
    	obj1.run();
    	
    	correctErrors obj2 = new correctErrors(FOLDER_GLANCE + "output" + File.separator, THRESHOLD);    	
    	obj2.run();    	
    	
    	categorizeGlances obj3 = new categorizeGlances(FOLDER_GLANCE + "output" + File.separator + "error_corrected" + File.separator, PATH_DRIVING, CORRECTION_FILE, STRAIGHT_SECTION);
    	obj3.run();
    	
    	//straightSectionPerformance obj4 = new straightSectionPerformance(PATH_DRIVING, STRAIGHT_SECTION, CORRECTION_FILE);    	
    	//obj4.run();
    	
    	//ConvertOpenDSLCTaskToSDefaultTask obj5 = new ConvertOpenDSLCTaskToSDefaultTask(PATH_SIGNS, PATH_LCT);	
    	//obj5.run();
	}
	
}
