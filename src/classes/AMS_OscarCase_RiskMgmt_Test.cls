@isTest
private class AMS_OscarCase_RiskMgmt_Test {
	@testsetup
	static void CreateData(){
		//Create countries
		list<IATA_ISO_Country__c> lsCountries = new list<IATA_ISO_Country__c>();
		lsCountries.add(New IATA_ISO_Country__c(Name='Country1', Enable_Risk_Change_Codes__c=false, iso_code__c='01'));
		lsCountries.add(New IATA_ISO_Country__c(Name='Country2', Enable_Risk_Change_Codes__c=true, iso_code__c='02'));
		insert lsCountries;
		
		//Create Accounts
		id AgencyRecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency') ;
		list<Account> lsAccntHO = new list<Account>();
		lsAccntHO.add(new Account(Name='Accnt1', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(0).Id, Location_Class__c='P', Location_type__c = 'HO', Status__c = 'Accredited', Reason__c = '90-MEETS CRITERIA'));	//Empty Location Class. Will give Error
		lsAccntHO.add(new Account(Name='Accnt2', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(1).Id, Location_Class__c='C', Location_type__c = 'HO', Status__c = 'Accredited', Reason__c = '90-MEETS CRITERIA'));
		lsAccntHO.add(new Account(Name='Accnt3', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(1).Id, Location_Class__c='P', Location_type__c = 'HO', Status__c = 'Accredited', Reason__c = '90-MEETS CRITERIA'));
		insert lsAccntHO;
		
		list<Account> lsAccntBR = new list<Account>();
		lsAccntBR.add(new Account(Name='Accnt3.1', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(1).Id, Location_Class__c='P', Location_type__c = 'BR', Status__c = 'Accredited', Reason__c = '90-MEETS CRITERIA', ParentId = lsAccntHO.get(2).Id));
		lsAccntBR.add(new Account(Name='Accnt3.2', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(1).Id, Location_Class__c='P', Location_type__c = 'BR', Status__c = 'Accredited', Reason__c = '90-MEETS CRITERIA', ParentId = lsAccntHO.get(2).Id));
		insert lsAccntBR;
		
		insert new Account(Name='Accnt3.1.1', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(1).Id, Location_Class__c='P', Location_type__c = 'SA', Status__c = 'Accredited', Reason__c = '90-MEETS CRITERIA', ParentId = lsAccntBR.get(0).Id);
		
		//Create configurations
		list<AMS_ChangeCodes__c> lsConf = new list<AMS_ChangeCodes__c>();
		lsConf.add(new AMS_ChangeCodes__c(Name='RRC', CHANGE_CODE__C='RRC', REASON_CODE__C='PREV', REASON_CODE_DESCRIPTION__C='PREV', RECORD_TYPE__C='SIDRA', FIELD1__C='REI_ApprovalRejectin__c', FIELD1VALUES__C='VALUES:Approved', FIELD2__C='Update_AIMS_REI_DEFWITH__c', FIELD2VALUES__C='not blank', FIELD3__C=null, FIELD3VALUES__C=null, FIELD4__C=null, FIELD4VALUES__C=null, FIELD5__C=null, FIELD5VALUES__C=null, FIELD6__C=null, FIELD6VALUES__C=null, ACCOUNT_STATUS_CHANGE__C=null, CLASS_TYPE__C='P;D;R', BULLETIN_MEMO_TEXT__C=null, BULLETIN_MEMO_TEXT2__C=null, BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='C', BILLABLE__C=TRUE, PUBLISHED_IN_BULLETIN__C=FALSE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=FALSE, CLEAR_IRREGULARITIES__C=FALSE, USED_BY_CNS__C=FALSE));
		lsConf.add(new AMS_ChangeCodes__c(Name='TER', CHANGE_CODE__C='TER', REASON_CODE__C='1', REASON_CODE_DESCRIPTION__C='DEFAULT NON SETTLEMENT', RECORD_TYPE__C='SIDRA', FIELD1__C='TER_Approval_Rejection__c', FIELD1VALUES__C='VALUES:Approved', FIELD2__C='Update_AIMS_TER__c', FIELD2VALUES__C='NOT Blank', FIELD3__C='Termination_Reason__c', FIELD3VALUES__C='VALUES:Non Payment;Financial criteria not met;Voluntary relinquishment', FIELD4__C=null, FIELD4VALUES__C=null, FIELD5__C=null, FIELD5VALUES__C=null, FIELD6__C=null, FIELD6VALUES__C=null, ACCOUNT_STATUS_CHANGE__C='0', CLASS_TYPE__C='P;D;C;R;Q;I', BULLETIN_MEMO_TEXT__C='Agent Terminated due to <Termination Reason>', BULLETIN_MEMO_TEXT2__C=null, BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='D', BILLABLE__C=FALSE, PUBLISHED_IN_BULLETIN__C=TRUE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=FALSE, CLEAR_IRREGULARITIES__C=FALSE, USED_BY_CNS__C=FALSE));
		lsConf.add(new AMS_ChangeCodes__c(Name='RWD', CHANGE_CODE__C='RWD', REASON_CODE__C='60', REASON_CODE_DESCRIPTION__C='NON COMPLIANCE TO ACCREDITATION CRITERIA', RECORD_TYPE__C='SIDRA_Lite', FIELD1__C='DEF_Withdrawal_Approval_Rejection__c', FIELD1VALUES__C='VALUES:Approved', FIELD2__C='DEF_Withdrawal_Reason__c', FIELD2VALUES__C='VALUES:Internal IATA error;No change evidence received;Other', FIELD3__C='ChangeCode', FIELD3VALUES__C='EXISTS:SRM', FIELD4__C='Update_AIMS_REI_DEFWITH__c', FIELD4VALUES__C='not blank', FIELD5__C=null, FIELD5VALUES__C=null, FIELD6__C=null, FIELD6VALUES__C=null, ACCOUNT_STATUS_CHANGE__C='PREV', CLASS_TYPE__C='P;D;C;R', BULLETIN_MEMO_TEXT__C='Agency complies with the accreditation criteria. Agent is reinstated and review status is withdrawn', BULLETIN_MEMO_TEXT2__C=null, BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='C', BILLABLE__C=FALSE, PUBLISHED_IN_BULLETIN__C=TRUE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=FALSE, CLEAR_IRREGULARITIES__C=FALSE, USED_BY_CNS__C=FALSE));
		lsConf.add(new AMS_ChangeCodes__c(Name='RCR', CHANGE_CODE__C='RCR', REASON_CODE__C='91', REASON_CODE_DESCRIPTION__C='MEETS CRITERIA', RECORD_TYPE__C='SIDRA_Lite', FIELD1__C='Update_AIMS_DEF__c', FIELD1VALUES__C='NOT BLANK', FIELD2__C='DEF_Withdrawal_Approval_Rejection__c', FIELD2VALUES__C='VALUES:Approved', FIELD3__C='Update_AIMS_REI_DEFWITH__c', FIELD3VALUES__C='NOT BLANK', FIELD4__C=null, FIELD4VALUES__C=null, FIELD5__C=null, FIELD5VALUES__C=null, FIELD6__C=null, FIELD6VALUES__C=null, ACCOUNT_STATUS_CHANGE__C='9', CLASS_TYPE__C='P;D;C;R;Q;I', BULLETIN_MEMO_TEXT__C='Agent reinstated after default following: <SIDRA Lite Reason>',	BULLETIN_MEMO_TEXT2__C=null, BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='C', BILLABLE__C=TRUE, PUBLISHED_IN_BULLETIN__C=TRUE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=FALSE, CLEAR_IRREGULARITIES__C=TRUE, USED_BY_CNS__C=FALSE));
		lsConf.add(new AMS_ChangeCodes__c(Name='DEF', CHANGE_CODE__C='DEF', REASON_CODE__C='53', REASON_CODE_DESCRIPTION__C='DEFAULT ACCUM. IRREGULARITIES - NON COMPLIANCE', RECORD_TYPE__C='SIDRA_Lite', FIELD1__C='SIDRA_Lite_Reason__c', FIELD1VALUES__C='VALUES:Financial Review Non-compliance;Financial Security Non-compliance;Annual fees', FIELD2__C='DEF_Approval_Rejection__c', FIELD2VALUES__C='VALUES:Approved', FIELD3__C='Reason_for_Default__c', FIELD3VALUES__C='VALUES:Technical Default', FIELD4__C='Update_AIMS_DEF__c', FIELD4VALUES__C='NOT Blank', FIELD5__C=null, FIELD5VALUES__C=null, FIELD6__C=null, FIELD6VALUES__C=null, ACCOUNT_STATUS_CHANGE__C='5', CLASS_TYPE__C='P;D', BULLETIN_MEMO_TEXT__C='Agent is placed under Default due to <SIDRA Lite Reason>.  <IRRS Sequence> Agent is served Notice of Termination by <Termination Date>.  ISS Management is withdrawing ticketing authoirty and will demand an immediate accounting and settlement of',	BULLETIN_MEMO_TEXT2__C='amounts owing up to date of default. Financial Security furnished by Agent<Financial Securities>.', BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='C', BILLABLE__C=FALSE, PUBLISHED_IN_BULLETIN__C=TRUE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=TRUE, CLEAR_IRREGULARITIES__C=FALSE, USED_BY_CNS__C=FALSE));
		lsConf.add(new AMS_ChangeCodes__c(Name='STR', CHANGE_CODE__C='STR', REASON_CODE__C='PREV', REASON_CODE_DESCRIPTION__C='PREV', RECORD_TYPE__C='SIDRA_Lite', FIELD1__C='DEF_Withdrawal_Approval_Rejection__c', FIELD1VALUES__C='VALUES:Approved', FIELD2__C='Update_AIMS_REI_DEFWITH__c', FIELD2VALUES__C='NOT Blank', FIELD3__C='NOT_Date__c', FIELD3VALUES__C='Blank', FIELD4__C='Shut_Down_TKT_System_GDS_and_BSPlink__c', FIELD4VALUES__C='not blank', FIELD5__C=null, FIELD5VALUES__C=null, FIELD6__C=null, FIELD6VALUES__C=null, ACCOUNT_STATUS_CHANGE__C='PREV', CLASS_TYPE__C='P;D', BULLETIN_MEMO_TEXT__C='The removal of STDs will no longer apply as Agent submitted the requested Notice of Change', BULLETIN_MEMO_TEXT2__C=null, BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='C', BILLABLE__C=TRUE, PUBLISHED_IN_BULLETIN__C=TRUE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=TRUE, CLEAR_IRREGULARITIES__C=FALSE, USED_BY_CNS__C=FALSE));
		lsConf.add(new AMS_ChangeCodes__c(Name='IRR', CHANGE_CODE__C='IRR', REASON_CODE__C='PREV', REASON_CODE_DESCRIPTION__C='PREV', RECORD_TYPE__C='SIDRA_Lite', FIELD1__C='SIDRA_Lite_Reason__c', FIELD1VALUES__C='VALUES:Financial Review Non-compliance', FIELD2__C='IRR_Approval_Rejection__c', FIELD2VALUES__C='VALUES:Approved', FIELD3__C='Update_AIMS_IRR__c', FIELD3VALUES__C='NOT Blank', FIELD4__C=null, FIELD4VALUES__C=null, FIELD5__C=null, FIELD5VALUES__C=null, FIELD6__C=null, FIELD6VALUES__C=null, ACCOUNT_STATUS_CHANGE__C=null, CLASS_TYPE__C='P;D;C', BULLETIN_MEMO_TEXT__C='Agent is served Notice of Irregularity due to <SIDRA Lite Reason> , agent is given 30 days to submit the required documents.  No monies outstanding', BULLETIN_MEMO_TEXT2__C=null, BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='C', BILLABLE__C=FALSE, PUBLISHED_IN_BULLETIN__C=TRUE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=FALSE, CLEAR_IRREGULARITIES__C=FALSE, USED_BY_CNS__C=FALSE));
		lsConf.add(new AMS_ChangeCodes__c(Name='IRW', CHANGE_CODE__C='IRW', REASON_CODE__C='PREV', REASON_CODE_DESCRIPTION__C='PREV', RECORD_TYPE__C='SIDRA_Lite', FIELD1__C='SIDRA_Lite_Reason__c', FIELD1VALUES__C='VALUES:Financial Review Non-compliance;Financial Security Non-compliance;Annual fees', FIELD2__C='IRR_Withdrawal_Approval_Rejection__c', FIELD2VALUES__C='VALUES:Approved', FIELD3__C='IRR_Withdrawal_Reason__c', FIELD3VALUES__C='VALUES:Exception raised', FIELD4__C='Update_AIMS_IRRWITH__c', FIELD4VALUES__C='NOT Blank', FIELD5__C=null, FIELD5VALUES__C=null, FIELD6__C=null, FIELD6VALUES__C=null, ACCOUNT_STATUS_CHANGE__C='PREV', CLASS_TYPE__C='P;D;C;R;Q;I', BULLETIN_MEMO_TEXT__C='Withdrawal of Irregularity due to Agency Administrator\'s decision', BULLETIN_MEMO_TEXT2__C=null, BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='C', BILLABLE__C=FALSE, PUBLISHED_IN_BULLETIN__C=TRUE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=FALSE, CLEAR_IRREGULARITIES__C=FALSE, USED_BY_CNS__C=FALSE));
		insert lsConf;
	}
	
