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

    @TestVisible private static final String INVALID_ACTION_TRIGGER_SIDRA_LITE = 'Invalid action, you need to trigger SIDRA Lite action in order to put the agent Under review.';
    @TestVisible private static final String INVALID_ACTION_REINSTATE_AGENT = 'Invalid action, you need to reinstate the agent from the SIDRA lite related case.';
    @TestVisible private static final String INVALID_ACTION_REMOVE_CASH_CONDITIONS = 'Invalid action, you need to remove Cash conditions using the appropriate button.';
    @TestVisible private static final String INVALID_ACTION_CONDITIONS_NOT_SATISFIED_APPLY = 'Conditions are not satisfied to apply Cash Condition on the agent.';
    @TestVisible private static final String CASH_CONDITION_SUCCESSFULLY_APPLIED = 'Second non-compliance was successfully applied.';
    @TestVisible private static final String UNABLE_TO_APPLY_CASH_CONDITION = 'Unable to apply cash condition on the agent.';
    @TestVisible private static final String CASH_CONDITION_SUCCESSFULLY_REMOVED = 'Agent reinstated successfully after second non-compliance.';
    @TestVisible private static final String UNABLE_TO_REMOVE_CASH_CONDITION = 'Unable to remove cash condition from the agent.';
    @TestVisible private static final String INVALID_ACTION_CONDITIONS_NOT_SATISFIED_REMOVE = 'Conditions are not satisfied to remove Cash Condition from the agent.';
    @TestVisible private static final String AGENT_DOES_NOT_HAVE_CASH_CONDITION = 'Agent does not have cash condition.';

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

    WebService static String generateURLForNewCaseFromSAAM(String caseId) {

        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        ID CNScaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CNS_Collection_Process');

        String url = '/500/e?retURL=/' + caseId + '&RecordType=' + IFAPcaseRecordTypeID;

        // find the case
        Case cse = [Select Id, CaseNumber, Account.Id, RecordTypeId, BusinessHoursId from Case where Id = :caseId limit 1];
        if (cse == null) {
            return 'ERROR: The case with Id ' + caseId + ' was not found.';
        }

        // find the IFAP contact associated to the Account
        List<Contact> ifapContact = [Select c.Id from Contact c where c.Account.Id = : cse.Account.Id and c.Financial_Assessment_Contact__c = true];
        if (ifapContact == null || ifapContact.size() == 0) {
            return 'ERROR: Account selected does not have an IATA Financial Assessment contact assigned.';
        }

        // check if there already was an IFAP case associated to the SAAM case
        List<Case> existingIFAPCases = [Select c.Id, c.Subject from Case c where c.ParentId = :caseId and c.RecordTypeId = :IFAPcaseRecordTypeID];
        if (existingIFAPCases != null && existingIFAPCases.size() > 0) {
            return 'ERROR: This case already has an IFAP case related to it.';
        }

        // set the parent case
        url += '&cas28=' + EncodingUtil.urlEncode(cse.CaseNumber, 'UTF-8');

        // set the account
        url += '&cas4_lkid=' + EncodingUtil.urlEncode(cse.Account.Id, 'UTF-8');

        // set the contact
        url += '&cas3_lkid=' + EncodingUtil.urlEncode(ifapContact[0].Id, 'UTF-8');

        //ACAMBAS - WMO-484: Begin
        if(cse.RecordTypeId == CNScaseRecordTypeID) {
            // set the finantial review type
            url += '&00N20000003JdqT=' + EncodingUtil.urlEncode('CNS Collection Process', 'UTF-8');

            // set the FA Deadline Date
            Date deadlineDate = BusinessHours.nextStartDate(cse.BusinessHoursId, Date.today().addDays(30)).date();
            String deadlineDateStr = deadlineDate.month() + '/' + deadlineDate.day() + '/' + deadlineDate.year();
            url += '&00N20000001G2Tq=' + EncodingUtil.urlEncode(deadlineDateStr, 'UTF-8');

            // set CNS Case flag
            url += '&00Nw00000094hq4=1';      
        }
        //ACAMBAS - WMO-484: End
        
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

    private static Account fetchAccountInformation(Id caseId, Id accountId){

			Account acct =
				[SELECT 
					Id,
					ANG_IsNewgenAgency__c,
                    ANG_HE_CashCondition__c,
                    (SELECT
                        Id,
                        ANG_Limit_Cash_Conditions__c
                     FROM
                        Location_Risk_Events__r
                     WHERE
                        ANG_Risk_Type__r.Name = 'Fail Financial Statements'
                     AND
                        ANG_Event_Status__c IN ('Active', 'Inactive_Revoked')
                     ORDER BY LastModifiedDate DESC
                     LIMIT 1
                    ),
                    (SELECT
						Id,
						Status,
                        Deadline_Date__c,
						FA_Second_Deadline_Date__c,
						Financial_Review_Result__c,
						Assessment_Performed_Date__c
					FROM 
						Cases 
					WHERE 
						Id = :caseId
					),
					(SELECT 
						Id, 
						Security_Status__c 
					FROM 
						Financial_Securities__r
					)
				FROM 
					Account 
				WHERE 
					Id = :accountId
				LIMIT 1
				];

        return acct;

    }

    private static Boolean hasAgentFinancialSecurity(List<Financial_Security__c> fsLst){

        Set<String> fsStatusSet = new Set<String>{
			ANG_Risk_Helper.SECURITY_STATUS_ACTIVE, 
			ANG_Risk_Helper.SECURITY_STATUS_CLOSE_EXPIRY_DATE
		};

		for(Financial_Security__c fs : fsLst){
			if(fsStatusSet.contains(fs.Security_Status__c)){
				return true;
			}
		}

        return false;

    }

	webservice static String applyCashCondition(Id caseId, Id accountId){

		try {

			Account acct = fetchAccountInformation(caseId, accountId);

			Case cse = acct.Cases.get(0);
            
			String message = isValidForApplyingCashCondition(acct, cse, hasAgentFinancialSecurity(acct.Financial_Securities__r));

			if('VALID' != message){
				return message;
			}

            ANG_Agency_Risk_Event__c riskEvent = acct.Location_Risk_Events__r.get(0);

			message = applyCashConditionAction(riskEvent, cse);

			if(message != 'SUCCESS'){
				return UNABLE_TO_APPLY_CASH_CONDITION + '\n\n' + AMS_Utils.beautifyErrorMessage(message) + '.';
			}

			return CASH_CONDITION_SUCCESSFULLY_APPLIED;

		}
		catch(Exception e){
			system.debug(LoggingLevel.ERROR, e.getStackTraceString());
			system.debug(LoggingLevel.ERROR, e.getMessage());
			return UNABLE_TO_APPLY_CASH_CONDITION + '\n\n' + AMS_Utils.beautifyErrorMessage(e.getMessage()) + '.';
		}

	}

	private static String applyCashConditionAction(ANG_Agency_Risk_Event__c riskEvent, Case cse){

		Savepoint sp = Database.setSavePoint();

		try {
			riskEvent.ANG_Limit_Cash_Conditions__c = true;
			update riskEvent;

			cse.secondFAnonComplianceDate__c = System.today();
			cse.FA_Third_Deadline_Date__c    = cse.Deadline_Date__c.addDays(365);
			update cse;
		}
		catch(Exception e){
			system.debug(LoggingLevel.ERROR, e.getStackTraceString());
			system.debug(LoggingLevel.ERROR, e.getMessage());
			Database.rollback(sp);
			return e.getMessage();
		}

		return 'SUCCESS';

	}

	private static String isValidForApplyingCashCondition(Account acct, Case cse, Boolean hasAgentFS){

		Set<String> caseStatusSet = new Set<String>{
			'Agent Notified (Email)',
			'Agent Notified (Mail)',
			'Sanity Check Failure'
		};

		if(acct.ANG_IsNewgenAgency__c && cse.FA_Second_Deadline_Date__c < System.Today() && caseStatusSet.contains(cse.Status) && !hasAgentFS){
			return INVALID_ACTION_TRIGGER_SIDRA_LITE;
		}

		if(acct.ANG_IsNewgenAgency__c && String.isNotBlank(cse.Financial_Review_Result__c) && cse.Assessment_Performed_Date__c > cse.FA_Second_Deadline_Date__c && !hasAgentFS){
			return INVALID_ACTION_REINSTATE_AGENT;
		}

		if(acct.ANG_IsNewgenAgency__c && String.isNotBlank(cse.Financial_Review_Result__c) && cse.Assessment_Performed_Date__c > cse.FA_Second_Deadline_Date__c && hasAgentFS){
			return INVALID_ACTION_REMOVE_CASH_CONDITIONS;
		}

		if(!acct.ANG_IsNewgenAgency__c || cse.FA_Second_Deadline_Date__c >= System.Today() || !caseStatusSet.contains(cse.Status) || !hasAgentFS){
			return INVALID_ACTION_CONDITIONS_NOT_SATISFIED_APPLY;
		}

		return 'VALID';

	}

    webservice static String removeCashCondition(Id caseId, Id accountId){

        Account acct = fetchAccountInformation(caseId, accountId);

        Case cse = acct.Cases.get(0);

        String message = isValidForRemovingCashCondition(acct, cse, hasAgentFinancialSecurity(acct.Financial_Securities__r));

        if('VALID' != message){
            return message;
        }

		ANG_Agency_Risk_Event__c riskEvent = acct.Location_Risk_Events__r.get(0);

        message = removeCashConditionAction(riskEvent);

        if(message != 'SUCCESS'){
            return UNABLE_TO_REMOVE_CASH_CONDITION + '\n\n' + AMS_Utils.beautifyErrorMessage(message) + '.';
        }

        return CASH_CONDITION_SUCCESSFULLY_REMOVED;

    }

	private static String isValidForRemovingCashCondition(Account acct, Case cse, Boolean hasAgentFS){

		if(acct.ANG_IsNewgenAgency__c && String.isNotBlank(cse.Financial_Review_Result__c) && cse.Assessment_Performed_Date__c > cse.FA_Second_Deadline_Date__c && !hasAgentFS){
			return INVALID_ACTION_REINSTATE_AGENT;
		}

		if(!acct.ANG_IsNewgenAgency__c || cse.Assessment_Performed_Date__c <= cse.FA_Second_Deadline_Date__c || String.isBlank(cse.Financial_Review_Result__c)){
			return INVALID_ACTION_CONDITIONS_NOT_SATISFIED_REMOVE;
		}

        if(!acct.ANG_HE_CashCondition__c){
            return AGENT_DOES_NOT_HAVE_CASH_CONDITION;
        }

		return 'VALID';

    }

    private static String removeCashConditionAction(ANG_Agency_Risk_Event__c riskEvent){

		try {
			riskEvent.ANG_Limit_Cash_Conditions__c = false;
			update riskEvent;
		}
		catch(Exception e){
			system.debug(LoggingLevel.ERROR, e.getStackTraceString());
			system.debug(LoggingLevel.ERROR, e.getMessage());
			return e.getMessage();
		}

		return 'SUCCESS';

    }

}
