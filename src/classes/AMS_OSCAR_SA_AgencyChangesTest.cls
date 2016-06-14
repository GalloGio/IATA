@isTest
public class AMS_OSCAR_SA_AgencyChangesTest {
    
	public static String SECTORPAX = 'Travel Agent';
	public static String CATEGORYPAX = 'IATA Passenger Sales Agent';
	public static String LOCCLASSPAX = 'P';

    @testSetup static void setup()
    {

    	ID rtAgency = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();

    	IATA_ISO_Country__c portugal = new IATA_ISO_Country__c(Name='Portugal', ISO_Code__c='PT', Region__c='Europe', ISS_Office_Location__c='Portugal');
		insert portugal;

        Account HO1 = new Account(RecordTypeId = rtAgency, Name = 'Winter Travels HO1', IATAcode__c = '1234567', IATA_ISO_Country__c = portugal.id, 
						 Sector__c = SECTORPAX, Category__c = CATEGORYPAX, 
						 Location_Class__c = LOCCLASSPAX, Location_Type__c = 'HO', Status__c = AMS_Utils.ACC_S9_APPROVED);

		List<Account> hos = new List<Account>{HO1};
		insert hos;

		Account BR1 = new Account(RecordTypeId = rtAgency, Name = 'Fire Travels BR1', IATAcode__c = '7654321', IATA_ISO_Country__c = portugal.id, 
						 Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Status__c = AMS_Utils.ACC_S9_APPROVED,  
						 Location_Class__c = LOCCLASSPAX, Location_Type__c = 'BR', ParentId = HO1.Id);

		Account BR2 = new Account(RecordTypeId = rtAgency, Name = 'Water Travels BR2', IATAcode__c = '7654323', IATA_ISO_Country__c = portugal.id, 
						 Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Status__c = AMS_Utils.ACC_S9_APPROVED, 
						 Location_Class__c = LOCCLASSPAX, Location_Type__c = 'BR', ParentId = HO1.Id);

		List<Account> brs = new List<Account>{BR1, BR2};
		insert brs;

		Account SA1 = new Account(RecordTypeId = rtAgency, Name = 'Water Travels SA1', IATAcode__c = '7654324', IATA_ISO_Country__c = portugal.id, 
						 Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Status__c = AMS_Utils.ACC_S9_APPROVED, 
						 Location_Class__c = LOCCLASSPAX, Location_Type__c = 'SA', ParentId = HO1.Id);

		Account SA2 = new Account(RecordTypeId = rtAgency, Name = 'Earth Travels SA2', IATAcode__c = '7654325', IATA_ISO_Country__c = portugal.id, 
						 Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Status__c = AMS_Utils.ACC_S9_APPROVED, 
						 Location_Class__c = LOCCLASSPAX, Location_Type__c = 'SA', ParentId = BR1.Id);

		Account SA3 = new Account(RecordTypeId = rtAgency, Name = 'Headhunter Travels SA3', IATAcode__c = '7654326', IATA_ISO_Country__c = portugal.id, 
						 Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Status__c = AMS_Utils.ACC_S9_APPROVED, 
						 Location_Class__c = LOCCLASSPAX, Location_Type__c = 'SA', ParentId = BR1.Id);

		Account SA4 = new Account(RecordTypeId = rtAgency, Name = 'Beach Travels SA4', IATAcode__c = '7654323', IATA_ISO_Country__c = portugal.id, 
						 Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Status__c = AMS_Utils.ACC_S9_APPROVED, 
						 Location_Class__c = LOCCLASSPAX, Location_Type__c = 'SA', ParentId = HO1.Id);

		List<Account> sas = new List<Account>{SA1, SA2, SA3, SA4};
		insert sas;

		//Create contacts and owners
		Contact C1 = new Contact(FirstName = 'First', LastName = 'Contact',  AccountId = HO1.Id, Email = 'thecontact1@gmail.com', Phone = '123123123');
		insert C1;

		//Create hierarchy
		AMS_Agencies_Hierarchy__c H1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');
		List<AMS_Agencies_Hierarchy__c> hs = new List<AMS_Agencies_Hierarchy__c>{H1};
		insert hs;
		
		List<AMS_Agencies_relationhip__c> rels = new List<AMS_Agencies_relationhip__c>();
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = HO1.Id, Child_Account__c = BR1.Id));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = HO1.Id, Child_Account__c = BR2.Id));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = HO1.Id, Child_Account__c = SA1.Id));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = BR1.Id, Child_Account__c = SA2.Id));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = BR1.Id, Child_Account__c = SA3.Id));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = HO1.Id, Child_Account__c = SA4.Id));
		
		insert rels;

		//Agency changes configuration settings
		List<AMS_AgencyChangesConfig__c> customsettings = new List<AMS_AgencyChangesConfig__c>();
		customsettings.add(new AMS_AgencyChangesConfig__c(Name = 'ChangeLocationType', TC_Location_type__c = true,
														  TC_Legal_status__c = false, TC_Location__c = false, TC_Location_with_inspection__c = false, 
														  TC_Minor_Shareholding__c = false, TC_Name__c = false, TC_Ownership_to_IATA_Agent__c = false, 
														  TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = false, TC_VMFR__c = false, 
														  TCA_Sanity_check__c = 'CAD', TCA_Application_withdrawal__c = 'CWD'));
		customsettings.add(new AMS_AgencyChangesConfig__c(Name = 'ChangeLocation', TC_Location_type__c = false,
														  TC_Legal_status__c = false, TC_Location__c = true, TC_Location_with_inspection__c = false, 
														  TC_Minor_Shareholding__c = false, TC_Name__c = false, TC_Ownership_to_IATA_Agent__c = false, 
														  TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = false, TC_VMFR__c = false, 
														  TCA_Sanity_check__c = 'CHL', TCA_Application_withdrawal__c = 'CWD'));

		insert customsettings;

    }
    
    //Scenario 1: Branch becomes an HeadOffice
    @isTest static void changeOfLocationType1Test()
    {

    	//Open the OSCAR on the Branch that has a child SA
    	ID rtChange = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();

    	Account BR1 = [SELECT Id, Name, IATAcode__c, IATA_ISO_Country__c, Location_Class__c, Location_Type__c, ParentId FROM Account WHERE Name = 'Fire Travels BR1'];

    	Contact C1 = [SELECT Id FROM Contact WHERE Email = 'thecontact1@gmail.com'];
		
		//open the OSCAR in a BR which has child SA agencies
    	AMS_OSCAR__c oscar = new AMS_OSCAR__c(RecordTypeId = rtChange, Account__c = BR1.Id, Type_of_change__c = 'Location Type');
		insert oscar;

		ID rtCommCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();
		Case theCommunicationCase = new Case(RecordTypeId = rtCommCase, Subject = '' + BR1.Name, OSCAR__c = oscar.Id,
											AccountId = (BR1.ParentId == null ? BR1.Id : BR1.ParentId), ContactId = C1.Id);
		insert theCommunicationCase;

    	// Create the Staging area for the Account
		AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = BR1.Name, 
															IATAcode__c = BR1.IATAcode__c, 
															Branch_Office_Country__c = BR1.IATA_ISO_Country__c,
														   Location_Class__c = BR1.Location_Class__c, 
														   Location_Type__c = BR1.Location_Type__c,
														   SAAM_Case__c = theCommunicationCase.Id);
															
		insert stagingArea;

		oscar.AMS_Online_Accreditation__c = stagingArea.Id;
		update oscar;

        Test.startTest();
        
        oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        update oscar;

        Test.stopTest();

        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the new hierarchy structure
        List<AMS_Agencies_relationhip__c> rels = [SELECT ID, Child_Account__r.Name, Child_Account__r.Location_Type__c, Parent_Account__r.Name, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c =: H1.Id];
        System.assertEquals(6, rels.size());

        Account HO1 = [SELECT Id, ParentId FROM Account WHERE Name = 'Winter Travels HO1'];
        BR1 = [SELECT Id, ParentId FROM Account WHERE Name = 'Fire Travels BR1'];

        Integer countConditions = 0;

        for(AMS_Agencies_relationhip__c rel: rels){
        	if(rel.Child_Account__r.Name == 'Winter Travels HO1'){
 				//the old HO should now be a BR
        		System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Fire Travels BR1', rel.Parent_Account__r.Name);
        		System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Water Travels BR2'){
        		System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Fire Travels BR1', rel.Parent_Account__r.Name);
        		System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Water Travels SA1'){
        		System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Winter Travels HO1', rel.Parent_Account__r.Name);
        		System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Earth Travels SA2'){
        		System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Fire Travels BR1', rel.Parent_Account__r.Name);
        		System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Headhunter Travels SA3'){
        		System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Fire Travels BR1', rel.Parent_Account__r.Name);
        		System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}else if(rel.Child_Account__r.Name == 'Beach Travels SA4'){
        		System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Winter Travels HO1', rel.Parent_Account__r.Name);
        		System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        }

        System.assertEquals(BR1.ParentId, null);

        //all the conditions inside the loop must happen
        System.assertEquals(6, countConditions);

    }

    //Scenario 2: SA become BR
    @isTest static void changeOfLocationType2Test()
    {

    	//Open the OSCAR on the Branch that has a child SA
    	ID rtChange = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();

    	Account SA2 = [SELECT Id, Name, IATAcode__c, IATA_ISO_Country__c, Location_Class__c, Location_Type__c, ParentId FROM Account WHERE Name = 'Earth Travels SA2'];

    	Contact C1 = [SELECT Id FROM Contact WHERE Email = 'thecontact1@gmail.com'];
		
		//open the oscar in an SA under a BR
    	AMS_OSCAR__c oscar = new AMS_OSCAR__c(RecordTypeId = rtChange, Account__c = SA2.Id, Type_of_change__c = 'Location Type');
		insert oscar;

		ID rtCommCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();
		Case theCommunicationCase = new Case(RecordTypeId = rtCommCase, Subject = '' + SA2.Name, OSCAR__c = oscar.Id,
											AccountId = (SA2.ParentId == null ? SA2.Id : SA2.ParentId), ContactId = C1.Id);
		insert theCommunicationCase;

    	// Create the Staging area for the Account
		AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = SA2.Name, 
															IATAcode__c = SA2.IATAcode__c, 
															Branch_Office_Country__c = SA2.IATA_ISO_Country__c,
														   Location_Class__c = SA2.Location_Class__c, 
														   Location_Type__c = SA2.Location_Type__c,
														   SAAM_Case__c = theCommunicationCase.Id);
															
		insert stagingArea;

		oscar.AMS_Online_Accreditation__c = stagingArea.Id;
		update oscar;

        Test.startTest();
        
        oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        update oscar;

        Test.stopTest();

        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the new hierarchy structure
        List<AMS_Agencies_relationhip__c> rels = [SELECT ID, Child_Account__r.Name, Child_Account__r.Location_Type__c, Parent_Account__r.Name, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c =: H1.Id];
        System.assertEquals(6, rels.size());

        Account HO1 = [SELECT Id, ParentId FROM Account WHERE Name = 'Winter Travels HO1'];
        SA2 = [SELECT Id, ParentId FROM Account WHERE Name = 'Earth Travels SA2'];

        Integer countConditions = 0;

        for(AMS_Agencies_relationhip__c rel: rels){
        	if(rel.Child_Account__r.Name == 'Earth Travels SA2'){
        		System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Winter Travels HO1', rel.Parent_Account__r.Name);
        		System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Water Travels BR2'){
        		System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Winter Travels HO1', rel.Parent_Account__r.Name);
        		System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Water Travels SA1'){
        		System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Winter Travels HO1', rel.Parent_Account__r.Name);
        		System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Fire Travels BR1'){
        		System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Earth Travels SA2', rel.Parent_Account__r.Name);
        		System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(SA2.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Headhunter Travels SA3'){
        		System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Earth Travels SA2', rel.Parent_Account__r.Name);
        		System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(SA2.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Beach Travels SA4'){
        		System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Winter Travels HO1', rel.Parent_Account__r.Name);
        		System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        }

        System.assertEquals(HO1.ParentId, null);

        //all the conditions inside the loop must happen
        System.assertEquals(countConditions, 6);

    }

    //Scenario 3: SA becomes BR, the parent is not changed (SA under a BR moves directly under the HO of the hierarchy)
    @isTest static void changeOfLocationType3Test()
    {

    	//Open the OSCAR on the Branch that has a child SA
    	ID rtChange = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();

    	Account SA2 = [SELECT Id, Name, IATAcode__c, IATA_ISO_Country__c, Location_Class__c, Location_Type__c, ParentId FROM Account WHERE Name = 'Earth Travels SA2'];

    	Contact C1 = [SELECT Id FROM Contact WHERE Email = 'thecontact1@gmail.com'];
		
		//open the oscar in an SA under a BR with “Change of location type behavior” with value “Don’t change the parent”.
    	AMS_OSCAR__c oscar = new AMS_OSCAR__c(RecordTypeId = rtChange, Account__c = SA2.Id, Type_of_change__c = 'Location Type', Change_of_location_type_behavior__c = AMS_Utils.CHLOCTYPEBEHAVIOR_NOSWAP);
		insert oscar;

		ID rtCommCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();
		Case theCommunicationCase = new Case(RecordTypeId = rtCommCase, Subject = '' + SA2.Name, OSCAR__c = oscar.Id,
											AccountId = (SA2.ParentId == null ? SA2.Id : SA2.ParentId), ContactId = C1.Id);
		insert theCommunicationCase;

    	// Create the Staging area for the Account
		AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = SA2.Name, 
															IATAcode__c = SA2.IATAcode__c, 
															Branch_Office_Country__c = SA2.IATA_ISO_Country__c,
														   Location_Class__c = SA2.Location_Class__c, 
														   Location_Type__c = SA2.Location_Type__c,
														   SAAM_Case__c = theCommunicationCase.Id);
															
		insert stagingArea;

		oscar.AMS_Online_Accreditation__c = stagingArea.Id;
		update oscar;

        Test.startTest();
        
        oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        update oscar;

        Test.stopTest();

        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the new hierarchy structure
        List<AMS_Agencies_relationhip__c> rels = [SELECT ID, Child_Account__r.Name, Child_Account__r.Location_Type__c, Parent_Account__r.Name, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c =: H1.Id];
        System.assertEquals(6, rels.size());

        Account HO1 = [SELECT Id, ParentId FROM Account WHERE Name = 'Winter Travels HO1'];
        Account BR1 = [SELECT Id, ParentId FROM Account WHERE Name = 'Fire Travels BR1'];

        Integer countConditions = 0;

        for(AMS_Agencies_relationhip__c rel: rels){
        	if(rel.Child_Account__r.Name == 'Water Travels SA1'){
        		System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Winter Travels HO1', rel.Parent_Account__r.Name);
        		System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Earth Travels SA2'){
        		System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Winter Travels HO1', rel.Parent_Account__r.Name);
        		System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Fire Travels BR1'){
        		System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Winter Travels HO1', rel.Parent_Account__r.Name);
        		System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Water Travels BR2'){
        		System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Winter Travels HO1', rel.Parent_Account__r.Name);
        		System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Headhunter Travels SA3'){
        		System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Fire Travels BR1', rel.Parent_Account__r.Name);
        		System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Beach Travels SA4'){
        		System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Winter Travels HO1', rel.Parent_Account__r.Name);
        		System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        }

        System.assertEquals(HO1.ParentId, null);

        //all the conditions inside the loop must happen
        System.assertEquals(countConditions, 6);

    }

    //Scenario 4: SA becomes HO
    @isTest static void changeOfLocationType4Test()
    {

    	//Open the OSCAR on the Branch that has a child SA
    	ID rtChange = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();

    	Account SA1 = [SELECT Id, Name, IATAcode__c, IATA_ISO_Country__c, Location_Class__c, Location_Type__c, ParentId FROM Account WHERE Name = 'Water Travels SA1'];

    	Contact C1 = [SELECT Id FROM Contact WHERE Email = 'thecontact1@gmail.com'];
		
		//open the oscar in an SA under an HO
    	AMS_OSCAR__c oscar = new AMS_OSCAR__c(RecordTypeId = rtChange, Account__c = SA1.Id, Type_of_change__c = 'Location Type');
		insert oscar;

		ID rtCommCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();
		Case theCommunicationCase = new Case(RecordTypeId = rtCommCase, Subject = '' + SA1.Name, OSCAR__c = oscar.Id,
											AccountId = (SA1.ParentId == null ? SA1.Id : SA1.ParentId), ContactId = C1.Id);
		insert theCommunicationCase;

    	// Create the Staging area for the Account
		AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = SA1.Name, 
															IATAcode__c = SA1.IATAcode__c, 
															Branch_Office_Country__c = SA1.IATA_ISO_Country__c,
														   Location_Class__c = SA1.Location_Class__c, 
														   Location_Type__c = SA1.Location_Type__c,
														   SAAM_Case__c = theCommunicationCase.Id);
															
		insert stagingArea;

		oscar.AMS_Online_Accreditation__c = stagingArea.Id;
		update oscar;

        Test.startTest();
        
        oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        update oscar;

        Test.stopTest();

        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the new hierarchy structure
        List<AMS_Agencies_relationhip__c> rels = [SELECT ID, Child_Account__r.Name, Child_Account__r.Location_Type__c, Parent_Account__r.Name, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c =: H1.Id];
        System.assertEquals(6, rels.size());

        SA1 = [SELECT Id, ParentId FROM Account WHERE Name = 'Water Travels SA1'];
        Account BR1 = [SELECT Id, ParentId FROM Account WHERE Name = 'Fire Travels BR1'];

        Integer countConditions = 0;

        for(AMS_Agencies_relationhip__c rel: rels){
        	if(rel.Child_Account__r.Name == 'Winter Travels HO1'){
        		System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Water Travels SA1', rel.Parent_Account__r.Name);
        		System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(SA1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Water Travels BR2'){
        		System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Water Travels SA1', rel.Parent_Account__r.Name);
        		System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(SA1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Earth Travels SA2'){
        		System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Fire Travels BR1', rel.Parent_Account__r.Name);
        		System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Fire Travels BR1'){
        		System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Water Travels SA1', rel.Parent_Account__r.Name);
        		System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(SA1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Headhunter Travels SA3'){
        		System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Fire Travels BR1', rel.Parent_Account__r.Name);
        		System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        	else if(rel.Child_Account__r.Name == 'Beach Travels SA4'){
        		System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
        		System.assertEquals('Water Travels SA1', rel.Parent_Account__r.Name);
        		System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
        		System.assertEquals(SA1.Id, rel.Child_Account__r.ParentId);
        		countConditions++;
        	}
        }

        System.assertEquals(SA1.ParentId, null);

        //all the conditions inside the loop must happen
        System.assertEquals(countConditions, 6);

    }

     //Change of location type behavior - If “Type of change” is not “Location type” this field must be empty
    @isTest static void verifyOptionBlock1()
    {

    	//Open the OSCAR on the Branch that has a child SA
    	ID rtChange = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();

    	Account SA1 = [SELECT Id, Name, IATAcode__c, IATA_ISO_Country__c, Location_Class__c, Location_Type__c, ParentId FROM Account WHERE Name = 'Water Travels SA1'];

    	Contact C1 = [SELECT Id FROM Contact WHERE Email = 'thecontact1@gmail.com'];
		
		//open the oscar in an SA under an HO
    	AMS_OSCAR__c oscar = new AMS_OSCAR__c(RecordTypeId = rtChange, Account__c = SA1.Id, Type_of_change__c = 'Location');
		insert oscar;

		ID rtCommCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();
		Case theCommunicationCase = new Case(RecordTypeId = rtCommCase, Subject = '' + SA1.Name, OSCAR__c = oscar.Id,
											AccountId = (SA1.ParentId == null ? SA1.Id : SA1.ParentId), ContactId = C1.Id);
		insert theCommunicationCase;

    	// Create the Staging area for the Account
		AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = SA1.Name, 
															IATAcode__c = SA1.IATAcode__c, 
															Branch_Office_Country__c = SA1.IATA_ISO_Country__c,
														   Location_Class__c = SA1.Location_Class__c, 
														   Location_Type__c = SA1.Location_Type__c,
														   SAAM_Case__c = theCommunicationCase.Id);
															
		insert stagingArea;

		oscar.AMS_Online_Accreditation__c = stagingArea.Id;
		update oscar;

        Test.startTest();
        
        try{
        	//block is only done when trying to pass sanity check
        	oscar.STEP6__c = AMS_Utils.PASSED;
	        oscar.Change_of_location_type_behavior__c = AMS_Utils.CHLOCTYPEBEHAVIOR_NOSWAP;
	        update oscar;
	        System.assert(false, 'exception expected');
        }catch(Exception e){
			Boolean expectedExceptionThrown =  e.getMessage().contains('This field can only be filled for changes of Location Type.') ? true : false;
			System.assertEquals(expectedExceptionThrown, true);
		} 

        Test.stopTest();

    }

     //Change of location type behavior - oscar is opened with change of location type on BR, the only value admissible is “Swap with the parent”.
    @isTest static void verifyOptionBlock2()
    {

    	//Open the OSCAR on the Branch that has a child SA
    	ID rtChange = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();

    	Account BR1 = [SELECT Id, Name, IATAcode__c, IATA_ISO_Country__c, Location_Class__c, Location_Type__c, ParentId FROM Account WHERE Name = 'Fire Travels BR1'];
    	Account SA1 = [SELECT Id, Name, IATAcode__c, IATA_ISO_Country__c, Location_Class__c, Location_Type__c, ParentId FROM Account WHERE Name = 'Water Travels SA1'];

    	Contact C1 = [SELECT Id FROM Contact WHERE Email = 'thecontact1@gmail.com'];
		
		//open the oscar in an SA under an HO
    	AMS_OSCAR__c oscar = new AMS_OSCAR__c(RecordTypeId = rtChange, Account__c = BR1.Id, Type_of_change__c = 'Location Type');
		insert oscar;

		ID rtCommCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();
		Case theCommunicationCase = new Case(RecordTypeId = rtCommCase, Subject = '' + SA1.Name, OSCAR__c = oscar.Id,
											AccountId = (SA1.ParentId == null ? SA1.Id : SA1.ParentId), ContactId = C1.Id);
		insert theCommunicationCase;

    	// Create the Staging area for the Account
		AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = SA1.Name, 
															IATAcode__c = SA1.IATAcode__c, 
															Branch_Office_Country__c = SA1.IATA_ISO_Country__c,
														   Location_Class__c = SA1.Location_Class__c, 
														   Location_Type__c = SA1.Location_Type__c,
														   SAAM_Case__c = theCommunicationCase.Id);
															
		insert stagingArea;

		oscar.AMS_Online_Accreditation__c = stagingArea.Id;
		update oscar;

        Test.startTest();
        
        try{
        	//block is only done when trying to pass sanity check
        	oscar.STEP6__c = AMS_Utils.PASSED;
	        oscar.Change_of_location_type_behavior__c = AMS_Utils.CHLOCTYPEBEHAVIOR_NOSWAP;
	        update oscar;
	        System.assert(false, 'exception expected');
        }catch(Exception e){
			Boolean expectedExceptionThrown =  e.getMessage().contains('This option cannot be used when the OSCAR is opened for a Branch.') ? true : false;
			System.assertEquals(expectedExceptionThrown, true);
		} 

        Test.stopTest();

    }
    
}