	private static id SIDRALiteRTId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('SIDRA_Lite');
	private static id SIDRARTId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('SIDRA');
	
    static testMethod void TestCountryNotPilot(){
    	Account a = [select id from Account where name='Accnt1'];
    	Case SidraLiteCase = new Case();
    	SidraLiteCase.AccountId = a.Id;
    	SidraLiteCase.recordtypeId = SIDRALiteRTId;
    	insert SidraLiteCase;
    	
    	test.StartTest();
    	
    	SidraLiteCase.Update_AIMS_DEF__c = system.Now();
    	SidraLiteCase.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
    	SidraLiteCase.Update_AIMS_REI_DEFWITH__c = system.Now();
    	SidraLiteCase.DEF_Withdrawal_Reason__c = 'Administrative error';
    	
    	update SidraLiteCase;
    	
    	system.assertEquals(0, [Select id from Agency_applied_change_code__c where account__c = :a.Id].size(), 'No Change Code Created because country is not enabled');
    	test.StopTest();
    }
    
    static testMethod void TestCCToSingleAgency(){
    	test.StartTest();
    	Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt2'];
    	
    	Case SidraLiteCase = new Case();
    	SidraLiteCase.AccountId = a.Id;
    	SidraLiteCase.recordtypeId = SIDRALiteRTId;
    	SidraLiteCase.DEF_Withdrawal_Reason__c = 'Administrative error';
		SidraLiteCase.Update_AIMS_DEF__c = system.Now();
    	SidraLiteCase.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
    	SidraLiteCase.Update_AIMS_REI_DEFWITH__c = system.Now();
		insert SidraLiteCase;
    	
    	system.assertEquals(1, [Select id from Agency_applied_change_code__c where account__c = :a.Id].size(), 'Change Code Created because country is enabled');
    	test.StopTest();
    }
    
    
    static testMethod void TestCCToAllHierarchyFromSA(){
    	test.StartTest();

    	Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt3.1.1'];
    	Case SidraLiteCase = new Case();
    	SidraLiteCase.AccountId = a.Id;
    	SidraLiteCase.recordtypeId = SIDRALiteRTId;
    	SidraLiteCase.DEF_Withdrawal_Reason__c = 'Administrative error';
    	SidraLiteCase.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
    	SidraLiteCase.Update_AIMS_REI_DEFWITH__c = system.now();
    	SidraLiteCase.Shut_Down_TKT_System_GDS_and_BSPlink__c = system.Now();
    	insert SidraLiteCase;
    	
    	system.assertEquals(1, [Select id from Agency_applied_change_code__c where account__r.Name = :'Accnt3'].size(), 'Change Code Created for whole hierarchy - HO');
    	system.assertEquals(1, [Select id from Agency_applied_change_code__c where account__r.Name = :'Accnt3.1'].size(), 'Change Code Created for whole hierarchy - BR1');
    	system.assertEquals(1, [Select id from Agency_applied_change_code__c where account__r.Name = :'Accnt3.2'].size(), 'Change Code Created for whole hierarchy - BR2');
    	system.assertEquals(1, [Select id from Agency_applied_change_code__c where account__r.Name = :'Accnt3.1.1'].size(), 'Change Code Created for whole hierarchy - SA');
    	
    	test.StopTest();
    }
    
