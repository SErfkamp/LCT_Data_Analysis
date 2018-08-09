
public class init {
	
	//WINDWOWS
	static final String PATH_SIGNS = "C:\\Users\\serfk\\OneDrive\\Thesis\\Auswertung\\LCTa - ISO26022\\LCTSigns.txt";
	static final String PATH_DRIVING = "C:\\Users\\serfk\\OneDrive\\Thesis\\Auswertung\\Daten\\Driving";
	static final String STRAIGHT_SECTION =	"C:\\\\Users\\\\serfk\\\\OneDrive\\\\Thesis\\\\Auswertung\\\\Daten\\\\Straight_Sections";
	static final String CORRECTION_FILE = "C:\\Users\\serfk\\OneDrive\\Thesis\\Auswertung\\Data Analysis\\correction_values.csv";
	static final String FOLDER_GLANCE = "C:\\Users\\serfk\\OneDrive\\Thesis\\Auswertung\\Daten\\Eye_tracking\\Corrected\\";
	static final String PATH_LCT = "C:\\Users\\serfk\\Documents\\Thesis\\opends45\\assets\\DrivingTasks\\Projects\\LaneChangeTest\\";

	//MACOS
//	static final String PATH_SIGNS = "C:\\Users\\serfk\\OneDrive\\Thesis\\Auswertung\\LCTa - ISO26022\\LCTSigns.txt";
//	static final String PATH_DRIVING = "C:\\Users\\serfk\\OneDrive\\Thesis\\Auswertung\\Daten\\Driving";
//	static final String STRAIGHT_SECTION =	"C:\\\\Users\\\\serfk\\\\OneDrive\\\\Thesis\\\\Auswertung\\\\Daten\\\\Straight_Sections";
//	static final String CORRECTION_FILE = "C:\\Users\\serfk\\OneDrive\\Thesis\\Auswertung\\Data Analysis\\correction_values.csv";
//	static final String FOLDER_GLANCE = "C:\\Users\\serfk\\OneDrive\\Thesis\\Auswertung\\Daten\\Eye_tracking\\Corrected\\";
//	static final String PATH_LCT = "C:\\Users\\serfk\\Documents\\Thesis\\opends45\\assets\\DrivingTasks\\Projects\\LaneChangeTest\\";
	
	
	static final int THRESHOLD = 199; //threshold in ms 


	
	public static void main(String[] args) {
		
    	createGlanceData obj1 = new createGlanceData(FOLDER_GLANCE);    	
    	obj1.run();
    	
    	correctErrors obj2 = new correctErrors(FOLDER_GLANCE + "output\\", THRESHOLD);    	
    	obj2.run();    	
    	
    	categorizeGlances obj3 = new categorizeGlances(FOLDER_GLANCE + "output\\" + "error_corrected\\", PATH_DRIVING, CORRECTION_FILE, STRAIGHT_SECTION);
    	obj3.run();
    	
    	//straightSectionPerformance obj4 = new straightSectionPerformance(PATH_DRIVING, STRAIGHT_SECTION, CORRECTION_FILE);    	
    	//obj4.run();
    	
    	//ConvertOpenDSLCTaskToSDefaultTask obj5 = new ConvertOpenDSLCTaskToSDefaultTask(PATH_SIGNS, PATH_LCT);	
    	//obj5.run();
	}
	
}
