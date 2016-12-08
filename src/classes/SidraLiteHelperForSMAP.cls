/**
    Methods to process SIDRA Lite when parent Case is SMAP
**/
public with sharing class SidraLiteHelperForSMAP {

    /**
        Create a new sidra lite case from a sMAP case
    **/
    public static Case createCase(Case cse){
        try {
            if (cse.Cases != null && ! cse.Cases.isEmpty()) {
                throw new WSSidraLite.SidraLiteException('SIDRA Lite case already created, cannot create another one');
            }
            if ( cse.Decision__c == null || ! cse.Decision__c.contains('Prejudiced Collection of Funds') ) {
                throw new WSSidraLite.SidraLiteException('SIDRA Lite can be created only for "Prejudiced Collection of Funds"');
            }
            if ( cse.Suspension_Date__c != null && cse.Suspension_Date__c > Date.today() ) {
                throw new WSSidraLite.SidraLiteException('You cannot create a SIDRA Lite for future suspension date');
            }

            Case newCase = new Case();
            newCase.RecordTypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE;
            newCase.Subject = 'SIDRA Lite – Prejudiced Collection of Funds';
            newCase.ParentId = cse.Id;
            newCase.AccountId = cse.AccountId;
            newCase.ContactId = cse.ContactId;
            newCase.Region__c = cse.Region__c;
            newCase.BSPCountry__c = cse.BSPCountry__c;
            newCase.SIDRA_Lite_Reason__c = 'Prejudiced Collection of Funds';
            newCase.BSP_CASS__c = SidraLiteUtil.getBSPCASS(cse.account);

            if (SidraLiteUtil.isAccountActive(cse.account)) {
                newCase.Reason_for_Default__c = 'Suspension - Prejudiced Collection of Funds';
                newCase.SIDRA_Lite_Default_Date__c = Date.Today();
                newCase.Confirmation_moneys_not_received__c = Date.today();
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
}
