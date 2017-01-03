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
            if (cse.Cases != null && ! cse.Cases.isEmpty()) {
                throw new WSSidraLite.SidraLiteException('SIDRA Lite case already created, cannot create another one');
            }
            if (cse.OSCAR__r==null ||
                    !(
                        cse.OSCAR__r.RPM_Approval__c == 'Authorize Disapproval' ||
                        cse.OSCAR__r.Step11__c == 'Failed' ||
                        cse.OSCAR__r.Step12__c == 'Failed' ||
                        cse.OSCAR__r.Step13__c == 'Failed' ||
                        cse.OSCAR__r.Step14__c == 'Failed'
                    )
            ) {
                throw new WSSidraLite.SidraLiteException('You cannot create a SIDRA Lite case if the Change Disapproval is not Authorized or the Sanity Check Failure is not Failed');
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
            newCase.SIDRA_Lite_Reason__c = getOSCARReason(cse.OSCAR__r);

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

    private static String getOSCARReason(AMS_OSCAR__c oscar) {
        if (oscar.Step11__c == 'Failed' || oscar.Step12__c == 'Failed' || oscar.Step13__c == 'Failed' || oscar.Step14__c == 'Failed') {
            return 'Non submission of supporting documents';
        }
        return 'Change deficiency';
    }
}