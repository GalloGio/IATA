@isTest
public class ANG_AgencyChangesHelperTest {

	 @testSetup static void testSetup(){
		

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);
        insert stt;
		
		Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

		Account account = new Account();
		account.Name = 'Main HE Account H1';
		account.Sector__c = 'Travel Agent';
		account.IATACode__c = '12345678';
		account.Category__c = 'IATA Passenger Sales Agent';
		account.Location_Class__c = 'P';
		account.Location_Type__c = 'HE';

		account.ANG_IEP_HE_AccntNum__c = '1232132323';
		account.ANG_IEP_Status__c = 'Suspended' ;
		account.ANG_HE_CashCondition__c = true;
		account.ANG_HE_RiskHistoryAssessment__c = 'Not Applicable';
		account.ANG_HE_RiskStatus__c = 'Not Applicable';
		account.RecordTypeId = accountAgencyRT;
		account.ANG_Accreditation_Model__c = 'Cashless';

		insert account;
		
		List<Account> accountList = new List<Account>();
		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, ANG_IEP_Status__c = null, ANG_Accreditation_Model__c = 'Cashless' ,RecordTypeId = accountAgencyRT, IATACode__c='12345671',Name='Account AE1 H1',Short_Name__c='Account AE1 H1',Category__c = 'IATA Passenger Sales Agent',Location_Class__c = 'P',Location_Type__c = 'AE', ParentId = account.Id);
		Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ANG_IEP_Status__c = null, ANG_Accreditation_Model__c = 'Cashless' , RecordTypeId = accountAgencyRT, IATACode__c='12345672',Name='Account AE2 H1',Short_Name__c='Account AE2 H1',Category__c = 'IATA Passenger Sales Agent',Location_Class__c = 'P',Location_Type__c = 'AE', ParentId = account.Id);
		Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ANG_IEP_Status__c = null, ANG_Accreditation_Model__c = 'Cashless' , RecordTypeId = accountAgencyRT, IATACode__c='12345673',Name='Account AE3 H1',Short_Name__c='Account AE3 H1',Category__c = 'IATA Passenger Sales Agent',Location_Class__c = 'P',Location_Type__c = 'AE', ParentId = account.Id);
		
		accountList.add(a1);
		accountList.add(a2);
		accountList.add(a3);

		insert accountList;

		AMS_Agencies_Hierarchy__c h = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Newgen Hierarchy (old)');
		insert h;

		AMS_Agencies_relationhip__c r1 = new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true, Child_Account__c = a1.Id , Parent_Account__c = account.Id, Hierarchy__c = h.Id);
		AMS_Agencies_relationhip__c r2 = new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true, Child_Account__c = a2.Id , Parent_Account__c = account.Id, Hierarchy__c = h.Id);
		AMS_Agencies_relationhip__c r3 = new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true, Child_Account__c = a3.Id , Parent_Account__c = account.Id, Hierarchy__c = h.Id);

		insert new List<AMS_Agencies_relationhip__c>{r1,r2,r3};

	}


	@isTest static void performChangeOfLocationType(){

		Test.startTest();

		Account a1 = [Select Id, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE1 H1'];

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = a1.id);
		insert oscar;

		Map<string, Id> caseRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case');

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		String OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

        ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfLocationType(oscar,null);

        List<AMS_Agencies_relationhip__c> relationsMap = struct.relationsMap.values();
		List<Account> accountsMap = struct.accountsMap.values();

		upsert relationsMap;
		upsert accountsMap;
/*
		ID rtAgencyInvolved = Schema.SObjectType.AMS_Process_Detail__c.getRecordTypeInfosByName().get('Agency Involved').getRecordTypeId();

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = BR1.Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = BR2.Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = BR3.Id));
		
		insert agenciesinvolved;
*/

		List<AMS_Agencies_Hierarchy__c> hierarchies =  [Select Id from AMS_Agencies_Hierarchy__c];
		
		System.assertEquals(1,hierarchies.size());

		For(Account a: [Select Id, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account]){

			if(a.Id == a1.Id){

				System.assertEquals('HE', a.Location_Type__c);
				System.assertEquals(null, a.ANG_IEP_HE_AccntNum__c);
				System.assertEquals('No IEP Account', a.ANG_IEP_Status__c);
				System.assertEquals(true, a.ANG_HE_CashCondition__c);
				System.assertEquals('Not Applicable', a.ANG_HE_RiskHistoryAssessment__c);
				System.assertEquals('Not Applicable', a.ANG_HE_RiskStatus__c);

			}else{
				System.assertEquals('AE', a.Location_Type__c);
				System.assertEquals(null, a.ANG_IEP_HE_AccntNum__c);
				System.assertEquals(null, a.ANG_IEP_Status__c);
				System.assertEquals(false, a.ANG_HE_CashCondition__c);
				System.assertEquals(null, a.ANG_HE_RiskHistoryAssessment__c);
				System.assertEquals(null, a.ANG_HE_RiskStatus__c);
			}
		}

		For( AMS_Agencies_relationhip__c rel :[Select Id, Parent_Account__c, Child_Account__r.ParentId, Parent_Account__r.ParentId, Child_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.Location_Type__c from AMS_Agencies_relationhip__c]){

			System.assertEquals(rel.Child_Account__r.ParentId , rel.Parent_Account__c);
			System.assertEquals('AE',rel.Child_Account__r.Location_Type__c);
			System.assertEquals('HE',rel.Parent_Account__r.Location_Type__c );

		}

        Test.stopTest();

	}

	@isTest static void performChangeOfHierarchyScenario1(){

		// push a subset of agencies and creating a new brand new hierarchy (scenario 1)

		Test.startTest();

		AMS_Agencies_Hierarchy__c originalHierarchy =  [Select Id from AMS_Agencies_Hierarchy__c];

		Account a1 = [Select Id, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE1 H1'];
		Account he1 = [Select Id, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Main HE Account H1'];

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = a1.id, New_parent__c = a1.id);
		insert oscar;

		Map<string, Id> caseRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case');

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		String OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		List<Account> accounts = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE2 H1'];

        ID rtAgencyInvolved = Schema.SObjectType.AMS_Process_Detail__c.getRecordTypeInfosByName().get('Agency Involved').getRecordTypeId();

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts.get(0).Id));
		
		insert agenciesinvolved;

		// let's start !!

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfHierarchy(oscar,null,accountIdsInvolvedSet);

        List<AMS_Agencies_relationhip__c> relationsMap = struct.relationsMap.values();
		List<Account> accountsMap = struct.accountsMap.values();

		System.debug('Accounts to update:'+accountsMap);

		upsert relationsMap;
		upsert accountsMap;


		List<AMS_Agencies_Hierarchy__c> hierarchies =  [Select Id, Hierarchy_Name__c from AMS_Agencies_Hierarchy__c];
		List<Account> accountsToCheck = [Select Id, Name, ANG_Accreditation_Model__c ,ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account];
		List<AMS_Agencies_relationhip__c> relsToCheck = [Select Id, Hierarchy__r.Hierarchy_Name__c, Child_Account__r.Name, Parent_Account__r.Name, Parent_Account__c, Child_Account__r.ParentId, Parent_Account__r.ParentId, Child_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.Location_Type__c from AMS_Agencies_relationhip__c];
		
		System.debug('[performChangeOfLocationTypeScenario1]- Accounts are:'+accountsToCheck);
		System.debug('[performChangeOfLocationTypeScenario1]- Relations are:'+relsToCheck);
		System.debug('[performChangeOfLocationTypeScenario1]- Hierarchies are:'+hierarchies);
		
		System.assertEquals(2,hierarchies.size());
		System.assertEquals(2,relsToCheck.size());

		For(Account a: accountsToCheck){
			
			System.debug('[performChangeOfLocationTypeScenario1]-Processing account:'+a);

			if(a.Id == a1.Id || a.Name == 'Main HE Account H1'){

				System.assertEquals('HE', a.Location_Type__c);

				if(a.Id == a1.Id){
					System.assertEquals(null, a.ANG_IEP_HE_AccntNum__c);
					System.assertEquals('No IEP Account', a.ANG_IEP_Status__c);
					System.assertEquals(false, a.ANG_HE_CashCondition__c);
					System.assertEquals(null, a.ANG_HE_RiskHistoryAssessment__c);
					System.assertEquals('Not Applicable', a.ANG_HE_RiskStatus__c);
				}else{ // the old and still HE
					System.assertEquals(true, a.ANG_HE_CashCondition__c);
					System.assertEquals('1232132323', a.ANG_IEP_HE_AccntNum__c);
					System.assertEquals('Suspended', a.ANG_IEP_Status__c);
					System.assertEquals('Cashless', a.ANG_Accreditation_Model__c);
				}
			}else{
				System.assertEquals('AE', a.Location_Type__c);
				System.assertEquals(null, a.ANG_IEP_HE_AccntNum__c);
				System.assertEquals(null, a.ANG_IEP_Status__c);
				System.assertEquals(false, a.ANG_HE_CashCondition__c);
				System.assertEquals(null, a.ANG_HE_RiskHistoryAssessment__c);
				System.assertEquals(null, a.ANG_HE_RiskStatus__c);
			}
		}

		For( AMS_Agencies_relationhip__c rel :relsToCheck){


			if(rel.Hierarchy__r.Hierarchy_Name__c == 'Newgen Hierarchy (old)'){

				System.assertEquals(rel.Child_Account__r.Name , 'Account AE3 H1');
				System.assertEquals(rel.Parent_Account__c , he1.Id);

			}else{

				System.assertEquals(rel.Child_Account__r.Name , 'Account AE2 H1');
				System.assertEquals(rel.Parent_Account__c , a1.Id);

			}
			
		}

		Integer parentAccountOriginal = 0;
		Integer parentAccountDestination = 0;
		Integer numberofAE = 0;
		Integer numberofHE = 0;

		For(account a: accountsToCheck){

			if(a.Location_Type__c == AMS_Utils.AE)
				numberofAE++;
			if(a.Location_Type__c == AMS_Utils.HE)
				numberofHE++;

			if(a.ParentId == he1.Id)
				parentAccountOriginal++;
			if(a.ParentId == a1.id)
				parentAccountDestination++;

		}

		System.assertEquals(2,numberofAE);
		System.assertEquals(2,numberofHE);
		System.assertEquals(1,parentAccountOriginal);
		System.assertEquals(1,parentAccountDestination);


		Test.stopTest();

	}

	@isTest static void performChangeOfHierarchyScenario2(){

		// push a subset of agencies and Moving them to a already existing hierarchy with one account

		Test.startTest();


		// creating existing hierarchy


		IATA_ISO_Country__c ctry = [Select Id from IATA_ISO_Country__c];

        IATA_ISO_State__c stt =[select id from  IATA_ISO_State__c];
		
		Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

		Account destinationAccount = new Account();
		destinationAccount.Name = 'Destination HE Account';
		destinationAccount.Sector__c = 'Travel Agent';
		destinationAccount.IATACode__c = '10045678';
		destinationAccount.Category__c = 'IATA Passenger Sales Agent';
		destinationAccount.Location_Class__c = 'P';
		destinationAccount.Location_Type__c = 'HE';

		destinationAccount.ANG_IEP_HE_AccntNum__c = '12324353454';
		destinationAccount.ANG_IEP_Status__c = 'Open' ;
		destinationAccount.ANG_HE_CashCondition__c = true;
		destinationAccount.ANG_HE_RiskHistoryAssessment__c = 'Not Applicable';
		destinationAccount.ANG_HE_RiskStatus__c = 'Not Applicable';
		destinationAccount.RecordTypeId = accountAgencyRT;
		destinationAccount.ANG_Accreditation_Model__c = 'Cashless';

		insert destinationAccount;



		Account childDestAccount = new Account(IATA_ISO_Country__c = ctry.id, ANG_IEP_Status__c = null, ANG_Accreditation_Model__c = 'Cashless' , RecordTypeId = accountAgencyRT, IATACode__c='12399973',Name='Account AE1 H2',Short_Name__c='Account AE1 H2',Category__c = 'IATA Passenger Sales Agent',Location_Class__c = 'P',Location_Type__c = 'AE', ParentId = destinationAccount.Id);
		
		insert childDestAccount;

		AMS_Agencies_Hierarchy__c destinationH = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Newgen Hierarchy (new)');
		insert destinationH;

		AMS_Agencies_relationhip__c r1 = new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true, Child_Account__c = childDestAccount.Id , Parent_Account__c = destinationAccount.Id, Hierarchy__c = destinationH.Id);

		insert r1;

		Account a1 = [Select Id, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE1 H1'];
		Account he1 = [Select Id, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Main HE Account H1'];

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = a1.id, New_parent__c = destinationAccount.id);
		insert oscar;

		Map<string, Id> caseRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case');

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		String OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		List<Account> accounts = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE2 H1'];

        ID rtAgencyInvolved = Schema.SObjectType.AMS_Process_Detail__c.getRecordTypeInfosByName().get('Agency Involved').getRecordTypeId();

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts.get(0).Id));
		
		insert agenciesinvolved;

		// let's start !!

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfHierarchy(oscar,null,accountIdsInvolvedSet);

        List<AMS_Agencies_relationhip__c> relationsMap = struct.relationsMap.values();
		List<Account> accountsMap = struct.accountsMap.values();

		System.debug('Accounts to update:'+accountsMap);

		upsert relationsMap;
		upsert accountsMap;

		List<AMS_Agencies_Hierarchy__c> hierarchies =  [Select Id, Hierarchy_Name__c from AMS_Agencies_Hierarchy__c];
		List<Account> accountsToCheck = [Select Id, Name, ANG_Accreditation_Model__c ,ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account];
		List<AMS_Agencies_relationhip__c> relsToCheck = [Select Id, Hierarchy__r.Hierarchy_Name__c, Child_Account__r.Name, Parent_Account__r.Name, Parent_Account__c, Child_Account__r.ParentId, Parent_Account__r.ParentId, Child_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.Location_Type__c from AMS_Agencies_relationhip__c];
		
		System.debug('[performChangeOfLocationTypeScenario1]- Accounts are:'+accountsToCheck);
		System.debug('[performChangeOfLocationTypeScenario1]- Relations are:'+relsToCheck);
		System.debug('[performChangeOfLocationTypeScenario1]- Hierarchies are:'+hierarchies);
		
		System.assertEquals(2,hierarchies.size());
		System.assertEquals(4,relsToCheck.size());

		Integer parentAccountOriginal = 0;
		Integer parentAccountDestination = 0;
		Integer numberofAE = 0;
		Integer numberofHE = 0;

		For(account a: accountsToCheck){

			if(a.Location_Type__c == AMS_Utils.AE)
				numberofAE++;
			if(a.Location_Type__c == AMS_Utils.HE)
				numberofHE++;

			if(a.ParentId == he1.Id)
				parentAccountOriginal++;
			if(a.ParentId == destinationAccount.id)
				parentAccountDestination++;

		}

		System.assertEquals(4,numberofAE);
		System.assertEquals(2,numberofHE);
		System.assertEquals(1,parentAccountOriginal);
		System.assertEquals(3,parentAccountDestination);


		Test.stopTest();

	}

	@isTest static void performChangeOfHierarchyScenario3(){

		// push a subset of agencies and Moving them to a new HE withouth hierarchy

		Test.startTest();


		// creating existing hierarchy


		IATA_ISO_Country__c ctry = [Select Id from IATA_ISO_Country__c];

        IATA_ISO_State__c stt =[select id from  IATA_ISO_State__c];
		
		Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

		Account destinationAccount = new Account();
		destinationAccount.Name = 'Destination HE Account';
		destinationAccount.Sector__c = 'Travel Agent';
		destinationAccount.IATACode__c = '10045678';
		destinationAccount.Category__c = 'IATA Passenger Sales Agent';
		destinationAccount.Location_Class__c = 'P';
		destinationAccount.Location_Type__c = 'HE';

		destinationAccount.ANG_IEP_HE_AccntNum__c = '12324353454';
		destinationAccount.ANG_IEP_Status__c = 'Open' ;
		destinationAccount.ANG_HE_CashCondition__c = true;
		destinationAccount.ANG_HE_RiskHistoryAssessment__c = 'Not Applicable';
		destinationAccount.ANG_HE_RiskStatus__c = 'Not Applicable';
		destinationAccount.RecordTypeId = accountAgencyRT;
		destinationAccount.ANG_Accreditation_Model__c = 'Cashless';

		insert destinationAccount;

		Account a1 = [Select Id, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE1 H1'];
		Account he1 = [Select Id, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Main HE Account H1'];

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = a1.id, New_parent__c = destinationAccount.id);
		insert oscar;

		Map<string, Id> caseRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case');

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		String OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		List<Account> accounts = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE2 H1'];
		List<Account> accounts2 = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE3 H1'];

        ID rtAgencyInvolved = Schema.SObjectType.AMS_Process_Detail__c.getRecordTypeInfosByName().get('Agency Involved').getRecordTypeId();

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts.get(0).Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts2.get(0).Id));
		
		insert agenciesinvolved;

		// let's start !!

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfHierarchy(oscar,null,accountIdsInvolvedSet);

        List<AMS_Agencies_relationhip__c> relationsMap = struct.relationsMap.values();
		List<Account> accountsMap = struct.accountsMap.values();

		System.debug('Accounts to update:'+accountsMap);

		upsert relationsMap;
		upsert accountsMap;

		List<AMS_Agencies_Hierarchy__c> hierarchies =  [Select Id, Hierarchy_Name__c from AMS_Agencies_Hierarchy__c];
		List<Account> accountsToCheck = [Select Id, Name, ANG_Accreditation_Model__c ,ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account];
		List<AMS_Agencies_relationhip__c> relsToCheck = [Select Id, Hierarchy__r.Hierarchy_Name__c, Child_Account__r.Name, Parent_Account__r.Name, Parent_Account__c, Child_Account__r.ParentId, Parent_Account__r.ParentId, Child_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.Location_Type__c from AMS_Agencies_relationhip__c];
		
		System.debug('[performChangeOfLocationTypeScenario1]- Accounts are:'+accountsToCheck);
		System.debug('[performChangeOfLocationTypeScenario1]- Relations are:'+relsToCheck);
		System.debug('[performChangeOfLocationTypeScenario1]- Hierarchies are:'+hierarchies);
		
		System.assertEquals(1,hierarchies.size());
		System.assertEquals(3,relsToCheck.size());

		Integer parentAccountOriginal = 0;
		Integer parentAccountDestination = 0;
		Integer numberofAE = 0;
		Integer numberofHE = 0;

		For(account a: accountsToCheck){

			if(a.Location_Type__c == AMS_Utils.AE)
				numberofAE++;
			if(a.Location_Type__c == AMS_Utils.HE)
				numberofHE++;

			if(a.ParentId == he1.Id)
				parentAccountOriginal++;
			if(a.ParentId == destinationAccount.id)
				parentAccountDestination++;

		}

		System.assertEquals(3,numberofAE);
		System.assertEquals(2,numberofHE);
		System.assertEquals(0,parentAccountOriginal);
		System.assertEquals(3,parentAccountDestination);


		Test.stopTest();

	}

	@isTest static void performChangeOfHierarchyScenario4(){

		// push all agencies and Moving them to a new HE withouth hierarchy

		Test.startTest();


		// creating existing hierarchy


		IATA_ISO_Country__c ctry = [Select Id from IATA_ISO_Country__c];

        IATA_ISO_State__c stt =[select id from  IATA_ISO_State__c];
		
		Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

		Account destinationAccount = new Account();
		destinationAccount.Name = 'Destination HE Account';
		destinationAccount.Sector__c = 'Travel Agent';
		destinationAccount.IATACode__c = '10045678';
		destinationAccount.Category__c = 'IATA Passenger Sales Agent';
		destinationAccount.Location_Class__c = 'P';
		destinationAccount.Location_Type__c = 'HE';

		destinationAccount.ANG_IEP_HE_AccntNum__c = '12324353454';
		destinationAccount.ANG_IEP_Status__c = 'Open' ;
		destinationAccount.ANG_HE_CashCondition__c = true;
		destinationAccount.ANG_HE_RiskHistoryAssessment__c = 'Not Applicable';
		destinationAccount.ANG_HE_RiskStatus__c = 'Not Applicable';
		destinationAccount.RecordTypeId = accountAgencyRT;
		destinationAccount.ANG_Accreditation_Model__c = 'Cashless';

		insert destinationAccount;

		Account a1 = [Select Id, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE1 H1'];
		Account he1 = [Select Id, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Main HE Account H1'];

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = a1.id, New_parent__c = destinationAccount.id);
		insert oscar;

		Map<string, Id> caseRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case');

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		String OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		List<Account> accounts = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE2 H1'];
		List<Account> accounts2 = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE3 H1'];

        ID rtAgencyInvolved = Schema.SObjectType.AMS_Process_Detail__c.getRecordTypeInfosByName().get('Agency Involved').getRecordTypeId();

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts.get(0).Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts2.get(0).Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = he1.Id));
		
		insert agenciesinvolved;

		// let's start !!

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfHierarchy(oscar,null,accountIdsInvolvedSet);

        List<AMS_Agencies_relationhip__c> relationsMap = struct.relationsMap.values();
		List<Account> accountsMap = struct.accountsMap.values();

		System.debug('Accounts to update:'+accountsMap);

		upsert relationsMap;
		upsert accountsMap;

		List<AMS_Agencies_Hierarchy__c> hierarchies =  [Select Id, Hierarchy_Name__c from AMS_Agencies_Hierarchy__c];
		List<Account> accountsToCheck = [Select Id, Name, ANG_Accreditation_Model__c ,ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account];
		List<AMS_Agencies_relationhip__c> relsToCheck = [Select Id, Hierarchy__r.Hierarchy_Name__c, Child_Account__r.Name, Parent_Account__r.Name, Parent_Account__c, Child_Account__r.ParentId, Parent_Account__r.ParentId, Child_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.Location_Type__c from AMS_Agencies_relationhip__c];
		
		System.debug('[performChangeOfLocationTypeScenario1]- Accounts are:'+accountsToCheck);
		System.debug('[performChangeOfLocationTypeScenario1]- Relations are:'+relsToCheck);
		System.debug('[performChangeOfLocationTypeScenario1]- Hierarchies are:'+hierarchies);
		
		System.assertEquals(1,hierarchies.size());
		System.assertEquals(4,relsToCheck.size());

		Integer parentAccountOriginal = 0;
		Integer parentAccountDestination = 0;
		Integer numberofAE = 0;
		Integer numberofHE = 0;

		For(account a: accountsToCheck){

			if(a.Location_Type__c == AMS_Utils.AE)
				numberofAE++;
			if(a.Location_Type__c == AMS_Utils.HE)
				numberofHE++;

			if(a.ParentId == he1.Id)
				parentAccountOriginal++;
			if(a.ParentId == destinationAccount.id)
				parentAccountDestination++;

		}

		System.assertEquals(4,numberofAE);
		System.assertEquals(1,numberofHE);
		System.assertEquals(0,parentAccountOriginal);
		System.assertEquals(4,parentAccountDestination);


		Test.stopTest();

	}

	@isTest static void performChangeOfHierarchyScenario5(){

		// push all agencies and Moving them to a new HE with an existing hierarchy

		Test.startTest();


		// creating existing hierarchy


		IATA_ISO_Country__c ctry = [Select Id from IATA_ISO_Country__c];

        IATA_ISO_State__c stt =[select id from  IATA_ISO_State__c];
		
		Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

		Account destinationAccount = new Account();
		destinationAccount.Name = 'Destination HE Account';
		destinationAccount.Sector__c = 'Travel Agent';
		destinationAccount.IATACode__c = '10045678';
		destinationAccount.Category__c = 'IATA Passenger Sales Agent';
		destinationAccount.Location_Class__c = 'P';
		destinationAccount.Location_Type__c = 'HE';

		destinationAccount.ANG_IEP_HE_AccntNum__c = '12324353454';
		destinationAccount.ANG_IEP_Status__c = 'Open' ;
		destinationAccount.ANG_HE_CashCondition__c = true;
		destinationAccount.ANG_HE_RiskHistoryAssessment__c = 'Not Applicable';
		destinationAccount.ANG_HE_RiskStatus__c = 'Not Applicable';
		destinationAccount.RecordTypeId = accountAgencyRT;
		destinationAccount.ANG_Accreditation_Model__c = 'Cashless';

		insert destinationAccount;

		Account childDestAccount = new Account(IATA_ISO_Country__c = ctry.id, ANG_IEP_Status__c = null, ANG_Accreditation_Model__c = 'Cashless' , RecordTypeId = accountAgencyRT, IATACode__c='12399973',Name='Account AE1 H2',Short_Name__c='Account AE1 H2',Category__c = 'IATA Passenger Sales Agent',Location_Class__c = 'P',Location_Type__c = 'AE', ParentId = destinationAccount.Id);
		
		insert childDestAccount;

		AMS_Agencies_Hierarchy__c destinationH = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Newgen Hierarchy (new)');
		insert destinationH;

		AMS_Agencies_relationhip__c r1 = new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true, Child_Account__c = childDestAccount.Id , Parent_Account__c = destinationAccount.Id, Hierarchy__c = destinationH.Id);

		insert r1;


		Account a1 = [Select Id, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE1 H1'];
		Account he1 = [Select Id, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Main HE Account H1'];

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = a1.id, New_parent__c = destinationAccount.id);
		insert oscar;

		Map<string, Id> caseRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case');

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		String OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		List<Account> accounts = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE2 H1'];
		List<Account> accounts2 = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE3 H1'];

        ID rtAgencyInvolved = Schema.SObjectType.AMS_Process_Detail__c.getRecordTypeInfosByName().get('Agency Involved').getRecordTypeId();

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts.get(0).Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts2.get(0).Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = he1.Id));
		
		insert agenciesinvolved;

		// let's start !!

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfHierarchy(oscar,null,accountIdsInvolvedSet);

        List<AMS_Agencies_relationhip__c> relationsMap = struct.relationsMap.values();
		List<Account> accountsMap = struct.accountsMap.values();

		System.debug('Accounts to update:'+accountsMap);

		upsert relationsMap;
		upsert accountsMap;

		List<AMS_Agencies_Hierarchy__c> hierarchies =  [Select Id, Hierarchy_Name__c from AMS_Agencies_Hierarchy__c];
		List<Account> accountsToCheck = [Select Id, Name, ANG_Accreditation_Model__c ,ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account];
		List<AMS_Agencies_relationhip__c> relsToCheck = [Select Id, Hierarchy__r.Hierarchy_Name__c, Child_Account__r.Name, Parent_Account__r.Name, Parent_Account__c, Child_Account__r.ParentId, Parent_Account__r.ParentId, Child_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.Location_Type__c from AMS_Agencies_relationhip__c];
		
		System.debug('[performChangeOfLocationTypeScenario1]- Accounts are:'+accountsToCheck);
		System.debug('[performChangeOfLocationTypeScenario1]- Relations are:'+relsToCheck);
		System.debug('[performChangeOfLocationTypeScenario1]- Hierarchies are:'+hierarchies);
		
		System.assertEquals(1,hierarchies.size());
		System.assertEquals(5,relsToCheck.size());

		Integer parentAccountOriginal = 0;
		Integer parentAccountDestination = 0;
		Integer numberofAE = 0;
		Integer numberofHE = 0;

		For(account a: accountsToCheck){

			if(a.Location_Type__c == AMS_Utils.AE)
				numberofAE++;
			if(a.Location_Type__c == AMS_Utils.HE)
				numberofHE++;

			if(a.ParentId == he1.Id)
				parentAccountOriginal++;
			if(a.ParentId == destinationAccount.id)
				parentAccountDestination++;

		}

		System.assertEquals(5,numberofAE);
		System.assertEquals(1,numberofHE);
		System.assertEquals(0,parentAccountOriginal);
		System.assertEquals(5,parentAccountDestination);


		Test.stopTest();

	}

	@isTest static void performChangeOfHierarchyScenario6(){

		// push songle agencies and to a new HE with an existing hierarchy

		Test.startTest();

		IATA_ISO_Country__c ctry = [Select Id from IATA_ISO_Country__c];

        IATA_ISO_State__c stt =[select id from  IATA_ISO_State__c];
		
		Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

		Account newHeSingle = new Account();
		newHeSingle.Name = 'Destination HE Account';
		newHeSingle.Sector__c = 'Travel Agent';
		newHeSingle.IATACode__c = '10045678';
		newHeSingle.Category__c = 'IATA Passenger Sales Agent';
		newHeSingle.Location_Class__c = 'P';
		newHeSingle.Location_Type__c = 'HE';

		newHeSingle.ANG_IEP_HE_AccntNum__c = '12324353454';
		newHeSingle.ANG_IEP_Status__c = 'Open' ;
		newHeSingle.ANG_HE_CashCondition__c = true;
		newHeSingle.ANG_HE_RiskHistoryAssessment__c = 'Not Applicable';
		newHeSingle.ANG_HE_RiskStatus__c = 'Not Applicable';
		newHeSingle.RecordTypeId = accountAgencyRT;
		newHeSingle.ANG_Accreditation_Model__c = 'Cashless';

		insert newHeSingle;


		Account he1 = [Select Id, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Main HE Account H1'];

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = newHeSingle.id, New_parent__c = he1.id);
		insert oscar;

		Map<string, Id> caseRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case');

		Contact co1 = new Contact(AccountId = newHeSingle.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		String OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = newHeSingle.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		// let's start !!

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfHierarchy(oscar,null,accountIdsInvolvedSet);

        List<AMS_Agencies_relationhip__c> relationsMap = struct.relationsMap.values();
		List<Account> accountsMap = struct.accountsMap.values();

		System.debug('Accounts to update:'+accountsMap);

		upsert relationsMap;
		upsert accountsMap;

		List<AMS_Agencies_Hierarchy__c> hierarchies =  [Select Id, Hierarchy_Name__c from AMS_Agencies_Hierarchy__c];
		List<Account> accountsToCheck = [Select Id, Name, ANG_Accreditation_Model__c ,ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account];
		List<AMS_Agencies_relationhip__c> relsToCheck = [Select Id, Hierarchy__r.Hierarchy_Name__c, Child_Account__r.Name, Parent_Account__r.Name, Parent_Account__c, Child_Account__r.ParentId, Parent_Account__r.ParentId, Child_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.Location_Type__c from AMS_Agencies_relationhip__c];
		
		System.debug('[performChangeOfLocationTypeScenario1]- Accounts are:'+accountsToCheck);
		System.debug('[performChangeOfLocationTypeScenario1]- Relations are:'+relsToCheck);
		System.debug('[performChangeOfLocationTypeScenario1]- Hierarchies are:'+hierarchies);
		
		System.assertEquals(1,hierarchies.size());
		System.assertEquals(4,relsToCheck.size());

		Integer parentAccountOriginal = 0;
		Integer parentAccountDestination = 0;
		Integer numberofAE = 0;
		Integer numberofHE = 0;

		For(account a: accountsToCheck){

			if(a.Location_Type__c == AMS_Utils.AE)
				numberofAE++;
			if(a.Location_Type__c == AMS_Utils.HE)
				numberofHE++;

			if(a.ParentId == newHeSingle.Id)
				parentAccountOriginal++;
			if(a.ParentId == he1.id)
				parentAccountDestination++;

		}

		System.assertEquals(4,numberofAE);
		System.assertEquals(1,numberofHE);
		System.assertEquals(0,parentAccountOriginal);
		System.assertEquals(4,parentAccountDestination);


		Test.stopTest();


	}

	@isTest static void performChangeOfHierarchyScenario7(){

		// push single agency to a single new HE

		Test.startTest();

		IATA_ISO_Country__c ctry = [Select Id from IATA_ISO_Country__c];

        IATA_ISO_State__c stt =[select id from  IATA_ISO_State__c];
		
		Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

		Account newHeSingle = new Account();
		newHeSingle.Name = 'Original HE Account';
		newHeSingle.Sector__c = 'Travel Agent';
		newHeSingle.IATACode__c = '10041278';
		newHeSingle.Category__c = 'IATA Passenger Sales Agent';
		newHeSingle.Location_Class__c = 'P';
		newHeSingle.Location_Type__c = 'HE';

		newHeSingle.ANG_IEP_HE_AccntNum__c = '12323333454';
		newHeSingle.ANG_IEP_Status__c = 'Open' ;
		newHeSingle.ANG_HE_CashCondition__c = true;
		newHeSingle.ANG_HE_RiskHistoryAssessment__c = 'Not Applicable';
		newHeSingle.ANG_HE_RiskStatus__c = 'Not Applicable';
		newHeSingle.RecordTypeId = accountAgencyRT;
		newHeSingle.ANG_Accreditation_Model__c = 'Cashless';

		insert newHeSingle;

		Account destinationAccount = new Account();
		destinationAccount.Name = 'Destination HE Account';
		destinationAccount.Sector__c = 'Travel Agent';
		destinationAccount.IATACode__c = '10045678';
		destinationAccount.Category__c = 'IATA Passenger Sales Agent';
		destinationAccount.Location_Class__c = 'P';
		destinationAccount.Location_Type__c = 'HE';

		destinationAccount.ANG_IEP_HE_AccntNum__c = '15520003454';
		destinationAccount.ANG_IEP_Status__c = 'Open' ;
		destinationAccount.ANG_HE_CashCondition__c = true;
		destinationAccount.ANG_HE_RiskHistoryAssessment__c = 'Not Applicable';
		destinationAccount.ANG_HE_RiskStatus__c = 'Not Applicable';
		destinationAccount.RecordTypeId = accountAgencyRT;
		destinationAccount.ANG_Accreditation_Model__c = 'Cashless';

		insert destinationAccount;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = newHeSingle.id, New_parent__c = destinationAccount.id);
		insert oscar;

		Map<string, Id> caseRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case');

		Contact co1 = new Contact(AccountId = newHeSingle.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		String OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = newHeSingle.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		// let's start !!

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfHierarchy(oscar,null,accountIdsInvolvedSet);

        List<AMS_Agencies_relationhip__c> relationsMap = struct.relationsMap.values();
		List<Account> accountsMap = struct.accountsMap.values();

		System.debug('Accounts to update:'+accountsMap);

		upsert relationsMap;
		upsert accountsMap;

		List<AMS_Agencies_Hierarchy__c> hierarchies =  [Select Id, Hierarchy_Name__c from AMS_Agencies_Hierarchy__c];
		List<Account> accountsToCheck = [Select Id, Name, ANG_Accreditation_Model__c ,ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account];
		List<AMS_Agencies_relationhip__c> relsToCheck = [Select Id, Hierarchy__r.Hierarchy_Name__c, Child_Account__r.Name, Parent_Account__r.Name, Parent_Account__c, Child_Account__r.ParentId, Parent_Account__r.ParentId, Child_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.Location_Type__c from AMS_Agencies_relationhip__c];
		
		System.debug('[performChangeOfLocationTypeScenario1]- Accounts are:'+accountsToCheck);
		System.debug('[performChangeOfLocationTypeScenario1]- Relations are:'+relsToCheck);
		System.debug('[performChangeOfLocationTypeScenario1]- Hierarchies are:'+hierarchies);
		
		System.assertEquals(2,hierarchies.size());
		System.assertEquals(4,relsToCheck.size());

		Integer parentAccountDestination = 0;
		Integer numberofAE = 0;
		Integer numberofHE = 0;

		For(account a: accountsToCheck){

			if(a.Location_Type__c == AMS_Utils.AE)
				numberofAE++;
			if(a.Location_Type__c == AMS_Utils.HE)
				numberofHE++;

			if(a.ParentId == destinationAccount.id)
				parentAccountDestination++;

		}

		System.assertEquals(4,numberofAE);
		System.assertEquals(2,numberofHE);
		System.assertEquals(1,parentAccountDestination);

		Test.stopTest();


	}

	@isTest static void performChangeOfFields(){

		Test.startTest();

		//Agency changes configuration settings
        List<ANG_AgencyChangesConfig__c> customsettings = new List<ANG_AgencyChangesConfig__c>();
        customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeName', TC_Location_type__c = false,
                           TC_Legal_status__c = false, TC_Location__c = false, 
                           TC_Minor_Shareholding__c = false, TC_Legal_Name__c = true, TC_Ownership__c = false, TC_Hierarchy__c = false,
                           TC_Major_Shareholding__c = false,  TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CON', TCA_Application_withdrawal__c = 'CWD'));
        customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeLocationType', TC_Location_type__c = true,
                           TC_Legal_status__c = false, TC_Location__c = false, 
                           TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = false, TC_Hierarchy__c = false,
                           TC_Major_Shareholding__c = false, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CAD', TCA_Application_withdrawal__c = 'CWD'));
        customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeLocation', TC_Location_type__c = false,
                           TC_Legal_status__c = false, TC_Location__c = true, 
                           TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = false, TC_Hierarchy__c = false,
                           TC_Major_Shareholding__c = false, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CHL', TCA_Application_withdrawal__c = 'CWD'));
        customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeOwnership', TC_Location_type__c = false,
                           TC_Legal_status__c = false, TC_Location__c = false, 
                           TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = true, TC_Hierarchy__c = false,
                           TC_Major_Shareholding__c = false, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CHI', TCA_Application_withdrawal__c = 'CWD'));
        customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeLegal', TC_Location_type__c = false,
                           TC_Legal_status__c = true, TC_Location__c = false, 
                           TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = false, TC_Hierarchy__c = false,
                           TC_Major_Shareholding__c = false, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CHS', TCA_Application_withdrawal__c = 'CWD'));
        customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeOwnershipNonIATA', TC_Location_type__c = false,
                           TC_Legal_status__c = false, TC_Location__c = false, 
                           TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = false, TC_Hierarchy__c = false,
                           TC_Major_Shareholding__c = false, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CHO', TCA_Application_withdrawal__c = 'CWD'));
        customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeMajorShareholding', TC_Location_type__c = false,
                           TC_Legal_status__c = false, TC_Location__c = false, 
                           TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = false, TC_Hierarchy__c = false,
                           TC_Major_Shareholding__c = true, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CHC', TCA_Application_withdrawal__c = 'CWD'));

        customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeMix', TC_Location_type__c = false,
                           TC_Legal_status__c = false, TC_Location__c = true, 
                           TC_Minor_Shareholding__c = false, TC_Legal_Name__c = true, TC_Ownership__c = false,
                           TC_Major_Shareholding__c = false, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CNL', TCA_Application_withdrawal__c = 'CWD', TCA_Manager_approval__c = 'MCF'));

        insert customsettings;

		Account he1 = [Select Id, Name, IATAcode__c, IATA_ISO_Country__c, Location_Class__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Main HE Account H1'];

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = he1.id, ANG_Type_Of_Change__c = 'Legal Name');
		insert oscar;

		Map<string, Id> caseRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case');

		Contact co1 = new Contact(AccountId = he1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		String OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = he1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

         // Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
                IATAcode__c = he1.IATAcode__c,
                Branch_Office_Country__c = he1.IATA_ISO_Country__c,
                Location_Class__c = he1.Location_Class__c,
                Location_Type__c = he1.Location_Type__c,
                SAAM_Case__c = oscarCase.Id,
				Account_Name__c = 'Lisbon Travel Gods',
				ISSP_AMS_Legal_Status__c = 'Association',
				Short_Name__c = 'Lisbon Travel Gods',
				TradeName__c = 'Lisbon Travel Gods',
				Trade_Name__c = 'Lisbon Travel Gods',
				ISSP_AMS_License_No__c = '111222333',
				ISSP_AMS_VAT_Number_Input__c = '111222333',
				Branch_Office_Email__c = 'ltg23@fefff2.com',
				Website__c = 'wwww.asdasidsss12233.pt',
				Branch_Office_Phone__c = '123456780',
				Branch_Office_Phone_National__c = '123456780',
				Branch_Office_FAX__c = '123456780',
				Branch_Office_Fax_National__c = '123456780',
				Abbreviated_name__c = 'Lisbon Travel Gods',
				VAT_Number_2__c = '111222333'
                );

        insert stagingArea;

        oscar.AMS_Online_Accreditation__c = stagingArea.Id;
        update oscar;

		List<Account> accounts = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE2 H1'];
		List<Account> accounts2 = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE3 H1'];
		List<Account> accounts3 = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE1 H1'];
        
        ID rtAgencyInvolved = Schema.SObjectType.AMS_Process_Detail__c.getRecordTypeInfosByName().get('Agency Involved').getRecordTypeId();

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts.get(0).Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts2.get(0).Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts3.get(0).Id));

		insert agenciesinvolved;

		// let's start !!

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfFields(oscar, accountIdsInvolvedSet, null);

        List<AMS_Agencies_relationhip__c> relationsMap = struct.relationsMap.values();
		List<Account> accountsMap = struct.accountsMap.values();

		System.debug('Accounts to update:'+accountsMap);

		upsert relationsMap;
		upsert accountsMap;

		List<AMS_Agencies_Hierarchy__c> hierarchies =  [Select Id, Hierarchy_Name__c from AMS_Agencies_Hierarchy__c];
		List<Account> accountsToCheck = [Select Id, Name,Short_Name__c,TradeName__c,License_Number__c,VAT_Number__c,BillingStreet,Website,BillingPostalCode,BillingCity,IATA_ISO_Country__c,Iso_State__c,ShippingStreet,ShippingPostalCode,Email__c,Phone,Fax,ShippingCity,Operation__c,Abbreviated_name__c,Abbreviated_address__c,Remittance_frequency__c,Solicitation_Flag__c,VAT_Number_2__c,CASS_Number__c,Location_Class__c,Location_Type__c,Mobile__c,Is_your_firm_handling_Dangerous_Goods__c,IATA_ISO_Billing_State__c,IATA_ISO_Shipping_Country__c,IATA_ISO_Shipping_State__c,Link_agent_name__c, ANG_Accreditation_Model__c ,ParentId, IATACode__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account];
		List<AMS_Agencies_relationhip__c> relsToCheck = [Select Id, Hierarchy__r.Hierarchy_Name__c, Child_Account__r.Name, Parent_Account__r.Name, Parent_Account__c, Child_Account__r.ParentId, Parent_Account__r.ParentId, Child_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.Location_Type__c from AMS_Agencies_relationhip__c];
		
		System.debug('[performChangeOfLocationTypeScenario1]- Accounts are:'+accountsToCheck);
		System.debug('[performChangeOfLocationTypeScenario1]- Relations are:'+relsToCheck);
		System.debug('[performChangeOfLocationTypeScenario1]- Hierarchies are:'+hierarchies);

		For(Account a: accountsToCheck){

			System.assertEquals('Lisbon Travel Gods',a.Name);
			System.assertEquals('Lisbon Travel Gods',a.Short_Name__c);
			System.assertEquals('Lisbon Travel Gods',a.TradeName__c);
			System.assertEquals('wwww.asdasidsss12233.pt',a.Website);
			System.assertEquals('Lisbon Travel Gods',a.Abbreviated_name__c);

		}

        Test.stopTest();


	}
}