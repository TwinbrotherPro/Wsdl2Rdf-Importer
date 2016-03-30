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

import org.openrdf.model.Value;
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

public class Wsdl2RdfElement {

	private ClassLoader classLoader;;
	private final InputStream xsltFileLocation;
	private final File outputTarget;
	private URL url;

	public Wsdl2RdfElement(File wsdlFile) throws TransformerException {
		classLoader = getClass().getClassLoader();
		xsltFileLocation = classLoader.getResourceAsStream("wsdl20-rdf.xslt");
		url = classLoader.getResource("wsdl20-rdf.xslt");
		outputTarget = new File(
				Wsdl2Rdf.getWorkingDirectory().getAbsolutePath() + "/" + wsdlFile.getName().split("\\.")[0] + ".rdf");
		process(wsdlFile);
	}

	/**
	 * Process the given wsdlFile to rdf
	 * 
	 * @throws TransformerException
	 */
	private void process(File wsdlFile) throws TransformerException {

		Source source = new StreamSource(xsltFileLocation);
		source.setSystemId(url.toExternalForm());

		TransformerFactory tFactory = TransformerFactory.newInstance();
		Transformer transformer = tFactory.newTransformer(new StreamSource(xsltFileLocation));
		System.out.println("XSLT-Location:" + url);
		transformer.transform(new StreamSource(wsdlFile), new StreamResult(outputTarget));
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
