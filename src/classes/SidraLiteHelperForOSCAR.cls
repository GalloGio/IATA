/**
    Methods to process SIDRA Lite when parent Case is OSCAR
**/
public with sharing class SidraLiteHelperForOSCAR {

    public static final set<String> VALID_REASONS = new set<String>{'CHO / CHS – Change of Ownership / Legal Status','CHC – Change of Shareholding','CHN - Change of Name','CHL - Change of Location','Certificate DGR','Major Change', 'Change of Hierarchy', 'Accreditation Type','Annual revalidation'};
    public static final set<String> VALID_REASONS1 = new set<String>{'CHO / CHS – Change of Ownership / Legal Status','CHC – Change of Shareholding','CHN - Change of Name','CHL - Change of Location','Major Change', 'Change of Hierarchy', 'Accreditation Type','Annual revalidation'};
    public static final set<String> VALID_REASONS2 = new set<String>{'Certificate DGR'};
    
    public static String CHECK_STEP = null;

    public static final map<String,String> MAP_STEP_REASON = new map<String,String>{
        '6' => 'Non submission of supporting documents',
        '9' => 'Non payment of change fees',
        '11' => 'Financial Review Non-compliance (OSCAR Change)',
        '12' => 'Financial Security Non-compliance (OSCAR Change)',
        '14' => 'Non submission of PSAA',
        '26' => 'Late/Absence of Notification of Change',
        '35' => 'Financial Security Non-compliance (OSCAR Change)',
        '44' => 'Annual Revalidation Non-Compliance',
        'RPM' => 'Change Deficiency',
        'DGR' => 'Failure to submit DGR certificate by deadline'
    };

    public static void checkBussinessRules(Case cse) {
        try {
            if (cse.OSCAR__r==null) {
                throw new WSSidraLite.SidraLiteException('You cannot create a SIDRA Lite without an OSCAR record');
            }
            if (cse.Reason1__c == null) {
                throw new WSSidraLite.SidraLiteException('You cannot create a SIDRA Lite under no reason');
            }
            if (!VALID_REASONS.contains(cse.Reason1__c)) {
                throw new WSSidraLite.SidraLiteException('You cannot create a SIDRA Lite under reason "' + cse.Reason1__c + '"');
            }
        } catch(Exception e) {
            throw new WSSidraLite.SidraLiteException(e.getMessage());
        }
    }

    public static Case createDummyCaseFirstNonCompliance(Case cse){
        return createCase(cse);
    }

    /**
        Create a new sidra lite case from an OSCAR case
    **/
    public static Case createCase(Case cse){
        try {
            checkBussinessRules(cse);
            if (VALID_REASONS1.contains(cse.Reason1__c)) {
                return createCaseReasons1(cse);
            } else if (VALID_REASONS2.contains(cse.Reason1__c)) {
                return createCaseReasons2(cse);
            }
            // if no valid reason is found
            throw new WSSidraLite.SidraLiteException('You cannot create a SIDRA Lite under reason "' + cse.Reason1__c + '"');

        } catch(Exception e) {
            throw new WSSidraLite.SidraLiteException(e.getMessage());
        }
    }

    public static Case createCaseReasons1(Case cse){
        Case newCase = new Case();
        newCase.RecordTypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE;
        newCase.Subject = 'SIDRA Lite – Non-Compliance due to "' + cse.Reason1__c + '"';
        newCase.ParentId = cse.Id;
        newCase.AccountId = cse.AccountId;
        newCase.ContactId = cse.ContactId;
        newCase.Region__c = cse.Region__c;
        newCase.BSPCountry__c = cse.BSPCountry__c;
        newCase.BSP_CASS__c = SidraLiteUtil.getBSPCASS(cse.account);
        newCase.SIDRA_Lite_Reason__c = getOSCARReason(cse);

        if (SidraLiteUtil.isAccountActive(cse.account)) {
            newCase.NOT_Date__c = Date.today();
            newCase.SIDRA_Lite_Default_Date__c = Date.Today();
            newCase.Reason_for_Default__c = 'Disapproval of Change';
            newCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
            newCase.Total_Irregularities__c = String.ValueOf(cse.account.Accumulated_Irregularities__c);
        } else {
            newCase.IRR_Withdrawal_Reason__c = 'Default Prev';
            newCase.Termination_date_manual_entry__c = WSSidraLite.getTerminationDateFromRelatedCase(cse.account);
        }
        return newCase;
    }

    public static Case createCaseReasons2(Case cse){
        Case newCase = new Case();
        newCase.RecordTypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE;
        newCase.Subject = 'SIDRA Lite – ' + cse.Reason1__c;
        newCase.ParentId = cse.Id;
        newCase.AccountId = cse.AccountId;
        newCase.ContactId = cse.ContactId;
        newCase.Region__c = cse.Region__c;
        newCase.BSPCountry__c = cse.BSPCountry__c;
        newCase.BSP_CASS__c = SidraLiteUtil.getBSPCASS(cse.account);
        newCase.SIDRA_Lite_Reason__c = 'Failure to submit DGR certificate by deadline';
        newCase.Origin = 'IATA Internal User';
        newCase.Status = 'Open';

        if (SidraLiteUtil.isAccountActive(cse.account)) {
            newCase.SIDRA_Lite_Default_Date__c = Date.Today();
            newCase.Reason_for_Default__c = 'DGR Certificate';
            newCase.NOT_Date__c = Date.today();
            newCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
        } else {
            newCase.IRR_Withdrawal_Reason__c = 'Default Prev';
            newCase.Termination_date_manual_entry__c = WSSidraLite.getTerminationDateFromRelatedCase(cse.account);
        }
        return newCase;
    }

    public static String getOSCARReason(Case cse) {
        // create a set with all reasons of the children
        set<String> existentReasons = new set<String>();
        for (Case child: cse.Cases) {
            existentReasons.add(child.SIDRA_Lite_Reason__c);
        }

        AMS_OSCAR__c oscar = cse.OSCAR__r;

        if (oscar.Step6__c == 'Failed') {
            String reason = MAP_STEP_REASON.get('6');
            if (!existentReasons.contains(reason) ) {
                return reason;
            }
        }
        if (oscar.Step9__c == 'Failed') {
            String reason = MAP_STEP_REASON.get('9');
            if (!existentReasons.contains(reason) ) {
                return reason;
            }
        }
        if (oscar.Step11__c == 'Failed') {
            String reason = MAP_STEP_REASON.get('11');
            if (!existentReasons.contains(reason) ) {
                return reason;
            }
        }
        if (oscar.Step12__c == 'Failed') {
            String reason = MAP_STEP_REASON.get('12');
            if (!existentReasons.contains(reason) ) {
                return reason;
            }
        }
        if (oscar.Step14__c == 'Failed') {
            String reason = MAP_STEP_REASON.get('14');
            if (!existentReasons.contains(reason) ) {
                return reason;
            }
        }
        if (oscar.Step26__c == 'Failed') {
            String reason = MAP_STEP_REASON.get('26');
            if (!existentReasons.contains(reason) ) {
                return reason;
            }
        }
        if (oscar.Step35__c == 'Failed') {
            String reason = MAP_STEP_REASON.get('35');
            if (!existentReasons.contains(reason) ) {
                return reason;
            }
        }
        if (oscar.Step44__c == 'Failed') {
            String reason = MAP_STEP_REASON.get('44');
            if (!existentReasons.contains(reason) ) {
                return reason;
            }
        }
        if (oscar.RPM_Approval__c == 'Authorize Disapproval') {
            String reason = MAP_STEP_REASON.get('RPM');
            if (!existentReasons.contains(reason) ) {
                return reason;
            }
        }
        throw new WSSidraLite.SidraLiteException('Unable to identify a non-compliance scenario in this case');
    }

    public static Case getRelatedCase(Case parentCase) {
        if (VALID_REASONS1.contains(parentCase.Reason1__c)) {
            String reasonToCheck = MAP_STEP_REASON.get(CHECK_STEP);
            if (CHECK_STEP!=null) {
                for (Case cse: parentCase.Cases) {
                    if (cse.SIDRA_lite_Reason__c == reasonToCheck) {
                        return cse;
                    }
                }
            }
        } else if (VALID_REASONS2.contains(parentCase.Reason1__c)) {
            if (parentCase.Cases.size() > 0) {
                return parentCase.Cases.get(0);
            }
        }
        return null;
    }

    /**
        Check conditions to show an alert message to user to confirm if second or third non compliance must be processed
    **/
    public static void throwPopUpMessage(Case parentCase) {
        if (VALID_REASONS2.contains(parentCase.Reason1__c)) {
            throw new WSSidraLite.ShowConfirmationException('Update child Sidra Lite case, continue?');
        } else {
            throw new WSSidraLite.SidraLiteException('SIDRA Lite case already created, cannot create another one');
        }
    }

    public static list<Case> updateSidraLiteAndParent(Case parentCase, Case childCase) {
        // case CERTIFICATE DGR
        if (VALID_REASONS2.contains(parentCase.Reason1__c)) {
            if (parentCase.Termination_date__c == null ) {
                throw new WsSidraLite.SidraLiteException('Cannot update if termination date is empty');
            }
            if (parentCase.Termination_date__c >= Date.today() ) {
                throw new WsSidraLite.SidraLiteException('Cannot update if termination date is future');
            }
            childCase.Propose_Default__c = DateTime.now();
            childCase.Termination_Reason__c = 'Non Renewal of DGR certificate';
            childCase.Status = 'Re-opened';
        } else {
            throw new WSSidraLite.SidraLiteException('SIDRA Lite case already created, cannot create another one');
        }

        list<Case> listUpdate = new list<Case>();
        listUpdate.add(childCase);
        listUpdate.add(parentCase);
        return listUpdate;
    }

}