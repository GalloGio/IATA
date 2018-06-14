@isTest
private class FSM_MassEmailReminderControllerTest {
	private static final string CASE_RECORDTYPE_FSM = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Security Monitoring');
	//Create County codes
	private static list<IATA_ISO_Country__c> CreateCountryCodes(){
		list<IATA_ISO_Country__c> lsISO = new list<IATA_ISO_Country__c>();
		lsISO.add(new IATA_ISO_Country__c(Name='South Africa', ISO_CODE__c='ZA', Region__c='Africa & Middle East'));
		lsISO.add(new IATA_ISO_Country__c(Name='United States', ISO_CODE__c='US', Region__c='Americas'));
		lsISO.add(new IATA_ISO_Country__c(Name='Japan', ISO_CODE__c='JP', Region__c='Asia & Pacific'));
		lsISO.add(new IATA_ISO_Country__c(Name='Hong Kong SAR, China', ISO_CODE__c='HK', Region__c='China & North Asia'));
		lsISO.add(new IATA_ISO_Country__c(Name='United Kingdom', ISO_CODE__c='GB', Region__c='Europe'));
		return lsISO;
	}
	
	//Create Account
	//private static list<Account> CreateAccounts(list<IATA_ISO_Country__c> lsIso) {
	private static void CreateAccounts(list<IATA_ISO_Country__c> lsIso) {
		list<Account> listAccount = new list<Account>();
		for ( Integer i = 0; i < lsIso.size(); i++ ) {
			listAccount.add( new Account( Name = 'account' + i, AIMS_ID__c = String.ValueOf(i), Industry='Cargo Agent', Type = 'IATA Cargo Agent', Location_Type__c = 'HO', IATA_ISO_Country__c = lsIso[i].ID) );
		}
		
		insert listAccount;
//		return listAccount;
	}

	//Create FA Contacts
	private static list<Contact> CreateContacts(list<Account> lsAccnt) {
		list<Contact> listcontact = new list<Contact>();
		for(integer i=0; i<lsAccnt.size(); i++)
			listcontact.add( new Contact( FirstName = 'Name', LastName = 'TestName ' + i, AccountId = lsAccnt[i].Id, Financial_Assessment_Contact__c = true) );
		return listcontact;
	}

	//Create Cases
	private static list<Case> CreateCases(list<Account> lsAccnt, map<id, id> mapCasesCreated, map<string, EmailTemplate__c> mapTemplates){
		list<Case> lsCase = new list<Case>();
		for(Account accnt:lsAccnt){
			Case newCase = new Case();
			newCase.RecordTypeId = CASE_RECORDTYPE_FSM;
			newCase.Reporting_date__c = system.today();
			newCase.Subject = accnt.Country_ISO_Code__c + '-FS_UPDATE-Sales_Monitoring-2015-01'; 
			newCase.Description = 'Annual Financial Review 2015_';
			newCase.ContactId = accnt.Contacts.isEmpty()?null:accnt.Contacts[0].Id;
			newCase.AccountId = accnt.Id;
			newCase.Region__c = accnt.Region_formula__c;
			newCase.CCG_Participant__c = accnt.CCG_Participant__c;
			newCase.Current_held_FS_amount__c = 1000;
			newCase.Financial_Security_Amount_2__c = 2000;
			newCase.CurrencyISOCode = 'USD';
			EmailTemplate__c et = mapTemplates.get('FSM_' + accnt.Country_ISO_Code__c + '_English');
			
			system.debug(logginglevel.ERROR, 'DTULLO CaseKey: ' + 'FSM_' + accnt.Country_ISO_Code__c + '_English');
			system.debug(logginglevel.ERROR, 'DTULLO Template: ' + et);
			
			newCase.Reminder_EmailTemplate__c = et.id;
			if(mapCasesCreated != null)
				newCase.ParentId = mapCasesCreated.get(accnt.Id);
			newCase.Request_Expiry_Date__c = system.today()+30;
			lsCase.add(newCase);
		}
		return lsCase;
	}
	
