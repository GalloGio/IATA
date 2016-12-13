trigger AMS_OSCARTrigger on AMS_OSCAR__c (before insert, before update, after insert, after update) {

    if(!AMS_TriggerExecutionManager.checkExecution(AMS_OSCAR__c.getSObjectType(), 'AMS_OSCARTrigger')) { return; }
    
    //In time all logic in this trigger should be moved inside these helper methods
    if (Trigger.isBefore && Trigger.isInsert) {
        AMS_OSCARTriggerHandler.handleBeforeInsert();
    } else if (Trigger.isBefore && Trigger.isUpdate) {
        AMS_OSCARTriggerHandler.handleBeforeUpdate(Trigger.new);
    }//TD: After Insert && after update. 
    else if(trigger.isAfter && trigger.isInsert){
        AMS_OSCARTriggerHandler.handleAfterInsert();
    }else if(trigger.isAfter && trigger.isUpdate){
        AMS_OSCARTriggerHandler.handleAfterUpdate();
    }

    List<Case> casesToUpdate = new List<Case>();
    Set<Id> caseCheck = new Set<Id>(); //prevent same case from being added to the list again

    public Map<String, String> oscarExternalLabels {
        get {
            return new Map<String, String> {
                'STEP1__c' => System.Label.AMS_OSCAR_STEP1,
                'STEP10__c' => System.Label.AMS_OSCAR_STEP10,
                'STEP11__c' => System.Label.AMS_OSCAR_STEP11,
                'STEP12__c' => System.Label.AMS_OSCAR_STEP12,
                'STEP13__c' => System.Label.AMS_OSCAR_STEP13,
                'STEP14__c' => System.Label.AMS_OSCAR_STEP14,
                'STEP15__c' => System.Label.AMS_OSCAR_STEP15,
                'STEP16__c' => System.Label.AMS_OSCAR_STEP16,
                'STEP17__c' => System.Label.AMS_OSCAR_STEP17,
                'STEP18__c' => System.Label.AMS_OSCAR_STEP18,
                'STEP19__c' => System.Label.AMS_OSCAR_STEP19,
                'STEP2__c' => System.Label.AMS_OSCAR_STEP2,
                'STEP20__c' => System.Label.AMS_OSCAR_STEP20,
                'STEP21__c' => System.Label.AMS_OSCAR_STEP21,
                'STEP22__c' => System.Label.AMS_OSCAR_STEP22,
                'STEP23__c' => System.Label.AMS_OSCAR_STEP23,
                'STEP24__c' => System.Label.AMS_OSCAR_STEP24,
                'STEP25__c' => System.Label.AMS_OSCAR_STEP25,
                'STEP3__c' => System.Label.AMS_OSCAR_STEP3,
                'STEP4__c' => System.Label.AMS_OSCAR_STEP4,
                'STEP5__c' => System.Label.AMS_OSCAR_STEP5,
                'STEP6__c' => System.Label.AMS_OSCAR_STEP6,
                'STEP7__c' => System.Label.AMS_OSCAR_STEP7,
                'STEP8__c' => System.Label.AMS_OSCAR_STEP8,
                'STEP9__c' => System.Label.AMS_OSCAR_STEP9
            };
        }
        set;
    }
    
    //get all step fields from the OSCAR object
    List<String> stepsOSCAR = new List<String>();
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Map<String, Schema.SObjectField> fieldMap = schemaMap.get('AMS_OSCAR__c').getDescribe().fields.getMap();

    for (String fieldName : fieldMap.keySet()) {
        //System.debug('##Field API Name='+fieldName);// list of all field API name
        if (fieldName.startsWithIgnoreCase('STEP'))
            //stepsOSCAR.add(fieldName);
            stepsOSCAR.add(fieldMap.get(fieldName).getDescribe().getLabel());
    }

    System.debug('STEPs on OSCAR Object: ' + stepsOSCAR);
    
    //TD: Because I added "AFTER INSERT", I added here the isBefore, which was missing
    if (Trigger.isBefore && Trigger.isInsert) {

        List<AMS_OSCAR__c> oscars = new List<AMS_OSCAR__c>();

        Set<Id> oscarAgencies = new Set<Id>();

        for (AMS_OSCAR__c oscar : Trigger.new) {
            oscarAgencies.add(oscar.Account__c);
        }

        Map<Id, Account> agencyAccount = new Map<Id, Account>([select id, IATACode__c from Account where id in :oscarAgencies]);

        for (AMS_OSCAR__c oscar : Trigger.new) {
            //set default name if no case is attached to the oscar
            oscar.Name = 'Wait for OSCAR Communication Case to be attached';
            for (String step : stepsOSCAR) {
                oscar.put(step + '__c', 'Not Started');
                //requirement to put iata code generator as passed if the account already as a iata code
                if (step == 'STEP10' && agencyAccount.get(oscar.Account__c) != null && agencyAccount.get(oscar.Account__c).IATACode__c != null) {
                    oscar.put(step + '__c', 'Passed');
                }
            }

            //ON INSERT
            //USED ON: HO,BR,TIDS,GSA,AHA,GSSA,MSO,SA
            oscar.Dossier_Reception_Date__c = Date.today();

            if(oscar.Process__c == AMS_Utils.new_HO || oscar.Process__c == AMS_Utils.new_BR_ABROAD || oscar.Process__c == AMS_Utils.new_BR || oscar.Process__c == AMS_Utils.new_SA){
            	oscar.Sanity_check_deadline__c = Date.today() + 30;
            	oscar.OSCAR_Deadline__c = Date.today() + 30;
            }
            else if(oscar.Process__c == AMS_Utils.new_TIDS){
                oscar.Sanity_check_deadline__c = Date.today()+3;
                oscar.OSCAR_Deadline__c = Date.today() + 3;
            }
            else if(oscar.Process__c == AMS_Utils.new_GSA_BSP || oscar.Process__c == AMS_Utils.new_AHA_BSP || oscar.Process__c == AMS_Utils.new_GSSA)
                oscar.Sanity_check_deadline__c = Date.today();


            if(oscar.Process__c == AMS_Utils.new_GSA_BSP || oscar.Process__c == AMS_Utils.new_AHA_BSP)
                oscar.BSPLink_participation__c = true;
            //removed in issue AMS-1584
            //oscar.Sanity_check_deadline__c = Date.today() + 15;


            oscars.add(oscar);

        }

        if (!oscars.isEmpty()){
            //deprecated AMS-1665
            //AMS_OscarCaseTriggerHelper.assignOscarToRegionQueue(oscars);
        }

    } //TD: Because I added "AFTER UPDATE", I added here the isBefore, which was missing
    else if (Trigger.isBefore && Trigger.isUpdate) {

        Set<Id> oscarAccountIds = new Set<Id>();

        for (AMS_OSCAR__c oscar : Trigger.new)
            oscarAccountIds.add(oscar.Account__c);

        Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships = AMS_HierarchyHelper.getAccountsHierarchies(oscarAccountIds);

        AMS_OSCAR_JSONHelper helper = null;
        boolean resultLoad = false;

        List<AMS_OSCAR__c> closedOscars = new List<AMS_OSCAR__c>();

        Map<Id, Case> caseOscars = new Map<Id, Case>();

        //processes to ignore in the creation of the DIS change code
        Set<String> ProcessesToIgnoreChangeCode = new Set <String> {AMS_Utils.new_TIDS,
                                                                    AMS_Utils.new_MSO,
                                                                    AMS_Utils.new_GSA,
                                                                    AMS_Utils.new_GSSA,
                                                                    AMS_Utils.new_AHA
                                                                    };

        for (AMS_OSCAR__c updatedOSCAR : Trigger.New) {
            AMS_OSCAR__c oldOSCAR = Trigger.oldMap.get(updatedOSCAR.Id);

            applyAccreditationProcessLogic(oldOSCAR, updatedOscar);

            if(!ProcessesToIgnoreChangeCode.contains(updatedOscar.Process__c))
                applyChangeCodesWithDependencies(oldOSCAR, updatedOscar, accountHierarchyRelationships);


            processFieldsTracking(oldOSCAR, updatedOscar);

            //check for each OSCAR which steps were changed
            for (String step : stepsOSCAR) {

                if (updatedOSCAR.get(step + '__c') <> oldOSCAR.get(step + '__c')) {


                    if (helper == null) {
                        helper = new AMS_OSCAR_JSONHelper();
                        resultLoad = helper.loadJsonResource('JSON_OSCAR_Process');
                    }

                    if (resultLoad)
                        boolean result = helper.processAutomation(updatedOSCAR.Process__c, step, (String)updatedOSCAR.get(step + '__c'), updatedOSCAR);

                }
            }

            // logic: When the user changes the OSCAR status to any of the 4 Closed values (either on the left or directly in the centre),
            // the Date Closed field should be populated with the current date and the case should be closed.

            if ( updatedOSCAR.Status__c != null && updatedOSCAR.Status__c <> oldOSCAR.Status__c && AMS_OSCARTriggerHandler.closedStatusMapping.containsKey(updatedOSCAR.Status__c) ) {

                updatedOSCAR.Date_Time_Closed__c = System.now();
            }

            if (updatedOSCAR.Status__c != null && updatedOSCAR.Status__c <> oldOSCAR.Status__c && updatedOSCAR.Status__c.equalsIgnoreCase('Pending Validation')) {
                AMS_OSCAR_ApprovalHelper.submit('', updatedOSCAR.Id, UserInfo.getUserId(), 'Automated approval submission based on OSCAR Status "Pending Validation".');
            }

        }

    }

    private static void applyChangeCodesWithDependencies(AMS_OSCAR__c oldOSCAR, AMS_OSCAR__c updatedOscar, Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships) {
        ID newRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
        ID corrRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CORRECTION').getRecordTypeId();
        if (updatedOscar.recordTypeID == newRT){
            if (oldOSCAR.STEP2__c != 'Passed' && updatedOscar.STEP2__c == 'Passed') {
                AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

                changeCode.name = 'FIN';
                changeCode.reasonCode = '91';
                changeCode.memoText = AMS_Utils.getChangeCodeMemoText(updatedOscar.Process__c,changeCode.name);
                changeCode.reasonDesc  = 'ACCREDITED–MEETS–STANDARDS';
                changeCode.status  = '9';

                Account acct = new Account(Id = updatedOscar.Account__c);
                AMS_Utils.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {updatedOscar}, new List<Account> {acct}, true);

            } else if (oldOSCAR.STEP2__c != 'Failed' && updatedOscar.STEP2__c == 'Failed' && updatedOscar.RPM_Approval__c=='Authorize Disapproval') {

                AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

                changeCode.name = 'DIS';
                changeCode.reasonCode = '00';
                changeCode.memoText = AMS_Utils.getChangeCodeMemoText(updatedOscar.Process__c,changeCode.name);
                changeCode.reasonDesc  = 'NON COMPLIANCE TO CRITERIA';
                changeCode.status  = '0';

                Account acct = new Account(Id = updatedOscar.Account__c);
                AMS_Utils.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {updatedOscar}, new List<Account> {acct}, true);
            }
        // Management of CORRECTION OSCARs
        }else if (updatedOscar.recordTypeID == corrRT){
            if (oldOSCAR.STEP6__c != 'Passed' && updatedOscar.STEP6__c == 'Passed'){

                Savepoint sp = Database.setSavepoint();

                try {

                    // Regardless the changecode is generated or not, move data to Master Data
                    // First move the account
                    system.debug(LoggingLevel.ERROR,'applyChangeCodesWithDependencies() -> move to MD account data');
                    AMS_Utils.copyDataToAccount(new List<AMS_OSCAR__c>{updatedOscar}, false);

                    // THen move the owners
                    Map<Id, Set<Id>> stagingToAccounts = new Map<Id, Set<Id>>();
                    //Need to apply change of ownership to all the accounts in herarchy
                    Set<Id> allHierarchyAccountIds = new Set<Id>();


                    //AMS-1671
                    if(isEmptyAccountHierarchyRelationshipsMap(accountHierarchyRelationships)){// it means that the account does not have an hierarchy yet generated.
                        allHierarchyAccountIds.add(updatedOscar.Account__c);
                    }else{
                        for(AMS_Agencies_relationhip__c rel: accountHierarchyRelationships.get(updatedOscar.Account__c)){
                            allHierarchyAccountIds.add(rel.Parent_Account__c);
                            allHierarchyAccountIds.add(rel.Child_Account__c);
                        }
                    }

                    //Remove TERMINATED Accounts from list
                    for(Account acc: [SELECT Id, Status__c FROM Account WHERE Id IN :allHierarchyAccountIds AND Status__c <> null]){
                        if(acc.Status__c.equalsIgnoreCase(AMS_Utils.ACC_S0_TERMINATED))
                            allHierarchyAccountIds.remove(acc.Id);
                    }

                    stagingToAccounts.put(updatedOscar.AMS_Online_Accreditation__c, allHierarchyAccountIds);
                    system.debug('applyChangeCodesWithDependencies() -> move to MD contact data. Pass map: '+stagingToAccounts);
                    AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(stagingToAccounts, true);


                    //verify ownership alignment
                    if(allHierarchyAccountIds.size()>0 && !AMS_HierarchyHelper.checkHierarchyIntegrity(new Map<Id, Set<Id>>{updatedOscar.Id => allHierarchyAccountIds}))
                        throw new AMS_ApplicationException('This operation cannot be performed because the ownership in this hierarchy is not aligned. It is advised to perform a change of ownership to align the owners in this hierarchy.');

                    // If the picklist is set create a COR change code.
                    if(updatedOscar.AMS_Correction_change_code__c == 'COR') {
                        system.debug(LoggingLevel.ERROR,'applyChangeCodesWithDependencies() -> generate the change code');
                        AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

                        changeCode.name = 'COR';
                        changeCode.reasonCode = '91';
                        changeCode.memoText = 'Correction';
                        changeCode.reasonDesc  = 'ACCREDITED–MEETS–STANDARDS';
                        changeCode.status  = '9';

                        Account acct = new Account(Id = updatedOscar.Account__c);
                        AMS_Utils.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {updatedOscar}, new List<Account> {acct}, true);
                    }
                    // If the picklist is set create a CAD change code.
                    if(updatedOscar.AMS_Correction_change_code__c == 'CAD') {
                        system.debug(LoggingLevel.ERROR,'applyChangeCodesWithDependencies() -> generate the change code');
                        AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

                        List<Agency_Applied_Change_code__c> accountActiveChangeCode = [SELECT Reason_Code__c, Reason_Description__c FROM Agency_Applied_Change_code__c WHERE Account__c =: updatedOscar.Account__c AND Active__c = TRUE];

                        changeCode.name = 'CAD';
                        changeCode.reasonCode = 'Change data';
                        changeCode.memoText = 'Minor Changes';
                        changeCode.reasonDesc  = 'Accredited-Meets Criteria.';
                        changeCode.status  = null;

                        if(accountActiveChangeCode.size() > 0){
                            changeCode.reasonCode = accountActiveChangeCode[0].Reason_Code__c;
                            changeCode.reasonDesc = accountActiveChangeCode[0].Reason_Description__c;
                        }
                        Account acct = new Account(Id = updatedOscar.Account__c);
                        AMS_Utils.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {updatedOscar}, new List<Account> {acct}, true);
                    }

                } catch (Exception ex) {
                    System.debug('Exception: ' + ex);
                    Database.rollback(sp);
                    throw ex;
                }

            }

        }
    }

    private static boolean isEmptyAccountHierarchyRelationshipsMap(Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships){

        if(accountHierarchyRelationships.isEmpty())
            return true;

        if(accountHierarchyRelationships.values().isEmpty())
            return true;

        for(List<AMS_Agencies_relationhip__c> agency:accountHierarchyRelationships.values()){
            if(!agency.isEmpty())
                return false;
        }

        return true;
    }


    private static void applyAccreditationProcessLogic(AMS_OSCAR__c oldOSCAR, AMS_OSCAR__c updatedOscar) {
        //To update with current date 'Checkbox Field' => 'Date Field'
        Map<String,String> oscarDateFieldsMap = new Map <String,String> {
            'Cancel_Inspection_Requests_Disapproval__c' => 'Cancel_Inspection_Req_Disapproval_Date__c',
            'Cancel_Inspection_Requests_Rejection__c'   => 'Cancel_Inspection_Req_Rejection_Date__c',
            'Close_IFAP_Disapproval__c'                 => 'Close_IFAP_Disapproval_Date__c',
            'Close_IFAP_Rejection__c'                   => 'Close_IFAP_Rejection_Date__c',
            'Country_Specifics_Approval__c'             => 'Country_Specifics_Approval_Date__c',
            'Country_Specifics_Disapproval__c'          => 'Country_Specifics_Disapproval_Date__c',
            'Country_Specifics_Rejection__c'            => 'Country_Specifics_Rejection_Date__c',
            'Update_AIMS_Approval__c'                   => 'Update_AIMS_Approval_Date__c',
            'Update_AIMS_Disapproval__c'                => 'Update_AIMS_Disapproval_Date__c',
            'Update_AIMS_Rejection__c'                  => 'Update_AIMS_Rejection_Date__c',
            'Update_DPC__c'                             => 'DPC_updated__c',
            'Update_IRIS__c'                            => 'IRIS_updated__c',
            'Update_BSPLink_CASSLink__c'                => 'Operational_Systems_Updated__c',
            'Update_Portal_Setup__c'                    => 'Portal_setup_performed__c',
            'Send_approval_letter__c'                   => 'Approval_letter_sent__c',
            'Welcome_pack__c'                           => 'Welcome_Pack_Sent__c',
            'Off_site_storage__c'                       => 'Storage_performed__c',
            'Welcome_call__c'                           => 'Welcome_call_performed__c',
            'Issue_disapproval_pack__c'                 => 'Disapproval_pack_sent__c',
            'Issue_credit_note_if_applicable__c'        => 'Fees_refund_requested__c',
            'Release_FS_if_applicable__c'               => 'Financial_Security_released__c',
            'Issue_Withdrawal_notification__c'          => 'Withdrawal_notification_sent__c',
            'Issue_credit_note_withdrawal__c'           => 'Fees_refunds_requested_withdrawal__c',
            'Release_FS_withdrawal__c'                  => 'Financial_Security_released_withdrawal__c',
            'Update_IRIS_processing__c'                 => 'IRIS_updated_processing__c',
            'Confirm_DD_setup_with_R_S__c'              => 'DD_setup_with_R_S_confirmed__c',
            'Confirm_DD_setup_with_agent__c'            => 'DD_setup_with_agent_confirmed__c',
            'Confirm_DGR_DGA__c'                        => 'DGR_DGA_confirmed__c',
            'Issue_rejection_notification_pack__c'      => 'Rejection_notification_sent__c',
            'Roll_back_account_data__c'                 => 'Account_data_rolled_back__c',
            'Issue_billing_document__c'                 => 'Invoice_Requested__c',
            'Notify_Agent_Suspension__c'                => 'NOC_Requested__c',
            'NOC_Received__c'                           => 'NOC_Received_Date__c',
            'Suspend_in_BSPLINK_CASSLink__c'            => 'Suspended_in_BSPLINK_CASSLink__c',
            'Release_FS_if_applicable__c'               => 'Financial_Security_released__c',
            'Reactivate_Agent_in_BSPlink_CASSlink__c'   => 'Reactivated_Agent_in_BSPlink_CASSlink__c',
            'Confirm_Payment_if_applicable__c'          => 'Proof_of_payment_received__c',
            'Send_Confirmation__c'                      => 'Confirmation_Sent__c'
            };
           //Map to update Date related checkbox values
        for (String oscarDateFieldKey: oscarDateFieldsMap.keyset())
        {
            if (oldOSCAR.get(oscarDateFieldKey) == false && updatedOscar.get(oscarDateFieldKey) == true)
            {
                system.debug(oscarDateFieldsMap.get(oscarDateFieldKey));
                updatedOscar.put(oscarDateFieldsMap.get(oscarDateFieldKey),Date.today());
            }
        }
      
      
        if (oldOSCAR.Send_invoice__c == false && updatedOscar.Send_invoice__c == true) {
            updatedOSCAR.STEP8__c = 'Passed';
            updatedOSCAR.Payment_requested__c = Date.today();
            updatedOSCAR.Invoice_deadline__c = Date.today() + 7;
        }

        if (oldOSCAR.Send_inspection_request__c == false && updatedOscar.Send_inspection_request__c == true)
            updatedOSCAR.STEP13__c = 'In Progress';

        if (oldOSCAR.Send_agreement__c == false && updatedOscar.Send_agreement__c == true)
            updatedOSCAR.STEP14__c = 'In Progress';

        if (oldOSCAR.Send_FS_request__c == false && updatedOscar.Send_FS_request__c == true) {
            updatedOSCAR.Bank_Guarantee_requested__c = Date.today();
            updatedOSCAR.Bank_Guarantee_deadline__c = Date.today() + 30;
        }

        if (oldOSCAR.RPM_Approval__c <> updatedOscar.RPM_Approval__c && updatedOscar.RPM_Approval__c == 'Authorize Approval') {
            // Approve the Approval Process from the Manager's perspective
            List<Id> currentApprovals = AMS_OSCAR_ApprovalHelper.getAllApprovals(new List<Id> {updatedOscar.Id});
            if (currentApprovals.size() > 0) {
                AMS_OSCAR_ApprovalHelper.processForObject('Approve', updatedOscar.Id, null, 'Automated approval based on Manager approval with comments: ' + updatedOscar.Comments_approval__c);
            }
            updatedOSCAR.STEP2__c = 'Passed';
        }

        if (oldOSCAR.RPM_Approval__c <> updatedOscar.RPM_Approval__c && updatedOscar.RPM_Approval__c == 'Authorize Disapproval') {
            // Approve the Approval Process from the Manager's perspective
            List<Id> currentApprovals = AMS_OSCAR_ApprovalHelper.getAllApprovals(new List<Id> {updatedOscar.Id});
            if (currentApprovals.size() > 0) {
                AMS_OSCAR_ApprovalHelper.processForObject('Approve', updatedOscar.Id, null, 'Automated approval based on Manager approval with comments: ' + updatedOscar.Comments_approval__c);
            }
            updatedOSCAR.STEP2__c = 'Failed';
        }
        if (oldOSCAR.RPM_Approval__c <> updatedOscar.RPM_Approval__c && updatedOscar.RPM_Approval__c == 'Reprocess case') {
            // Reject the Approval Process from the Manager's perspective
            List<Id> currentApprovals = AMS_OSCAR_ApprovalHelper.getAllApprovals(new List<Id> {updatedOscar.Id});
            if (currentApprovals.size() > 0) {
                AMS_OSCAR_ApprovalHelper.processForObject('Reject', updatedOscar.Id, null, 'Automated rejection based on Manager disapproval with comments: ' + updatedOscar.Comments_approval__c);
            }
            updatedOSCAR.STEP2__c = 'Failed';
        }

        if (oldOSCAR.Bank_Guarantee_amount__c == null && updatedOscar.Bank_Guarantee_amount__c != null)
            updatedOSCAR.STEP12__c = 'In Progress';


        if (oldOSCAR.Validation_Status__c != updatedOscar.Validation_Status__c) {
            List<Id> currentApprovals = AMS_OSCAR_ApprovalHelper.getAllApprovals(new List<Id> {updatedOscar.Id});
            if (updatedOscar.Validation_Status__c == 'Passed') {
                /*
                    1) Approve current approval process (assistant manager's)
                    2) Continue with the step no. 2 (for the manager)
                */
                if (currentApprovals.size() > 0) {
                    AMS_OSCAR_ApprovalHelper.processForObject('Approve', updatedOscar.Id, null, 'Automated approval based on Assistant Manager validation with comments: ' + updatedOscar.Comments_validate__c);
                }
            } else if (updatedOscar.Validation_Status__c == 'Failed' || updatedOscar.Validation_Status__c == 'Not Applicaple') {
                // Reject the approval process
                if (currentApprovals.size() > 0)
                    AMS_OSCAR_ApprovalHelper.processForObject('Reject', updatedOscar.Id, null, 'Automated rejection based on Assistant Manager validation rejection with comments: ' + updatedOscar.Comments_validate__c);
            }
            if(updatedOscar.Process__c.equals(AMS_Utils.AGENCYCHANGES))
                updatedOscar.STEP25__c = updatedOscar.Validation_Status__c;
            else
                updatedOscar.STEP15__c = updatedOscar.Validation_Status__c;
        }

        if (oldOSCAR.BSPLink_participation__c == false && updatedOscar.BSPLink_participation__c == true && oldOSCAR.Process__c == AMS_Utils.new_GSA)
            updatedOSCAR.Process__c = AMS_Utils.new_GSA_BSP;

        if (oldOSCAR.BSPLink_participation__c == true && updatedOscar.BSPLink_participation__c == false && oldOSCAR.Process__c == AMS_Utils.new_GSA_BSP)
            updatedOSCAR.Process__c = AMS_Utils.new_GSA;

        if (oldOSCAR.BSPLink_participation__c == false && updatedOscar.BSPLink_participation__c == true && oldOSCAR.Process__c == AMS_Utils.new_AHA)
            updatedOSCAR.Process__c = AMS_Utils.new_AHA_BSP;

        if (oldOSCAR.BSPLink_participation__c == true && updatedOscar.BSPLink_participation__c == false && oldOSCAR.Process__c == AMS_Utils.new_AHA_BSP)
            updatedOSCAR.Process__c = AMS_Utils.new_AHA;

        if (oldOSCAR.Apply_Penalty_Fee__c == false && updatedOscar.Apply_Penalty_Fee__c == true) {

            //late/absence of NOC - penalty fees can only be applied for some ToC (could add validation for dates)
            Set<String> tocList = new Set<String>();
            if(updatedOscar.Type_of_Change__c != null) tocList.addAll(updatedOscar.Type_of_change__c.split(';'));

            System.debug(loggingLevel.Debug, '____ [trg AMS_OSCARTrigger - validateStep29] tocList - ' + tocList);
            if(
                !tocList.contains(AMS_Utils.OWNERSHIP_IATA)
                && !tocList.contains(AMS_Utils.OWNERSHIP_NON_IATA)
                && !tocList.contains(AMS_Utils.MAJ_SHAREHOLDING)
                && !tocList.contains(AMS_Utils.NAME)
                && !tocList.contains(AMS_Utils.LEGAL_STATUS)
                && !tocList.contains(AMS_Utils.LOCATION)
            ){
                updatedOSCAR.addError('Penalty fees can only be applied for \n-'+AMS_Utils.OWNERSHIP_IATA+'\n-'+AMS_Utils.OWNERSHIP_NON_IATA+'\n-'+AMS_Utils.MAJ_SHAREHOLDING+'\n-'+AMS_Utils.NAME+'\n-'+AMS_Utils.LEGAL_STATUS+'\n-'+AMS_Utils.LOCATION);
            }
        }
        if (oldOSCAR.Apply_Penalty_Fee__c == true && updatedOscar.Apply_Penalty_Fee__c == false) {
            updatedOSCAR.addError('It\'s not possible to cancel the penalty fees that were applied');
        }

        if (oldOSCAR.Notify_Agent_Suspension__c == false && updatedOscar.Notify_Agent_Suspension__c == true) {
            updatedOSCAR.NOC_Deadline__c = AMS_Utils.AddBusinessDays(System.today(), 5, 'Late NOC - '+updatedOSCAR.Region__c);
        }
        
        if (oldOSCAR.Notify_Agent_Termination__c == false && updatedOscar.Notify_Agent_Termination__c == true) {
            updatedOSCAR.Termination_Date__c = AMS_Utils.lastDayOfMonth(System.today().addMonths(1));
            System.debug(loggingLevel.Debug, '____ [trg AMS_OSCARTrigger - beforUpdate] updatedOSCAR.Termination_Date__c - ' + updatedOSCAR.Termination_Date__c);

            if (AMS_Utils.IsWeekendDay(updatedOSCAR.Termination_Date__c, 'Late NOC - '+updatedOSCAR.Region__c)) {
                updatedOSCAR.Termination_Date__c = AMS_Utils.AddBusinessDays(updatedOSCAR.Termination_Date__c, 1, 'Late NOC - '+updatedOSCAR.Region__c);
            }
        }

        if (oldOSCAR.NOC_Received__c == false && updatedOscar.NOC_Received__c == true) {
            updatedOSCAR.Termination_Date__c = null;
        }

    }

    private void processFieldsTracking(AMS_OSCAR__c oldOscar, AMS_OSCAR__c updatedOSCAR) {

        Map<String, String> oscarLabels = AMS_Utils.getObjectLabels('AMS_OSCAR__c');

        List<AMS_OSCAR_Event__c> eventsToInsert = new List<AMS_OSCAR_Event__c>();

        List<AMS_OSCAR_HistoryFields__c> historyFieldsLst = AMS_OSCAR_HistoryFields__c.getAll().values();

        String fieldName;
        String relatedStep;

        for (AMS_OSCAR_HistoryFields__c field : historyFieldsLst) {

            relatedStep = null;

            fieldName = field.Name;

            if (oldOSCAR.get(fieldName) <> updatedOSCAR.get(fieldName)) {

                if (field.HasExternalLabel__c) {

                    relatedStep = oscarExternalLabels.get(fieldName);

                } else {

                    relatedStep = oscarLabels.get(fieldName.toLowerCase());
                }

                relatedStep = relatedStep == null ? fieldName : relatedStep;

                AMS_OSCAR_Event__c  event = new AMS_OSCAR_Event__c(OSCAR__c = updatedOSCAR.id, Related_Step__c = relatedStep, Old_Value__c = String.valueOf(oldOSCAR.get(fieldName)), New_Value__c = String.valueOf(updatedOSCAR.get(fieldName)));

                eventsToInsert.add(event);
            }

        }


        if (!eventsToInsert.isEmpty())
            insert eventsToInsert;

    }


}