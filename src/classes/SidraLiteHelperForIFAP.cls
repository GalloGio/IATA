/**
    Methods to process SIDRA Lite when parent Case is IFAP
**/
public with sharing class SidraLiteHelperForIFAP {

    public class SidraLiteException extends Exception {}

    public static final set<String> STATUS_FOR_FA = new set<String>{
        'Agent Notified (Mail)',
        'Agent Notified (Email)',
        'Financial Statements Uploaded',
        'Sanity Check Failure'};
    public static final set<String> STATUS_FOR_FS = new set<String>{
            'Financial Security Requested'};
    public static final set<String> STATUS_NOT_VALID = new set<String>{
        'Action Needed',
        'Agent to be Notified',
        'Agent to be notified (Email)',
        'Assessment Performed',
        'Financial Security Provided',
        'Re-open/ed',
        'Submitted',
        'Assessment Cancelled',
        'Closed'};

    /**
        Bussines Rules checked before inserting and updating SIDRA lite Cases
    **/
    public static void checkBussinessRules(Case parentCase) {
        // check parent status if FA letter sent
        if ( !parentCase.FA_Letter_Sent__c && STATUS_FOR_FA.contains(parentCase.Status) ){
            throw new SidraLiteException('The "FA Letter Sent" check box has not been ticked, kindly send the physical letter requesting the financial documents to the Agent before you proceed.');
        }
        // check parent status if FS letter sent
        if ( !parentCase.FS_Letter_Sent__c && STATUS_FOR_FS.contains(parentCase.Status) ){
            throw new SidraLiteException('The "FS Letter Sent" check box has not been ticked, kindly send the physical letter requesting the financial documents to the Agent before you proceed.');
        }
        // check parent status
        if ( STATUS_NOT_VALID.contains(parentCase.Status) ){
            throw new SidraLiteException('A SIDRA lite case cannot be created when the parent case status is ' + parentCase.Status);
        }
    }

    /**
        Create a dummy case to set the default values for first non compliance date
    **/
    public static Case createDummyCaseFirstNonCompliance(Case parentCase) {
        Case returnCase = new Case();
        returnCase.RecordTypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE;
        returnCase.ContactId = parentCase.ContactId;
        returnCase.AccountId = parentCase.AccountId;
        returnCase.ParentId = parentCase.Id;
        returnCase.Region__c = parentCase.Region__c;
        returnCase.BSPCountry__c = parentCase.Account_Billing_Country__c;
        returnCase.Origin = 'Internal Case';
        returnCase.Status= 'Open';
        returnCase.BSP_CASS__c = SidraLiteUtil.getBSPCASS(parentCase.account);
        // for FS
        if ( isFS(parentCase) ) {
            returnCase.Subject = 'SIDRA Lite - Financial Security Non-compliance';
            returnCase.SIDRA_Lite_Reason__c = 'Financial Security Non-compliance';
            if ( SidraLiteUtil.isPassenger(parentCase.account) ) {
                if (SidraLiteUtil.isAccountActive(parentCase.account)) {
                    returnCase.SIDRA_Lite_Default_Date__c = Date.today();
                    //returnCase.IRR_Approval_Rejection__c = 'Approved';
                    //returnCase.Propose_Irregularity__c = DateTime.now();
                    //returnCase.IRR_Approval_Rejection_Date__c = DateTime.now();
                    //returnCase.IRR_Type__c =  'Double Irregularity';
                    returnCase.Reason_for_Default__c =  'Suspension - FS Non Compliance';
                } else {
                    returnCase.IRR_Withdrawal_Reason__c  = 'Default Prev';
                }
            }
            if ( SidraLiteUtil.isCargoCASS(parentCase.account) ) {
                if (SidraLiteUtil.isAccountActive(parentCase.account)) {
                    returnCase.IRR_Withdrawal_Reason__c  = 'Cargo Reminder only';
                    returnCase.IRR_Approval_Rejection__c = '';
                    returnCase.IRR_Type__c = '';
                } else {
                    returnCase.IRR_Withdrawal_Reason__c  = 'Default Prev';
                }
            }
        }

        // for FA
        if ( !isFS(parentCase) || parentCase.Status == 'Sanity Check Failure') {
            if (parentCase.Status == 'Sanity Check Failure') {
                returnCase.SIDRA_Lite_Reason__c = 'Sanity Check failure of financial statement';
            } else {
                returnCase.SIDRA_Lite_Reason__c = 'Financial Review Non-compliance';
            }
            returnCase.Subject = 'SIDRA Lite - ' + returnCase.SIDRA_Lite_Reason__c;
            if ( SidraLiteUtil.isPassenger(parentCase.account) ) {
                if (SidraLiteUtil.isAccountActive(parentCase.account)) {
                    returnCase.IRR_Approval_Rejection__c = 'Approved';
                    returnCase.Propose_Irregularity__c = DateTime.now();
                    returnCase.IRR_Approval_Rejection_Date__c = DateTime.now();
                    returnCase.IRR_Type__c =  'Double Irregularity';
                    returnCase.IRR_Withdrawal_Reason__c = '';
                } else {
                    returnCase.IRR_approval_Rejection__c = '';
                    returnCase.IRR_Type__c =  '';
                    returnCase.IRR_Withdrawal_Reason__c = 'Default Prev';
                }
            }
            if ( SidraLiteUtil.isCargoCASS(parentCase.account) ) {
                returnCase.IRR_approval_Rejection__c = '';
                returnCase.IRR_Type__c = '';
                if (SidraLiteUtil.isAccountActive(parentCase.account)) {
                    returnCase.IRR_Withdrawal_Reason__c  = 'Cargo Reminder only';
                } else {
                    returnCase.IRR_Withdrawal_Reason__c  = 'Default Prev';
                }
            }
        }
        returnCase.Termination_date_manual_entry__c = WSSidraLite.getTerminationDateFromRelatedCase(parentCase.account);

        return returnCase;
    }

    /**
        Check conditions to show an alert message to user to confirm if second or third non compliance must be processed
    **/
    public static void throwPopUpMessage(Case parentCase) {
        if (isFS(parentCase)) {
            if (parentCase.FS_third_non_compliance_date__c != null) {
                throw new WSSidraLite.ShowConfirmationException('Process third non-compliance date, continue?');
            } else {
                throw new WSSidraLite.ShowConfirmationException('Process second non-compliance date, continue?');
            }
        } else {
            if (parentCase.Third_FA_non_Compliance_Date__c != null) {
                throw new WSSidraLite.ShowConfirmationException('Process third non-compliance date, continue?');
            } else {
                throw new WSSidraLite.ShowConfirmationException('Process second non-compliance date, continue?');
            }
        }
    }

    /**
        Update Ifap case and Sidra lite child case to FA/FS second or third deadline date
        Any other situation will retrieve an error message
        Return a case list with both cases, ready to update them
    **/
    public static list<Case> updateSidraLiteAndParent(Case parentCase, Case childCase) {
        Account account = parentCase.account;

        // ACTIONS for FS
        if (isFS(parentCase)) {
            // First non-compliance, must be filled
            if (parentCase.firstFSnonComplianceDate__c == null ) {
                throw new SidraLiteException('Cannot update a 1st FS non-compliance case. The 1st FS Non-Compliance Date is empty');
            }
            // Second non-compliance, allowed
            else if(parentCase.secondFSnonComplianceDate__c==null) {
                if (parentCase.FS_Second_Deadline_Date__c == null) {
                    throw new SidraLiteException('Cannot proceed with the 2nd non-compliance in the SIDRA lite case if the 2nd deadline date is empty');
                }
                if (parentCase.FS_Second_Deadline_Date__c >= Date.today()) {
                    throw new SidraLiteException('Cannot proceed with the 2nd FS non-compliance. The 2nd FS Deadline is ' + parentCase.FS_Second_Deadline_Date__c.format());
                }
                parentCase.secondFSnonComplianceDate__c = Date.today();
                parentCase.FS_Third_Deadline_Date__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
                Boolean isLastSidraCase = SidraLiteUtil.isLastSidraCase(childCase);
                if (SidraLiteUtil.isPAssenger(account) && (SidraLiteUtil.isAccountActive(account) || isLastSidraCase)) {
                    childCase.NOT_Date__c = Date.today();
                }
                if (SidraLiteUtil.isCargoCASS(account) && (SidraLiteUtil.isAccountActive(account) || isLastSidraCase)) {
                    parentCase.SIDRA_Lite_Default_Date__c = Date.today();
                }
                //update child
                childCase.SIDRA_Lite_Default_Date__c = Date.today();
                childCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
                childCase.Status = 'Re-opened';
            }
            // Third non-compliance, allowed
            else if(parentCase.FS_third_non_compliance_date__c==null) {
                 if (parentCase.FS_Third_Deadline_Date__c == null) {
                     throw new SidraLiteException('Cannot proceed with a 3rd FS non-compliance case. The 3rd FS Deadline is empty');
                 }
                 if (parentCase.FS_Third_Deadline_Date__c >= Date.today()) {
                     throw new SidraLiteException('Cannot proceed with a 3rd FS non-compliance case. The 3rd FS Deadline is ' + parentCase.FS_Third_Deadline_Date__c.format());
                 }
                 parentCase.FS_third_non_compliance_date__c = Date.today();
                 //update child
                 childCase.Propose_Default__c = DateTime.now();
                 childCase.Status = 'Re-opened';
            }
            // Fourth non-compliance, not allowed
            else {
                throw new SidraLiteException('Cannot proceed with a 4th FS non-compliance case.');
            }
        }

        // ACTIONS for FA
        else {
            // First non-compliance, must be filled
            if (parentCase.firstFAnonComplianceDate__c == null ) {
                throw new SidraLiteException('Cannot update a 1st FA non-compliance case. The 1st FA Non-Compliance-Date is empty');
            }
            // Second non-compliance, allowed
            else if(parentCase.secondFAnonComplianceDate__c==null) {
                if (parentCase.FA_Second_Deadline_Date__c == null) {
                    throw new SidraLiteException('Cannot proceed with the 2nd non-compliance in the SIDRA lite case if the 2nd deadline date is empty');
                }
                if (parentCase.FA_Second_Deadline_Date__c >= Date.today()) {
                    throw new SidraLiteException('Cannot udpate a 2nd FA non-compliance case. The 2nd FA Deadline is ' + parentCase.FA_Second_Deadline_Date__c.format());
                }
                parentCase.secondFAnonComplianceDate__c = Date.today();
                parentCase.FA_Third_Deadline_Date__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
                if (SidraLiteUtil.isAccountActive(account) || SidraLiteUtil.isLastSidraCase(childCase) ) {
                    childCase.SIDRA_Lite_Default_Date__c = Date.today();
                }
                //update child
                childCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
                childCase.Reason_for_Default__c  = 'Suspension - FA Non Compliance';
                childCase.Status = 'Re-opened';
            }
            // Third non-compliance, allowed
            else if (parentCase.Third_FA_non_Compliance_Date__c == null ) {
                if (parentCase.FA_Third_Deadline_Date__c== null) {
                    throw new SidraLiteException('Cannot update a 3rd FA non-compliance case. The 3rd FA Deadline is empty');
                }
                if (parentCase.FA_Third_Deadline_Date__c >= Date.today()) {
                    throw new SidraLiteException('Cannot update a 3rd FA non-compliance case. The 3rd FA Deadline is ' + parentCase.FA_Third_Deadline_Date__c.format());
                }
                parentCase.Third_FA_non_Compliance_Date__c = Date.today();
                //update child
                childCase.Propose_Default__c = DateTime.now();
                childCase.Status = 'Re-opened';
            }
            // Fourth non-compliance, not allowed
            else {
                throw new SidraLiteException('Cannot update a 4th FA non-compliance case.');
            }
        }
        childCase.Total_Irregularities__c = String.ValueOf(parentCase.account.Accumulated_Irregularities__c);

        list<Case> listUpdate = new list<Case>();
        listUpdate.add(childCase);
        listUpdate.add(parentCase);
        return listUpdate;
    }

    /**
        Return true if input case is FS, if false then is FA
    **/
    public static Boolean isFS(Case cse) {
        return STATUS_FOR_FS.contains(cse.Status);
    }
}
