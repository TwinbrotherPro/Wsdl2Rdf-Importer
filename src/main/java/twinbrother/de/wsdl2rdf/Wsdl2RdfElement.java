package twinbrother.de.wsdl2rdf;

import java.io.File;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

public class Wsdl2RdfElement {

	private ClassLoader classLoader;;
	private final File xsltFileLocation;
	private final File outputTarget;

	public Wsdl2RdfElement(File wsdlFile) throws TransformerException {
		classLoader = getClass().getClassLoader();
		xsltFileLocation = new File(classLoader.getResource("wsdl20-rdf.xslt").getFile());
		outputTarget = new File(
				Wsdl2Rdf.getWorkingDirectory().getAbsolutePath() + "/" + wsdlFile.getName().split("\\.")[0] + ".rdf");
		process(wsdlFile);
	}

	/**
	 * Process the given wsdlFile to rdf
	 * @throws TransformerException 
	 */
	private void process(File wsdlFile) throws TransformerException {

		TransformerFactory tFactory = TransformerFactory.newInstance();
		Transformer transformer = tFactory.newTransformer(new StreamSource(xsltFileLocation));
		transformer.transform(new StreamSource(wsdlFile), new StreamResult(outputTarget));
	}

	/**
	 * Returns the created RDF/XML file
	 * 
	 * @return
	 */
	public File geRdfXmlFile() {

		return outputTarget;

	}

	/**
	 * Transforms the created RDF/XML in turtle format
	 * 
	 * @return
	 */
	public File getRdfTurtle() {
		// TODO Not implemented yet
		return null;
	}

}
