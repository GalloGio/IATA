@isTest
public class ANG_AgencyChangesHelperTest {

	 @testSetup static void testSetup(){
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);
        insert stt;
		
		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account account = new Account();
		account.Name = 'Main HE Account H1';
		account.Sector__c = 'Travel Agent';
		account.IATACode__c = '12345678';
		account.Category__c = 'IATA Passenger Sales Agent';
		account.Location_Class__c = 'P';
		account.Location_Type__c = 'HE';
		account.ANG_Accreditation_Model__c = 'Cashless';
		account.IATA_ISO_Country__c = ctry.Id;
		account.ANG_IEP_HE_AccntNum__c = '1232132323';
		account.ANG_IEP_Status__c = 'Suspended' ;
		account.ANG_HE_CashCondition__c = true;
		account.ANG_HE_RiskHistoryAssessment__c = 'Not Applicable';
		account.ANG_HE_RiskStatus__c = 'Not Applicable';
		account.RecordTypeId = accountAgencyRT;

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

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

        ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfLocationType(oscar,null, null, false);

        List<AMS_Agencies_relationhip__c> relationsMap = struct.relationsMap.values();
		List<Account> accountsMap = struct.accountsMap.values();

		upsert relationsMap;
		upsert accountsMap;

		List<AMS_Agencies_Hierarchy__c> hierarchies =  [Select Id from AMS_Agencies_Hierarchy__c];
		
		System.assertEquals(1,hierarchies.size());

		For(Account a: [Select Id, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account]){

			if(a.Id == a1.Id){

				System.assertEquals('HE', a.Location_Type__c);
				System.assertEquals('1232132323', a.ANG_IEP_HE_AccntNum__c);
				System.assertEquals('Suspended', a.ANG_IEP_Status__c);
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

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		List<Account> accounts = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE2 H1'];

        ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts.get(0).Id));
		
		insert agenciesinvolved;

