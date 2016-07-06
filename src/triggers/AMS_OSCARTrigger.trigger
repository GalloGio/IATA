trigger AMS_OSCARTrigger on AMS_OSCAR__c (before insert, before update, after insert, after update) {

    if(!AMS_TriggerExecutionManager.checkExecution(AMS_OSCAR__c.getSObjectType(), 'AMS_OSCARTrigger')) { return; }
    
    //In time all logic in this trigger should be moved inside these helper methods
    if (Trigger.isBefore && Trigger.isInsert) {
        AMS_OSCARTriggerHandler.handleBeforeInsert(Trigger.new);
    } else if (Trigger.isBefore && Trigger.isUpdate) {
        AMS_OSCARTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
    }//TD: After Insert && after update. 
    else if(trigger.isAfter && trigger.isInsert){
        AMS_OSCARTriggerHandler.handleAfterInsert(Trigger.new);
    }else if(trigger.isAfter && trigger.isUpdate){
        AMS_OSCARTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
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

            //removed in issue AMS-1584
            //oscar.Sanity_check_deadline__c = Date.today() + 15;


            oscars.add(oscar);

        }

        if (!oscars.isEmpty()){
            AMS_OscarCaseTriggerHelper.assignOscarToRegionQueue(oscars);
        }

        for(Case c : [SELECT Id, Oscar__c, OwnerId FROM Case WHERE RecordType.Name = 'OSCAR Communication' AND Oscar__c in :Trigger.new]){
            AMS_OSCAR__c o = trigger.newMap.get(c.OSCAR__c);
            if(c.OwnerId != o.OwnerId){
                c.OwnerId = o.OwnerId;
                casesToUpdate.add(c);
            }
        }

        if(!casesToUpdate.isEmpty()) update casesToUpdate;

    } //TD: Because I added "AFTER UPDATE", I added here the isBefore, which was missing
    else if (Trigger.isBefore && Trigger.isUpdate) {

        AMS_OSCAR_JSONHelper helper = null;
        boolean resultLoad = false;

        List<AMS_OSCAR__c> closedOscars = new List<AMS_OSCAR__c>();

        //List<CASE> caseList = [select id, Status, Oscar__r.Id from CASE c where c.Oscar__r.id in :Trigger.newMap.keySet() and recordType.name = 'OSCAR Communication'];
        List<CASE> caseList = [select id, Status, Oscar__r.Id from CASE c where c.Oscar__c != null and recordType.name = 'OSCAR Communication' and c.Oscar__r.id in :Trigger.newMap.keySet()];

        Map<Id, Case> caseOscars = new Map<Id, Case>();

        for (Case caseOscar : caseList) {
            caseOscars.put(caseOscar.OSCAR__r.Id, caseOscar);
        }

        //processes to ignore in the creation of the DIS change code
        Set<String> ProcessesToIgnoreChangeCode = new Set <String> {AMS_Utils.new_TIDS,
                                                                    AMS_Utils.new_MSO,
                                                                    AMS_Utils.new_GSA,
                                                                    AMS_Utils.new_GSSA,
                                                                    AMS_Utils.new_AHA
                                                                    };

        for (AMS_OSCAR__c updatedOSCAR : Trigger.new) {
            AMS_OSCAR__c oldOSCAR = Trigger.oldMap.get(updatedOSCAR.Id);

            applyAccreditationProcessLogic(oldOSCAR, updatedOscar);

            if(!ProcessesToIgnoreChangeCode.contains(updatedOscar.Process__c))
                applyChangeCodesWithDependencies(oldOSCAR, updatedOscar);


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

            if (updatedOSCAR.Status__c <> oldOSCAR.Status__c) {

                if ( updatedOSCAR.Status__c == 'Closed (Closed)' ||
                        updatedOSCAR.Status__c == 'Closed_Not Accepted' ||
                        updatedOSCAR.Status__c == 'Closed_Rejected' ||
                        updatedOSCAR.Status__c == 'Closed_Withrawn' ) {

                    updatedOSCAR.Date_Time_Closed__c = System.now();

                    // now get the associated case and close it
                    Case caseToClose = caseOscars.get(updatedOSCAR.Id);

                    if (caseToClose != null) {

                        //CASE caseToClose = caseList.get(0);

                        if (updatedOSCAR.Status__c == 'Closed (Closed)')
                            caseToClose.Status = 'Closed';
                        else if (updatedOSCAR.Status__c == 'Closed_Not Accepted')
                            caseToClose.Status = 'Closed_ Not Accepted';
                        else if (updatedOSCAR.Status__c == 'Closed_Rejected')
                            caseToClose.Status = 'Closed_Rejected';
                        else if (updatedOSCAR.Status__c == 'Closed_Withrawn')
                            caseToClose.Status = 'Closed_Withdrawn';

                        casesToUpdate.add(caseToClose);
                    }
                } else if ( updatedOSCAR.Status__c.equalsIgnoreCase('Pending Approval') || updatedOSCAR.Status__c.equalsIgnoreCase('Pending Validation')) {
                    // Start an approval process
                    if (updatedOSCAR.Status__c.equalsIgnoreCase('Pending Validation')) {
                        AMS_OSCAR_ApprovalHelper.submit('', updatedOSCAR.Id, UserInfo.getUserId(), 'Automated approval submission based on OSCAR Status "Pending Validation".');
                    }

                    Case caseToUpdate = caseOscars.get(updatedOSCAR.Id);

                    if (caseToUpdate != null) {
                        caseToUpdate.Status = updatedOSCAR.Status__c;
                    }
                    if(caseCheck.add(caseToUpdate.Id)) casesToUpdate.add(caseToUpdate);

                } else {
                    //for other OSCAR "Status__c" values, updates the CASE status to be equal to the one in the OSCAR!
                    //Status to be caught on this area: 'Accepted_Pending Agreement', 'Accepted_Pending BG', 'Accepted_Pending Docs',
                    //                                  'On Hold_External', 'On Hold_Internal', 'Open', 'Reopen'

                    Case caseToUpdate = caseOscars.get(updatedOSCAR.Id);

                    if (caseToUpdate != null) {
                        caseToUpdate.Status = updatedOSCAR.Status__c;
                    }
                    if(caseCheck.add(caseToUpdate.Id)) casesToUpdate.add(caseToUpdate);
                }
            }

            if(updatedOSCAR.OwnerId != oldOscar.OwnerId){
                Case caseToUpdate = caseOscars.get(updatedOSCAR.Id);

                if (caseToUpdate != null) {
                    caseToUpdate.OwnerId = updatedOSCAR.OwnerId;
                    if(caseCheck.add(caseToUpdate.Id)) casesToUpdate.add(caseToUpdate);
                }
            }
        }

        if (!casesToUpdate.isEmpty())
            update casesToUpdate;
    }

    private static void applyChangeCodesWithDependencies(AMS_OSCAR__c oldOSCAR, AMS_OSCAR__c updatedOscar) {
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
                // If the checkbox is set create a COR change code.
                if(updatedOscar.AMS_Generate_COR_change_code__c==true) {
                    system.debug(LoggingLevel.ERROR,'applyChangeCodesWithDependencies() -> generate the change code');
                    AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

                    changeCode.name = 'COR';
                    changeCode.reasonCode = '91';
                    changeCode.memoText = 'Correction';
                    changeCode.reasonDesc  = 'ACCREDITED';
                    changeCode.status  = '9';

                    Account acct = new Account(Id = updatedOscar.Account__c);
                    AMS_Utils.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {updatedOscar}, new List<Account> {acct}, true);
                }

                // Regardless the changecode is generated or not, move data to Master Data
                // First move the account
                system.debug(LoggingLevel.ERROR,'applyChangeCodesWithDependencies() -> move to MD account data');
                AMS_Utils.copyDataToAccount(new List<AMS_OSCAR__c>{updatedOscar});

                // THen move the owners
                Map<Id, Set<Id>> stagingToAccounts = new Map<Id, Set<Id>>();
                stagingToAccounts.put(updatedOscar.AMS_Online_Accreditation__c, new Set<Id>{updatedOscar.Account__c});
                system.debug(LoggingLevel.ERROR,'applyChangeCodesWithDependencies() -> move to MD contact data. Pass map: '+stagingToAccounts);
                AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(stagingToAccounts);
            }

        }
    }


    private static void applyAccreditationProcessLogic(AMS_OSCAR__c oldOSCAR, AMS_OSCAR__c updatedOscar) {

        if (oldOSCAR.Send_invoice__c == false && updatedOscar.Send_invoice__c == true) {
            updatedOSCAR.STEP8__c = 'Passed';
            updatedOSCAR.Payment_requested__c = Date.today();
            updatedOSCAR.Invoice_deadline__c = Date.today() + 7;
        }

        if (oldOSCAR.Send_inspection_request__c == false && updatedOscar.Send_inspection_request__c == true)
            updatedOSCAR.STEP13__c = 'In Progress';

        if (oldOSCAR.Send_agreement__c == false && updatedOscar.Send_agreement__c == true)
            updatedOSCAR.STEP14__c = 'In Progress';

        if (oldOSCAR.Update_DPC__c == false && updatedOscar.Update_DPC__c == true)
            updatedOSCAR.DPC_updated__c = Date.today();

        if (oldOSCAR.Update_IRIS__c == false && updatedOscar.Update_IRIS__c == true)
            updatedOSCAR.IRIS_updated__c = Date.today();

        if (oldOSCAR.Update_BSPLink_CASSLink__c == false && updatedOscar.Update_BSPLink_CASSLink__c == true)
            updatedOSCAR.Operational_Systems_Updated__c = Date.today();

        if (oldOSCAR.Update_Portal_Setup__c == false && updatedOscar.Update_Portal_Setup__c == true)
            updatedOSCAR.Portal_setup_performed__c = Date.today();

        if (oldOSCAR.Send_approval_letter__c == false && updatedOscar.Send_approval_letter__c == true)
            updatedOSCAR.Approval_letter_sent__c = Date.today();

        if (oldOSCAR.Welcome_pack__c == false && updatedOscar.Welcome_pack__c == true)
            updatedOSCAR.Welcome_Pack_Sent__c = Date.today();

        if (oldOSCAR.Off_site_storage__c == false && updatedOscar.Off_site_storage__c == true)
            updatedOSCAR.Storage_performed__c = Date.today();

        if (oldOSCAR.Welcome_call__c == false && updatedOscar.Welcome_call__c == true)
            updatedOSCAR.Welcome_call_performed__c = Date.today();

        if (oldOSCAR.Issue_disapproval_pack__c == false && updatedOscar.Issue_disapproval_pack__c == true)
            updatedOSCAR.Disapproval_pack_sent__c = Date.today();

        if (oldOSCAR.Issue_credit_note_if_applicable__c == false && updatedOscar.Issue_credit_note_if_applicable__c == true)
            updatedOSCAR.Fees_refund_requested__c = Date.today();

        if (oldOSCAR.Release_FS_if_applicable__c == false && updatedOscar.Release_FS_if_applicable__c == true)
            updatedOSCAR.Financial_Security_released__c = Date.today();

        if (oldOSCAR.Issue_Withdrawal_notification__c == false && updatedOscar.Issue_Withdrawal_notification__c == true)
            updatedOSCAR.Withdrawal_notification_sent__c = Date.today();

        if (oldOSCAR.Issue_credit_note_withdrawal__c == false && updatedOscar.Issue_credit_note_withdrawal__c == true)
            updatedOSCAR.Fees_refunds_requested_withdrawal__c = Date.today();

        if (oldOSCAR.Release_FS_withdrawal__c == false && updatedOscar.Release_FS_withdrawal__c == true)
            updatedOSCAR.Financial_Security_released_withdrawal__c = Date.today();

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
        if (oldOSCAR.RPM_Approval__c <> updatedOscar.RPM_Approval__c && updatedOscar.RPM_Approval__c != 'Authorize Disapproval' && updatedOscar.RPM_Approval__c != 'Authorize Approval') {
            // Reject the Approval Process from the Manager's perspective
            List<Id> currentApprovals = AMS_OSCAR_ApprovalHelper.getAllApprovals(new List<Id> {updatedOscar.Id});
            if (currentApprovals.size() > 0) {
                AMS_OSCAR_ApprovalHelper.processForObject('Reject', updatedOscar.Id, null, 'Automated rejection based on Manager disapproval with comments: ' + updatedOscar.Comments_approval__c);
            }
            updatedOSCAR.STEP2__c = 'Failed';
        }

        if (oldOSCAR.Bank_Guarantee_amount__c == null && updatedOscar.Bank_Guarantee_amount__c != null)
            updatedOSCAR.STEP12__c = 'In Progress';

        if (oldOSCAR.Update_IRIS_processing__c == false && updatedOscar.Update_IRIS_processing__c == true)
            updatedOSCAR.IRIS_updated_processing__c = Date.today();

        if (oldOSCAR.Confirm_DD_setup_with_R_S__c == false && updatedOscar.Confirm_DD_setup_with_R_S__c == true)
            updatedOSCAR.DD_setup_with_R_S_confirmed__c = Date.today();

        if (oldOSCAR.Confirm_DD_setup_with_agent__c == false && updatedOscar.Confirm_DD_setup_with_agent__c == true)
            updatedOSCAR.DD_setup_with_agent_confirmed__c = Date.today();

        if (oldOSCAR.Confirm_DGR_DGA__c == false && updatedOscar.Confirm_DGR_DGA__c == true)
            updatedOSCAR.DGR_DGA_confirmed__c = Date.today();

        if (oldOSCAR.Issue_rejection_notification_pack__c == false && updatedOscar.Issue_rejection_notification_pack__c == true)
            updatedOSCAR.Rejection_notification_sent__c = Date.today();

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
            updatedOscar.STEP15__c = updatedOscar.Validation_Status__c;
        }
        if (oldOSCAR.Issue_billing_document__c == false && updatedOscar.Issue_billing_document__c == true)
            updatedOSCAR.Process_Start_Date__c = Date.today();

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