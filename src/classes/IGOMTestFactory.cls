/**
 * @description		Data creation class for test methods.
 */
@isTest
public class IGOMTestFactory {
	/**
	 * @description	Method to create User records in a factory
	 * @param		amount <Number of the wanted User records>
	 * @return		List<User> <List of the wanted users>
	 */
	public static List<User> userFactoryCreation(Integer amount){
		List<User> users = new List<User>();
		Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
		for (Integer i=0; i<amount; i++) {
			users.add(new User(
				Firstname = 'Test ' + randomInt,
				Lastname = 'Test ' + randomInt,
				Alias = String.valueof(randomInt),
				Email = 'test' + randomInt + '@user.com',
				IsActive = true,
				EmailEncodingKey = 'UTF-8',
				LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US',
				TimezoneSidKey = 'Asia/Dubai',
				Username = 'test' + randomInt + '@user.com',
				PortalRole = 'Manager',
				CommunityNickname = 'Test ' + randomInt,
				License_Cost_Center__c  = 'ISF005CH01'
			));
		}
		return users;
	}

	/**
	 * @description	Method to create Account records in a factory
	 * @param		amount <Number of the wanted Account records>
	 * @return		List<Account> <List of the wanted accounts>
	 */
	public static List<Account> accountFactoryCreation(Integer amount){
		List<Account> accounts = new List<Account>();
		for (Integer i=0; i<amount; i++) {
			accounts.add(new Account(Name = 'Test name ' + i));
		}
		return accounts;
	}

	/**
	 * @description	Method to create Contact records in a factory
	 * @param		amount <Number of the wanted Contact records>
	 * @param		accountId <Account to relate the contacts to>
	 * @return		List<Contact> <List of the wanted contacts>
	 */
	public static List<Contact> contactFactoryCreation(Integer amount, Id accountId){
		List<Contact> contacts = new List<Contact>();
		for (Integer i=0; i<amount; i++) {
			Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
			contacts.add(new Contact(
				FirstName = 'Test FirstName' + randomInt,
				LastName = 'Test LastName' + randomInt,
				Email = 'TestEmail' + randomInt + '@test.test',
				AccountId = accountId
			));
		}
		return contacts;
	}

	/**
	 * @description	Method to create Account_Role__c records in a factory.
	 * @param		amount <Number of the wanted Account_Role__c records>
	 * @param		accountId <Account to relate the account roles to>
	 * @return		List<Account_Role__c> <List of the wanted account roles>
	 */
	private static final Id defaultRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Default');
	public static List<Account_Role__c> accountRoleFactoryCreation(Integer amount, Id accountId){
		List<Account_Role__c> accRoles = new List<Account_Role__c>();
		for (Integer i=0; i<amount; i++) {
			accRoles.add(new Account_Role__c(
				RecordTypeId = defaultRecordTypeId,
				Account__c = accountId,
				Status__c = 'Active'
			));
		}
		return accRoles;
	}

	/**
	 * @description	Method to create an Account_Contact_Role__c record.
	 * @param		accountId <Account to relate the account contact role to>
	 * @param		contactId <Contact to relate the account contact role to>
	 * @param		accRole <Account_Role__c to relate the account contact role to>
	 * @return		Account_Contact_Role__c <New Account contact role>
	 */
	private static final Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
	public static Account_Contact_Role__c createAccountContactRole(Id accountId, Id contactId, Id accRole){
		return new Account_Contact_Role__c(
			RecordTypeId = functionalRecordTypeId,
			Account__c = accountId,
			Contact__c = contactId,
			Account_Role__c = accRole,
			Service_Rendered__c = IGOMConstants.GLOBALS.SERVICE_RENDERED_NAME,
			Functional_Role__c = IGOMConstants.GLOBALS.FUNCTIONAL_ROLE_SERVICE
		);
	}