    static testMethod void TestCCToAllHierarchyFromBR(){
    	test.StartTest();

    	Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt3.1'];
    	Case SidraLiteCase = new Case();
    	SidraLiteCase.AccountId = a.Id;
    	SidraLiteCase.recordtypeId = SIDRALiteRTId;
    	SidraLiteCase.DEF_Withdrawal_Reason__c = 'Administrative error';
    	SidraLiteCase.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
    	SidraLiteCase.Update_AIMS_REI_DEFWITH__c = system.now();
    	SidraLiteCase.Shut_Down_TKT_System_GDS_and_BSPlink__c = system.Now();
    	insert SidraLiteCase;
    	
    	system.assertEquals(1, [Select id from Agency_applied_change_code__c where account__r.Name = :'Accnt3'].size(), 'Change Code Created for whole hierarchy - HO');
    	system.assertEquals(1, [Select id from Agency_applied_change_code__c where account__r.Name = :'Accnt3.1'].size(), 'Change Code Created for whole hierarchy - BR1');
    	system.assertEquals(1, [Select id from Agency_applied_change_code__c where account__r.Name = :'Accnt3.2'].size(), 'Change Code Created for whole hierarchy - BR2');
    	system.assertEquals(1, [Select id from Agency_applied_change_code__c where account__r.Name = :'Accnt3.1.1'].size(), 'Change Code Created for whole hierarchy - SA');
    	
    	test.StopTest();
    }
    
    
    static testMethod void TestNewIrregularity(){
    	test.StartTest();
    	
    	Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt2'];

    	Case SidraLiteCase = new Case();
			SidraLiteCase.AccountId = a.Id;
			SidraLiteCase.recordtypeId = SIDRALiteRTId;
	    	SidraLiteCase.SIDRA_Lite_Reason__c = 'Financial Review Non-compliance';
	    	SidraLiteCase.IRR_Approval_Rejection__c = 'Approved';
	    	SidraLiteCase.IRR_Approval_Rejection_Date__c = system.now();
	    	SidraLiteCase.Update_AIMS_IRR__c = system.Now();
	    	SidraLiteCase.IRR_Type__c = 'Double Irregularity';
	    	SidraLiteCase.CS_Rep_Acc_IRR_DEF__c = userinfo.getUserId();
    	insert SidraLiteCase;
    	
    	list<Agency_applied_change_code__c> AACC = [select id, Change_code__c, Operation__c, Irregularities_Points__c from Agency_applied_Change_code__c where Account__c =:a.Id];
    	
    	system.assertEquals(1, AACC.size(), '1 IRR Created');
    	system.assertEquals('IRR', AACC.get(0).Change_code__c, 'IRR Created');
    	system.assertEquals('A', AACC.get(0).Operation__c, 'Addition IRR Created');
    	system.assertEquals(2, AACC.get(0).Irregularities_Points__c, '1 IRR Created with 2 points created');
    	system.assertEquals(2, [select Accumulated_irregularities__c from Account where id =: a.id].Accumulated_Irregularities__C, 'Total Acc Irr: 2');
    	
    	test.StopTest();
    	
    }
    