	private static map<string, EmailTemplate__c> CreateTemplates(list<IATA_ISO_Country__c> lsISO){
		Recordtype recordtypeFSM = [Select Id, DeveloperName From RecordType where developerName like 'FSM' and sObjectType = 'EmailTemplate__c'];
		list<EmailTemplate__c> lsET = new list<EmailTemplate__c>();
		for(IATA_ISO_Country__c iso:lsISO){
			lsET.add(new EmailTemplate__c(RecordtypeId = recordtypeFSM.Id, Template_Language__c = 'English', IATA_ISO_Country__c = iso.Id, Agent_Type__c='All'));//, UniqueId__c = ('FSM_' + iso.ISO_CODE__c + '_English')));
		}
		
		insert lsET;
		map<string, EmailTemplate__c> oReturn = new map<string, EmailTemplate__c>();
		for(EmailTemplate__c et:[select UniqueId__c, Id from EmailTemplate__c]){
			oReturn.put(et.UniqueId__c, et);
		}
		
		return oReturn;
	}

	//Test Method
	static testMethod void TestAll() {
		list<IATA_ISO_Country__c> lsISO = CreateCountryCodes();
		insert lsISO;
		system.assert(lsISO.size()==5);
		
		map<string, EmailTemplate__c> mapTemplates = CreateTemplates(lsISO);
		system.assert(mapTemplates.size()==5);
		
		for(string s:mapTemplates.keySet())
			system.debug(logginglevel.ERROR, 'DTULLO Key: ' + s);
		
		//list<Account> lsAccnt = 
		CreateAccounts(lsISO); 
		//insert lsAccnt;
		
		list<Account> lsAccnt = [select Id, Name, Country_ISO_Code__c,Region_formula__c,CCG_Participant__c from Account];
		system.assert(lsAccnt.size()==5);
		
		insert CreateContacts(lsAccnt);
		system.assert([select id from Contact].size()==lsAccnt.size());
		
		list<Case> lsCase = new list<Case>();
		list<Case> lsCaseTmp = CreateCases(lsAccnt, null, mapTemplates);
		insert lsCaseTmp;
		lsCase.addAll(lsCaseTmp);
		
		map<id, id> mapCasesCreated = new map<id, id>();
		for(Case c:lsCase)
			mapCasesCreated.put(c.AccountId, c.Id);
		//Create recurrent cases
		lsCaseTmp.clear();
		lsCaseTmp = CreateCases(lsAccnt, mapCasesCreated, mapTemplates);
		insert lsCaseTmp;
		lsCase.addAll(lsCaseTmp);
		
		system.assert(lsCase.size()==10);
		
		insert new IATA_ISO_Country__c(Name='All Countries', ISO_CODE__c='WW', Region__c='');
		system.assert([select id from IATA_ISO_Country__c].size()==6);
		
		test.StartTest();
		//Initialize the page
		PageReference pageRef = Page.FSM_Mass_Email_Reminder;
        Test.setCurrentPage(pageRef);
		
		FSM_MassEmailReminderController controller = new FSM_MassEmailReminderController();
		
		//Search cases test
		controller.SelectedCountry = 'WW';
		
		controller.sSelectedCaseTypeToSearch='Latest';
		controller.searchCase();
		controller.QueryForCases();
		system.assert(controller.cases.size()==5);
		
		controller.sSelectedCaseTypeToSearch='Master';
		controller.searchCase();
		controller.QueryForCases();
		system.debug(logginglevel.ERROR, 'DTULLO --> ' + controller.cases.size());
		system.debug(logginglevel.ERROR, 'DTULLO --> ' + controller.cases);
		system.assert(controller.cases.size()==5);
		
		controller.sSelectedCaseTypeToSearch='All';
		controller.searchCase();
		controller.QueryForCases();
		
		system.assert(controller.cases.size()==10);
		system.assert(controller.getHasCases());
		system.assert(controller.getThePageSize()!=null);
		system.assert(controller.getTotalPages()>0);
		
		system.debug(logginglevel.ERROR, 'DTULLO --> ' + controller.cases.size());
		system.debug(logginglevel.ERROR, 'DTULLO --> ' + controller.cases);
		
		//change pagesize to 1
		controller.setThePageSize('1');
		controller.UpdatePageSize();
		controller.setThePageSize('1'); //check return null
//		controller.iPageSize = 1;
		system.assert(controller.getHasNext());
		controller.doNext();
		system.assert(controller.getHasPrevious());
		controller.doPrevious();
		
		string buildSetSelectedCases = '';
		for(case c:lsCase)
			buildSetSelectedCases+=c.id + ';';
		
		controller.lsSelectedCases = buildSetSelectedCases;
		controller.buildSetSelectedCases();
		
		controller.sendMails();
		//controller.sendMailsToAll();
		
		test.StopTest();
	}
}