		// let's start !!

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfHierarchy(oscar,null,accountIdsInvolvedSet,false);

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
		
		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account destinationAccount = new Account();
		destinationAccount.Name = 'Destination HE Account';
		destinationAccount.Sector__c = 'Travel Agent';
		destinationAccount.IATACode__c = '10045678';
		destinationAccount.Category__c = 'IATA Passenger Sales Agent';
		destinationAccount.Location_Class__c = 'P';
		destinationAccount.Location_Type__c = 'HE';
		destinationAccount.IATA_ISO_Country__c = ctry.Id;
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

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		List<Account> accounts = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE2 H1'];

        ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts.get(0).Id));
		
		insert agenciesinvolved;

		// let's start !!

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfHierarchy(oscar,null,accountIdsInvolvedSet, false);

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
		
		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account destinationAccount = new Account();
		destinationAccount.Name = 'Destination HE Account';
		destinationAccount.Sector__c = 'Travel Agent';
		destinationAccount.IATACode__c = '10045678';
		destinationAccount.Category__c = 'IATA Passenger Sales Agent';
		destinationAccount.Location_Class__c = 'P';
		destinationAccount.Location_Type__c = 'HE';
		destinationAccount.IATA_ISO_Country__c = ctry.Id;
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

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		List<Account> accounts = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE2 H1'];
		List<Account> accounts2 = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE3 H1'];

        ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts.get(0).Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts2.get(0).Id));
		
		insert agenciesinvolved;

		// let's start !!

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfHierarchy(oscar,null,accountIdsInvolvedSet,false);

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
		
		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account destinationAccount = new Account();
		destinationAccount.Name = 'Destination HE Account';
		destinationAccount.Sector__c = 'Travel Agent';
		destinationAccount.IATACode__c = '10045678';
		destinationAccount.Category__c = 'IATA Passenger Sales Agent';
		destinationAccount.Location_Class__c = 'P';
		destinationAccount.Location_Type__c = 'HE';
		destinationAccount.IATA_ISO_Country__c = ctry.Id;
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

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		List<Account> accounts = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE2 H1'];
		List<Account> accounts2 = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE3 H1'];

        ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts.get(0).Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts2.get(0).Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = he1.Id));
		
		insert agenciesinvolved;

		// let's start !!

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfHierarchy(oscar,null,accountIdsInvolvedSet,false);

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
		
		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account destinationAccount = new Account();
		destinationAccount.Name = 'Destination HE Account';
		destinationAccount.Sector__c = 'Travel Agent';
		destinationAccount.IATACode__c = '10045678';
		destinationAccount.Category__c = 'IATA Passenger Sales Agent';
		destinationAccount.Location_Class__c = 'P';
		destinationAccount.Location_Type__c = 'HE';
		destinationAccount.IATA_ISO_Country__c = ctry.Id;
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

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		List<Account> accounts = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE2 H1'];
		List<Account> accounts2 = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE3 H1'];

        ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts.get(0).Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts2.get(0).Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = he1.Id));
		
		insert agenciesinvolved;

		// let's start !!

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfHierarchy(oscar,null,accountIdsInvolvedSet,false);

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

		IATA_ISO_Country__c ctry = [Select Id,ANG_Enable_NewGen__c from IATA_ISO_Country__c];

        IATA_ISO_State__c stt =[select id from  IATA_ISO_State__c];
		
		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

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
		newHeSingle.IATA_ISO_Country__c = ctry.Id;

		insert newHeSingle;


		Account he1 = [Select Id, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Main HE Account H1'];

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = newHeSingle.id, New_parent__c = he1.id);
		insert oscar;

		Contact co1 = new Contact(AccountId = newHeSingle.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = newHeSingle.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		// let's start !!

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfHierarchy(oscar,null,accountIdsInvolvedSet,false);

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

		IATA_ISO_Country__c ctry = [Select Id,ANG_Enable_NewGen__c from IATA_ISO_Country__c];


        IATA_ISO_State__c stt =[select id from  IATA_ISO_State__c];
		
		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

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
		newHeSingle.IATA_ISO_Country__c = ctry.Id;

		insert newHeSingle;

		Account destinationAccount = new Account();
		destinationAccount.Name = 'Destination HE Account';
		destinationAccount.Sector__c = 'Travel Agent';
		destinationAccount.IATACode__c = '10045678';
		destinationAccount.Category__c = 'IATA Passenger Sales Agent';
		destinationAccount.Location_Class__c = 'P';
		destinationAccount.Location_Type__c = 'HE';
		destinationAccount.IATA_ISO_Country__c = ctry.Id;
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

		Contact co1 = new Contact(AccountId = newHeSingle.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = newHeSingle.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		// let's start !!

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfHierarchy(oscar,null,accountIdsInvolvedSet,false);

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

        ID rtChange = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes');

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = he1.id, RecordTypeId = rtChange, Process__c = 'ANG.MAJOR.CHANGES.1.0');

		insert oscar;

		Contact co1 = new Contact(AccountId = he1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = he1.Id;
        oscarCase.ContactId = co1.Id;
        oscarCase.Reason = 'Product Inquiry';
        oscarCase.Type = 'Case';
        oscarCase.subject = 'Changes - WEBER VOYAGES SARL';
    	oscarCase.CaseArea__c = 'Accreditation Process';
     	oscarCase.Reason1__c = 'Changes';
		oscarCase.Type_of_customer__c = 'IATA Travel Agent';
		oscarCase.BSPCountry__c = 'US';
		oscarCase.Account_Concerned__c = he1.Id;
		oscarCase.Region__c = 'Europe';

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
        oscar.ANG_Type_Of_Change__c = 'Legal Name';
        update oscar;

		List<Account> accounts = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE2 H1'];
		List<Account> accounts2 = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE3 H1'];
		List<Account> accounts3 = [Select Id, Name, ParentId, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE1 H1'];
        
        ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts.get(0).Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts2.get(0).Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = accounts3.get(0).Id));

		insert agenciesinvolved;

		// let's start !!

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		AMS_Pax_Accreditation_Form__c oscarOnlineAccreditation = ANG_AgencyChangesHelper.getAccreditation(oscar.AMS_Online_Accreditation__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfFields(oscar, accountIdsInvolvedSet, null,oscarOnlineAccreditation);

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


	@isTest static void performChangeOfOwnership1(){



		// push single agency to a single new HE

		Test.startTest();

		Account he = null;
		Account ae1 = null;
		Account ae2 = null;
		Account ae3 = null;

		For(Account acct : [Select Id, Name, ParentId,IATA_ISO_Country__c, Location_Class__c, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account]){

			if(acct.Name == 'Main HE Account H1' )
				he = acct;
			if(acct.Name == 'Account AE1 H1' )
				ae1 = acct;
			if(acct.Name == 'Account AE2 H1' )
				ae2 = acct;
			if(acct.Name == 'Account AE3 H1' )
				ae3 = acct;
		}

		System.assert(he != null);
		System.assert(ae1 != null);
		System.assert(ae2 != null);
		System.assert(ae3 != null);

        ID rtChange = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes');

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = he.id, RecordTypeId = rtChange, Process__c = 'ANG.MAJOR.CHANGES.1.0');
		insert oscar;

		Contact co1 = new Contact(AccountId = he.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = he.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

                 // Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
                IATAcode__c = he.IATAcode__c,
                Branch_Office_Country__c = he.IATA_ISO_Country__c,
                Location_Class__c = he.Location_Class__c,
                Location_Type__c = he.Location_Type__c,
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

        List<AMS_Accreditation_Contact__c> accreditationContacts = new List<AMS_Accreditation_Contact__c>();

        Id personAccreditationRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

        accreditationContacts.add(new AMS_Accreditation_Contact__c(Agency_Owner__c = true, Financial_interest__c = 20, AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = he.Id, First_name__c='NameToUse1', Last_name__c='Last1', Job_title__c='ABC1', Mobile__c='+4112345671', Phone__c='3424322341', Email__c='unique@email1.com', RecordTypeId=personAccreditationRT));
        accreditationContacts.add(new AMS_Accreditation_Contact__c(Agency_Owner__c = true, Financial_interest__c = 20, AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = he.Id, First_name__c='NameToUse2', Last_name__c='Last2', Job_title__c='ABC2', Mobile__c='+4112345672', Phone__c='3424322342', Email__c='unique@email2.com', RecordTypeId=personAccreditationRT));
        accreditationContacts.add(new AMS_Accreditation_Contact__c(Agency_Owner__c = true, Financial_interest__c = 60, AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = he.Id, First_name__c='NameToUse3', Last_name__c='Last3', Job_title__c='ABC3', Mobile__c='+4112345673', Phone__c='3424322343', Email__c='unique@email3.com', RecordTypeId=personAccreditationRT));

        insert accreditationContacts;

        oscar.AMS_Online_Accreditation__c = stagingArea.Id;
        update oscar;

		// let's start !!

        ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = ae1.Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = ae2.Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = ae3.Id));
		
		insert agenciesinvolved;

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfOwnership(oscar, accountIdsInvolvedSet, null, true);

        List<AMS_Account_Role__c> roleList = [select Contact__c, Percentage__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c from AMS_Account_Role__c];

        For(AMS_Account_Role__c role :roleList)
	        System.debug('[ANG_AgencyChangesHelperTest]: Owner inserted:' + role);

        System.assertEquals(12,roleList.size());

		Test.stopTest();

	}

	@isTest static void performChangeOfOwnership2(){

		// push single agency to a single new HE

		Test.startTest();

		Account he = null;
		Account ae1 = null;
		Account ae2 = null;
		Account ae3 = null;

		For(Account acct : [Select Id, Name, ParentId,IATA_ISO_Country__c, Location_Class__c, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account]){

			if(acct.Name == 'Main HE Account H1' )
				he = acct;
			if(acct.Name == 'Account AE1 H1' )
				ae1 = acct;
			if(acct.Name == 'Account AE2 H1' )
				ae2 = acct;
			if(acct.Name == 'Account AE3 H1' )
				ae3 = acct;
		}

		System.assert(he != null);
		System.assert(ae1 != null);
		System.assert(ae2 != null);
		System.assert(ae3 != null);

		Id ownerRtId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
        
        List<AMS_Account_Role__c> accountRoles = new List<AMS_Account_Role__c>();

        accountRoles.add(new AMS_Account_Role__c(Owner_Name__c = 'Owner1', recordTypeId = ownerRtId, Account__c = he.Id, Person__c = null, Contact__c = null, Percentage__c=40.0, Legacy_External_ID__c='12345323'));
        accountRoles.add(new AMS_Account_Role__c(Owner_Name__c = 'Owner2', recordTypeId = ownerRtId, Account__c = he.Id, Person__c = null, Contact__c = null, Percentage__c=30.0, Legacy_External_ID__c='12345321'));
        accountRoles.add(new AMS_Account_Role__c(Owner_Name__c = 'Owner3', recordTypeId = ownerRtId, Account__c = he.Id, Person__c = null, Contact__c = null, Percentage__c=30.0, Legacy_External_ID__c='12345322'));

        insert accountRoles;

        ID rtChange = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes');

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = he.id, RecordTypeId = rtChange, Process__c = 'ANG.MAJOR.CHANGES.1.0');

		insert oscar;

		Contact co1 = new Contact(AccountId = he.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = he.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

                 // Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
                IATAcode__c = he.IATAcode__c,
                Branch_Office_Country__c = he.IATA_ISO_Country__c,
                Location_Class__c = he.Location_Class__c,
                Location_Type__c = he.Location_Type__c,
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

        List<AMS_Accreditation_Contact__c> accreditationContacts = new List<AMS_Accreditation_Contact__c>();

        Id personAccreditationRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

        accreditationContacts.add(new AMS_Accreditation_Contact__c(AMS_Ownership_Role__c = accountRoles.get(0).Id ,Agency_Owner__c = true, Financial_interest__c = 20, AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = he.Id, First_name__c='NameToUse1', Last_name__c='Last1', Job_title__c='ABC1', Mobile__c='+4112345671', Phone__c='3424322341', Email__c='unique@email1.com', RecordTypeId=personAccreditationRT));
        accreditationContacts.add(new AMS_Accreditation_Contact__c(AMS_Ownership_Role__c = accountRoles.get(1).Id ,Agency_Owner__c = true, Financial_interest__c = 20, AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = he.Id, First_name__c='NameToUse2', Last_name__c='Last2', Job_title__c='ABC2', Mobile__c='+4112345672', Phone__c='3424322342', Email__c='unique@email2.com', RecordTypeId=personAccreditationRT));
        accreditationContacts.add(new AMS_Accreditation_Contact__c(AMS_Ownership_Role__c = accountRoles.get(2).Id ,Agency_Owner__c = true, Financial_interest__c = 60, AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = he.Id, First_name__c='NameToUse3', Last_name__c='Last3', Job_title__c='ABC3', Mobile__c='+4112345673', Phone__c='3424322343', Email__c='unique@email3.com', RecordTypeId=personAccreditationRT));

        insert accreditationContacts;

        oscar.AMS_Online_Accreditation__c = stagingArea.Id;
        update oscar;

		// let's start !!

        ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = ae1.Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = ae2.Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = ae3.Id));
		
		insert agenciesinvolved;

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfOwnership(oscar, accountIdsInvolvedSet, null, true);

        List<AMS_Account_Role__c> roleList = [select Owner_Name__c, Legacy_External_ID__c, Contact__c, Percentage__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, Active__c from AMS_Account_Role__c];

        For(AMS_Account_Role__c role :roleList)
	        System.debug('[ANG_AgencyChangesHelperTest]: Owner inserted:' + role);

        System.assertEquals(12,roleList.size());

		Test.stopTest();

	}

	@isTest static void performChangeOfOwnership3(){

		// push single agency to a single new HE

		Test.startTest();

		Account he = null;
		Account ae1 = null;
		Account ae2 = null;
		Account ae3 = null;

		For(Account acct : [Select Id, Name, ParentId,IATA_ISO_Country__c, Location_Class__c, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account]){

			if(acct.Name == 'Main HE Account H1' )
				he = acct;
			if(acct.Name == 'Account AE1 H1' )
				ae1 = acct;
			if(acct.Name == 'Account AE2 H1' )
				ae2 = acct;
			if(acct.Name == 'Account AE3 H1' )
				ae3 = acct;
		}

		System.assert(he != null);
		System.assert(ae1 != null);
		System.assert(ae2 != null);
		System.assert(ae3 != null);

		Id ownerRtId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
        
        List<AMS_Account_Role__c> accountRoles = new List<AMS_Account_Role__c>();

        accountRoles.add(new AMS_Account_Role__c(Owner_Name__c = 'Owner1', recordTypeId = ownerRtId, Account__c = he.Id, Person__c = null, Contact__c = null, Percentage__c=40.0, Legacy_External_ID__c='12345323'));
        accountRoles.add(new AMS_Account_Role__c(Owner_Name__c = 'Owner2', recordTypeId = ownerRtId, Account__c = he.Id, Person__c = null, Contact__c = null, Percentage__c=30.0, Legacy_External_ID__c='12345321'));
        accountRoles.add(new AMS_Account_Role__c(Owner_Name__c = 'Owner3', recordTypeId = ownerRtId, Account__c = he.Id, Person__c = null, Contact__c = null, Percentage__c=30.0, Legacy_External_ID__c='12345322'));

        accountRoles.add(new AMS_Account_Role__c(Owner_Name__c = 'Owner4', recordTypeId = ownerRtId, Account__c = ae1.Id, Person__c = null, Contact__c = null, Percentage__c=100.0, Legacy_External_ID__c='12345122'));
        accountRoles.add(new AMS_Account_Role__c(Owner_Name__c = 'Owner5', recordTypeId = ownerRtId, Account__c = ae2.Id, Person__c = null, Contact__c = null, Percentage__c=100.0, Legacy_External_ID__c='12315322'));

        insert accountRoles;

        ID rtChange = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes');

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = he.id, RecordTypeId = rtChange, Process__c = 'ANG.MAJOR.CHANGES.1.0');

		insert oscar;

		Contact co1 = new Contact(AccountId = he.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = he.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

                 // Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
                IATAcode__c = he.IATAcode__c,
                Branch_Office_Country__c = he.IATA_ISO_Country__c,
                Location_Class__c = he.Location_Class__c,
                Location_Type__c = he.Location_Type__c,
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

        List<AMS_Accreditation_Contact__c> accreditationContacts = new List<AMS_Accreditation_Contact__c>();

        Id personAccreditationRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

        accreditationContacts.add(new AMS_Accreditation_Contact__c(AMS_Ownership_Role__c = accountRoles.get(0).Id ,Agency_Owner__c = true, Financial_interest__c = 20, AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = he.Id, First_name__c='NameToUse1', Last_name__c='Last1', Job_title__c='ABC1', Mobile__c='+4112345671', Phone__c='3424322341', Email__c='unique@email1.com', RecordTypeId=personAccreditationRT));
        accreditationContacts.add(new AMS_Accreditation_Contact__c(AMS_Ownership_Role__c = accountRoles.get(1).Id ,Agency_Owner__c = true, Financial_interest__c = 20, AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = he.Id, First_name__c='NameToUse2', Last_name__c='Last2', Job_title__c='ABC2', Mobile__c='+4112345672', Phone__c='3424322342', Email__c='unique@email2.com', RecordTypeId=personAccreditationRT));
        accreditationContacts.add(new AMS_Accreditation_Contact__c(AMS_Ownership_Role__c = accountRoles.get(2).Id ,Agency_Owner__c = true, Financial_interest__c = 60, AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = he.Id, First_name__c='NameToUse3', Last_name__c='Last3', Job_title__c='ABC3', Mobile__c='+4112345673', Phone__c='3424322343', Email__c='unique@email3.com', RecordTypeId=personAccreditationRT));

        insert accreditationContacts;

        oscar.AMS_Online_Accreditation__c = stagingArea.Id;
        update oscar;

		// let's start !!

        ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = ae1.Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = ae2.Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = ae3.Id));
		
		insert agenciesinvolved;

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);

		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfOwnership(oscar, accountIdsInvolvedSet, null, true);

        List<AMS_Account_Role__c> roleList = [select Owner_Name__c, Legacy_External_ID__c, Contact__c, Percentage__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, Active__c from AMS_Account_Role__c];

        For(AMS_Account_Role__c role :roleList)
	        System.debug('[ANG_AgencyChangesHelperTest]: Owner inserted:' + role);

        System.assertEquals(14,roleList.size());

		roleList = [select Owner_Name__c, Legacy_External_ID__c, Contact__c, Percentage__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, Active__c from AMS_Account_Role__c where Active__c = true];

        System.assertEquals(12,roleList.size());

		Test.stopTest();

	}

	@isTest static void performChangeOfAccreditationCash(){

		// push single agency to a single new HE

		Test.startTest();

		Account he = null;
		Account ae1 = null;
		Account ae2 = null;
		Account ae3 = null;

		For(Account acct : [Select Id, Name, ParentId,IATA_ISO_Country__c, Location_Class__c, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account]){

			if(acct.Name == 'Main HE Account H1' )
				he = acct;
			if(acct.Name == 'Account AE1 H1' )
				ae1 = acct;
			if(acct.Name == 'Account AE2 H1' )
				ae2 = acct;
			if(acct.Name == 'Account AE3 H1' )
				ae3 = acct;
		}

		System.assert(he != null);
		System.assert(ae1 != null);
		System.assert(ae2 != null);
		System.assert(ae3 != null);

		Id	formOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');

		List<Agency_Authorization__c> toUpsert = new List<Agency_Authorization__c>();

	    toUpsert.add(new Agency_Authorization__c(Account__c = he.Id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Not Authorized', RecordTypeId = formOfPaymentRT));

	    insert toUpsert;

        ID rtChange = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes');

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = he.id, RecordTypeId = rtChange, Process__c = 'ANG.MAJOR.CHANGES.1.0');

		insert oscar;

		Contact co1 = new Contact(AccountId = he.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		String OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = he.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		ID rtChangesStagingId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'New_Gen_Changes');

                 // Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
        		RecordTypeId = rtChangesStagingId,
                IATAcode__c = he.IATAcode__c,
                Branch_Office_Country__c = he.IATA_ISO_Country__c,
                Location_Class__c = he.Location_Class__c,
                Location_Type__c = he.Location_Type__c,
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
				VAT_Number_2__c = '111222333',
				ANG_Accreditation_type__c = 'Cash'
                );

        insert stagingArea;

        oscar.AMS_Online_Accreditation__c = stagingArea.Id;
        update oscar;

		// let's start !!

        ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = ae1.Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = ae2.Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = ae3.Id));
		
		insert agenciesinvolved;

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);


		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfAccreditationType(oscar, accountIdsInvolvedSet, null);

		List<Agency_Authorization__c> aaList = [Select Id , Status__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA' and Status__c = 'Active' and RecordType.DeveloperName = 'FormOfPayment'];

        System.assertEquals(4,aaList.size());

		Test.stopTest();

	}

	@isTest static void performChangeOfAccreditationCashless(){

		// push single agency to a single new HE

		Test.startTest();

		Account he = null;
		Account ae1 = null;
		Account ae2 = null;
		Account ae3 = null;

		For(Account acct : [Select Id, Name, ParentId,IATA_ISO_Country__c, Location_Class__c, IATACode__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account]){

			if(acct.Name == 'Main HE Account H1' )
				he = acct;
			if(acct.Name == 'Account AE1 H1' )
				ae1 = acct;
			if(acct.Name == 'Account AE2 H1' )
				ae2 = acct;
			if(acct.Name == 'Account AE3 H1' )
				ae3 = acct;
		}

		System.assert(he != null);
		System.assert(ae1 != null);
		System.assert(ae2 != null);
		System.assert(ae3 != null);

		he.ANG_Accreditation_Model__c = 'Cash';
		update he;

		Id	formOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');

		List<Agency_Authorization__c> toUpsert = new List<Agency_Authorization__c>();

	    toUpsert.add(new Agency_Authorization__c(Account__c = he.Id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
	    toUpsert.add(new Agency_Authorization__c(Account__c = ae1.Id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
	    toUpsert.add(new Agency_Authorization__c(Account__c = ae2.Id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
	    toUpsert.add(new Agency_Authorization__c(Account__c = ae3.Id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));

	    insert toUpsert;

        ID rtChange = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes');

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = he.id, RecordTypeId = rtChange, Process__c = 'ANG.MAJOR.CHANGES.1.0');

		insert oscar;

		Contact co1 = new Contact(AccountId = he.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		String OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = he.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		ID rtChangesStagingId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'New_Gen_Changes');

                 // Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
        		RecordTypeId = rtChangesStagingId,
                IATAcode__c = he.IATAcode__c,
                Branch_Office_Country__c = he.IATA_ISO_Country__c,
                Location_Class__c = he.Location_Class__c,
                Location_Type__c = he.Location_Type__c,
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
				VAT_Number_2__c = '111222333',
				ANG_Accreditation_type__c = 'Cashless'
                );

        insert stagingArea;

        oscar.AMS_Online_Accreditation__c = stagingArea.Id;
        update oscar;

		// let's start !!

        ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = ae1.Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = ae2.Id));
		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = ae3.Id));
		
		insert agenciesinvolved;

		Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
		accountIdsInvolvedSet.add(oscar.Account__c);


		ANG_AgencyChangesHelper.AChangeStructure struct = ANG_AgencyChangesHelper.applyChangeOfAccreditationType(oscar, accountIdsInvolvedSet, null);

		List<Agency_Authorization__c> aaList = [Select Id , Status__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA' and Status__c = 'Active' and RecordType.DeveloperName = 'FormOfPayment'];

        System.assertEquals(0,aaList.size());

		aaList = [Select Id , Status__c from Agency_Authorization__c where ANG_FormOfPayment_ID__c = 'CA' and Status__c = 'Not Authorized' and RecordType.DeveloperName = 'FormOfPayment'];

        System.assertEquals(4,aaList.size());

		Test.stopTest();

	}

	@isTest static void performChangeOfLocationTypeOscar(){

		EF_AttachmentListController.runningForEF = false;
		loadCredentials();

		// push a subset of agencies and creating a new brand new hierarchy (scenario 1)

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

		AMS_Agencies_Hierarchy__c originalHierarchy =  [Select Id from AMS_Agencies_Hierarchy__c];

		Account a1 = [Select Id, IATACode__c,IATA_ISO_Country__c,Location_Class__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE1 H1'];
		Account he1 = [Select Id, IATACode__c, IATA_ISO_Country__c,Location_Class__c,Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Main HE Account H1'];

		Id oscarRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes');

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = a1.id, New_parent__c = a1.id, recordTypeId = oscarRT, Process__c = 'ANG.MAJOR.CHANGES.1.0' );
		insert oscar;

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        oscarCase.Reason = 'Product Inquiry';
        oscarCase.Type = 'Case';
        oscarCase.subject = 'Changes - WEBER VOYAGES SARL';
    	oscarCase.CaseArea__c = 'Accreditation Process';
     	oscarCase.Reason1__c = 'Changes';
		oscarCase.Type_of_customer__c = 'IATA Travel Agent';
		oscarCase.BSPCountry__c = 'US';
		oscarCase.Account_Concerned__c = he1.Id;
		oscarCase.Region__c = 'Europe';
        insert oscarCase;

		// let's start !!

		ID rtChangesStagingId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'New_Gen_Changes');

		// Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
        		RecordTypeId = rtChangesStagingId,
                IATAcode__c = a1.IATAcode__c,
                Branch_Office_Country__c = a1.IATA_ISO_Country__c,
                Location_Class__c = a1.Location_Class__c,
                Location_Type__c = a1.Location_Type__c,
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
				VAT_Number_2__c = '111222333',
				ANG_Accreditation_type__c = 'Cashless'
                );

        insert stagingArea;

        oscar.AMS_Online_Accreditation__c = stagingArea.Id;
        update oscar;
		
		Test.startTest();

		List<AMS_Accreditation_Contact__c> accreditationContacts = new List<AMS_Accreditation_Contact__c>();

        Id personAccreditationRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

        accreditationContacts.add(new AMS_Accreditation_Contact__c(Agency_Owner__c = true, Financial_interest__c = 100, AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = he1.Id, First_name__c='NameToUse1', Last_name__c='Last1', Job_title__c='ABC1', Mobile__c='+4112345671', Phone__c='3424322341', Email__c='unique@email1.com', RecordTypeId=personAccreditationRT));

        insert accreditationContacts;
  	    
		Blob pdfArchive = Blob.valueOf('Test content');

		Attachment att = new Attachment();
		att.Name = 'Certificates '+oscarCase.Id+'.pdf';
		att.Body = pdfArchive;
		att.ParentId = oscarCase.Id;

		insert att;

        oscar.STEP6__c = 'Passed';
		oscar.Change_effective_as_of__c = System.today();
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
		oscar.ANG_Type_Of_Change__c = 'Location type';

		update oscar;

		Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Account__c = a1.Id, Change_Code__c = 'IEP',  Sent_to_external_system__c = false);

		insert aacc1;

		ANG_AgencyChangesHelper.AChangeStructure changesContainer = new ANG_AgencyChangesHelper.AChangeStructure();

		ANG_AgencyChangesHelper.generateLNFChangeCode(oscar, new Map<Id, Agency_Applied_Change_code__c>{a1.Id => aacc1}, changesContainer);

		Test.stopTest();

	}

	private static void loadCredentials() {
        Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
        Amazon_Cred__c GenericAttach =  new Amazon_Cred__c(name = 'GenericAttach', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
        Amazon_Cred__c recycleBin =  new Amazon_Cred__c(name = 'RecycleBin', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
        List<Amazon_Cred__c> creds = new List<Amazon_Cred__c>();
        creds.add(Amazon_Cred);
        creds.add(GenericAttach);
        creds.add(recycleBin);
        insert creds;


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

	@isTest static void test_getChangeCodes(){

		// push a subset of agencies and creating a new brand new hierarchy (scenario 1)
		ANG_AgencyChangesHelper.testRunnningForNonBackup = true;
		EF_AttachmentListController.runningForEF = false;
		loadCredentials();

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

        customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeMixAll', TC_Location_type__c = true,
                   TC_Legal_status__c = false, TC_Location__c = true, TC_Accreditation_Type__c = false,
                   TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = false,
                   TC_Major_Shareholding__c = false, TC_VMFR__c = true,
                   TCA_Sanity_check__c = 'CNL', TCA_Application_withdrawal__c = 'CWD', TCA_Manager_approval__c = 'MCF',TC_Hierarchy__c = true));

        insert customsettings;

		AMS_Agencies_Hierarchy__c originalHierarchy =  [Select Id from AMS_Agencies_Hierarchy__c];

		Account a1 = [Select Id, ANG_Accreditation_Model__c, IATACode__c,IATA_ISO_Country__c,Location_Class__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE1 H1'];
		Account he1 = [Select Id, ANG_Accreditation_Model__c, IATACode__c, IATA_ISO_Country__c,Location_Class__c,Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Main HE Account H1'];

		a1.ANG_Accreditation_Model__c = 'Cash';
		he1.ANG_Accreditation_Model__c = 'Cashless';

		Id oscarRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes');

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = a1.id, New_parent__c = a1.id, recordTypeId = oscarRT, Process__c = 'ANG.MAJOR.CHANGES.1.0' );
		insert oscar;

		ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = he1.Id));
		
		insert agenciesinvolved;


		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		String OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        oscarCase.Reason = 'Product Inquiry';
        oscarCase.Type = 'Case';
        oscarCase.subject = 'Changes - WEBER VOYAGES SARL';
    	oscarCase.CaseArea__c = 'Accreditation Process';
     	oscarCase.Reason1__c = 'Changes';
		oscarCase.Type_of_customer__c = 'IATA Travel Agent';
		oscarCase.BSPCountry__c = 'US';
		oscarCase.Account_Concerned__c = he1.Id;
		oscarCase.Region__c = 'Europe';
        insert oscarCase;

		// let's start !!

		ID rtChangesStagingId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'New_Gen_Changes');

		// Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
        		RecordTypeId = rtChangesStagingId,
                IATAcode__c = a1.IATAcode__c,
                Branch_Office_Country__c = a1.IATA_ISO_Country__c,
                Location_Class__c = a1.Location_Class__c,
                Location_Type__c = a1.Location_Type__c,
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
				VAT_Number_2__c = '111222333',
				ANG_Accreditation_type__c = 'Cashless'
                );

        insert stagingArea;

        oscar.AMS_Online_Accreditation__c = stagingArea.Id;
        oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_LOCATION+';'+AMS_Utils.LOCATION_TYPE+';'+AMS_Utils.ANG_HIERARCHY+';'+AMS_Utils.ANG_VMFR;
        update oscar;

		Test.startTest();
		
		List<AMS_Accreditation_Contact__c> accreditationContacts = new List<AMS_Accreditation_Contact__c>();

        Id personAccreditationRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

        accreditationContacts.add(new AMS_Accreditation_Contact__c(Agency_Owner__c = true, Financial_interest__c = 100, AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = he1.Id, First_name__c='NameToUse1', Last_name__c='Last1', Job_title__c='ABC1', Mobile__c='+4112345671', Phone__c='3424322341', Email__c='unique@email1.com', RecordTypeId=personAccreditationRT));

        insert accreditationContacts;

        oscar.STEP6__c = 'Passed';
		oscar.Change_effective_as_of__c = System.today();
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
		oscar.ANG_Type_Of_Change__c = 'Location type';
  	    
		Blob pdfArchive = Blob.valueOf('Test content');

		System.debug('Case Id is:'+oscarCase.Id);

		Attachment att = new Attachment();
		att.Name = 'Certificates '+oscarCase.Id+'.pdf';
		att.Body = pdfArchive;
		att.ParentId = oscarCase.Id;

		insert att;
		
		update oscar;

		Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Account__c = a1.Id, Change_Code__c = 'IEP',  Sent_to_external_system__c = false);

		insert aacc1;

		ANG_AgencyChangesHelper.AChangeStructure changesContainer = new ANG_AgencyChangesHelper.AChangeStructure();

		ANG_AgencyChangesHelper.generateLNFChangeCode(oscar, new Map<Id, Agency_Applied_Change_code__c>{a1.Id => aacc1}, changesContainer);

		Test.stopTest();

	}

	@isTest static void testOscarNGCorrection1(){

		// push a subset of agencies and creating a new brand new hierarchy (scenario 1)
		EF_AttachmentListController.runningForEF = false;
		loadCredentials();

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

        customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeMixAll', TC_Location_type__c = false,
                   TC_Legal_status__c = false, TC_Location__c = true, TC_Accreditation_Type__c = false,
                   TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = false,
                   TC_Major_Shareholding__c = false, TC_VMFR__c = false,
                   TCA_Sanity_check__c = 'CNL', TCA_Application_withdrawal__c = 'CWD', TCA_Manager_approval__c = 'MCF',TC_Hierarchy__c = false));

        insert customsettings;

		AMS_Agencies_Hierarchy__c originalHierarchy =  [Select Id from AMS_Agencies_Hierarchy__c];

		Account a1 = [Select Id, ANG_Accreditation_Model__c, IATACode__c,IATA_ISO_Country__c,Location_Class__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE1 H1'];
		Account he1 = [Select Id, ANG_Accreditation_Model__c, IATACode__c, IATA_ISO_Country__c,Location_Class__c,Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Main HE Account H1'];

		List<AMS_Oscar__c> oscars = new List<AMS_Oscar__c>();
		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = a1.id, New_parent__c = a1.id, recordTypeId = AMS_Utils.RECTYPE_NGCORRECTION, Process__c = AMS_Utils.NGCORRECTION );
		AMS_OSCAR__c oscar2 = new AMS_OSCAR__c(Account__c = a1.id, New_parent__c = a1.id, recordTypeId = AMS_Utils.RECTYPE_NGCORRECTION, Process__c = AMS_Utils.NGCORRECTION );
		
		oscars.add(oscar);
		oscars.add(oscar2);

		insert oscars;

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		List<Case> cases = new List<Case>();

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        oscarCase.Reason = 'Product Inquiry';
        oscarCase.Type = 'Case';
        oscarCase.subject = 'Changes - WEBER VOYAGES SARL';
    	oscarCase.CaseArea__c = 'Accreditation Process';
     	oscarCase.Reason1__c = 'Changes';
		oscarCase.Type_of_customer__c = 'IATA Travel Agent';
		oscarCase.BSPCountry__c = 'US';
		oscarCase.Account_Concerned__c = he1.Id;
		oscarCase.Region__c = 'Europe';

		cases.add(oscarCase);

	    Case oscarCase2 = new Case(Oscar__c = oscar2.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase2.AccountId = a1.Id;
        oscarCase2.ContactId = co1.Id;
        oscarCase2.Reason = 'Product Inquiry';
        oscarCase2.Type = 'Case';
        oscarCase2.subject = 'Changes - WEBER VOYAGES SARL';
    	oscarCase2.CaseArea__c = 'Accreditation Process';
     	oscarCase2.Reason1__c = 'Changes';
		oscarCase2.Type_of_customer__c = 'IATA Travel Agent';
		oscarCase2.BSPCountry__c = 'US';
		oscarCase2.Account_Concerned__c = he1.Id;
		oscarCase2.Region__c = 'Europe';

		cases.add(oscarCase2);

        insert cases;

		// let's start !!


		ID rtChangesStagingId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'New_Gen_Changes');

		// Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
        		RecordTypeId = rtChangesStagingId,
                IATAcode__c = a1.IATAcode__c,
                Branch_Office_Country__c = a1.IATA_ISO_Country__c,
                Location_Class__c = a1.Location_Class__c,
                Location_Type__c = a1.Location_Type__c,
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
				VAT_Number_2__c = '111222333',
				ANG_Accreditation_type__c = 'Cashless'
                );

        insert stagingArea;

        oscar.AMS_Online_Accreditation__c = stagingArea.Id;
        oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_LOCATION;
        update oscar;

		
		List<AMS_Accreditation_Contact__c> accreditationContacts = new List<AMS_Accreditation_Contact__c>();

        Id personAccreditationRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

        accreditationContacts.add(new AMS_Accreditation_Contact__c(Agency_Owner__c = true, Financial_interest__c = 100, AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = he1.Id, First_name__c='NameToUse1', Last_name__c='Last1', Job_title__c='ABC1', Mobile__c='+4112345671', Phone__c='3424322341', Email__c='unique@email1.com', RecordTypeId=personAccreditationRT));

        insert accreditationContacts;
		
		Test.startTest();

        PageReference pg = Page.ANG_AccountHierarchySelection;
        pg.getParameters().put('Id', oscar.Id);


        oscar.STEP6__c = 'Passed';
		oscar.Change_effective_as_of__c = System.today();
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = System.today();
		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_LOCATION;
		oscar.AMS_Correction_change_code__c = 'COR';
  	    
		Blob pdfArchive = Blob.valueOf('Test content');

		System.debug('Case Id is:'+oscarCase.Id);

		Attachment att = new Attachment();
		att.Name = 'Certificates '+oscarCase.Id+'.pdf';
		att.Body = pdfArchive;
		att.ParentId = oscarCase.Id;

		insert att;
		
		
		update oscar;

		Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Account__c = a1.Id, Change_Code__c = 'IEP',  Sent_to_external_system__c = false);

		insert aacc1;
		

		ANG_AgencyChangesHelper.AChangeStructure changesContainer = new ANG_AgencyChangesHelper.AChangeStructure();

		ANG_AgencyChangesHelper.generateLNFChangeCode(oscar, new Map<Id, Agency_Applied_Change_code__c>{a1.Id => aacc1}, changesContainer);

		List<Id> accountsIds = new List<Id>();
		accountsIds.add(a1.Id);
		accountsIds.add(he1.Id);

		ANG_AgencyChangesHelper.fetchAccountAgOperationPerOpCode(accountsIds);

		
		//2nd oscar - CAD

		AMS_Pax_Accreditation_Form__c stagingArea2 = new  AMS_Pax_Accreditation_Form__c(
        		RecordTypeId = rtChangesStagingId,
                IATAcode__c = a1.IATAcode__c,
                Branch_Office_Country__c = a1.IATA_ISO_Country__c,
                Location_Class__c = a1.Location_Class__c,
                Location_Type__c = a1.Location_Type__c,
                SAAM_Case__c = oscarCase2.Id,
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
				VAT_Number_2__c = '111222333',
				ANG_Accreditation_type__c = 'Cashless'
                );

        insert stagingArea2;
		

        oscar2.AMS_Online_Accreditation__c = stagingArea2.Id;
        oscar2.ANG_Type_Of_Change__c = AMS_Utils.ANG_LOCATION;
        update oscar2;

        accreditationContacts = new List<AMS_Accreditation_Contact__c>();

        personAccreditationRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

        accreditationContacts.add(new AMS_Accreditation_Contact__c(Agency_Owner__c = true, Financial_interest__c = 100, AMS_Pax_Accreditation_Form__c = stagingArea2.Id, Company__c = he1.Id, First_name__c='NameToUse2', Last_name__c='Last1', Job_title__c='ABC1', Mobile__c='+4112345671', Phone__c='3424322341', Email__c='unique2@email1.com', RecordTypeId=personAccreditationRT));

        insert accreditationContacts;

        pg = Page.ANG_AccountHierarchySelection;
        pg.getParameters().put('Id', oscar2.Id);

        oscar2.STEP6__c = 'Passed';
		oscar2.Change_effective_as_of__c = System.today();
		oscar2.Is_PCI_compliant__c = 'Yes';
		oscar2.ANG_PCI_compliance_expiry_date__c = System.today();
		oscar2.ANG_Type_Of_Change__c = AMS_Utils.ANG_LOCATION;
		oscar2.AMS_Correction_change_code__c = 'CAD';
  	    
		pdfArchive = Blob.valueOf('Test content');

		System.debug('Case Id is:'+oscarCase2.Id);

		update oscar2;

		Test.stopTest();

	}

	@isTest static void testOscarNGCorrection2(){

		// push a subset of agencies and creating a new brand new hierarchy (scenario 1)
		EF_AttachmentListController.runningForEF = false;
		loadCredentials();

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

        customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeMixAll', TC_Location_type__c = false,
                   TC_Legal_status__c = false, TC_Location__c = true, TC_Accreditation_Type__c = false,
                   TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = false,
                   TC_Major_Shareholding__c = false, TC_VMFR__c = false,
                   TCA_Sanity_check__c = 'CNL', TCA_Application_withdrawal__c = 'CWD', TCA_Manager_approval__c = 'MCF',TC_Hierarchy__c = false));

        insert customsettings;

		AMS_Agencies_Hierarchy__c originalHierarchy =  [Select Id from AMS_Agencies_Hierarchy__c];

		Account a1 = [Select Id, ANG_Accreditation_Model__c, IATACode__c,IATA_ISO_Country__c,Location_Class__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Account AE1 H1'];
		Account he1 = [Select Id, ANG_Accreditation_Model__c, IATACode__c, IATA_ISO_Country__c,Location_Class__c,Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c from Account where Name = 'Main HE Account H1'];

		List<AMS_Oscar__c> oscars = new List<AMS_Oscar__c>();
		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = a1.id, New_parent__c = a1.id, recordTypeId = AMS_Utils.RECTYPE_NGCORRECTION, Process__c = AMS_Utils.NGCORRECTION );
		
		insert oscar;

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        oscarCase.Reason = 'Product Inquiry';
        oscarCase.Type = 'Case';
        oscarCase.subject = 'Changes - WEBER VOYAGES SARL';
    	oscarCase.CaseArea__c = 'Accreditation Process';
     	oscarCase.Reason1__c = 'Changes';
		oscarCase.Type_of_customer__c = 'IATA Travel Agent';
		oscarCase.BSPCountry__c = 'US';
		oscarCase.Account_Concerned__c = he1.Id;
		oscarCase.Region__c = 'Europe';

        insert oscarCase;

		// let's start !!

		Test.startTest();

		ID rtChangesStagingId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'New_Gen_Changes');

		// Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
        		RecordTypeId = rtChangesStagingId,
                IATAcode__c = a1.IATAcode__c,
                Branch_Office_Country__c = a1.IATA_ISO_Country__c,
                Location_Class__c = a1.Location_Class__c,
                Location_Type__c = a1.Location_Type__c,
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
				VAT_Number_2__c = '111222333',
				ANG_Accreditation_type__c = 'Cashless'
                );

        insert stagingArea;

        oscar.AMS_Online_Accreditation__c = stagingArea.Id;
        oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_LOCATION;
        update oscar;

		
		List<AMS_Accreditation_Contact__c> accreditationContacts = new List<AMS_Accreditation_Contact__c>();

        Id personAccreditationRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

        accreditationContacts.add(new AMS_Accreditation_Contact__c(Agency_Owner__c = true, Financial_interest__c = 100, AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = he1.Id, First_name__c='NameToUse1', Last_name__c='Last1', Job_title__c='ABC1', Mobile__c='+4112345671', Phone__c='3424322341', Email__c='unique@email1.com', RecordTypeId=personAccreditationRT));

        insert accreditationContacts;

        PageReference pg = Page.ANG_AccountHierarchySelection;
        pg.getParameters().put('Id', oscar.Id);


        oscar.STEP6__c = 'Passed';
		oscar.Change_effective_as_of__c = System.today();
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = System.today();
		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_LOCATION;
		oscar.AMS_Correction_change_code__c = 'LET';
  	    
		Blob pdfArchive = Blob.valueOf('Test content');

		System.debug('Case Id is:'+oscarCase.Id);

		Attachment att = new Attachment();
		att.Name = 'Certificates '+oscarCase.Id+'.pdf';
		att.Body = pdfArchive;
		att.ParentId = oscarCase.Id;

		insert att;
		
		
		update oscar;

		Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Account__c = a1.Id, Change_Code__c = 'IEP',  Sent_to_external_system__c = false);

		insert aacc1;
		

		ANG_AgencyChangesHelper.AChangeStructure changesContainer = new ANG_AgencyChangesHelper.AChangeStructure();

		ANG_AgencyChangesHelper.generateLNFChangeCode(oscar, new Map<Id, Agency_Applied_Change_code__c>{a1.Id => aacc1}, changesContainer);

		List<Id> accountsIds = new List<Id>();
		accountsIds.add(a1.Id);
		accountsIds.add(he1.Id);

		ANG_AgencyChangesHelper.fetchAccountAgOperationPerOpCode(accountsIds);

		Test.stopTest();

	}

	@isTest static void testANGAccountHierarchyChange(){

		ANG_AgencyChangesHelper.testRunnningForNonBackup = true;

		// push a subset of agencies and creating a new brand new hierarchy (scenario 1)
		EF_AttachmentListController.runningForEF = false;
		loadCredentials();

				//Agency changes configuration settings
        List<ANG_AgencyChangesConfig__c> customsettings = new List<ANG_AgencyChangesConfig__c>();


        customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'Change~Hierarchy', TC_Location_type__c = false,
                   TC_Legal_status__c = false, TC_Location__c = false, TC_Accreditation_Type__c = false,
                   TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = false,
                   TC_Major_Shareholding__c = false, TC_VMFR__c = false,
                   TCA_Sanity_check__c = 'CNL', TCA_Application_withdrawal__c = 'CWD', TCA_Manager_approval__c = 'MCF',TC_Hierarchy__c = true));

        insert customsettings;

		AMS_Agencies_Hierarchy__c originalHierarchy =  [Select Id from AMS_Agencies_Hierarchy__c];

		Account a1 = [Select Id, ANG_Accreditation_Model__c, IATACode__c,IATA_ISO_Country__c,Location_Class__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c, ANG_FA_Opt_out__c from Account where Name = 'Account AE1 H1'];
		Account he1 = [Select Id, ANG_Accreditation_Model__c, IATACode__c, IATA_ISO_Country__c,Location_Class__c,Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c, ANG_FA_Opt_out__c from Account where Name = 'Main HE Account H1'];

		a1.ANG_Accreditation_Model__c = 'Cash';
		he1.ANG_Accreditation_Model__c = 'Cashless';

		Id oscarRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes');

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = a1.id, New_parent__c = a1.id, recordTypeId = oscarRT, Process__c = 'ANG.MAJOR.CHANGES.1.0' );
		insert oscar;

		ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = he1.Id));
		
		insert agenciesinvolved;


		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		String OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        oscarCase.Reason = 'Product Inquiry';
        oscarCase.Type = 'Case';
        oscarCase.subject = 'Changes - WEBER VOYAGES SARL';
    	oscarCase.CaseArea__c = 'Accreditation Process';
     	oscarCase.Reason1__c = 'Changes';
		oscarCase.Type_of_customer__c = 'IATA Travel Agent';
		oscarCase.BSPCountry__c = 'US';
		oscarCase.Account_Concerned__c = he1.Id;
		oscarCase.Region__c = 'Europe';
        insert oscarCase;

		// let's start !!

		ID rtChangesStagingId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'New_Gen_Changes');

		// Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
        		RecordTypeId = rtChangesStagingId,
                IATAcode__c = a1.IATAcode__c,
                Branch_Office_Country__c = a1.IATA_ISO_Country__c,
                Location_Class__c = a1.Location_Class__c,
                Location_Type__c = a1.Location_Type__c,
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
				VAT_Number_2__c = '111222333',
				ANG_Accreditation_type__c = 'Cashless'
                );

        insert stagingArea;

        oscar.AMS_Online_Accreditation__c = stagingArea.Id;
        update oscar;

		Test.startTest();
		
		List<AMS_Accreditation_Contact__c> accreditationContacts = new List<AMS_Accreditation_Contact__c>();

        Id personAccreditationRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

        accreditationContacts.add(new AMS_Accreditation_Contact__c(Agency_Owner__c = true, Financial_interest__c = 100, AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = he1.Id, First_name__c='NameToUse1', Last_name__c='Last1', Job_title__c='ABC1', Mobile__c='+4112345671', Phone__c='3424322341', Email__c='unique@email1.com', RecordTypeId=personAccreditationRT));

        insert accreditationContacts;

        oscar.STEP6__c = 'Passed';
		oscar.Change_effective_as_of__c = System.today();
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_HIERARCHY;
  	    
		Blob pdfArchive = Blob.valueOf('Test content');

		System.debug('Case Id is:'+oscarCase.Id);

		Attachment att = new Attachment();
		att.Name = 'Certificates '+oscarCase.Id+'.pdf';
		att.Body = pdfArchive;
		att.ParentId = oscarCase.Id;

		insert att;
		
		update oscar;

		try {
            oscar.Status__c = AMS_Utils.OSCAR_CLOSED;
            update oscar;
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot close the OSCAR until the Manager Approval Step is not completed.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        

		Test.stopTest();

	}

		@isTest static void testANGAccountHierarchyChange2(){

		ANG_AgencyChangesHelper.testRunnningForNonBackup = true;

		// push a subset of agencies and creating a new brand new hierarchy (scenario 1)
		EF_AttachmentListController.runningForEF = false;
		loadCredentials();

				//Agency changes configuration settings
        List<ANG_AgencyChangesConfig__c> customsettings = new List<ANG_AgencyChangesConfig__c>();


        customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'Change~Hierarchy', TC_Location_type__c = false,
                   TC_Legal_status__c = false, TC_Location__c = false, TC_Accreditation_Type__c = false,
                   TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = false,
                   TC_Major_Shareholding__c = false, TC_VMFR__c = false,
                   TCA_Sanity_check__c = 'CNL', TCA_Application_withdrawal__c = 'CWD', TCA_Manager_approval__c = 'MCF',TC_Hierarchy__c = true));

        insert customsettings;

		AMS_Agencies_Hierarchy__c originalHierarchy =  [Select Id from AMS_Agencies_Hierarchy__c];

		Account a1 = [Select Id, ANG_Accreditation_Model__c, IATACode__c,IATA_ISO_Country__c,Location_Class__c, Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c, ANG_FA_Opt_out__c from Account where Name = 'Account AE1 H1'];
		Account he1 = [Select Id, ANG_Accreditation_Model__c, IATACode__c, IATA_ISO_Country__c,Location_Class__c,Location_Type__c, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c, ANG_FA_Opt_out__c from Account where Name = 'Main HE Account H1'];

		a1.ANG_Accreditation_Model__c = 'Cash';
		he1.ANG_Accreditation_Model__c = 'Cashless';

		Id oscarRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes');

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = a1.id, New_parent__c = a1.id, recordTypeId = oscarRT, Process__c = 'ANG.MAJOR.CHANGES.1.0' );
		insert oscar;

		ID rtAgencyInvolved =RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');

        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = he1.Id));
		
		insert agenciesinvolved;


		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		String OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        oscarCase.Reason = 'Product Inquiry';
        oscarCase.Type = 'Case';
        oscarCase.subject = 'Changes - WEBER VOYAGES SARL';
    	oscarCase.CaseArea__c = 'Accreditation Process';
     	oscarCase.Reason1__c = 'Changes';
		oscarCase.Type_of_customer__c = 'IATA Travel Agent';
		oscarCase.BSPCountry__c = 'US';
		oscarCase.Account_Concerned__c = he1.Id;
		oscarCase.Region__c = 'Europe';
        insert oscarCase;

		// let's start !!

		ID rtChangesStagingId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'New_Gen_Changes');

		// Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
        		RecordTypeId = rtChangesStagingId,
                IATAcode__c = a1.IATAcode__c,
                Branch_Office_Country__c = a1.IATA_ISO_Country__c,
                Location_Class__c = a1.Location_Class__c,
                Location_Type__c = a1.Location_Type__c,
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
				VAT_Number_2__c = '111222333',
				ANG_Accreditation_type__c = 'Cashless'
                );

        insert stagingArea;

        oscar.AMS_Online_Accreditation__c = stagingArea.Id;
        update oscar;

		Test.startTest();
		
		List<AMS_Accreditation_Contact__c> accreditationContacts = new List<AMS_Accreditation_Contact__c>();

        Id personAccreditationRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

        accreditationContacts.add(new AMS_Accreditation_Contact__c(Agency_Owner__c = true, Financial_interest__c = 100, AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = he1.Id, First_name__c='NameToUse1', Last_name__c='Last1', Job_title__c='ABC1', Mobile__c='+4112345671', Phone__c='3424322341', Email__c='unique@email1.com', RecordTypeId=personAccreditationRT));

        insert accreditationContacts;

        oscar.STEP6__c = 'Passed';
		oscar.Change_effective_as_of__c = System.today();
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_HIERARCHY;
  	    
		Blob pdfArchive = Blob.valueOf('Test content');

		System.debug('Case Id is:'+oscarCase.Id);

		Attachment att = new Attachment();
		att.Name = 'Certificates '+oscarCase.Id+'.pdf';
		att.Body = pdfArchive;
		att.ParentId = oscarCase.Id;

		insert att;		

        oscar.ANG_FA_Opt_out__c = 'Opt-Out';
        oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
		oscar.STEP15__c = AMS_Utils.PASSED;
		oscar.STEP12__c = AMS_Utils.PASSED;
		update oscar;
       
        oscar.RPM_Approval__c = AMS_Utils.AUTH_DISAPPROVAL;
        update oscar;

        oscar.ANG_FA_Opt_out__c = 'Not Applicable';
        oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        update oscar;
        

		Test.stopTest();

	}

}