    static testMethod void TestIrregularityWithdrawn(){
    	Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt2'];
		
		list<Agency_applied_change_code__c> lsCC = new list<Agency_applied_change_code__c>();
    	lsCC.add(new Agency_Applied_change_code__c(Account__c = a.Id, Change_code__c = 'IRR', Effective_date__c = system.today(), Irregularities_Points__c=2, Operation__c='A', AIMS_ID__c='1'));
    	lsCC.add(new Agency_Applied_change_code__c(Account__c = a.Id, Change_code__c = 'IRR', Effective_date__c = system.today(), Irregularities_Points__c=2, Operation__c='A', AIMS_ID__c='2'));
    	insert lsCC;
    	
    	system.assertEquals(4, [select Accumulated_irregularities__c from Account where id =: a.id].Accumulated_Irregularities__C, 'Total Acc Irr: 4');

    	test.StartTest();
    	
    	//WithDraw 1 IRR
    	Case SidraLiteCase3 = new Case();
    		SidraLiteCase3.AccountId = a.Id;
			SidraLiteCase3.recordtypeId = SIDRALiteRTId;
			SidraLiteCase3.SIDRA_Lite_Reason__c = 'Annual fees';
	    	SidraLiteCase3.IRR_Withdrawal_Approval_Rejection__c = 'Approved';
	    	SidraLiteCase3.IRR_Withdrawal_Reason__c = 'Exception raised';
	    	SidraLiteCase3.Update_AIMS_IRRWITH__c = system.Now();
	    	SidraLiteCase3.CS_Rep_Acc_IRR_DEF__c = userinfo.getUserId();
	    	SidraLiteCase3.IRR_Type__c = 'Double Irregularity';
    	insert SidraLiteCase3;
    	
    	for(Agency_applied_Change_code__c aa:[select id, Change_code__c, Operation__c, recordtype.developername, Irregularities_Points__c from Agency_applied_Change_code__c where Account__c = :a.Id])
			system.debug(Logginglevel.ERROR, 'DTULLO 180 IRR Type. ' + aa.RecordType.DeveloperName + ' - ' + aa.Operation__c + ' - ' + aa.Change_code__c + ' - ' +aa.Irregularities_Points__c);
    	
    	system.assertEquals(3, [select id from Agency_applied_Change_code__c where Account__c =:a.Id].size(), '3 IRRS: 2 A and 1 W');
    	system.assertEquals(2, [select Accumulated_irregularities__c from Account where id =: a.id].Accumulated_Irregularities__C, 'Total Acc Irr: 2');
    	
    	test.StopTest();
    }
    
