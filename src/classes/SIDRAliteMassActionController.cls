public with sharing class SIDRAliteMassActionController {

    public static final Integer MIN_CASES_FOR_BATCH =11;
    public static final Integer MAX_SEARCH_ELEMENTS =900;
    public Integer getMinCasesForBatch(){ return MIN_CASES_FOR_BATCH;}

    public static final Schema.RecordTypeInfo RECORDTYPE_SIDRA_LITE = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SIDRA Lite');
    public static final Schema.RecordTypeInfo RECORDTYPE_IFAP = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IATA Financial Review');
    public static final Schema.RecordTypeInfo RECORDTYPE_SMAP = Schema.SObjectType.Case.getRecordTypeInfosByName().get('sMAP(sales Monitoring Alert Process)');
    public static final Schema.RecordTypeInfo RECORDTYPE_SAAM = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SAAM');
    public static final Schema.RecordTypeInfo RECORDTYPE_OSCAR = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication');
    public static final Schema.RecordTypeInfo RECORDTYPE_INVOICING = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Invoicing Collection Cases');
    public static final Id RECORDTYPE_SIDRA_LITE_ID = RECORDTYPE_SIDRA_LITE.getRecordTypeId();
    public static final Id RECORDTYPE_IFAP_ID = RECORDTYPE_IFAP.getRecordTypeId();
    public static final Id RECORDTYPE_SMAP_ID = RECORDTYPE_SMAP.getRecordTypeId();
    public static final Id RECORDTYPE_SAAM_ID = RECORDTYPE_SAAM.getRecordTypeId();
    public static final Id RECORDTYPE_OSCAR_ID = RECORDTYPE_OSCAR.getRecordTypeId();
    public static final Id RECORDTYPE_INVOICING_ID = RECORDTYPE_INVOICING.getRecordTypeId();
    public static final map<Id,Schema.RecordTypeInfo> LIST_RT = new map<Id,Schema.RecordTypeInfo>{
        RECORDTYPE_IFAP_ID => RECORDTYPE_IFAP,
        RECORDTYPE_SMAP_ID => RECORDTYPE_SMAP,
        RECORDTYPE_SAAM_ID => RECORDTYPE_SAAM,
        RECORDTYPE_OSCAR_ID => RECORDTYPE_OSCAR,
        RECORDTYPE_INVOICING_ID => RECORDTYPE_INVOICING
    };

    public static final set<String> TYPE_ACCOUNT_PAX =   SidraLiteUtil.TYPE_ACCOUNT_PAX;
    public static final set<String> TYPE_ACCOUNT_CARGO = SidraLiteUtil.TYPE_ACCOUNT_CARGO;
    public static final set<String> TYPE_ACCOUNT_AGENT = SidraLiteUtil.TYPE_ACCOUNT_AGENT;
    public static final set<String> STATUS_FOR_FS = SidraLiteHelperForIFAP.STATUS_FOR_FS;
    public static final set<String> STATUS_FOR_FA = SidraLiteHelperForIFAP.STATUS_FOR_FA;

    public static final String FIRST_NON_COMPLIANCE = '1st Non-Compliance';
    public static final String SECOND_NON_COMPLIANCE = '2nd Non-Compliance';
    public static final String THIRD_NON_COMPLIANCE = '3th Non-Compliance';

    public list<WrapperCase> listWrapperCase {get;set;}
    public String selectedIds {get;set;}
    public WrapperFilter filter {get;set;}
    public Boolean showResultSection{get;set;}
    public Boolean showProcessBatchSection{get;set;}

    // Confirm action section
    //public Boolean showConfirmTriggerSidraLiteAction {get;set;}

    public class SIDRAliteMassActionException extends Exception{}

    /**
        Constructor
        by default the page is loaded with all cases searched without filter
    **/
    public SIDRAliteMassActionController() {
        this.listWrapperCase = new list<WrapperCase>();
        this.filter = new WrapperFilter();
        this.showResultSection = false;
        this.showProcessBatchSection = false;
        //this.showConfirmTriggerSidraLiteAction = false;
        this.selectedIds = '';

        // check if it's an admin user
        Profile profile = [Select Name from Profile where Id = :UserInfo.getProfileId()];
        search();
    }

    /**
        Reloads current page
    **/
    public Pagereference reload() {
        PageReference pageref = Page.SIDRAliteMassAction;
        pageref.setRedirect(true);
        return pageref;
    }

    /**
        Search all cases based on the filters selected by the user
    **/
    public void search() {
        try {
            if (this.filter.getIsIFAP()) {
                searchIFAP();
            } else if (this.filter.getIsSMAP()) {
                searchSMAP();
            } else if (this.filter.getIsSAAM()) {
                searchSAAM();
            } else if (this.filter.getIsOSCAR()) {
                searchOSCAR();
            } else if (this.filter.getIsInvoicing()) {
                searchInvoicing();
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));
        }
        this.showResultSection = false;
        this.showProcessBatchSection = false;
    }

    private static Boolean isEmpty(String input) {
        return input==null || input == '';
    }

    private static String serialize(set<String> setString) {
        list<String> listString = new list<String>(setString);
        return serialize(listString);
    }
    private static String serialize(list<String> listString) {
        return '(\'' + String.join(listString,'\',\'') +'\')';
    }

    private static String filter(String str) {
        return String.escapeSingleQuotes(str==null?'':str);
    }

    private String getBaseQuery(Id recordtypeId) {
        String query = 'Select Id, Status, Financial_Review_Type__c,'
            + ' FA_Letter_Sent__c, Deadline_Date__c, firstFAnonComplianceDate__c, FA_Second_Deadline_Date__c, FA_Third_Deadline_Date__c, secondFAnonComplianceDate__c, Third_FA_non_Compliance_Date__c,'
            + ' FS_Letter_Sent__c, FS_Deadline_Date__c, firstFSnonComplianceDate__c, FS_Second_Deadline_Date__c, FS_Third_Deadline_Date__c, secondFSnonComplianceDate__c, FS_third_non_compliance_date__c,'
            + ' IFAP_Agent_Type__c, AccountId, CaseNumber, Origin, Subject, IFAP_Agent_Code__c, Region__c, Account_Billing_Country__c, BSPCountry__c,'
            + ' RecordtypeId, Reason1__c, Decision__c, Suspension_Date__c, Bank_Guarantee_deadline__c, SAAM_Deadline_Date__c, Key_Customer_Case__c,'
            + ' BSP_CASS__c, Termination_date_manual_entry__c, Termination_date__c, New_IFAP_Deadline_date__c, Documentation_Complete__c, Bank_Guarantee_received__c,Has_the_agent_paid_invoice__c, isClosed,'
            + ' Account.Id, Account.Name, Account.Type, Account.Status__c, Account.Accumulated_Irregularities__c, Account.Category__c, Comments__c, OwnerId, Owner.Name, ContactId, Contact.Name,'
            + ' OSCAR__r.Id, OSCAR__r.RPM_Approval__c, OSCAR__r.STEP44__c, OSCAR__r.Step6__c, OSCAR__r.Step9__c, OSCAR__r.Step11__c, OSCAR__r.Step12__c, OSCAR__r.Step14__c, OSCAR__r.Step26__c, OSCAR__r.Step35__c, '
            + ' (Select Id, SIDRA_lite_Reason__c, Status, ParentId, RecordtypeId,'
            + '     FA_Letter_Sent__c, Deadline_Date__c, firstFAnonComplianceDate__c, FA_Second_Deadline_Date__c, FA_Third_Deadline_Date__c, secondFAnonComplianceDate__c,'
            + '     FS_Letter_Sent__c, FS_Deadline_Date__c, firstFSnonComplianceDate__c, FS_Second_Deadline_Date__c, FS_Third_Deadline_Date__c, secondFSnonComplianceDate__c,'
            + '     ContactId, IFAP_Agent_Type__c, AccountId, CaseNumber, Origin, Subject, IFAP_Agent_Code__c, Region__c, Account_Billing_Country__c,'
            + '     BSP_CASS__c, Reason_for_Default__c, Confirmation_moneys_not_received__c, DEF_Approval_Rejection__c, Termination_date_manual_entry__c,'
            + '     TER_Approval_Rejection__c, Termination_Reason__c, Propose_Default__c, NOT_Date__c,'
            + '     Account.Id, Account.Type, Account.Status__c, Comments__c'
            + '     from Cases'
            + '     where RecordtypeId = :RECORDTYPE_SIDRA_LITE_ID '
            + ' )'
            + ' from Case'
            + ' Where RecordtypeId = \'' + recordtypeId + '\''
            + ' AND account.Status__c != \'Terminated\''
            + ' AND (NOT Owner.Name like \'%recycle%\')'
            + ' AND Region__c = \'' + filter(this.filter.cse.Region__c) +  '\'';

        // add filter for selected country
        String country = filter(this.filter.cse.BSPCountry__c);
        if (!isEmpty(country)) {
            if (recordtypeId == RECORDTYPE_IFAP_ID) {
                query += ' AND Account_Billing_Country__c = \'' + country + '\'';
            } else {
                query += ' AND BSPCountry__c = \'' + country + '\'';
            }
        }
        // add Financial_Review_Type__c filter
        if (recordtypeId == RECORDTYPE_IFAP_ID && filter(this.filter.cse.Financial_Review_Type__c) != '') {
            query += ' AND Financial_Review_Type__c = \'' + this.filter.cse.Financial_Review_Type__c + '\'';
        }
        // add Reason Filter
        if (recordtypeId == RECORDTYPE_SAAM_ID || recordtypeId == RECORDTYPE_OSCAR_ID || recordtypeId == RECORDTYPE_INVOICING_ID) {
            String reason = filter(this.filter.cse.Reason1__c);
            if (isEmpty(reason)) {
                list<String> allReasons = new list<String>();
                if (recordtypeId == RECORDTYPE_SAAM_ID) {
                    allReasons.addAll(SidraLiteHelperForSAAM.VALID_REASONS);
                } else if (recordtypeId == RECORDTYPE_OSCAR_ID) {
                    allReasons.addAll(SidraLiteHelperForOSCAR.VALID_REASONS);
                } else if (recordtypeId == RECORDTYPE_INVOICING_ID) {
                    allReasons.addAll(SidraLiteHelperForInvoicing.VALID_REASONS);
                }
                query += ' AND Reason1__c IN ' + serialize(allReasons);
            } else {
                query += ' AND Reason1__c = \'' + reason + '\'';
            }
        }
        // add category filter
        String category = filter(this.filter.category);
        if (!isEmpty(category)) {
            query += ' AND Account.Category__c = \'' + category + '\'';
        }
        return query;
    }

    /**
        Run input string query and checks the result lenght
        returns the Result
    **/
    private list<Case> executeQuery(String query) {
        query += ' limit ' + (MAX_SEARCH_ELEMENTS + 1);
        list<Case> listCase = (list<Case>)Database.query(query);
        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,query));
        return listCase;
    }

    /**
        Filter the list to a maximum number
    **/
    private void addWrapper(WrapperCase wrapper) {
        if (this.listWrapperCase.size()<MAX_SEARCH_ELEMENTS) {
            this.listWrapperCase.add(wrapper);
        } else {
            throw new SIDRAliteMassActionException('Your search criteria result exceeds the limit of number of records (' + MAX_SEARCH_ELEMENTS + '). Try to apply more filters to reduce the number of records or process your request in multiple sessions');
        }
    }

    /**
        Search all Ifap cases, for 1st 2nd and 3th non compliance state
    **/
    private void searchIFAP(){
        list<Case> listCase1 = new list<Case>(); // list for 1st non compliance
        list<Case> listCase2 = new list<Case>(); // list for 2nd non compliance
        list<Case> listCase3 = new list<Case>(); // list for 3th non compliance
        // IF FS
        if (isEmpty(this.filter.ifapType) || this.filter.ifapType == 'FS') {
            String query1 = getBaseQuery(RECORDTYPE_IFAP.getRecordTypeId());
            query1 += ' AND FS_Letter_Sent__c = true';
            query1 += ' AND Status in :STATUS_FOR_FS';
            query1 += ' AND firstFSnonComplianceDate__c = null';
            query1 += ' AND FS_Second_Deadline_Date__c = null';
            query1 += ' AND FS_Third_Deadline_Date__c = null';
            query1 += ' AND FS_Deadline_Date__c < TODAY';
            if (!isEmpty(this.filter.dateFilter)) {
                query1 += ' AND FS_Deadline_Date__c = ' + this.filter.dateFilter;
            }
            listCase1.addAll(executeQuery(query1));

            String query2 = getBaseQuery(RECORDTYPE_IFAP.getRecordTypeId());
            query2 += ' AND Status in :STATUS_FOR_FS';
            query2 += ' AND firstFSnonComplianceDate__c != null';
            query2 += ' AND secondFSnonComplianceDate__c = null';
            query2 += ' AND FS_Second_Deadline_Date__c < TODAY';
            if (!isEmpty(this.filter.dateFilter)) {
                query2 += ' AND FS_Second_Deadline_Date__c = ' + this.filter.dateFilter;
            }
            listCase2.addAll(executeQuery(query2));

            String query3 = getBaseQuery(RECORDTYPE_IFAP.getRecordTypeId());
            query3 += ' AND Status in :STATUS_FOR_FS';
            query3 += ' AND firstFSnonComplianceDate__c != null';
            query3 += ' AND secondFSnonComplianceDate__c != null';
            query3 += ' AND FS_third_non_compliance_date__c = null';
            query3 += ' AND FS_Third_Deadline_Date__c < TODAY';
            if (!isEmpty(this.filter.dateFilter)) {
                query3 += ' AND FS_Third_Deadline_Date__c = ' + this.filter.dateFilter;
            }
            listCase3.addAll(executeQuery(query3));
        }
        //IF FA
        if (isEmpty(this.filter.ifapType) || this.filter.ifapType == 'FA') {
            String query1 = getBaseQuery(RECORDTYPE_IFAP.getRecordTypeId());
            query1 += ' AND FA_Letter_Sent__c = true';
            query1 += ' AND Status in :STATUS_FOR_FA';
            query1 += ' AND firstFAnonComplianceDate__c = null';
            query1 += ' AND FA_Second_Deadline_Date__c = null';
            query1 += ' AND FA_Third_Deadline_Date__c = null';
            query1 += ' AND Deadline_Date__c < TODAY';
            if (!isEmpty(this.filter.dateFilter)) {
                query1 += ' AND Deadline_Date__c = ' + this.filter.dateFilter;
            }
            listCase1.addAll(executeQuery(query1));

            String query2 = getBaseQuery(RECORDTYPE_IFAP.getRecordTypeId());
            query2 += ' AND Status in :STATUS_FOR_FA';
            query2 += ' AND firstFAnonComplianceDate__c != null';
            query2 += ' AND secondFAnonComplianceDate__c = null';
            query2 += ' AND FA_Second_Deadline_Date__c < TODAY';
            if (!isEmpty(this.filter.dateFilter)) {
                query2 += ' AND FA_Second_Deadline_Date__c = ' + this.filter.dateFilter;
            }
            listCase2.addAll(executeQuery(query2));

            String query3 = getBaseQuery(RECORDTYPE_IFAP.getRecordTypeId());
            query3 += ' AND Status in :STATUS_FOR_FA';
            query3 += ' AND firstFAnonComplianceDate__c != null';
            query3 += ' AND secondFAnonComplianceDate__c != null';
            query3 += ' AND Third_FA_non_Compliance_Date__c = null';
            query3 += ' AND FA_Third_Deadline_Date__c < TODAY';
            if (!isEmpty(this.filter.dateFilter)) {
                query3 += ' AND FA_Third_Deadline_Date__c = ' + this.filter.dateFilter;
            }
            listCase3.addAll(executeQuery(query3));
        }

        this.listWrapperCase = new list<WrapperCase>();
        for (Case cse: listCase1) {
            Case relatedCase = SidraLiteManager.getRelatedCaseForIFAP(cse);
            if (relatedCase == null) {
                addWrapper(new WrapperCase(cse));
            }
        }
        for (Case cse: listCase2) {
            Case relatedCase = SidraLiteManager.getRelatedCaseForIFAP(cse);
            if (relatedCase!= null) {
                addWrapper(new WrapperCase(cse, relatedCase, SECOND_NON_COMPLIANCE));
            }
        }
        for (Case cse: listCase3) {
            Case relatedCase = SidraLiteManager.getRelatedCaseForIFAP(cse);
            if (relatedCase!= null) {
                addWrapper(new WrapperCase(cse, relatedCase, THIRD_NON_COMPLIANCE));
            }
        }
    }

    /**
        Search all SMAP cases ready to process with SIDRA Lite.
        SMAP process is only for Sidra Lite case creation
    **/
    private void searchSMAP(){
        String query = getBaseQuery(RECORDTYPE_SMAP_ID);
        query += ' AND Decision__c includes (\'Prejudiced Collection of Funds\')';
        query += ' AND Suspension_Date__c <= TODAY';
        if (!isEmpty(this.filter.dateFilter)) {
            query += ' AND Suspension_Date__c = ' + this.filter.dateFilter;
        }

        this.listWrapperCase = new list<WrapperCase>();
        for (Case cse: executeQuery(query)) {
            if (cse.cases.isEmpty()) {
                addWrapper(new WrapperCase(cse));
            }
        }
    }

    /**
        Search SAAM cases ready to process with SIDRA Lite, for 1st, 2nd and 3th non compliance
    **/
    private void searchSAAM(){
        list<Case> listCase1 = new list<Case>(); // list for 1st non compliance
        list<Case> listCase2 = new list<Case>(); // list for 2nd non compliance
        list<Case> listCase3 = new list<Case>(); // list for 3th non compliance

        // Financial Security
        if (isEmpty(this.filter.cse.Reason1__c) || SidraLiteHelperForSAAM.VALID_REASONS1.contains(this.filter.cse.Reason1__c)) {
            String query1 = getBaseQuery(RECORDTYPE_SAAM_ID);
            query1 += ' AND Reason1__c IN ' + serialize(SidraLiteHelperForSAAM.VALID_REASONS1);
            query1 += ' AND Bank_Guarantee_deadline__c < TODAY';
            query1 += ' AND Bank_Guarantee_received__c = null';
            if (!isEmpty(this.filter.dateFilter)) {
                query1 += ' AND Bank_Guarantee_deadline__c = ' + this.filter.dateFilter;
            }
            listCase1.addAll(executeQuery(query1));

            String query2 = getBaseQuery(RECORDTYPE_SAAM_ID);
            query2 += ' AND Reason1__c IN ' + serialize(SidraLiteHelperForSAAM.VALID_REASONS1);
            query2 += ' AND FS_Third_Deadline_Date__c = null';
            query2 += ' AND FS_Second_Deadline_Date__c < TODAY';
            query2 += ' AND Bank_Guarantee_received__c = null';
            if (!isEmpty(this.filter.dateFilter)) {
                query2 += ' AND FS_Second_Deadline_Date__c = ' + this.filter.dateFilter;
            }
            listCase2.addAll(executeQuery(query2));

            String query3 = getBaseQuery(RECORDTYPE_SAAM_ID);
            query3 += ' AND Reason1__c IN ' + serialize(SidraLiteHelperForSAAM.VALID_REASONS1);
            query3 += ' AND FS_third_non_compliance_date__c = null';
            query3 += ' AND FS_Third_Deadline_Date__c < TODAY';
            query3 += ' AND Bank_Guarantee_received__c = null';
            if (!isEmpty(this.filter.dateFilter)) {
                query3 += ' AND FS_Third_Deadline_Date__c = ' + this.filter.dateFilter;
            }
            listCase3.addAll(executeQuery(query3));
        }
        // Certificate DGR
        if (isEmpty(this.filter.cse.Reason1__c) || SidraLiteHelperForSAAM.VALID_REASONS2.contains(this.filter.cse.Reason1__c)) {
            String query1 = getBaseQuery(RECORDTYPE_SAAM_ID);
            query1 += ' AND Reason1__c IN ' + serialize(SidraLiteHelperForSAAM.VALID_REASONS2);
            query1 += ' AND SAAM_Deadline_Date__c < TODAY';
            query1 += ' AND Termination_date__c = null';
            query1 += ' AND Documentation_Complete__c = null';
            if (!isEmpty(this.filter.dateFilter)) {
                query1 += ' AND SAAM_Deadline_Date__c = ' + this.filter.dateFilter;
            }
            listCase1.addAll(executeQuery(query1));

            String query2 = getBaseQuery(RECORDTYPE_SAAM_ID);
            query2 += ' AND Reason1__c IN ' + serialize(SidraLiteHelperForSAAM.VALID_REASONS2);
            query2 += ' AND Termination_date__c < TODAY';
            query2 += ' AND Documentation_Complete__c = null';
            if (!isEmpty(this.filter.dateFilter)) {
                query2 += ' AND Termination_date__c = ' + this.filter.dateFilter;
            }
            listCase2.addAll(executeQuery(query2));

            // no third non compliance for certificare DGR
        }
        // Annual Fees
        if (isEmpty(this.filter.cse.Reason1__c) || SidraLiteHelperForSAAM.VALID_REASONS3.contains(this.filter.cse.Reason1__c)) {
            String query1 = getBaseQuery(RECORDTYPE_SAAM_ID);
            query1 += ' AND Reason1__c IN ' + serialize(SidraLiteHelperForSAAM.VALID_REASONS3);
            query1 += ' AND SAAM_Deadline_Date__c < TODAY';
            query1 += ' AND New_IFAP_deadline_Date__c = null';
            query1 += ' AND Termination_date__c = null';
            query1 += ' AND account.type IN (\'IATA Passenger Sales Agent\',\'IATA Cargo Agent\',\'TIDS Agent\',\'CASS Associate\')';
            query1 += ' AND isClosed = false';
            if (!isEmpty(this.filter.dateFilter)) {
                query1 += ' AND SAAM_Deadline_Date__c = ' + this.filter.dateFilter;
            }
            listCase1.addAll(executeQuery(query1));

            String query2 = getBaseQuery(RECORDTYPE_SAAM_ID);
            query2 += ' AND Reason1__c IN ' + serialize(SidraLiteHelperForSAAM.VALID_REASONS3);
            query2 += ' AND (';
            query2 += '     (account.type IN :TYPE_ACCOUNT_PAX';
            query2 += '     AND Termination_date__c = null';
            query2 += '     AND New_IFAP_Deadline_date__c < TODAY';
            if (!isEmpty(this.filter.dateFilter)) {
                query2 += ' AND New_IFAP_Deadline_date__c = ' + this.filter.dateFilter;
            }
            query2 += '     )';
            query2 += '     OR';
            query2 += '     (account.type IN :TYPE_ACCOUNT_CARGO';
            query2 += '     AND Termination_date__c < TODAY';
            if (!isEmpty(this.filter.dateFilter)) {
                query2 += ' AND Termination_date__c = ' + this.filter.dateFilter;
            }
            query2 += '     )';
            query2 += ' )';
            query2 += ' AND isClosed = false';
            listCase2.addAll(executeQuery(query2));

            String query3 = getBaseQuery(RECORDTYPE_SAAM_ID);
            query3 += ' AND Reason1__c IN ' + serialize(SidraLiteHelperForSAAM.VALID_REASONS3);
            query3 += ' AND account.type IN :TYPE_ACCOUNT_PAX';
            query3 += ' AND Termination_date__c < TODAY';
            query3 += ' AND isClosed = false';
            if (!isEmpty(this.filter.dateFilter)) {
                query3 += ' AND Termination_date__c = ' + this.filter.dateFilter;
            }
            listCase3.addAll(executeQuery(query3));
        }

        this.listWrapperCase = new list<WrapperCase>();
        for (Case cse: listCase1) {
            if (cse.cases.isEmpty()) {
                addWrapper(new WrapperCase(cse));
            }
        }
        for (Case cse: listCase2) {
            if (!cse.cases.isEmpty()) {
                if (SidraLiteHelperForSAAM.VALID_REASONS3.contains(cse.Reason1__c)
                 && SidraLiteUtil.isCargoCASS(cse.account) && cse.Cases[0].Propose_Default__c!=null) {
                     // ignore these cases
                } else {
                    addWrapper(new WrapperCase(cse, cse.Cases[0], SECOND_NON_COMPLIANCE));
                }
            }
        }
        for (Case cse: listCase3) {
            if (!cse.cases.isEmpty()
            && SidraLiteUtil.isPassenger(cse.account) && cse.Cases[0].Propose_Default__c==null) {
                addWrapper(new WrapperCase(cse, cse.Cases[0], THIRD_NON_COMPLIANCE));
            }
        }
    }

    /**
        Search all OSCAR cases ready to create SIDRA Lite Cases
    **/
    private void searchOSCAR(){
        this.listWrapperCase = new list<WrapperCase>();

        // Valid reasons 1
        if (isEmpty(this.filter.cse.Reason1__c) || SidraLiteHelperForOSCAR.VALID_REASONS1.contains(this.filter.cse.Reason1__c)) {
            String query1 = getBaseQuery(RECORDTYPE_OSCAR_ID);
            query1 += ' AND Reason1__c IN ' + serialize(SidraLiteHelperForOSCAR.VALID_REASONS1);
            query1 += ' AND (OSCAR__r.Step6__c = \'Failed\'';
            query1 += ' OR OSCAR__r.Step9__c = \'Failed\'';
            query1 += ' OR OSCAR__r.Step11__c = \'Failed\'';
            query1 += ' OR OSCAR__r.Step12__c = \'Failed\'';
            query1 += ' OR OSCAR__r.Step14__c = \'Failed\'';
            query1 += ' OR OSCAR__r.RPM_Approval__c = \'Authorize Disapproval\')';

            for (Case cse: executeQuery(query1)) {
                try {
                    // check the reason
                    SidraLiteHelperForOSCAR.getOSCARReason(cse);
                    addWrapper(new WrapperCase(cse));
                } catch (WSSidraLite.SidraLiteException e) {
                    // do not add cases with exception, it means that ther is already a sidra lite case for this reason
                }
            }
        }

        // Certificate DGR
        list<Case> listCase1 = new list<Case>(); // list for 1st non compliance
        list<Case> listCase2 = new list<Case>(); // list for 2nd non compliance

        if (isEmpty(this.filter.cse.Reason1__c) || SidraLiteHelperForOSCAR.VALID_REASONS2.contains(this.filter.cse.Reason1__c)) {
            String query1 = getBaseQuery(RECORDTYPE_OSCAR_ID);
            query1 += ' AND Reason1__c IN ' + serialize(SidraLiteHelperForOSCAR.VALID_REASONS2);
            query1 += ' AND SAAM_Deadline_Date__c < TODAY';
            query1 += ' AND Termination_date__c = null';
            query1 += ' AND Documentation_Complete__c = null';
            listCase1.addAll(executeQuery(query1));

            String query2 = getBaseQuery(RECORDTYPE_OSCAR_ID);
            query2 += ' AND Reason1__c IN ' + serialize(SidraLiteHelperForOSCAR.VALID_REASONS2);
            query2 += ' AND Termination_date__c < TODAY';
            query2 += ' AND Documentation_Complete__c = null';
            if (!isEmpty(this.filter.dateFilter)) {
                query2 += ' AND Termination_date__c = ' + this.filter.dateFilter;
            }
            listCase2.addAll(executeQuery(query2));

            // no third non compliance for certificare DGR
        }

        for (Case cse: listCase1) {
            if (cse.cases.isEmpty()) {
                addWrapper(new WrapperCase(cse));
            }
        }
        for (Case cse: listCase2) {
            if (!cse.cases.isEmpty()) {
                addWrapper(new WrapperCase(cse, cse.Cases[0], SECOND_NON_COMPLIANCE));
            }
        }
    }

    /**
        Search all invoicing cases ready to process SIDRA Lite including 1st, 2nd and 3th non compliance
    **/
    private void searchInvoicing(){
        list<Case> listCase1 = new list<Case>(); // list for 1st non compliance
        list<Case> listCase2 = new list<Case>(); // list for 2nd non compliance
        list<Case> listCase3 = new list<Case>(); // list for 3th non compliance

        String query1 = getBaseQuery(RECORDTYPE_INVOICING_ID);
        query1 += ' AND SAAM_Deadline_Date__c < TODAY';
        query1 += ' AND (account.type IN :TYPE_ACCOUNT_PAX OR account.type IN :TYPE_ACCOUNT_CARGO OR account.type IN :TYPE_ACCOUNT_AGENT)';
        query1 += ' AND Has_the_agent_paid_invoice__c IN ' + serialize(SidraLiteHelperForInvoicing.VALID_AGENT_PAID);
        if (!isEmpty(this.filter.dateFilter)) {
            query1 += ' AND SAAM_Deadline_Date__c = ' + this.filter.dateFilter;
        }
        listCase1 = executeQuery(query1);

        String query2 = getBaseQuery(RECORDTYPE_INVOICING_ID);
        query2 += ' AND Termination_date__c = null';
        query2 += ' AND (';
        query2 += ' (account.type IN :TYPE_ACCOUNT_PAX';
        query2 += ' AND New_IFAP_Deadline_date__c < TODAY';
        if (!isEmpty(this.filter.dateFilter)) {
            query2 += ' AND New_IFAP_Deadline_date__c = ' + this.filter.dateFilter;
        }
        query2 += ' )';
        query2 += ' OR';
        query2 += ' (account.type IN :TYPE_ACCOUNT_CARGO';
        query2 += ' AND Termination_date__c < TODAY )';
        if (!isEmpty(this.filter.dateFilter)) {
            query2 += ' AND Termination_date__c = ' + this.filter.dateFilter;
        }
        query2 += ' )';
        query2 += ' AND Has_the_agent_paid_invoice__c IN ' + serialize(SidraLiteHelperForInvoicing.VALID_AGENT_PAID);
        listCase2 = executeQuery(query2);

        String query3 = getBaseQuery(RECORDTYPE_INVOICING_ID);
        query3 += ' AND account.type IN :TYPE_ACCOUNT_PAX';
        query3 += ' AND Termination_date__c < TODAY';
        query3 += ' AND Has_the_agent_paid_invoice__c IN ' + serialize(SidraLiteHelperForInvoicing.VALID_AGENT_PAID);
        if (!isEmpty(this.filter.dateFilter)) {
            query3 += ' AND Termination_date__c = ' + this.filter.dateFilter;
        }
        listCase3 = executeQuery(query3);

        this.listWrapperCase = new list<WrapperCase>();
        for (Case cse: listCase1) {
            if (cse.cases.isEmpty()) {
                addWrapper(new WrapperCase(cse));
            }
        }
        for (Case cse: listCase2) {
            if (!cse.cases.isEmpty()) {
                if (!(TYPE_ACCOUNT_CARGO.contains(cse.account.type) && cse.Cases[0].Propose_Default__c!=null)) {
                    addWrapper(new WrapperCase(cse, cse.Cases[0], SECOND_NON_COMPLIANCE));
                }
            }
        }
        for (Case cse: listCase3) {
            if (!cse.cases.isEmpty() && cse.cases[0].Propose_Default__c == null) {
                addWrapper(new WrapperCase(cse, cse.Cases[0], THIRD_NON_COMPLIANCE));
            }
        }
    }


    /**
        porcess SIDRA Lite action to all selected cases
    **/

    public void triggerSidraLiteAction() {
        set<Id> setSelectedIds = new Set<Id>();
        for (String ids  : this.selectedIds.split(',')) {
            try {
                setSelectedIds.add(Id.valueOf(ids));
            } catch(Exception e) {
                System.debug( ids + ' ' + e.getMessage());
            }
        }
        this.selectedIds = '';
        list<WrapperCase> listSelected = new list<WrapperCase>();
        for (WrapperCase wrapper: this.listWrapperCase) {
            if (setSelectedIds.contains(wrapper.cse.Id)) {
                listSelected.add(wrapper);
                System.debug('**** selectedId ' + wrapper.cse.caseNumber);
            }
        }
        if (listSelected.size()<MIN_CASES_FOR_BATCH) {
            processCases(listSelected);
        } else {
            processCasesBatch(listSelected);
        }
    }

    private void processCases(list<WrapperCase> listSelected) {
        list<Case> listUpsert = new list<Case>();
        list<Id> listParentId = new list<Id>();
        for (WrapperCase wrapper: listSelected) {
            list<Case> casesToUpdate = getSidraLiteCase(wrapper);
            listUpsert.addAll(casesToUpdate);
            listParentId.add(wrapper.cse.Id);
        }
        this.listWrapperCase = listSelected;
        // check if there are selected cases
        if (listUpsert.isEmpty()) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'There are no cases selected'));
            return;
        }

        // make the upsert and store the results in a map

        list<Database.UpsertResult> listResult = Database.upsert(listUpsert, false);
        map<Id,Database.UpsertResult> mapResults = new map<Id,Database.UpsertResult>();
        for (Integer i=0; i<listUpsert.size();i++) {
            Case upsertCase = listUpsert[i];
            Database.UpsertResult result = listResult[i];
            Id key = upsertCase.Id!=null? upsertCase.Id: upsertCase.ParentId;
            mapResults.put(key,result);
        }

        // query all sidra lite cases recently inserted and updated
        map<Id,Case> mapChild = new map<Id,Case>();
        for (Case child: [Select Id, SIDRA_lite_Reason__c, Status, ParentId, RecordtypeId,
                FA_Letter_Sent__c, Deadline_Date__c, firstFAnonComplianceDate__c, FA_Second_Deadline_Date__c, FA_Third_Deadline_Date__c, secondFAnonComplianceDate__c,
                FS_Letter_Sent__c, FS_Deadline_Date__c, firstFSnonComplianceDate__c, FS_Second_Deadline_Date__c, FS_Third_Deadline_Date__c, secondFSnonComplianceDate__c,
                ContactId, IFAP_Agent_Type__c, AccountId, CaseNumber, Origin, Subject, IFAP_Agent_Code__c, Region__c, Account_Billing_Country__c,
                BSP_CASS__c, Reason_for_Default__c, Confirmation_moneys_not_received__c, DEF_Approval_Rejection__c, Termination_date_manual_entry__c,
                TER_Approval_Rejection__c, Termination_Reason__c, Propose_Default__c, NOT_Date__c, Comments__c,
                Account.Id, Account.Type, Account.Status__c
            FROM Case
            WHERE RecordtypeId = :RECORDTYPE_SIDRA_LITE.getRecordTypeId()
            AND ParentId in :listParentId]) {
                mapChild.put(child.ParentId, child);
        }
        // update the children info and the DML results into the main Wrapper
        for (WrapperCase wrapper: this.listWrapperCase) {
            wrapper.child = mapChild.get(wrapper.cse.Id);
            wrapper.addResult(mapResults.get(wrapper.getChildId()));
            wrapper.addResult(mapResults.get(wrapper.cse.Id));
        }
        insertComments(this.listWrapperCase);
        this.showResultSection = true;
        //this.showConfirmTriggerSidraLiteAction = false;
    }

    private void processCasesBatch(list<WrapperCase> listSelected) {
        list<Case> listUpsert = new list<Case>();
        for (WrapperCase wrapper: listSelected) {
            list<Case> casesToUpdate = getSidraLiteCase(wrapper);
            listUpsert.addAll(casesToUpdate);
        }
        SIDRALiteMassActionBatch batch = new SIDRALiteMassActionBatch(listUpsert, UserInfo.getUSerId());
        Database.executeBatch(batch, 1);
        this.showProcessBatchSection = true;
    }

    /**
        Check all succesfully updated cases and call the method insert comments
        this action is done after clicking the button 'Sidra Lite Action' and must be done here too
    **/
    private void insertComments(list<WrapperCase> listWrapper) {
        // list for all cases in 1st non compliance
        list<Case> listCaseToInsertComment = new list<Case>();
        // list of all corretly updated case Ids
        list<Id> listCaseId = new list<Id>();
        for (WrapperCase wrapper: this.listWrapperCase) {
            if (wrapper.getIsSuccess() ) {
                listCaseId.add(wrapper.cse.Id);
                listCaseId.add(wrapper.child.Id);
                if (wrapper.type != FIRST_NON_COMPLIANCE) {
                    listCaseToInsertComment.add(wrapper.child);
                }
            }
        }
        insertCommentForMassAction(listCaseId);
        WSSidraLite.insertComments(listCaseToInsertComment);
    }

    public static void insertCommentForMassAction(list<Id> listCaseId) {
        try {
            list<CaseComment> listComments = new list<CaseComment>();
            for (Id caseId: listCaseId) {
                listComments.add(
                    new CaseComment(
                        ParentId = caseId,
                        CommentBody = 'This case was processed via SIDRA Lite mass action tool')
                );
            }
            insert listComments;
        } catch (Exception e) {
            System.debug('Problem inserting comments to updated cases ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'Problem inserting comments to updated cases'));
        }
    }

    /**
        process a sinlge input case with SIDRA Lite
    **/
    private list<Case> getSidraLiteCase(WrapperCase wrapper){
        try {
            list<Case> listCase = new list<Case>();
            if (wrapper.type == FIRST_NON_COMPLIANCE ) {
                if (this.filter.getIsIFAP()) {
                    wrapper.child = SidraLiteHelperForIFAP.createDummyCaseFirstNonCompliance(wrapper.cse);
                    listCase.add(wrapper.child);
                } else if (this.filter.getIsSMAP()) {
                    wrapper.child = SidraLiteHelperForSMAP.createCase(wrapper.cse);
                    listCase.add(wrapper.child);
                } else if (this.filter.getIsSAAM()) {
                    wrapper.child = SidraLiteHelperForSAAM.createDummyCaseFirstNonCompliance(wrapper.cse);
                    listCase.add(wrapper.child);
                } else if (this.filter.getIsOSCAR()) {
                    wrapper.child = SidraLiteHelperForOSCAR.createCase(wrapper.cse);
                    listCase.add(wrapper.child);
                } else if (this.filter.getIsInvoicing()) {
                    wrapper.child = SidraLiteHelperForInvoicing.createDummyCaseFirstNonCompliance(wrapper.cse);
                    listCase.add(wrapper.child);
                }
            } else {
                if (this.filter.getIsIFAP()) {
                    listCase = SidraLiteHelperForIFAP.updateSidraLiteAndParent(wrapper.cse, wrapper.child);
                } else if (this.filter.getIsSAAM()) {
                    listCase = SidraLiteHelperForSAAM.updateSidraLiteAndParent(wrapper.cse, wrapper.child);
                } else if (this.filter.getIsInvoicing()) {
                    listCase = SidraLiteHelperForInvoicing.updateSidraLiteAndParent(wrapper.cse, wrapper.child);
                }
            }
            return listCase;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'ERROR in case ' + wrapper.cse.CaseNumber + ': '  + e.getMessage()));
            return new list<Case>();
        }
    }

    /**
        Wrapper to show a case in the main table adding a selection checkbox
    **/
    public class WrapperCase {
        public Boolean selected {get; set;}
        public Case cse {get; set;}
        public Case child {get; set;}
        public String type {get; set;}
        public list<String> listErrors {get; set;}

        public WrapperCase(Case cse) {
            this.cse = cse;
            this.type = FIRST_NON_COMPLIANCE;
            this.selected = false;
            this.listErrors = new list<String>();
        }
        public WrapperCase(Case cse, Case child, String type) {
            this.cse = cse;
            this.child = child;
            this.type = type;
            this.selected = false;
            this.listErrors = new list<String>();
        }

        public void addResult(Database.UpsertResult result) {
            if (result!=null && !result.isSuccess()) {
                for ( Database.Error error: result.getErrors()) {
                    this.listErrors.add(error.getMessage());
                }
            }
        }

        public Boolean getIsSuccess() {
            return this.listErrors.isEmpty();
        }

        public String getChildId() {
            try {
                return this.child.Id;
            } catch (Exception e) {
                return null;
            }
        }

        public String getIfapType() {
            if (STATUS_FOR_FS.contains(this.cse.Status) ) {
                return 'FS';
            }
            if (STATUS_FOR_FA.contains(this.cse.Status) ) {
                return 'FA';
            }
            return '';
        }

    }

    /**
        class to store all variables required to create a set of filters
        for the case selection
    **/
    public class WrapperFilter {
        public Case cse {get; set;}
        public Account account {get; set;}
        public String ifapType {get; set;}
        public String category {get; set;}
        public String dateFilter {get; set;}

        public WrapperFilter() {
            reset();
        }

        public void reset() {
            this.cse = new Case();
            this.account = new Account();
            this.ifapType = '';
            this.category = '';
            this.cse.Region__c = SidraLiteUtil.getDefaultRegion();
            this.cse.BSPCountry__c = '';

            //this.cse.RecordtypeId = RECORDTYPE_SAAM_ID;
            //this.cse.Region__c = 'Americas';
            //this.cse.Reason1__c = 'Annual Fees';
        }

        public list<SelectOption> getListRecordtype() {
            list<SelectOption> listOptions = new list<SelectOption>();
            listOptions.add(new SelectOption('', '--None--'));
            for ( Schema.RecordTypeInfo rt: LIST_RT.values() ) {
                listOptions.add(new SelectOption(rt.getRecordTypeId(), rt.getName()));
            }
            return listOptions;
        }

        public list<SelectOption> getListReasons() {
            list<SelectOption> listOptions = new list<SelectOption>();
            if (getIsOSCAR()) {
                listOptions.add(new SelectOption('', '--None--'));
                for( String reason : SidraLiteHelperForOSCAR.VALID_REASONS) {
                    listOptions.add(new SelectOption(reason, reason));
                }
            } else if (getIsSAAM()) {
                listOptions.add(new SelectOption('', '--None--'));
                for( String reason : SidraLiteHelperForSAAM.VALID_REASONS) {
                    listOptions.add(new SelectOption(reason, reason));
                }
            } else if (getIsInvoicing()) {
                for( String reason : SidraLiteHelperForInvoicing.VALID_REASONS) {
                    listOptions.add(new SelectOption(reason, reason));
                }
            }
            return listOptions;
        }

        public list<SelectOption> getListIFAPCountries() {
            list<SelectOption> listOptions = new list<SelectOption>();
            listOptions.add(new SelectOption('', '--None--'));
            for( IATA_ISO_Country__c isoCountry : [
                    SELECT Name From IATA_ISO_Country__c
                    WHERE Region__c = :this.cse.Region__c
                    AND Name != 'All Region'
                    ORDER BY Name]) {
                listOptions.add(new SelectOption(isoCountry.Name, isoCountry.Name));
            }
            return listOptions;
        }

        public list<SelectOption> getListFinancialReviews() {
            list<SelectOption> listOptions = new list<SelectOption>();
            listOptions.add(new SelectOption('', '--None--'));
            for(Schema.Picklistentry picklistEntry : Case.Financial_Review_Type__c.getDescribe().getPicklistValues()) {
                listOptions.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
            }
            return listOptions;
        }


        public Boolean getIsIFAP() {
            return this.cse.RecordtypeId == RECORDTYPE_IFAP.getRecordTypeId();
        }

        public Boolean getIsSMAP() {
            return this.cse.RecordtypeId == RECORDTYPE_SMAP.getRecordTypeId();
        }

        public Boolean getIsOSCAR() {
            return this.cse.RecordtypeId == RECORDTYPE_OSCAR.getRecordTypeId();
        }

        public Boolean getIsSAAM() {
            return this.cse.RecordtypeId == RECORDTYPE_SAAM.getRecordTypeId();
        }

        public Boolean getIsInvoicing() {
            return this.cse.RecordtypeId == RECORDTYPE_INVOICING.getRecordTypeId();
        }

        public String getShortName() {
            if (getIsIFAP()) {
                return 'IFAP';
            }
            if (getIsSMAP()) {
                return 'sMAP';
            }
            if (getIsOSCAR()) {
                return 'OSCAR';
            }
            if (getIsSAAM()) {
                return 'SAAM';
            }
            if (getIsInvoicing()) {
                return 'Invoicing';
            }
            return '';
        }
    }

    /**
        Redirect to the Page in csv format
    **/
    public PageReference exportCSV() {
        return Page.SIDRAliteMassActionExport;
    }

    /**
        Returns a string with the content of current listWrapper in csv format
    **/
    public String getcsvContent() {
        Map <String, Schema.SObjectField> mapCaseFields = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();
        Map <String, Schema.SObjectField> mapAccountFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();

        // create csv header
        String content = '"Id"';
        content += ',"' + mapCaseFields.get('CaseNumber').getDescribe().getLabel() + '"';
        content += ',"' + mapCaseFields.get('Subject').getDescribe().getLabel() + '"';
        content += ',"' + mapCaseFields.get('Status').getDescribe().getLabel() + '"';
        if (filter.getIsIFAP())
            content += ',"' + mapCaseFields.get('Financial_Review_Type__c').getDescribe().getLabel() + '"';
        if (filter.getIsIFAP())
            content += ',"FA/FS"';
        content += ',"Account Id"';
        content += ',"' + mapAccountFields.get('Name').getDescribe().getLabel() + '"';
        if (filter.getIsIFAP()) {
            content += ',"' + mapCaseFields.get('Account_Billing_Country__c').getDescribe().getLabel() + '"';
        } else {
            content += ',"' + mapCaseFields.get('BSPCountry__c').getDescribe().getLabel() + '"';
        }
        content += ',"' + mapCaseFields.get('OwnerId').getDescribe().getLabel() + '"';
        content += ',"' + mapCaseFields.get('OwnerId').getDescribe().getLabel() + ' Name"';
        content += ',"' + mapCaseFields.get('ContactId').getDescribe().getLabel() + '"';
        content += ',"' + mapCaseFields.get('ContactId').getDescribe().getLabel() + ' Name"';
        content += ',"' + mapAccountFields.get('Category__c').getDescribe().getLabel() + '"';
        content += ',"' + mapCaseFields.get('Key_Customer_Case__c').getDescribe().getLabel() + '"';
        if (!filter.getIsIFAP())
            content += ',"' + mapCaseFields.get('Reason1__c').getDescribe().getLabel() + '"';
        content += '\n';
        // fill each line
        for (WrapperCase wrapper: this.listWrapperCase) {
            content += '"' + wrapper.cse.Id + '"';
            content += ',"' + wrapper.cse.CaseNumber + '"';
            content += ',"' + wrapper.cse.Subject + '"';
            content += ',"' + wrapper.cse.Status + '"';
            if (filter.getIsIFAP()) content += ',"' + wrapper.cse.Financial_Review_Type__c + '"';
            if (filter.getIsIFAP()) content += ',"' + wrapper.getifapType() + '"';
            content += ',"' + wrapper.cse.AccountId + '"';
            content += ',"' + wrapper.cse.Account.Name + '"';
            if (filter.getIsIFAP()) {
                content += ',"' + wrapper.cse.Account_Billing_Country__c + '"';
            } else {
                content += ',"' + wrapper.cse.BSPCountry__c + '"';
            }
            content += ',"' + wrapper.cse.OwnerId + '"';
            content += ',"' + wrapper.cse.Owner.Name + '"';
            content += ',"' + wrapper.cse.ContactId + '"';
            content += ',"' + wrapper.cse.Contact.Name + '"';
            content += ',"' + wrapper.cse.Account.Category__c + '"';
            content += ',"' + (wrapper.cse.Key_Customer_Case__c!=null? 'true': 'false') + '"';
            if (!filter.getIsIFAP()) content += ',"' + wrapper.cse.Reason1__c + '"';
            content += '\n';
        }
        return content;
    }

}