	/**
	 * @description	Method to create an IGOM_Account_Role_Detail__c record.
	 * @param		accountRoleId <Account role to relate the station to>
	 * @param		type <Name of the record type of the station>
	 * @return		IGOM_Account_Role_Detail__c <New station>
	 */
	public static IGOM_Account_Role_Detail__c createIGOMAccountRoleDetail(Id accountRoleId, String type){
		if(type != null){
			Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('IGOM_Account_Role_Detail__c', type);
			return new IGOM_Account_Role_Detail__c(
				RecordTypeId = recordTypeId,
				Account_Role__c = accountRoleId
			);
		}
		return new IGOM_Account_Role_Detail__c(
			Account_Role__c = accountRoleId
		);
	}

	/**
	 * @description	Method to create an IGOM_Contact_Role_Detail__c record.
	 * @param		accountContactRoleId <Account contact role to relate the contact role to>
	 * @param		accountRoleDetailId <IGOM_Account_Role_Detail__c record (the station) to relate the contact role to>
	 * @param		role <Name of the role that wants to be set>
	 * @return		IGOM_Contact_Role_Detail__c <Created contact role detail>
	 */
	public static IGOM_Contact_Role_Detail__c createIGOMContactRoleDetail(Id accountContactRoleId, Id accountRoleDetailId, String role){	
		return new IGOM_Contact_Role_Detail__c(
			Account_Contact_Role__c = accountContactRoleId,
			Account_Role_Detail__c = accountRoleDetailId,
			Role__c = role
		);
	}

	/**
	 * @description	Method to create an IGOM_Contact_Role_Procedure_Compliance__c record.
	 * @param		contactRoleDetailId <IGOM Contact role detail to relate the notification to>
	 * @param		complianceReviewPartId <Compliance review part to relate the notification to>
	 * @return		IGOM_Contact_Role_Procedure_Compliance__c <Created notification>
	 */
	public static IGOM_Contact_Role_Procedure_Compliance__c createIGOMContactRoleProcedureCompliance(Id contactRoleDetailId, Id complianceReviewPartId){
		return new IGOM_Contact_Role_Procedure_Compliance__c(
			IGOM_Contact_Role_Detail__c	 = contactRoleDetailId,
			Compliance_Review_Part__c = complianceReviewPartId,
			Notification_Status__c = 'Unread'
		);
	}

	/**
	 * @description	Method to create an IGOM_Account_Role_Relationship__c record.
	 * @param		fromAccRoleId <Account role detail that represents the "from" side of the relationship>
	 * @param		toAccRoleId <Account role detail that represents the "to" side of the relationship>
	 * @param		requestedById <Account role detail that requests the relationship>
	 * @param		acceptsNotifs <Indicator of whether notifications are accepted on the "from" side of the relationship, whenever it's hierarchical>
	 * @param		type <The type of relationship, Group_relationship or Hierarchical_relationship>
	 * @param		status <Indicates the status of the relationship, Pending, Active or Inactive>
	 * @return		IGOM_Account_Role_Relationship__c <Created account role relationship>
	 */
	public static IGOM_Account_Role_Relationship__c createIGOMAccountRoleRelationship(Id fromAccRoleId, Id toAccRoleId, Id requestedById, Boolean acceptsNotifs, String type, String status){
		return new IGOM_Account_Role_Relationship__c(
			From__c = fromAccRoleId,
			To__c = toAccRoleId,
			Requested_By__c = requestedById,
			Accepts_Notifications__c = acceptsNotifs,
			Type__c = type,
			Status__c = status
		);
	}

	
	/**
	 * @description	Method to create Document__c records in a factory.
	 * @param		amount <Number of the wanted Document__c records>
	 * @param		stationId <IGOM Account role detail to relate the documents to>
	 * @param		title <Title of the document>
	 * @param		lang <Language of the document>
	 * @return		List<Document__c> <List of the created documents>
	 */
	public static List<Document__c> documentFactoryCreation(Integer amount, Id stationId, String title, String lang, String recordType){
		List<Document__c> documents = new List<Document__c>();
		Date today = Date.today();
		for (Integer i=0; i<amount; i++) {
			documents.add(new Document__c(
				RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Document__c', recordType),
				Abbreviated_Name__c = title.contains(' ') ? title.split(' ').get(0) : title.left(10),
				Document_Name__c = title,
				Type__c = 'Online',
				Edition__c = '1.' + i,
				Effective_Date__c = today.addDays(365),
				Is_Active__c = true,
				Published_Date__c = today,
				Review_Date__c = today.addDays(33),
				Revision__c = 'Test revision ' + i,
				Version__c = '0.' + i,
				Station__c = stationId,
				Language__c = lang
			));
		}
		return documents;
	}

