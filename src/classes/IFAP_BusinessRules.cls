/**
 * Class that encapsulate business logic for the IFAP project.
 * Created by Alexandre McGraw on 2012-01-09
 */
public with sharing class IFAP_BusinessRules {

    //**POSSIBLE IFAP STATUS**//
    private static final string ACTION_NEEDED = 'Action Needed';
    private static final string AGENT_NOTIFIED_EMAIL = 'Agent Notified (Email)';
    private static final string AGENT_NOTIFIED_TRACKED_EMAIL = 'Agent Notified (Tracked Email)';
    private static final string AGENT_NOTIFIED_MAIL = 'Agent Notified (Mail)';
    private static final string AGENT_TO_BE_NOTIFIED = 'Agent to be Notified';
    private static final string ASSESSMENT_CANCELLED = 'Assessment Cancelled';
    private static final string ASSESSMENT_PERFORMED = 'Assessment Performed';
    private static final string CLOSED = 'Closed';
    private static final string FS_PROVIDED = 'Financial Security Provided';
    private static final string FS_REJECTED = 'Financial Security Rejected';
    private static final string FS_REQUESTED = 'Financial Security Requested';
    private static final string FINANCIAL_STATEMENTS_UPLOADED = 'Financial Statements Uploaded';
    private static final string QI_REJECTED = 'Quality Issue Rejected';
    private static final string QI_REQUEST_APPROVED = 'Quality Issue Request Approved';
    private static final string QI_REQUESTED = 'Quality Issue Requested';
    private static final string QI_REQUEST_PENDING_APPROVAL = 'Quality Issue Request Pending Approval';
    private static final string REOPENED = 'Re-open/ed';
    private static final string SCF = 'Sanity Check Failure';
    private static final string SUBMITTED = 'Submitted';
    private static final string CLOSEDOPTOUT = 'Closed Opt-out';


    /**
     * Validates the country of a Case's Account
     */
    public static boolean isCountryValid(Case theCase, map<id, Account> accountMap) {


        boolean isValid = false;

        // try to find the country base on the Billing country
        try {

            IATA_ISO_Country__c[] associatedCountry = IATAIsoCountryDAO.getIsoCountryByCountriesName(new Set<String>{accountMap.get(theCase.id).BillingCountry});

            // the country is valid if the country was found
            system.debug('\nassociatedCountry.size():' + associatedCountry.size());
            isValid = (associatedCountry != null && associatedCountry.size() > 0);
        } catch (Exception ex) {

        }


        System.debug('** Is country valid ' + isValid);
        return isValid;
    }

    /**
     * Validates the Agent Type of a Case's Contact
     */
    public static boolean isAgentTypeValid(Case theCase, map<id, Contact> contactMap) {

        boolean isValid = false;

        try {
            // the Agent Type is valid if it equals one of the two below values
            /*isValid = (contactMap.get(theCase.id).Agent_Type__c != null
                        && (contactMap.get(theCase.id).Agent_Type__c == 'IATA Cargo Agent' ||  contactMap.get(theCase.id).Agent_Type__c == 'IATA Passenger Sales Agent' || contactMap.get(theCase.id).Agent_Type__c == 'CASS Associate' ||  contactMap.get(theCase.id).Agent_Type__c == 'Domestic Agent'));*/
            isValid = (theCase.IFAP_Agent_Type__c != null
                       && (theCase.IFAP_Agent_Type__c == 'IATA Cargo Agent' ||  theCase.IFAP_Agent_Type__c == 'IATA Passenger Sales Agent' || theCase.IFAP_Agent_Type__c == 'CASS Associate' || theCase.IFAP_Agent_Type__c == 'Import Agent'));






        } catch (Exception ex) {

        }
        System.debug('** Agent Type ' + theCase.IFAP_Agent_Type__c);
        System.debug('** Is agent type valid ' + isValid);
        return isValid;
    }

    /**
     * Validates the Agent Code of a Contact
     */
    public static boolean isAgentCodeValid(Case theCase, map<Id, Account> accountMap) {

        boolean isValid = false;
                System.debug('theCase.id=' +theCase.id);
                System.debug('accountMap.get(theCase.id)=' +accountMap.get(theCase.id));

        try {
            if (accountMap.get(theCase.id).IATACode__c != null) {

                isValid = (accountMap.get(theCase.id).IATACode__c.length() >= 7 && accountMap.get(theCase.id).IATACode__c.length() <= 11);
                //INC249798
                //Pattern valid_characters = Pattern.compile('([0-9]+)'); //only numbers
                //Matcher check_chars = valid_characters.matcher(accountMap.get(theCase.id).IATACode__c);





                //isValid &= check_chars.matches();
            }
        } catch (Exception ex) {





        }

        return isValid;
    }

    /**
     * Set the IATA Area (1, 2 or 3) and Country ISO code on the Case (fields IFAP_Area__c and IFAP_Country_ISO__c)
     */
    public static void setCountryAreaAndISOCode(Case theCase, map<Id, Account> accountMap)  {

        // get contact and account associated to the Case
        //Contact con = [Select Id, AccountId from Contact where Id =: theCase.ContactId limit 1];
        //Account acc = [Select Id, BillingCountry, Type from Account where Id =: con.AccountId limit 1];
        IATA_ISO_Country__c country ;
        try {

            country = IATAIsoCountryDAO.getIsoCountryByCountriesName(new Set<String>{accountMap.get(theCase.id).BillingCountry})[0];

        } catch (Exception e) {
            theCase.IFAP_Area__c.addError('The account\'s country is not a valid IATA_ISO_Country: ' + accountMap.get(theCase.id).BillingCountry);
            return;
        }

        // Email Template


        theCase.IFAP_Area__c = 'Area ' + country.AIMS_Area_ID__c;
        theCase.IFAP_Country_ISO__c = country.ISO_Code__c;

        //adding region for case used in RPM approval flow todetermine which user the approval is sent to
        theCase.Region__c = country.Region__c;

    }


    /**
     * Creates a Case object, for each given contact, built with the provided information
     */
    //@future
    public static void massCreateCase(List<String> listContactId,
                                      Id batchNumberId, string status, string subject,
                                      string description, string reviewType, date deadlineDate,
                                      String templateLang, String financialYear, String financialMonth,
                                      String emailTemplateName, String agentsWithOpenCasesReportURL,
                                      boolean IFAP_CanCreateWhileClosedCase) {


        List<String> errors = new List<String>();
        List<String> success = new List<String>();
        List<Case> cList = new List<Case>();

        // get the IFAP case recordtype (we get it from the singleton class)
        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

        BatchNumber__c batch = [Select Id, Name from BatchNumber__c where Id = : batchNumberId];
        Group g = [Select id, name from Group where type = 'Queue' and name = 'Cases - Agent Financial Review'];

        Map<id, Contact> contacts = new Map<id, Contact>();
        for (Contact aContact : [Select Id, Email, Account.BillingCountry, Account.Type, AccountId from Contact where Id IN : listContactId]) {
            contacts.put(aContact.id, acontact);
        }

        for (String contactId : listContactId) {

            Case aCase = new Case();
            List<EmailTemplate__c> et = new List<EmailTemplate__c>();
            List<EmailTemplate__c> etReminder = new List<EmailTemplate__c>();

            try {
                //Contact c = [Select Id, Email, Account.BillingCountry, Account.Type, accountId from Contact where Id =: contactId limit 1];
                //Email template Details



                aCase.ContactId = contactId;
                aCase.AccountId = contacts.get(contactId).AccountId;
                aCase.RecordTypeId = IFAPcaseRecordTypeID;
                aCase.Origin = 'Agent Financial Review Notification';
                aCase.BatchNumber__c = batchNumberId;
                if ( status == AGENT_NOTIFIED_EMAIL){
                    aCase.Mass_Case_Creation_Email_Send__c = true;
                    aCase.FA_Letter_Sent__c = true;
                    aCase.Status = status;
                }
                else if ( status == AGENT_NOTIFIED_TRACKED_EMAIL){
                    aCase.Status = AGENT_TO_BE_NOTIFIED;
                }
                else{
                    aCase.Status = status;
                }
                aCase.Subject = subject;
                aCase.Description = description;
                aCase.Financial_Review_Type__c = reviewType;

                aCase.Deadline_Date__c = deadlineDate;

                aCase.EmailTemplate__c = templateLang;

                aCase.IFAP_Financial_Year__c = financialYear;
                aCase.IFAP_Financial_Month__c = financialMonth;
                aCase.OwnerId = g.Id;
                acase.IFAP_CanCreateWhileClosedCase__c = IFAP_CanCreateWhileClosedCase;

                cList.add(aCase);



                success.add('case number ' + aCase.CaseNumber + ' for contact ' + contacts.get(contactId).Email + ' (Id ' + contactId + ')');
                //success.add(aCase.CaseNumber + ',' + c.Email + ',' + contactId + ',' + et[0].Name);
            } catch (Exception ex) {
                errors.add('case for contact Id ' + contactId + '. Error message: ' + ex.getMessage());
                //errors.add(contactId + '&' + ex.getMessage());
            }


        }

        //Case Batch Processing
        clsMassCaseCreationBatch cBatch = new clsMassCaseCreationBatch();
        cBatch.caseList = cList;
        cBatch.caseContact = listContactId;
        cBatch.nCases = cList.size();
        cBatch.batchName = batch.Name;
        cBatch.status = status;
        cBatch.subject = subject;
        cBatch.description = description;
        cBatch.reviewType = reviewType;
        cBatch.deadlineDate = deadlineDate;
        cBatch.templateNameOverride = emailTemplateName;
        cBatch.agentsWithOpenCasesReportURL = agentsWithOpenCasesReportURL;

        ID batchprocessid = Database.executeBatch(cBatch, 5);
        
        System.debug('created cases : ' + cBatch.caseList);
    }

    public static Boolean CheckFinancialAssessmentContactExist(Contact theContact) {

        // Check for the record type, the agent type (P/C) and for the financial assessment contact boolean field
        //        //(theContact.RecordTypeId == ContactRecordType.Id || theContact.RecordTypeId == ContactRecordTypeStandard.Id ) &&
        if (
            theContact.Financial_Assessment_Contact__c == true &&
            (theContact.Agent_Type__c == 'IATA Passenger Sales Agent' || theContact.Agent_Type__c == 'IATA Cargo Agent' || theContact.Agent_Type__c == 'CASS Associate')) {

            List<Contact> AccountContacts = [Select Id, Financial_Assessment_Contact__c, AccountId From Contact 
                                            Where AccountId = : theContact.AccountId 
                                            And Id <>: theContact.Id AND Financial_Assessment_Contact__c = true];

            if (AccountContacts.size() > 0) {
                return true;
            }
        }
        return false;
    }

    public static Boolean IsStatusCanBeSelected(Boolean isOnCaseCreation, Case UpdatedCase, Case OldCase, Profile currentUserProfile, Boolean isAuthorizedUser) {

        String caseStatus = UpdatedCase.Status;

        //System Administrator: Has permission to change to any status.
        if (currentUserProfile.Name.toLowerCase().contains('system administrator')) {
            system.debug('*** ADMIN BYPASS ***');
            return true;
        }

        //Portal users can only change the case status using the button Confirm Submission of Documents to IATA.
        //Status change coming from these users should always be allowed.
        if (currentUserProfile.Name == 'ISS Portal Agency Delegated Admin User' || currentUserProfile.Name == 'ISS Portal Agency User (Partner)'  ) {
            return true;
        }

        if (isOnCaseCreation) {

            //initial status of the case must be one of the following
            if (caseStatus == AGENT_NOTIFIED_EMAIL || caseStatus == AGENT_NOTIFIED_MAIL || caseStatus == AGENT_TO_BE_NOTIFIED) {
                system.debug('** checking initial case status for agent notified email/mail or agent to be notified ');
                return true;
            }

        } else {

            String userIdsAllowedToBypass = UtilityCS__c.getInstance('IFAP Bypass Rules').value__c;

            if (userIdsAllowedToBypass != null) {
                Set<String> aux = new Set<String>(userIdsAllowedToBypass.split(',', 0));
                if (aux.contains(UserInfo.getUserId()))
                    return true;
            }

            String oldCaseStatus = OldCase.Status;
            //from status Action Needed the status can always be changed to the previous status
            if (oldCaseStatus == ACTION_NEEDED && caseStatus != FINANCIAL_STATEMENTS_UPLOADED) {
                // get case history
                List <CaseHistory> caseH = [SELECT Id, CaseId, Field, CreatedById, CreatedDate, IsDeleted, NewValue, OldValue FROM CaseHistory where caseid = : UpdatedCase.ID  and field = 'Status' order by CreatedDate desc];

                // we only let the user select the previous status
                if (caseH.Size() > 0 && caseH[0].OldValue == caseStatus)
                    return true;

            }

            if (caseStatus == CLOSEDOPTOUT)
                    return true;

            if (caseStatus == AGENT_NOTIFIED_EMAIL)
                if (oldCaseStatus == ACTION_NEEDED || oldCaseStatus == AGENT_NOTIFIED_MAIL || oldCaseStatus == AGENT_TO_BE_NOTIFIED || oldCaseStatus == FINANCIAL_STATEMENTS_UPLOADED)
                    return true;

            if (caseStatus == AGENT_NOTIFIED_MAIL)
                if (oldCaseStatus == ACTION_NEEDED || oldCaseStatus == AGENT_NOTIFIED_EMAIL || oldCaseStatus == AGENT_TO_BE_NOTIFIED || oldCaseStatus == FINANCIAL_STATEMENTS_UPLOADED)
                    return true;

            if (caseStatus ==  AGENT_TO_BE_NOTIFIED)
                if (oldCaseStatus == ACTION_NEEDED)
                    return true;

            if (caseStatus == ASSESSMENT_PERFORMED) {
                if (oldCaseStatus == QI_REJECTED)
                    return true;

                //special situation only for authorized users
                if (isAuthorizedUser && (oldCaseStatus == REOPENED || oldCaseStatus == CLOSED))
                    return true;

            }

            if (caseStatus == CLOSED)
                //changing status to Closed is handled in the existing validation rule
                return false;

            if (caseStatus == FS_PROVIDED)
                if (oldCaseStatus == ACTION_NEEDED || oldCaseStatus == FS_REJECTED || oldCaseStatus == FS_REQUESTED || oldCaseStatus == QI_REJECTED)
                    return true;

            if (caseStatus == FS_REJECTED)
                if (oldCaseStatus == FS_REQUESTED)
                    return true;

            if (caseStatus == FS_REQUESTED) {
                if (oldCaseStatus == ASSESSMENT_PERFORMED || oldCaseStatus == FS_REJECTED || oldCaseStatus == QI_REJECTED || oldCaseStatus == QI_REQUEST_APPROVED || oldCaseStatus == QI_REQUESTED || oldCaseStatus == ACTION_NEEDED)
                    if (UpdatedCase.Financial_Review_Result__c != null && Pattern.matches('Satisfactory - New Financial Security|Satisfactory - Update Financial Security|Unsatisfactory - New Financial Security|Unsatisfactory - Update Financial Security', UpdatedCase.Financial_Review_Result__c)
                            && UpdatedCase.Financial_Security_Amount__c != null && UpdatedCase.Financial_Security_Currency__c != null  && UpdatedCase.FS_Letter_Sent__c == true)
                        return true;
            }

            if (caseStatus == QI_REQUEST_PENDING_APPROVAL)
                if (oldCaseStatus == ASSESSMENT_PERFORMED || oldCaseStatus == FS_REQUESTED || oldCaseStatus == SCF || oldCaseStatus == QI_REJECTED)
                    return true;

            if (caseStatus == SCF)
                if (oldCaseStatus == QI_REJECTED || oldCaseStatus == FINANCIAL_STATEMENTS_UPLOADED)
                    return true;

            if(caseStatus == QI_REQUEST_APPROVED || caseStatus == QI_REJECTED){ //TD - INC276565
                if(oldCaseStatus == QI_REQUEST_PENDING_APPROVAL){
                    return true;
                }
            }
        }
        /*// default value is false ...*/
        System.debug('** Default Response -- This status change is not valid! **');
        return false;
    }


    public static Boolean isTemplateCountryValid(EmailTemplate__c emailTemplate, string caseCountryISO) {

        if (emailTemplate == null)
            return true;

        /*// retreive template's ISO country*/
        IATA_ISO_Country__c[] templateCountry = IATAIsoCountryDAO.getIsoCountriesByIds(new Set<ID>{emailTemplate.IATA_ISO_Country__r.Id});

        if (templateCountry.size() == 0)
            return false;

        /*// check if the country of the template matches the country of the case*/
        return caseCountryISO.equalsIgnoreCase(templateCountry[0].ISO_Code__c);
    }

    public static Boolean AccountCountryHasChanged(Case oldCase, Case newCase) {

        /*// get account associated to the old and new Case*/
        Account oldAcc = [Select Id, BillingCountry, Type from Account where Id = : oldCase.AccountId limit 1];
        Account newAcc = [Select Id, BillingCountry, Type from Account where Id = : newCase.AccountId limit 1];

        return (oldAcc.BillingCountry != newAcc.BillingCountry);
        /*//return (oldCase.Account.BillingCountry != newCase.Account.BillingCountry);*/
    }

    /*// ** replaces validation rule: IFAP_FS_validation_check_box*/
    public static Boolean FSValidationCheckBox(Case UpdatedCase, Case OldCase, Profile currentUserProfile) {

        /*//base case*/
        if (UpdatedCase.Agent_Name_chkbx__c == false && UpdatedCase.Financial_Security_Amount_chkbx__c == false && UpdatedCase.Financial_Security_Currency_chkbx__c == false && UpdatedCase.Financial_Security_Type_chkbx__c == false && UpdatedCase.Financial_Security_Template_chkbx__c == false && UpdatedCase.Financial_Security_Provider_chkbx__c == false && UpdatedCase.Expiry_Date_chkbx__c == false)
            return false;

        /*//allows admin to do anything.*/
        if (currentUserProfile.Name.toLowerCase().contains('system administrator')) {
            return false;
        }

        /*// only allow saving if status = FS Requested, FS Provided or Closed when the check boxes are checked*/
        if (!currentUserProfile.Name.toLowerCase().contains('system administrator')) {

            if (  (UpdatedCase.Agent_Name_chkbx__c && UpdatedCase.Financial_Security_Amount_chkbx__c && UpdatedCase.Financial_Security_Currency_chkbx__c && UpdatedCase.Financial_Security_Type_chkbx__c && UpdatedCase.Financial_Security_Template_chkbx__c && UpdatedCase.Financial_Security_Provider_chkbx__c && UpdatedCase.Expiry_Date_chkbx__c )
                    && ((UpdatedCase.Status == 'Financial Security Requested' && UpdatedCase.FS_Submitted_Date__c != null) || (UpdatedCase.Status == 'Financial Security Provided' && UpdatedCase.FS_Submitted_Date__c != null)  || UpdatedCase.Status  == 'Closed' || UpdatedCase.Status == 'Assessment Performed' || UpdatedCase.Status == 'Assessment Cancelled' || UpdatedCase.Status == 'Quality Issue Request Pending Approval' || UpdatedCase.Status == 'Quality Issue Request Approved' || UpdatedCase.Status == 'Quality Issue Rejected')) {
                return false;
            }
        }

        return true;
    }

    /*
    * Return True if the account has one or more closed case for the specified financial year
    */
    public static Boolean accountHasClosedCases(String accountId, String financialYear) {
        return (accountNbrClosedCase(accountId, financialYear) > 0);
    }

    public static Integer accountNbrClosedCase(String accountId, String financialYear) {
        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

        List<Case> cases = [Select c.Status, c.IFAP_Financial_Year__c, c.IFAP_Financial_Month__c, c.AccountId, c.RecordTypeId From Case c where c.AccountId = : accountId and c.Status = 'Closed' and c.IFAP_Financial_Year__c = : financialYear and c.RecordTypeId = : IFAPcaseRecordTypeID];
        return (cases == null ? 0 : cases.size());
    }

    public static Boolean isSAAMCase(String caseId) {
        ID ProcessISSPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');

        List<Case> theCase = [select c.Id, c.Subject, c.RecordTypeId from Case c where c.Id = :caseId and c.RecordTypeId = :ProcessISSPcaseRecordTypeID];
        return (theCase != null && theCase.size() > 0);
    }

    public static Boolean caseHasChildIFAPCases(String caseId) {
        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        List<Case> childCases = [Select c.Status, c.RecordTypeId From Case c where c.ParentId = : caseId and c.RecordTypeId = : IFAPcaseRecordTypeID];
        return (childCases != null && childCases.size() > 0);
    }

    public static void updateParentSAAMCase(Case previousIFAPCase, Case updatedIFAPCase) {
        Boolean mustUpdateSAAMCase = false;
        List<Case> parentSAAMCase = [select c.Financial_Assessment_requested__c, c.Financial_Assessment_received__c, c.Financial_Assessment_deadline__c, c.Financial_Assessment_compliant__c from Case c where c.Id = :updatedIFAPCase.ParentId];
        if (parentSAAMCase == null || parentSAAMCase.size() == 0) {
            updatedIFAPCase.addError('Could not find parent SAAM case for Case ' + updatedIFAPCase.CaseNumber + '.');
            return;
        }

        // check if the FA Submitted Date has changed
        if (previousIFAPCase.Submitted_Date__c <> updatedIFAPCase.Submitted_Date__c) {
            parentSAAMCase[0].Financial_Assessment_requested__c = updatedIFAPCase.Submitted_Date__c;
            // requirements says 3 working days... business proposed 5 calendar days
            parentSAAMCase[0].Financial_Assessment_deadline__c = updatedIFAPCase.Submitted_Date__c <> null ? updatedIFAPCase.Submitted_Date__c.addDays(5) : null;
            mustUpdateSAAMCase = true;
        }

        // check if the Assessment Performed Date has changed
        if (previousIFAPCase.Assessment_Performed_Date__c <> updatedIFAPCase.Assessment_Performed_Date__c) {
            parentSAAMCase[0].Financial_Assessment_received__c = updatedIFAPCase.Assessment_Performed_Date__c;
            mustUpdateSAAMCase = true;
        }

        // check if the Financial Review Result has changed
        if (previousIFAPCase.Financial_Review_Result__c <> updatedIFAPCase.Financial_Review_Result__c) {
            if (updatedIFAPCase.Financial_Review_Result__c.startsWith('Satisfactory')) {
                parentSAAMCase[0].Financial_Assessment_compliant__c = 'Satisfactory';
                mustUpdateSAAMCase = true;
            } else if (updatedIFAPCase.Financial_Review_Result__c.startsWith('Unsatisfactory')) {
                parentSAAMCase[0].Financial_Assessment_compliant__c = 'Unsatisfactory';
                mustUpdateSAAMCase = true;
            }
        }

        if (mustUpdateSAAMCase) {
            update parentSAAMCase;
        }
    }

    public static Boolean caseHasReassesments(String caseId) {
        List<IFAP_Quality_Issue__c> caseReassessments = [Select i.Related_Case__c, i.Name, i.Id From IFAP_Quality_Issue__c i where i.Related_Case__c = :caseId];
        return (caseReassessments != null && caseReassessments.size() > 0);
    }

    public static Id getAssessmentTemplateForAccount(Account theAccount) {

        Id assessmentTemplateId = null;

        if (theAccount != null) {

            // check the Passenger/Cargo flag
            String paxCargoFlag;
            if (theAccount.Type == null)
                paxCargoFlag = '';
            else if (theAccount.Type == 'IATA Passenger Sales Agent')
                paxCargoFlag = 'P';
            else if (theAccount.Type == 'IATA Cargo Agent')
                paxCargoFlag = 'C';
            else
                paxCargoFlag = '';

            // upper case the country
            String country = '';
            if (theAccount.BillingCountry != null)
                country = theAccount.BillingCountry.toUpperCase();

            // check for the corresponding assessment template
            Assessment_Template__c[] templates = [Select a.Id, a.Template_Code__c, a.Passenger_Cargo__c, a.Name, a.Country_Name__c, a.Country_ISO_Code__c
                                                  From Assessment_Template__c a
                                                  where a.Passenger_Cargo__c = :paxCargoFlag
                                                          and a.Country_Name__c = :country];

            if (templates != null && templates.size() > 0) {
                assessmentTemplateId = templates[0].Id;
            }
        }

        return assessmentTemplateId;
    }

    /**
     * To use once on deployment to production
     */
    public static Boolean assignAssessmentTemplateToAccountsWhereMissing(Integer maxLimit) {

        Id accountRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        Account[] listAccountToAssign = [Select a.Id, a.Name, a.Type, a.BillingCountry, a.Assessment_Template__c From Account a where a.Assessment_Template__c = null and a.RecordTypeId = :accountRecordTypeId limit :maxLimit];

        for (Account a : listAccountToAssign) {
            //Boolean result = setAssessmentTemplateToAccount(a);
            Id assessmentTemplateId = getAssessmentTemplateForAccount(a);
            if (assessmentTemplateId != null) {
                a.Assessment_Template__c = assessmentTemplateId;
                update a;
            }
        }

        return true;
    }

    /**
    * Quality Issue
    * Check if at least one Reassessment Accounting issue is related to the current quality issue.
    **/
    public static boolean isReassessmentAccountingIssueLinked(IFAP_Quality_Issue__c qualityIssue) {

        List<IFAP_Reassessment_Accounting_Issue__c> accountingIssues = [SELECT Id FROM IFAP_Reassessment_Accounting_Issue__c WHERE IFAP_Reassessment__c = : qualityIssue.Id];

        // if we find at least one accounting issue related to the Quality issue it's ok (return true)
        if (accountingIssues.size() > 0) return true;
        return false;
    }

    public static boolean isAtLeastOneQualityIssueIsSelected(IFAP_Quality_Issue__c qualityIssue) {
        if (qualityIssue.Assessment_using_wrong_template__c == false && qualityIssue.Financials_not_audited_certified__c == false &&
                qualityIssue.Incorrect_sales_used_for_the_assessment__c == false && qualityIssue.Incorrect_sanity_check_failure__c == false &&
                qualityIssue.Missing_value_in_fields__c == false && qualityIssue.Output_is_empty_not_completed_has_errors__c == false &&
                qualityIssue.Parent_company_accounts_not_reviewed__c == false && qualityIssue.The_printout_of_the_result_is_unreadable__c == false &&
                qualityIssue.Wrong_figure_was_extracted__c == false && qualityIssue.Wrong_financial_year__c == false) {
            return false;
        }
        return true;
    }

    /**
    * Check if the field Other Details is required (Quality issue object validation)
    **/
    public static boolean isOtherDetailsFieldRequired(IFAP_Quality_Issue__c qualityIssue) {
        system.debug('Quality Issue: ' + qualityIssue);
        if (qualityIssue.Wrong_figure_was_extracted__c || qualityIssue.Incorrect_sanity_check_failure__c ||
                qualityIssue.Parent_company_accounts_not_reviewed__c || qualityIssue.Financials_not_audited_certified__c ||
                qualityIssue.Assessment_using_wrong_template__c || qualityIssue.Wrong_financial_year__c ||
                qualityIssue.Incorrect_sales_used_for_the_assessment__c) {
            return true;
        }
        return false;
    }

    /**
    * Check if the field Formatting issue Detail is required (Quality issue object validation)
    **/
    public static boolean isFormattingIssueDetailsRequired(IFAP_Quality_Issue__c qualityIssue) {
        system.debug('Quality Issue: ' + qualityIssue);
        if (qualityIssue.The_printout_of_the_result_is_unreadable__c || qualityIssue.Missing_value_in_fields__c || qualityIssue.Output_is_empty_not_completed_has_errors__c) {
            return true;
        }

        return false;
    }
}
