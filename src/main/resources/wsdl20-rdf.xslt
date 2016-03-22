<!-- NOTE: when changing namespace of the ontology, also change it below 
	in the file -->
<xsl:stylesheet version="1.0" xmlns:wsdl="http://www.w3.org/ns/wsdl"
	xmlns:rwsdl="http://www.w3.org/2005/10/wsdl-rdf#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xml:space="default" xmlns:str="http://exslt.org/strings" xmlns:exslt="http://exslt.org/common"
	extension-element-prefixes="str exslt">

	<xsl:template match="/">
		<xsl:if test="not(function-available('str:split'))">
			<xsl:message terminate="yes">
				This stylesheet requires the function str:split!
			</xsl:message>
		</xsl:if>

		<rdf:RDF>
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="wsdl:description">
		<xsl:variable name="wsdl-tns"
			select="ancestor-or-self::wsdl:description/@targetNamespace" />
		<xsl:variable name="wsdl-namespace"
			select="concat(str:split($wsdl-tns, '#')[1], '#')" />

		<rwsdl:Description rdf:about="{concat($wsdl-namespace, 'wsdl.description()')}">
			<xsl:apply-templates
				select="*|@*[namespace-uri() != '' and namespace-uri() != 'http://www.w3.org/2006/01/wsdl' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema-instance' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema']"
				mode="linking" />
		</rwsdl:Description>
	</xsl:template>

	<xsl:template match="wsdl:documentation" mode="linking">
		<rwsdl:documentation rdf:parseType="Literal">
			<xsl:value-of select="." />
		</rwsdl:documentation>
	</xsl:template>

	<xsl:template match="wsdl:import[@location]|wsdl:include[@location]"
		mode="linking">
		<!-- anything but wsdl:description in import/include will get ignored -->
		<xsl:apply-templates select="document(@location)/wsdl:description/*"
			mode="linking" />
	</xsl:template>

	<!-- ignoring types, we only reference elements and types by qname -->
	<xsl:template match="wsdl:types" mode="linking" />

	<xsl:template match="wsdl:interface" mode="linking">
		<rwsdl:interface>
			<xsl:apply-templates select="." />
		</rwsdl:interface>
	</xsl:template>

	<xsl:template match="wsdl:interface">
		<xsl:variable name="wsdl-tns"
			select="ancestor-or-self::wsdl:description/@targetNamespace" />
		<xsl:variable name="wsdl-namespace"
			select="concat(str:split($wsdl-tns, '#')[1], '#')" />

		<rwsdl:Interface
			rdf:about="{concat($wsdl-namespace, 'wsdl.interface(', @name, ')')}">
			<xsl:if test="@extends">
				<xsl:variable name="cur" select="." />
				<xsl:for-each select="str:split(@extends)">
					<xsl:variable name="qname-ns">
						<xsl:call-template name="qname-ns">
							<xsl:with-param name="qname" select="." />
							<xsl:with-param name="node" select="$cur" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="qname-local">
						<xsl:call-template name="qname-local">
							<xsl:with-param name="qname" select="." />
							<xsl:with-param name="node" select="$cur" />
						</xsl:call-template>
					</xsl:variable>

					<rwsdl:extensionOf
						rdf:resource="{concat(str:split($qname-ns, '#')[1], '#wsdl.interface(', $qname-local, ')')}" />
				</xsl:for-each>
			</xsl:if>
			<rdfs:label rdf:parseType="Literal">
				<xsl:value-of select="@name" />
			</rdfs:label>
			<xsl:apply-templates
				select="*|@*[namespace-uri() != '' and namespace-uri() != 'http://www.w3.org/2006/01/wsdl' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema-instance' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema']"
				mode="linking" />
		</rwsdl:Interface>
	</xsl:template>

	<xsl:template match="wsdl:interface/wsdl:fault" mode="linking">
		<rwsdl:interfaceFault>
			<xsl:apply-templates select="." />
		</rwsdl:interfaceFault>
	</xsl:template>

	<xsl:template match="wsdl:interface/wsdl:fault">
		<xsl:variable name="wsdl-tns"
			select="ancestor-or-self::wsdl:description/@targetNamespace" />
		<xsl:variable name="wsdl-namespace"
			select="concat(str:split($wsdl-tns, '#')[1], '#')" />

		<rwsdl:InterfaceFault
			rdf:about="{concat($wsdl-namespace, 'wsdl.interfaceFault(', parent::wsdl:interface/@name, '/', @name, ')')}">
			<xsl:call-template name="element-declaration-reference" />
			<xsl:apply-templates
				select="*|@*[namespace-uri() != '' and namespace-uri() != 'http://www.w3.org/2006/01/wsdl' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema-instance' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema']"
				mode="linking" />
		</rwsdl:InterfaceFault>
	</xsl:template>

	<xsl:template name="element-declaration-reference">
		<xsl:if test="@element">
			<rwsdl:elementDeclaration>
				<xsl:variable name="qname-ns">
					<xsl:call-template name="qname-ns">
						<xsl:with-param name="qname" select="@element" />
						<xsl:with-param name="node" select="." />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="qname-local">
					<xsl:call-template name="qname-local">
						<xsl:with-param name="qname" select="@element" />
						<xsl:with-param name="node" select="." />
					</xsl:call-template>
				</xsl:variable>
				<rwsdl:QName rwsdl:localName="{$qname-local}"
					rwsdl:namespace="{$qname-ns}" />
			</rwsdl:elementDeclaration>
		</xsl:if>
	</xsl:template>

	<xsl:template match="wsdl:interface/wsdl:operation" mode="linking">
		<rwsdl:interfaceOperation>
			<xsl:apply-templates select="." />
		</rwsdl:interfaceOperation>
	</xsl:template>

	<xsl:template match="wsdl:interface/wsdl:operation">
		<xsl:variable name="wsdl-tns"
			select="ancestor-or-self::wsdl:description/@targetNamespace" />
		<xsl:variable name="wsdl-namespace"
			select="concat(str:split($wsdl-tns, '#')[1], '#')" />

		<rwsdl:InterfaceOperation
			rdf:about="{concat($wsdl-namespace, 'wsdl.interfaceOperation(', parent::wsdl:interface/@name, '/', @name, ')')}">
			<rwsdl:messageExchangePattern
				rdf:resource="{@pattern}" />
			<xsl:choose>
				<xsl:when test="@style">
					<xsl:call-template name="operation-styles">
						<xsl:with-param name="styles" select="@style" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="parent::wsdl:interface/@styleDefault">
						<xsl:call-template name="operation-styles">
							<xsl:with-param name="styles"
								select="parent::wsdl:interface/@styleDefault" />
						</xsl:call-template>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:apply-templates
				select="*|@*[namespace-uri() != '' and namespace-uri() != 'http://www.w3.org/2006/01/wsdl' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema-instance' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema']"
				mode="linking" />
		</rwsdl:InterfaceOperation>
	</xsl:template>

	<xsl:template name="operation-styles">
		<xsl:param name="styles" />
		<xsl:for-each select="str:split($styles)">
			<rwsdl:operationStyle rdf:resource="{.}" />
		</xsl:for-each>
	</xsl:template>



	<!-- interface message references -->
	<xsl:template
		match="wsdl:interface/wsdl:operation/wsdl:input | wsdl:interface/wsdl:operation/wsdl:output"
		mode="linking">
		<rwsdl:interfaceMessageReference>
			<xsl:apply-templates select="." />
		</rwsdl:interfaceMessageReference>
	</xsl:template>

	<xsl:template
		match="wsdl:interface/wsdl:operation/wsdl:input | wsdl:interface/wsdl:operation/wsdl:output">
		<xsl:variable name="wsdl-tns"
			select="ancestor-or-self::wsdl:description/@targetNamespace" />
		<xsl:variable name="wsdl-namespace"
			select="concat(str:split($wsdl-tns, '#')[1], '#')" />

		<xsl:variable name="msg-label">
			<xsl:choose>
				<xsl:when test="@messageLabel">
					<xsl:value-of select="@messageLabel" />
				</xsl:when>
				<xsl:when
					test="local-name() =  'input' and parent::wsdl:operation[@pattern='http://www.w3.org/2006/01/wsdl/in-only'  or @pattern='http://www.w3.org/2006/01/wsdl/robust-in-only' or @pattern='http://www.w3.org/2006/01/wsdl/in-opt-out'      or @pattern='http://www.w3.org/2006/01/wsdl/out-opt-in' or @pattern='http://www.w3.org/2006/01/wsdl/in-out' or @pattern='http://www.w3.org/2006/01/wsdl/out-in']">
					In
				</xsl:when>
				<xsl:when
					test="local-name() = 'output' and parent::wsdl:operation[@pattern='http://www.w3.org/2006/01/wsdl/out-only' or @pattern='http://www.w3.org/2006/01/wsdl/in-opt-out'     or @pattern='http://www.w3.org/2006/01/wsdl/robust-out-only' or @pattern='http://www.w3.org/2006/01/wsdl/out-opt-in' or @pattern='http://www.w3.org/2006/01/wsdl/in-out' or @pattern='http://www.w3.org/2006/01/wsdl/out-in']">
					Out
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="msg-label-uri">
			<xsl:choose>
				<xsl:when
					test="local-name() =  'input' and parent::wsdl:operation[@pattern='http://www.w3.org/2006/01/wsdl/in-only'  or @pattern='http://www.w3.org/2006/01/wsdl/robust-in-only' or @pattern='http://www.w3.org/2006/01/wsdl/in-opt-out'      or @pattern='http://www.w3.org/2006/01/wsdl/out-opt-in' or @pattern='http://www.w3.org/2006/01/wsdl/in-out' or @pattern='http://www.w3.org/2006/01/wsdl/out-in']">
					<xsl:value-of select="concat(parent::*/@pattern, '#In')" />
				</xsl:when>
				<xsl:when
					test="local-name() = 'output' and parent::wsdl:operation[@pattern='http://www.w3.org/2006/01/wsdl/out-only' or @pattern='http://www.w3.org/2006/01/wsdl/in-opt-out'     or @pattern='http://www.w3.org/2006/01/wsdl/robust-out-only' or @pattern='http://www.w3.org/2006/01/wsdl/out-opt-in' or @pattern='http://www.w3.org/2006/01/wsdl/in-out' or @pattern='http://www.w3.org/2006/01/wsdl/out-in']">
					<xsl:value-of select="concat(parent::*/@pattern, '#Out')" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="msg-direction">
			<xsl:choose>
				<xsl:when test="local-name() =  'input'">
					InputMessage
				</xsl:when>
				<xsl:when test="local-name() = 'output'">
					OutputMessage
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<rwsdl:InterfaceMessageReference>
			<xsl:if test="$msg-label">
				<xsl:attribute name="rdf:about"><xsl:value-of
					select="concat($wsdl-namespace, 'wsdl.interfaceMessageReference(', parent::wsdl:operation/parent::wsdl:interface/@name, '/', parent::wsdl:operation/@name, '/', $msg-label, ')')" /></xsl:attribute>
			</xsl:if>
			<xsl:if test="$msg-label-uri">
				<rwsdl:messageLabel rdf:resource="{$msg-label-uri}" />
			</xsl:if>
			<rdf:type rdf:resource="http://www.w3.org/2005/10/wsdl-rdf#{$msg-direction}" />
			<xsl:choose>
				<xsl:when test="not(@element)">
					<xsl:call-template name="message-content-model">
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="starts-with(@element, '#')">
					<xsl:call-template name="message-content-model">
						<xsl:with-param name="model" select="@element" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="message-content-model">
						<xsl:with-param name="model" select="'#element'" />
					</xsl:call-template>
					<xsl:call-template name="element-declaration-reference" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates
				select="*|@*[namespace-uri() != '' and namespace-uri() != 'http://www.w3.org/2006/01/wsdl' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema-instance' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema']"
				mode="linking" />
		</rwsdl:InterfaceMessageReference>
	</xsl:template>

	<xsl:template name="message-content-model">
		<xsl:param name="model" select="'#other'" />
		<rwsdl:messageContentModel
			rdf:resource="http://www.w3.org/2005/10/wsdl-rdf{$model}" />
	</xsl:template>



	<!-- interface fault references -->
	<xsl:template
		match="wsdl:interface/wsdl:operation/wsdl:infault | wsdl:interface/wsdl:operation/wsdl:outfault"
		mode="linking">
		<rwsdl:interfaceFaultReference>
			<xsl:apply-templates select="." />
		</rwsdl:interfaceFaultReference>
	</xsl:template>

	<xsl:template
		match="wsdl:interface/wsdl:operation/wsdl:infault | wsdl:interface/wsdl:operation/wsdl:outfault">
		<xsl:variable name="wsdl-tns"
			select="ancestor-or-self::wsdl:description/@targetNamespace" />
		<xsl:variable name="wsdl-namespace"
			select="concat(str:split($wsdl-tns, '#')[1], '#')" />
		<xsl:variable name="fault-namespace">
			<xsl:call-template name="qname-ns">
				<xsl:with-param name="qname" select="@ref" />
				<xsl:with-param name="node" select="." />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="fault-name">
			<xsl:call-template name="qname-local">
				<xsl:with-param name="qname" select="@ref" />
				<xsl:with-param name="node" select="." />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="msg-label">
			<xsl:choose>
				<xsl:when test="@messageLabel">
					<xsl:value-of select="@messageLabel" />
				</xsl:when>
				<xsl:when
					test="local-name() =  'infault' and parent::wsdl:operation[@pattern='http://www.w3.org/2006/01/wsdl/out-in']">
					In
				</xsl:when>
				<xsl:when
					test="local-name() =  'infault' and parent::wsdl:operation[@pattern='http://www.w3.org/2006/01/wsdl/in-opt-out' or @pattern='http://www.w3.org/2006/01/wsdl/out-opt-in' or @pattern='http://www.w3.org/2006/01/wsdl/robust-out-only']">
					Out
				</xsl:when>
				<xsl:when
					test="local-name() = 'outfault' and parent::wsdl:operation[@pattern='http://www.w3.org/2006/01/wsdl/in-out']">
					Out
				</xsl:when>
				<xsl:when
					test="local-name() = 'outfault' and parent::wsdl:operation[@pattern='http://www.w3.org/2006/01/wsdl/in-opt-out' or @pattern='http://www.w3.org/2006/01/wsdl/out-opt-in' or @pattern='http://www.w3.org/2006/01/wsdl/robust-in-only']">
					In
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="msg-label-uri">
			<xsl:choose>
				<xsl:when
					test="local-name() =  'infault' and parent::wsdl:operation[@pattern='http://www.w3.org/2006/01/wsdl/out-in']">
					<xsl:value-of select="concat(parent::*/@pattern, '#In')" />
				</xsl:when>
				<xsl:when
					test="local-name() =  'infault' and parent::wsdl:operation[@pattern='http://www.w3.org/2006/01/wsdl/in-opt-out' or @pattern='http://www.w3.org/2006/01/wsdl/out-opt-in' or @pattern='http://www.w3.org/2006/01/wsdl/robust-out-only']">
					<xsl:value-of select="concat(parent::*/@pattern, '#Out')" />
				</xsl:when>
				<xsl:when
					test="local-name() = 'outfault' and parent::wsdl:operation[@pattern='http://www.w3.org/2006/01/wsdl/in-out']">
					<xsl:value-of select="concat(parent::*/@pattern, '#Out')" />
				</xsl:when>
				<xsl:when
					test="local-name() = 'outfault' and parent::wsdl:operation[@pattern='http://www.w3.org/2006/01/wsdl/in-opt-out' or @pattern='http://www.w3.org/2006/01/wsdl/out-opt-in' or @pattern='http://www.w3.org/2006/01/wsdl/robust-in-only']">
					<xsl:value-of select="concat(parent::*/@pattern, '#In')" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="msg-direction">
			<xsl:choose>
				<xsl:when test="local-name() =  'infault'">
					InputMessage
				</xsl:when>
				<xsl:when test="local-name() = 'outfault'">
					OutputMessage
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="$fault-namespace != $wsdl-tns">
			<xsl:message terminate="yes">
				ERROR: This stylesheet cannot handle interface fault references to
				faults from imported extended interfaces.
			</xsl:message>
		</xsl:if>

		<xsl:variable name="found-interface">
			<xsl:call-template name="find-interface-with-fault">
				<xsl:with-param name="interface"
					select="parent::wsdl:operation/parent::wsdl:interface" />
				<xsl:with-param name="fault-name" select="$fault-name" />
				<xsl:with-param name="wsdl-namespace" select="$wsdl-tns" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:if test="not(string($found-interface))">
			<xsl:message terminate="yes">
				ERROR: This stylesheet cannot handle interface fault references to
				faults from included extended interfaces.
			</xsl:message>
		</xsl:if>

		<rwsdl:InterfaceFaultReference>
			<xsl:if test="$msg-label">
				<xsl:attribute name="rdf:about"><xsl:value-of
					select="concat($wsdl-namespace, 'wsdl.interfaceFaultReference(', parent::wsdl:operation/parent::wsdl:interface/@name, '/', parent::wsdl:operation/@name, '/', $msg-label, '/', $fault-name, ')')" /></xsl:attribute>
			</xsl:if>
			<xsl:if test="$msg-label-uri">
				<rwsdl:messageLabel rdf:resource="{$msg-label-uri}" />
			</xsl:if>
			<rdf:type rdf:resource="http://www.w3.org/2005/10/wsdl-rdf#{$msg-direction}" />
			<rwsdl:interfaceFault>
				<xsl:attribute name="rdf:resource"><xsl:value-of
					select="concat($wsdl-namespace, 'wsdl.interfaceFault(', $found-interface, '/', $fault-name, ')')" /></xsl:attribute>
			</rwsdl:interfaceFault>
			<xsl:apply-templates
				select="*|@*[namespace-uri() != '' and namespace-uri() != 'http://www.w3.org/2006/01/wsdl' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema-instance' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema']"
				mode="linking" />
		</rwsdl:InterfaceFaultReference>
	</xsl:template>

	<xsl:template name="find-interface-by-name-with-operation">
		<xsl:param name="wsdl-namespace" />
		<xsl:param name="interface-name" />
		<xsl:param name="operation-name" />

		<xsl:variable name="found-interfaces">
			<xsl:call-template name="find-interfaces-with-operation">
				<xsl:with-param name="interface"
					select="/wsdl:description/wsdl:interface[@name = $interface-name]" />
				<xsl:with-param name="operation-name" select="$operation-name" />
				<xsl:with-param name="wsdl-namespace" select="$wsdl-namespace" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="str:split($found-interfaces, ':')[1]" />
	</xsl:template>

	<xsl:template name="find-interfaces-with-operation">
		<xsl:param name="wsdl-namespace" />
		<xsl:param name="interface" />
		<xsl:param name="operation-name" />

		<xsl:choose>
			<xsl:when test="$interface/wsdl:operation[@name=$operation-name]">
				<xsl:value-of select="$interface/@name" />
				:
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="str:split($interface/@extends)">
					<xsl:variable name="extended-interface-name">
						<xsl:call-template name="qname-local">
							<xsl:with-param name="qname" select="." />
							<xsl:with-param name="node" select="$interface" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="extended-interface-namespace">
						<xsl:call-template name="qname-ns">
							<xsl:with-param name="qname" select="." />
							<xsl:with-param name="node" select="$interface" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:if
						test="$extended-interface-namespace = $wsdl-namespace and $interface/parent::*/wsdl:interface[@name = $extended-interface-name]">
						<xsl:call-template name="find-interfaces-with-operation">
							<xsl:with-param name="wsdl-namespace" select="$wsdl-namespace" />
							<xsl:with-param name="interface"
								select="$interface/parent::*/wsdl:interface[@name = $extended-interface-name]" />
							<xsl:with-param name="operation-name" select="$operation-name" />
						</xsl:call-template>
					</xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="find-interface-by-name-with-fault">
		<xsl:param name="wsdl-namespace" />
		<xsl:param name="interface-name" />
		<xsl:param name="fault-name" />

		<xsl:variable name="found-interfaces">
			<xsl:call-template name="find-interfaces-with-fault">
				<xsl:with-param name="interface"
					select="/wsdl:description/wsdl:interface[@name = $interface-name]" />
				<xsl:with-param name="fault-name" select="$fault-name" />
				<xsl:with-param name="wsdl-namespace" select="$wsdl-namespace" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="str:split($found-interfaces, ':')[1]" />
	</xsl:template>

	<xsl:template name="find-interface-with-fault">
		<xsl:param name="wsdl-namespace" />
		<xsl:param name="interface" />
		<xsl:param name="fault-name" />

		<xsl:variable name="found-interfaces">
			<xsl:call-template name="find-interfaces-with-fault">
				<xsl:with-param name="interface" select="$interface" />
				<xsl:with-param name="fault-name" select="$fault-name" />
				<xsl:with-param name="wsdl-namespace" select="$wsdl-namespace" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="str:split($found-interfaces, ':')[1]" />
	</xsl:template>

	<xsl:template name="find-interfaces-with-fault">
		<xsl:param name="wsdl-namespace" />
		<xsl:param name="interface" />
		<xsl:param name="fault-name" />

		<xsl:choose>
			<xsl:when test="$interface/wsdl:fault[@name=$fault-name]">
				<xsl:value-of select="$interface/@name" />
				:
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="str:split($interface/@extends)">
					<xsl:variable name="extended-interface-name">
						<xsl:call-template name="qname-local">
							<xsl:with-param name="qname" select="." />
							<xsl:with-param name="node" select="$interface" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="extended-interface-namespace">
						<xsl:call-template name="qname-ns">
							<xsl:with-param name="qname" select="." />
							<xsl:with-param name="node" select="$interface" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:if
						test="$extended-interface-namespace = $wsdl-namespace and $interface/parent::*/wsdl:interface[@name = $extended-interface-name]">
						<xsl:call-template name="find-interfaces-with-fault">
							<xsl:with-param name="wsdl-namespace" select="$wsdl-namespace" />
							<xsl:with-param name="interface"
								select="$interface/parent::*/wsdl:interface[@name = $extended-interface-name]" />
							<xsl:with-param name="fault-name" select="$fault-name" />
						</xsl:call-template>
					</xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- bindings -->
	<xsl:template match="wsdl:binding" mode="linking">
		<rwsdl:binding>
			<xsl:apply-templates select="." />
		</rwsdl:binding>
	</xsl:template>

	<xsl:template match="wsdl:binding">
		<xsl:variable name="wsdl-tns"
			select="ancestor-or-self::wsdl:description/@targetNamespace" />
		<xsl:variable name="wsdl-namespace"
			select="concat(str:split($wsdl-tns, '#')[1], '#')" />

		<rwsdl:Binding
			rdf:about="{concat($wsdl-namespace, 'wsdl.binding(', @name, ')')}">
			<rdf:type rdf:resource="{@type}" />
			<xsl:if test="@interface">
				<xsl:variable name="interface-ns">
					<xsl:call-template name="qname-ns">
						<xsl:with-param name="qname" select="@interface" />
						<xsl:with-param name="node" select="." />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="interface-local">
					<xsl:call-template name="qname-local">
						<xsl:with-param name="qname" select="@interface" />
						<xsl:with-param name="node" select="." />
					</xsl:call-template>
				</xsl:variable>
				<rwsdl:interface
					rdf:resource="{concat(str:split($interface-ns, '#')[1], '#wsdl.interface(', $interface-local, ')')}" />
			</xsl:if>

			<xsl:apply-templates
				select="*|@*[namespace-uri() != '' and namespace-uri() != 'http://www.w3.org/2006/01/wsdl' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema-instance' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema']"
				mode="linking" />
		</rwsdl:Binding>
	</xsl:template>

	<xsl:template match="wsdl:binding/wsdl:fault" mode="linking">
		<rwsdl:bindingFault>
			<xsl:apply-templates select="." />
		</rwsdl:bindingFault>
	</xsl:template>

	<xsl:template match="wsdl:binding/wsdl:fault">
		<xsl:variable name="wsdl-tns"
			select="ancestor-or-self::wsdl:description/@targetNamespace" />
		<xsl:variable name="wsdl-namespace"
			select="concat(str:split($wsdl-tns, '#')[1], '#')" />
		<xsl:variable name="ref-ns">
			<xsl:call-template name="qname-ns">
				<xsl:with-param name="qname" select="@ref" />
				<xsl:with-param name="node" select="." />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="ref-name">
			<xsl:call-template name="qname-local">
				<xsl:with-param name="qname" select="@ref" />
				<xsl:with-param name="node" select="." />
			</xsl:call-template>
		</xsl:variable>

		<rwsdl:BindingFault>
			<xsl:attribute name="rdf:about">
      <xsl:choose>
        <xsl:when test="$ref-ns != $wsdl-tns">
          <xsl:value-of
				select="concat($wsdl-namespace, 'xmlns(ns=', $ref-ns, ')wsdl.bindingFault(', parent::*/@name, '/ns:', $ref-name, ')')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of
				select="concat($wsdl-namespace, 'wsdl.bindingFault(', parent::*/@name, '/', $ref-name, ')')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
			<rwsdl:interfaceFault>
				<xsl:attribute name="rdf:resource">
        <xsl:if test="$ref-ns != $wsdl-tns">
          <xsl:message terminate="yes">ERROR: This stylesheet cannot handle binding faults referencing faults from imported extended interfaces.</xsl:message>
        </xsl:if>

        <xsl:variable name="found-interface">
          <xsl:call-template name="find-interface-by-name-with-fault">
            <xsl:with-param name="interface-name"
					select="str:split(parent::wsdl:binding/@interface, ':')[position()=last()]" />
            <xsl:with-param name="fault-name" select="$ref-name" />
            <xsl:with-param name="wsdl-namespace"
					select="$wsdl-tns" />
          </xsl:call-template>
        </xsl:variable>

        <xsl:if test="not(string($found-interface))">
          <xsl:message terminate="yes">ERROR: This stylesheet cannot handle binding faults referencing faults from included extended interfaces.</xsl:message>
        </xsl:if>
        <xsl:value-of
					select="concat($wsdl-namespace, 'wsdl.interfaceFault(', $found-interface, '/', $ref-name, ')')" />
      </xsl:attribute>
			</rwsdl:interfaceFault>

			<xsl:apply-templates
				select="*|@*[namespace-uri() != '' and namespace-uri() != 'http://www.w3.org/2006/01/wsdl' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema-instance' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema']"
				mode="linking" />
		</rwsdl:BindingFault>
	</xsl:template>

	<xsl:template match="wsdl:binding/wsdl:operation" mode="linking">
		<rwsdl:bindingOperation>
			<xsl:apply-templates select="." />
		</rwsdl:bindingOperation>
	</xsl:template>

	<xsl:template match="wsdl:binding/wsdl:operation">
		<xsl:variable name="wsdl-tns"
			select="ancestor-or-self::wsdl:description/@targetNamespace" />
		<xsl:variable name="wsdl-namespace"
			select="concat(str:split($wsdl-tns, '#')[1], '#')" />
		<xsl:variable name="ref-ns">
			<xsl:call-template name="qname-ns">
				<xsl:with-param name="qname" select="@ref" />
				<xsl:with-param name="node" select="." />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="ref-name">
			<xsl:call-template name="qname-local">
				<xsl:with-param name="qname" select="@ref" />
				<xsl:with-param name="node" select="." />
			</xsl:call-template>
		</xsl:variable>

		<rwsdl:BindingOperation>
			<xsl:attribute name="rdf:about">
      <xsl:choose>
        <xsl:when test="$ref-ns != $wsdl-tns">
          <xsl:value-of
				select="concat($wsdl-namespace, 'xmlns(ns=', $ref-ns, ')wsdl.bindingOperation(', parent::*/@name, '/ns:', $ref-name, ')')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of
				select="concat($wsdl-namespace, 'wsdl.bindingOperation(', parent::*/@name, '/', $ref-name, ')')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
			<rwsdl:interfaceOperation>
				<xsl:attribute name="rdf:resource">
        <xsl:if test="$ref-ns != $wsdl-tns">
          <xsl:message terminate="yes">ERROR: This stylesheet cannot handle binding operations referencing operations from imported extended interfaces.</xsl:message>
        </xsl:if>

        <xsl:variable name="found-interface">
          <xsl:call-template name="find-interface-by-name-with-operation">
            <xsl:with-param name="interface-name"
					select="str:split(parent::wsdl:binding/@interface, ':')[position()=last()]" />
            <xsl:with-param name="operation-name"
					select="$ref-name" />
            <xsl:with-param name="wsdl-namespace"
					select="$wsdl-tns" />
          </xsl:call-template>
        </xsl:variable>

        <xsl:if test="not(string($found-interface))">
          <xsl:message terminate="yes">ERROR: This stylesheet cannot handle binding operations referencing operations from included extended interfaces.</xsl:message>
        </xsl:if>
        <xsl:value-of
					select="concat($wsdl-namespace, 'wsdl.interfaceOperation(', $found-interface, '/', $ref-name, ')')" />
      </xsl:attribute>
			</rwsdl:interfaceOperation>
			<xsl:apply-templates
				select="*|@*[namespace-uri() != '' and namespace-uri() != 'http://www.w3.org/2006/01/wsdl' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema-instance' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema']"
				mode="linking" />
		</rwsdl:BindingOperation>
	</xsl:template>



	<!-- binding message references -->
	<xsl:template
		match="wsdl:binding/wsdl:operation/wsdl:input | wsdl:binding/wsdl:operation/wsdl:output"
		mode="linking">
		<rwsdl:bindingMessageReference>
			<xsl:apply-templates select="." />
		</rwsdl:bindingMessageReference>
	</xsl:template>

	<xsl:template
		match="wsdl:binding/wsdl:operation/wsdl:input | wsdl:binding/wsdl:operation/wsdl:output">
		<xsl:variable name="wsdl-tns"
			select="ancestor-or-self::wsdl:description/@targetNamespace" />
		<xsl:variable name="wsdl-namespace"
			select="concat(str:split($wsdl-tns, '#')[1], '#')" />
		<!-- NOTE: we assume here that the operation is in an interface within 
			this WSDL file, otherwise already bindingoperation would shout -->
		<xsl:variable name="ref-name">
			<xsl:call-template name="qname-local">
				<xsl:with-param name="qname" select="parent::*/@ref" />
				<xsl:with-param name="node" select="parent::*" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="found-interface">
			<xsl:call-template name="find-interface-by-name-with-operation">
				<xsl:with-param name="interface-name"
					select="str:split(parent::wsdl:operation/parent::wsdl:binding/@interface, ':')[position()=last()]" />
				<xsl:with-param name="operation-name" select="$ref-name" />
				<xsl:with-param name="wsdl-namespace" select="$wsdl-tns" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="referenced-op-pattern"
			select="parent::wsdl:operation/parent::wsdl:binding/parent::*/wsdl:interface[@name=string($found-interface)]/wsdl:operation[@name=$ref-name]/@pattern" />
		<xsl:variable name="msg-label">
			<xsl:choose>
				<xsl:when test="@messageLabel">
					<xsl:value-of select="@messageLabel" />
				</xsl:when>
				<xsl:when
					test="local-name() =  'input' and ($referenced-op-pattern='http://www.w3.org/2006/01/wsdl/in-only'  or $referenced-op-pattern='http://www.w3.org/2006/01/wsdl/robust-in-only' or $referenced-op-pattern='http://www.w3.org/2006/01/wsdl/in-opt-out'      or $referenced-op-pattern='http://www.w3.org/2006/01/wsdl/out-opt-in' or $referenced-op-pattern='http://www.w3.org/2006/01/wsdl/in-out' or $referenced-op-pattern='http://www.w3.org/2006/01/wsdl/out-in')">
					In
				</xsl:when>
				<xsl:when
					test="local-name() = 'output' and ($referenced-op-pattern='http://www.w3.org/2006/01/wsdl/out-only' or $referenced-op-pattern='http://www.w3.org/2006/01/wsdl/in-opt-out'     or $referenced-op-pattern='http://www.w3.org/2006/01/wsdl/robust-out-only' or $referenced-op-pattern='http://www.w3.org/2006/01/wsdl/out-opt-in' or $referenced-op-pattern='http://www.w3.org/2006/01/wsdl/in-out' or $referenced-op-pattern='http://www.w3.org/2006/01/wsdl/out-in')">
					Out
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="not(string($msg-label))">
			<xsl:message terminate="yes">
				ERROR: This stylesheet cannot handle binding message references into
				operations with unknown MEP without explicit message label.
			</xsl:message>
		</xsl:if>

		<rwsdl:BindingMessageReference>
			<xsl:attribute name="rdf:about">
      <xsl:value-of
				select="concat($wsdl-namespace, 'wsdl.bindingMessageReference(', parent::*/parent::*/@name, '/', $ref-name, '/', $msg-label, ')')" />
    </xsl:attribute>
			<rwsdl:interfaceMessageReference>
				<xsl:attribute name="rdf:resource">
        <xsl:value-of
					select="concat($wsdl-namespace, 'wsdl.interfaceMessageReference(', $found-interface, '/', $ref-name, '/', $msg-label, ')')" />
      </xsl:attribute>
			</rwsdl:interfaceMessageReference>
			<xsl:apply-templates
				select="*|@*[namespace-uri() != '' and namespace-uri() != 'http://www.w3.org/2006/01/wsdl' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema-instance' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema']"
				mode="linking" />
		</rwsdl:BindingMessageReference>
	</xsl:template>



	<!-- binding fault references -->
	<xsl:template
		match="wsdl:binding/wsdl:operation/wsdl:infault | wsdl:binding/wsdl:operation/wsdl:outfault"
		mode="linking">
		<rwsdl:bindingFaultReference>
			<xsl:apply-templates select="." />
		</rwsdl:bindingFaultReference>
	</xsl:template>

	<xsl:template
		match="wsdl:binding/wsdl:operation/wsdl:infault | wsdl:binding/wsdl:operation/wsdl:outfault">
		<xsl:variable name="wsdl-tns"
			select="ancestor-or-self::wsdl:description/@targetNamespace" />
		<xsl:variable name="wsdl-namespace"
			select="concat(str:split($wsdl-tns, '#')[1], '#')" />
		<!-- NOTE: we assume here that the operation is in an interface within 
			this WSDL file, otherwise already bindingoperation would shout -->
		<xsl:variable name="ref-name">
			<xsl:call-template name="qname-local">
				<xsl:with-param name="qname" select="parent::*/@ref" />
				<xsl:with-param name="node" select="parent::*" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="fault-ref-name">
			<xsl:call-template name="qname-local">
				<xsl:with-param name="qname" select="@ref" />
				<xsl:with-param name="node" select="." />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="found-interface-with-op">
			<xsl:call-template name="find-interface-by-name-with-operation">
				<xsl:with-param name="interface-name"
					select="str:split(parent::wsdl:operation/parent::wsdl:binding/@interface, ':')[position()=last()]" />
				<xsl:with-param name="operation-name" select="$ref-name" />
				<xsl:with-param name="wsdl-namespace" select="$wsdl-tns" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="referenced-op"
			select="parent::wsdl:operation/parent::wsdl:binding/parent::*/wsdl:interface[@name=string($found-interface-with-op)]/wsdl:operation[@name=$ref-name]" />
		<xsl:variable name="referenced-op-pattern" select="$referenced-op/@pattern" />
		<xsl:variable name="msg-label">
			<xsl:choose>
				<xsl:when test="@messageLabel">
					<xsl:value-of select="@messageLabel" />
				</xsl:when>
				<xsl:when
					test="local-name() =  'infault' and ($referenced-op-pattern='http://www.w3.org/2006/01/wsdl/out-in')">
					In
				</xsl:when>
				<xsl:when
					test="local-name() =  'infault' and ($referenced-op-pattern='http://www.w3.org/2006/01/wsdl/in-opt-out' or $referenced-op-pattern='http://www.w3.org/2006/01/wsdl/out-opt-in' or $referenced-op-pattern='http://www.w3.org/2006/01/wsdl/robust-out-only')">
					Out
				</xsl:when>
				<xsl:when
					test="local-name() = 'outfault' and ($referenced-op-pattern='http://www.w3.org/2006/01/wsdl/in-out')">
					Out
				</xsl:when>
				<xsl:when
					test="local-name() = 'outfault' and ($referenced-op-pattern='http://www.w3.org/2006/01/wsdl/in-opt-out' or $referenced-op-pattern='http://www.w3.org/2006/01/wsdl/out-opt-in' or $referenced-op-pattern='http://www.w3.org/2006/01/wsdl/robust-in-only')">
					In
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="not(string($msg-label))">
			<xsl:message terminate="yes">
				ERROR: This stylesheet cannot handle binding fault references into
				operations with unknown MEP without explicit message label.
			</xsl:message>
		</xsl:if>

		<rwsdl:BindingFaultReference>
			<xsl:attribute name="rdf:about">
      <xsl:value-of
				select="concat($wsdl-namespace, 'wsdl.bindingFaultReference(', parent::*/parent::*/@name, '/', $ref-name, '/', $msg-label, '/', $fault-ref-name, ')')" />
    </xsl:attribute>
			<rwsdl:interfaceFaultReference>
				<xsl:attribute name="rdf:resource">
        <xsl:value-of
					select="concat($wsdl-namespace, 'wsdl.interfaceFaultReference(', $found-interface-with-op, '/', $ref-name, '/', $msg-label, '/', $fault-ref-name, ')')" />
      </xsl:attribute>
			</rwsdl:interfaceFaultReference>
			<xsl:apply-templates
				select="*|@*[namespace-uri() != '' and namespace-uri() != 'http://www.w3.org/2006/01/wsdl' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema-instance' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema']"
				mode="linking" />
		</rwsdl:BindingFaultReference>
	</xsl:template>



	<!-- service -->
	<xsl:template match="wsdl:service" mode="linking">
		<rwsdl:service>
			<xsl:apply-templates select="." />
		</rwsdl:service>
	</xsl:template>

	<xsl:template match="wsdl:service">
		<xsl:variable name="wsdl-tns"
			select="ancestor-or-self::wsdl:description/@targetNamespace" />
		<xsl:variable name="wsdl-namespace"
			select="concat(str:split($wsdl-tns, '#')[1], '#')" />

		<rwsdl:Service
			rdf:about="{concat($wsdl-namespace, 'wsdl.service(', @name, ')')}">
			<xsl:variable name="interface-ns">
				<xsl:call-template name="qname-ns">
					<xsl:with-param name="qname" select="@interface" />
					<xsl:with-param name="node" select="." />
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="interface-name">
				<xsl:call-template name="qname-local">
					<xsl:with-param name="qname" select="@interface" />
					<xsl:with-param name="node" select="." />
				</xsl:call-template>
			</xsl:variable>
			<rwsdl:interface
				rdf:resource="{concat(str:split($interface-ns, '#')[1], '#wsdl.interface(', $interface-name, ')')}" />
			<xsl:apply-templates
				select="*|@*[namespace-uri() != '' and namespace-uri() != 'http://www.w3.org/2006/01/wsdl' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema-instance' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema']"
				mode="linking" />
		</rwsdl:Service>
	</xsl:template>

	<xsl:template match="wsdl:endpoint" mode="linking">
		<rwsdl:endpoint>
			<xsl:apply-templates select="." />
		</rwsdl:endpoint>
	</xsl:template>

	<xsl:template match="wsdl:endpoint">
		<xsl:variable name="wsdl-tns"
			select="ancestor-or-self::wsdl:description/@targetNamespace" />
		<xsl:variable name="wsdl-namespace"
			select="concat(str:split($wsdl-tns, '#')[1], '#')" />

		<rwsdl:Endpoint
			rdf:about="{concat($wsdl-namespace, 'wsdl.endpoint(', parent::*/@name, '/', @name, ')')}">
			<xsl:variable name="binding-ns">
				<xsl:call-template name="qname-ns">
					<xsl:with-param name="qname" select="@binding" />
					<xsl:with-param name="node" select="." />
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="binding-name">
				<xsl:call-template name="qname-local">
					<xsl:with-param name="qname" select="@binding" />
					<xsl:with-param name="node" select="." />
				</xsl:call-template>
			</xsl:variable>
			<rwsdl:binding
				rdf:resource="{concat(str:split($binding-ns, '#')[1], '#wsdl.binding(', $binding-name, ')')}" />
			<xsl:if test="@address">
				<rwsdl:address rdf:resource="{@address}" />
			</xsl:if>
			<xsl:apply-templates
				select="*|@*[namespace-uri() != '' and namespace-uri() != 'http://www.w3.org/2006/01/wsdl' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema-instance' and namespace-uri() != 'http://www.w3.org/2001/XMLSchema']"
				mode="linking" />
		</rwsdl:Endpoint>
	</xsl:template>

	<!-- todo features and properties -->
	<xsl:template match="wsdl:feature[@required='true' or @required='1']"
		mode="linking">
		<rwsdl:requiresFeature rdf:resource="{@ref}" />
	</xsl:template>
	<xsl:template match="wsdl:feature[not(@required='true' or @required='1')]"
		mode="linking">
		<rwsdl:offersFeature rdf:resource="{@ref}" />
	</xsl:template>

	<xsl:template match="wsdl:property" mode="linking">
		<rwsdl:propertyValue>
			<xsl:apply-templates select="." />
		</rwsdl:propertyValue>
	</xsl:template>

	<!-- todo properties <xsl:template match="wsdl:property"> <rwsdl:PropertyValue 
		rdf:about="{ -->



	<!-- todo - known extensions - adjuncts -->
	<!-- todo handle optional extensions -->
	<!-- todo handle unknown extension attributes -->
	<!-- todo element declarations and type definitions have component designators -->
	<!-- todo check that everything appropriate (prolly everything) has internal 
		apply-templates -->


	<!-- drop everything that has mandatory extensions, unless they are the 
		known extensions -->
	<!-- todo on the above dropping, also mind import/include - import/include 
		of description with unknown mandatory extension results in nothing added -->
	<xsl:template priority='100'
		match="*[*[(@wsdl:required='true' or @wsdl:required='1') and 
      namespace-uri()!='http://www.w3.org/2006/01/wsdl' and
      namespace-uri()!='http://www.w3.org/2006/01/wsdl-extensions' and
      namespace-uri()!='http://www.w3.org/2006/01/wsdl/soap' and
      namespace-uri()!='http://www.w3.org/2006/01/wsdl/http' and
      namespace-uri()!='http://www.w3.org/2006/01/wsdl/rpc' and
      namespace-uri()!='http://www.w3.org/2001/XMLSchema']]"
		mode="linking">
		<xsl:message>
			Ignoring element
			<xsl:value-of select="name()" />
			with unknown mandatory extension.
		</xsl:message>
	</xsl:template>



	<!-- forget anything unknown todo - shout if anything in the known namespaces 
		is present - change the following rules to only include the known namespaces 
		because anything else should be preempted by extensibility handling -->
	<xsl:template match="*" mode="linking">
		<xsl:message>
			Ignoring element
			<xsl:value-of select="concat('{', namespace-uri(), '}', local-name())" />
			in linking mode.
		</xsl:message>
	</xsl:template>
	<xsl:template match="*">
		<xsl:message>
			Ignoring element
			<xsl:value-of select="concat('{', namespace-uri(), '}', local-name())" />
			.
		</xsl:message>
	</xsl:template>
	<xsl:template match="@*" mode="linking">
		<xsl:message>
			Ignoring attribute
			<xsl:value-of select="concat('{', namespace-uri(), '}', local-name())" />
			in linking mode.
		</xsl:message>
	</xsl:template>
	<xsl:template match="@*">
		<xsl:message>
			Ignoring attribute
			<xsl:value-of select="concat('{', namespace-uri(), '}', local-name())" />
			.
		</xsl:message>
	</xsl:template>


	<!-- helper functions/templates -->

	<xsl:template name="qname-ns">
		<xsl:param name="qname" />
		<xsl:param name="node" />

		<xsl:variable name="after-split" select="str:split($qname, ':')" />
		<xsl:choose>
			<xsl:when test="count($after-split) = 1">
				<xsl:value-of select="$node/namespace::*[local-name() = '']" />
			</xsl:when>
			<xsl:when test="count($after-split) = 2">
				<xsl:value-of select="$node/namespace::*[local-name() = $after-split[1]]" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">
					qname with more than one colon!
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="qname-local">
		<xsl:param name="qname" />

		<xsl:variable name="after-split" select="str:split($qname, ':')" />
		<xsl:value-of select="$after-split[position()=last()]" />
	</xsl:template>



</xsl:stylesheet>
<!-- vim:tw=0:sts=2:sw=2: -->

