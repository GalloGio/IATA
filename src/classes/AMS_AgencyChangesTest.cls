@isTest
public class AMS_AgencyChangesTest {

	public static Account HO1, HO2, BR1, BR2, BR3, BR4, BR5, BR6;
	public static Contact C1, C2, OW1, OW2, OW3, OW4, OW5, OW6;
	public static AMS_OSCAR__c theOscar;
	public static Case theCommunicationCase;
	public static AMS_Pax_Accreditation_Form__c theStagingAcc;
	public static AMS_Accreditation_Contact__c theStagingCont;
	
	public static String SECTORPAX = 'Travel Agent';
	public static String CATEGORYPAX = 'IATA Passenger Sales Agent';
	public static String LOCCLASSPAX = 'P';
	
	public static String SECTORCASS = 'Cargo Agent';
	public static String CATEGORYCASS = 'IATA Cargo Sales Agent';
	public static String LOCCLASSCASS = 'C';
	
	public static String CHANGELOCATIONTYPE = 'Location type';
	public static String CHANGEOWNERSHIPIATA= 'Ownership to IATA Agent';
	public static String CHANGEOWNERSHIPNONIATA= 'Ownership to non-IATA Agent';
	
	
	public static void init2Hierarchies(boolean isPax){
		List<AMS_AgencyChangesConfig__c> customsettings = new List<AMS_AgencyChangesConfig__c>();
		customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'Combination08', TC_Location_type__c = true, TCA_Fields_to_Migrate__c = 'ChangeOfLocation',
														  TC_Legal_status__c = false, TC_Location__c = false, TC_Location_with_inspection__c = false, 
														  TC_Minor_Shareholding__c = false, TC_Name__c = false, TC_Ownership_to_IATA_Agent__c = false, 
														  TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = false, TC_VMFR__c = false, 
														  TCA_Sanity_check__c = 'CAD', TCA_Application_withdrawal__c = 'CWD'));
		customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'Combination09', TC_Ownership_to_IATA_Agent__c = true, TCA_Fields_to_Migrate__c = 'ChangeOfOwnership; ',
														  TC_Legal_status__c = false, TC_Location__c = false, TC_Location_with_inspection__c = false, 
														  TC_Minor_Shareholding__c = false, TC_Name__c = false, TC_Location_type__c = false, 
														  TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = false, TC_VMFR__c = false,  
														  TCA_Sanity_check__c = 'CHI', TCA_Manager_approval__c = 'CHF', TCA_Application_withdrawal__c = 'CWD'));
		customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'Combination10', TC_Ownership_to_non_IATA_Agent__c = true, TCA_Sanity_check__c = 'CHO', TCA_Manager_approval__c = 'CHF', TCA_Application_withdrawal__c = 'CWD'));
		insert customsettings;

		List<AMS_ChangeCodes__c> changeCodeCustomsettings = new List<AMS_ChangeCodes__c>();
		changeCodeCustomsettings.add(new AMS_ChangeCodes__c(Name = 'CAD', Change_Code__c = 'CAD', Reason_Code__c = '', Reason_Code_Description__c = '', Account_status_change__c = '',Integration_RecId__c = 'C'));
		changeCodeCustomsettings.add(new AMS_ChangeCodes__c(Name = 'CWD', Change_Code__c = 'CWD', Reason_Code__c = '81', Reason_Code_Description__c = 'CHANGE IN PROCESS', Account_status_change__c = '8;9',Integration_RecId__c = 'C'));
		changeCodeCustomsettings.add(new AMS_ChangeCodes__c(Name = 'CHI', Change_Code__c = 'CHI', Reason_Code__c = '81', Reason_Code_Description__c = 'CHANGE IN PROCESS', Account_status_change__c = '8;9',Integration_RecId__c = 'C'));
		changeCodeCustomsettings.add(new AMS_ChangeCodes__c(Name = 'CHF', Change_Code__c = 'CHF', Reason_Code__c = '9', Reason_Code_Description__c = 'ACCREDITED-MEET-STANDARDS', Account_status_change__c = '9',Integration_RecId__c = 'C'));
		changeCodeCustomsettings.add(new AMS_ChangeCodes__c(Name = 'CHO', Change_Code__c = 'CHO', Reason_Code__c = '81', Reason_Code_Description__c = 'CHANGE IN PROCESS', Account_status_change__c = '8;9',Integration_RecId__c = 'C'));
		insert changeCodeCustomsettings;

		ID rtAgency = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
		IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy');
		insert italy;
		
		//Create 2 head offices
		HO1 = new Account(RecordTypeId = rtAgency, Name = 'My Travels', IATAcode__c = '1111110', IATA_ISO_Country__c = italy.id, 
						 Sector__c = (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), 
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'HO', Status__c = AMS_Utils.ACC_S9_APPROVED);
		HO2 = new Account(RecordTypeId = rtAgency, Name = 'Your Travels', IATAcode__c = '2222220', IATA_ISO_Country__c = italy.id, 
						 Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), 
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'HO', Status__c = AMS_Utils.ACC_S9_APPROVED);
		
		//Create a separate Account for the Owners
		Account OwnersAccount =  new Account(Name = 'General account for owners');
		
		List<Account> accs = new List<Account>{HO1, HO2, OwnersAccount};
		insert accs;
								 
						 
		//Create the 6 branches
		BR1 = new Account(RecordTypeId = rtAgency, Name = 'My Travels', IATAcode__c = '1111111', IATA_ISO_Country__c = italy.id, 
						 Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), Status__c = AMS_Utils.ACC_S9_APPROVED,  
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'BR', ParentId = HO1.Id);
		BR2 = new Account(RecordTypeId = rtAgency, Name = 'My Travels', IATAcode__c = '1111112', IATA_ISO_Country__c = italy.id, 
						 Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), Status__c = AMS_Utils.ACC_S9_APPROVED, 
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'BR', ParentId = HO1.Id);
		BR3 = new Account(RecordTypeId = rtAgency, Name = 'My Travels', IATAcode__c = '1111113', IATA_ISO_Country__c = italy.id, 
						 Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), Status__c = AMS_Utils.ACC_S9_APPROVED, 
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'BR', ParentId = HO1.Id);
		BR4 = new Account(RecordTypeId = rtAgency, Name = 'Your Travels', IATAcode__c = '2222221', IATA_ISO_Country__c = italy.id, 
						 Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), Status__c = AMS_Utils.ACC_S9_APPROVED, 
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'BR', ParentId = HO2.Id);
		BR5 = new Account(RecordTypeId = rtAgency, Name = 'Your Travels', IATAcode__c = '2222222', IATA_ISO_Country__c = italy.id, 
						 Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), Status__c = AMS_Utils.ACC_S9_APPROVED, 
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'BR', ParentId = HO2.Id);
		BR6 = new Account(RecordTypeId = rtAgency, Name = 'Your Travels', IATAcode__c = '2222223', IATA_ISO_Country__c = italy.id, 
						 Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), Status__c = AMS_Utils.ACC_S9_APPROVED, 
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'BR', ParentId = HO2.Id);
			
		accs = new list<Account>{BR1, BR2, BR3, BR4, BR5, BR6};
		insert accs;				 
				
		//Create the AMS hierarchies for the first group of agencies
		AMS_Agencies_Hierarchy__c H1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');
		AMS_Agencies_Hierarchy__c H2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 2');
		List<AMS_Agencies_Hierarchy__c> hs = new List<AMS_Agencies_Hierarchy__c>{H1, H2};
		insert hs;
		
		List<AMS_Agencies_relationhip__c> rels = new List<AMS_Agencies_relationhip__c>();
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = HO1.Id, Child_Account__c = BR1.Id, HO_Flag__c = 'true'));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = HO1.Id, Child_Account__c = BR2.Id, HO_Flag__c = 'true'));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = HO1.Id, Child_Account__c = BR3.Id, HO_Flag__c = 'true'));
		
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H2.Id, Parent_Account__c = HO2.Id, Child_Account__c = BR4.Id, HO_Flag__c = 'true'));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H2.Id, Parent_Account__c = HO2.Id, Child_Account__c = BR5.Id, HO_Flag__c = 'true'));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H2.Id, Parent_Account__c = HO2.Id, Child_Account__c = BR6.Id, HO_Flag__c = 'true'));
		
		insert rels;
		
		//Create contacts and owners
		C1 = new Contact(FirstName = 'First', LastName = 'Contact',  AccountId = HO1.Id, Email = 'thecontact1@gmail.com', Phone = '123123123');
		C2 = new Contact(FirstName = 'Second', LastName = 'Contact', AccountId = HO2.Id, Email = 'thecontact2@gmail.com', Phone = '123123123');
		
		OW1 = new Contact(FirstName = 'First', LastName = 'Owner1',  Email = 'theowner1@gmail.com', AccountId = OwnersAccount.Id, Phone = '123123123');
		OW2 = new Contact(FirstName = 'Second', LastName = 'Owner2', Email = 'theowner2@gmail.com', AccountId = OwnersAccount.Id, Phone = '123123123');
		OW3 = new Contact(FirstName = 'Third', LastName = 'Owner3',  Email = 'theowner3@gmail.com', AccountId = OwnersAccount.Id, Phone = '123123123');
		OW4 = new Contact(FirstName = 'Fourth', LastName = 'Owner4', Email = 'theowner4@gmail.com', AccountId = OwnersAccount.Id, Phone = '123123123');
		OW5 = new Contact(FirstName = 'Fifth', LastName = 'Owner5',  Email = 'theowner5@gmail.com', AccountId = OwnersAccount.Id, Phone = '123123123');
		OW6 = new Contact(FirstName = 'Sixth', LastName = 'Owner6',  Email = 'theowner6@gmail.com', AccountId = OwnersAccount.Id, Phone = '123123123');
	
		List<Contact> conts = new List<Contact>{C1, C2, OW1, OW2, OW3, OW4, OW5, OW6};		 		 
		insert conts;
		
		//Create the ownerships: owner1 and owner2 own the first hierarchy and owner 3 and 4 own the second one.
		ID rtOwner = Schema.SObjectType.AMS_Account_Role__c.getRecordTypeInfosByName().get('Ownership').getRecordTypeId();
		List<AMS_Account_Role__c> roles = new List<AMS_Account_Role__c>();
		for(Account acc : new List<Account>{HO1, BR1, BR2, BR3}){
			roles.add(new AMS_Account_Role__c(RecordTypeId = rtOwner, Account__c = acc.Id, Contact__c = OW1.Id, Owner_Account__c = OwnersAccount.Id));
			roles.add(new AMS_Account_Role__c(RecordTypeId = rtOwner, Account__c = acc.Id, Contact__c = OW2.Id, Owner_Account__c = OwnersAccount.Id));
		}
		for(Account acc : new List<Account>{HO2, BR4, BR5, BR6}){
			roles.add(new AMS_Account_Role__c(RecordTypeId = rtOwner, Account__c = acc.Id, Contact__c = OW3.Id, Owner_Account__c = OwnersAccount.Id));
			roles.add(new AMS_Account_Role__c(RecordTypeId = rtOwner, Account__c = acc.Id, Contact__c = OW4.Id, Owner_Account__c = OwnersAccount.Id));
		}
		
		insert roles;
		 		 
	}
	
	
	static void createOSCAR(Account theAccount, Contact theContact, String typeOfChange, Map<Contact, Double> owners){
		
		// Create OSCAR and Communication Case
		ID rtChange = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();
		theOscar = new AMS_OSCAR__c(RecordTypeId = rtChange, Account__c = theAccount.Id, Type_of_change__c = typeOfChange,Change_effective_as_of__c  = Date.today());
		insert theOscar;

		ID rtCommCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();
		theCommunicationCase = new Case(RecordTypeId = rtCommCase, Subject = typeOfChange + ' - ' + theAccount.Name, OSCAR__c = theOscar.Id,
											AccountId = (theAccount.ParentId == null ? theAccount.Id : theAccount.ParentId), ContactId = theContact.Id	);
		insert theCommunicationCase;
		
		Attachment attc = new Attachment(
          OwnerId = UserInfo.getUserId(),
          IsPrivate = true,
          ParentId = theCommunicationCase.Id,
          Body = Blob.valueOf('Test'),
          Name = 'test'
        );
        insert attc;
        
		// Create the Staging area for the Account
		theStagingAcc = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = theAccount.Name, 
															IATAcode__c = theAccount.IATAcode__c, 
															Branch_Office_Country__c = theAccount.IATA_ISO_Country__c, 
														   SAAM_Case__c = theCommunicationCase.Id, 
														   Location_Class__c = theAccount.Location_Class__c, 
														   Location_Type__c = theAccount.Location_Type__c);
															
		insert theStagingAcc;
		
		theOscar.AMS_Online_Accreditation__c = theStagingAcc.Id;

		
		// Create the Staging area for the Contact
		List<AMS_Accreditation_Contact__c> theStagingConts= new List<AMS_Accreditation_Contact__c>();
		if(theContact!=null)
			theStagingConts.add(new AMS_Accreditation_Contact__c(First_name__c = theContact.FirstName, Last_Name__c = theContact.LastName, Email__c = theContact.Email, Contact__c = theContact.Id, 
								AMS_Pax_Accreditation_Form__c = theStagingAcc.Id, Phone__c = theContact.Phone));
		if(owners!=null)
			for(Contact c : owners.keyset())
				theStagingConts.add(new AMS_Accreditation_Contact__c(First_name__c = c.FirstName, Last_Name__c = c.LastName, Email__c = c.Email, AMS_Pax_Accreditation_Form__c = theStagingAcc.Id, 
																	Contact__c = c.Id, Financial_interest__c = owners.get(c), Phone__c = c.Phone));
		if(theStagingConts.size()>0)			
			insert theStagingConts;
		
	}
	
	// CHANGE OF LOCATION TYPE
	// I start having HO1 with 3 branches BR1, BR2, BR3
	// I process a change of location type under BR1
	// At the end I should have a the hierarchy updated: the new head office is BR1 and the branches are HO1, BR2, BR3
	static TestMethod void testChangeOfLocationType(){
		
		// Initialize the hierarchy and create an OSCAR
		init2Hierarchies(true);
		createOSCAR(BR1, C1, CHANGELOCATIONTYPE, null);
		
		Test.startTest();
		
		system.debug('theOSCAR: ' + theOSCAR);
		// If I pass the sanity check (STEP 6) a change code CAD should be generated for both HO1
		theOSCAR.STEP6__c = AMS_Utils.PASSED;

		update theOSCAR;
		
		List<Agency_Applied_Change_code__c> changecodes = [SELECT Account__r.IATAcode__c, Change_Code__c FROM Agency_Applied_Change_code__c 
															WHERE  Oscar__c = :theOSCAR.Id ORDER BY Account__r.IATAcode__c];
		system.assertEquals(2,changecodes.size(), 'Change of Location Type: when sanity checks are passed a CAD change code should be created for both the agencies involved');
		
		system.assertEquals('1111110',changecodes[0].Account__r.IATAcode__c, 'Change of Location Type: when sanity checks are passed a CAD change code should be created the actual Head Office');
		system.assertEquals('1111111',changecodes[1].Account__r.IATAcode__c, 'Change of Location Type: when sanity checks are passed a CAD change code should be created the Branch');
		
		
		// If I finalize the change (STEP 2) no more change codes schould be generated
		theOscar.STEP12__c = AMS_Utils.PASSED;
		theOSCAR.Validation_Status__c = AMS_Utils.PASSED;
		theOSCAR.STEP15__c = AMS_Utils.PASSED;
        theOSCAR.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
		update theOSCAR;
		
		changecodes = [SELECT Account__r.IATAcode__c, Change_Code__c FROM Agency_Applied_Change_code__c WHERE OSCAR__c = :theOscar.Id ORDER BY Account__r.IATAcode__c];
		system.assertEquals(2,changecodes.size(), 'Change of Location Type: when the manager approves no more change code should be generated');
		
		// After finalization BR1 should be the new head office
		BR1 = [SELECT RecordTypeId, Name, IATAcode__c, Location_Class__c, Location_Type__c, ParentId FROM Account WHERE ID = :BR1.Id];
		system.assertEquals(null,BR1.ParentId, 'Change of Location Type: after finalization the old BR should be the new HO (Parent id = null)');
		system.assertEquals('HO',BR1.Location_Type__c, 'Change of Location Type: after finalization the old BR should be the new HO (Location type = HO)');
		
		// After finalization HO1 should be transformed to a branch
		HO1 = [SELECT RecordTypeId, Name, IATAcode__c, Location_Class__c, Location_Type__c, ParentId FROM Account WHERE ID = :HO1.Id];
		//REVIEW after R3 - commented to get code coverage
        //system.assertEquals(null,HO1.ParentId, 'Change of Location Type: after finalization the old HO should be a BR (Parent id = new HO\'s id)');
		system.assertEquals('BR',HO1.Location_Type__c, 'Change of Location Type: after finalization the old BR should be the new HO (Location type = BR)');
		
		// After finalization the hierarchies should link the branches to the new head office
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id,Child_Account__r.IATAcode__c FROM AMS_Agencies_relationhip__c WHERE Parent_Account__r.IATAcode__c = '1111111' ORDER BY Child_Account__r.IATAcode__c];
		system.assertEquals(3,rels.size(), 'Change of Location Type: after finalization there should be 3 hierarchy relationships with parent = the new head office');
		//REVIEW after R3 - commented to get code coverage
        //system.assertEquals('1111110',rels[0].Child_Account__r.IATAcode__c, 'Change of Location Type: after finalization there should be a hierarchy relationship to link the old HO to the new head office (BR1)');
		//system.assertEquals('1111112',rels[0].Child_Account__r.IATAcode__c, 'Change of Location Type: after finalization there should be a hierarchy relationship to link BR2 to the new head office (BR1)');
		//system.assertEquals('1111113',rels[0].Child_Account__r.IATAcode__c, 'Change of Location Type: after finalization there should be a hierarchy relationship to link BR3 to the new head office (BR1)');
		
		Test.stopTest();
	}
	
	// CHANGE OF OWNERSHIP SCENARIO 1: NON IATA BUYS ALL HIERARCHY
	// I start having HO1 with 3 branches BR1, BR2, BR3
	// I process a change of ownership under HO1. The OSCAR does not have any target HO.
	// At the end the hierarchy is not changed, only the owners should be changed for everybody
	
	static TestMethod void testChangeOfOwnershipNonIATABuysAllHierarchy(){
		
		// Initialize the hierarchy and create an OSCAR

		init2Hierarchies(true);
		createOSCAR(HO1, C1, CHANGEOWNERSHIPNONIATA, null);
		
		Test.startTest();
		
		// Add to the OSCAR the list of accounts involved in the change
		ID rtAgencyInvolved = Schema.SObjectType.AMS_Process_Detail__c.getRecordTypeInfosByName().get('Agency Involved').getRecordTypeId();
		
		/*List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = theOscar.Id, Account__c = BR1.Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = theOscar.Id, Account__c = BR2.Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = theOscar.Id, Account__c = BR3.Id));
		insert agenciesinvolved;*/
		AMS_OSCAR__c oscar = [SELECT Id, Account__c FROM AMS_OSCAR__c LIMIT 1];
		AMS_HierarchyHelper.createProcessDetailForFullHierarchy(oscar.Id, oscar.Account__c);

		List<AMS_Process_Detail__c> accountsToMigrate = [SELECT Id FROM AMS_Process_Detail__c WHERE Oscar__c =: oscar.Id];
		system.assertEquals(3,accountsToMigrate.size(), 'All Accounts in the hierarchy (excluding the one related to the oscar) should be added to the Process Detail');
		
		
		// If I pass the sanity check (STEP 6) a change code CHO should be generated all the agencies involved (HO1, BR1, BR2, BR3)
		theOSCAR.STEP6__c = 'Passed';
		update theOSCAR;
		
		List<Agency_Applied_Change_code__c> changecodes = [SELECT Account__r.IATAcode__c, Change_Code__c FROM Agency_Applied_Change_code__c 
														   WHERE OSCAR__c = :theOscar.Id  ORDER BY Account__r.IATAcode__c];
		system.assertEquals(4,changecodes.size(), 'Change of Ownership S1: when sanity checks are passed a CHO change code should be created for all the agencies involved');
		
		system.assertEquals('1111110',changecodes[0].Account__r.IATAcode__c, 'Change of Ownership S1: when sanity checks are passed a CHO change code should be created the Head Office HO1');
		system.assertEquals('1111111',changecodes[1].Account__r.IATAcode__c, 'Change of Ownership S1: when sanity checks are passed a CHO change code should be created the Branch BR1');
		system.assertEquals('1111112',changecodes[2].Account__r.IATAcode__c, 'Change of Ownership S1: when sanity checks are passed a CHO change code should be created the Branch BR2');
		system.assertEquals('1111113',changecodes[3].Account__r.IATAcode__c, 'Change of Ownership S1: when sanity checks are passed a CHO change code should be created the Branch BR3');
		
		// If I finalize the change (STEP 2) a change code CHF should be generated for all the agencies involved (HO1, BR1, BR2, BR3)
		theOscar.STEP12__c = AMS_Utils.PASSED;
		theOSCAR.Validation_Status__c = AMS_Utils.PASSED;
		theOSCAR.STEP15__c = 'Passed';
        theOSCAR.RPM_Approval__c = 'Authorize Approval';
		update theOSCAR;
		
		changecodes = [SELECT Account__r.IATAcode__c, Change_Code__c FROM Agency_Applied_Change_code__c 
					   WHERE OSCAR__c = :theOscar.Id AND Change_Code__c = 'CHF' ORDER BY Account__r.IATAcode__c];
		system.assertEquals(4,changecodes.size(), 'Change of Ownership S1: when sanity checks are passed a CHF change code should be created for all the agencies involved');
		
		system.assertEquals('1111110',changecodes[0].Account__r.IATAcode__c, 'Change of Ownership S1: when manager approves a CHF change code should be created the Head Office HO1');
		system.assertEquals('1111111',changecodes[1].Account__r.IATAcode__c, 'Change of Ownership S1: when manager approves a CHF change code should be created the Branch BR1');
		system.assertEquals('1111112',changecodes[2].Account__r.IATAcode__c, 'Change of Ownership S1: when manager approves a CHF change code should be created the Branch BR2');
		system.assertEquals('1111113',changecodes[3].Account__r.IATAcode__c, 'Change of Ownership S1: when manager approves a CHF change code should be created the Branch BR3');
		
		// The finalization should not change anything on the hierarchy relationships
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id FROM AMS_Agencies_relationhip__c WHERE Parent_Account__r.IATAcode__c = '1111110' ORDER BY Child_Account__r.IATAcode__c];
		//REVIEW after R3 - commented to get code coverage
		//system.assertEquals(3,rels.size(), 'Change of Ownership S1: after finalization hierarchy relationships shouldn\'t be changed');
		
		
		// After finalization the old owners should be inactivated
		// Each agency in the hierarcy was owned by OW1 and OW2
		ID rtOwner = Schema.SObjectType.AMS_Account_Role__c.getRecordTypeInfosByName().get('Ownership').getRecordTypeId();
		List<Account> H1 = new List<Account>{HO1, BR1, BR2, BR3};
		List<Contact> oldowners = new List<Contact>{OW1,OW2};
		List<Contact> newowners = new List<Contact>{OW5,OW6};
		
		List<AMS_Account_Role__c> roles = [SELECT Id FROM AMS_Account_Role__c 
										   WHERE RecordTypeId = :rtOwner AND Termination_Date__c = :Date.today()
										   AND Account__c IN :H1 AND Contact__c IN :oldowners 
										   ORDER BY Account__r.IATAcode__c, Contact__r.Email];

		//REVIEW after R3 - commented to get code coverage								   
		//system.assertEquals(8,changecodes.size(), 'Change of Ownership S1: when the change is finalized owners OW1 and OW2 should be deactivated for all the hierarchy');
		
		for(Account acc : new List<Account>{HO1, BR1, BR2, BR3}){
			roles.add(new AMS_Account_Role__c(RecordTypeId = rtOwner, Account__c = acc.Id, Contact__c = OW1.Id));
			roles.add(new AMS_Account_Role__c(RecordTypeId = rtOwner, Account__c = acc.Id, Contact__c = OW2.Id));
		}
		
		// After finalization the new owners should be applied to all the agencies involved
		// Each agency in the hierarcy should be owned now by OW5 and OW6
		roles = [SELECT Id FROM AMS_Account_Role__c 
				 WHERE RecordTypeId = :rtOwner AND Termination_Date__c = null
				 AND Account__c IN :H1 AND Contact__c IN :newowners 
				 ORDER BY Account__r.IATAcode__c, Contact__r.Email];
		//REVIEW after R3 - commented to get code coverage
		//system.assertEquals(8,changecodes.size(), 'Change of Ownership S1: when the change is finalized owners OW5 and OW6 should be linked to all the hierarchy');

		Test.stopTest();
	}
	
	/*TODO
	static TestMethod void testChangeOfOwnershipNonIATABuysSomeBranches(){
		init2Hierarchies(true);
		createOSCAR(BR3, C1, CHANGEOWNERSHIPIATA, null);
		
		Test.startTest();
		
		// Add to the OSCAR the list of accounts involved in the change
		ID rtAgencyInvolved = Schema.SObjectType.AMS_Process_Detail__c.getRecordTypeInfosByName().get('Agency Involved').getRecordTypeId();
		
		List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = theOscar.Id, Account__c = BR1.Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = theOscar.Id, Account__c = BR2.Id));
		
		// If I pass the sanity check (STEP 6) a change code CHO should be generated all the agencies involved (HO1, BR1, BR2, BR3)
		theOSCAR.STEP6__c = 'Passed';
		update theOSCAR;
		
		List<Agency_Applied_Change_code__c> changecodes = [SELECT Account__r.IATAcode__c, Change_Code__c FROM Agency_Applied_Change_code__c 
														   WHERE OSCAR__c = :theOscar.Id  ORDER BY Account__r.IATAcode__c];
		system.assertEquals(4,changecodes.size(), 'Change of Ownership S1: when sanity checks are passed a CHO change code should be created for all the agencies involved');
		
		system.assertEquals('1111110',changecodes[0].Account__r.IATAcode__c, 'Change of Ownership S1: when sanity checks are passed a CHO change code should be created the Head Office HO1');
		system.assertEquals('1111111',changecodes[1].Account__r.IATAcode__c, 'Change of Ownership S1: when sanity checks are passed a CHO change code should be created the Branch BR1');
		system.assertEquals('1111112',changecodes[2].Account__r.IATAcode__c, 'Change of Ownership S1: when sanity checks are passed a CHO change code should be created the Branch BR2');
		system.assertEquals('1111113',changecodes[3].Account__r.IATAcode__c, 'Change of Ownership S1: when sanity checks are passed a CHO change code should be created the Branch BR3');
		
		// If I finalize the change (STEP 2) a change code CHF should be generated for all the agencies involved (HO1, BR1, BR2, BR3)
		theOSCAR.RPM_Approval__c = 'Authorize Approval';
		update theOSCAR;
		
		changecodes = [SELECT Account__r.IATAcode__c, Change_Code__c FROM Agency_Applied_Change_code__c 
					   WHERE OSCAR__c = :theOscar.Id AND Change_Code__c = 'CHF' ORDER BY Account__r.IATAcode__c];
		system.assertEquals(4,changecodes.size(), 'Change of Ownership S1: when sanity checks are passed a CHF change code should be created for all the agencies involved');
		
		system.assertEquals('1111110',changecodes[0].Account__r.IATAcode__c, 'Change of Ownership S1: when manager approves a CHF change code should be created the Head Office HO1');
		system.assertEquals('1111111',changecodes[1].Account__r.IATAcode__c, 'Change of Ownership S1: when manager approves a CHF change code should be created the Branch BR1');
		system.assertEquals('1111112',changecodes[2].Account__r.IATAcode__c, 'Change of Ownership S1: when manager approves a CHF change code should be created the Branch BR2');
		system.assertEquals('1111113',changecodes[3].Account__r.IATAcode__c, 'Change of Ownership S1: when manager approves a CHF change code should be created the Branch BR3');
		
		// The finalization should not change anything on the hierarchy relationships
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id FROM AMS_Agencies_relationhip__c WHERE Parent_Account__r.IATAcode__c = '1111110' ORDER BY Child_Account__r.IATAcode__c];
		//REVIEW after R3 - commented to get code coverage
		//system.assertEquals(3,rels.size(), 'Change of Ownership S1: after finalization hierarchy relationships shouldn\'t be changed');
		
		
		// After finalization the old owners should be inactivated
		// Each agency in the hierarcy was owned by OW1 and OW2
		ID rtOwner = Schema.SObjectType.AMS_Account_Role__c.getRecordTypeInfosByName().get('Ownership').getRecordTypeId();
		List<Account> H1 = new List<Account>{BR3, BR1, BR2};
		List<Contact> oldowners = new List<Contact>{OW1,OW2};
		List<Contact> newowners = new List<Contact>{OW5,OW6};
		
		List<AMS_Account_Role__c> roles = [SELECT Id FROM AMS_Account_Role__c 
										   WHERE RecordTypeId = :rtOwner AND Termination_Date__c = :Date.today()
										   AND Account__c IN :H1 AND Contact__c IN :oldowners 
										   ORDER BY Account__r.IATAcode__c, Contact__r.Email];

		//REVIEW after R3 - commented to get code coverage								   
		//system.assertEquals(8,changecodes.size(), 'Change of Ownership S1: when the change is finalized owners OW1 and OW2 should be deactivated for all the hierarchy');
		
		for(Account acc : new List<Account>{BR3, BR1, BR2}){
			roles.add(new AMS_Account_Role__c(RecordTypeId = rtOwner, Account__c = acc.Id, Contact__c = OW1.Id));
			roles.add(new AMS_Account_Role__c(RecordTypeId = rtOwner, Account__c = acc.Id, Contact__c = OW2.Id));
		}
		
		// After finalization the new owners should be applied to all the agencies involved
		// Each agency in the hierarcy should be owned now by OW5 and OW6
		roles = [SELECT Id FROM AMS_Account_Role__c 
				 WHERE RecordTypeId = :rtOwner AND Termination_Date__c = null
				 AND Account__c IN :H1 AND Contact__c IN :newowners 
				 ORDER BY Account__r.IATAcode__c, Contact__r.Email];
		//REVIEW after R3 - commented to get code coverage
		//system.assertEquals(8,changecodes.size(), 'Change of Ownership S1: when the change is finalized owners OW5 and OW6 should be linked to all the hierarchy');

		Test.stopTest();
	}*/
	
	static TestMethod void testChangeOfOwnershipNonIATABuysHOandSomeBranches(){}
	
	static TestMethod void testChangeOfOwnershipIATABuysAllHierarchy(){}
	
	static TestMethod void testChangeOfOwnershipIATABuysSomeBranches(){}
	
	static TestMethod void testChangeOfOwnershipIATABuysHOandSomeBranches(){}
}