@isTest
private class trg_Case_FSM_Handle_NonCompliance_Test {

    private static final string CASE_RECORDTYPE_FSM = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Security Monitoring');
    private static final string NCRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SAAM');
    public static final String PAX = 'Travel Agent';
	public static final String CARGO = 'Cargo Agent';
	
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
	private static void CreateAccounts(list<IATA_ISO_Country__c> lsIso, integer iNumAccnt) {
		list<Account> listAccount = new list<Account>();
		for ( Integer i = 0; i < iNumAccnt; i++ ) {
			string sIndustry = 'Cargo Agent';
			string sType = 'IATA Cargo Agent';
			if(math.mod(i,2)==0)
				listAccount.add( new Account( Name = 'account' + i, AIMS_ID__c = String.ValueOf(i), Industry='Travel Agent', Type = 'IATA Passenger Sales Agent', Location_Type__c = 'HO', IATA_ISO_Country__c = lsIso[i].ID) );
			else
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
		map<id, id> mapContact = new map<id,id>();
		
		set<id> setAccntId = new set<id>();
		
		for(Account ac:lsAccnt)
			setAccntId.add(ac.Id);
			
		for(Contact c: [select AccountId, Id from Contact where AccountId in:setAccntId])
			mapContact.put(c.AccountId, c.Id);
		
		for(Account accnt:lsAccnt){
			Case newCase = new Case();
			newCase.RecordTypeId = CASE_RECORDTYPE_FSM;
			newCase.Reporting_date__c = system.today();
			newCase.Subject = accnt.Country_ISO_Code__c + '-FS_UPDATE-Sales_Monitoring-2015-01'; 
			newCase.Description = 'Annual Financial Review 2015_';
			//newCase.ContactId = accnt.Contacts.isEmpty()?null:accnt.Contacts[0].Id;
			newCase.ContactId = mapContact.get(accnt.Id);
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
	
	
	private static list<Case> CreateFSMCases(){
		list<IATA_ISO_Country__c> lsISO = CreateCountryCodes();
		insert lsISO;
		system.assert(lsISO.size()==5);
		
		map<string, EmailTemplate__c> mapTemplates = CreateTemplates(lsISO);
		system.assert(mapTemplates.size()==5);
		
		CreateAccounts(lsISO, 2); 
		
		list<Account> lsAccnt = [select Id, Name, Country_ISO_Code__c,Region_formula__c,CCG_Participant__c from Account];
		system.assert(lsAccnt.size()==2);
		
		insert CreateContacts(lsAccnt);
		system.assert([select id from Contact].size()==lsAccnt.size());
		
		list<Case> lsCaseFSM = CreateCases(lsAccnt, null, mapTemplates);
		insert lsCaseFSM;
		
		return lsCaseFSM;
	}
	
	private static Case getNCCase(Case FSMCase){
		Case NCCase = new Case();
		NCCase.RecordTypeId = NCRecordTypeID;
		NCCase.ContactId = FSMCase.ContactId;
		NCCase.Type_of_customer__c = FSMCase.IFAP_Agent_Type__c;
		NCCase.AccountId = FSMCase.AccountId;
		NCCase.ParentId = FSMCase.Id;
		NCCase.Origin = 'Internal Case';
		NCCase.CaseArea__c = 'Accreditation Process';
		NCCase.Reason1__c = 'FA/ FS Non-Compliance';
		NCCase.New_IFAP_Deadline_date__c = system.today().addDays(10);
		return NCCase;
	}
	
	
	private static list<Case> getFSMCases(){
		return [Select Id, Status, RecordTypeId, Account.Industry, FS_Letter_Sent__c, isClosed
							, FS_Deadline_Date__c, FS_Second_Deadline_Date__c, FS_Third_Deadline_Date__c
							, firstFSnonComplianceDate__c, secondFSnonComplianceDate__c, FS_third_non_compliance_date__c
							from Case c where RecordTypeId = :CASE_RECORDTYPE_FSM];
	}
	
	private static Date getMondayIfOnWeekend(date deaddate){
		Date RefDate = date.NewInstance(1900,1,7);
		integer dayOfWeek = math.mod(RefDate.daysBetween(deaddate),7);
		if(dayOfWeek==0)//Sunday
			return deaddate.addDays(1);
		else if(dayOfWeek==6)//Saturday
			return deaddate.addDays(2);
		else
			return deaddate;
	}
	
	private static list<Case> getInsertedNCCase(){return [select Id from Case where RecordTypeId=:NCRecordTypeID];}
	
	//First Non-compliance
	static testMethod void FirstNonComplianceTest(){
		list<Case> lsCaseFSM = CreateFSMCases();
		system.assert(lsCaseFSM.size()>0);
		
		test.StartTest();
		
		list<Case> lsNCCase = new list<Case>();
		for(Case FSMCase: lsCaseFSM)
			lsNCCase.add(getNCCase(FSMCase));
		
		system.assert(lsNCCase.size() == lsCaseFSM.size());
		
		//Generate Exception (letter NOT sent)
		try{
			insert lsNCCase;
		}catch(Exception e){} 
		
		//No NCC Inserted: letter not sent (FS_Deadline_Date__c==null)
		system.assert(getInsertedNCCase().size()==0);
		
		//Letter sent (in the future) (Error)
		for(Case FSMCase: lsCaseFSM)
			FSMCase.FS_Deadline_Date__c = system.today().addDays(10);
		
		update lsCaseFSM;
		
		
		try{
			insert lsNCCase;
		}catch(exception e){}
		
		system.assert(getInsertedNCCase().size()==0);
		
		//Letter sent (in the past)
		for(Case FSMCase: lsCaseFSM)
			FSMCase.FS_Deadline_Date__c = system.today().addDays(-10);
		
		update lsCaseFSM;
		
		insert lsNCCase;
		
		//NCC Inserted. one per FSMCase
		system.assert(getInsertedNCCase().size()==lsCaseFSM.size());
		
		system.debug(Logginglevel.ERROR, 'DTULLO getInsertedNCCase().size() --> ' + getInsertedNCCase().size());
		system.debug(Logginglevel.ERROR, 'DTULLO lsCaseFSM().size() --> ' + lsCaseFSM.size());
		
		//loop through FSMCase and check dates
		for(Case FSMCase:getFSMCases()){
			system.debug(Logginglevel.ERROR, 'DTULLO FSMCase.Account.Industry --> ' + FSMCase.Account.Industry);
			system.assert(FSMCase.firstFSnonComplianceDate__c==system.today());
			if(FSMCase.Account.Industry==PAX){
				system.assert(FSMCase.FS_Second_Deadline_Date__c == getMondayIfOnWeekend(date.Today().addDays(31)));
			}
			
			if(FSMCase.Account.Industry==CARGO){
				system.assert(FSMCase.FS_Second_Deadline_Date__c == system.today().addDays(10));
			}
		}
		
		test.StopTest();
	}
	
	
	//Simulate 2nd non-compliance
	static testMethod void SecondNonComplianceTest(){
		list<Case> lsCaseFSM = CreateFSMCases();
		system.assert(lsCaseFSM.size()>0);
		
		test.StartTest();
		
		//Letter sent (in the past)
		for(Case CaseFSM:lsCaseFSM)
			CaseFSM.FS_Deadline_Date__c = system.today().addDays(-10);
		
		update lsCaseFSM;
		
		list<Case> lsNCCase = new list<Case>();
		
		//Create First non-compliance (correctly)
		for(Case FSMCase: lsCaseFSM)
			lsNCCase.add(getNCCase(FSMCase));
		
		insert lsNCCase;
		
		system.assert(getInsertedNCCase().size() == lsCaseFSM.size());
		
		lsNCCase.clear();
		//Create Second non-compliance Generate Exception: 2nd deadline date > today
		for(Case FSMCase: lsCaseFSM)
			lsNCCase.add(getNCCase(FSMCase));

		try{
			insert lsNCCase;
		}catch(Exception e){} 
		
		system.assert(getInsertedNCCase().size()==lsCaseFSM.size());
		
		//Modify second deadline date (simulate to less than today)
		for(Case FSMCase: lsCaseFSM)
			FSMCase.FS_Second_Deadline_Date__c = system.today().addDays(-9);
		
		update lsCaseFSM;
		
		insert lsNCCase;
		
		//NCC Inserted. one per FSMCase
		system.assert(getInsertedNCCase().size()>0);
		system.assert(getInsertedNCCase().size()==(lsCaseFSM.size()*2));
		
		//loop through FSMCase and check dates
		for(Case FSMCase:getFSMCases()){
			system.assert(FSMCase.secondFSnonComplianceDate__c==system.today());
			if(FSMCase.Account.Industry==PAX){
				system.assert(FSMCase.FS_Third_Deadline_Date__c == getMondayIfOnWeekend(Date.newInstance(Date.today().addMonths(2).year(), Date.today().addMonths(2).month(), 1).addDays(-1)));
			}
			
			if(FSMCase.Account.Industry==CARGO){
				system.assert(FSMCase.FS_Third_Deadline_Date__c == system.today().addDays(10));
			}
		}
		
		test.StopTest();
	}
	
	
	
	//Simulate 3rd non-compliance
	static testMethod void ThirdNonComplianceTest(){
		list<Case> lsCaseFSM = CreateFSMCases();
		system.assert(lsCaseFSM.size()>0);
		test.StartTest();
		
		//Letter sent (in the past)
		for(Case CaseFSM:lsCaseFSM)
			CaseFSM.FS_Deadline_Date__c = system.today().addDays(-10);
		
		update lsCaseFSM;
		
		list<Case> lsNCCase = new list<Case>();
		
		//Create First non-compliance (correctly)
		for(Case FSMCase: lsCaseFSM)
			lsNCCase.add(getNCCase(FSMCase));
		
		insert lsNCCase;
		
		system.assert(getInsertedNCCase().size() == lsCaseFSM.size());
		
		
		//Create Second non-compliance
		for(Case FSMCase: lsCaseFSM)
			FSMCase.FS_Second_Deadline_Date__c = system.today().addDays(-9);
		
		update lsCaseFSM;
		
		lsNCCase.clear();
		for(Case FSMCase: lsCaseFSM)
			lsNCCase.add(getNCCase(FSMCase));

		try{
			insert lsNCCase;
		}catch(Exception e){} 
		
		system.assert(getInsertedNCCase().size()==(lsCaseFSM.size()*2));
		
		//Create 3rd non-compliance. Generate error because 3rd deadline > today()
		lsNCCase.clear();
		for(Case FSMCase: lsCaseFSM)
			lsNCCase.add(getNCCase(FSMCase));
		
		try{
			insert lsNCCase;
		}catch(Exception e){} 
		
		system.assert(getInsertedNCCase().size()==(lsCaseFSM.size()*2));
		
		//Modify second deadline date (simulate to less than today)
		for(Case FSMCase: lsCaseFSM)
			FSMCase.FS_third_Deadline_Date__c = system.today().addDays(-8);
		
		update lsCaseFSM;
		
		insert lsNCCase;
		
		system.assert(getInsertedNCCase().size()>0);
		system.assert(getInsertedNCCase().size()==(lsCaseFSM.size()*3));
		
		//loop through FSMCase and check dates
		for(Case FSMCase:getFSMCases()){
			system.assert(FSMCase.FS_third_non_compliance_date__c==system.today());
		}
		
		test.StopTest();
	}
	
	
	
	//Simulate 4th non-compliance (error)
	static testMethod void fourthNonComplianceTest(){
		list<Case> lsCaseFSM = CreateFSMCases();
		system.assert(lsCaseFSM.size()>0);
		
		test.StartTest();
		//simulate all 3 non-compliance are already sent
		for(Case FSMCase:lsCaseFSM){
			FSMCase.FS_Deadline_Date__c = system.today().addDays(-10);
			FSMCase.FS_Second_Deadline_Date__c = system.today().addDays(-9);
			FSMCase.FS_Third_Deadline_Date__c = system.today().addDays(-8);
			FSMCase.firstFSnonComplianceDate__c=system.today();
			FSMCase.secondFSnonComplianceDate__c=system.today();
			FSMCase.FS_third_non_compliance_date__c=system.today();
		}
		
		update lsCaseFSM;
		
		list<Case> lsNCCase = new list<Case>();
		
		//Create First non-compliance (correctly)
		for(Case FSMCase: lsCaseFSM)
			lsNCCase.add(getNCCase(FSMCase));
		
		try{
			insert lsNCCase;
		}catch(exception e){}
		
		system.assert(getInsertedNCCase().size() == 0);
		
		test.StopTest();
	}
	
	
	//Simulate 4th non-compliance (error)
	static testMethod void CaseClosedTest(){
		list<Case> lsCaseFSM = CreateFSMCases();
		system.assert(lsCaseFSM.size()>0);
		
		test.StartTest();
		//simulate all 3 non-compliance are already sent
		for(Case FSMCase:lsCaseFSM){
			FSMCase.FS_Deadline_Date__c = system.today().addDays(-10);
			system.debug(Logginglevel.ERROR, 'DTULLO Account ID --> ' + FSMCase.AccountId);
			system.debug(Logginglevel.ERROR, 'DTULLO Contact ID --> ' + FSMCase.ContactId);
			FSMCase.status = 'Closed';
		}
		
		update lsCaseFSM;
		
		list<Case> lsNCCase = new list<Case>();
		
		//Create First non-compliance (correctly)
		for(Case FSMCase: lsCaseFSM)
			lsNCCase.add(getNCCase(FSMCase));
		
		try{
			insert lsNCCase;
		}catch(exception e){}
		
		system.assert(getInsertedNCCase().size() == 0);
		
		test.StopTest();
	}
	
	
	//First Non-compliance: Cargo with wrong New Ifap Deadline Date
	static testMethod void FirstNonComplianceTestOnlyCargo(){
		list<Case> lsCaseFSM = CreateFSMCases();
		
		lsCaseFSM = getFSMCases();
		
		system.assert(lsCaseFSM.size()>0);
		
		test.StartTest();
		
		list<Case> lsNCCase = new list<Case>();
		for(Case FSMCase: lsCaseFSM)
			FSMCase.FS_Deadline_Date__c = system.today().addDays(-10);
		
		update lsCaseFSM;
		
		for(Case FSMCase: lsCaseFSM){
			if(FSMCase.Account.Industry == CARGO){
				lsNCCase.add(getNCCase(FSMCase));
			}
		}
		
		system.assert(lsNCCase.size()>0);
		
		for(case NCCase:lsNCCase){
			NCCase.New_IFAP_Deadline_date__c = null;
		}
		
		try{
			insert lsNCCase;
		}catch(exception e){}
		
		system.assert(getInsertedNCCase().size()==0);
		
		for(case NCCase:lsNCCase){
			NCCase.New_IFAP_Deadline_date__c = system.today().addDays(-5);
		}
		
		try{
			insert lsNCCase;
		}catch(exception e){}
		
		system.assert(getInsertedNCCase().size()==0);
		
		for(case NCCase:lsNCCase){
			NCCase.New_IFAP_Deadline_date__c = system.today().addDays(5);
		}
		
		insert lsNCCase;
		
		system.assert(getInsertedNCCase().size()==lsNCCase.size());
		
		//loop through FSMCase (cargo only) and check dates
		for(Case FSMCase:getFSMCases()){
			if(FSMCase.Account.Industry==CARGO){
				system.assert(FSMCase.FS_Second_Deadline_Date__c == system.today().addDays(5));
				system.assert(FSMCase.firstFSnonComplianceDate__c==system.today());
			}
		}
		
		//SECOND NON-COMPLIANCE
		for(Case FSMCase: lsCaseFSM){
			FSMCase.FS_Second_Deadline_Date__c = system.today().addDays(-9);
		}
		
		update lsCaseFSM;
		
		lsNCCase.clear();
		
		for(Case FSMCase: lsCaseFSM){
			if(FSMCase.Account.Industry == CARGO){
				lsNCCase.add(getNCCase(FSMCase));
			}
		}
		
		system.assert(lsNCCase.size()>0);
		
		for(case NCCase:lsNCCase){
			NCCase.New_IFAP_Deadline_date__c = null;
		}
		
		try{
			insert lsNCCase;
		}catch(exception e){}
		
		system.assert(getInsertedNCCase().size()==lsNCCase.size());
		
		for(case NCCase:lsNCCase){
			NCCase.New_IFAP_Deadline_date__c = system.today().addDays(-5);
		}
		
		try{
			insert lsNCCase;
		}catch(exception e){}
		
		system.assert(getInsertedNCCase().size()==lsNCCase.size());
		
		for(case NCCase:lsNCCase){
			NCCase.New_IFAP_Deadline_date__c = system.today().addDays(5);
		}
		
		insert lsNCCase;
		
		system.assert(getInsertedNCCase().size()==lsNCCase.size()*2);
		
		test.StopTest();
	}
	
	
	static testMethod void TestUpdate(){
		list<Case> lsCaseFSM = CreateFSMCases();
		system.assert(lsCaseFSM.size()>0);
		
		test.StartTest();
		//simulate all 3 non-compliance are already sent
		for(Case FSMCase:lsCaseFSM){
			FSMCase.FS_Deadline_Date__c = system.today().addDays(-10);
		}
		
		update lsCaseFSM;
		
		list<Case> lsNCCase = new list<Case>();
		
		for(Case FSMCase: lsCaseFSM)
			lsNCCase.add(getNCCase(FSMCase));
		
		try{
			insert lsNCCase;
		}catch(exception e){}
		
		system.assert(getInsertedNCCase().size() == lsCaseFSM.size());
		
		
		for(Case FSMCase:lsCaseFSM){
			FSMCase.FS_Deadline_Date__c = null;
		}
		
		update lsCaseFSM;
		
		try{
			update lsNCCase;
		}catch(exception e){}
		
		system.assert(getInsertedNCCase().size() == lsCaseFSM.size());
		
		
		for(Case FSMCase:lsCaseFSM){
			FSMCase.FS_Deadline_Date__c = system.today().addDays(-10);
			FSMCase.Status = 'Closed';
		}
		
		update lsCaseFSM;
		
		try{
			update lsNCCase;
		}catch(exception e){}
		
		system.assert(getInsertedNCCase().size() == lsCaseFSM.size());
		
		
		test.StopTest();
	}
	
	static testMethod void TestMultiFSM(){
		list<Case> lsCaseFSM = CreateFSMCases();
		system.assert(lsCaseFSM.size()>0);
		
		test.StartTest();
		
		for(Case FSMCase:lsCaseFSM){
			FSMCase.FS_Deadline_Date__c = system.today().addDays(-10);
		}
		
		update lsCaseFSM;
		
		list<Case> lsNCCase = new list<Case>();
		
		//Create First non-compliance (correctly)
		for(Case FSMCase: lsCaseFSM)
			lsNCCase.add(getNCCase(FSMCase));
			
		for(Case FSMCase: lsCaseFSM)
			lsNCCase.add(getNCCase(FSMCase));
		
		try{
			insert lsNCCase;
		}catch(exception e){}
		
		system.assert(getInsertedNCCase().size() == 0);
		
		test.StopTest();
	}
}