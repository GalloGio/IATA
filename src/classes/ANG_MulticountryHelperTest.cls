@isTest
private class ANG_MulticountryHelperTest {	

	@testSetup static void setup(){

		Test.startTest();

		AMS_Settlement_System__c bspPT = new AMS_Settlement_System__c(
			Name = 'BSP-PT',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);

		AMS_Settlement_System__c bspGB = new AMS_Settlement_System__c(
			Name = 'BSP-GB',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);

		AMS_Settlement_System__c bspFR = new AMS_Settlement_System__c(
			Name = 'BSP-FR',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);

		insert new List<AMS_Settlement_System__c>{bspPT, bspGB, bspFR};

		IATA_ISO_Country__c countryPT = new IATA_ISO_Country__c();
		
		countryPT.Name = 'Portugal';
		countryPT.ISO_Code__c = 'PT';
		countryPT.ANG_Enable_NewGen__c = true;
		countryPT.AMS_Settlement_System__c = bspPT.Id;

		IATA_ISO_Country__c countryUK = new IATA_ISO_Country__c();
		
		countryUK.Name = 'United Kingdom';
		countryUK.ISO_Code__c = 'GB';
		countryUK.ANG_Enable_NewGen__c = true;
		countryUK.AMS_Settlement_System__c = bspGB.Id;

		IATA_ISO_Country__c countryFR = new IATA_ISO_Country__c();
		
		countryFR.Name = 'France';
		countryFR.ISO_Code__c = 'FR';
		countryFR.ANG_Enable_NewGen__c = true;
		countryFR.AMS_Settlement_System__c = bspFR.Id;

		insert new List<IATA_ISO_Country__c>{countryPT, countryUK, countryFR};

		Id standardAcctRecId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Account accountGE = new Account();

		accountGE.Name = 'Multicountry GE PT';
		accountGE.Location_Type__c = AMS_Utils.GE;
		accountGE.Location_Class__c = 'P';
		accountGE.IATA_ISO_Country__c = countryPT.Id;
		accountGE.RecordTypeId = standardAcctRecId;

		insert accountGE;

		Account accountHE = new Account();
		accountHE.Name = 'Multicountry HE UK';
		accountHE.ParentId = accountGE.Id;
		accountHE.Location_Type__c = AMS_Utils.HE;
		accountHE.Location_Class__c = 'P';
		accountHE.IATA_ISO_Country__c = countryUK.Id;
		accountHE.RecordTypeId = standardAcctRecId;

		Account accountAE = new Account();
		accountAE.Name = 'Multicountry AE PT';
		accountAE.ParentId = accountGE.Id;
		accountAE.Location_Type__c = AMS_Utils.AE;
		accountAE.Location_Class__c = 'P';
		accountAE.IATA_ISO_Country__c = countryPT.Id;
		accountAE.RecordTypeId = standardAcctRecId;

		insert new List<Account>{accountHE, accountAE};

		Test.stopTest();

	} 	

	@isTest static void allowIATACodeGenerationTest(){

		List<Account> accountLst = new List<Account>(
			[SELECT 
				Id 
			 FROM 
			 	Account 
			 WHERE 
			 	Name IN ('Multicountry HE UK', 'Multicountry GE PT')
			 ORDER BY
			 	Name ASC
			]
		);

		Account accountHE = accountLst.get(1);

		AMS_Oscar__c oscar = new AMS_OSCAR__c(
        	RecordTypeId = AMS_Utils.RECTYPE_MCAE,
        	Account__c = accountHE.Id
        );

        insert oscar;

        Case cse = new Case(
        	RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM, 
        	AccountId = accountHE.Id,
        	Oscar__c = oscar.Id
        );

        insert cse;

        Test.startTest();

        AMS_OSCAR__c oscarWithRels = [SELECT Account__c, Account__r.Parent.Status__c FROM AMS_OSCAR__c];

        Boolean allowIATACodeGeneration = ANG_MulticountryHelper.allowIATACodeGeneration(oscarWithRels);
       	
       	System.assert(!allowIATACodeGeneration, 'Should not allow the IATA code generation.');

       	Account accountGE = accountLst.get(0);

       	accountGE.Status__c = AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING;
       	accountGE.IATACode__c = '12345678';

       	update accountGE;

        Agency_Applied_Change_code__c changeCodeApplied = new Agency_Applied_Change_code__c(
        	Account__c = accountGE.Id, 
        	Change_Code__c = 'NEW', 
        	Sent_to_external_system__c = false
        );

        insert changeCodeApplied;

        oscarWithRels = [SELECT Account__c, Account__r.Parent.Status__c FROM AMS_OSCAR__c];

        allowIATACodeGeneration = ANG_MulticountryHelper.allowIATACodeGeneration(oscarWithRels);
       	
       	System.assert(allowIATACodeGeneration, 'Should allow the IATA code generation.');

       	Test.stopTest();

	}

