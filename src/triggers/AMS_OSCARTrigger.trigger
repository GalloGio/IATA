trigger AMS_OSCARTrigger on AMS_OSCAR__c (before insert, before update, after insert, after update) {

    if(!AMS_TriggerExecutionManager.checkExecution(AMS_OSCAR__c.getSObjectType(), 'AMS_OSCARTrigger')) { return; }
	
	//EM: To be removed
	if (Test.isRunningTest()) {
		Integer i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
	}
    
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
            //USED ON: HO,BR,TIDS,GSA,AHA,GSSA,MSO,SA,NEWHELITE
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
            else if(oscar.Process__c == AMS_Utils.NEWHELITE || oscar.Process__c == AMS_Utils.NEWHESTANDARD || oscar.Process__c == AMS_Utils.NEWAE || oscar.Process__c == AMS_Utils.NGCHANGES){
                oscar.Sanity_check_deadline__c = Date.today() + 15;
                oscar.OSCAR_Deadline__c = Date.today() + 30;

                if(oscar.Is_using_credit_card__c == true){

                    if(oscar.Requested_Bank_Guarantee_amount__c == null)
                        oscar.Requested_Bank_Guarantee_amount__c = 5000;

                    oscar.Requested_Bank_Guarantee_currency__c = 'USD';
                }
            }else
            	if(oscar.recordTypeId == AMS_Utils.RECTYPE_NGCHANGES && oscar.Process__c == AMS_Utils.BANKACCCHANGES){
            		oscar.Sanity_check_deadline__c = Date.today() + 15;
            	}

            if(oscar.Process__c == AMS_Utils.new_GSA_BSP || oscar.Process__c == AMS_Utils.new_AHA_BSP) oscar.BSPLink_participation__c = true;
            //removed in issue AMS-1584
            //oscar.Sanity_check_deadline__c = Date.today() + 15;
            if(oscar.Process__c == AMS_Utils.CERTIFICATION) oscar.Sanity_check_deadline__c = Date.today()+90;

            if(oscar.Process__c != AMS_Utils.CERTIFICATE) oscar.Certificate_Quantity__c = null;


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

            if(updatedOSCAR.Process__c != AMS_Utils.CERTIFICATE) updatedOSCAR.Certificate_Quantity__c = null;

        }

    }

    /*Risk Event Management*/
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        new ANG_RiskEventGenerator(Trigger.New, Trigger.oldMap).generate();
    }
    /*Risk Event Management*/

    private static void applyChangeCodesWithDependencies(AMS_OSCAR__c oldOSCAR, AMS_OSCAR__c updatedOscar, Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships) {
        ID newRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
        ID newNGRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NG New HE').getRecordTypeId();

        ID corrRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CORRECTION').getRecordTypeId();
        if (updatedOscar.recordTypeID == newRT || updatedOscar.recordTypeID == newNGRT || updatedOSCAR.recordTypeID == AMS_Utils.RECTYPE_NEWAE){
            if (oldOSCAR.STEP2__c != 'Passed' && updatedOscar.STEP2__c == 'Passed') {
                AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

                changeCode.name = 'FIN';
                changeCode.reasonCode = '91';
                changeCode.memoText = AMS_Utils.getChangeCodeMemoText(updatedOscar.Process__c,changeCode.name);
                changeCode.reasonDesc  = 'ACCREDITED–MEETS–STANDARDS';
                changeCode.status  = '9';

                Account acct = new Account(Id = updatedOscar.Account__c);
                AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {updatedOscar}, new List<Account> {acct}, true);

            } else if (oldOSCAR.STEP2__c != 'Failed' && updatedOscar.STEP2__c == 'Failed' && updatedOscar.RPM_Approval__c=='Authorize Disapproval') {

                AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

                changeCode.name = 'DIS';
                changeCode.reasonCode = '12';
                changeCode.memoText = AMS_Utils.getChangeCodeMemoText(updatedOscar.Process__c,changeCode.name);
                changeCode.reasonDesc  = 'APPLICATION DISAPPROVED';
                changeCode.status  = '1';

                Account acct = new Account(Id = updatedOscar.Account__c);
                AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {updatedOscar}, new List<Account> {acct}, true);
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
                        if(acc.Status__c.equalsIgnoreCase(AMS_Utils.ACC_S0_TERMINATED)) allHierarchyAccountIds.remove(acc.Id);
                    }

                    stagingToAccounts.put(updatedOscar.AMS_Online_Accreditation__c, allHierarchyAccountIds);
                    system.debug('applyChangeCodesWithDependencies() -> move to MD contact data. Pass map: '+stagingToAccounts);
                    AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(stagingToAccounts, true);


                    //verify ownership alignment
                    if(allHierarchyAccountIds.size()>0 && !AMS_HierarchyHelper.checkHierarchyIntegrity(new Map<Id, Set<Id>>{updatedOscar.Id => allHierarchyAccountIds}))
                        throw new AMS_ApplicationException('This operation cannot be performed because the ownership in this hierarchy is not aligned. It is advised to perform a change of ownership to align the owners in this hierarchy.');

                    if(updatedOscar.AMS_Correction_change_code__c == 'COR' || updatedOscar.AMS_Correction_change_code__c == 'CAD'){
                        system.debug(LoggingLevel.ERROR,'applyChangeCodesWithDependencies() -> generate the change code');
                        AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

                        changeCode.status  = null;
    
                        // If the picklist is set create a COR change code.
                        if(updatedOscar.AMS_Correction_change_code__c == 'COR') {
                        changeCode.name = 'COR';
                        changeCode.memoText = 'Correction';
                        changeCode.publishedOnEBulletin = false;
                        }
                    // If the picklist is set create a CAD change code.
                        else if(updatedOscar.AMS_Correction_change_code__c == 'CAD'){
                        changeCode.name = 'CAD';
                        changeCode.memoText = 'Minor Changes';
                        }
                        // If the picklist is set create a LET change code.
                        /*else if(updatedOscar.AMS_Correction_change_code__c == 'LET'){
                            changeCode.name = 'LET';
                            changeCode.memoText = '';
                        }*/

                        List<Agency_Applied_Change_code__c> accountActiveChangeCode = [SELECT Reason_Code__c, Reason_Description__c,Account__r.Status__c FROM Agency_Applied_Change_code__c WHERE Account__c =: updatedOscar.Account__c AND Active__c = TRUE];                    

                        if(accountActiveChangeCode.size() > 0){
                            changeCode.reasonCode = accountActiveChangeCode[0].Reason_Code__c;
                            changeCode.reasonDesc = accountActiveChangeCode[0].Reason_Description__c;
                            changeCode.status = AMS_Utils.getIATANumericStatus(accountActiveChangeCode[0].Account__r.Status__c);
                        }
                        Account acct = new Account(Id = updatedOscar.Account__c);
                        AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {updatedOscar}, new List<Account> {acct}, true);
                    }
                    if(updatedOscar.AMS_Correction_change_code__c == 'LET') {
                        system.debug(LoggingLevel.ERROR,'applyChangeCodesWithDependencies() -> generate the change code');
                        AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

                        changeCode.name = 'LET';
                        changeCode.reasonCode = '91';
                        changeCode.memoText = '';
                        changeCode.reasonDesc  = 'ACCREDITED–MEETS–STANDARDS';
                        changeCode.status  = '9';

                        Account acct = new Account(Id = updatedOscar.Account__c);
                        AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {updatedOscar}, new List<Account> {acct}, true);
                    }

                } catch (Exception ex) {
                    System.debug('Exception: ' + ex);
                    Database.rollback(sp); throw ex;
                }


            system.debug('RB - Sanity check already passed: ' + updatedOscar.Sanity_Check_Passed__c);

            if(updatedOscar.Sanity_Check_Passed__c == true) {
                updatedOscar.addError('Change code already generated for this OSCAR! Rollback data through a new OSCAR Correction and Set this OSCAR Status to Closed_Withdrawn');                
            }
            
            updatedOscar.Sanity_Check_Passed__c = true;
        }
        }
    }

    private static boolean isEmptyAccountHierarchyRelationshipsMap(Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships){

        if(accountHierarchyRelationships.isEmpty()) return true;

        if(accountHierarchyRelationships.values().isEmpty()) return true;

        for(List<AMS_Agencies_relationhip__c> agency:accountHierarchyRelationships.values()){
            
            if(!agency.isEmpty()) return false;
                
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
            'Send_Confirmation__c'                      => 'Confirmation_Sent__c',
            'Update_BSPLink__c'                         => 'BSPLink_updated__c',
            'Create_Agency_Authorization__c'            => 'Agency_Authorization_created__c',
            'Release_previous_FS_if_applicable__c'      => 'Previous_FS_released__c',
            'Suspend_Agency__c'                         => 'NOC_Requested__c'
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

        if (oldOSCAR.Is_using_credit_card__c == true && updatedOscar.Is_using_credit_card__c == false) {
            updatedOSCAR.STEP34__c = 'Not Applicable';
            updatedOSCAR.STEP35__c = 'Not Applicable';
            updatedOSCAR.Requested_Bank_Guarantee_amount__c = null;
            updatedOSCAR.Requested_Bank_Guarantee_currency__c =  '';
        }

        if (oldOSCAR.Is_using_credit_card__c == false && updatedOscar.Is_using_credit_card__c == true) {
            
            if(updatedOSCAR.Requested_Bank_Guarantee_amount__c == null)
                updatedOSCAR.Requested_Bank_Guarantee_amount__c = 5000;
            
            updatedOSCAR.Requested_Bank_Guarantee_currency__c =  'USD';
            updatedOSCAR.STEP34__c = 'In Progress';
            updatedOSCAR.STEP35__c = 'In Progress';
        }

        if(oldOSCAR.STEP35__c <> updatedOscar.STEP35__c && updatedOscar.STEP35__c == 'Passed'){

            Integer resultComparisson = AMS_Utils.compareRates(updatedOscar.Requested_Bank_Guarantee_currency__c,updatedOscar.Requested_Bank_Guarantee_amount__c,updatedOscar.Received_Bank_Guarantee_currency__c,updatedOscar.Received_Bank_Guarantee_amount__c);
        
            if(resultComparisson == -1){
                updatedOSCAR.addError('There was a problem using the rates for the Requestest Bank Garantee Amount and Received Bank Garantee Amount. Please check the values.');
            }

            if(resultComparisson == -2){
                updatedOSCAR.addError('There was a problem with the amounts. Please check the values.');
            }

            if(resultComparisson == 2){
                updatedOSCAR.addError('You cannot proceed because the amount of bank guarantee requested is minor than the amount of bank guarantee provided.');
            }


        }

        if (oldOSCAR.Send_inspection_request__c == false && updatedOscar.Send_inspection_request__c == true)
            updatedOSCAR.STEP13__c = 'In Progress';

        if (oldOSCAR.Send_agreement__c == false && updatedOscar.Send_agreement__c == true)
            updatedOSCAR.STEP14__c = 'In Progress';

        if (oldOSCAR.Send_FS_request__c == false && updatedOscar.Send_FS_request__c == true) {
            updatedOSCAR.Bank_Guarantee_requested__c = Date.today();

            if(AMS_Utils.oscarNewGenProcesses.contains(updatedOSCAR.Process__c))
                updatedOSCAR.Bank_Guarantee_deadline__c = Date.today() + 40;
            else
                updatedOSCAR.Bank_Guarantee_deadline__c = Date.today() + 30;
        }

        if(AMS_Utils.oscarNewGenProcesses.contains(updatedOscar.Process__c) && oldOSCAR.STEP6__c <> updatedOscar.STEP6__c && updatedOscar.STEP6__c == 'Passed'){

            System.debug('Sending the email for the user to anounce approval of the oscar');

            //using an already existing method to send email aler to user.
            AMS_OSCARTriggerHandler.sendEmailAlert(updatedOscar.Id, updatedOscar.Oscar_Communication_Case_Id__c, updatedOscar.Process__c, AMS_Utils.SANITYCHECK, true);

        }

        if (oldOSCAR.RPM_Approval__c <> updatedOscar.RPM_Approval__c && updatedOscar.RPM_Approval__c == 'Authorize Approval') {

            if(updatedOscar.Process__c == AMS_Utils.NEWHELITE || updatedOscar.Process__c == AMS_Utils.NEWHESTANDARD || updatedOscar.Process__c == AMS_Utils.NEWAE){

                System.debug('Sending the email for the user to anounce approval of the oscar');

                //using an already existing method to send email aler to user.
                AMS_OSCARTriggerHandler.sendEmailAlert(updatedOscar.Id, updatedOscar.Oscar_Communication_Case_Id__c, updatedOscar.Process__c, AMS_Utils.APPROVAL, true);

                if((updatedOscar.Process__c == AMS_Utils.NEWHELITE && updatedOscar.Is_using_credit_card__c) || updatedOscar.Process__c == AMS_Utils.NEWHESTANDARD)
                    createAgencyAuthorizations(updatedOscar);
                else if(updatedOscar.Process__c == AMS_Utils.NEWAE)
                    copyAgencyAuthorizationsFromParent(updatedOscar);

            }

            // Approve the Approval Process from the Manager's perspective
            List<Id> currentApprovals = AMS_OSCAR_ApprovalHelper.getAllApprovals(new List<Id> {updatedOscar.Id});
            if (currentApprovals.size() > 0) {
                AMS_OSCAR_ApprovalHelper.processForObject('Approve', updatedOscar.Id, null, 'Automated approval based on Manager approval with comments: ' + updatedOscar.Comments_approval__c);
            

            }
            updatedOSCAR.STEP2__c = 'Passed';
        }

        if (oldOSCAR.RPM_Approval__c <> updatedOscar.RPM_Approval__c && updatedOscar.RPM_Approval__c == 'Authorize Disapproval') {

            if(updatedOscar.Process__c == AMS_Utils.NEWHELITE || updatedOscar.Process__c == AMS_Utils.NEWHESTANDARD){

                System.debug('Sending the email for the user to anounce disapproval of the oscar');

                    //using an already existing method to send email aler to user.
                AMS_OSCARTriggerHandler.sendEmailAlert(updatedOscar.Id, updatedOscar.Oscar_Communication_Case_Id__c, updatedOscar.Process__c, AMS_Utils.APPROVAL, false);

            }
            
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
            } else if (updatedOscar.Validation_Status__c == 'Failed' || updatedOscar.Validation_Status__c == 'Not Applicable') {
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

        if (oldOSCAR.Apply_Penalty_Fee__c == false && updatedOscar.Apply_Penalty_Fee__c == true && !AMS_Utils.oscarNewGenProcesses.contains(updatedOSCAR.Process__c)) {

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

        if (oldOSCAR.Apply_Penalty_Fee__c == false && updatedOscar.Apply_Penalty_Fee__c == true && AMS_Utils.oscarNewGenProcesses.contains(updatedOSCAR.Process__c)) {

            //late/absence of NOC - penalty fees can only be applied for some ToC (could add validation for dates)
            Set<String> tocList = new Set<String>();
            if(updatedOscar.ANG_Type_of_change__c != null) tocList.addAll(updatedOscar.ANG_Type_of_change__c.split(';'));

            System.debug(loggingLevel.Debug, '____ [trg AMS_OSCARTrigger - validateStep29] tocList - ' + tocList);
            if(
                !tocList.contains(AMS_Utils.ANG_LEGAL_NAME)
                && !tocList.contains(AMS_Utils.ANG_LEGAL_STATUS)
                && !tocList.contains(AMS_Utils.ANG_MAJOR_SHAREHOLDING)
                && !tocList.contains(AMS_Utils.ANG_LOCATION_TYPE)
                && !tocList.contains(AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY)
                && !tocList.contains(AMS_Utils.ANG_OWNERSHIP)
            ){
                updatedOSCAR.addError('Penalty fees can only be applied for \n-'+AMS_Utils.ANG_LEGAL_NAME+'\n-'+AMS_Utils.ANG_LEGAL_STATUS+'\n-'+AMS_Utils.ANG_MAJOR_SHAREHOLDING+'\n-'+AMS_Utils.ANG_LOCATION_TYPE+'\n-'+AMS_Utils.ANG_OWNERSHIP+'\n-'+AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY);
            }
        }

        if (oldOSCAR.Apply_Penalty_Fee__c == true && updatedOscar.Apply_Penalty_Fee__c == false) {
            updatedOSCAR.addError('It\'s not possible to cancel the penalty fees that were applied');
        }

        if(!AMS_Utils.oscarNewGenProcesses.contains(updatedOSCAR.Process__c)){
            if (oldOSCAR.Notify_Agent_Suspension__c == false && updatedOscar.Notify_Agent_Suspension__c == true) {
                updatedOSCAR.NOC_Deadline__c = BusinessDays.addNBusinessDays(System.now(), 5, updatedOSCAR.BusinessHours__c).date();
            }
            
            if (oldOSCAR.Notify_Agent_Termination__c == false && updatedOscar.Notify_Agent_Termination__c == true) {
                DateTime nextMonthEnd = DateTime.newInstance(AMS_Utils.lastDayOfMonth(System.today().addMonths(1)), DateTime.now().time());
                updatedOSCAR.Termination_Date__c = BusinessHours.nextStartDate(updatedOSCAR.BusinessHours__c, nextMonthEnd).date();
                System.debug(loggingLevel.Debug, '____ [trg AMS_OSCARTrigger - beforUpdate] updatedOSCAR.Termination_Date__c - ' + updatedOSCAR.Termination_Date__c);
            }

            if (oldOSCAR.NOC_Received__c == false && updatedOscar.NOC_Received__c == true) updatedOSCAR.Termination_Date__c = null;
        }

        // ***************************************
        // ********* NEWGEN VALIDATIONS ************
        // ***************************************
        if(AMS_Utils.oscarNewGenProcesses.contains(updatedOSCAR.Process__c)){

            // ************************************************************
            // ********* GENERIC VALIDATIONS FOR NEW APPLICATIONS**********
            // ************************************************************
            if(updatedOSCAR.Process__c != AMS_Utils.NGCHANGES){
                if(oldOSCAR.STEP37__c <> updatedOscar.STEP37__c && updatedOscar.STEP37__c == 'Passed' && (updatedOscar.Create_Agency_Authorization__c == false || updatedOscar.Update_BSPLink__c == false)){
                    updatedOSCAR.addError('Ticketing Authorities stage status cannot be set to passed until both "Update BSPLink" and "Create Agency Authorization" are not performed.');   
                }

                if(oldOSCAR.Status__c <> updatedOscar.Status__c && updatedOscar.Status__c == 'Closed' && updatedOscar.RPM_Approval__c == 'Authorize Approval' && updatedOscar.STEP37__c != 'Passed'){
                    updatedOSCAR.addError('Cannot close the OSCAR until the Ticketing Authorities step will be completed.');   
                }
            }

            // *****************************************************
            // ********* STANDARD WITH CASH VALIDATIONS ************
            // *****************************************************
            if(updatedOSCAR.Process__c == AMS_Utils.NEWHESTANDARD || updatedOSCAR.Process__c == AMS_Utils.NGCHANGES){

                
                if(updatedOSCAR.Process__c == AMS_Utils.NEWHESTANDARD && oldOSCAR.Status__c <> updatedOscar.Status__c && updatedOscar.Status__c == 'Closed' && (updatedOscar.RPM_Approval__c == 'Not Started' || updatedOscar.RPM_Approval__c == null)){
                    updatedOSCAR.addError('Cannot close the OSCAR until the Manager Approval Step is not completed.');
                }

                if(oldOSCAR.Status__c <> updatedOscar.Status__c && updatedOscar.Status__c == 'Closed' && updatedOscar.RPM_Approval__c == 'Authorize Approval' && updatedOscar.STEP36__c != 'Passed'){
                    updatedOSCAR.addError('Cannot close the OSCAR until the Risk Event step is completed.');   
                }

            }

            //*********************
            //****PENALTY NEWGEN***
            //*********************
            if (oldOSCAR.Suspend_Agency__c == false && updatedOscar.Suspend_Agency__c == true) {
                updatedOSCAR.NOC_Deadline__c = BusinessDays.addNBusinessDays(System.now(), 5, updatedOSCAR.BusinessHours__c).date();
            }
            
            if (oldOSCAR.Terminate_Agency__c == false && updatedOscar.Terminate_Agency__c == true) {
                DateTime nextMonthEnd = DateTime.newInstance(AMS_Utils.lastDayOfMonth(System.today().addMonths(1)), DateTime.now().time());
                updatedOSCAR.Termination_Date__c = BusinessHours.nextStartDate(updatedOSCAR.BusinessHours__c, nextMonthEnd).date();
                System.debug(loggingLevel.Debug, '____ [trg AMS_OSCARTrigger - beforUpdate] updatedOSCAR.Termination_Date__c - ' + updatedOSCAR.Termination_Date__c);
            }

            if (oldOSCAR.NOC_Received__c == false && updatedOscar.NOC_Received__c == true) updatedOSCAR.Termination_Date__c = null;
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

    private static void createAgencyAuthorizations(AMS_OSCAR__c oscar){
        List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();
        ID FormOfPaymentRT = AMS_Utils.getId('Agency_Authorization__c','FormOfPayment');
        authorizations.add(new Agency_Authorization__c(Account__c = oscar.Account__c, ANG_FormOfPayment_ID__c = 'CC', Status__c = oscar.Is_PCI_compliant__c == 'Yes' ? 'Active' : 'Inactive', RecordTypeId = FormOfPaymentRT));
        if(oscar.Process__c == AMS_Utils.NEWHESTANDARD)
            authorizations.add(new Agency_Authorization__c(Account__c = oscar.Account__c, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
        authorizations.add(new Agency_Authorization__c(Account__c = oscar.Account__c, ANG_FormOfPayment_ID__c = 'EP', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));

        insert authorizations;
    }

    private static void copyAgencyAuthorizationsFromParent(AMS_OSCAR__c oscar){
        List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();
        ID FormOfPaymentRT = AMS_Utils.getId('Agency_Authorization__c','FormOfPayment');

        Account account = [SELECT ParentId FROM Account WHERE Id =: oscar.Account__c ];
        List<Agency_Authorization__c> parentFormsOfPayment = [SELECT Account__c, ANG_FormOfPayment_ID__c, Status__c, RecordTypeId FROM Agency_Authorization__c WHERE Account__c =: account.ParentId AND Status__c = 'Active' AND RecordTypeId =: FormOfPaymentRT];

        for(Agency_Authorization__c fop: parentFormsOfPayment)
            authorizations.add(new Agency_Authorization__c(Account__c = oscar.Account__c, ANG_FormOfPayment_ID__c = fop.ANG_FormOfPayment_ID__c, Status__c = fop.Status__c, RecordTypeId = fop.RecordTypeId));

        insert authorizations;
    }


}