    static testMethod void TestClearAllIRRs(){
    	Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt2'];
    	list<Agency_applied_change_code__c> lsCC = new list<Agency_applied_change_code__c>();
    	lsCC.add(new Agency_Applied_change_code__c(Account__c = a.Id, Change_code__c = 'IRR', Effective_date__c = system.today(), Irregularities_Points__c=2, Operation__c='A', AIMS_ID__c='1'));
    	lsCC.add(new Agency_Applied_change_code__c(Account__c = a.Id, Change_code__c = 'IRR', Effective_date__c = system.today(), Irregularities_Points__c=2, Operation__c='A', AIMS_ID__c='2'));
    	lsCC.add(new Agency_Applied_change_code__c(Account__c = a.Id, Change_code__c = 'IRW', Effective_date__c = system.today(), Irregularities_Points__c=2, Operation__c='W', AIMS_ID__c='3'));
    	
    	insert lsCC;
    	
    	system.assertEquals(2, [select Accumulated_irregularities__c from Account where id =: a.id].Accumulated_Irregularities__C, 'Starting with 2 Accumulated Irregularities');
		
    	test.StartTest();
    	//Generate a change code that will clear all IRRS:
    	Case SidraLiteCase4 = new Case();
	    	SidraLiteCase4.AccountId = a.Id;
			SidraLiteCase4.recordtypeId = SIDRALiteRTId;
	    	SidraLiteCase4.Update_AIMS_DEF__c = system.Now();
	    	SidraLiteCase4.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
	    	SidraLiteCase4.Update_AIMS_REI_DEFWITH__c = system.now();
	    	SidraLiteCase4.CS_Rep_Acc_IRR_DEF__c = userinfo.getUserId();
	    	SidraLiteCase4.DEF_Withdrawal_Reason__c = 'Other';
	    	SidraLiteCase4.IRR_Type__c = 'Double Irregularity';
		insert SidraLiteCase4;
		
		
    	system.assertEquals(4, [select id from Agency_applied_Change_code__c where Account__c =:a.Id].size(), '3 IRR still remains + RCR');
    	system.assertEquals(0, [select Accumulated_irregularities__c from Account where id =: a.id].Accumulated_Irregularities__C, 'Total Acc Irr: 0 - Cleared');
    	
    	test.StopTest();
    }
    
