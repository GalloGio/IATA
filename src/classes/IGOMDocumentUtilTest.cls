@isTest
public inherited sharing class IGOMDocumentUtilTest {
	public static final String IGOM_NAME = 'IGOM Document';
	public static final String PART_1_NAME = 'Part 1';
	public static final String PART_2_NAME = 'Part 2';
	public static final String EXC_NOT_THROWN = 'Exception not thrown';
	public static final String UNEXP_EXC_CAUGHT = 'Unexpected exception caught ';

	@TestSetup
	static void makeData() {
		// Generate an IGOM and a GOM
		List<Document__c> documents = new List<Document__c>();
		Document__c igomDocument = IGOMTestFactory.documentFactoryCreation(1, null, IGOM_NAME, 'English', IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM)[0];
		documents.add(igomDocument);
		Document__c gomDocument = IGOMTestFactory.documentFactoryCreation(1, null, 'GOM Document', 'English', IGOMConstants.DOCUMENT.RECORD_TYPE.GOM)[0];
		documents.add(gomDocument);
		insert documents;
		// Generate IGOM parts
		List<Document_Part__c> documentParts = new List<Document_Part__c>();
		//Chapter 1
		Document_Part__c chapter1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.PART, igomDocument.Id, 1, PART_1_NAME);
		chapter1.External_Reference_ID__c = '0000';
		documentParts.add(chapter1);
		Document_Part__c section1_1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.CHAPTER, igomDocument.Id, 1, 'Chapter 1');
		section1_1.External_Reference_ID__c = '0001';
		documentParts.add(section1_1);
		Document_Part__c section1_2 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.CHAPTER, igomDocument.Id, 2, 'Chapter 2');
		section1_2.External_Reference_ID__c = '0002';
		documentParts.add(section1_2);
		Document_Part__c subchapter1_1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION, igomDocument.Id, 1, 'Section 1 Proc. 1');
		subchapter1_1.External_Reference_ID__c = '0003';
		subchapter1_1.Version_Change_Status__c = IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.MODIFIED;
		documentParts.add(subchapter1_1);
		Document_Part__c subchapter1_2 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION, igomDocument.Id, 2, 'Section 1 Proc. 2');
		subchapter1_2.External_Reference_ID__c = '0004';
		subchapter1_2.Version_Change_Status__c = IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.MODIFIED;
		documentParts.add(subchapter1_2);
		Document_Part__c subchapter1_3 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION, igomDocument.Id, 1, 'Section 2 Proc. 1');
		subchapter1_3.External_Reference_ID__c = '0005';
		subchapter1_3.Version_Change_Status__c = IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.MODIFIED;
		documentParts.add(subchapter1_3);
		//Chapter 2
		Document_Part__c chapter2 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.PART, igomDocument.Id, 2, PART_2_NAME);
		chapter2.External_Reference_ID__c = '0006';
		documentParts.add(chapter2);
		Document_Part__c section2_1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.CHAPTER, igomDocument.Id, 1, 'Chapter 1');
		section2_1.External_Reference_ID__c = '0007';
		documentParts.add(section2_1);
		Document_Part__c subchapter2_1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION, igomDocument.Id, 1, 'Section 1 Proc. 1');
		subchapter2_1.External_Reference_ID__c = '0008';
		documentParts.add(subchapter2_1);
		Document_Part__c subsubchapter2_1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SUB_SECTION, igomDocument.Id, 1, 'Section 1 Proc. 1 Sub section 1');
		subsubchapter2_1.External_Reference_ID__c = '0009';
		subsubchapter2_1.Version_Change_Status__c = IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.MODIFIED;
		documentParts.add(subsubchapter2_1);
		insert documentParts;

		//Assign parents
		subchapter1_3.Parent__c = section1_2.Id;
		subchapter1_2.Parent__c = section1_1.Id;
		subchapter1_1.Parent__c = section1_1.Id;
		section1_2.Parent__c = chapter1.Id;
		section1_1.Parent__c = chapter1.Id;

		subsubchapter2_1.Parent__c = subchapter2_1.Id;
		subchapter2_1.Parent__c = section2_1.Id;
		section2_1.Parent__c = chapter2.Id;
		update documentParts;

		IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ);

		List<SObject> stationObjects = IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ).get(0);
		insert new Apex_Setting__c(Name='RT valid to reopen attachment trigger', Text_1__c='CasesEurope,Cases_Global,CasesAmericas,CasesMENA,ExternalCasesIDFSglobal,Cases_China_North_Asia, ComplaintIDFS,'
                                           +  'Inter_DPCs,Invoicing_Collection_Cases,Cases_SIS_Help_Desk,InternalCasesEuropeSCE,CS_Process_IDFS_ISS,ID_Card_Application');
	}

    
	/**
	 * @description Test the queryDocumentById method.
	 */
	@isTest
	public static void queryDocumentByIdTest(){
        List<Id> documentIds = new List<Id>();
        for (Document__c doc : [SELECT Id FROM Document__c]) {
            documentIds.add(doc.Id);
        }

        List<IGOMDocumentUtil.Document> documents = new List<IGOMDocumentUtil.Document>();
        Test.startTest();
        documents = IGOMDocumentUtil.queryDocumentById(documentIds);
        Test.stopTest();

		System.assertEquals(2, documents.size());
    }

	
	/**
	 * @description Test the getDocumentsByStationId method.
	 */
	@isTest
	public static void getDocumentsByStationIdTest(){
		Id stationId = [SELECT Id FROM Account_Role__c LIMIT 1].Id;
        Document__c doc = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];
        doc.Station__c = stationId;
		update doc;

        List<IGOMDocumentUtil.Document> documents = new List<IGOMDocumentUtil.Document>();
        Test.startTest();
        documents = IGOMDocumentUtil.getDocumentsByStationId(stationId);
        Test.stopTest();

		System.assertEquals(1, documents.size());
    }
	
	
	/**
	 * @description Test the getIGOMManualById method.
	 */
	@isTest
	public static void getIGOMManualByIdTest(){
        Document__c igomDoc = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];

        IGOMDocumentUtil.Document igom;
        Test.startTest();
        igom = IGOMDocumentUtil.getIGOMManualById(igomDoc.Id);
        Test.stopTest();

		System.assertEquals(IGOM_NAME, igom.name);
	}

	/**
	 * @description Test the getIGOMManualById method when the document is not an IGOM.
	 */
	@isTest
	public static void getIGOMManualByIdTest_NoPermission(){
        Document__c gomDoc = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];
        IGOMDocumentUtil.Document igom;
        Test.startTest();
		try {
			igom = IGOMDocumentUtil.getIGOMManualById(gomDoc.Id);
			System.assert(false, EXC_NOT_THROWN);
		} catch (AuraHandledException exc) {
			System.assert(true);
		} catch (Exception error) {
			System.assert(false, UNEXP_EXC_CAUGHT + error);
		}
        Test.stopTest();
	}


	/**
	 * @description Test the getLastActiveIGOMManual method.
	 */
	@isTest
	public static void getLastActiveIGOMManualTest(){
        IGOMDocumentUtil.Document lastActiveManual;
		
        Test.startTest();
		lastActiveManual = IGOMDocumentUtil.getLastActiveIGOMManual();
        Test.stopTest();

        Document__c igomDoc = [SELECT Id, Name, RecordType.Name, Abbreviated_Name__c, Edition__c, Version__c, Revision__c, Document_Name__c,
		Published_Date__c, Review_date__c, Station__c, Effective_Date__c, Type__c FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];

        IGOMDocumentUtil.Document igom = new IGOMDocumentUtil.Document(igomDoc);
		System.assertEquals(igom.id, lastActiveManual.id);
		System.assertEquals(igom.name, lastActiveManual.name);
		System.assertEquals(igom.publishDate, lastActiveManual.publishDate);
	}

	/**
	 * @description Test the getMyStationsDocuments method.
	 */
	@isTest
	public static void getMyStationsDocumentsTest_Success(){
		Id stationAccRoleId = [SELECT Id FROM Account_Role__c LIMIT 1].Id;
		Id stationId = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1].Id;
		
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];

        Document__c doc = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];
        doc.Station__c = stationAccRoleId;
		update doc;

        List<IGOMDocumentUtil.Document> documents = new List<IGOMDocumentUtil.Document>();
        Test.startTest();
		System.runAs(user){
        	documents = IGOMDocumentUtil.getMyStationsDocuments(stationId);
		}
        Test.stopTest();

		System.assertEquals(1, documents.size());
	}
	
	/**
	 * @description Test the getMyStationsDocuments method when the user has no permission.
	 */
	@isTest
	public static void getMyStationsDocumentsTest_NoPermission(){
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = IGOMConstants.ROLES.VIEWER;
		update contactRole;
		IGOM_Account_Role_Detail__c station = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1];
		User user = [SELECT Id FROM User LIMIT 1];

        List<IGOMDocumentUtil.Document> stationDocs;
        Test.startTest();
		System.runAs(user){
			try {
				stationDocs = IGOMDocumentUtil.getMyStationsDocuments(station.Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
        Test.stopTest();
	}

	
	/**
	 * @description Test the getCurrentIGOMLanguages method.
	 */
	@isTest
	public static void getCurrentIGOMLanguagesTest(){
		List<Document__c> documents = new List<Document__c>();
		Document__c igomDocument_ES = IGOMTestFactory.documentFactoryCreation(1, null, IGOM_NAME, 'Spanish', IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM)[0];
		documents.add(igomDocument_ES);
		Document__c igomDocument_FR = IGOMTestFactory.documentFactoryCreation(1, null, IGOM_NAME, 'French', IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM)[0];
		documents.add(igomDocument_FR);
		insert documents;

		List<String> langs = new List<String>();
		Test.startTest();
		langs = IGOMDocumentUtil.getCurrentIGOMLanguages();
		Test.stopTest();

		System.assertEquals(3, langs.size());
	}


	/**
	 * @description Test the getPermidsToChapter method.
	 */
	@isTest
	public static void getPermidsToChapterTest(){
        Document__c igom = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];
		Map<String, String> permIdsToChapters = new Map<String, String>();
		Test.startTest();
		permIdsToChapters = IGOMDocumentUtil.getPermidsToChapter(igom.Id);
		Test.stopTest();

		System.assertEquals(PART_1_NAME, permIdsToChapters.get('0000'));
		System.assertEquals(PART_1_NAME, permIdsToChapters.get('0001'));
		System.assertEquals(PART_1_NAME, permIdsToChapters.get('0002'));
		System.assertEquals(PART_1_NAME, permIdsToChapters.get('0003'));
		System.assertEquals(PART_1_NAME, permIdsToChapters.get('0004'));
		System.assertEquals(PART_1_NAME, permIdsToChapters.get('0005'));
		System.assertEquals(PART_2_NAME, permIdsToChapters.get('0006'));
		System.assertEquals(PART_2_NAME, permIdsToChapters.get('0007'));
		System.assertEquals(PART_2_NAME, permIdsToChapters.get('0008'));
		System.assertEquals(PART_2_NAME, permIdsToChapters.get('0009'));
	}


	/**
	 * @description Test the getCurrentIGOMFormatted method for the main language.
	 */
	@isTest
	public static void getCurrentIGOMFormattedTest_Success(){
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		IGOMDocumentUtil.IGOMManual formattedIgom;
		Test.startTest();
		System.runAs(user){
			formattedIgom = IGOMDocumentUtil.getCurrentIGOMFormatted('English');
		}
		Test.stopTest();

        Document__c igom = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];
		System.assertEquals(igom.Id, formattedIgom.manual.Id);
		System.assertEquals(2, formattedIgom.chapters.size());

		System.assertEquals(2, formattedIgom.chapters.get(0).subprocedures.size());
		System.assertEquals(1, formattedIgom.chapters.get(1).subprocedures.size());

		System.assertEquals(2, formattedIgom.chapters.get(0).subprocedures.get(0).subprocedures.size());
		System.assertEquals(1, formattedIgom.chapters.get(0).subprocedures.get(1).subprocedures.size());
	}

	/**
	 * @description Test the getCurrentIGOMFormatted method when the IGOM that wants to be retrieved is not in main language.
	 */
	@isTest
	public static void getCurrentIGOMFormattedTest_SuccessOtherLang(){
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		
		Document__c igomDocumentSp = IGOMTestFactory.documentFactoryCreation(1, null, IGOM_NAME, 'Spanish', IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM)[0];
		insert igomDocumentSp;

		// Generate IGOM parts in spanish
		List<Document_Part__c> documentParts = new List<Document_Part__c>();
		//Chapter 1
		Document_Part__c chapter1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.PART, igomDocumentSp.Id, 1, 'Parte 1');
		chapter1.External_Reference_ID__c = '0000';
		documentParts.add(chapter1);
		Document_Part__c section1_1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.CHAPTER, igomDocumentSp.Id, 1, 'Capítulo 1');
		section1_1.External_Reference_ID__c = '0001';
		documentParts.add(section1_1);
		Document_Part__c section1_2 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.CHAPTER, igomDocumentSp.Id, 1, 'Capítulo 2');
		section1_2.External_Reference_ID__c = '0002';
		documentParts.add(section1_2);
		Document_Part__c subchapter1_1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION, igomDocumentSp.Id, 1, 'Sección 1 Proc. 1');
		subchapter1_1.External_Reference_ID__c = '0003';
		subchapter1_1.Version_Change_Status__c = IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.MODIFIED;
		documentParts.add(subchapter1_1);
		Document_Part__c subchapter1_2 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION, igomDocumentSp.Id, 2, 'Sección 1 Proc. 2');
		subchapter1_2.External_Reference_ID__c = '0004';
		subchapter1_2.Version_Change_Status__c = IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.MODIFIED;
		documentParts.add(subchapter1_2);
		Document_Part__c subchapter1_3 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION, igomDocumentSp.Id, 1, 'Sección 2 Proc. 1');
		subchapter1_3.External_Reference_ID__c = '0005';
		subchapter1_3.Version_Change_Status__c = IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.MODIFIED;
		documentParts.add(subchapter1_3);
		//Chapter 2
		Document_Part__c chapter2 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.PART, igomDocumentSp.Id, 1, 'Parte 2');
		chapter2.External_Reference_ID__c = '0006';
		documentParts.add(chapter2);
		Document_Part__c section2_1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.CHAPTER, igomDocumentSp.Id, 1, 'Capítulo 1');
		section2_1.External_Reference_ID__c = '0007';
		documentParts.add(section2_1);
		Document_Part__c subchapter2_1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION, igomDocumentSp.Id, 1, 'Sección 1 Proc. 1');
		subchapter2_1.External_Reference_ID__c = '0008';
		documentParts.add(subchapter2_1);
		Document_Part__c subsubchapter2_1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SUB_SECTION, igomDocumentSp.Id, 1, 'Sección 1 Proc. 1 Sub sección 1');
		subsubchapter2_1.External_Reference_ID__c = '0009';
		subsubchapter2_1.Version_Change_Status__c = IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.MODIFIED;
		documentParts.add(subsubchapter2_1);
		insert documentParts;

		//Assign parents
		subchapter1_3.Parent__c = section1_2.Id;
		subchapter1_2.Parent__c = section1_1.Id;
		subchapter1_1.Parent__c = section1_1.Id;
		section1_2.Parent__c = chapter1.Id;
		section1_1.Parent__c = chapter1.Id;

		subsubchapter2_1.Parent__c = subchapter2_1.Id;
		subchapter2_1.Parent__c = section2_1.Id;
		section2_1.Parent__c = chapter2.Id;
		update documentParts;

		IGOMDocumentUtil.IGOMManual formattedIgom;
		Test.startTest();
		System.runAs(user){
			formattedIgom = IGOMDocumentUtil.getCurrentIGOMFormatted('Spanish');
		}
		Test.stopTest();

        Document__c igom = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM AND Language__c = :IGOMConstants.GLOBALS.LANGUAGE_ENGLISH LIMIT 1];
		System.assertEquals(igom.Id, formattedIgom.manual.Id); //It keeps the id from the main igom
		System.assertEquals(2, formattedIgom.chapters.size());

		System.assertEquals(2, formattedIgom.chapters.get(0).subprocedures.size());
		System.assertEquals(1, formattedIgom.chapters.get(1).subprocedures.size());
		
		System.assertEquals('Parte 1', formattedIgom.chapters.get(0).procedure.Name__c);
		System.assertEquals('Parte 2', formattedIgom.chapters.get(1).procedure.Name__c);
	}

	/**
	 * @description Test the getCurrentIGOMFormatted method when the IGOM does not have that language.
	 */
	@isTest
	public static void getCurrentIGOMFormattedTest_DiffLang(){
		User user = [SELECT Id FROM User LIMIT 1];
		IGOMDocumentUtil.IGOMManual formattedIgom;
		Test.startTest();
		System.runAs(user){
			try {
				formattedIgom = IGOMDocumentUtil.getCurrentIGOMFormatted('Spanish');
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
		Test.stopTest();
	}

	/**
	 * @description Test the getCurrentIGOMFormatted method when the IGOM does not have any language.
	 */
	@isTest
	public static void getCurrentIGOMFormattedTest_NoLang(){
		User user = [SELECT Id FROM User LIMIT 1];

		Document__c igom = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];
		igom.Language__c = null;
		update igom;

		IGOMDocumentUtil.IGOMManual formattedIgom;
		Test.startTest();
		System.runAs(user){
			try {
				formattedIgom = IGOMDocumentUtil.getCurrentIGOMFormatted('English');
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
		Test.stopTest();
	}

	/**
	 * @description Test the getCurrentIGOMFormatted method when the IGOM does not exist in english.
	 */
	@isTest
	public static void getCurrentIGOMFormattedTest_NoIgomInEnglish(){
		User user = [SELECT Id FROM User LIMIT 1];

		Document__c igom = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];
		delete igom;
		
		Document__c igomDocumentSp = IGOMTestFactory.documentFactoryCreation(1, null, IGOM_NAME, 'Spanish', IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM)[0];
		insert igomDocumentSp;

		IGOMDocumentUtil.IGOMManual formattedIgom;
		Test.startTest();
		System.runAs(user){
			try {
				formattedIgom = IGOMDocumentUtil.getCurrentIGOMFormatted('English');
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
		Test.stopTest();
	}

	/**
	 * @description Test the getCurrentIGOMFormatted method when the IGOM does not exist.
	 */
	@isTest
	public static void getCurrentIGOMFormattedTest_NoIgom(){
		User user = [SELECT Id FROM User LIMIT 1];

		Document__c igom = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];
		delete igom;

		IGOMDocumentUtil.IGOMManual formattedIgom;
		Test.startTest();
		System.runAs(user){
			try {
				formattedIgom = IGOMDocumentUtil.getCurrentIGOMFormatted('English');
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
		Test.stopTest();
	}

	/**
	 * @description Test the getCurrentIGOMFormatted method when the IGOM that wants to be retrieved is not in main language but it does not have translations.
	 */
	@isTest
	public static void getCurrentIGOMFormattedTest_NoTranslation(){
		User user = [SELECT Id FROM User LIMIT 1];
		
		Document__c igomDocumentSp = IGOMTestFactory.documentFactoryCreation(1, null, IGOM_NAME, 'Spanish', IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM)[0];
		insert igomDocumentSp;

		IGOMDocumentUtil.IGOMManual formattedIgom;
		Test.startTest();
		System.runAs(user){
			try {
				formattedIgom = IGOMDocumentUtil.getCurrentIGOMFormatted('Spanish');
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
		Test.stopTest();
	}

	
	/**
	 * @description Test the upsertGomDocument method.
	 */
	@isTest
	public static void upsertGomDocumentTest_Success(){
		IGOM_Account_Role_Detail__c station = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1];
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];

        Document__c gom = [SELECT Id, Station__c, RecordType.Name, Document_Name__c, Abbreviated_Name__c, Type__c, Published_Date__c,
		Review_date__c, Effective_date__c, Version__c, Edition__c, Revision__c FROM Document__c 
		WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];

        IGOMDocumentUtil.Document stationDoc;
        Test.startTest();
		System.runAs(user){
			stationDoc = IGOMDocumentUtil.upsertGomDocument(station.Id, new IGOMDocumentUtil.Document(gom));
		}
		Test.stopTest();

		Account_Role__c stationAccRole = [SELECT Id FROM Account_Role__c LIMIT 1];

		System.assertEquals(stationAccRole.Id, stationDoc.stationId);
	}

	/**
	 * @description Test the upsertGomDocument method when the user has no permission.
	 */
	@isTest
	public static void upsertGomDocumentTest_NoPermission(){
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = IGOMConstants.ROLES.VIEWER;
		update contactRole;
		IGOM_Account_Role_Detail__c station = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1];
		User user = [SELECT Id FROM User LIMIT 1];
        Document__c gom = [SELECT Id, Station__c, RecordType.Name, Document_Name__c, Abbreviated_Name__c, Type__c, Published_Date__c,
		Review_date__c, Effective_date__c, Version__c, Edition__c, Revision__c FROM Document__c 
		WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];

		IGOMDocumentUtil.Document stationDoc;
        Test.startTest();
		System.runAs(user){
			try {
				stationDoc = IGOMDocumentUtil.upsertGomDocument(station.Id, new IGOMDocumentUtil.Document(gom));
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
        Test.stopTest();
	}
	

	/**
	 * @description Test the importGomDocuments method.
	 */
	@isTest
	public static void importGomDocumentsTest(){
		List<Document__c> gomDocuments = IGOMTestFactory.documentFactoryCreation(5, null, 'GOM Document', 'English', IGOMConstants.DOCUMENT.RECORD_TYPE.GOM);
		insert gomDocuments;

		List<Attachment> gomAttachments = new List<Attachment>();
		List<IGOMDocumentUtil.Document> goms = new List<IGOMDocumentUtil.Document>();
		Set<Id> docIds = new Set<Id>();
		for (Document__c doc : gomDocuments) {
			gomAttachments.add(new Attachment(
				Name = 'Test Attachment',
				Body = Blob.valueOf('Test body for the attachment'),
				ParentId = doc.Id
			));
			goms.add(new IGOMDocumentUtil.Document(doc));
			docIds.add(doc.Id);
		}
		insert gomAttachments;

		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = IGOMConstants.ROLES.VIEWER;
		update contactRole;
		Account_Role__c stationAccRole = [SELECT Id FROM Account_Role__c LIMIT 1];
		Map<Id, IGOMDocumentUtil.Document> newDocPerOldDocId = new Map<Id, IGOMDocumentUtil.Document>();
		Test.startTest();
		newDocPerOldDocId = IGOMDocumentUtil.importGomDocuments(goms, stationAccRole.Id);
		Test.stopTest();

		System.assertEquals(gomDocuments.size(), newDocPerOldDocId.size());
		for (Id oldDocId : newDocPerOldDocId.keySet()) {
			System.assert(docIds.contains(oldDocId));
			System.assertNotEquals(null, newDocPerOldDocId.get(oldDocId));
		}
	}

	
	/**
	 * @description Test the deleteGomDocument method.
	 */
	@isTest
	public static void deleteGomDocumentTest_Success(){
		Id stationId = [SELECT Id FROM Account_Role__c LIMIT 1].Id;

        Document__c doc = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];
        doc.Station__c = stationId;
		update doc;
        Document__c igomDoc = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];

		Document_Part__c chapter1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.PART, igomDoc.Id, 1, PART_1_NAME);
		chapter1.External_Reference_ID__c = '0000';
		insert chapter1;
		
		// Generate a compliance review
		Compliance_Review__c complianceReview = IGOMTestFactory.createComplianceReview(igomDoc.Id, stationId, 'GAP');
		insert complianceReview;

		// Generate the compliance review parts of the first chapter in this compliance review
		List<Compliance_Review_Part__c> complianceReviewParts = new List<Compliance_Review_Part__c>();
		Compliance_Review_Part__c complianceReviewPart = IGOMTestFactory.createComplianceReviewPart(complianceReview.Id, chapter1.Id, doc.Id);
		complianceReviewPart.Status__c = IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION;
		// complianceReviewPart.Variation_Comments__c = 'Varies 1';
		insert complianceReviewPart;

		insert new Attachment(
			Name = 'Test Attachment',
			Body = Blob.valueOf('Test body for the attachment'),
			ParentId = doc.Id
		);
		
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c WHERE  Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		System.runAs(user){
			IGOMDocumentUtil.deleteGomDocument(doc.Id);
		}
		Test.stopTest();

        List<Document__c> docs = [SELECT Id FROM Document__c];
		for (Document__c d : docs) {
			System.assertNotEquals(doc.Id, d.Id);
		}

		List<Compliance_Review_Part__c> parts = [SELECT Id FROM Compliance_Review_Part__c WHERE Document__c = :doc.Id];
		System.assertEquals(0, parts.size());
	}

	/**
	 * @description Test the deleteGomDocument method when the object is not a Document__c type.
	 */
	@isTest
	public static void deleteGomDocumentTest_OtherObjectType(){
		Id stationId = [SELECT Id FROM Account_Role__c LIMIT 1].Id;
		Test.startTest();
		try {
			IGOMDocumentUtil.deleteGomDocument(stationId);
			System.assert(false, EXC_NOT_THROWN);
		} catch (AuraHandledException exc) {
			System.assert(true);
		} catch (Exception error) {
			System.assert(false, UNEXP_EXC_CAUGHT + error);
		}
		Test.stopTest();
	}
	
	/**
	 * @description Test the deleteGomDocument method when the document id does not correspond to a document.
	 */
	@isTest
	public static void deleteGomDocumentTest_NoDocForId(){
		Document__c doc = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];
		delete doc;
		Test.startTest();
		try {
			IGOMDocumentUtil.deleteGomDocument(doc.Id);
			System.assert(false, EXC_NOT_THROWN);
		} catch (AuraHandledException exc) {
			System.assert(true);
		} catch (Exception error) {
			System.assert(false, UNEXP_EXC_CAUGHT + error);
		}
		Test.stopTest();
	}

	/**
	 * @description Test the deleteGomDocument method when the document is not a gom document.
	 */
	@isTest
	public static void deleteGomDocumentTest_NotGomDoc(){
		Document__c igomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];
		Test.startTest();
		try {
			IGOMDocumentUtil.deleteGomDocument(igomDocument.Id);
			System.assert(false, EXC_NOT_THROWN);
		} catch (AuraHandledException exc) {
			System.assert(true);
		} catch (Exception error) {
			System.assert(false, UNEXP_EXC_CAUGHT + error);
		}
		Test.stopTest();
	}

	
	/**
	 * @description Test the deleteGomDocument method when the user has no permission.
	 */
	@isTest
	public static void deleteGomDocumentTest_NoPermission(){
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = IGOMConstants.ROLES.VIEWER;
		update contactRole;
		User user = [SELECT Id FROM User LIMIT 1];
		Id stationId = [SELECT Id FROM Account_Role__c LIMIT 1].Id;
		
        Document__c doc = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];
        doc.Station__c = stationId;
		update doc;
        Test.startTest();
		System.runAs(user){
			try {
				IGOMDocumentUtil.deleteGomDocument(doc.Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
        Test.stopTest();
	}

	
	/**
	 * @description Test the getIGOMManualIndex method.
	 */
	@isTest
	public static void getIGOMManualIndexTest(){
		Document__c igom = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];

		Map<Id, IGOMDocumentUtil.Index> indexesById = new Map<Id, IGOMDocumentUtil.Index>();
		Test.startTest();
		indexesById = IGOMDocumentUtil.getIGOMManualIndex(igom.Id);
		Test.stopTest();
		System.assert(!indexesById.isEmpty());
		System.assertEquals(10, indexesById.size());
	}

	
	/**
	 * @description Test the uploadIGOMDocument method.
	 */
	@isTest
	public static void uploadIGOMDocumentTest_Success(){
		String xmlFile = '<?xmlversion="1.0" encoding="utf-8"?><Chapter permid="igom-gap-1" id="igom-gap-1" edition="10" xml:lang="en"><Section1 permid="igom-permid_0.4171466117622492" id="igom-1" xml:lang="en"><Section1Number>Chapter 1:</Section1Number><Section1Heading>PassengerHandlingProcedures</Section1Heading><Section2 permid="igom-permid_0.7857337828998681" id="igom-1-1.1"><Section2Number>1.1</Section2Number><Section2Heading>PassengerDeparture</Section2Heading><Section3 permid="igom-permid_0.6496767700095887" id="igom-1-1.1.1"><Section3Number>1.1.1</Section3Number><Section3Heading>Pre-DepartureActivities</Section3Heading><Section4 permid="igom-permid_0.6146238625670233" id="igom-1-1.1.1.1" rev="changed"><Section4Number>1.1.1.1</Section4Number><Section4Heading>TicketSalesCounter</Section4Heading></Section4><Section4 permid="igom-permid_0.6487040525387596" id="igom-1-1.1.1.2" rev="deleted"><Section4Number>1.1.1.2</Section4Number><Section4Heading>PassengerPre-FlightPreparation</Section4Heading></Section4></Section3></Section2></Section1></Chapter>';
		
		Document__c oldIgom = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = IGOMConstants.ROLES.IATA_PERSONNEL;
		update contactRole;
		Id contactId = contactRole.Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		
		Id igomId;
		Test.startTest();
		System.runAs(user){
			igomId = IGOMDocumentUtil.uploadIGOMDocument(xmlFile);
		}
		Test.stopTest();

		System.assertNotEquals(null, igomId);
		System.assertNotEquals(oldIgom.Id, igomId);
	}
	
	/**
	 * @description Test the uploadIGOMDocument method when the user has no permission.
	 */
	@isTest
	public static void uploadIGOMDocumentTest_NoPermission(){
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = IGOMConstants.ROLES.VIEWER;
		update contactRole;
		User user = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c LIMIT 1];
		
		String xmlFile = '<?xmlversion="1.0" encoding="utf-8"?><Chapter permid="igom-gap-1" id="igom-gap-1" edition="10" xml:lang="en"><Section1 permid="igom-permid_0.4171466117622492" id="igom-1" xml:lang="en"><Section1Number>Chapter 1:</Section1Number><Section1Heading>PassengerHandlingProcedures</Section1Heading><Section2 permid="igom-permid_0.7857337828998681" id="igom-1-1.1"><Section2Number>1.1</Section2Number><Section2Heading>PassengerDeparture</Section2Heading><Section3 permid="igom-permid_0.6496767700095887" id="igom-1-1.1.1"><Section3Number>1.1.1</Section3Number><Section3Heading>Pre-DepartureActivities</Section3Heading><Section4 permid="igom-permid_0.6146238625670233" id="igom-1-1.1.1.1" rev="changed"><Section4Number>1.1.1.1</Section4Number><Section4Heading>TicketSalesCounter</Section4Heading></Section4><Section4 permid="igom-permid_0.6487040525387596" id="igom-1-1.1.1.2" rev="deleted"><Section4Number>1.1.1.2</Section4Number><Section4Heading>PassengerPre-FlightPreparation</Section4Heading></Section4></Section3></Section2></Section1></Chapter>';
		Id igomId;
        Test.startTest();
		System.runAs(user){
			try {
				igomId = IGOMDocumentUtil.uploadIGOMDocument(xmlFile);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
        Test.stopTest();
	}

	
	/**
	 * @description Test the activateIGOMManual method.
	 */
	@isTest
	public static void activateIGOMManualTest_Success(){
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = IGOMConstants.ROLES.IATA_PERSONNEL;
		update contactRole;
		
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];

		Document__c newIgom = IGOMTestFactory.documentFactoryCreation(1, null, IGOM_NAME, 'English', IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM)[0];
		newIgom.Is_Active__c = false;
		insert newIgom;

		Date today = Date.today();
		Test.startTest();
		System.runAs(user){
			IGOMDocumentUtil.activateIGOMManual(newIgom.Id);
		}
        Test.stopTest();

		for(Document__c igom : [SELECT Id, Is_Active__c, Document_Name__c, Published_Date__c, Version__c
		FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM]){
			if(igom.Id == newIgom.Id){
				System.assertEquals(true, igom.Is_Active__c);
			}else{
				System.assertNotEquals(true, igom.Is_Active__c);
			}
		}
	}
		
	/**
	 * @description Test the activateIGOMManual method when the user has no permission.
	 */
	@isTest
	public static void activateIGOMManualTest_NoPermission(){
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = IGOMConstants.ROLES.VIEWER;
		update contactRole;
		User user = [SELECT Id FROM User LIMIT 1];
		
		Document__c igom = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];
		Date today = Date.today();
        Test.startTest();
		System.runAs(user){
			try {
				IGOMDocumentUtil.activateIGOMManual(igom.Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
        Test.stopTest();
	}
	
	/**
	 * @description Test the activateIGOMManual method when some error takes place during the igom update.
	 */
	@isTest
	public static void activateIGOMManualTest_ErrorInUpdate(){
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = IGOMConstants.ROLES.IATA_PERSONNEL;
		update contactRole;
		User user = [SELECT Id FROM User LIMIT 1];

		Document__c newIgom = IGOMTestFactory.documentFactoryCreation(1, null, IGOM_NAME, 'English', IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM)[0];
		newIgom.Is_Active__c = false;
		insert newIgom;

		Test.startTest();
		System.runAs(user){
			try {
				IGOMDocumentUtil.activateIGOMManual(newIgom.Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
			
		}
        Test.stopTest();
	}

	/**
	 * @description Test the getIGOMProcedures method.
	 */
	@isTest
	public static void getIGOMProceduresTest_Success(){
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Document__c manual = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];
		IGOMDocumentUtil.IGOMManual manualNew;
		Test.startTest();
		System.runAs(user){
			manualNew = IGOMDocumentUtil.getIGOMProcedures(manual.Id);
		}
        Test.stopTest();

		System.assertEquals(2, manualNew.chapters.size());
		System.assertEquals(2, manualNew.chapters.get(0).subprocedures.size());
		System.assertEquals('1.1', manualNew.chapters.get(0).subprocedures.get(0).index);
		System.assertEquals('1.2', manualNew.chapters.get(0).subprocedures.get(1).index);
	}
	
	/**
	 * @description Test the getIGOMProcedures method when the user does not have permission.
	 */
	@isTest
	public static void getIGOMProceduresTest_NoPermission(){
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = null;
		update contactRole;

		User user = [SELECT Id FROM User LIMIT 1];
		Document__c manual = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];
		IGOMDocumentUtil.IGOMManual manualNew;
		Test.startTest();
		System.runAs(user){
			try {
				manualNew = IGOMDocumentUtil.getIGOMProcedures(manual.Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
        Test.stopTest();
	}
	
	/**
	 * @description Test the getIGOMProcedures method when there are no igoms.
	 */
	@isTest
	public static void getIGOMProceduresTest_NoIGOMs(){
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = IGOMConstants.ROLES.VIEWER;
		update contactRole;
		User user = [SELECT Id FROM User LIMIT 1];
		Document__c manual = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];
		delete manual;
		IGOMDocumentUtil.IGOMManual manualNew;
		Test.startTest();
		System.runAs(user){
			try {
				manualNew = IGOMDocumentUtil.getIGOMProcedures(manual.Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
        Test.stopTest();
	}


	/**
	 * @description Test the getIGOMManuals method.
	 */
	@isTest
	public static void getIGOMManualsTest(){
		List<Document__c> docs = new List<Document__c>();

		Test.startTest();
		docs = IGOMDocumentUtil.getIGOMManuals();
		Test.stopTest();
		System.assert(!docs.isEmpty());
		System.assertEquals(1, docs.size());
	}

	
	/**
	 * @description Test the getDocumentReference method.
	 */
	@isTest
	public static void getDocumentReferenceTest_Success(){
		Document__c doc = [SELECT Abbreviated_Name__c, Edition__c, Version__c, Revision__c FROM Document__c LIMIT 1];
		String docReference = '';
		Test.startTest();
		docReference = IGOMDocumentUtil.getDocumentReference(doc);
		Test.stopTest();

		System.assertNotEquals('', docReference);
		System.assert(docReference.contains(doc.Abbreviated_Name__c));
		if (doc.Edition__c != null) {
			System.assert(docReference.contains(' Ed.' + doc.Edition__c));
		}
		if (doc.Revision__c != null) {
			System.assert(docReference.contains(' R.' + doc.Revision__c));
		}
		if (doc.Version__c != null) {
			System.assert(docReference.contains(' V.' + doc.Version__c));
		}
	}

	/**
	 * @description Test the getDocumentReference method when any of the fields is not queried.
	 */
	@isTest
	public static void getDocumentReferenceTest_SOQLFail(){
		Document__c doc = [SELECT Id FROM Document__c LIMIT 1];
		String docReference = '';
		Test.startTest();
		try {
			docReference = IGOMDocumentUtil.getDocumentReference(doc);
			System.assert(false, EXC_NOT_THROWN);
		} catch (SObjectException exc) {
			System.assert(true);
		} catch (Exception error) {
			System.assert(false, UNEXP_EXC_CAUGHT + error);
		}
		Test.stopTest();
	}

}