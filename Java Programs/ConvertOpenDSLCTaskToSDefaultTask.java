
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.stream.Stream;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.xml.sax.SAXException;


public class ConvertOpenDSLCTaskToSDefaultTask {
	
	private String PATH_SIGNS = "C:\\Users\\serfk\\Documents\\Thesis\\LCTa - ISO26022\\LCTSigns.txt";
	private String PATH_LCT = "C:\\Users\\serfk\\Documents\\Thesis\\opends45\\assets\\DrivingTasks\\Projects\\LaneChangeTest\\";
	static final String[] signDirections = {"Right","Center","Left"};
	int[][] lcTypes = new int[10][19];


	public ConvertOpenDSLCTaskToSDefaultTask(String PATH_SIGNS, String PATH_LCT) {
		this.PATH_SIGNS = PATH_SIGNS;
		this.PATH_LCT = PATH_LCT;
	}

	void run () {
		
    	System.out.println("Start trackConvert");

    	
    	int[] tracks = {0, 3335, 6510, 9783, 12985, 16279, 19525, 22843, 26113, 29383};
    	double signs[][] = this.readSignsFromFile();
		// offset : difference between default track and openDS track
    	int offset;
        
    	DocumentBuilderFactory f = DocumentBuilderFactory.newInstance();
    	DocumentBuilder b,b2;
		try {
			b = f.newDocumentBuilder();
			//b2 = f.newDocumentBuilder();
			
	    	Document doc = b.parse(new File(PATH_LCT + "scene.xml"));
	    	XPath xPath = XPathFactory.newInstance().newXPath();
	    	
	    	//Document docScenario = b2.parse(new File(PATH_LCT + "scenario.xml"));
	    	//XPath xPathScenario = XPathFactory.newInstance().newXPath();
	    	
	    	for (int i = 0; i < tracks.length; i++) {	
    	    	
    	    	/*Node idealTrackNode = (Node) xPathScenario
    	    			.compile("//idealTrack[@id='lane0" + i + "']/point[@ref='point_0" + i + "_00']//entry[3]")
    	    			.evaluate(docScenario, XPathConstants.NODE);
    	    	
    	    	double middleOfTrack = Double.parseDouble(idealTrackNode.getTextContent());
    	    	
    	    	System.out.println(idealTrackNode.getTextContent());
    	    	System.out.println(middleOfTrack);
    	    	
    	    	Node roadNode = (Node) xPathScenario
    	    			.compile("//road")
    	    			.evaluate(docScenario, XPathConstants.NODE);
    	    	
    	    	Node xMin = docScenario.createElement("xMin");
    	    	Node xMax = docScenario.createElement("xMax");
    	    	
    	    	double xMinD = Math.round((middleOfTrack - 5.775)*1000)/1000.0;
    	    	double xMaxD = Math.round((middleOfTrack + 5.775)*1000)/1000.0;
    	    	
    	    	xMin.setTextContent( xMinD + "");
    	    	xMax.setTextContent( xMaxD + "");
    	    	
    	    	Node newLaneNode = docScenario.createElement("lane");
    	    	newLaneNode.appendChild(xMin);
    	    	newLaneNode.appendChild(xMax);
    	    	
    	    	roadNode.appendChild(newLaneNode);
    	    	*/
	    		

    	    	
    	    	if(i%2 == 0) {
    	    		//starting at 1 to skip start sign
    	    		for (int j = 1; j < signs[i].length; j++) {
    	    			
    	    			offset = 1650;
    	    			
    	    			double newSignPos = Math.round((offset-signs[i][j])*100.0)/100.0;
    	    			String signString = j < 10 ? i + "0" + j : i + "" + j;
    	    			String newSignDirection = "Scenes/SLCTask/Sign_" + signDirections[lcTypes[i][j]] + ".scene";
    	    			System.out.println(signString + " - " + signs[i][19-j] + " - " + newSignPos  + " - " + newSignDirection);
    	    	    	
    	    	    	Node signPosNodeLeft = (Node) xPath
    	    	    			.compile("//model[@id='LeftBoxSign" + signString + "']/translation//entry[1]")
    	    	    			.evaluate(doc, XPathConstants.NODE);
    	    	    	
    	    	    	Node signPosNodeRight = (Node) xPath
    	    	    			.compile("//model[@id='RightBoxSign" + signString + "']/translation//entry[1]")
    	    	    			.evaluate(doc, XPathConstants.NODE);
    	    	    	
    	    	    	Node signPosNode = (Node) xPath
    	    	    			.compile("//model[@id='Sign" + signString + "']/translation//entry[1]")
    	    	    			.evaluate(doc, XPathConstants.NODE);
    	    	    	
    	    	    	Node triggerBoxNode = (Node) xPath
    	    	    			.compile("//model[@id='triggerBox" + signString + "']/translation//entry[1]")
    	    	    			.evaluate(doc, XPathConstants.NODE);
    	    	    	
    	    	    	Node lcTypeNode = (Node) xPath
    	    	    			.compile("//model[@id='Sign" + signString + "']")
    	    	    			.evaluate(doc, XPathConstants.NODE);
    	    	    	
    	    	    	
    	    	    	Node lcNode = lcTypeNode.getAttributes().getNamedItem("key");	    	    	    	
    	    	    	lcNode.setTextContent(newSignDirection);
    	    	    	
    	    	    	signPosNodeLeft.setTextContent(""+newSignPos);	    
    	    	    	signPosNodeRight.setTextContent(""+newSignPos);	
    	    	    	signPosNode.setTextContent(""+newSignPos);
    	    	    	triggerBoxNode.setTextContent(""+ (newSignPos+40.0));

    	    		}
    	    	} else {
    	    		//starting at 1 to skip start sign
    	    		for (int j = 18; j > 0; j--) {
    	    			
    	    			offset = 1500;
    	    			
    	    			double newSignPos = Math.round((signs[i][19-j]-offset)*100.0)/100.0;
    	    			String signString = j < 10 ? i + "0" + j : i + "" + j;
    	    			String newSignDirection = "Scenes/SLCTask/Sign_" + signDirections[Math.abs(lcTypes[i][19-j]-2)] + ".scene";
    	    			//System.out.println(signString + " - " + signs[i][19-j] + " - " + newSignPos  + " - " + newSignDirection);
    	    			
    	    			//1.0 in Datenbanken2 - Kemper wäre stolz
    	    	    	Node signPosNodeLeft = (Node) xPath
    	    	    			.compile("//model[@id='LeftBoxSign" + signString + "']/translation//entry[1]")
    	    	    			.evaluate(doc, XPathConstants.NODE);
    	    	    	
    	    	    	Node signPosNodeRight = (Node) xPath
    	    	    			.compile("//model[@id='RightBoxSign" + signString + "']/translation//entry[1]")
    	    	    			.evaluate(doc, XPathConstants.NODE);
    	    	    	
    	    	    	Node signPosNode = (Node) xPath
    	    	    			.compile("//model[@id='Sign" + signString + "']/translation//entry[1]")
    	    	    			.evaluate(doc, XPathConstants.NODE);
    	    	    	
    	    	    	Node triggerBoxNode = (Node) xPath
    	    	    			.compile("//model[@id='triggerBox" + signString + "']/translation//entry[1]")
    	    	    			.evaluate(doc, XPathConstants.NODE);
    	    	    	
    	    	    	Node lcTypeNode = (Node) xPath
    	    	    			.compile("//model[@id='Sign" + signString + "']")
    	    	    			.evaluate(doc, XPathConstants.NODE);
    	    	    	
    	    	    	Node lcNode = lcTypeNode.getAttributes().getNamedItem("key");	    	    	    	
    	    	    	lcNode.setTextContent(newSignDirection);
    	    	    	
    	    	    	signPosNodeLeft.setTextContent(""+newSignPos);	    
    	    	    	signPosNodeRight.setTextContent(""+newSignPos);	
    	    	    	signPosNode.setTextContent(""+newSignPos);
    	    	    	triggerBoxNode.setTextContent(""+ (newSignPos-40.0));
	    	    	
    	    		}  	    		
    	    	}
	    	}
    	    	
	    					
	    	//write to file
			Transformer tf = TransformerFactory.newInstance().newTransformer();
			tf.setOutputProperty(OutputKeys.INDENT, "yes");
			tf.setOutputProperty(OutputKeys.METHOD, "xml");
			tf.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "4");
	
			DOMSource domSource = new DOMSource(doc);
			StreamResult sr = new StreamResult(new File(PATH_LCT + "scene.xml"));
			tf.transform(domSource, sr);
			
			//DOMSource domSourceScenario = new DOMSource(docScenario);
			//StreamResult srScenario = new StreamResult(new File(PATH_LCT + "scenario.xml"));
			//tf.transform(domSourceScenario, srScenario);
		
		} catch (ParserConfigurationException | XPathExpressionException | SAXException | IOException | TransformerFactoryConfigurationError | TransformerException e) {
			e.printStackTrace();
		}
    	System.out.println("End trackConvert");

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