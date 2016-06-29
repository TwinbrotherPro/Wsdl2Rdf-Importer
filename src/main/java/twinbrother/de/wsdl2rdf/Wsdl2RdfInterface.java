package twinbrother.de.wsdl2rdf;

import java.io.File;
import java.util.List;

import twinbrother.de.wsdl2rdf.exception.Wsdl2RdfException;

public interface Wsdl2RdfInterface {
	
	/**
	 * Takes a given wsdl file
	 * 
	 * @param location of the given WSDL file
	 * @return {@link Wsdl2RdfElement} for further working with the file
	 * @throws Exception 
	 */
	public Wsdl2RdfElement importSingleFile(File location) throws Wsdl2RdfException;
	
	/**
	 * Takes a given folder or archive and extracts the WSDL files
	 * 
	 * @param location can either be a folder or archive
	 * @return collection of {@link Wsdl2RdfElement}
	 */
	public List<Wsdl2RdfElement> importMultipleFiles(File location);
	
	
}
