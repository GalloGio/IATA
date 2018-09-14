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
        lsAccntHO.add(new Account(Name='Accnt1', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(0).Id, Location_Class__c='P', Location_type__c = 'HO', Status__c = 'Approved', Reason__c = '90-MEETS CRITERIA')); //Empty Location Class. Will give Error
        lsAccntHO.add(new Account(Name='Accnt2', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(1).Id, Location_Class__c='C', Location_type__c = 'HO', Status__c = 'Approved', Reason__c = '90-MEETS CRITERIA'));
        lsAccntHO.add(new Account(Name='Accnt3', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(1).Id, Location_Class__c='P', Location_type__c = 'HO', Status__c = 'Approved', Reason__c = '90-MEETS CRITERIA'));
        insert lsAccntHO;

        list<Account> lsAccntBR = new list<Account>();
        lsAccntBR.add(new Account(Name='Accnt3.1', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(1).Id, Location_Class__c='P', Location_type__c = 'BR', Status__c = 'Approved', Reason__c = '90-MEETS CRITERIA', ParentId = lsAccntHO.get(2).Id));
        lsAccntBR.add(new Account(Name='Accnt3.2', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(1).Id, Location_Class__c='P', Location_type__c = 'BR', Status__c = 'Approved', Reason__c = '90-MEETS CRITERIA', ParentId = lsAccntHO.get(2).Id));
        insert lsAccntBR;

        insert new Account(Name='Accnt3.1.1', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(1).Id, Location_Class__c='P', Location_type__c = 'SA', Status__c = 'Approved', Reason__c = '90-MEETS CRITERIA', ParentId = lsAccntBR.get(0).Id);

        //Create configurations
        list<AMS_ChangeCodes__c> lsConf = new list<AMS_ChangeCodes__c>();
        lsConf.add(new AMS_ChangeCodes__c(Name='RRC', CHANGE_CODE__C='RRC', REASON_CODE__C='PREV', REASON_CODE_DESCRIPTION__C='PREV', RECORD_TYPE__C='SIDRA', FIELD1__C='REI_ApprovalRejectin__c', FIELD1VALUES__C='VALUES:Approved', FIELD2__C='Update_AIMS_REI_DEFWITH__c', FIELD2VALUES__C='not blank', FIELD3__C=null, FIELD3VALUES__C=null, FIELD4__C=null, FIELD4VALUES__C=null, FIELD5__C=null, FIELD5VALUES__C=null, FIELD6__C=null, FIELD6VALUES__C=null, ACCOUNT_STATUS_CHANGE__C=null, CLASS_TYPE__C='P;D;R', BULLETIN_MEMO_TEXT__C=null, BULLETIN_MEMO_TEXT2__C=null, BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='C', BILLABLE__C=TRUE, PUBLISHED_IN_BULLETIN__C=FALSE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=FALSE, CLEAR_IRREGULARITIES__C=FALSE, USED_BY_CNS__C=FALSE));
        lsConf.add(new AMS_ChangeCodes__c(Name='TER', CHANGE_CODE__C='TER', REASON_CODE__C='1', REASON_CODE_DESCRIPTION__C='DEFAULT NON SETTLEMENT', RECORD_TYPE__C='SIDRA', FIELD1__C='TER_Approval_Rejection__c', FIELD1VALUES__C='VALUES:Approved', FIELD2__C='Update_AIMS_TER__c', FIELD2VALUES__C='NOT Blank', FIELD3__C='Termination_Reason__c', FIELD3VALUES__C='VALUES:Non Payment;Financial criteria not met;Voluntary relinquishment', FIELD4__C=null, FIELD4VALUES__C=null, FIELD5__C=null, FIELD5VALUES__C=null, FIELD6__C=null, FIELD6VALUES__C=null, ACCOUNT_STATUS_CHANGE__C='0', CLASS_TYPE__C='P;D;C;R;Q;I', BULLETIN_MEMO_TEXT__C='Agent Terminated due to <Termination Reason>', BULLETIN_MEMO_TEXT2__C=null, BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='D', BILLABLE__C=FALSE, PUBLISHED_IN_BULLETIN__C=TRUE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=FALSE, CLEAR_IRREGULARITIES__C=FALSE, USED_BY_CNS__C=FALSE));
        lsConf.add(new AMS_ChangeCodes__c(Name='FPY', CHANGE_CODE__C='FPY', REASON_CODE__C='1', REASON_CODE_DESCRIPTION__C='DEFAULT NON SETTLEMENT', RECORD_TYPE__C='SIDRA_Lite', FIELD1__C='IRR_Approval_Rejection__c', FIELD1VALUES__C='VALUES:Approved', FIELD2__C='Update_AIMS_IRR__c', FIELD2VALUES__C='NOT Blank', FIELD3__C='DEF_Approval_Rejection__c', FIELD3VALUES__C='NOT EQUAL TO:Approved', FIELD4__C='End_of_Grace_Period_Date__c', FIELD4VALUES__C='NOT Blank', FIELD5__C='Current_Outstanding_Amount_USD__c', FIELD5VALUES__C='<=:50', FIELD6__C='Current_Outstanding_Amount_USD__c', FIELD6VALUES__C='>:0', ACCOUNT_STATUS_CHANGE__C='0', CLASS_TYPE__C='P;D;C;R;Q;I', BULLETIN_MEMO_TEXT__C='Further to Irregularity served, no further action taken since the Agent has remitted full payment <PLS NOTE CHANGE ALSO APPLIES TO ALL BR LOCATIONS>', BULLETIN_MEMO_TEXT2__C=null, BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='D', BILLABLE__C=FALSE, PUBLISHED_IN_BULLETIN__C=TRUE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=FALSE, CLEAR_IRREGULARITIES__C=FALSE, USED_BY_CNS__C=FALSE));
        lsConf.add(new AMS_ChangeCodes__c(Name='FPL', CHANGE_CODE__C='FPL', REASON_CODE__C='1', REASON_CODE_DESCRIPTION__C='DEFAULT NON SETTLEMENT', RECORD_TYPE__C='SIDRA_Lite', FIELD1__C='IRR_Approval_Rejection__c', FIELD1VALUES__C='VALUES:Approved', FIELD2__C='Update_AIMS_IRR__c', FIELD2VALUES__C='NOT Blank', FIELD3__C='DEF_Approval_Rejection__c', FIELD3VALUES__C='NOT EQUAL TO:Approved', FIELD4__C='End_of_Grace_Period_Date__c', FIELD4VALUES__C='NOT Blank', FIELD5__C='Current_Outstanding_Amount_USD__c', FIELD5VALUES__C='>=:50', FIELD6__C='Current_Outstanding_Amount_USD__c', FIELD6VALUES__C='<:100', ACCOUNT_STATUS_CHANGE__C='0', CLASS_TYPE__C='P;D;C;R;Q;I', BULLETIN_MEMO_TEXT__C='Further to Irregularity served, no further action taken since the Agent has remitted full payment <PLS NOTE CHANGE ALSO APPLIES TO ALL BR LOCATIONS>', BULLETIN_MEMO_TEXT2__C=null, BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='D', BILLABLE__C=FALSE, PUBLISHED_IN_BULLETIN__C=TRUE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=FALSE, CLEAR_IRREGULARITIES__C=FALSE, USED_BY_CNS__C=FALSE));
        lsConf.add(new AMS_ChangeCodes__c(Name='RWD', CHANGE_CODE__C='RWD', REASON_CODE__C='60', REASON_CODE_DESCRIPTION__C='NON COMPLIANCE TO ACCREDITATION CRITERIA', RECORD_TYPE__C='SIDRA_Lite', FIELD1__C='DEF_Withdrawal_Approval_Rejection__c', FIELD1VALUES__C='VALUES:Approved', FIELD2__C='DEF_Withdrawal_Reason__c', FIELD2VALUES__C='VALUES:Internal IATA error;No change evidence received;Other', FIELD3__C='ChangeCode', FIELD3VALUES__C='EXISTS:SRM', FIELD4__C='Update_AIMS_REI_DEFWITH__c', FIELD4VALUES__C='not blank', FIELD5__C=null, FIELD5VALUES__C=null, FIELD6__C=null, FIELD6VALUES__C=null, ACCOUNT_STATUS_CHANGE__C='PREV', CLASS_TYPE__C='P;D;C;R', BULLETIN_MEMO_TEXT__C='Agency complies with the accreditation criteria. Agent is reinstated and review status is withdrawn', BULLETIN_MEMO_TEXT2__C=null, BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='C', BILLABLE__C=FALSE, PUBLISHED_IN_BULLETIN__C=TRUE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=FALSE, CLEAR_IRREGULARITIES__C=FALSE, USED_BY_CNS__C=FALSE));
        lsConf.add(new AMS_ChangeCodes__c(Name='RCR', CHANGE_CODE__C='RCR', REASON_CODE__C='91', REASON_CODE_DESCRIPTION__C='MEETS CRITERIA', RECORD_TYPE__C='SIDRA_Lite', FIELD1__C='Update_AIMS_DEF__c', FIELD1VALUES__C='NOT BLANK', FIELD2__C='DEF_Withdrawal_Approval_Rejection__c', FIELD2VALUES__C='VALUES:Approved', FIELD3__C='Update_AIMS_REI_DEFWITH__c', FIELD3VALUES__C='NOT BLANK', FIELD4__C=null, FIELD4VALUES__C=null, FIELD5__C=null, FIELD5VALUES__C=null, FIELD6__C=null, FIELD6VALUES__C=null, ACCOUNT_STATUS_CHANGE__C='9', CLASS_TYPE__C='P;D;C;R;Q;I', BULLETIN_MEMO_TEXT__C='Agent reinstated after default following: <SIDRA Lite Reason>',   BULLETIN_MEMO_TEXT2__C=null, BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='C', BILLABLE__C=TRUE, PUBLISHED_IN_BULLETIN__C=TRUE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=FALSE, CLEAR_IRREGULARITIES__C=TRUE, USED_BY_CNS__C=FALSE));
        lsConf.add(new AMS_ChangeCodes__c(Name='DEF', CHANGE_CODE__C='DEF', REASON_CODE__C='53', REASON_CODE_DESCRIPTION__C='DEFAULT ACCUM. IRREGULARITIES - NON COMPLIANCE', RECORD_TYPE__C='SIDRA_Lite', FIELD1__C='SIDRA_Lite_Reason__c', FIELD1VALUES__C='VALUES:Financial Review Non-compliance;Financial Security Non-compliance;Annual fees', FIELD2__C='DEF_Approval_Rejection__c', FIELD2VALUES__C='VALUES:Approved', FIELD3__C='Reason_for_Default__c', FIELD3VALUES__C='VALUES:Technical Default', FIELD4__C='Update_AIMS_DEF__c', FIELD4VALUES__C='NOT Blank', FIELD5__C=null, FIELD5VALUES__C=null, FIELD6__C=null, FIELD6VALUES__C=null, ACCOUNT_STATUS_CHANGE__C='5', CLASS_TYPE__C='P;D', BULLETIN_MEMO_TEXT__C='Agent is placed under Default due to <SIDRA Lite Reason>.  <IRRS Sequence> Agent is served Notice of Termination by <Termination Date>.  ISS Management is withdrawing ticketing authoirty and will demand an immediate accounting and settlement of', BULLETIN_MEMO_TEXT2__C='amounts owing up to date of default. Financial Security furnished by Agent<Financial Securities>.', BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='C', BILLABLE__C=FALSE, PUBLISHED_IN_BULLETIN__C=TRUE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=TRUE, CLEAR_IRREGULARITIES__C=FALSE, USED_BY_CNS__C=FALSE));
        lsConf.add(new AMS_ChangeCodes__c(Name='STR', CHANGE_CODE__C='STR', REASON_CODE__C='PREV', REASON_CODE_DESCRIPTION__C='PREV', RECORD_TYPE__C='SIDRA_Lite', FIELD1__C='DEF_Withdrawal_Approval_Rejection__c', FIELD1VALUES__C='VALUES:Approved', FIELD2__C='Update_AIMS_REI_DEFWITH__c', FIELD2VALUES__C='NOT Blank', FIELD3__C='NOT_Date__c', FIELD3VALUES__C='Blank', FIELD4__C='Shut_Down_TKT_System_GDS_and_BSPlink__c', FIELD4VALUES__C='not blank', FIELD5__C=null, FIELD5VALUES__C=null, FIELD6__C=null, FIELD6VALUES__C=null, ACCOUNT_STATUS_CHANGE__C='PREV', CLASS_TYPE__C='P;D', BULLETIN_MEMO_TEXT__C='The removal of STDs will no longer apply as Agent submitted the requested Notice of Change', BULLETIN_MEMO_TEXT2__C=null, BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='C', BILLABLE__C=TRUE, PUBLISHED_IN_BULLETIN__C=TRUE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=TRUE, CLEAR_IRREGULARITIES__C=FALSE, USED_BY_CNS__C=FALSE));
        lsConf.add(new AMS_ChangeCodes__c(Name='IRR', CHANGE_CODE__C='IRR', REASON_CODE__C='CURRENT', REASON_CODE_DESCRIPTION__C='CURRENT', RECORD_TYPE__C='SIDRA_Lite', FIELD1__C='SIDRA_Lite_Reason__c', FIELD1VALUES__C='VALUES:Financial Review Non-compliance', FIELD2__C='IRR_Approval_Rejection__c', FIELD2VALUES__C='VALUES:Approved', FIELD3__C='Update_AIMS_IRR__c', FIELD3VALUES__C='NOT Blank', FIELD4__C=null, FIELD4VALUES__C=null, FIELD5__C=null, FIELD5VALUES__C=null, FIELD6__C=null, FIELD6VALUES__C=null, ACCOUNT_STATUS_CHANGE__C=null, CLASS_TYPE__C='P;D;C', BULLETIN_MEMO_TEXT__C='Agent is served Notice of Irregularity due to <SIDRA Lite Reason> , agent is given 30 days to submit the required documents.  No monies outstanding', BULLETIN_MEMO_TEXT2__C=null, BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='C', BILLABLE__C=FALSE, PUBLISHED_IN_BULLETIN__C=TRUE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=FALSE, CLEAR_IRREGULARITIES__C=FALSE, USED_BY_CNS__C=FALSE));
        lsConf.add(new AMS_ChangeCodes__c(Name='IRW', CHANGE_CODE__C='IRW', REASON_CODE__C='PREV', REASON_CODE_DESCRIPTION__C='PREV', RECORD_TYPE__C='SIDRA_Lite', FIELD1__C='SIDRA_Lite_Reason__c', FIELD1VALUES__C='VALUES:Financial Review Non-compliance;Financial Security Non-compliance;Annual fees', FIELD2__C='IRR_Withdrawal_Approval_Rejection__c', FIELD2VALUES__C='VALUES:Approved', FIELD3__C='IRR_Withdrawal_Reason__c', FIELD3VALUES__C='VALUES:Exception raised', FIELD4__C='Update_AIMS_IRRWITH__c', FIELD4VALUES__C='NOT Blank', FIELD5__C=null, FIELD5VALUES__C=null, FIELD6__C=null, FIELD6VALUES__C=null, ACCOUNT_STATUS_CHANGE__C='PREV', CLASS_TYPE__C='P;D;C;R;Q;I', BULLETIN_MEMO_TEXT__C='Withdrawal of Irregularity due to Agency Administrator\'s decision', BULLETIN_MEMO_TEXT2__C=null, BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='C', BILLABLE__C=FALSE, PUBLISHED_IN_BULLETIN__C=TRUE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=FALSE, CLEAR_IRREGULARITIES__C=FALSE, USED_BY_CNS__C=FALSE));
        lsConf.add(new AMS_ChangeCodes__c(Name='DWD', CHANGE_CODE__C='DWD', REASON_CODE__C='PREV;DEF;DFE', REASON_CODE_DESCRIPTION__C='PREV;DEF;DFE', RECORD_TYPE__C='SIDRA_Lite', FIELD1__C='DEF_Withdrawal_Approval_Rejection__c', FIELD1VALUES__C='VALUES:Approved', FIELD2__C='DEF_Withdrawal_Reason__c', FIELD2VALUES__C='VALUES:Matching Error;Master Data Error;Administrative error;Other;Billing Error', FIELD3__C='Update_AIMS_REI_DEFWITH__c', FIELD3VALUES__C='NOT Blank', FIELD4__C='REI_ApprovalRejectin__c', FIELD4VALUES__C='VALUES:Approved', FIELD5__C='NOT_Sent__c', FIELD5VALUES__C='Blank', FIELD6__C=null, FIELD6VALUES__C=null, ACCOUNT_STATUS_CHANGE__C='PREV;DEF;DFE', CLASS_TYPE__C='P;D', BULLETIN_MEMO_TEXT__C='blabla', BULLETIN_MEMO_TEXT2__C='', BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='C', BILLABLE__C=FALSE, PUBLISHED_IN_BULLETIN__C=TRUE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=TRUE, CLEAR_IRREGULARITIES__C=FALSE, USED_BY_CNS__C=FALSE, Publish_HO_Only__c=TRUE));
		lsConf.add(new AMS_ChangeCodes__c(Name='REI', CHANGE_CODE__C='REI', REASON_CODE__C='PREV;DEF;DFE', REASON_CODE_DESCRIPTION__C='PREV;DEF;DFE', RECORD_TYPE__C='SIDRA_Lite', FIELD1__C='DEF_Withdrawal_Approval_Rejection__c', FIELD1VALUES__C='VALUES:Approved', FIELD2__C='DEF_Withdrawal_Reason__c', FIELD2VALUES__C='VALUES:Matching Error;Master Data Error;Administrative error;Other;Billing Error', FIELD3__C='Update_AIMS_REI_DEFWITH__c', FIELD3VALUES__C='Blank', FIELD4__C='REI_ApprovalRejectin__c', FIELD4VALUES__C='VALUES:Approved', FIELD5__C='NOT_Sent__c', FIELD5VALUES__C='Blank', FIELD6__C=null, FIELD6VALUES__C=null, ACCOUNT_STATUS_CHANGE__C='PREV;DEF;DFE', CLASS_TYPE__C='P;D', BULLETIN_MEMO_TEXT__C='blabla', BULLETIN_MEMO_TEXT2__C='', BULLETIN_MEMO_TEXT3__C=null, INTEGRATION_RECID__C='C', BILLABLE__C=FALSE, PUBLISHED_IN_BULLETIN__C=TRUE, RISK_CHANGECODE__C=TRUE, APPLY_TO_HIERARCHY__C=TRUE, CLEAR_IRREGULARITIES__C=FALSE, USED_BY_CNS__C=FALSE, Publish_HO_Only__c=TRUE));

        insert lsConf;

        list<String> listAirlineId = new list<String>();
        for (Profile profile: [SELECT Id FROM Profile WHERE Name LIKE 'ISS Portal Airline%']) {
            listAirlineId.add(profile.Id);
        }
        System.assert(!listAirlineId.isEmpty(), 'No airline profiles found');
        list<String> listAgencyId = new list<String>();
        for (Profile profile: [SELECT Id FROM Profile WHERE Name LIKE 'ISS Portal Agency%']) {
            listAgencyId.add(profile.Id);
        }
        System.assert(!listAgencyId.isEmpty(), 'No agency profiles found');
        list<ISSP_CS__c> listCs = new list<ISSP_CS__c>();
        listCs.add(new ISSP_CS__c(Name='ISS OperationalCalendar Airline Profil',Value__c=String.join(listAirlineId,',')));
        listCs.add(new ISSP_CS__c(Name='ISS OperationalCalendar Agency Profile',Value__c=String.join(listAgencyId,',')));
        insert listCs;
     
        //Create Operational Calendar
        Operational_calendar__c oc = new operational_calendar__c(First_Day__c = system.today(), Last_Day__c = system.today().addDays(15), Operation_Period_code__c = '123_456', Operation_Code__c='123_456', Period_Code__c='789');
        insert oc;
    }

    private static id SIDRALiteRTId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('SIDRA_Lite');
    private static id SIDRARTId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('SIDRA');
    private static Id RTOSCAR = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('OSCAR_Communication');

    static testmethod void TestCountryNotPilot(){
        Account a = [select id from Account where name='Accnt1'];
        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = a.Id);
        insert parent;

        Case SidraLiteCase = new Case();
        SidraLiteCase.AccountId = a.Id;
        SidraLiteCase.recordtypeId = SIDRALiteRTId;
        SidraLiteCase.ParentId = parent.Id;

        insert SidraLiteCase;

        AMS_OscarCase_RiskMgmt.EndRun();
        test.StartTest();

        SidraLiteCase.Update_AIMS_DEF__c = system.Now();
        SidraLiteCase.DEF_Approval_Rejection__c = 'Approved';
        SidraLiteCase.REI_ApprovalRejectin__c = 'Approved';
        SidraLiteCase.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
        SidraLiteCase.Update_AIMS_REI_DEFWITH__c = system.Now();
        SidraLiteCase.DEF_Withdrawal_Reason__c = 'Administrative error';
        SidraLiteCase.Update_AIMS_REI_DEFWITH__c = DateTime.now();
        SidraLiteCase.SIDRA_Lite_Reason__c = 'Bankruptcy';

        update SidraLiteCase;

        system.assertEquals(0, [Select id from Agency_applied_change_code__c where account__c = :a.Id].size(), 'No Change Code Created because country is not enabled');
        test.StopTest();
    }

    static testmethod void TestCCToSingleAgency(){
        Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt2'];
        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = a.Id);
        insert parent;

        Case SidraLiteCase = new Case();
        SidraLiteCase.AccountId = a.Id;
        SidraLiteCase.recordtypeId = SIDRALiteRTId;
        SidraLiteCase.ParentId = parent.Id;
        insert SidraLiteCase;

        AMS_OscarCase_RiskMgmt.EndRun();
        test.StartTest();

        SidraLiteCase.DEF_Withdrawal_Reason__c = 'Administrative error';
        SidraLiteCase.Update_AIMS_DEF__c = system.Now();
        SidraLiteCase.DEF_Approval_Rejection__c = 'Approved';
        SidraLiteCase.REI_ApprovalRejectin__c = 'Approved';
        SidraLiteCase.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
        SidraLiteCase.Update_AIMS_REI_DEFWITH__c = system.Now();
        SidraLiteCase.SIDRA_Lite_Reason__c = 'Bankruptcy';
        update SidraLiteCase;

        system.assertEquals(1, [Select id from Agency_applied_change_code__c where account__c = :a.Id].size(), 'Change Code Created because country is enabled');
        test.StopTest();
    }


    static testmethod void TestCCToAllHierarchyFromSA(){
        Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt3.1.1'];
        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = a.Id);
        insert parent;

        Case SidraLiteCase = new Case();
        SidraLiteCase.AccountId = a.Id;
        SidraLiteCase.recordtypeId = SIDRALiteRTId;
        SidraLiteCase.ParentId = parent.Id;

        insert SidraLiteCase;

        AMS_OscarCase_RiskMgmt.EndRun();
        test.StartTest();

        SidraLiteCase.DEF_Withdrawal_Reason__c = 'Administrative error';
        SidraLiteCase.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
        SidraLiteCase.REI_ApprovalRejectin__c = 'Approved';
        SidraLiteCase.Update_AIMS_REI_DEFWITH__c = system.now();
        SidraLiteCase.Shut_Down_TKT_System_GDS_and_BSPlink__c = system.Now();
        update SidraLiteCase;

        //system.assertEquals(1, [Select id from Agency_applied_change_code__c where account__r.Name = :'Accnt3'].size(), 'Change Code Created for whole hierarchy - HO');
        //system.assertEquals(1, [Select id from Agency_applied_change_code__c where account__r.Name = :'Accnt3.1'].size(), 'Change Code Created for whole hierarchy - BR1');
        //system.assertEquals(1, [Select id from Agency_applied_change_code__c where account__r.Name = :'Accnt3.2'].size(), 'Change Code Created for whole hierarchy - BR2');
        //system.assertEquals(1, [Select id from Agency_applied_change_code__c where account__r.Name = :'Accnt3.1.1'].size(), 'Change Code Created for whole hierarchy - SA');

        test.StopTest();
    }

    static testmethod void TestCCToAllHierarchyFromBR(){
        Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt3.1'];
        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = a.Id);
        insert parent;

        Case SidraLiteCase = new Case();
        SidraLiteCase.AccountId = a.Id;
        SidraLiteCase.recordtypeId = SIDRALiteRTId;
        SidraLiteCase.ParentId = parent.Id;
        insert SidraLiteCase;

        AMS_OscarCase_RiskMgmt.EndRun();
        test.StartTest();

        SidraLiteCase.DEF_Withdrawal_Reason__c = 'Administrative error';
        SidraLiteCase.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
        SidraLiteCase.REI_ApprovalRejectin__c = 'Approved';
        SidraLiteCase.Update_AIMS_REI_DEFWITH__c = system.now();
        SidraLiteCase.Shut_Down_TKT_System_GDS_and_BSPlink__c = system.Now();
        update SidraLiteCase;

        //system.assertEquals(1, [Select id from Agency_applied_change_code__c where account__r.Name = :'Accnt3'].size(), 'Change Code Created for whole hierarchy - HO');
        //system.assertEquals(1, [Select id from Agency_applied_change_code__c where account__r.Name = :'Accnt3.1'].size(), 'Change Code Created for whole hierarchy - BR1');
        //system.assertEquals(1, [Select id from Agency_applied_change_code__c where account__r.Name = :'Accnt3.2'].size(), 'Change Code Created for whole hierarchy - BR2');
        //system.assertEquals(1, [Select id from Agency_applied_change_code__c where account__r.Name = :'Accnt3.1.1'].size(), 'Change Code Created for whole hierarchy - SA');

        test.StopTest();
    }


    static testmethod void TestNewIrregularity(){
        Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt2'];
        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = a.Id);
        insert parent;

        Case SidraLiteCase = new Case();
            SidraLiteCase.AccountId = a.Id;
            SidraLiteCase.recordtypeId = SIDRALiteRTId;
            SidraLiteCase.SIDRA_Lite_Reason__c = 'Financial Review Non-compliance';
            SidraLiteCase.ParentId = parent.Id;
        insert SidraLiteCase;

        AMS_OscarCase_RiskMgmt.EndRun();
        test.StartTest();

        SidraLiteCase.IRR_Approval_Rejection__c = 'Approved';
        SidraLiteCase.IRR_Approval_Rejection_Date__c = system.now();
        SidraLiteCase.Update_AIMS_IRR__c = system.Now();
        SidraLiteCase.IRR_Type__c = 'Double Irregularity';
        SidraLiteCase.External_ID__c = '123 456 789';
        SidraLiteCase.CS_Rep_Acc_IRR_DEF__c = userinfo.getUserId();

        update SidraLiteCase;

        list<Agency_applied_change_code__c> AACC = [select id, Change_code__c, Operation__c, Irregularities_Points__c from Agency_applied_Change_code__c where Account__c =:a.Id];

        system.assertEquals(1, AACC.size(), '1 IRR Created');
        system.assertEquals('IRR', AACC.get(0).Change_code__c, 'IRR Created');
        system.assertEquals('A', AACC.get(0).Operation__c, 'Addition IRR Created');
        system.assertEquals(2, AACC.get(0).Irregularities_Points__c, '1 IRR Created with 2 points created');
        system.assertEquals(2, [select Accumulated_irregularities__c from Account where id =: a.id].Accumulated_Irregularities__C, 'Total Acc Irr: 2');

        test.StopTest();

    }

    static testmethod void TestAll6Conditions(){
        Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt2'];
        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = a.Id);
        insert parent;

        Case SidraLiteCase = new Case();
            SidraLiteCase.AccountId = a.Id;
            SidraLiteCase.recordtypeId = SIDRALiteRTId;
            SidraLiteCase.ParentId = parent.Id;
        insert SidraLiteCase;

        AMS_OscarCase_RiskMgmt.EndRun();
        test.StartTest();

        SidraLiteCase.IRR_Approval_Rejection__c = 'Approved';
        SidraLiteCase.Update_AIMS_IRR__c = system.Now();
        SidraLiteCase.DEF_Approval_Rejection__c = 'Rejected';
        SidraLiteCase.End_of_Grace_Period_Date__c = system.today();
        SidraLiteCase.Outstanding_Amount__c  = 75;

        update SidraLiteCase;

        test.StopTest();

    }

    static testmethod void TestAll6Conditions2(){
        Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt2'];
        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = a.Id);
        insert parent;

        Case SidraLiteCase = new Case();
            SidraLiteCase.AccountId = a.Id;
            SidraLiteCase.recordtypeId = SIDRALiteRTId;
            SidraLiteCase.ParentId = parent.Id;
        insert SidraLiteCase;

        AMS_OscarCase_RiskMgmt.EndRun();
        test.StartTest();

        SidraLiteCase.IRR_Approval_Rejection__c = 'Approved';
        SidraLiteCase.Update_AIMS_IRR__c = system.Now();
        SidraLiteCase.DEF_Approval_Rejection__c = 'Rejected';
        SidraLiteCase.End_of_Grace_Period_Date__c = system.today();
        SidraLiteCase.Outstanding_Amount__c  = 40;

        update SidraLiteCase;

        test.StopTest();

    }

    static testmethod void TestIrregularityWithdrawn(){
        Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt2'];
        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = a.Id);
        insert parent;

        list<Agency_applied_change_code__c> lsCC = new list<Agency_applied_change_code__c>();
        lsCC.add(new Agency_Applied_change_code__c(Account__c = a.Id, Change_code__c = 'IRR', Effective_date__c = system.today(), Irregularities_Points__c=2, Operation__c='A', AIMS_ID__c='1'));
        lsCC.add(new Agency_Applied_change_code__c(Account__c = a.Id, Change_code__c = 'IRR', Effective_date__c = system.today(), Irregularities_Points__c=2, Operation__c='A', AIMS_ID__c='2'));
        insert lsCC;

        system.assertEquals(4, [select Accumulated_irregularities__c from Account where id =: a.id].Accumulated_Irregularities__C, 'Total Acc Irr: 4');

        //WithDraw 1 IRR
        Case SidraLiteCase3 = new Case();
            SidraLiteCase3.AccountId = a.Id;
            SidraLiteCase3.recordtypeId = SIDRALiteRTId;
            SidraLiteCase3.ParentId = parent.Id;
        insert SidraLiteCase3;

        AMS_OscarCase_RiskMgmt.EndRun();
        test.StartTest();

        SidraLiteCase3.SIDRA_Lite_Reason__c = 'Annual fees';
        SidraLiteCase3.IRR_Withdrawal_Approval_Rejection__c = 'Approved';
        SidraLiteCase3.IRR_Withdrawal_Reason__c = 'Exception raised';
        SidraLiteCase3.Update_AIMS_IRRWITH__c = system.Now();
        SidraLiteCase3.CS_Rep_Acc_IRR_DEF__c = userinfo.getUserId();
        SidraLiteCase3.IRR_Type__c = 'Double Irregularity';

        update SidraLiteCase3;

        for(Agency_applied_Change_code__c aa:[select id, Change_code__c, Operation__c, recordtype.developername, Irregularities_Points__c from Agency_applied_Change_code__c where Account__c = :a.Id])
            system.debug(Logginglevel.ERROR, 'DTULLO 180 IRR Type. ' + aa.RecordType.DeveloperName + ' - ' + aa.Operation__c + ' - ' + aa.Change_code__c + ' - ' +aa.Irregularities_Points__c);

        system.assertEquals(3, [select id from Agency_applied_Change_code__c where Account__c =:a.Id].size(), '3 IRRS: 2 A and 1 W');
        system.assertEquals(2, [select Accumulated_irregularities__c from Account where id =: a.id].Accumulated_Irregularities__C, 'Total Acc Irr: 2');

        test.StopTest();
    }

    static testmethod void TestClearAllIRRs(){
        Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt2'];
        list<Agency_applied_change_code__c> lsCC = new list<Agency_applied_change_code__c>();
        lsCC.add(new Agency_Applied_change_code__c(Account__c = a.Id, Change_code__c = 'IRR', Effective_date__c = system.today(), Irregularities_Points__c=2, Operation__c='A', AIMS_ID__c='1'));
        lsCC.add(new Agency_Applied_change_code__c(Account__c = a.Id, Change_code__c = 'IRR', Effective_date__c = system.today(), Irregularities_Points__c=2, Operation__c='A', AIMS_ID__c='2'));
        lsCC.add(new Agency_Applied_change_code__c(Account__c = a.Id, Change_code__c = 'IRW', Effective_date__c = system.today(), Irregularities_Points__c=2, Operation__c='W', AIMS_ID__c='3'));

        insert lsCC;

        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = a.Id);
        insert parent;

        system.assertEquals(2, [select Accumulated_irregularities__c from Account where id =: a.id].Accumulated_Irregularities__C, 'Starting with 2 Accumulated Irregularities');

        //Generate a change code that will clear all IRRS:
        Case SidraLiteCase4 = new Case();
            SidraLiteCase4.AccountId = a.Id;
            SidraLiteCase4.recordtypeId = SIDRALiteRTId;
            SidraLiteCase4.ParentId = parent.Id;
        insert SidraLiteCase4;

        AMS_OscarCase_RiskMgmt.EndRun();
        test.StartTest();

        SidraLiteCase4.Update_AIMS_DEF__c = system.Now();
        SidraLiteCase4.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
        SidraLiteCase4.REI_ApprovalRejectin__c = 'Approved';
        SidraLiteCase4.DEF_Approval_Rejection__c = 'Approved';
        SidraLiteCase4.Update_AIMS_REI_DEFWITH__c = system.now();
        SidraLiteCase4.CS_Rep_Acc_IRR_DEF__c = userinfo.getUserId();
        SidraLiteCase4.DEF_Withdrawal_Reason__c = 'Other';
        SidraLiteCase4.IRR_Type__c = 'Double Irregularity';
        SidraLiteCase4.SIDRA_Lite_Reason__c = 'Bankruptcy';

        update SidraLiteCase4;

        system.assertEquals(4, [select id from Agency_applied_Change_code__c where Account__c =:a.Id].size(), '3 IRR still remains + RCR');
        system.assertEquals(0, [select Accumulated_irregularities__c from Account where id =: a.id].Accumulated_Irregularities__C, 'Total Acc Irr: 0 - Cleared');

        test.StopTest();
    }

    static testmethod void TestBulletinMemoText(){
        Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt2'];
        case cc = new case(AccountId = a.Id);
        insert cc;
        Financial_Institution__c FI = new Financial_Institution__c(Name = 'FI1', INSTITUTION_TYPE__C='Bank');
        insert FI;
        Financial_Security__c FS = new Financial_Security__c(CURRENCYISOCODE='USD', Account__c=a.Id, AMOUNT__C=3000, EXPIRY_DATE__C=system.Today().AddDays(100), FINANCIAL_INSTITUTION__c=FI.Id, SECURITY_STATUS__C='Active', Security_Type__c='Bank Guarantee', Region__c ='Europe', Reception_Date__c=system.today(), Reasonforrequest__c='New Application', Reception_Case__c=cc.Id);
        insert FS;
        
        test.StartTest();

        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = a.Id);
        insert parent;

        list<Agency_applied_change_code__c> lsCC = new list<Agency_applied_change_code__c>();
        lsCC.add(new Agency_Applied_change_code__c(Account__c = a.Id, Change_code__c = 'IRW', Effective_date__c = system.today().addDays(1), Irregularities_Points__c=2, Operation__c='W', AIMS_ID__c='1'));
        lsCC.add(new Agency_Applied_change_code__c(Account__c = a.Id, Change_code__c = 'IRR', Effective_date__c = system.today(), Irregularities_Points__c=2, Operation__c='A', AIMS_ID__c='2'));
        lsCC.add(new Agency_Applied_change_code__c(Account__c = a.Id, Change_code__c = 'IRR', Effective_date__c = system.today().addDays(-1), Irregularities_Points__c=2, Operation__c='A', AIMS_ID__c='3'));

        system.debug(Logginglevel.ERROR, 'DTULLO AMS OscarCase Risk Mgmt TEST 1 --> Query issued: ' + Limits.getQueries());

        insert lsCC;

        system.debug(Logginglevel.ERROR, 'DTULLO AMS OscarCase Risk Mgmt TEST 2 --> Query issued: ' + Limits.getQueries());

        Case SidraLiteCase4 = new Case();
            SidraLiteCase4.AccountId = a.Id;
            SidraLiteCase4.recordtypeId = SIDRALiteRTId;
            SidraLiteCase4.ParentId = parent.Id;
        insert SidraLiteCase4;
        
        system.debug(Logginglevel.ERROR, 'DTULLO AMS OscarCase Risk Mgmt TEST 2.1 --> Query issued: ' + Limits.getQueries());

        AMS_OscarCase_RiskMgmt.EndRun();        

        SidraLiteCase4.Update_AIMS_DEF__c = system.Now();
        SidraLiteCase4.DEF_Approval_Rejection__c = 'Approved';
        SidraLiteCase4.REI_ApprovalRejectin__c = 'Approved';
        SidraLiteCase4.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
        SidraLiteCase4.Update_AIMS_REI_DEFWITH__c = system.now();
        SidraLiteCase4.CS_Rep_Acc_IRR_DEF__c = userinfo.getUserId();
        SidraLiteCase4.Termination_date_manual_entry__c = system.today();
        SidraLiteCase4.DEF_Withdrawal_Reason__c='Bank error';
        SidraLiteCase4.SIDRA_Lite_Reason__c = 'Bankruptcy';
        SidraLiteCase4.End_of_Grace_Period_Date__c = system.Today().addDays(15);
        SidraLiteCase4.IRR_Withdrawal_Reason__c = 'Exception raised';
        SidraLiteCase4.Outstanding_Amount__c = 3000;
        SidraLiteCase4.Termination_Reason__c = 'Non Payment';
        SidraLiteCase4.Reason_for_Default__c = 'Annual Fees';
        SidraLiteCase4.Reason_of_REI_WD__c = 'IATA Error';
        SidraLiteCase4.Shut_Down_TKT_System_GDS_and_BSPlink__c = system.now();
        SidraLiteCase4.CS_Rep_Acc_DEF__c = userinfo.getUserId();
        SidraLiteCase4.CS_Rep_Acc_REI__c = userinfo.getUserId();

        update SidraLiteCase4;        

        system.debug(Logginglevel.ERROR, 'DTULLO AMS OscarCase Risk Mgmt TEST 3 --> Query issued: ' + Limits.getQueries());


        system.debug(Logginglevel.ERROR, 'DTULLO AMS OscarCase Risk Mgmt TEST 4 --> Query issued: ' + Limits.getQueries());

        string sMemo1 = '<Termination Date> <Financial Securities> <DEF Withdrawal reason> <SIDRA Lite Reason>';
        string sMemo2 = ' <End Grace Period Date> <IRR Withdrawal Reason> <Outstanding Amount> <Termination Reason>';
        string sMemo3 = ' <Update AIMS-DEF> <IRRS Sequence> <Reason for default> <Reason of REI/WD> <Inform GDS to Shut Down TKT System>';

        list<Case> lsCase = [select id, recordType.DeveloperName, DEF_Withdrawal_Approval_Rejection__c, DEF_Withdrawal_Reason__c, DEF_Approval_Rejection__c, End_of_Grace_Period_Date__c,
                                  Shut_Down_TKT_System_GDS_and_BSPlink__c, IRR_Approval_Rejection__c, IRR_Withdrawal_Approval_Rejection__c, IRR_Withdrawal_Reason__c, NOT_Date__c, NOT_Sent__c,
                                  Notify_Agreement_Approval_to_AG__c, Reason_for_Default__c, REI_ApprovalRejectin__c, Repayment_Schedule_Approval__c, SIDRA_Lite_Reason__c, TER_Approval_Rejection__c,
                                  Termination_Reason__c, Ticketing_Authority_Re_assigned__c, Update_AIMS_DEF__c, Update_AIMS_IRR__c, Update_AIMS_IRRWITH__c, Update_AIMS_REI_DEFWITH__c,
                                  Update_AIMS_Repayment_agreed__c, Update_AIMS_TER__c, Parent.OSCAR__r.Type_of_change__c, Parent.OSCAR__c, IRR_Approval_Rejection_Date__c, IRR_Type__c,
                                  Termination_date__c, Outstanding_Amount__c, Reason_of_REI_WD__c,
                                  Account.Location_Class__c, AccountId, Account.Status__c, Account.PreviousStatus__c, Account.Previous_Reason__c, Account.Reason__c, Account.Accumulated_Irregularities__c, Account.IATA_ISO_Country__r.Enable_Risk_Change_Codes__c
                                  from case where AccountId = :a.Id];

        list<Financial_Security__c> lsFS = [select id, Unlimited_Security__c, Account__c, Amount__c, CurrencyIsoCode, Expiry_Date__c
                                          from Financial_Security__c
                                          where Account__c = :a.Id];

        system.debug(Logginglevel.ERROR, 'DTULLO AMS OscarCase Risk Mgmt TEST 5 --> Query issued: ' + Limits.getQueries());

        string s = AMS_OscarCase_RiskMgmt.GenerateMemoText(lsCase.get(0), null, sMemo1, sMemo2, sMemo3, null, lsFS, '', true);
        //string s = AMS_OscarCase_RiskMgmt.GenerateMemoText(lsCase.get(0), null, sMemo1, sMemo2, sMemo3, null, lsFS);

        system.debug(Logginglevel.ERROR, 'DTULLO AMS OscarCase Risk Mgmt TEST 6 --> Query issued: ' + Limits.getQueries());

        test.StopTest();
    }

    static testmethod void TestBulletinMemoTextIRR(){
        Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt2'];

        list<Agency_applied_change_code__c> lsCC = new list<Agency_applied_change_code__c>();
        lsCC.add(new Agency_Applied_change_code__c(Account__c = a.Id, Change_code__c = 'IRW', Effective_date__c = system.today().addDays(1), Irregularities_Points__c=2, Operation__c='W', AIMS_ID__c='1'));
        lsCC.add(new Agency_Applied_change_code__c(Account__c = a.Id, Change_code__c = 'IRR', Effective_date__c = system.today(), Irregularities_Points__c=2, Operation__c='A', AIMS_ID__c='2'));
        lsCC.add(new Agency_Applied_change_code__c(Account__c = a.Id, Change_code__c = 'IRR', Effective_date__c = system.today().addDays(-1), Irregularities_Points__c=2, Operation__c='A', AIMS_ID__c='3'));

        insert lsCC;

        system.debug(Logginglevel.ERROR, 'DTULLO AMS OscarCase Risk Mgmt TEST 1 --> Query issued: ' + Limits.getQueries());

        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = a.Id);
        insert parent;

        system.debug(Logginglevel.ERROR, 'DTULLO AMS OscarCase Risk Mgmt TEST 2 --> Query issued: ' + Limits.getQueries());

        Case SidraLiteCase4 = new Case();
            SidraLiteCase4.AccountId = a.Id;
            SidraLiteCase4.recordtypeId = SIDRALiteRTId;
            SidraLiteCase4.ParentId = parent.Id;
        insert SidraLiteCase4;

        system.debug(Logginglevel.ERROR, 'DTULLO AMS OscarCase Risk Mgmt TEST 3 --> Query issued: ' + Limits.getQueries());

        AMS_OscarCase_RiskMgmt.EndRun();
        test.StartTest();

        SidraLiteCase4.Update_AIMS_DEF__c = system.Now();
        SidraLiteCase4.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
        SidraLiteCase4.DEF_Approval_Rejection__c = 'Approved';
        SidraLiteCase4.REI_ApprovalRejectin__c = 'Approved';
        SidraLiteCase4.Update_AIMS_REI_DEFWITH__c = system.now();
        SidraLiteCase4.CS_Rep_Acc_IRR_DEF__c = userinfo.getUserId();
        SidraLiteCase4.Termination_date_manual_entry__c = system.today();
        SidraLiteCase4.DEF_Withdrawal_Reason__c='Bank error';
        SidraLiteCase4.SIDRA_Lite_Reason__c = 'Bankruptcy';
        SidraLiteCase4.End_of_Grace_Period_Date__c = system.Today().addDays(15);
        SidraLiteCase4.IRR_Withdrawal_Reason__c = 'Exception raised';
        SidraLiteCase4.Outstanding_Amount__c = 3000;
        SidraLiteCase4.Termination_Reason__c = 'Non Payment';
        SidraLiteCase4.Reason_for_Default__c = 'Annual Fees';
        SidraLiteCase4.Reason_of_REI_WD__c = 'IATA Error';
        SidraLiteCase4.Shut_Down_TKT_System_GDS_and_BSPlink__c = system.now();

        update SidraLiteCase4;
        string sMemo1 = '<IRRS Sequence>';

        list<Case> lsCase = [select id, recordType.DeveloperName, DEF_Withdrawal_Approval_Rejection__c, DEF_Withdrawal_Reason__c, DEF_Approval_Rejection__c, End_of_Grace_Period_Date__c,
                                  Shut_Down_TKT_System_GDS_and_BSPlink__c, IRR_Approval_Rejection__c, IRR_Withdrawal_Approval_Rejection__c, IRR_Withdrawal_Reason__c, NOT_Date__c, NOT_Sent__c,
                                  Notify_Agreement_Approval_to_AG__c, Reason_for_Default__c, REI_ApprovalRejectin__c, Repayment_Schedule_Approval__c, SIDRA_Lite_Reason__c, TER_Approval_Rejection__c,
                                  Termination_Reason__c, Ticketing_Authority_Re_assigned__c, Update_AIMS_DEF__c, Update_AIMS_IRR__c, Update_AIMS_IRRWITH__c, Update_AIMS_REI_DEFWITH__c,
                                  Update_AIMS_Repayment_agreed__c, Update_AIMS_TER__c, Parent.OSCAR__r.Type_of_change__c, Parent.OSCAR__c, IRR_Approval_Rejection_Date__c, IRR_Type__c,
                                  Termination_date__c, Outstanding_Amount__c, Reason_of_REI_WD__c,
                                  Account.Location_Class__c, AccountId, Account.Status__c, Account.PreviousStatus__c, Account.Previous_Reason__c, Account.Reason__c, Account.Accumulated_Irregularities__c, Account.IATA_ISO_Country__r.Enable_Risk_Change_Codes__c
                                  from case where AccountId = :a.Id];

        system.debug(Logginglevel.ERROR, 'DTULLO AMS OscarCase Risk Mgmt TEST 4 --> Query issued: ' + Limits.getQueries());

        string s = AMS_OscarCase_RiskMgmt.GenerateMemoText(lsCase.get(0), null, sMemo1, null, null, lsCC, null, '', true);
        //string s = AMS_OscarCase_RiskMgmt.GenerateMemoText(lsCase.get(0), null, sMemo1, null, null, lsCC, null);

        system.debug(Logginglevel.ERROR, 'DTULLO AMS OscarCase Risk Mgmt TEST 5 --> Query issued: ' + Limits.getQueries());

        test.StopTest();
    }


    static testmethod void checkConditionsType(){
        Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt2'];

        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = a.Id, status='Open');
        insert parent;

        Case SidraLiteCase4 = new Case();
            SidraLiteCase4.AccountId = a.Id;
            SidraLiteCase4.recordtypeId = SIDRALiteRTId;
            SidraLiteCase4.ParentId = parent.Id;
            SidraLiteCase4.Update_AIMS_DEF__c = system.Now();
            SidraLiteCase4.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
            SidraLiteCase4.DEF_Approval_Rejection__c = 'Approved';
            SidraLiteCase4.REI_ApprovalRejectin__c = 'Approved';
            SidraLiteCase4.Update_AIMS_REI_DEFWITH__c = system.now();
            SidraLiteCase4.CS_Rep_Acc_IRR_DEF__c = userinfo.getUserId();
            SidraLiteCase4.Termination_date_manual_entry__c = system.today();
            SidraLiteCase4.DEF_Withdrawal_Reason__c='Bank error';
            SidraLiteCase4.SIDRA_Lite_Reason__c = 'Bankruptcy';
            SidraLiteCase4.End_of_Grace_Period_Date__c = system.Today().addDays(15);
            SidraLiteCase4.IRR_Withdrawal_Reason__c = 'Exception raised';
            SidraLiteCase4.Outstanding_Amount__c = 3000;
            SidraLiteCase4.Termination_Reason__c = 'Non Payment';
            SidraLiteCase4.Reason_for_Default__c = 'Annual Fees';
            SidraLiteCase4.Reason_of_REI_WD__c = 'IATA Error';
            SidraLiteCase4.Shut_Down_TKT_System_GDS_and_BSPlink__c = system.now();
            SidraLiteCase4.CS_Rep_Acc_DEF__c = userinfo.getUserId();
            SidraLiteCase4.CS_Rep_Acc_REI__c = userinfo.getUserId();

        insert SidraLiteCase4;

        AMS_OscarCase_RiskMgmt.EndRun();

        list<Agency_applied_change_code__c> lsCC = new list<Agency_applied_change_code__c>();
        lsCC.add(new Agency_Applied_change_code__c(Account__c = a.Id, Change_code__c = 'IRR', Effective_date__c = system.today().addDays(-1), Irregularities_Points__c=2, Operation__c='A', AIMS_ID__c='3', SIDRA_Case__c=SidraLiteCase4.id));
        insert lsCC;

        map<id, list<Agency_Applied_Change_code__c>> mapExistingChangeCodes = new map<id, list<Agency_Applied_Change_code__c>>();

        for(Agency_Applied_Change_code__c aa:[select id, createddate, AccountNewStatus__c, AccountPreviousStatus__c, PreviousReason__c, Account__c, Account__r.Location_Class__c, Change_Code__c, SIDRA_Case__c from Agency_Applied_Change_code__c where SIDRA_Case__c =:SidraLiteCase4.Id]){
            list<Agency_Applied_Change_code__c> lsAACCtmp;
            if(mapExistingChangeCodes.keyset().contains(aa.Account__c))
                lsAACCtmp = mapExistingChangeCodes.get(aa.Account__c);
            else
                lsAACCtmp = new list<Agency_Applied_Change_code__c>();

            lsAACCtmp.add(aa);

            mapExistingChangeCodes.put(aa.Account__c, lsAACCtmp);
        }

        test.StartTest();

        case c = [select id, recordType.DeveloperName, DEF_Withdrawal_Approval_Rejection__c, DEF_Withdrawal_Reason__c, DEF_Approval_Rejection__c, End_of_Grace_Period_Date__c,
                                  Shut_Down_TKT_System_GDS_and_BSPlink__c, IRR_Approval_Rejection__c, IRR_Withdrawal_Approval_Rejection__c, IRR_Withdrawal_Reason__c, NOT_Date__c, NOT_Sent__c,
                                  Notify_Agreement_Approval_to_AG__c, Reason_for_Default__c, REI_ApprovalRejectin__c, Repayment_Schedule_Approval__c, SIDRA_Lite_Reason__c, TER_Approval_Rejection__c, Current_Outstanding_Amount_USD__c, Type_of_REI_WD__c,
                                  Termination_Reason__c, Ticketing_Authority_Re_assigned__c, Update_AIMS_DEF__c, Update_AIMS_IRR__c, Update_AIMS_IRRWITH__c, Update_AIMS_REI_DEFWITH__c,
                                  Update_AIMS_Repayment_agreed__c, Update_AIMS_TER__c, Parent.OSCAR__r.Type_of_change__c, Parent.OSCAR__c, Parent.Status, IRR_Approval_Rejection_Date__c, IRR_Type__c,
                                  Termination_date__c, Outstanding_Amount__c, Reason_of_REI_WD__c, External_ID__c,
                                  Account.Location_Class__c, AccountId, Account.Status__c, Account.PreviousStatus__c, Account.Previous_Reason__c, Account.Reason__c, Account.Accumulated_Irregularities__c
                                  , Account.IATA_ISO_Country__r.Enable_Risk_Change_Codes__c, Account.AIMS_ID__c, Account.WebStar_ID__c, Account.IATACode__c
                                  //DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER
                                  , Account.CNS_Agency__c
                                  from case where id =: SidraLiteCase4.Id];

        system.assertEquals(true, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'DEF_Withdrawal_Approval_Rejection__c', 'NOT BLANK', null, mapExistingChangeCodes));
        system.assertEquals(true, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'IRR_Type__c', 'BLANK', null, mapExistingChangeCodes));
        system.assertEquals(true, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'DEF_Withdrawal_Approval_Rejection__c', 'NOT EQUAL TO:Rejected', null, mapExistingChangeCodes));
        system.assertEquals(true, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'Parent.Status', 'NOT EQUAL TO:Closed', null, mapExistingChangeCodes));
        system.assertEquals(true, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'End_of_Grace_Period_Date__c', 'GREATER THAN TODAY', null, mapExistingChangeCodes));

        // START: amtosantos, 2017-04-18, Increase Code Coverage
        system.assertEquals(true, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'End_of_Grace_Period_Date__c', 'GREATER THAN TODAY OR EQUAL TO TODAY', null, mapExistingChangeCodes));
        //   END: amtosantos

        system.assertEquals(true, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'Update_AIMS_DEF__c', 'EQUAL TO TODAY', null, mapExistingChangeCodes));
        system.assertEquals(true, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'Outstanding_Amount__c', '<=:5000', null, mapExistingChangeCodes));
        system.assertEquals(true, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'Outstanding_Amount__c', '>=:1000', null, mapExistingChangeCodes));
        system.assertEquals(true, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'Outstanding_Amount__c', '>:1000', null, mapExistingChangeCodes));
        system.assertEquals(true, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'Outstanding_Amount__c', '<:5000', null, mapExistingChangeCodes));
        system.assertEquals(true, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'ChangeCode', 'EXISTS:IRR', null, mapExistingChangeCodes));
        system.assertEquals(true, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'ChangeCode', 'NOT EXISTS:DEF', null, mapExistingChangeCodes));

        system.assertEquals(true, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'Parent.Status', 'VALUES:OPEN', null, mapExistingChangeCodes));
        system.assertEquals(true, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'SIDRA_Lite_Reason__c', 'VALUES:BANKRUPTCY', null, mapExistingChangeCodes));

        system.assertEquals(false, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'IRR_Type__c', 'NOT BLANK', null, mapExistingChangeCodes));
        system.assertEquals(false, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'DEF_Withdrawal_Approval_Rejection__c', 'BLANK', null, mapExistingChangeCodes));
        system.assertEquals(false, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'DEF_Withdrawal_Approval_Rejection__c', 'NOT EQUAL TO:APPROVED', null, mapExistingChangeCodes));
        system.assertEquals(false, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'Parent.Status', 'NOT EQUAL TO:OPEN', null, mapExistingChangeCodes));
        system.assertEquals(false, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'Update_AIMS_DEF__c', 'GREATER THAN TODAY', null, mapExistingChangeCodes));
        system.assertEquals(false, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'End_of_Grace_Period_Date__c', 'EQUAL TO TODAY', null, mapExistingChangeCodes));
        system.assertEquals(false, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'Outstanding_Amount__c', '<=:1000', null, mapExistingChangeCodes));
        system.assertEquals(false, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'Outstanding_Amount__c', '>=:5000', null, mapExistingChangeCodes));
        system.assertEquals(false, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'Outstanding_Amount__c', '>:5000', null, mapExistingChangeCodes));
        system.assertEquals(false, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'Outstanding_Amount__c', '<:1000', null, mapExistingChangeCodes));
        system.assertEquals(false, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'ChangeCode', 'EXISTS:DEF', null, mapExistingChangeCodes));
        system.assertEquals(false, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'ChangeCode', 'NOT EXISTS:IRR', null, mapExistingChangeCodes));
        system.assertEquals(false, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'IRR_Withdrawal_Reason__c', 'VALUES:BlaBlaBla', null, mapExistingChangeCodes));
        system.assertEquals(false, AMS_OscarCase_RiskMgmt.bCheckCondition(c, 'Parent.Status', 'VALUES:CLOSED', null, mapExistingChangeCodes));

        test.StopTest();
    }


    static testMethod void checkPrevStatusReason(){
        Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt3'];

        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = a.Id, status='Open');
        insert parent;

        Case SidraLiteCase4 = new Case();
            SidraLiteCase4.AccountId = a.Id;
            SidraLiteCase4.recordtypeId = SIDRALiteRTId;
            SidraLiteCase4.ParentId = parent.Id;
            SidraLiteCase4.SIDRA_Lite_Reason__c = 'Bankruptcy';
            SidraLiteCase4.CS_Rep_Acc_DEF__c = userinfo.getUserId();
            SidraLiteCase4.CS_Rep_Acc_REI__c = userinfo.getUserId();
            SidraLiteCase4.CS_Rep_Acc_IRR_DEF__c = userinfo.getUserId();
        insert SidraLiteCase4;

        AMS_OscarCase_RiskMgmt.EndRun();

        test.StartTest();
        SidraLiteCase4.DEF_Approval_Rejection__c = 'Approved';
        SidraLiteCase4.Reason_for_Default__c = 'Technical Default';
        SidraLiteCase4.Update_AIMS_DEF__c = system.now();

        update SidraLiteCase4;
        //system.assertEquals(1, [select id from Agency_applied_Change_code__c where Account__c =:a.Id].size(), 'DEF Created');

        AMS_OscarCase_RiskMgmt.EndRun();

        SidraLiteCase4.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
        SidraLiteCase4.DEF_Withdrawal_Reason__c = 'Other';
        SidraLiteCase4.Update_AIMS_REI_DEFWITH__c = system.now();
        SidraLiteCase4.REI_ApprovalRejectin__c = 'Approved';

        update SidraLiteCase4;
        system.debug(logginglevel.error, 'DTULLO 620 --> ' + [Select id, change_code__c from Agency_applied_Change_code__c where Account__c =:a.Id]);
        system.assert([select id from Agency_applied_Change_code__c where Account__c =:a.Id].size()>1);

        test.StopTest();
    }
	
	static testMethod void TestCompliant() {
        AMS_OscarCase_RiskMgmt a = new AMS_OscarCase_RiskMgmt();
        a.isTestCompliant();
        AMS_AgencyRegulationTriggerHandler ar = new AMS_AgencyRegulationTriggerHandler();
        ar.isTestCompliant();
        AMS_QueryUtils aq = new AMS_QueryUtils();
        aq.isTestCompliant();
    }

    static testMethod void checkPrevStatusReasonUpdated(){
        Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt3'];

        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = a.Id, status='Open');
        insert parent;

        Case SidraLiteCase4 = new Case();
            SidraLiteCase4.AccountId = a.Id;
            SidraLiteCase4.recordtypeId = SIDRALiteRTId;
            SidraLiteCase4.ParentId = parent.Id;
            SidraLiteCase4.SIDRA_Lite_Reason__c = 'Bankruptcy';
            SidraLiteCase4.CS_Rep_Acc_DEF__c = userinfo.getUserId();
            SidraLiteCase4.CS_Rep_Acc_REI__c = userinfo.getUserId();
            SidraLiteCase4.CS_Rep_Acc_IRR_DEF__c = userinfo.getUserId();
        insert SidraLiteCase4;


        Agency_applied_change_code__c ap = new Agency_applied_change_code__c();
		ap.Account__c = a.Id;
        ap.AccountPreviousStatus__c = 'Cash basis/no commission';
        ap.PreviousReason__c = '51-DEFAULT-OVERDUE REMITTANCE';
        ap.AccountNewStatus__c = '';
        ap.Change_Code__c = 'DEF';
        ap.Reason_Description__c = 'NON COMPLIANCE TO CRITERIA';
        ap.Reason_Code__c = '00';
        ap.SIDRA_Case__c = SidraLiteCase4.Id;
        ap.Date_time_of_change__c = system.now().addDays(-1);
		insert ap;



        Agency_applied_change_code__c apa = new Agency_applied_change_code__c();
        apa.Account__c = a.Id;
        apa.AccountNewStatus__c = AMS_Utils.ACC_S8_CHANGESPROCESSED;
        apa.Change_Code__c = 'TER';
        apa.Reason_code__c = '81';
        apa.Reason_Description__c = 'TEST';
        apa.Date_time_of_change__c = system.now().addDays(-50);

		insert apa;

        test.StartTest();
        SidraLiteCase4.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
        SidraLiteCase4.DEF_Withdrawal_Reason__c = 'Matching Error';
        SidraLiteCase4.REI_ApprovalRejectin__c = 'Approved';
        SidraLiteCase4.Update_AIMS_REI_DEFWITH__c = null;
        SidraLiteCase4.NOT_Sent__c = null;

		AMS_OscarCase_RiskMgmt.EndRun();
        update SidraLiteCase4;

        System.debug('## account status: '+[select status__C from Account where id =:a.Id]);
        System.debug('## account change codes: '+[select change_code__c, Date_time_of_change__c, AccountPreviousStatus__c, PreviousReason__c from agency_applied_change_code__c where account__c = :a.Id order by Date_time_of_change__c desc]);
        System.assertEquals(1, [select id from  Agency_applied_change_code__c where account__c = :a.Id and change_code__c ='REI' and AccountNewStatus__c = :AMS_Utils.ACC_S8_CHANGESPROCESSED].size(), 'REI change code should be generated and have accountnewstatus field = '+AMS_Utils.ACC_S8_CHANGESPROCESSED);

        test.StopTest();
    }

    static testMethod void checkPrevStatusReasonUpdatedB(){
        Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt3'];

        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = a.Id, status='Open');
        insert parent;

        Case SidraLiteCase4 = new Case();
            SidraLiteCase4.AccountId = a.Id;
            SidraLiteCase4.recordtypeId = SIDRALiteRTId;
            SidraLiteCase4.ParentId = parent.Id;
            SidraLiteCase4.SIDRA_Lite_Reason__c = 'Bankruptcy';
            SidraLiteCase4.CS_Rep_Acc_DEF__c = userinfo.getUserId();
            SidraLiteCase4.CS_Rep_Acc_REI__c = userinfo.getUserId();
            SidraLiteCase4.CS_Rep_Acc_IRR_DEF__c = userinfo.getUserId();
        insert SidraLiteCase4;


        Agency_applied_change_code__c ap = new Agency_applied_change_code__c();
		ap.Account__c = a.Id;
        ap.AccountPreviousStatus__c = 'Cash basis/no commission';
        ap.PreviousReason__c = '51-DEFAULT-OVERDUE REMITTANCE';
        ap.AccountNewStatus__c = '';
        ap.Change_Code__c = 'DEF';
        ap.Reason_Description__c = 'NON COMPLIANCE TO CRITERIA';
        ap.Reason_Code__c = '00';
        ap.SIDRA_Case__c = SidraLiteCase4.Id;
        ap.Date_time_of_change__c = system.now().addDays(-1);
		insert ap;



        Agency_applied_change_code__c apa = new Agency_applied_change_code__c();
        apa.Account__c = a.Id;
        apa.AccountNewStatus__c = AMS_Utils.ACC_S7_UNDERREVIEW;
        apa.Change_Code__c = 'TER';
        apa.Reason_code__c = '';
        apa.Reason_Description__c = 'TEST';
        apa.Date_time_of_change__c = system.now().addDays(-50);

		insert apa;

        test.StartTest();
        SidraLiteCase4.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
        SidraLiteCase4.DEF_Withdrawal_Reason__c = 'Matching Error';
        SidraLiteCase4.REI_ApprovalRejectin__c = 'Approved';
        SidraLiteCase4.Update_AIMS_REI_DEFWITH__c = null;
        SidraLiteCase4.NOT_Sent__c = null;

		AMS_OscarCase_RiskMgmt.EndRun();
        update SidraLiteCase4;

        System.debug('## account status: '+[select status__C from Account where id =:a.Id]);
        System.debug('## account change codes: '+[select change_code__c, Date_time_of_change__c, AccountPreviousStatus__c, PreviousReason__c from agency_applied_change_code__c where account__c = :a.Id order by Date_time_of_change__c desc]);
        //should be ACC_S9_APPROVED because the fallback system. The RiskManagement will not find one greater than 8 and not 4 and will fallback to 91-MEETS STANDARDS
        System.assertEquals(1, [select id from  Agency_applied_change_code__c where account__c = :a.Id and change_code__c ='REI' and AccountNewStatus__c = :AMS_Utils.ACC_S9_APPROVED].size(), 'REI change code should be generated and have accountnewstatus field = '+AMS_Utils.ACC_S9_APPROVED);

        test.StopTest();
    }

    static testMethod void checkPrevStatusReasonUpdatedC(){
        Account a = [select id, Name, IATA_ISO_Country__r.Enable_Risk_Change_Codes__c from Account where name='Accnt3'];

        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = a.Id, status='Open');
        insert parent;

        Case SidraLiteCase4 = new Case();
            SidraLiteCase4.AccountId = a.Id;
            SidraLiteCase4.recordtypeId = SIDRALiteRTId;
            SidraLiteCase4.ParentId = parent.Id;
            SidraLiteCase4.SIDRA_Lite_Reason__c = 'Bankruptcy';
            SidraLiteCase4.CS_Rep_Acc_DEF__c = userinfo.getUserId();
            SidraLiteCase4.CS_Rep_Acc_REI__c = userinfo.getUserId();
            SidraLiteCase4.CS_Rep_Acc_IRR_DEF__c = userinfo.getUserId();
        insert SidraLiteCase4;


        Agency_applied_change_code__c ap = new Agency_applied_change_code__c();
		ap.Account__c = a.Id;
        ap.AccountPreviousStatus__c = 'Cash basis/no commission';
        ap.PreviousReason__c = '51-DEFAULT-OVERDUE REMITTANCE';
        ap.AccountNewStatus__c = '';
        ap.Change_Code__c = 'DEF';
        ap.Reason_Description__c = 'NON COMPLIANCE TO CRITERIA';
        ap.Reason_Code__c = '00';
        ap.SIDRA_Case__c = SidraLiteCase4.Id;
        ap.Date_time_of_change__c = system.now().addDays(-1);
		insert ap;



        Agency_applied_change_code__c apa = new Agency_applied_change_code__c();
        apa.Account__c = a.Id;
        apa.AccountNewStatus__c = AMS_Utils.ACC_S8_CHANGESPROCESSED;
        apa.Change_Code__c = 'TER';
        apa.Reason_code__c = '';
        apa.Reason_Description__c = 'TEST';
        apa.Date_time_of_change__c = system.now().addDays(-50);

		insert apa;

        test.StartTest();
        SidraLiteCase4.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
        SidraLiteCase4.DEF_Withdrawal_Reason__c = 'Matching Error';
        SidraLiteCase4.REI_ApprovalRejectin__c = 'Approved';
        SidraLiteCase4.Update_AIMS_REI_DEFWITH__c = null;
        SidraLiteCase4.NOT_Sent__c = null;

		AMS_OscarCase_RiskMgmt.EndRun();
        update SidraLiteCase4;

        System.debug('## account status: '+[select status__C from Account where id =:a.Id]);
        System.debug('## account change codes: '+[select change_code__c, Date_time_of_change__c, AccountPreviousStatus__c, PreviousReason__c from agency_applied_change_code__c where account__c = :a.Id order by Date_time_of_change__c desc]);
        System.assertEquals(1, [select id from  Agency_applied_change_code__c where account__c = :a.Id and change_code__c ='REI' and AccountNewStatus__c = :AMS_Utils.ACC_S8_CHANGESPROCESSED].size(), 'REI change code should be generated and have accountnewstatus field = '+AMS_Utils.ACC_S8_CHANGESPROCESSED);

        test.StopTest();
    }
}