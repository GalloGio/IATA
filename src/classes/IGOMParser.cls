/**
 * @author		Axel Martinez <axel.martinez@adesso.es>
 * @description	Parses the content of an XML IGOM document to a list of structured Document_Part__c records [section and procedure are used to reference the same concept]
 * @history	    2020/07/28  |  Axel Martinez <axel.martinez@adesso.es>	|	Creation.
 *				2020/08/18  |  Jorge Corral <jorge.corral@adesso.es>	|	IGOMSection class modified to support Comparable interface, parse and parseSections methods adapted and getIndex and getLevel added.
 */
public without sharing class IGOMParser {

	private static Map<String, String> mapISOCodeToLang = new Map<String, String>{
		'en' => IGOMConstants.GLOBALS.LANGUAGE_ENGLISH,
		'es' => IGOMConstants.GLOBALS.LANGUAGE_SPANISH,
		'fr' => IGOMConstants.GLOBALS.LANGUAGE_FRENCH
	};

	private static Map<String, String> mapRevisionStringToEnum = new Map<String, String>{
		null => IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.NONE,
		'stet' => IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.NONE,
		'inserted' => IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.NEVV,
		'deleted' => IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.DELETED,
		'changed' => IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.MODIFIED
	};

	private static List<String> categoryByLevel = new List<String>{
		IGOMConstants.DOCUMENT_PART.CATEGORY.PART,
		IGOMConstants.DOCUMENT_PART.CATEGORY.CHAPTER,
		IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION,
		IGOMConstants.DOCUMENT_PART.CATEGORY.SUB_SECTION,
		IGOMConstants.DOCUMENT_PART.CATEGORY.SUB_SUB_SECTION,
		IGOMConstants.DOCUMENT_PART.CATEGORY.PARAGRAPH,
		IGOMConstants.DOCUMENT_PART.CATEGORY.SUB_PARAGRAPH,
		IGOMConstants.DOCUMENT_PART.CATEGORY.SUB_SUB_PARAGRAPH
	};

	/**
	 * Apex Object containing the data from an IGOM Document Part that is being parsed from an XML doc.
	 */
	public class IGOMSection implements Comparable{
		public String parentPermId;

		public String permId;
		public Integer index_Original;
		public Integer index;
		public Integer level;
		public String heading;
		public Boolean isSafetyCritical;
		public String revision;

		public String language_doc;
		public String effectiveDate_doc; //Must follow a dd/mm/yyyy format
		public String edition_doc;
		public String revision_doc;

		public Integer compareTo(Object compareTo) {
			IGOMSection compareToSection = (IGOMSection)compareTo;
			if (index_Original == compareToSection.index_Original){
				//If the section that is being compared is new, it will be positioned before the other section
				if(revision != compareToSection.revision && compareToSection.revision == IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.NEVV){return 1;}
				//else if(revision != compareToSection.revision && revision == RevisionStatus.STATUS_NEW){return 0;}
				else{return 0;}
			}
			if (index_Original > compareToSection.index_Original) return 1;
			return -1;
		}

		public Date getEffectiveDate(){
			if (effectiveDate_doc != null) {
				List<String> effectiveDateInfo = effectiveDate_doc.split('/');
				return Date.newInstance(Integer.valueOf(effectiveDateInfo.get(0)), Integer.valueOf(effectiveDateInfo.get(1)), Integer.valueOf(effectiveDateInfo.get(2)));
			}
			return null;
		}
	}
	
	public class ParsingException extends Exception{}

	/**
	 * @description	Parses the XML document to an IGOM object where all sections are structured the same way
	 * @param		xmlString <Content of the IGOM XML document>
	 * @return		Id <Created manual Id>
	 */
	public static Id parse(String xmlString) {
		IGOM_XMLParser.XMLElement xmlParsed = IGOM_XMLParser.parse(xmlString);
		List<IGOMSection> sections = parseSections(xmlParsed);

		Map<Integer, List<Document_Part__c>> sectionsByLevel = new Map<Integer, List<Document_Part__c>>();
		List<Document_Part__c> sectionsToInsert = new List<Document_Part__c>();
		Set<String> allPermIds = new Set<String>();

		if (!sections.isEmpty()) {
			String language_doc = IGOMConstants.GLOBALS.LANGUAGE_ENGLISH;
			String edition_doc;
			String revision_doc;
			List<String> firstReminderDateInfo = IGOMConstants.METADATA.REMINDERS_FIRST_DATE.split('/');
			Date effectiveDate_doc = Date.newInstance(Integer.valueOf(firstReminderDateInfo.get(0)), Integer.valueOf(firstReminderDateInfo.get(1)), Integer.valueOf(firstReminderDateInfo.get(2)));
			for (IGOMSection section : sections) {
				//Obtain document related object
				if (section.language_doc != null) {
					language_doc = mapISOCodeToLang.get(section.language_doc);
				}
				
				Date docEffectiveDate = section.getEffectiveDate();
				if (docEffectiveDate != null) {
					effectiveDate_doc = docEffectiveDate;
				}

				if (section.edition_doc != null) {
					edition_doc = section.edition_doc;
				}
				if (section.revision_doc != null) {
					revision_doc = section.revision_doc;
				}
			}

			Id igomRecordType = RecordTypeSingleton.getInstance().getRecordTypeId('Document__c', IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM);

			Document__c manual = new Document__c(
				CurrencyIsoCode = 'USD',
				Document_Name__c = 'IGOM',
				Edition__c = edition_doc,
				Revision__c = revision_doc,
				Published_Date__c = Date.today(),
				Effective_Date__c = effectiveDate_doc,
				Type__c = IGOMConstants.DOCUMENT.TYPE.FILES,
				Abbreviated_Name__c = 'IGOM',
				Review_Date__c = Date.today().addDays(365),
				Language__c = language_doc,
				Is_Active__c = false,
				RecordTypeId = igomRecordType
			);
			insert manual;

			//Map fields to Sf
			Map<String, Document_Part__c> permIdToAuditableProcedure = new Map<String, Document_Part__c>();
			Map<String, String> permIdToParentPermId = new Map<String, String>();
			for(IGOMSection section : sections){
				Document_Part__c procedure = new Document_Part__c(
					External_Reference_ID__c = section.permId,
					Name__c = section.heading,
					Category__c = getCategory(section.level),
					Index__c = section.index,
					Is_Safety_Critical__c = section.isSafetyCritical,
					Version_Change_Status__c = section.revision,
					Document__c = manual.Id
				);

				permIdToAuditableProcedure.put(section.permId, procedure);
				if(section.parentPermId != null) {
					permIdToParentPermId.put(section.permId, section.parentPermId);
				}

				sectionsToInsert.add(procedure);


				allPermIds.add(section.permId);
			}

			insert sectionsToInsert;

			// Relate each procedure with its parent
			for (Document_Part__c auditableProcedure : sectionsToInsert) {
				final String parentPermid = permIdToParentPermId.get(auditableProcedure.External_Reference_ID__c);
				if (parentPermid != null) {
					auditableProcedure.Parent__c = permIdToAuditableProcedure.get(parentPermid).Id;
				}
			}
			update sectionsToInsert;

			//Link the inserted file to Manual
			ContentVersion cv = createContentVersion(EncodingUtil.Base64Encode(Blob.valueOf(xmlString)), manual.Id + '.xml');
			createContentLink(cv.Id, manual.Id);

			return manual.Id;
		}else{
			return null;
		}
	}

	/**
	 * @description	Returns the category based on the level
	 * @param		lv <Level of the document part>
	 * @return		String <Category for the specified level>
	 */
	public static String getCategory(Integer lv) {
		try{
			return categoryByLevel.get(lv-1);
		}catch(ListException exc){
			throw new ParsingException(String.format(IGOMConstants.ERRORS.LV_WITHOUT_CATEGORY_ERROR, new List<Object>{String.valueOf(lv)}));
		}
	}

	/**
	 * @description	Recursive method that creates a list of IGOM Sections where content is structured similar to
	 *				the final Document_Part__c structure
	 * @param		element <Content of a general XML element>
	 * @return		List<IGOMSection> <The list of IGOM Sections created so far>
	 */
	private static List<IGOMSection> parseSections(IGOM_XMLParser.XMLElement element) {
		List<IGOMSection> sections = new List<IGOMSection>();

		//If element contains children, it will create a section for each of them and sort them assigning each of them an ordered index
		if(element.children.size() != 0){
			for(Integer i = 0; i<element.children.size(); i++){
				//Call this same method recursively to start from lower levels upwards
				sections.addAll(parseSections(element.children.get(i)));
			}

			//Create a list exclusively with the children sections to set the index correctly
			List<IGOMSection> childrenSections = new List<IGOMSection>();
			for(IGOM_XMLParser.XMLElement child : element.children){
				for(IGOMSection section : sections){
					if(child.attributes.get('permid') == section.permId){
						childrenSections.add(section);
					}
				}
			}

			//Sort the list of children based on original index
			childrenSections.sort();

			Integer index = 1;
			for(IGOMSection section : childrenSections){
				//If element was deleted leave the index as null
				//Do not modify the index variable, in any other case, set the index
				if(section.revision != IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.DELETED){
					section.index = index;
					index++;
				}
				section.parentPermId = element.name != IGOMConstants.GLOBALS.XML_ENCAPSULATOR_NAME ? element.attributes.get('permid') : null;
			}
		}

		if(element.name != IGOMConstants.GLOBALS.XML_ENCAPSULATOR_NAME){
			//Create the IGOMSection no matter if it has children or not
			IGOMSection section = new IGOMSection();
			if (element.attributes.get(element.name + 'Number') == null) {
				throw new AuraHandledException(element.name + ' (' + element.attributes.get('permid') + ') does not have a number');
			}
			Integer index = getIndex(element.attributes.get(element.name + 'Number'));
			section.index_Original = index;
			section.index = element.attributes.get(element.name + 'Number').contains(IGOMConstants.GLOBALS.XML_ENCAPSULATOR_NAME) ? index : null;
			section.heading = element.attributes.get(element.name + 'Heading');
			section.permId = element.attributes.get('permid');
			section.isSafetyCritical = element.attributes.get('iatareq') == 'yes';
			section.revision = mapRevisionStringToEnum.get(element.attributes.get('rev'));
			section.level = getLevel(element.attributes.get(element.name + 'Number'));
			section.language_doc = element.attributes.get('lang');
			section.effectiveDate_doc = element.attributes.get('effectivedate');
			section.revision_doc = element.attributes.get('revision');
			section.edition_doc = element.attributes.get('edition');
			sections.add(section);
		}
		return sections;
	}

	/**
	 * @description	Obtain the index of the section based on the section number string
	 * @param		str <section number (this string can have either a 'Chapter x:' or a 'z.y.x...' format)>
	 * @return		Integer <The position of the child element relative to its parent>
	 */
	private static Integer getIndex(String str){
		try {
			if(str.contains(IGOMConstants.GLOBALS.XML_ENCAPSULATOR_NAME) ||
			str.contains(IGOMConstants.GLOBALS.XML_ENCAPSULATOR_NAME_ES) ||
			str.contains(IGOMConstants.GLOBALS.XML_ENCAPSULATOR_NAME_FR)){
				return Integer.valueOf(str.substringBetween(' ', ':').replaceAll( '\\s+', ''));
			}else{
				return Integer.valueOf(str.substringAfterLast('.'));
			}
		} catch (Exception ex ) {
			throw new AuraHandledException('Cant get the index from "' + str + '"');
		}
	}

	/**
	 * @description	Obtain the level of the section based on the section number string
	 * @param		str <section number (this string can have either a 'Chapter x:' or a 'z.y.x...' format)>
	 * @return		Integer <The level that the section takes in the document (Following the stucture: 'Chapter x:' = 1, 'y.x' = 2, 'z.y.x:' = 3, etc.)>
	 */
	private static Integer getLevel(String str){
		if(str.contains(IGOMConstants.GLOBALS.XML_ENCAPSULATOR_NAME)){
			return 1;
		}else{
			return str.countMatches('.') + 1;
		}
	}

	/**
	 * @description	Creates a content version from a given file's base64 and name
	 * @param		base64 <base64 string that represents the file>
	 * @param		filename <full file name with extension, i.e. 'Invoice.pdf'>
	 * @return		ContentVersion <returns the newly created ContentVersion, or null if there was an error inserting the record>
	 */
	private static ContentVersion createContentVersion(String base64, String filename) {
		ContentVersion cv = new ContentVersion();
		cv.VersionData = EncodingUtil.base64Decode(base64);
		cv.Title = filename;
		cv.PathOnClient = filename;
		if (Test.isRunningTest()) {
			Id networkId = [SELECT Id FROM Network WHERE Name LIKE '%CS Portal%' LIMIT 1].Id;
			cv.NetworkId = networkId;
		}
		try {
			insert cv;
			return cv;
		} catch(DMLException e) {
			return null;
		}
	}

	/**
	 * @description	Creates a content link for a given ContentVersion and record
	 * @param 		contentVersionId - Id of the ContentVersion of the file
	 * @param 		recordId - Id of the record you want to attach this file to
	 * @return		ContentDocumentLink <returns the newly created ContentDocumentLink, or null if there was an error inserting the record>
	 */
	private static void createContentLink(String contentVersionId, String recordId) {
		if (contentVersionId != null && recordId != null) {
			ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.ContentDocumentId = [SELECT ContentDocumentId
									FROM ContentVersion
									WHERE Id =: contentVersionId].ContentDocumentId;
			cdl.LinkedEntityId = recordId;
			// ShareType is either 'V', 'C', or 'I'
			// V = Viewer, C = Collaborator, I = Inferred
			cdl.ShareType = 'V';
			insert cdl;
		}
	}
}