package twinbrother.de.wsdl2rdf;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;

import org.openrdf.query.BindingSet;
import org.openrdf.query.MalformedQueryException;
import org.openrdf.query.QueryEvaluationException;
import org.openrdf.query.QueryLanguage;
import org.openrdf.query.TupleQuery;
import org.openrdf.query.TupleQueryResult;
import org.openrdf.repository.Repository;
import org.openrdf.repository.RepositoryConnection;
import org.openrdf.repository.RepositoryException;
import org.openrdf.repository.sail.SailRepository;
import org.openrdf.rio.RDFFormat;
import org.openrdf.rio.RDFParseException;
import org.openrdf.sail.memory.MemoryStore;
import org.xml.sax.SAXException;

import twinbrother.de.wsdl2rdf.exception.Wsdl2RdfException;

public class Wsdl2RdfElement {

	private ClassLoader classLoader;;
	private final InputStream xsltFileLocation;
	private final File outputTarget;
	private URL url;

	public Wsdl2RdfElement(File wsdlFile) throws Wsdl2RdfException {
		classLoader = getClass().getClassLoader();
		xsltFileLocation = classLoader.getResourceAsStream("wsdl20-rdf.xslt");
		url = classLoader.getResource("wsdl20-rdf.xslt");
		outputTarget = new File(
				Wsdl2Rdf.getWorkingDirectory().getAbsolutePath() + "/" + wsdlFile.getName().split("\\.")[0] + ".rdf");
		try {
			process(wsdlFile);
		} catch (TransformerException e) {
			throw new Wsdl2RdfException(e.getMessage());
		}
	}

	/**
	 * Process the given wsdlFile to rdf
	 * 
	 * @throws TransformerException
	 * @throws Wsdl2RdfException
	 */
	private void process(File wsdlFile) throws TransformerException, Wsdl2RdfException {

		validate(wsdlFile);

		System.out.println("Start parcing file: " + wsdlFile.getName());

		Source source = new StreamSource(xsltFileLocation);
		source.setSystemId(url.toExternalForm());

		TransformerFactory tFactory = TransformerFactory.newInstance();
		Transformer transformer = tFactory.newTransformer(new StreamSource(xsltFileLocation));
		System.out.println("XSLT-Location:" + url);
		transformer.transform(new StreamSource(wsdlFile), new StreamResult(outputTarget));
	}

	/**
	 * Validates the given file against a WSDL 2.0 Schema
	 * 
	 * @param wsdlFile
	 *            the assumed WSDL 2.0 file
	 * @throws Wsdl2RdfException
	 *             is thrown if the given file is no valid WSDL 2.0 file
	 */
	private void validate(File wsdlFile) throws Wsdl2RdfException {

		System.out.println("Validating file: " + wsdlFile.getName());

		ClassLoader classLoader = getClass().getClassLoader();
		File schemaLocation = new File(classLoader.getResource("wsdl20.xsd").getFile());

		SchemaFactory factory = SchemaFactory.newInstance("http://www.w3.org/2001/XMLSchema");

		try {
			Schema xsdSchema = factory.newSchema(schemaLocation);
			Validator validator = xsdSchema.newValidator();
			validator.validate(new StreamSource(wsdlFile));
		} catch (SAXException e) {
			// Validator will ignore schema specification of types, includes and
			// imports
			//e.printStackTrace();
			throw new Wsdl2RdfException("The given WSDL File is no correct WSDL 2.0 File", e.getMessage());
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * Retrieves the targetNameSpace of the imported WSDL Document
	 * 
	 * @return String the targetNamespace of the given WSDL Document
	 * @throws RepositoryException
	 * @throws IOException
	 * @throws RDFParseException
	 * @throws QueryEvaluationException
	 * @throws MalformedQueryException
	 */
	public String getTargetNamespace() throws RepositoryException, RDFParseException, IOException,
			QueryEvaluationException, MalformedQueryException {

		String targetNamespace = "";

		Repository repo = new SailRepository(new MemoryStore());
		repo.initialize();

		RepositoryConnection con = repo.getConnection();

		try {
			con.add(geRdfXmlFile(), "http://TODO", RDFFormat.RDFXML);
			String queryString = "PREFIX rwsdl: <http://www.w3.org/2005/10/wsdl-rdf#> "
					+ "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> "
					+ "SELECT DISTINCT * where {?s rdf:type rwsdl:Description}";
			TupleQuery tupleQuery = con.prepareTupleQuery(QueryLanguage.SPARQL, queryString);

			TupleQueryResult result = tupleQuery.evaluate();
			try {
				while (result.hasNext()) { // iterate over the result
					BindingSet bindingSet = result.next();
					String valueOfS = bindingSet.getValue("s").stringValue();

					targetNamespace = valueOfS.split("#")[0];

					break;
				}
			} finally {
				result.close();
			}
		} finally {
			con.close();
		}

		return targetNamespace;
	}

	/**
	 * Returns the created RDF/XML file
	 * 
	 * @return an RDF/XML File
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