	@isTest static void allowApprovalStepTest(){

		List<Account> accountLst = new List<Account>(
			[SELECT 
				Id 
			 FROM 
			 	Account 
			 WHERE 
			 	Name IN ('Multicountry AE PT', 'Multicountry GE PT')
			 ORDER BY
			 	Name ASC
			]
		);

		Account accountAE = accountLst.get(0);

        AMS_Oscar__c oscar = new AMS_OSCAR__c(
        	RecordTypeId = AMS_Utils.RECTYPE_MCAE,
        	Account__c = accountAE.Id
        );

        insert oscar;

        Case cse = new Case(
        	RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM, 
        	AccountId = accountAE.Id,
        	Oscar__c = oscar.Id
        );

        insert cse;

        Test.startTest();

        Boolean allowApproval = ANG_MulticountryHelper.allowApprovalStep(oscar);
       	
       	System.assert(!allowApproval, 'Should not allow the approval step.');

       	Account accountGE = accountLst.get(1);

        Agency_Applied_Change_code__c changeCodeApplied = new Agency_Applied_Change_code__c(
        	Account__c = accountGE.Id, 
        	Change_Code__c = 'FIN', 
        	Sent_to_external_system__c = false
        );

        insert changeCodeApplied;

        allowApproval = ANG_MulticountryHelper.allowApprovalStep(oscar);
       	
       	System.assert(allowApproval, 'Should allow the approval step.');

       	Test.stopTest();

	}

	@isTest static void multicountryAccountValidationsTest() {

		Id standardAcctRecId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		List<IATA_ISO_Country__c> countriesLst = new List<IATA_ISO_Country__c>(
			[SELECT 
				Id, 
				Name 
			 FROM 
				IATA_ISO_Country__c 
			 ORDER BY 
			 	Name ASC
			]
		);

		IATA_ISO_Country__c countryFR = countriesLst.get(0);
		IATA_ISO_Country__c countryPT = countriesLst.get(1);
		IATA_ISO_Country__c countryUK = countriesLst.get(2);

		List<Account> accountLst = new List<Account>(
			[SELECT
				Id,
				IATA_ISO_Country__c
			 FROM
			 	Account
			 WHERE
			 	Name IN ('Multicountry GE PT', 'Multicountry HE UK')
			 ORDER BY
			 	Name ASC
			]
		);

		Account accountGE = accountLst.get(0);
		Account accountHE = accountLst.get(1);
		
        Test.startTest();

        Account HESameGEBSPCountry = new Account(
        	Name = 'Trigger HE same bsp than GE',
        	RecordTypeId = standardAcctRecId,
            IATA_ISO_Country__c = accountGE.IATA_ISO_Country__c,
            Location_Type__c = AMS_Utils.HE,
            Location_Class__c = 'P',
            ANG_Accreditation_Model__c = 'Multicountry',
            ParentId = accountGE.Id
        );
        
        try{
        	insert HESameGEBSPCountry;
        }
        catch(Exception e){
        	Boolean expectedExceptionThrown = e.getMessage().contains(Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_AE_Error);
        	System.assert(expectedExceptionThrown, 'Should throw \'' + Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_AE_Error + '\'.');
        }

        Account HESameCountry = new Account(
        	Name = 'Validation trigger same HE',
        	RecordTypeId = standardAcctRecId,
            IATA_ISO_Country__c = countryUK.Id,
            Location_Type__c = AMS_Utils.HE,
            Location_Class__c = 'P',
            ANG_Accreditation_Model__c = 'Multicountry',
            ParentId = accountGE.Id
        );
        
        try{        
        	insert HESameCountry;
        }
        catch(Exception e){
           	Boolean expectedExceptionThrown =  e.getMessage().contains(Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_AE_With_Correct_HE_Error);
        	System.assert(expectedExceptionThrown, 'Should throw \'' + Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_AE_With_Correct_HE_Error + '\'.');
		} 
        
        Account AECountry = new Account(
        	Name = 'Validation trigger AE with no HE',
            IATA_ISO_Country__c = countryFR.Id,
            Location_Type__c = AMS_Utils.AE,
            Location_Class__c = 'P',
            ANG_Accreditation_Model__c = 'Multicountry',
            ParentId = accountGE.Id
        );
        
        try{       
        	insert AECountry;
        }
        catch(Exception e){
        	Boolean expectedExceptionThrown =  e.getMessage().contains(Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_HE_Error);
        	System.assert(expectedExceptionThrown, 'Should throw \'' + Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_HE_Error + '\'.');
		}

		accountHE.IATA_ISO_Country__c = countryPT.id;

		try{   
        	update accountHE;
        }
        catch(Exception e){
        	Boolean expectedExceptionThrown = e.getMessage().contains(Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_AE_Error);
        	System.assert(expectedExceptionThrown, 'Should throw \'' + Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_AE_Error + '\'.');
        }

        Test.stopTest();

    }


