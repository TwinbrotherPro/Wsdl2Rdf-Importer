package twinbrother.de.wsdl2rdf;

import java.io.File;
import java.io.IOException;
import java.util.List;

import javax.xml.transform.TransformerConfigurationException;

public class Wsdl2Rdf implements Wsdl2RdfInterface {

	private static File workingDirectory = new File(System.getProperty("user.home") + "/wsdl2rdfWorkingdir/");

	public Wsdl2Rdf() {

		// Use default location
	}

	public Wsdl2Rdf(File workingDirectory) {
		Wsdl2Rdf.workingDirectory = new File(workingDirectory.getAbsolutePath() + "/wsdl2rdfWorkingdir/");
		if (!Wsdl2Rdf.workingDirectory.exists()) {
			System.out.println("Create dir");
			Wsdl2Rdf.workingDirectory.mkdir();
		}
	}

	public Wsdl2RdfElement importsingleFile(File location) throws Exception {
		return new Wsdl2RdfElement(location);
	}

	public List<Wsdl2RdfElement> importMultipleFiles(File location) {
		// TODO Check if file is a directory or archive containing wsdlFiles
		return null;
	}

	public static File getWorkingDirectory() {
		return workingDirectory;
	}

}