	/**
	 * @description	Method to create a Document_Part__c record.
	 * @param		category <Category of the document part>
	 * @param		documentId <Document to relate the document part to>
	 * @param		index <Index of the document part>
	 * @param		name <Name of the document>
	 * @return		Document_Part__c <Created document part>
	 */
	public static Document_Part__c createDocumentPart(String category, Id documentId, Integer index, String name){
		return new Document_Part__c(
			Category__c = category,
			Document__c = documentId,
			Index__c = index,
			Name__c = name,
			Version_Change_Status__c = 'None',
			External_Reference_ID__c = name
		);
	}

	/**
	 * @description	Method to create a Compliance_Review__c record.
	 * @param		documentId <Document to relate the compliance review to>
	 * @param		stationId <Account role detail to relate the documents to>
	 * @return		Compliance_Review__c <Created compliance review>
	 */
	private static final Id igomComplianceRevRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Compliance_Review__c', IGOMConstants.COMPLIANCE_REVIEW.RECORD_TYPE.IGOM);
	public static Compliance_Review__c createComplianceReview(Id documentId, Id stationId, String title){
		Date today = Date.today();
		return new Compliance_Review__c(
			RecordTypeId = igomComplianceRevRecordTypeId,
			Document__c = documentId,
			Effective_Date__c = today,
			Station__c = stationId,
			Title__c = title,
			Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.DRAFT,
			Notification_Date__c = today.addDays(120)
		);
	}

	/**
	 * @description	Method to create a Compliance_Review_Part__c record.
	 * @param		complianceReviewId <Compliance review to relate the compliance review part to>
	 * @param		stDocumentPartId <Standard Document (IGOM) to relate the compliance review part to>
	 * @param		relatedDocumentId <Document (GOM) used to comply the document part related to the compliance review part>
	 * @return		Compliance_Review_Part__c <Created compliance review>
	 */
	public static Compliance_Review_Part__c createComplianceReviewPart(Id complianceReviewId, Id stDocumentPartId, Id relatedDocumentId){
		return new Compliance_Review_Part__c(
			Compliance_Review__c = complianceReviewId,
			Standard_Document_Part__c = stDocumentPartId,
			Status__c = 'Conforms',
			Document__c = relatedDocumentId,
			User_Provision_Procedure__c = 'Test provision procedure text'
		);
	}


	/**
	 * @description	Method to generate all the data necessary to create a user for the IGOM proyect
	 * @param		roleType <The type of role wanted for the user>
	 * @param		stationType <The type of station to create>
	 * @return		List<sObject> <All the created records>
	 */
	public static List<sObject> generateIGOMUser(String roleType, String stationType){
		return generateIGOMUserFactory(1, roleType, stationType).get(0);
	}

