package twinbrother.de.wsdl2rdf.exception;

public class Wsdl2RdfException extends Exception {

	/**
	 * Versioning through Maven releases
	 * 
	 * current: 0.0.1
	 */
	private static final long serialVersionUID = 001;

	private String additionalInformation = "";

	public Wsdl2RdfException() {
		super();
	}

	public Wsdl2RdfException(String errorMessage) {
		super(errorMessage);
	}

	public Wsdl2RdfException(String errorMessage, String additionalInformation) {
		super(errorMessage);
		this.additionalInformation = additionalInformation;
	}

	public String getAdditionalInformation() {
		return additionalInformation;
	}

}
