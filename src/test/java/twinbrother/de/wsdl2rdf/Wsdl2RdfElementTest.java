package twinbrother.de.wsdl2rdf;

import static org.junit.Assert.*;

import java.io.File;

import org.junit.Test;

public class Wsdl2RdfElementTest {

	@Test
	public void testWsdl2RdfElement() {

	}

	@Test
	public void testGeRdfXmlFile() {

		ClassLoader classLoader = getClass().getClassLoader();
		File wsdlLocation = new File(classLoader.getResource("test.wsdl").getFile());
		File testFile = null;

		Wsdl2RdfInterface wsdl2rdf = new Wsdl2Rdf(new File("/GovRepDataFolder/"));
		try {
			Wsdl2RdfElement element = wsdl2rdf.importsingleFile(wsdlLocation);
			testFile = element.geRdfXmlFile();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		File outputfile = new File(Wsdl2Rdf.getWorkingDirectory().getAbsolutePath() + "/test.rdf");

		assertTrue(testFile.getAbsolutePath().equals(outputfile.getAbsolutePath()));

//		if (testFile != null) {
//			testFile.delete();
//		}
	}

	@Test
	public void testGetRdfTurtle() {

	}

	@Test
	public void testGetTargetNamespace() {
		ClassLoader classLoader = getClass().getClassLoader();
		File wsdlLocation = new File(classLoader.getResource("test.wsdl").getFile());
		String tns = "";
		File testFile = null;

		Wsdl2RdfInterface wsdl2rdf = new Wsdl2Rdf(new File("/GovRepDataFolder/"));
		try {
			Wsdl2RdfElement element = wsdl2rdf.importsingleFile(wsdlLocation);
			testFile = element.geRdfXmlFile();
			tns = element.getTargetNamespace();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		assertTrue(tns.equals("http://www.herongyang.com/Service/v1/"));
		
//		if (testFile != null) {
//			testFile.delete();
//		}
		
	}

}