    static testMethod void TestBulletinMemoText(){
    	Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt2'];
    	Financial_Institution__c FI = new Financial_Institution__c(Name = 'FI1', INSTITUTION_TYPE__C='Bank');
    	insert FI; 
    	Financial_Security__c FS = new Financial_Security__c(CURRENCYISOCODE='USD', Account__c=a.Id, AMOUNT__C=3000, EXPIRY_DATE__C=system.Today().AddDays(100), FINANCIAL_INSTITUTION__c=FI.Id, SECURITY_STATUS__C='Active', Security_Type__c='Bank Guarantee');
    	insert FS;
    	
    	Case SidraLiteCase4 = new Case();
	    	SidraLiteCase4.AccountId = a.Id;
			SidraLiteCase4.recordtypeId = SIDRALiteRTId;
	    	SidraLiteCase4.Update_AIMS_DEF__c = system.Now();
	    	SidraLiteCase4.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
	    	SidraLiteCase4.Update_AIMS_REI_DEFWITH__c = system.now();
	    	SidraLiteCase4.CS_Rep_Acc_IRR_DEF__c = userinfo.getUserId();
	    	SidraLiteCase4.Termination_date_manual_entry__c = system.today();
	    	SidraLiteCase4.DEF_Withdrawal_Reason__c='Bank error';
	    	SIdraLiteCase4.SIDRA_Lite_Reason__c = 'Annual Fees';
	    	SidraLiteCase4.End_of_Grace_Period_Date__c = system.Today().addDays(15);
	    	SidraLiteCase4.IRR_Withdrawal_Reason__c = 'Exception raised';
	    	SidraLiteCase4.Outstanding_Amount__c = 3000;
	    	SidraLiteCase4.Termination_Reason__c = 'Non Payment';
		insert SidraLiteCase4;
		
    	test.StartTest();
    	string sMemo1 = '<Termination Date> <Financial Securities> <DEF Withdrawal reason> <SIDRA Lite Reason>';
    	string sMemo2 = ' <End Grace Period Date> <IRR Withdrawal Reason> <Outstanding Amount> <Termination Reason>';
    	string sMemo3 = ' <Update AIMS-DEF>';
    	
    	list<Case> lsCase = [select id, recordType.DeveloperName, DEF_Withdrawal_Approval_Rejection__c, DEF_Withdrawal_Reason__c, DEF_Approval_Rejection__c, End_of_Grace_Period_Date__c, 
								  Shut_Down_TKT_System_GDS_and_BSPlink__c, IRR_Approval_Rejection__c, IRR_Withdrawal_Approval_Rejection__c, IRR_Withdrawal_Reason__c, NOT_Date__c, NOT_Sent__c, 
								  Notify_Agreement_Approval_to_AG__c, Reason_for_Default__c, REI_ApprovalRejectin__c, Repayment_Schedule_Approval__c, SIDRA_Lite_Reason__c, TER_Approval_Rejection__c, 
								  Termination_Reason__c, Ticketing_Authority_Re_assigned__c, Update_AIMS_DEF__c, Update_AIMS_IRR__c, Update_AIMS_IRRWITH__c, Update_AIMS_REI_DEFWITH__c, 
								  Update_AIMS_Repayment_agreed__c, Update_AIMS_TER__c, Parent.OSCAR__r.Type_of_change__c, Parent.OSCAR__c, IRR_Approval_Rejection_Date__c, IRR_Type__c,
								  Termination_date__c, Outstanding_Amount__c, 
								  Account.Location_Class__c, AccountId, Account.Status__c, Account.PreviousStatus__c, Account.Previous_Reason__c, Account.Reason__c, Account.Accumulated_Irregularities__c, Account.IATA_ISO_Country__r.Enable_Risk_Change_Codes__c
								  from case where AccountId = :a.Id];
    	
    	list<Financial_Security__c> lsFS = [select id, Unlimited_Security__c, Account__c, Amount__c, CurrencyIsoCode, Expiry_Date__c 
										  from Financial_Security__c 
										  where Account__c = :a.Id];
    	
    	string s = AMS_OscarCase_RiskMgmt.GenerateMemoText(lsCase.get(0), null, sMemo1, sMemo2, sMemo3, null, lsFS);
    	
    	test.StopTest();
    }
    
    
    /*
    static testMethod void TestPilotCountryIRRWithdrawn(){
    	test.StartTest();
    	
    	Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt2'];

    	Case SidraLiteCase = new Case();
			SidraLiteCase.AccountId = a.Id;
			SidraLiteCase.recordtypeId = SIDRALiteRTId;
	    	SidraLiteCase.SIDRA_Lite_Reason__c = 'Financial Review Non-compliance';
	    	SidraLiteCase.IRR_Approval_Rejection__c = 'Approved';
	    	SidraLiteCase.IRR_Approval_Rejection_Date__c = system.now();
	    	SidraLiteCase.Update_AIMS_IRR__c = system.Now();
	    	SidraLiteCase.IRR_Type__c = 'Double Irregularity';
	    	SidraLiteCase.CS_Rep_Acc_IRR_DEF__c = userinfo.getUserId();
    	insert SidraLiteCase;
    	
    	list<Agency_applied_change_code__c> AACC = [select id, Change_code__c, Operation__c, Irregularities_Points__c from Agency_applied_Change_code__c where Account__c =:a.Id];
    	
    	system.assertEquals(1, AACC.size(), '1 IRR Created');
    	system.assertEquals('IRR', AACC.get(0).Change_code__c, 'IRR Created');
    	system.assertEquals('A', AACC.get(0).Operation__c, 'Addition IRR Created');
    	system.assertEquals(2, AACC.get(0).Irregularities_Points__c, '1 IRR Created with 2 points created');
    	system.assertEquals(2, [select Accumulated_irregularities__c from Account where id =: a.id].Accumulated_Irregularities__C, 'Total Acc Irr: 2');
    	
    	AACC.clear();
		
		AMS_OscarCase_RiskMgmt.EndRun();
		
    	Case SidraLiteCase2 = new Case();
	    	SidraLiteCase2.AccountId = a.Id;
			SidraLiteCase2.recordtypeId = SIDRALiteRTId;
	    	SidraLiteCase2.SIDRA_Lite_Reason__c = 'Financial Review Non-compliance';
	    	SidraLiteCase2.IRR_Approval_Rejection__c = 'Approved';
	    	SidraLiteCase2.IRR_Approval_Rejection_Date__c = system.now();
	    	SidraLiteCase2.Update_AIMS_IRR__c = system.Now();
	    	SidraLiteCase2.IRR_Type__c = 'Double Irregularity';
	    	SidraLiteCase2.CS_Rep_Acc_IRR_DEF__c = userinfo.getUserId();
    	insert SidraLiteCase2;
    	
    	AACC = [select id, Change_code__c, Operation__c, Irregularities_Points__c from Agency_applied_Change_code__c where Account__c =:a.Id];
    	
    	system.assertEquals(2, AACC.size(), '2nd IRR Created');
    	system.assertEquals(4, [select Accumulated_irregularities__c from Account where id =: a.id].Accumulated_Irregularities__C, 'Total Acc Irr: 4');
    	
    	AMS_OscarCase_RiskMgmt.EndRun();
    	
    	//WithDraw 1 IRR
    	Case c3 = [select id, IRR_Withdrawal_Approval_Rejection__c, IRR_Withdrawal_Reason__c, Update_AIMS_IRRWITH__c from Case where id=:SidraLiteCase.Id];
	    	c3.IRR_Withdrawal_Approval_Rejection__c = 'Approved';
	    	c3.IRR_Withdrawal_Reason__c = 'Exception raised';
	    	c3.Update_AIMS_IRRWITH__c = system.Now();
	    	c3.CS_Rep_Acc_IRR_DEF__c = userinfo.getUserId();
    	update c3;
    	
    	system.assertEquals(2, [select id from Agency_applied_Change_code__c where Account__c =:a.Id].size(), '2 IRR still remains');
    	system.assertEquals(2, [select Accumulated_irregularities__c from Account where id =: a.id].Accumulated_Irregularities__C, 'Total Acc Irr: 2');
    	
    	AMS_OscarCase_RiskMgmt.EndRun();
    	
    	//Generate a change code that will clear all IRRS:
    	Case SidraLiteCase4 = new Case();
	    	SidraLiteCase4.AccountId = a.Id;
			SidraLiteCase4.recordtypeId = SIDRALiteRTId;
	    	SidraLiteCase4.Update_AIMS_DEF__c = system.Now();
	    	SidraLiteCase4.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
	    	SidraLiteCase4.Update_AIMS_REI_DEFWITH__c = system.now();
	    	SidraLiteCase4.CS_Rep_Acc_IRR_DEF__c = userinfo.getUserId();
		insert SidraLiteCase4;
		    	
    	system.assertEquals(2, [select id from Agency_applied_Change_code__c where Account__c =:a.Id].size(), '2 IRR still remains');
    	system.assertEquals(0, [select Accumulated_irregularities__c from Account where id =: a.id].Accumulated_Irregularities__C, 'Total Acc Irr: 0 - Cleared');
    	
    	test.StopTest();
    }*/
}