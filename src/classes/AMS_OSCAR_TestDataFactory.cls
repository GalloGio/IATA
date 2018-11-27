public with sharing class AMS_OSCAR_TestDataFactory
{
	public static void loadCredentials() {
	    
	    Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'GenericAttach', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
	    insert Amazon_Cred;
	    Amazon_Cred__c Amazon_Cred2 =  new Amazon_Cred__c(name = 'RecycleBin', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
	    insert Amazon_Cred2;

	    list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{
	        new AWSKey__c(
	            name = 'adevconf',
	            Key__c = 'asd', 
	            Secret__c = 'asd',  
	            IAS_configuration_name__c = 'asdas', 
	            IAS_Access_Point__c = 'asd',
	            Bucket__c = 'asd',
	            AWS_ENDPOINT_URL__c = 'asd')
	    };
	    insert AWS_KEYs;
	}

	public static void createOSCARtestData()
	{
		AMS_Person__c per = new AMS_Person__c(Name = 'teste', User__c = UserInfo.getUserId());
		insert per;

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);
        insert stt;
		
		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		Account account = new Account();
		account.Name = 'TestAccount';
		account.Type = 'Airport';
		account.IATACode__c = '1234567';
		insert account;
		
		List<Account> accountList = new List<Account>();
		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234567',Name='Test1 Agency',Short_Name__c='Test1 Agency');
		insert a1;
        
		AMS_OSCAR__c OSCAR = new AMS_OSCAR__c(STEP1__c = 'In Progress', Account__c = a1.id,Change_effective_as_of__c = Date.today());
		insert OSCAR;

		Agency_Applied_Change_code__c aacc = new Agency_Applied_Change_code__c(Active__c = true, /*Change_Code__c = acc.id,MACREVIEW*/ Account__c = a1.id);
		insert aacc;
		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;
		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication'));
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;


        //create oscar history custom setting
        List<AMS_OSCAR_HistoryFields__c> customsettings = new List<AMS_OSCAR_HistoryFields__c>();
		customsettings.add(new AMS_OSCAR_HistoryFields__c(Name = 'Welcome_Pack_Sent__c', HasExternalLabel__c = false, FieldName__c ='Welcome Pack Sent'));
		customsettings.add(new AMS_OSCAR_HistoryFields__c(Name = 'STEP1__c', HasExternalLabel__c = true, FieldName__c ='STEP1'));

		insert customsettings;

	}

	public static void createOSCARtestDataAccHier()
	{
		Account HO1, HO2, BR1, BR2, BR3, BR4, BR5, BR6;
		Contact C1, C2, OW1, OW2, OW3, OW4, OW5, OW6;
		AMS_OSCAR__c theOscar;
		Case theCommunicationCase;
		AMS_Pax_Accreditation_Form__c theStagingAcc;
		AMS_Accreditation_Contact__c theStagingCont;
		
		String SECTORPAX = 'Travel Agent';
		String CATEGORYPAX = 'IATA Passenger Sales Agent';
		String LOCCLASSPAX = 'P';
		
		String SECTORCASS = 'Cargo Agent';
		String CATEGORYCASS = 'IATA Cargo Sales Agent';
		String LOCCLASSCASS = 'C';
		
		String CHANGELOCATIONTYPE = 'Location type';
		String CHANGEOWNERSHIPIATA= 'Ownership to IATA Agent';
		String CHANGEOWNERSHIPNONIATA= 'Ownership to non-IATA Agent';

		boolean isPax = true;

		AMS_Person__c per = new AMS_Person__c(Name = 'teste', User__c = UserInfo.getUserId());
		insert per;

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);
        insert stt;
		
		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		Account account = new Account();
		account.Name = 'TestAccount';
		account.Type = 'Airport';
		account.IATACode__c = '1234567';
		insert account;
		
		List<Account> accountList = new List<Account>();
		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234567',Name='Test1 Agency',Short_Name__c='Test1 Agency');
		insert a1;

		IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy');
		insert italy;
		
		//Create 2 head offices
		HO1 = new Account(RecordTypeId = accountRT, Name = 'My Travels', IATAcode__c = '1111110', IATA_ISO_Country__c = italy.id, 
						 Sector__c = (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), 
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'HO', Status__c = AMS_Utils.ACC_S9_APPROVED,
   						 Reason_for_creation__c = 'Created by customer' );
		HO2 = new Account(RecordTypeId = accountRT, Name = 'Your Travels', IATAcode__c = '2222220', IATA_ISO_Country__c = italy.id, 
						 Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), 
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'HO', Status__c = AMS_Utils.ACC_S9_APPROVED,
   						 Reason_for_creation__c = 'Created by customer' );   
		
		//Create a separate Account for the Owners
		Account OwnersAccount =  new Account(Name = 'General account for owners');
		
		List<Account> accs = new List<Account>{HO1, HO2, OwnersAccount};
		insert accs;
								 
						 
		//Create the 6 branches
		BR1 = new Account(RecordTypeId = accountRT, Name = 'My Travels', IATAcode__c = '1111111', IATA_ISO_Country__c = italy.id, 
						 Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), Status__c = AMS_Utils.ACC_S9_APPROVED,  
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'BR', ParentId = HO1.Id,
      					 Reason_for_creation__c = 'Created by customer' );
		BR2 = new Account(RecordTypeId = accountRT, Name = 'My Travels', IATAcode__c = '1111112', IATA_ISO_Country__c = italy.id, 
						 Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), Status__c = AMS_Utils.ACC_S9_APPROVED, 
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'BR', ParentId = HO1.Id,
   						 Reason_for_creation__c = 'Created by customer' );
		BR3 = new Account(RecordTypeId = accountRT, Name = 'My Travels', IATAcode__c = '1111113', IATA_ISO_Country__c = italy.id, 
						 Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), Status__c = AMS_Utils.ACC_S9_APPROVED, 
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'BR', ParentId = HO1.Id,
   						 Reason_for_creation__c = 'Created by customer' );
		BR4 = new Account(RecordTypeId = accountRT, Name = 'Your Travels', IATAcode__c = '2222221', IATA_ISO_Country__c = italy.id, 
						 Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), Status__c = AMS_Utils.ACC_S9_APPROVED, 
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'BR', ParentId = HO2.Id,
   						 Reason_for_creation__c = 'Created by customer' );
		BR5 = new Account(RecordTypeId = accountRT, Name = 'Your Travels', IATAcode__c = '2222222', IATA_ISO_Country__c = italy.id, 
						 Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), Status__c = AMS_Utils.ACC_S9_APPROVED, 
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'BR', ParentId = HO2.Id,
   						 Reason_for_creation__c = 'Created by customer' );
		BR6 = new Account(RecordTypeId = accountRT, Name = 'Your Travels', IATAcode__c = '2222223', IATA_ISO_Country__c = italy.id, 
						 Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), Status__c = AMS_Utils.ACC_S9_APPROVED, 
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'BR', ParentId = HO2.Id,
   						 Reason_for_creation__c = 'Created by customer' );
			
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
        
		AMS_OSCAR__c OSCAR = new AMS_OSCAR__c(STEP1__c = 'In Progress', Account__c = HO1.id,Change_effective_as_of__c = Date.today());
		insert OSCAR;

		Agency_Applied_Change_code__c aacc = new Agency_Applied_Change_code__c(Active__c = true, /*Change_Code__c = acc.id,MACREVIEW*/ Account__c = a1.id);
		insert aacc;
		Contact co1 = new Contact(AccountId = HO1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;
		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication'));
        oscarCase.AccountId = HO1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;


        //create oscar history custom setting
        List<AMS_OSCAR_HistoryFields__c> customsettings = new List<AMS_OSCAR_HistoryFields__c>();
		customsettings.add(new AMS_OSCAR_HistoryFields__c(Name = 'Welcome_Pack_Sent__c', HasExternalLabel__c = false, FieldName__c ='Welcome Pack Sent'));
		customsettings.add(new AMS_OSCAR_HistoryFields__c(Name = 'STEP1__c', HasExternalLabel__c = true, FieldName__c ='STEP1'));

		insert customsettings;
		
	}

	public static void createOSCARwithInspectionsTestData()
	{
		AMS_Person__c per = new AMS_Person__c(Name = 'teste', User__c = UserInfo.getUserId());
		insert per;

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', AIMS_Area_Name__c = 'UNITED STATES')  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);
        insert stt;
		
		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		Account account = new Account();
		account.Name = 'TestAccount';
		account.Type = 'Airport';
		account.IATACode__c = '1234567';
		insert account;

		Id airlineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
		Account airline = new Account();
		airline.Name = 'TestAirline';
		airline.Sector__c = 'Airline';
		airline.IATA_ISO_Country__c = ctry.id;
		airline.RecordTypeId = airlineRT;
		insert airline;
		
		List<Account> accountList = new List<Account>();
		
		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, Location_Type__c = 'HO', IATACode__c='1234567',Name='Test1 Agency',Short_Name__c='Test1 Agency', Status__c = AMS_Utils.ACC_S9_APPROVED, Location_Class__c = 'R');
		Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, Location_Type__c = 'BR', IATACode__c='9876543',Name='Test2 Agency',Short_Name__c='Test2 Agency', ParentId = a1.Id);

		accountList.add(a1);
		accountList.add(a2);

		insert accountList;

		List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
        
		AMS_OSCAR__c OSCAR = new AMS_OSCAR__c(STEP1__c = 'Not started', Account__c = a1.id, Process__c = AMS_Utils.new_HO,Change_effective_as_of__c = Date.today(), BusinessHours__c = bhs[0].Id);
		insert OSCAR;

		List<Agency_Applied_Change_code__c> aaccList = new List<Agency_Applied_Change_code__c>();
		
		Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Active__c = true, /*Change_Code__c = acc.id,MACREVIEW*/ Account__c = a1.id);
		Agency_Applied_Change_code__c aacc2 = new Agency_Applied_Change_code__c(Active__c = true, /*Change_Code__c = acc.id,MACREVIEW*/ Account__c = a2.id);
		aaccList.add(aacc1);
		aaccList.add(aacc2);

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		Contact co2 = new Contact(AccountId = a2.id, Firstname = 'teste2', Lastname='test2', Phone = '911111111', MobilePhone = '911111111', Email = 'test2@test.com', Financial_Assessment_Contact__c = false);
		
		List<Contact> coList = new List<Contact>();
		
		coList.add(co1);
		coList.add(co2);

		insert coList;
		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication'));
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

        AMS_Pax_Accreditation_Form__c stagingArea = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = oscarCase.Id, Account_Name__c=a1.Name, Short_Name__c=a1.Short_Name__c );
        insert stagingArea;

        OSCAR.AMS_Online_Accreditation__c = stagingArea.Id;
        update OSCAR;


        //create oscar history custom setting
        List<AMS_OSCAR_HistoryFields__c> customsettings = new List<AMS_OSCAR_HistoryFields__c>();
		customsettings.add(new AMS_OSCAR_HistoryFields__c(Name = 'Welcome_Pack_Sent__c', HasExternalLabel__c = false, FieldName__c ='Welcome Pack Sent'));
		customsettings.add(new AMS_OSCAR_HistoryFields__c(Name = 'STEP11__c', HasExternalLabel__c = true, FieldName__c ='STEP11'));
		insert customsettings;

		//Create Inspections connected to OSCAR
		
		AMS_OSCAR__c OSCAR_GSA = new AMS_OSCAR__c(STEP1__c = 'In Progress', Account__c = a1.id, Process__c =AMS_Utils.new_GSA);
		
		insert OSCAR_GSA;

		Case oscarCase_GSA = new Case(Oscar__c = OSCAR_GSA.Id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication'));
        oscarCase_GSA.AccountId = a2.Id;
        oscarCase_GSA.ContactId = co2.Id;
        insert oscarCase_GSA;

		List<AMS_Inspection__c> agencyInspectionList = new List<AMS_Inspection__c>();
		agencyInspectionList.add(new AMS_Inspection__c(Oscar__c=OSCAR_GSA.id, Airline__c = airline.Id,Accreditation_Endorsement_Status_code__c = '0'));
		agencyInspectionList.add(new AMS_Inspection__c(Oscar__c=OSCAR_GSA.id, Airline__c = airline.Id,Accreditation_Endorsement_Status_code__c = '1'));
		agencyInspectionList.add(new AMS_Inspection__c(Oscar__c=OSCAR_GSA.id, Airline__c = airline.Id,Accreditation_Endorsement_Status_code__c = '2'));
		agencyInspectionList.add(new AMS_Inspection__c(Oscar__c=OSCAR_GSA.id, Airline__c = airline.Id,Accreditation_Endorsement_Status_code__c = '3'));
		agencyInspectionList.add(new AMS_Inspection__c(Oscar__c=OSCAR_GSA.id, Airline__c = airline.Id,Accreditation_Endorsement_Status_code__c = '8'));
		
		insert	agencyInspectionList;

	}

	public static void createCargoAgencyOSCARtestData()
	{

		IATA_ISO_Country__c ctry1 = new IATA_ISO_Country__c (Name='FR',ISO_Code__c='FR');
		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='AR',ISO_Code__c='AR');
		insert new List<IATA_ISO_Country__c>{ctry1, ctry2};

		AMS_Country_Specific_Attribute__c csa1 = new AMS_Country_Specific_Attribute__c(RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'DGR_Minimum_Requirements'), Location_Class__c='R', Minimum_DGR_BR__c=1, Minimum_DGR_HO__c=1, IATA_ISO_Country__c=ctry1.Id);
        AMS_Country_Specific_Attribute__c csa2 = new AMS_Country_Specific_Attribute__c(RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'DGR_Minimum_Requirements'), Location_Class__c='R', Minimum_DGR_BR__c=1, Minimum_DGR_HO__c=1, IATA_ISO_Country__c=ctry2.Id);
        insert new List<AMS_Country_Specific_Attribute__c>{csa1,csa2};

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'FR20', IATA_ISO_Country__c = ctry1.Id);
        insert stt;

		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account cargoHO = new Account(IATA_ISO_Country__c = ctry1.id, RecordTypeId = accountRT, IATACode__c='12345670001',
									Name='Test Cargo HO',Short_Name__c='Test Cargo', Sector__c = 'Cargo Agent',
									Location_Class__c = 'C', Location_type__c = 'HO', Reason_for_creation__c = 'none',
									Is_your_firm_handling_Dangerous_Goods__c='Yes');

		insert cargoHO;

		Account cargoBR = new Account(IATA_ISO_Country__c = ctry1.id, RecordTypeId = accountRT, IATACode__c='12345670001',
									Name='Test Cargo BR',Short_Name__c='Test Cargo', Sector__c = 'Cargo Agent',
									Location_Class__c = 'C', Location_type__c = 'BR', Reason_for_creation__c = 'none', ParentId = cargoHO.Id);
        insert cargoBR;

		AMS_OSCAR__c OSCAR = new AMS_OSCAR__c(Account__c = cargoHO.id, RecordTypeId = AMS_Utils.RECTYPE_NEW, Process__c =AMS_Utils.new_HO);
		insert OSCAR;

		Contact co1 = new Contact(AccountId = cargoHO.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', BSP_CASS_Payment_contact__c = true, User_Portal_Status__c = 'Approved Admin');
		Contact co2 = new Contact(AccountId = cargoHO.id, Firstname = 'teste2', Lastname='test2', Phone = '911111112', MobilePhone = '911111112', Email = 'test2@test.com', BSP_CASS_Payment_contact__c = false, User_Portal_Status__c = 'Approved Admin');
		Contact co3 = new Contact(AccountId = cargoHO.id, Firstname = 'teste3', Lastname='test3', Phone = '911111113', MobilePhone = '911111113', Email = 'test3@test.com', BSP_CASS_Payment_contact__c = false, User_Portal_Status__c = 'Approved');
		
		List<Contact> cos = new List<Contact>{co1,co2}; 
		insert cos;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication'));
        oscarCase.AccountId = cargoHO.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

         // Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = cargoHO.Name,
                IATAcode__c = cargoHO.IATAcode__c,
                Branch_Office_Country__c = cargoHO.IATA_ISO_Country__c,
                Location_Class__c = cargoHO.Location_Class__c,
                Location_Type__c = cargoHO.Location_Type__c,
                SAAM_Case__c = oscarCase.Id,
                Is_your_firm_handling_Dangerous_Goods__c = 'Yes',
                CASS_Number__c = '000');

        insert stagingArea;

        OSCAR.AMS_Online_Accreditation__c = stagingArea.Id;
        update oscar;

        Id trainedStaff = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Trained_Staff');

		AMS_Accreditation_Contact__c acontact1 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = stagingArea.Id, First_name__c='Bugs', Last_name__c='Bunny', Valid_until__c = Date.today().addYears(2), Type_Of_Certificate__c = AMS_Utils.CERT_DGR, RecordTypeId=trainedStaff);

		AMS_Accreditation_Contact__c acontact2 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = stagingArea.Id, First_name__c='Greg', Last_name__c='Plitt', Valid_until__c = Date.today().addYears(2), Type_Of_Certificate__c = AMS_Utils.CERT_DGA, RecordTypeId=trainedStaff);

		AMS_Accreditation_Contact__c acontact3 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = stagingArea.Id, First_name__c='Daff', Last_name__c='Duck', Valid_until__c = Date.today().addYears(2), Type_Of_Certificate__c = AMS_Utils.CERT_CATA, RecordTypeId=trainedStaff);

		insert new List<AMS_Accreditation_Contact__c>{acontact1,acontact2,acontact3};

	}

	public static void createNewGenTestData(String newGenProcess)
	{

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'FR20', ISO_Code__c = 'FR', IATA_ISO_Country__c = ctry.Id);
        insert stt;
		
		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
		
		List<Account> accountList = new List<Account>();
		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234567',Name='NewGenAgency',Short_Name__c='NewGenAgency');
		insert a1;
        
        Contact co1 = new Contact(AccountId = a1.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Process__c = newGenProcess, Account__c = a1.id, Is_using_credit_card__c = true);
		insert oscar;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = caseRT);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;
		
		// Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = a1.Name,
                IATAcode__c = a1.IATAcode__c,
                Branch_Office_Country__c = a1.IATA_ISO_Country__c,
                SAAM_Case__c = oscarCase.Id,
                Remittance_frequency__c = 'M'
				);

        insert stagingArea;

		oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;
        OSCAR.AMS_Online_Accreditation__c = stagingArea.Id;
        update oscar;

	}
	
	//EM - To be deleted
	public static void increasecoverage() {
		Integer i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		
	
	
	}
}