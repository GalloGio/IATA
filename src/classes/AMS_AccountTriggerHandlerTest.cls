@isTest
private class AMS_AccountTriggerHandlerTest {
	
	@testSetup static void setup(){

		List<Account> acctsToInsert = new List<Account>();

		Account acc1 = new Account();
		acc1.Name = 'HO Account 1';
		acc1.Type = 'IATA Cargo Agent';
		acc1.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') ;

		insert acc1;

		Account acc2 = new Account();
		acc2.Name = 'BR Account 2';
		acc2.Type = 'IATA Cargo Agent';
		acc2.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') ;
		acc2.ParentId = acc1.Id;
		acc2.Sector__c = 'Cargo Agent';
		acc2.REASON_FOR_CREATION__C = 'Created by customer';
		
		Account acc3 = new Account();
		acc3.Name = 'BR Account 3';
		acc3.Type = 'IATA Cargo Agent';
		acc3.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') ;
		acc3.ParentId = acc1.Id;
		acc3.Sector__c = 'Cargo Agent';
		acc3.REASON_FOR_CREATION__C = 'Created by customer';
	   
		Account acc4 = new Account();
		acc4.Name = 'BR Account 4';
		acc4.Type = 'IATA Cargo Agent';
		acc4.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') ;
		acc4.ParentId = acc1.Id;
		acc4.Sector__c = 'Cargo Agent';
		acc4.REASON_FOR_CREATION__C = 'Created by customer';
		
		// different set

		Account acc1d = new Account();
		acc1d.Name = 'HO Account Diff 1';
		acc1d.Type = 'IATA Cargo Agent';
		acc1d.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') ;
		
		insert acc1d;
		
		Account acc2d = new Account();
		acc2d.Name = 'BR Account Diff 2';
		acc2d.Type = 'IATA Cargo Agent';
		acc2d.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') ;
		acc2d.ParentId = acc1d.Id;
		acc2d.Sector__c = 'Cargo Agent';
		acc2d.REASON_FOR_CREATION__C = 'Created by customer';

		Account acc3d = new Account();
		acc3d.Name = 'BR Account Diff 3';
		acc3d.Type = 'IATA Cargo Agent';
		acc3d.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') ;
		acc3d.ParentId = acc1d.Id;
		acc3d.Sector__c = 'Cargo Agent';
		acc3d.REASON_FOR_CREATION__C = 'Created by customer';

		Account acc4d = new Account();
		acc4d.Name = 'BR Account Diff 4';
		acc4d.Type = 'IATA Cargo Agent';
		acc4d.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') ;
		acc4d.ParentId = acc1d.Id;
		acc4d.Sector__c = 'Cargo Agent';
		acc4d.REASON_FOR_CREATION__C = 'Created by customer';

		acctsToInsert.add(acc2);
		acctsToInsert.add(acc3);
		acctsToInsert.add(acc4);

		acctsToInsert.add(acc2d);
		acctsToInsert.add(acc3d);
		acctsToInsert.add(acc4d);

		insert acctsToInsert;

		// now for the hierarchies

		List<AMS_Agencies_Hierarchy__c> hierarchiesToInsert = new List<AMS_Agencies_Hierarchy__c>();

		AMS_Agencies_Hierarchy__c ah1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');
		
		AMS_Agencies_Hierarchy__c ah2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 2');

		hierarchiesToInsert.add(ah1);
		hierarchiesToInsert.add(ah2);

		insert hierarchiesToInsert;

		AMS_Agencies_relationhip__c ar1 = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah1.id,Child_Account__c=acc2.id,Parent_Account__c=acc1.id);
		AMS_Agencies_relationhip__c ar2 = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah1.id,Child_Account__c=acc3.id,Parent_Account__c=acc1.id);
		AMS_Agencies_relationhip__c ar3 = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah1.id,Child_Account__c=acc4.id,Parent_Account__c=acc1.id);

		AMS_Agencies_relationhip__c ar1d = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah2.id,Child_Account__c=acc2d.id,Parent_Account__c=acc1d.id);
		AMS_Agencies_relationhip__c ar2d = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah2.id,Child_Account__c=acc3d.id,Parent_Account__c=acc1d.id);
		AMS_Agencies_relationhip__c ar3d = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah2.id,Child_Account__c=acc4d.id,Parent_Account__c=acc1d.id);

		List<AMS_Agencies_relationhip__c> rels = new List<AMS_Agencies_relationhip__c>();

		rels.add(ar1);
		rels.add(ar2);
		rels.add(ar3);

		rels.add(ar1d);
		rels.add(ar2d);
		rels.add(ar3d);     

		insert rels;
	}

	@isTest static void verifychangeCassNumberError() {
		
		Test.StartTest();

		Boolean exceptionVar = false;

		List<Account> accountListToUpdate = new List<Account>();

		List<Account> accountList = [SELECT Id, Name , Cass_Number__c, ParentId from Account];

		if(accountList.isEmpty())
			System.assertEquals(true,false);

		for(Account acc: accountList){

			System.debug('Analyzing Account name '+ acc.Name + ' that has cass number ' + acc.CASS_Number__c);

			if(acc.ParentId != null){
			
				System.assert(acc.Cass_Number__c != null);
			
				if(acc.CASS_Number__c == '001'){
					acc.CASS_Number__c = '002';
					System.debug('Account name '+ acc.Name + ' now has cass number ' + acc.CASS_Number__c);
					accountListToUpdate.add(acc);
				}else{
					System.debug('Account name '+ acc.Name + ' has not been updated because has cass number ' + acc.CASS_Number__c);
				}
			}else{
				System.debug('The Account name '+ acc.Name + ' does not have parent id ');
			}
		}

		if(!accountListToUpdate.isEmpty()){
			try{
				update accountListToUpdate;
			}catch(Exception e){
				System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
				System.Assert(e.getMessage().contains('already has an agency with that cass number'));
				exceptionVar = true;
			}
		}
		else{
			System.assertEquals(true,false);
		}

		System.assert(exceptionVar,true);
		
		Test.StopTest();
	}
	
	@isTest static void verifychangeCassNumberSuccess() {

		Test.StartTest();

		List<Account> accountListToUpdate = new List<Account>();

		List<Account> accountList = [SELECT Id, Name , Cass_Number__c, ParentId from Account];

		if(accountList.isEmpty())
			System.assertEquals(true,false);

		for(Account acc: accountList){

			if(acc.ParentId != null){
			
				System.assert(acc.Cass_Number__c != null);
			
				if(acc.CASS_Number__c == '001'){
					acc.CASS_Number__c = '002';
					accountListToUpdate.add(acc);
				}else{
					if(acc.CASS_Number__c == '002'){
						acc.CASS_Number__c = '001';
						accountListToUpdate.add(acc);
					}
				}
			}
		}

		if(!accountListToUpdate.isEmpty()){
			update accountListToUpdate;
		}
		else{
			System.assertEquals(true,false);
		}
		
		Test.StopTest();
	}

	//Test the trigger trgAccount
	static testMethod void test_trgAccount() {
		IECTestUtil.bIgnoreCurrentUserProfile = true;
		Account acc1 = new Account();
		acc1.Name = 'HO Account 1';
		acc1.Type = 'IATA Cargo Agent';
		acc1.WebStar_ID__c = 'Some Test';
		acc1.Is_your_firm_handling_Dangerous_Goods__c = 'No';
		acc1.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		try{
			insert acc1;
		}catch(Exception e){
			System.assert(e.getMessage().contains(Label.Cannot_Update_AIMS_values));	

			IECTestUtil.bIgnoreCurrentUserProfile = false;	
			insert acc1;	
		}

		IECTestUtil.bIgnoreCurrentUserProfile = true;
		AMS_Agency_Regulation__c certificate1 = new AMS_Agency_Regulation__c(Last_Name__c = 'test1', Account__c = acc1.Id, Expiry_Date__c = Date.today().addDays(365), Type_of_Certificate__c = 'DGR', Is_your_firm_handling_Dangerous_Goods__c = 'No');
		insert certificate1;
		acc1.Reason_for_creation__c = 'Account is missing';
		acc1.Last_Modified_by_Source__c = System.now();
		acc1.Sector__c = AMS_Utils.SECTOR_CARGO;
		acc1.Is_your_firm_handling_Dangerous_Goods__c = 'Yes';
		update acc1;
	}

	static testMethod void test_irregularityCheck() {
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry;

        AMS_Country_Specific_Attribute__c irrThsd = new AMS_Country_Specific_Attribute__c(IATA_ISO_Country__c = ctry.Id, Location_Class__c = 'Test', Threshold__c = 1, 
        												RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Irregularity_Threshold'));
        insert irrThsd;

        Account a = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account'), Name='Test Agency', IATAcode__c = '1234567', Location_Class__c = 'Test');
        insert a;

        Test.startTest();

        	Agency_Applied_Change_code__c irr = new Agency_Applied_Change_code__c(Account__c = a.Id, 
        											RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Applied_Change_code__c', 'Irregularities'), 
        											Change_Code__c = 'IRR', Operation__c = 'A', Irregularities_Points__c = 1, Irregularities_Expired__c = false);
        	insert irr;

        	Account aAssert = [SELECT Id, Count_Accumulated_Irregularities__c, SUM_A_Irregularities__c, SUM_W_Irregularities__c FROM Account WHERE Id = :a.Id];
        	//System.assertEquals(1, aAssert.Count_Accumulated_Irregularities__c);

        Test.stopTest();
	}

	static testMethod void test_DDcheck() {
		
		/*IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
		insert ctry;*/

		Account a = new Account(RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account'), 
								Name='Test Agency', IATAcode__c = '1234567', Location_Class__c = 'Test');
		insert a;

		insert new AMS_Oscar__c(Account__c = a.Id, Status__c = 'Open');

		Test.startTest();

		a.Due_Diligence_Status__c = 'Cleared';
		update a;

		Test.stopTest();

		System.assertEquals('Passed', [SELECT Id, STEP17__c FROM AMS_OSCAR__c LIMIT 1].STEP17__c);
	}

	static testMethod void test_ICC_01() {
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(
			Name = 'Portugal',
			ISO_Code__c = 'PT',
			AIMS_Area_Name__c = 'Lisboa',
			OSCAR_enabled__c = true,
			CNS_Country__c = true
		);

		IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(
			Name = 'Spain',
			ISO_Code__c = 'SP',
			AIMS_Area_Name__c = 'Madrid',
			OSCAR_enabled__c = true
		);

		insert country;
		insert country2;

		Account account = new Account(
			Name = 'Test Account',
			Type = 'IATA Cargo Agent',
			Cass_Number__c = '000',
			Sector__c = AMS_Utils.SECTOR_CARGO,
			IATA_ISO_Country__c = country.Id,
			IATACode__c = '001',
			Accreditation_date__c = System.today(),
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
			phone = '00351218145439'
		);

		Account account2 = new Account(
			Name = 'Test Account',
			Type = 'IATA Cargo Agent',
			Cass_Number__c = null,
			Sector__c = AMS_Utils.SECTOR_CARGO,
			Location_Type__c = 'HO',
			IATA_ISO_Country__c = country.Id,
			IATACode__c = '001',
			Accreditation_date__c = System.today(),
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
			phone = '00351218145439'
		);

		insert account;
		insert account2;

		Agency_Applied_Change_code__c aacc = new Agency_Applied_Change_code__c(
			Reason_Code__c = '',
			Reason_Description__c = '',
			Account__c = account.id,
			Active__c = true
		);

		insert aacc;

		account.Cass_Number__c = '999';
		account.IATA_ISO_Country__c = country2.Id;

		update account;

		account.phone = '00351218145439';

		update account;

		Boolean bool = AMS_AccountTriggerHandler.verifyFieldChanges(account, account2);
	}
	
	static testMethod void test_MulticountryValidations() {

		Id settlementRTId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Settlement_System__c', 'BSP');

		AMS_Settlement_System__c settlement = new AMS_Settlement_System__c(
			Name = 'test settlement',
			RecordTypeId = settlementRTId
		);

        AMS_Settlement_System__c settlement2 = new AMS_Settlement_System__c(
			Name = 'test settlement2',
			RecordTypeId = settlementRTId
		);

		insert new List<AMS_Settlement_System__c>{settlement, settlement2};
        
        IATA_ISO_Country__c country1 = new IATA_ISO_Country__c(
			Name = 'Test Country',
			ISO_Code__c = 'TC',
			AIMS_Area_Name__c = 'Test City',
			OSCAR_enabled__c = true,
			Multicountry_Enabled__c = true,
            ANG_Enable_NewGen__c = true,
            AMS_Settlement_System__c = settlement.id
		);

  		IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(
			Name = 'Test Country 2',
			ISO_Code__c = 'ZZ',
			AIMS_Area_Name__c = 'Test City2',
			OSCAR_enabled__c = true,
			Multicountry_Enabled__c = true,
            ANG_Enable_NewGen__c = true
		);
        
		IATA_ISO_Country__c country3 = new IATA_ISO_Country__c(
			Name = 'Test Country 3',
			ISO_Code__c = 'TS',
			AIMS_Area_Name__c = 'Test City 3',
			OSCAR_enabled__c = true,
			Multicountry_Enabled__c = true,
            ANG_Enable_NewGen__c = true,
            AMS_Settlement_System__c = settlement2.id
		);

        insert new List<IATA_ISO_Country__c>{country1, country2, country3};
        
        Account topGEParent = new Account(
        	Name = 'trigger GE',
            IATA_ISO_Country__c = country1.Id,
            Location_Type__c = 'GE',
            Location_Class__c = 'P',
            ANG_Accreditation_Model__c = 'Multicountry'
        );

        insert topGEParent;
        
        Test.startTest();

        Account HESameGEBSPCountry = new Account(
        	Name = 'trigger HE same bsp than GE',
            IATA_ISO_Country__c = country1.Id,
            Location_Type__c = 'HE',
            Location_Class__c = 'P',
            ANG_Accreditation_Model__c = 'Multicountry',
            ParentId = topGEParent.Id
        );
        
        try{
        	insert HESameGEBSPCountry;
        }
        catch(Exception e){

        	Boolean expectedExceptionThrown = e.getMessage().contains(Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_AE_Error);

        	System.AssertEquals(expectedExceptionThrown, true);
        }

		Account HECountry = new Account(
			Name = 'trigger HE',
			IATA_ISO_Country__c = country3.Id,
            Location_Type__c = 'HE',
            Location_Class__c = 'P',
            ANG_Accreditation_Model__c = 'Multicountry',
            ParentId = topGEParent.Id
        );
        
        insert HEcountry;
 
        Account HESameCountry = new Account(
        	Name = 'Validation trigger same HE ',
            IATA_ISO_Country__c = country3.Id,
            Location_Type__c = 'HE',
            Location_Class__c = 'P',
            ANG_Accreditation_Model__c = 'Multicountry',
            ParentId = topGEParent.Id
        );
        
        try{        
        	insert HESameCountry;
        }
        catch(Exception e){
           	Boolean expectedExceptionThrown =  e.getMessage().contains(Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_AE_With_Correct_HE_Error);
        
        	System.AssertEquals(expectedExceptionThrown, true);
		} 
        
        Account AECountry = new Account(
        	Name = 'Validation trigger AE with no HE',
            IATA_ISO_Country__c = country2.Id,
            Location_Type__c = 'AE',
            Location_Class__c = 'P',
            ANG_Accreditation_Model__c = 'Multicountry',
            ParentId = topGEParent.Id
        );
        
        try{       
        	insert AECountry;
        }
        catch(Exception e){
        
        	Boolean expectedExceptionThrown =  e.getMessage().contains(Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_HE_Error);
        
        	System.AssertEquals(expectedExceptionThrown, true);
		}

		//Test Before Update 
		HECountry.IATA_ISO_Country__c = country1.id;
		try{   
        	update HECountry;
        }
        catch(Exception e){

        	Boolean expectedExceptionThrown = e.getMessage().contains(Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_AE_Error);

        	System.AssertEquals(expectedExceptionThrown, true);
        }

        Test.stopTest();

    }
}