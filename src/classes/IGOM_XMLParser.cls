/**
 * @author		Axel Martinez <axel.martinez@adesso.es>
 * @description	Class for parsing XML documents to an APEX Class structure. Flattens text-only nodes to attributes.
 * @history		2020/07/28  |	Axel Martinez <axel.martinez@adesso.es>  |  Creation.
 */
public without sharing class IGOM_XMLParser {
	/**
	 * Apex Object containing the data from a XML document element.
	 */
	public class XMLElement {
		public String name { get; private set; }
		public Map<String, String> attributes { get; private set; }
		public XMLElement[] children { get; private set; }
	}

	/**
	 * @description	Parses the XML document to an XMLElement object combining both child text nodes and attributes
	 * @param		xmlDocumentContent <Content of the XML document>
	 * @return		XMLElement <The root of the document>
	 */
	public static XMLElement parse(String xmlDocumentContent) {
		Dom.Document doc = new Dom.Document();
		doc.load(xmlDocumentContent);

		DOM.XmlNode root = doc.getRootElement();
		return parseElement(root);
	}

	/**
	 * @description	Parses the XML node to an XMLElement object.
	 * @param		xmlNode <Node of the xml>
	 * @return		XMLElement <The parsed XMLElement object>
	 */
	private static XMLElement parseElement(DOM.XmlNode xmlNode) {
		XMLElement elem = new XMLElement();
		elem.name = xmlNode.getName();
		elem.attributes = new Map<String, String>();
		elem.children = new List<XMLElement>();
		// Transfer every attribute
		for (Integer i = 0; i < xmlNode.getAttributeCount(); i++) {
			elem.attributes.put(xmlNode.getAttributeKeyAt(i),
								xmlNode.getAttributeValue(xmlNode.getAttributeKeyAt(i),
														  xmlNode.getAttributeKeyNsAt(i)));
		}
		// Transverse every child
		for (DOM.XmlNode child : xmlNode.getChildren()) {
			// Text-only childs are added as attributes
			if (child.getChildElements().size() == 0 && child.getName() != null && child.getText() != null) {
				elem.attributes.put(child.getName(), child.getText());
			// Elements are recursively transversed and added as children
			} else if (child.getNodeType() == Dom.XmlNodeType.ELEMENT) {
				elem.children.add(parseElement(child));
			}
		}
		return elem;
	}

}