	/**
	 * @description	Method to generate one of each necesary record to create an account x number of times.
	 * @param		amount <The number of different users, with different contacts, in different accounts, etc. to create>
	 * @param		roleType <The type of role wanted for the user>
	 * @param		roleType <The type of role wanted for the user>
	 * @return		List<List<sObject>> <All the created records>
	 */
	public static List<List<sObject>> generateIGOMUserFactory(Integer amount, String roleType, String stationType){
		List<List<sObject>> objectListList = new List<List<sObject>>();
		// Create a map that will contain every record per it's id
		Map<Id, sObject> objectPerId = new Map<Id, sObject>();

		List<Account> accs = accountFactoryCreation(amount);
		insert accs;

		// Create contacts and account roles
		List<Contact> cons = new List<Contact>();
		List<Account_Role__c> accRoles = new List<Account_Role__c>();
		for (Account acc : accs) {
			cons.add(contactFactoryCreation(1, acc.Id).get(0));
			Account_Role__c ar = accountRoleFactoryCreation(1, acc.Id).get(0);
			ar.Account_Name__c = acc.Name;
			accRoles.add(ar);
		}
		insert cons;
		insert accRoles;

		Map<Id, Id> contactPerAccount = new Map<Id, Id>();
		for(Contact c : cons){
			contactPerAccount.put(c.AccountId, c.Id);
			objectPerId.put(c.Id, c);
		}

		Map<Id, Id> accRolePerAccount = new Map<Id, Id>();
		for(Account_Role__c ar : accRoles){
			accRolePerAccount.put(ar.Account__c, ar.Id);
			objectPerId.put(ar.Id, ar);
		}

		// Create account contact roles
		List<Account_Contact_Role__c> accConRoles = new List<Account_Contact_Role__c>();
		for (Account acc : accs) {
			accConRoles.add(createAccountContactRole(acc.Id, contactPerAccount.get(acc.Id), accRolePerAccount.get(acc.Id)));
		}
		insert accConRoles;

		Map<Id, Id> accConRolePerAccount = new Map<Id, Id>();
		for (Account_Contact_Role__c accConRole : accConRoles) {
			accConRolePerAccount.put(accConRole.Account__c, accConRole.Id);
			objectPerId.put(accConRole.Id, accConRole);
		}

		// Create account role details
		List<IGOM_Account_Role_Detail__c> accRoleDetails = new List<IGOM_Account_Role_Detail__c>();
		for (Account acc : accs) {
			accRoleDetails.add(createIGOMAccountRoleDetail(accRolePerAccount.get(acc.Id), stationType));
		}
		insert accRoleDetails;

		Map<Id, Id> accRoleDetailPerAccountRole = new Map<Id, Id>();
		for (IGOM_Account_Role_Detail__c accRoleDetail : accRoleDetails) {
			accRoleDetailPerAccountRole.put(accRoleDetail.Account_Role__c, accRoleDetail.Id);
			objectPerId.put(accRoleDetail.Id, accRoleDetail);
		}

		// Create Contact role details
		List<IGOM_Contact_Role_Detail__c> conRoleDetails = new List<IGOM_Contact_Role_Detail__c>();
		for (Account acc : accs) {
			Id accRoleId = accRolePerAccount.get(acc.Id);
			conRoleDetails.add(createIGOMContactRoleDetail(accConRolePerAccount.get(acc.Id), accRoleDetailPerAccountRole.get(accRoleId), roleType));
		}
		insert conRoleDetails;

		Map<Id, Id> conRoleDetailPerAccountRoleDetail = new Map<Id, Id>();
		for (IGOM_Contact_Role_Detail__c conRoleDetail : conRoleDetails) {
			// Use the account role detail because this record is not related to an account
			conRoleDetailPerAccountRoleDetail.put(conRoleDetail.Account_Role_Detail__c, conRoleDetail.Id);
			objectPerId.put(conRoleDetail.Id, conRoleDetail);
		}
		
		// Create Users
		Id profileId = [SELECT Id FROM Profile WHERE Name = :IGOMConstants.GLOBALS.COMMUNITY_PROFILE LIMIT 1].Id;
		
		List<User> users = new List<User>();
		for (Contact c : cons) {
			User u = userFactoryCreation(1).get(0);
			u.ContactId = c.Id;
			u.ProfileId = profileId;
			users.add(u);
		}
		insert users;

		Map<Id, Id> userPerContact = new Map<Id, Id>();
		for (User u : users) {
			userPerContact.put(u.ContactId, u.Id);
			objectPerId.put(u.Id, u);
		}

		// Add all objects to a list for each of the accounts created
		for (Account acc : accs) {
			Id conId = contactPerAccount.get(acc.Id);
			Id accRoleId = accRolePerAccount.get(acc.Id);
			Id accRoleDetailId = accRoleDetailPerAccountRole.get(accRoleId);
			objectListList.add(new List<SObject>{
				acc,
				objectPerId.get(conId),
				objectPerId.get(userPerContact.get(conId)),
				objectPerId.get(accRoleId),
				objectPerId.get(accConRolePerAccount.get(acc.Id)),
				objectPerId.get(accRoleDetailId),
				objectPerId.get(conRoleDetailPerAccountRoleDetail.get(accRoleDetailId))
			});
		}
		return objectListList;
	}


