package twinbrother.de.wsdl2rdf;

import java.io.File;
import java.util.List;

import twinbrother.de.wsdl2rdf.exception.Wsdl2RdfException;

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

	public Wsdl2RdfElement importSingleFile(File location) throws Wsdl2RdfException {
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
