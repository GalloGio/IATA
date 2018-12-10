/***************************************************************************
*
*
*
*
*
*
*****************************************************************************/
global class IFAP_WebService {

    @RemoteAction
    public static final String CASE_STATUS_R_PENDING_APPROVAL = 'Quality Issue Request Pending Approval';
    public static final String CASE_STATUS_REASSESS_REJECTED = 'Quality Issue Rejected';
    public static final String CASE_STATUS_REASSESS_REQUESTED = 'Quality Issue Requested';
    public static final String CASE_STATUS_REASSESS_REQUEST_APPROVED = 'Quality Issue Request Approved';
    public static final String CASE_STATUS_ASSESSMENT_PERFORMED = 'Assessment Performed';
    public static final String CASE_STATUS_SANITY_CHECK_FAILURE = 'Sanity Check Failure';
    public static final String CASE_STATUS_FINANCIAL_SECURITY_REQUSTED = 'Financial Security Requested';


    WebService static String FinancialSecurityInfo(String caseNumber, String currencyCode, Decimal amount) {

        String returnValue = '';

       try {
            List<Case> Cases = [SELECT ID, Financial_Security_Amount__c,
                                Financial_Security_Currency__c,caseNumber
                                FROM Case
                                WHERE caseNumber = : caseNumbeR];
            if (cases <> null && cases.size() > 0) {
                cases[0].Financial_Security_Amount__c = amount;
                cases[0].Financial_Security_Currency__c = currencyCode;
            }

            update cases;
            return returnValue;

       } catch (Exception e) {

            System.debug('Error in the update of the FinancialSecurityInfo: ' + e.getmessage());
            return e.getmessage() + e.getStackTraceString();
        }


    }


  




    WebService static boolean isPortalUser() {
        boolean isPortalUser = false;

        //Query to user object to get contact Id of current login user.
        User objUser = [Select Id, contactID, IsPortalEnabled, IsActive from User where Id = :userinfo.getuserid()];
        //check contact Id is not null.
        if (objUser.contactID != null && objUser.IsActive && objUser.IsPortalEnabled) {
            //if contact is not null,then current login user is partner user.Make isPartnerUser flag true.
            isPortalUser = true;
        }
        return isPortalUser;
    }

    WebService static String getCaseStatus(String caseNumber) {
        String caseStatus;

        //Query to user object to get contact Id of current login user.
        Case objCase = [Select Id, status, casenumber from Case where casenumber = : + caseNumber];
        //check contact Id is not null.
        if (objCase != null) {
            //if contact is not null,then current login user is partner user.Make isPartnerUser flag true.
            caseStatus = objCase.Status;
        }
        return caseStatus;
    }



    //RA: used for FA Letter sent mass update button
    webService static Boolean UpdateFALetterSent(List<Case> cases, String batch) {


        try {
            clsUpdateLetterSentBatch cBatch = new clsUpdateLetterSentBatch ();
            cBatch.caseList = cases;
            cBatch.isFALetterSent = true;
            cBatch.type = 'Update FA Letter Sent';
            cBatch.batchNum = batch;
            ID batchprocessid = Database.executeBatch(cBatch, 5);

            return true;
        }

        catch (Exception e) {
            system.debug('**** UpdateFALetterSent Error');
            return false;
        }


    }

    //RA: used for FS Letter sent mass update button
    webService static Boolean UpdateFSLetterSent(List<Case> cases, String batch) {

        try {

            clsUpdateLetterSentBatch cBatch = new clsUpdateLetterSentBatch ();
            cBatch.caseList = cases;
            cBatch.isFALetterSent = false;
            cBatch.type = 'Update FS Letter Sent';
            cBatch.batchNum = batch;
            ID batchprocessid = Database.executeBatch(cBatch, 5);

            return true;
        }

        catch (Exception e) {
            system.debug('**** UpdateFSLetterSent Error');
            return false;
        }
    }

    //returns user language
    webService static String getLocaleLang() {

        User[] users = [Select u.LanguageLocaleKey From User u where u.Id = : UserInfo.getUserId()];

        if (users != null && users.size() > 0)
            return users[0].LanguageLocaleKey.substring(0, 2);
        else
            return '';

    }

    WebService static String generateURLForNewCaseFromSAAM(String saamCaseId) {

        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

        String url = '/500/e?retURL=/' + saamCaseId + '&RecordType=' + IFAPcaseRecordTypeID;

        // find the SAAM case
        Case saamCase = [Select c.Id, c.CaseNumber, c.Account.Id from Case c where c.Id = :saamCaseId limit 1];
        if (saamCase == null) {
            return 'ERROR: The SAAM case with Id ' + saamCaseId + ' was not found.';
            //throw new IFAPException('The SAAM case with Id ' + saamCaseId + ' was not found.');
        }

        // find the IFAP contact associated to the Account
        List<Contact> ifapContact = [Select c.Id from Contact c where c.Account.Id = : saamCase.Account.Id and c.Financial_Assessment_Contact__c = true];
        if (ifapContact == null || ifapContact.size() == 0) {
            return 'ERROR: Account selected does not have an IATA Financial Assessment contact assigned.';
        }

        // check if there already was an IFAP case associated to the SAAM case
        List<Case> existingIFAPCases = [Select c.Id, c.Subject from Case c where c.ParentId = :saamCaseId and c.RecordTypeId = :IFAPcaseRecordTypeID];
        if (existingIFAPCases != null && existingIFAPCases.size() > 0) {
            return 'ERROR: The SAAM case already has an IFAP case related to it';
        }

        // set the parent case
        url += '&cas28=' + EncodingUtil.urlEncode(saamCase.CaseNumber, 'UTF-8');

        // set the account
        url += '&cas4_lkid=' + EncodingUtil.urlEncode(saamCase.Account.Id, 'UTF-8');

        // set the contact
        url += '&cas3_lkid=' + EncodingUtil.urlEncode(ifapContact[0].Id, 'UTF-8');

        return url;
    }




    webService static String CheckCaseStatus(String caseId) {
        String caseStatus;
        try {
            Case o = [select id, status from Case where id = :caseId];
            caseStatus = o.Status;

        } catch (Exception e) {
            system.debug('CheckCaseStatus- No case found (case id#' + caseId + ')');
        }

        return caseStatus;
    }

    public with sharing class IFAPException extends Exception {

    }

    @RemoteAction
    webService static string CallReassessmentApprovalProcess(String caseId, string QualityIssueID) {

        try {
            ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

            Case[] c = [Select c.Status, c.OwnerId From Case c where c.Id = :caseId and c.RecordTypeId = : IFAPcaseRecordTypeID limit 1];
            if (c.size() > 0 ) {
                string oldStatus = c[0].Status;    // Keep the old case status in case there is an issue with the approval process

                if (oldStatus == CASE_STATUS_ASSESSMENT_PERFORMED || oldStatus == CASE_STATUS_REASSESS_REJECTED || oldStatus == CASE_STATUS_SANITY_CHECK_FAILURE  || oldStatus == CASE_STATUS_FINANCIAL_SECURITY_REQUSTED ) {
                    IFAP_Quality_Issue__c[] issue = [SELECT Id, Related_Case__c, Wrong_figure_was_extracted__c FROM IFAP_Quality_Issue__c WHERE Id = : QualityIssueID];

                    if (issue.size() > 0) {
                        Approval.ProcessResult result;
                        // If the Wrong Figure was extracted field is checked, we must check if at least one Reassessment accounting issue is related to the current Quality issue
                        if (issue[0].Wrong_figure_was_extracted__c == true) {
                            if (!IFAP_BusinessRules.isReassessmentAccountingIssueLinked(issue[0])) {
                                // error message
                                return 'Failed,' + Label.IFAP_Accounting_Issue_required;
                            } else {
                                // set the case status to Reassessment Request Pending Approval (entry criteria for the approval process)
                                c[0].Status = CASE_STATUS_R_PENDING_APPROVAL ;
                                //c[0].IsComplaint__c = true;
                                Update c[0];

                                // Create an approval request for the Opportunity
                                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                                req1.setComments('Submitting the Quality issue for approval');
                                req1.setObjectId(c[0].id);

                                // Submit the approval request for the Opportunity
                                result = Approval.process(req1);
                            }
                        } else {
                            // set the case status to Reassessment Request Pending Approval (entry criteria for the approval process)
                            c[0].Status = CASE_STATUS_R_PENDING_APPROVAL ;
                            //c[0].IsComplaint__c = true;
                            Update c[0];

                            // Create an approval request for the Opportunity
                            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                            req1.setComments('Submitting the Quality issue for approval');
                            req1.setObjectId(c[0].id);

                            // Submit the approval request for the Opportunity
                            result = Approval.process(req1);
                        }

                        if (result.isSuccess()) {
                            issue[0].Status__c = 'Pending approval';
                            issue[0].QI_Raised_on__c = datetime.Now();
                            Update issue[0];
                            return 'OK,';
                        } else {
                            // in case of error Set back the case status what it was before
                            c[0].Status = oldStatus;
                            Update c[0];

                            return 'Failed, Approval Process error occured';
                        }
                    }
                } else {
                    return 'Failed,A quality issue can be submitted for approval only when the status of the related case is one of the following statuses: \n -Assessment Performed\n -Financial Security Requested\n -Quality Issue Rejected\n -Sanity Check Failure';
                }
            }
            return 'Failed, Approval Process error occured';
        } catch (Exception e) {
            System.debug('** Error ' + e.getMessage());
            return 'Failed, ' + e.getMessage();
        }
    }
}