	public static List<Compliance_Review_Part__c> createExampleComplianceReviewData(){
		// Generate stations
		List<List<SObject>> objectsStations = IGOMTestFactory.generateIGOMUserFactory(3, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ);
		List<SObject> objectsStation1 = objectsStations.get(0);
		List<SObject> objectsStation2 = objectsStations.get(1);
		IGOM_Account_Role_Detail__c station1 = (IGOM_Account_Role_Detail__c) objectsStation1.get(5);
		IGOM_Account_Role_Detail__c station2 = (IGOM_Account_Role_Detail__c) objectsStation2.get(5);
		IGOM_Contact_Role_Detail__c contactRoleDetail1 = (IGOM_Contact_Role_Detail__c) objectsStation1.get(6);
		IGOM_Contact_Role_Detail__c contactRoleDetail2 = (IGOM_Contact_Role_Detail__c) objectsStation2.get(6);
		// Generate an IGOM and a GOM
		List<Document__c> documents = new List<Document__c>();
		Document__c igomDocument = IGOMTestFactory.documentFactoryCreation(1, null, 'IGOM Document', 'English', IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM)[0];
		documents.add(igomDocument);
		Document__c gomDocument = IGOMTestFactory.documentFactoryCreation(1, null, 'GOM Document', 'English', IGOMConstants.DOCUMENT.RECORD_TYPE.GOM)[0];
		documents.add(gomDocument);
		insert documents;
		// Generate IGOM parts
		List<Document_Part__c> documentParts = new List<Document_Part__c>();
		Document_Part__c chapter1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.PART, igomDocument.Id, 1, 'Part 1');
		documentParts.add(chapter1);
		Document_Part__c chapter2 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.PART, igomDocument.Id, 2, 'Part 2');
		documentParts.add(chapter2);
		Document_Part__c section1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.CHAPTER, igomDocument.Id, 1, 'Chapter 1');
		documentParts.add(section1);
		Document_Part__c section2 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.CHAPTER, igomDocument.Id, 1, 'Chapter 2');
		documentParts.add(section2);
		Document_Part__c subchapter1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION, igomDocument.Id, 1, 'Section 1 Procedure 1');
		documentParts.add(subchapter1);
		Document_Part__c subchapter2 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION, igomDocument.Id, 1, 'Section 1 Procedure 2');
		documentParts.add(subchapter2);
		Document_Part__c subchapter3 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION, igomDocument.Id, 1, 'Section 2 Procedure 1');
		documentParts.add(subchapter3);
		insert documentParts;
		subchapter3.Parent__c = section2.Id;
		subchapter2.Parent__c = section1.Id;
		subchapter1.Parent__c = section1.Id;
		section2.Parent__c = chapter1.Id;
		section1.Parent__c = chapter1.Id;
		update documentParts;
		// Generate compliance reviews
		List<Compliance_Review__c> complianceReviews = new List<Compliance_Review__c>();
		Compliance_Review__c complianceReview1 = IGOMTestFactory.createComplianceReview(igomDocument.Id, station1.Account_Role__c, 'Compliance Review 1');
		Compliance_Review__c complianceReview2 = IGOMTestFactory.createComplianceReview(igomDocument.Id, station1.Account_Role__c, 'Compliance Review 2');
		Compliance_Review__c complianceReview3 = IGOMTestFactory.createComplianceReview(igomDocument.Id, station2.Account_Role__c, 'Compliance Review 3');
		Compliance_Review__c complianceReview4 = IGOMTestFactory.createComplianceReview(igomDocument.Id, station2.Account_Role__c, 'Compliance Review 4');
		Compliance_Review__c complianceReview5 = IGOMTestFactory.createComplianceReview(igomDocument.Id, station2.Account_Role__c, 'Compliance Review 5');
		complianceReview1.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.DRAFT;
		complianceReview2.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED;
		complianceReview3.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED;
		complianceReview4.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.TEMPLATE;
		complianceReview5.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED;
		complianceReview2.Is_Latest_Published__c = true;
		complianceReview3.Is_Latest_Published__c = true;
		complianceReview4.Is_Latest_Published__c = true;
		complianceReview5.Is_Latest_Published__c = false;
		complianceReview5.Effective_Date__c = Date.today().addDays(1);
		complianceReviews.addAll(new List<Compliance_Review__c>{ complianceReview1, complianceReview2, complianceReview3, complianceReview4, complianceReview5 });
		insert complianceReviews;
		// Generate some compliance review parts
		List<Compliance_Review_Part__c> complianceReviewParts = new List<Compliance_Review_Part__c>();
		for (Integer complianceIndex = 0; complianceIndex <= 3; complianceIndex++) {
			Id complianceReviewId = complianceReviews.get(complianceIndex).Id;
			Compliance_Review_Part__c complianceReviewPart1 = IGOMTestFactory.createComplianceReviewPart(complianceReviewId, subchapter1.Id, gomDocument.Id);
			complianceReviewPart1.Status__c = IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION;
			complianceReviewPart1.Variation_Comments__c = 'Varies 1';
			complianceReviewParts.add(complianceReviewPart1);
			Compliance_Review_Part__c complianceReviewPart2 = IGOMTestFactory.createComplianceReviewPart(complianceReviewId, subchapter2.Id, gomDocument.Id);
			complianceReviewParts.add(complianceReviewPart2);
			Compliance_Review_Part__c complianceReviewPart3 = IGOMTestFactory.createComplianceReviewPart(complianceReviewId, subchapter3.Id, gomDocument.Id);
			complianceReviewPart3.Status__c = IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION;
			complianceReviewPart3.Variation_Comments__c = 'Varies 2';
			complianceReviewPart3.Variation_Alternative__c = 'Varia 2';
			complianceReviewPart3.Comment_Language__c = 'Spanish';
			complianceReviewParts.add(complianceReviewPart3);
			if (complianceIndex == 1) {
				complianceReviewPart1.Is_Reviewed__c = true;
			} else if (complianceIndex == 2) {
				complianceReviewPart1.Is_Reviewed__c = true;
				complianceReviewPart2.Is_Reviewed__c = true;
				complianceReviewPart3.Is_Reviewed__c = true;
				complianceReviewPart3.Status__c = IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.CONFORMITY;
			}
		}
		Compliance_Review_Part__c complianceReviewPart4 = IGOMTestFactory.createComplianceReviewPart(complianceReviews.get(4).Id, chapter2.Id, gomDocument.Id);
		complianceReviewPart4.Is_Reviewed__c = true;
		complianceReviewParts.add(complianceReviewPart4);
		insert complianceReviewParts;

		return complianceReviewParts;
	}
}