    @isTest static void testmulticountryAccountHasRemittenceFrequencyEmpty() {

    	List<Account> accountLst = new List<Account>(
			[SELECT Id 
			 FROM  	Account 
			 WHERE  Name IN ('Multicountry HE UK')
			 ORDER BY Name ASC
			]);

		Account accountHE = accountLst.get(0);

		AMS_Oscar__c oscar = new AMS_OSCAR__c(
        	RecordTypeId = AMS_Utils.RECTYPE_MCAE,
        	Account__c = accountHE.Id,
        	Process__c = AMS_Utils.MCAE
        );

        insert oscar;

		Case cse = new Case(
        	RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM, 
        	AccountId = accountHE.Id,
        	Oscar__c = oscar.Id
        );

        insert cse;

		AMS_Pax_Accreditation_Form__c paxAccreditation = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.Id);
		insert paxAccreditation; 

		oscar.AMS_Online_Accreditation__c = paxAccreditation.id;
		update oscar;

		AMS_Oscar__c oscar2 = [SELECT Id, Account__c, Process__c, Location_Type__c, AMS_Online_Accreditation__c 
								FROM AMS_Oscar__c WHERE Account__c = : accountHE.Id limit 1];

		Test.startTest();

		Boolean hasRF = ANG_MulticountryHelper.multicountryAccountHasRemittenceFrequencyEmpty(oscar2);

    	Test.stopTest();
    	
    	//Has empty Remittance Frequency 
    	System.assert(hasRF); 

    }

	@isTest static void cloneOwnersFromParentAccountTest() {

		List<Account> accountLst = new List<Account>(
			[SELECT 
				Id , ParentId, Name
			 FROM 
			 	Account 
			 WHERE 
			 	Name IN ('Multicountry HE UK', 'Multicountry GE PT')
			 ORDER BY
			 	Name ASC
			]
		);

		Account accountGE = accountLst.get(1).Name == 'Multicountry GE PT' ? accountLst.get(1) : accountLst.get(0);
		Account accountAE = accountLst.get(1).Name == 'Multicountry GE PT' ? accountLst.get(0) : accountLst.get(1);

		AMS_Oscar__c oscar = new AMS_OSCAR__c(
        	RecordTypeId = AMS_Utils.RECTYPE_MCAE,
        	Account__c = accountGE.Id
        );

        insert oscar;

        Case cse = new Case(
        	RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM, 
        	AccountId = accountGE.Id,
        	Oscar__c = oscar.Id
        );

        insert cse;

		AMS_Pax_Accreditation_Form__c onlineAccreditation  = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No', SAAM_Case__c = cse.Id, Account_Name__c = accountGE.Name);
        insert onlineAccreditation;

		System.assertEquals('The Parent Account could not be found.',ANG_MulticountryHelper.cloneOwnersFromParentAccount(onlineAccreditation.Id),'Expecting: The Parent Account could not be found.');

        Contact c1 = new Contact(AccountId = accountGE.id, Firstname = 'firstNAme', Lastname='LastNAme', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert c1;

        Id ownerRtId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
        
        AMS_Account_Role__c accountRole = new AMS_Account_Role__c(recordTypeId = ownerRtId, Account__c = accountGE.Id, Person__c = null, Contact__c = c1.Id, Percentage__c=100.0);
        insert accountRole;

		Test.startTest();

        Contact c2 = new Contact(AccountId = accountAE.id, Firstname = 'firstNAme', Lastname='LastNAme', Phone = '911111111', MobilePhone = '911111111', Email = 'test2@test.com', Financial_Assessment_Contact__c = false);
		insert c2;
        
        AMS_Account_Role__c accountRoleAE = new AMS_Account_Role__c(recordTypeId = ownerRtId, Account__c = accountAE.Id, Person__c = null, Contact__c = c1.Id, Percentage__c=100.0);
        insert accountRoleAE;

		//for the AE
		AMS_Oscar__c oscarAE = new AMS_OSCAR__c(
        	RecordTypeId = AMS_Utils.RECTYPE_MCAE,
        	Account__c = accountAE.Id
        );

        insert oscarAE;

        Case cseAE = new Case(
        	RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM, 
        	AccountId = accountAE.Id,
        	Oscar__c = oscarAE.Id
        );

        insert cseAE;

		AMS_Pax_Accreditation_Form__c onlineAccreditationAE  = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No', SAAM_Case__c = cseAE.Id, Account_Name__c = accountAE.Name);
        insert onlineAccreditationAE;

		String result = ANG_MulticountryHelper.cloneOwnersFromParentAccount(onlineAccreditationAE.Id);

		System.assert(result == null);
		System.assertEquals(1,[Select Id from AMS_Accreditation_Contact__c].size(),'The expected size is 1.');
		System.assertEquals('You must provide a valid Online Accreditation Form Id.',ANG_MulticountryHelper.cloneOwnersFromParentAccount(null),'Expecting: You must provide a valid Online Accreditation Form Id.');
		Test.stopTest();

	}
}
