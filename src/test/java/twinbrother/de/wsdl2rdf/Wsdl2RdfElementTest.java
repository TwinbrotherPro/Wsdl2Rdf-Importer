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
		
		Wsdl2RdfInterface wsdl2rdf = new Wsdl2Rdf(new File("/GovRepDataFolder/"));
		try {
			Wsdl2RdfElement element = wsdl2rdf.importsingleFile(wsdlLocation);
			element.geRdfXmlFile();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		File outputfile = new File(Wsdl2Rdf.getWorkingDirectory().getAbsolutePath() + "/test.rdf");
		System.out.println(outputfile.getAbsolutePath());
		
		assertTrue(outputfile.exists());
		
		//outputfile.delete();
	}

	@Test
	public void testGetRdfTurtle() {
		
	}

}
