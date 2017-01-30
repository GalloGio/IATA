/**
    Methods to process SIDRA Lite when parent Case is OSCAR
**/
public with sharing class SidraLiteHelperForOSCAR {

    public static final set<String> VALID_REASONS = new set<String>{'CHO / CHS – Change of Ownership / Legal Status','CHC – Change of Shareholding','CHN - Change of Name','CHL - Change of Location'};

    /**
        Create a new sidra lite case from an OSCAR case
    **/
    public static Case createCase(Case cse){
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
                newCase.SIDRA_Lite_Default_Date__c = Date.Today();
                newCase.Reason_for_Default__c = 'Disapproval of Change';
                newCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
                newCase.Total_Irregularities__c = String.ValueOf(cse.account.Accumulated_Irregularities__c);
            } else {
                newCase.IRR_Withdrawal_Reason__c = 'Default Prev';
                newCase.Termination_date_manual_entry__c = WSSidraLite.getTerminationDateFromRelatedCase(cse.account);
            }
            return newCase;

        } catch(Exception e) {
            throw new WSSidraLite.SidraLiteException(e.getMessage());
        }
    }

    public static String getOSCARReason(Case cse) {
        // create a set with all reasons of the children
        set<String> existentReasons = new set<String>();
        for (Case child: cse.Cases) {
            existentReasons.add(child.SIDRA_Lite_Reason__c);
        }

        AMS_OSCAR__c oscar = cse.OSCAR__r;

        if (oscar.Step6__c == 'Failed') {
            String reason = 'Non submission of supporting documents';
            if (!existentReasons.contains(reason) ) {
                return reason;
            }
        }
        if (oscar.Step9__c == 'Failed') {
            String reason = 'Non payment of change fees';
            if (!existentReasons.contains(reason) ) {
                return reason;
            }
        }
        if (oscar.Step11__c == 'Failed') {
            String reason = 'Financial Review Non-compliance (OSCAR Change)';
            if (!existentReasons.contains(reason) ) {
                return reason;
            }
        }
        if (oscar.Step12__c == 'Failed') {
            String reason = 'Financial Security Non-compliance (OSCAR Change)';
            if (!existentReasons.contains(reason) ) {
                return reason;
            }
        }
        if (oscar.Step14__c == 'Failed') {
            String reason = 'Non submission of PSAA';
            if (!existentReasons.contains(reason) ) {
                return reason;
            }
        }
        if (oscar.RPM_Approval__c == 'Authorize Disapproval') {
            String reason = 'Change Deficiency';
            if (!existentReasons.contains(reason) ) {
                return reason;
            }
        }
        throw new WSSidraLite.SidraLiteException('Unable to identify a non-compliance scenario in this case');
    }

}
