package openDS_lc_task_to_default_tracks;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Scanner;
import java.util.stream.Stream;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
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
	
	static final String PATH_SIGNS = "C:\\Users\\serfk\\Documents\\Thesis\\LCTa - ISO26022\\LCTSigns.txt";
	static final String PATH_LCT = "C:\\Users\\serfk\\Documents\\Thesis\\opends45\\assets\\DrivingTasks\\Projects\\LaneChangeTest\\";


	public static void main(String[] args) {
		
    	ConvertOpenDSLCTaskToSDefaultTask obj = new ConvertOpenDSLCTaskToSDefaultTask();
    	
    	obj.run();
    }
    
    void run () {
    	
    	int[] tracks = {0, 3335, 6510, 9783, 12985, 16279, 19525, 22843, 26113, 29383};
    	double signs[][] = this.readSignsFromFile();
        
    	DocumentBuilderFactory f = DocumentBuilderFactory.newInstance();
    	DocumentBuilder b;
		try {
			b = f.newDocumentBuilder();
		
	    	Document doc = b.parse(new File(PATH_LCT + "scene.xml"));
	    	XPath xPath = XPathFactory.newInstance().newXPath();
	    	
	    	for (int i = 0; i < tracks.length; i++) {
	    		
	    		// offset : difference between default track and openDS track
    	    	int offset = 1650;
    	    	
    	    	if(i%2 == 0) {
    	    		//starting at 1 to skip start sign
    	    		for (int j = 1; j < signs[i].length; j++) {
    	    			
    	    			double newSignPos = offset-Math.round(signs[i][j]*100)/100.0;
    	    			String signString = j < 10 ? i + "0" + j : i + "" + j;
    	    			System.out.println(signString + " - " + signs[i][j] + " - " + newSignPos);
    	    	    	
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
    	    	    	
    	    	    	
    	    	    	signPosNodeLeft.setTextContent(""+newSignPos);	    
    	    	    	signPosNodeRight.setTextContent(""+newSignPos);	
    	    	    	signPosNode.setTextContent(""+newSignPos);
    	    	    	triggerBoxNode.setTextContent(""+ (newSignPos+40.0));

    	    	    	
    	    		}
    	    	} else {
    	    		//starting at 1 to skip start sign
    	    		for (int j = 18; j > 0; j--) {
    	    			
    	    			double newSignPos = offset-Math.round(signs[i][19-j]*100)/100.0;
    	    			String signString = j < 10 ? i + "0" + j : i + "" + j;
    	    			System.out.println(signString + " - " + signs[i][19-j] + " - " + newSignPos);
    	    	    	
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
    	    	    	
    	    	    	
    	    	    	signPosNodeLeft.setTextContent(""+newSignPos);	    
    	    	    	signPosNodeRight.setTextContent(""+newSignPos);	
    	    	    	signPosNode.setTextContent(""+newSignPos);
    	    	    	triggerBoxNode.setTextContent(""+ (newSignPos-40.0));

    	    	    	
    	    		}
    	    		
    	    		
    	    	}
    	    	
	    		
//    	    	Node triggerStartRecording = (Node) xPath
//    	    			.compile("//model[@id='triggerBox_S0" + i + "']/translation//entry[1]")
//    	    			.evaluate(doc, XPathConstants.NODE);
//    	    	
//    	    	Node triggerEndRecording = (Node) xPath
//    	    			.compile("//model[@id='triggerBox_E0" + i + "']/translation//entry[1]")
//    	    			.evaluate(doc, XPathConstants.NODE);
//    	    	
//    	    	triggerStartRecording.setTextContent("" + tracks[i]);
//    	    	triggerEndRecording.setTextContent("" + tracks[i]+signs[i][signs[i].length-1]);
//	    		
	    		//starting at 1 to skip start sign
//	    		for (int j = 1; j < signs[i].length-1; j++) {
//	    			
//	    			String newSignPos = ""+signs[i][j];
//	    			String signString = j < 9 ? i + "0" + (j+1) : i + "" + (j+1);
//	    			System.out.println(signString);
//	    	    	
//	    	    	//1.0 in Datenbanken2 - Kemper wäre stolz
//	    	    	Node signPosNodeLeft = (Node) xPath
//	    	    			.compile("//model[@id='LeftBoxSign" + signString + "']/translation//entry[1]")
//	    	    			.evaluate(doc, XPathConstants.NODE);
//	    	    	
//	    	    	Node signPosNodeRight = (Node) xPath
//	    	    			.compile("//model[@id='RightBoxSign" + signString + "']/translation//entry[1]")
//	    	    			.evaluate(doc, XPathConstants.NODE);
//	    	    	
//	    	    	Node signPosNode = (Node) xPath
//	    	    			.compile("//model[@id='Sign" + signString + "']/translation//entry[1]")
//	    	    			.evaluate(doc, XPathConstants.NODE);
//	    	    	
//	    	    	Node triggerBoxNode = (Node) xPath
//	    	    			.compile("//model[@id='triggerBox" + signString + "']/translation//entry[1]")
//	    	    			.evaluate(doc, XPathConstants.NODE);
//	    	    	
//	    	    	
//	    	    	signPosNodeLeft.setTextContent(newSignPos);	    
//	    	    	signPosNodeRight.setTextContent(newSignPos);	
//	    	    	signPosNode.setTextContent(newSignPos);
//	    	    	triggerBoxNode.setTextContent(newSignPos);
//
//	    	    	
//	    		}
//	    		
	    	}
	    	  			
	    	//write to file
			Transformer tf = TransformerFactory.newInstance().newTransformer();
			tf.setOutputProperty(OutputKeys.INDENT, "yes");
			tf.setOutputProperty(OutputKeys.METHOD, "xml");
			tf.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "4");
	
			DOMSource domSource = new DOMSource(doc);
			StreamResult sr = new StreamResult(new File(PATH_LCT + "scene.xml"));
			tf.transform(domSource, sr);
		
		} catch (ParserConfigurationException | XPathExpressionException | SAXException | IOException | TransformerFactoryConfigurationError | TransformerException e) {
			e.printStackTrace();
		}

    }
    
    private double[][] readSignsFromFile() {
    	double signs[][] = new double[10][19];
    	
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
        return signs;
    }


}