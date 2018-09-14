public class AMS_OSCARTriggerHandler {

    //*************************************
    //************ variables **************
    //*************************************

    class AMSException extends Exception {}
    
    private static ID rtAgencyInvolved = Schema.SObjectType.AMS_Process_Detail__c.getRecordTypeInfosByName().get('Agency Involved').getRecordTypeId();

    //used to identify situations where the LocationType of an SA Agency should not be changed
    public static Boolean keepSALocationTypeFlag = false;

    public static Map<String, String> closedStatusMapping{
        get{
            if(closedStatusMapping == null){
                closedStatusMapping = new Map<String, String>{
                    'Closed (Closed)' => 'Closed',
                    'Closed_Not Accepted' => 'Closed_ Not Accepted',
                    'Closed_Rejected' => 'Closed_Rejected',
                    'Closed_Withrawn' => 'Closed_Withdrawn'
                };
            }
            return closedStatusMapping;
        }
        set;
    }


    public static Map<String, String> oscarExternalLabels {
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
                'STEP9__c' => System.Label.AMS_OSCAR_STEP9,
                'STEP41__c' => System.Label.AMS_OSCAR_STEP41,
                'STEP42__c' => System.Label.AMS_OSCAR_STEP42
            };
        }
        set;
    }

    /*** AMSU-113 Start ***/
    public static Set<String> pciCompliantProcesses {
        get {
            return new Set<String> {AMS_Utils.new_HO, AMS_Utils.new_BR, AMS_Utils.new_BR_ABROAD, AMS_Utils.PCI_COMPLIANT};
        }
        set;
    }
    /*** AMSU-113 End ***/

    /*** AMSU-121 Start ***/
    public static Map<Id, AMS_Pax_Accreditation_Form__c> allOnlineAccr {get;set;}
    public static Map<Id, AMS_Pax_Accreditation_Form__c> getAllAccreditations(List<AMS_OSCAR__c> oscars) {
        Set<Id> onlineAccreditaionsIds = new Set<Id>();
        for(AMS_OSCAR__c oscar : oscars) {
            if(oscar.AMS_Online_Accreditation__c != null) {
                onlineAccreditaionsIds.add(oscar.AMS_Online_Accreditation__c);
            }
        }

        if(!onlineAccreditaionsIds.isEmpty()) {
            return getAccreditations(onlineAccreditaionsIds);
        }

        return new Map<Id, AMS_Pax_Accreditation_Form__c>();
    }

    public static Map<Id, AMS_Pax_Accreditation_Form__c> getAccreditations2(Set<Id> accreditationsIds, Map<Id, AMS_Pax_Accreditation_Form__c> accreditations) {
        Map<Id, AMS_Pax_Accreditation_Form__c> res = new Map<Id, AMS_Pax_Accreditation_Form__c>();

        for(Id accreditationId : accreditationsIds) {
            AMS_Pax_Accreditation_Form__c accreditation = accreditations.get(accreditationId);
            if(accreditation != null) {
                res.put(accreditationId, accreditation);
            }
        }

        return res;
    }
    /*** AMSU-121 End ***/

    //*************************************
    //********* context methods ***********
    //*************************************

    public static void handleBeforeUpdate(List<AMS_OSCAR__c> oscars) {

        prepopulateValues();

        AMS_AccreditationContactHelper.mirrorAccrediationContactsFromAccountRole(oscars, (Map<Id,AMS_OSCAR__c>)Trigger.oldMap);

        //create agency regulation objects for Cargo agencies
        handleCargoAgencyRegulations();

        handleSanityCheckValidations(oscars, (Map<Id,AMS_OSCAR__c>)Trigger.oldMap);

        handleChangesProcess(oscars);

        ANG_AgencyChangesHelper.handleNewGenChangesProcess(oscars);

        copyDataFromTargetAgency();

        updateOSCARAppointments();

        handleVRProcess();

        checkOwnershipOnProcess(oscars, (Map<Id,AMS_OSCAR__c>)Trigger.oldMap);

        /*** AMSU-113 Start ***/
        processPCICompliant(Trigger.new, (Map<Id, AMS_OSCAR__c>) Trigger.oldMap);
        /*** AMSU-113 End ***/

        processGeneralActionsOnOscarBeforeUpdate((List<AMS_OSCAR__c>)Trigger.New, (Map<Id,AMS_OSCAR__c>)Trigger.oldMap);

        handleNewgenFOPActionsBeforeUpdate(oscars, (Map<Id,AMS_OSCAR__c>)Trigger.oldMap);

        updateAccountWithOptINOUT((List<AMS_OSCAR__c>)Trigger.New, (Map<Id,AMS_OSCAR__c>)Trigger.oldMap);
        
        /*** AMSU-125 Start ***/
        validateRemittanceFrequency((List<AMS_OSCAR__c>)Trigger.New, (Map<Id,AMS_OSCAR__c>)Trigger.oldMap, (Map<Id,AMS_OSCAR__c>)Trigger.newMap);
        /*** AMSU-125 End ***/

        handleAnnualRevalidation((List<AMS_OSCAR__c>)Trigger.New, (Map<Id,AMS_OSCAR__c>)Trigger.oldMap);
		
		//Newgen 13/09/2018: Temporary removed
		if(test.IsRunningTest())
			performBackupANG((Map<Id, AMS_OSCAR__c>) Trigger.oldMap, (Map<Id, AMS_OSCAR__c>) Trigger.newMap);


    }

    public static void handleBeforeInsert() {
        //assignOSCARToRegionalQueues();
        prepopulateValues();
        
        AMS_AccreditationContactHelper.mirrorAccrediationContactsFromAccountRole((List<AMS_OSCAR__c>)Trigger.New, null);
        
        copyDataFromTargetAgency();
    
        processGeneralActionsOnOscarBeforeInsert((List<AMS_OSCAR__c>)Trigger.New);
    }

    public static void handleAfterInsert() {
        /*** AMSU-134 Start ***/
        createSavepoint((List<AMS_OSCAR__c>) Trigger.new, null);
        /*** AMSU-134 End ***/

        updateCaseKPIFields();

        //Newgen 13/09/2018: Temporary removed
		if(test.IsRunningTest())
			performBackupANG((Map<Id, AMS_OSCAR__c>) Trigger.oldMap, (Map<Id, AMS_OSCAR__c>) Trigger.newMap);

    }

    public static void handleAfterUpdate() {

        updateCaseKPIFields();
        updateCaseInfo();
        createHoAdminNotifications();
        updateIfapForOptinOut();
        /*** AMSU-113 Start ***/
        updateAccountPCICompliant((List<AMS_OSCAR__c>) Trigger.new, (Map<Id, AMS_OSCAR__c>) Trigger.oldMap);
        /*** AMSU-113 End ***/
        /*** AMSU-121 Start ***/
        handleChangeOfLocation((List<AMS_OSCAR__c>) Trigger.new, (Map<Id, AMS_OSCAR__c>) Trigger.oldMap);
        /*** AMSU-121 End ***/
        /*** AMSU-134 Start ***/
        createSavepoint((List<AMS_OSCAR__c>) Trigger.new, (Map<Id, AMS_OSCAR__c>) Trigger.oldMap);
        rollbackChanges((List<AMS_OSCAR__c>) Trigger.new, (Map<Id, AMS_OSCAR__c>) Trigger.oldMap, (Map<Id, AMS_OSCAR__c>) Trigger.newMap);
        /*** AMSU-134 End ***/

        //Newgen 13/09/2018: Temporary removed
		if(test.IsRunningTest())
			performRollbackANG((Map<Id, AMS_OSCAR__c>) Trigger.oldMap, (Map<Id, AMS_OSCAR__c>) Trigger.newMap);

    }

    /*** AMSU-134 Start ***/
    public static void createSavepoint(List<AMS_OSCAR__c> oscars, Map<Id, AMS_OSCAR__c> oldMap) {
        Set<Id> oscarIds = new Set<Id>();
        for(AMS_Oscar__c oscar : oscars) {
            AMS_Oscar__c oldOscar = oldMap != null ? oldMap.get(oscar.Id) : null;
            Boolean isAgencyChange = oscar.Process__c == AMS_Utils.AGENCYCHANGES;
            Boolean hasTypeOfchange = (String.isNotBlank(oscar.Type_of_change__c) && oldOscar == null) || 
                (String.isNotBlank(oscar.Type_of_change__c) && oscar.Type_of_change__c <> oldOscar.Type_of_change__c);
            Boolean sanityCheckNotPassed = oscar.STEP6__c <> AMS_Utils.PASSED;
            if(isAgencyChange && hasTypeOfchange && sanityCheckNotPassed) {
                oscarIds.add(oscar.Id);
            }
        }

        if(!system.isBatch() && !system.isFuture() && !oscarIds.isEmpty()) {
            //AMS_OscarChangesHelper.createSavepoint(oscarIds);
            AMS_OSCAR_Savepoint oscarSavepoint = new AMS_OSCAR_Savepoint(oscars);
            System.enqueueJob(oscarSavepoint);
        }
    }

    public static void rollbackChanges(List<AMS_OSCAR__c> oscars, Map<Id,AMS_OSCAR__c> oldMap, Map<Id,AMS_OSCAR__c> newMap) {
        Set<Id> oscarIds = new Set<Id>();

        for(AMS_OSCAR__c oscar : oscars) {
            AMS_OSCAR__c oldOscar = oldMap.get(oscar.Id);
            if(oscar.Process__c == AMS_Utils.AGENCYCHANGES && oldOscar.STEP4__c != AMS_Utils.PASSED && oscar.STEP4__c == AMS_Utils.PASSED) {
                oscarIds.add(oscar.Id);
            }
        }   

        if(oscarIds.isEmpty()) {
            return;
        }

        List<Case> cases = [SELECT Id, Oscar__c, (SELECT Id FROM Cases WHERE IsClosed = false) FROM Case WHERE Oscar__c IN :oscarIds];
        for(Case cse : cases) {
            if(!cse.Cases.isEmpty()) {
                newMap.get(cse.OSCAR__c).addError('You cannot withdrawal a case with open related cases.');
                oscarIds.remove(cse.OSCAR__c);
            }
        }
        
        if(!oscarIds.isEmpty() && !system.isBatch() && !system.isFuture()) {
            AMS_OSCAR_Rollback rbk = new AMS_OSCAR_Rollback(oscars);
            rbk.rollbackOSCAR();
        }
    }
    /*** AMSU-134 End ***/

    /*** AMSU-125 Start ***/
    public static void validateRemittanceFrequency(List<AMS_OSCAR__c> oscars, Map<Id, AMS_OSCAR__c> oldMap, Map<Id, AMS_OSCAR__c> newMap) {
        List<AMS_Oscar__c> oscarsToValidate = new List<AMS_Oscar__c>();
        Map<String, Set<String>> mapClassAttributes = new Map<String, Set<String>>();
        Set<String> processToCheck = new Set<String> {AMS_Utils.new_HO, AMS_Utils.new_BR, AMS_Utils.new_SA};


        for(AMS_Oscar__c oscar : oscars) {
            AMS_Oscar__c oldRecord = oldMap.get(oscar.Id);
            if(processToCheck.contains(oscar.Process__c) && oldRecord.RPM_Approval__c <> oscar.RPM_Approval__c && 
                oscar.RPM_Approval__c == 'Authorize Approval' && 
                oscar.AMS_Online_Accreditation__c != null && !String.isBlank(oscar.Country_ISO_Code__c)) {
                oscarsToValidate.add(oscar);
                mapClassAttributes.put(oscar.Country_ISO_Code__c, null);
            }
        }

        Schema.RecordTypeInfo assessmentRT = Schema.SObjectType.AMS_Settlement_System__c.getRecordTypeInfosByName().get('BSP');
        Set<String> locationsToCheck = new Set<String> {'P', 'D'};
        if(!oscarsToValidate.isEmpty() && assessmentRT != null) {
            List<AMS_Operation__c> operations = [SELECT Id, Name, Country__c, Country__r.ISO_Code__c,
                                                    (SELECT Class_Type__c FROM BSP_Attributes__r WHERE Class_Type__c IN :locationsToCheck) 
                                                 FROM AMS_Operation__c
                                                 WHERE Country__r.ISO_Code__c IN :mapClassAttributes.keySet() AND 
                                                    Settlement__r.RecordtypeId = :assessmentRT.getRecordTypeId()]; 

            for(AMS_Operation__c operation : operations) {
                for(ANG_BSP_Attributes__c attribute : operation.BSP_Attributes__r) {
                    Set<String> locations = mapClassAttributes.get(operation.Country__r.ISO_Code__c);

                    if(locations == null) {
                        locations = new Set<String>();
                        mapClassAttributes.put(operation.Country__r.ISO_Code__c, locations);
                    }

                    locations.add(attribute.Class_Type__c);
                }
            }

            List<AMS_Oscar__c> oscarsWithAccr = [SELECT Id, AMS_Online_Accreditation__c, AMS_Online_Accreditation__r.Remittance_frequency__c,
                                                        AMS_Online_Accreditation__r.Location_Class__c, Country_ISO_Code__c 
                                                 FROM AMS_Oscar__c
                                                 WHERE Id IN :oscarsToValidate AND 
                                                       AMS_Online_Accreditation__r.Remittance_frequency__c = NULL AND
                                                       AMS_Online_Accreditation__r.Location_Class__c IN :locationsToCheck];
            
            for(AMS_Oscar__c oscarsRF : oscarsWithAccr) {
                Set<String> countryAttributes = mapClassAttributes.get(oscarsRF.Country_ISO_Code__c);
                if(countryAttributes != null && !countryAttributes.isEmpty()) {
                    newMap.get(oscarsRF.Id).addError('The OSCAR cannot be approved until the remittance frequency is populated.');
                }
            }   


        }        
    }
    /*** AMSU-125 End ***/
    
    /*** AMSU-121 Start ***/
    public static void handleChangeOfLocation(List<AMS_OSCAR__c> oscars, Map<Id,AMS_OSCAR__c> oldMap) {
        List<AMS_Pax_Accreditation_Form__c> accreditationsToUpdate = new List<AMS_Pax_Accreditation_Form__c>();
        Id changeRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();

        for(AMS_OSCAR__c oscar : oscars) {
            if(String.isBlank(oscar.Type_of_change__c)) {
                continue;
            }

            AMS_OSCAR__c oldOscar = oldMap.get(oscar.Id);
            Boolean prevIsChangeOfLocation = String.isBlank(oldOscar.Type_of_change__c) ? false : new Set<String>(oldOscar.Type_of_change__c.split(';')).contains(AMS_Utils.Location);
            Boolean currIsChangeOfLocation = new Set<String>(oscar.Type_of_change__c.split(';')).contains(AMS_Utils.Location);


            if(!prevIsChangeOfLocation && currIsChangeOfLocation && oscar.RecordTypeId == changeRT) {
                AMS_Pax_Accreditation_Form__c accreditation = new AMS_Pax_Accreditation_Form__c(Id = oscar.AMS_Online_Accreditation__c);
                accreditation.Shipping_Street__c = null;
                accreditation.Shipping_City__c = null;
                accreditation.Shipping_State__c = null;
                accreditation.Shipping_Country__c = null;
                accreditation.Shipping_Postal_Code__c = null;
                accreditation.Shipping_ISO_State__c = null;
                accreditation.Shipping_ISO_Country__c = null;
                accreditationsToUpdate.add(accreditation);
            }
        }

        if(!accreditationsToUpdate.isEmpty()) {
            update accreditationsToUpdate;
        }
    }
    /*** AMSU-121 End ***/

    /*** AMSU-113 Start ***/
    public static void processPCICompliant(List<AMS_OSCAR__c> oscars, Map<Id,AMS_OSCAR__c> oldMap) {
        System.debug('processPCICompliant - start ' );
        Set<String> locations = new Set<String> {'P', 'D'};//AMSU-157
        for(AMS_Oscar__c oscar : oscars) {
            AMS_Oscar__c oldOscar = oldMap.get(oscar.Id);
            if(!String.isBlank(oscar.Account__c) && pciCompliantProcesses.contains(oscar.Process__c) && locations.contains(oscar.Location_Class__c) && oldOscar.STEP6__c != oscar.STEP6__c && oscar.STEP6__c == AMS_Utils.PASSED && oscar.Is_PCI_compliant__c == 'No') {
                oscar.Change_Code__c = 'PCI';
                System.debug('processPCICompliant - oscar: ' + oscar);
            }
        }
    } 

    public static void updateAccountPCICompliant(List<AMS_OSCAR__c> oscars, Map<Id, AMS_OSCAR__c> oldMap) {
        Map<Id, String> mapExpiryDates = new Map<Id,String>();
        Set<String> locations = new Set<String> {'P', 'D'};//AMSU-157
        for(AMS_Oscar__c oscar : oscars) {
            AMS_OSCAR__c oldOscar = oldMap.get(oscar.id);
            if(!String.isBlank(oscar.Account__c) && pciCompliantProcesses.contains(oscar.Process__c) && locations.contains(oscar.Location_Class__c) && oldOscar.STEP6__c != oscar.STEP6__c && oscar.STEP6__c == AMS_Utils.PASSED) {
                //if(oscar.Is_PCI_compliant__c == 'Yes' || oscar.Is_PCI_compliant__c == 'Nil CC') {
                if(AMS_Utils.oscarPCICompliantValidationExpiryDate.contains(oscar.Is_PCI_compliant__c) ) {
                    mapExpiryDates.put(oscar.Account__c, oscar.ANG_PCI_compliance_expiry_date__c + ',' + oscar.Is_PCI_compliant__c);
                }else 
                //if(oscar.Is_PCI_compliant__c == 'No' || oscar.Is_PCI_compliant__c == 'Corporate Card') {
                if(oscar.Is_PCI_compliant__c != null && oscar.Is_PCI_compliant__c != '' && !AMS_Utils.oscarPCICompliantValidationExpiryDate.contains(oscar.Is_PCI_compliant__c) ) {    
                    mapExpiryDates.put(oscar.Account__c,  'empty,' + oscar.Is_PCI_compliant__c);
                }
            }
        }

        if(!mapExpiryDates.isEmpty()) {
            asyncUpdateAccPCI(mapExpiryDates);
        }
    }

    @future
    public static void asyncUpdateAccPCI(Map<Id, String> mapValues) {
        List<Account> accounts = new List<Account>();
        for(Id accountId : mapValues.keySet()) {
            List<String> values = mapValues.get(accountId).split(',');
            accounts.add(new Account(Id= accountId, 
                                     ANG_PCI_compliance_expiry_date__c= values[0]=='empty'?null:Date.valueOf(values[0]), 
                                     Is_PCI_compliant__c= (String) values[1],
                                     PCI_DSS_Compliant__c= null));
        }

        update accounts;
    }

    /*** AMSU-113 End ***/

    private static void processGeneralActionsOnOscarBeforeUpdate(List<AMS_OSCAR__c> oscarsToInsert, Map<Id,AMS_OSCAR__c> oldOscars){

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

        Set<Id> oscarAccountIds = new Set<Id>();

        for (AMS_OSCAR__c oscar : oscarsToInsert){
            oscarAccountIds.add(oscar.Account__c);
            addAccountId(oscar.Account__c);
        }

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

        /*** AMSU-31 Start ***/
        Set<AMS_Oscar__c> oscarsToCreateAuth = new Set<AMS_Oscar__c>();
        /*** AMSU-31 End ***/
        for (AMS_OSCAR__c updatedOSCAR : oscarsToInsert) {
            AMS_OSCAR__c oldOSCAR = oldOscars.get(updatedOSCAR.Id);

            applyAccreditationProcessLogic(oldOSCAR, updatedOscar);

            if(!ProcessesToIgnoreChangeCode.contains(updatedOscar.Process__c))
                applyChangeCodesWithDependencies(oldOSCAR, updatedOscar, oscarAccountIds, oscarsToCreateAuth);


            processFieldsTracking(oldOSCAR, updatedOscar);

            //check for each OSCAR which steps were changed
            for (String step : stepsOSCAR) {

                if(step == 'STEP20'){
                    System.debug('New Value:'+updatedOSCAR.get(step + '__c'));
                    System.debug('Old_Value__c:'+oldOSCAR.get(step + '__c'));

                }

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

        /*** AMSU-31 Start ***/
        if(!oscarsToCreateAuth.isEmpty()) {
            List<Case> cases = [SELECT Id, CaseNumber, OSCAR__c, OSCAR__r.Name, Oscar__r.Account__c, Contact.Email FROM Case WHERE OSCAR__c IN :oscarsToCreateAuth];
            List<Agency_Authorization__c> agenciesAuth = new List<Agency_Authorization__c>(); 
            for(Case cse : cases) {
                if(cse.CaseNumber != cse.OSCAR__r.Name) {
                    continue;
                }
                Agency_Authorization__c agencyAuth = new Agency_Authorization__c(Account__c= cse.OSCAR__r.Account__c, Email_Used_for_BSP_Creation__c= cse.Contact.Email, Status__c = 'Active');
                agenciesAuth.add(agencyAuth);
            }

            if(!agenciesAuth.isEmpty()) {
                insert agenciesAuth;
            }
        }
        /*** AMSU-31 Start ***/

    }

    private static void processGeneralActionsOnOscarBeforeInsert(List<AMS_OSCAR__c> oscarsToInsert){

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

        List<AMS_OSCAR__c> oscars = new List<AMS_OSCAR__c>();

        /*** AMSU-37 ***/
        Set<Id> accountIds = new Set<Id>();
        Set<String> reasonsToCheck = new Set<String> {AMS_Utils.APP_DISAPPROVED, AMS_Utils.APP_WITHDRAWN};
        Set<Id> accountIdsToSkip = new Set<Id>();
        for(AMS_OSCAR__c oscar : oscarsToInsert) {
            if(reasonsToCheck.contains(oscar.Account_Reason__c)) {
                accountIds.add(oscar.Account__c);
            }
        }

        if(!accountIds.isEmpty()) {
            Set<String> appliedChangeCodes = new Set<String> {'DIS', 'NWD'};
            for(Account acc : [SELECT Id, (SELECT Id FROM Agencies_Applied_Change_codes__r WHERE Active__c = true AND Change_Code__c IN :appliedChangeCodes) FROM Account WHERE Id IN :accountIds]) {
                if(!acc.Agencies_Applied_Change_codes__r.isEmpty()) {
                    accountIdsToSkip.add(acc.Id);
                }
            }
        }
        

        for (AMS_OSCAR__c oscar : oscarsToInsert) {
            //set default name if no case is attached to the oscar
            oscar.Name = 'Wait for OSCAR Communication Case to be attached';
            for (String step : stepsOSCAR) {

                if(oscar.get(step + '__c') != null)
                    continue;

                oscar.put(step + '__c', 'Not Started');
                //requirement to put iata code generator as passed if the account already as a iata code

                if (step == 'STEP10' && oscar.Flag_IATACode_Formula__c && !accountIdsToSkip.contains(oscar.Account__c)) {
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
                
            }else if (oscar.Process__c == AMS_Utils.NGANNUALREVAL){
                oscar.OSCAR_Deadline__c = Date.today() + 30;

            }else
                if((oscar.recordTypeId == AMS_Utils.RECTYPE_NGCHANGES || oscar.recordTypeId == AMS_Utils.RECTYPE_CHANGE) && oscar.Process__c == AMS_Utils.BANKACCCHANGES){
                    oscar.Sanity_check_deadline__c = Date.today() + 15;
                }

            if(oscar.Process__c == AMS_Utils.new_GSA_BSP || oscar.Process__c == AMS_Utils.new_AHA_BSP) oscar.BSPLink_participation__c = true;
            //removed in issue AMS-1584
            //oscar.Sanity_check_deadline__c = Date.today() + 15;
            if(oscar.Process__c == AMS_Utils.CERTIFICATION) oscar.Sanity_check_deadline__c = Date.today()+90;

            if(oscar.Process__c != AMS_Utils.CERTIFICATE) oscar.Certificate_Quantity__c = null;


            oscars.add(oscar);

        }

        if (!oscars.isEmpty()){}//deprecated AMS-1665//AMS_OscarCaseTriggerHelper.assignOscarToRegionQueue(oscars);

    }

    private static void copyDataFromTargetAgency(){

        List<AMS_Pax_Accreditation_Form__c> onlineAccredsToUpdate = new List<AMS_Pax_Accreditation_Form__c>();

        Set<Id> targetAccountsIds = new Set<Id>();
        Set<Id> oscarOnlineAccredIds = new Set<Id>();
        List<AMS_OSCAR__c> oscarsToProcess = new List<AMS_OSCAR__c>();

        for(AMS_OSCAR__c oscar: (List<AMS_OSCAR__c>)Trigger.New){
            if(oscar.AMS_Target_Agency__c != null && oscar.Type_of_change__c.containsIgnoreCase(AMS_Utils.OWNERSHIP_IATA)){
                AMS_OSCAR__c oldOscar;
                if(Trigger.isUpdate)
                    oldOscar = (AMS_OSCAR__c)Trigger.oldMap.get(oscar.Id);
                //Id oldTarget = oldOscar.AMS_Target_Agency__c;
                //Id currentTarget = oscar.AMS_Target_Agency__c;
                if(Trigger.isInsert || (Trigger.isUpdate && oscar.AMS_Target_Agency__c != oldOscar.AMS_Target_Agency__c)){
                    targetAccountsIds.add(oscar.AMS_Target_Agency__c);
                    oscarOnlineAccredIds.add(oscar.AMS_Online_Accreditation__c);
                    oscarsToProcess.add(oscar);
                }
            }
        }

        if(!oscarsToProcess.isEmpty()){

            Map<Id, Account> targetAccounts = new Map<Id, Account>([SELECT Name, IATACode__c, Company_Type__c, Short_Name__c, TradeName__c, License_Number__c, VAT_Number__c, GDS__c, Operation__c,
                    BillingCountry, BillingStreet, BillingPostalCode, BillingState, BillingCity, IATA_ISO_Country__c, Iso_State__c, ShippingCountry,
                    ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity, Email__c, Website, Phone, Fax, In_a_Airport__c, Abbreviated_name__c, Abbreviated_address__c,
                    Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c
                    ,IATA_ISO_Billing_State__c, IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_Country__r.Name, IATA_ISO_Shipping_State__c, IATA_ISO_Shipping_State__r.Name, ISO_State__r.Name FROM Account WHERE Id IN :targetAccountsIds]);


            Map<Id, AMS_Pax_Accreditation_Form__c> onlineAccreditations = new Map<Id, AMS_Pax_Accreditation_Form__c>([SELECT Account_Name__c, IATACode__c, ISSP_AMS_Legal_Status__c, Short_Name__c, Trade_Name__c, ISSP_AMS_License_No__c, ISSP_AMS_VAT_number__c,
                    ISSP_AMS_GDS_with_signed_contract__c, Operation__c, Branch_Office_Country__r.Name, Branch_Office_Street_name_number__c, Branch_Office_Postal_code__c,
                    Billing_State__c, Branch_Office_City__c, ISO_Country__c, IATA_ISO_State__c, Shipping_Country__c, Shipping_Street__c, Shipping_Postal_Code__c,
                    Shipping_State__c, Shipping_City__c, Branch_Office_Email__c, Website__c, Branch_Office_Phone__c, Branch_Office_FAX__c, ISSP_AMS_Premises_located_at_airport__c,
                    Abbreviated_name__c, Abbreviated_address__c, Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c
                    ,Shipping_ISO_Country__c,Shipping_ISO_State__c, Shipping_ISO_Country__r.Name, Shipping_ISO_State__r.Name, IATA_ISO_State__r.Name
                    FROM AMS_Pax_Accreditation_Form__c
                    WHERE Id IN :oscarOnlineAccredIds]);

            for (AMS_OSCAR__c oscar : oscarsToProcess) {
                onlineAccredsToUpdate.add(AMS_Utils.CopyDataFromAccountToStaging(AMS_UTILS.OWNERSHIP_IATA, targetAccounts.get(oscar.AMS_Target_Agency__c), onlineAccreditations.get(oscar.AMS_Online_Accreditation__c)));
            }

            if(!onlineAccredsToUpdate.isEmpty())
                update onlineAccredsToUpdate;
        }


    }

    //*************************************
    //********** helper methods ***********
    //*************************************
    private static void prepopulateValues() {
        //AMS-1674 - [Agency changes] when "Type of change" include "Location type" the "Change of location type behavior" shoule be pre-populated

        Map<Id, AMS_OSCAR__c> oldMap = (Map<Id,AMS_OSCAR__c>) Trigger.oldMap;

        for(AMS_OSCAR__c oscar : (List<AMS_OSCAR__c>)Trigger.New){
            if(
                oscar.Process__c == AMS_Utils.AGENCYCHANGES
                && oscar.Type_of_change__c != null
                && oscar.Change_of_location_type_behavior__c == null
                //&& (Trigger.isInsert || oscar.Type_of_change__c != oldMap.get(oscar.Id).Type_of_change__c)
            ){
                Set<String> tocList = new Set<String>();
                tocList.addAll(oscar.Type_of_change__c.split(';'));

                if(tocList.contains(AMS_Utils.LOCATION_TYPE)){
                    oscar.Change_of_location_type_behavior__c = AMS_Utils.CHLOCTYPEBEHAVIOR_STANDARD;
                }

            }

            if(oscar.Process__c == AMS_Utils.NGOPTINOUT){
                
                oscar.Process_Start_Date__c = System.today();

                if(oscar.ANG_FA_Opt_out__c == 'Opt-Out'){
                    oscar.STEP11__c = 'Not Applicable';
                }

            }

        }
    }

    private static void assignOSCARToRegionalQueues(){

        List<AMS_OSCAR__c> certificationOscars = new List<AMS_OSCAR__c>();

        for(AMS_OSCAR__c oscar : (List<AMS_OSCAR__c>)Trigger.New)
            if(oscar.RecordTypeId == AMS_Utils.RECTYPE_CERT)
                certificationOscars.add(oscar);

        /*if(!certificationOscars.isEmpty())
            AMS_OscarCaseTriggerHelper.assignOscarToRegionQueue(certificationOscars);*/
    }

    public static void handleChangesProcess(List<AMS_OSCAR__c> oscars) {

        //do Not run minor changes on agency changes trigger????
        AMS_AccountTriggerHandler.processMinorChangesValidationFlag = false;
        AMS_AccountTriggerHandler.minorChangesComingFromOSCAR = true;
        for(AMS_OSCAR__c oscar : oscars)
            if(oscar.Type_of_change__c!=null && oscar.Type_of_change__c.contains(AMS_Utils.REMOVALTRADENAME))
                AMS_AccountTriggerHandler.comingFromOSCARforRemoveTradeName = true;
        Id changeRT = Schema.AMS_OSCAR__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();
        List<AMS_OSCAR__c> oscarsToValidate = filterOSCARbyRT(changeRT, oscars);

        if (oscarsToValidate.size() > 0) {

            List<AMS_OSCAR__c> oscarsToProcess = getAgencyChangeOSCARSToProcess(oscarsToValidate);

            if (validateTypeOfChange(oscarsToValidate) && oscarsToProcess.size() > 0 )
                processAgencyChanges(oscarsToProcess);
        }
    }

    public static boolean validateTypeOfChange(List<AMS_OSCAR__c> oscars) {

        Map<Id, AMS_OSCAR__c> oldMap = (Map<Id,AMS_OSCAR__c>) Trigger.oldMap;

        for (AMS_OSCAR__c oscar : oscars) {

            if (oscar.Type_of_change__c <> oldMap.get(oscar.Id).Type_of_change__c && oldMap.get(oscar.Id).STEP6__c == AMS_Utils.PASSED)
                {
                    oscar.addError('Type of Change cannot be changed after Sanity Check is passed.');
                    return false;
                }



            if (oscar.Type_of_change__c <> oldMap.get(oscar.Id).Type_of_change__c || oldMap.get(oscar.Id).STEP6__c <> AMS_Utils.PASSED && oscar.STEP6__c == AMS_Utils.PASSED) {
                AMS_AgencyChangesConfigHelper.ChangesConfig oscarConfig = AMS_AgencyChangesConfigHelper.getConfig(oscar);
                if (oscarConfig != null) {
                    AMS_AgencyChangesConfigHelper.setNotApplicableSteps(oscarConfig.config, oscar);
                }
                else return false;
            }
    }

        return true;
        
    }

    //get only the Agency Change OSCARs that need to be processed
    private static List<AMS_OSCAR__c> getAgencyChangeOSCARSToProcess(List<AMS_OSCAR__c> oscars) {

        Map<Id, AMS_OSCAR__c> oldMap = (Map<Id,AMS_OSCAR__c>) Trigger.oldMap;

        ID changeRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();

        List<AMS_OSCAR__c> changeOscars = new List<AMS_OSCAR__c>();
        for (AMS_OSCAR__c oscar : oscars) {
            if (oscar.recordTypeID == changeRT) {
                AMS_OSCAR__c oldOSCAR = oldMap.get(oscar.Id);
                if ((oldOSCAR.STEP6__c <> AMS_Utils.PASSED && oscar.STEP6__c == AMS_Utils.PASSED) || (oldOSCAR.RPM_Approval__c <> AMS_Utils.AUTH_APPROVAL && oscar.RPM_Approval__c == AMS_Utils.AUTH_APPROVAL) || (oldOSCAR.STEP4__c <> AMS_Utils.PASSED && oscar.STEP4__c == AMS_Utils.PASSED) || (!oldOSCAR.Apply_Penalty_Fee__c && oscar.Apply_Penalty_Fee__c) || oscar.Change_effective_as_of__c > Date.today())
                    changeOscars.add(oscar);

            }
        }

        return changeOscars;
    }

    public static void processAgencyChanges(List<AMS_OSCAR__c> oscars) {

        boolean isSanityCheck = false;

        Map<Id, AMS_OSCAR__c> oldMap = (Map<Id,AMS_OSCAR__c>) Trigger.oldMap;

        //map that will be used to verify ownership consistency between a list of agencies
        Map<Id, Set<Id>> accsToCompareOwnership = new Map<Id, Set<Id>>();

        //map that given an agency will give us the id of its terminated child accounts
        Map<Id, Set<Id>> agencyTerminatedChildAgencies = new Map<Id, Set<Id>>();

        //this Container will store all change codes that need to be created
        List<AMS_Utils.Container> changesContainer = new List<AMS_Utils.Container>();

        //store all the updates to be made on account as consequence of migration of data from staging area to master data

        Map<Id,AMS_ChangeCodesHelper.ObjectChangesStruct> accountsToUpdate = new Map<Id,AMS_ChangeCodesHelper.ObjectChangesStruct>();

        // Account Fields Information
        Map<String, Schema.SObjectField>  acctFieldsMap= Schema.SObjectType.Account.fields.getMap();

        //this structure contains all the hierarchy relationships that need to be inserted/updated/deleted
        List<AMS_HierarchyHelper.HierarchyStruct> hierarchyChanges = new List<AMS_HierarchyHelper.HierarchyStruct>();

        Set<Id> oscarIds = new Set<Id>();
        Set<Id> oscarOnlineAccredIds = new Set<Id>();

        Map<Id, List<AMS_Process_Detail__c>> processDetailPerOSCAR = new Map<Id, List<AMS_Process_Detail__c>>();

        for (AMS_OSCAR__c oscar : oscars) {
            addAccountId(oscar.Account__c);
            addAccountId(oscar.AMS_Target_Agency__c);
            oscarIds.add(oscar.Id);
            oscarOnlineAccredIds.add(oscar.AMS_Online_Accreditation__c);
        }

        //query the the Process Detail object for all the agencies that are being bought
        //DTULLO: Added Check on Record Type
        List<AMS_Process_Detail__c> allProcessDetails = new List<AMS_Process_Detail__c>([SELECT Id, Account__c, OSCAR__c, Account__r.Status__c, RecordType.Developername FROM AMS_Process_Detail__c WHERE OSCAR__c IN :oscarIds and RecordType.Developername = 'Agency_Involved']);

        for (AMS_Process_Detail__c pd : allProcessDetails) {
            //TERMINATED AGENCIES IGNORED
            if(pd.Account__c != null && (pd.Account__r.Status__c != AMS_Utils.ACC_S0_TERMINATED || pd.Account__r.Status__c != AMS_Utils.ACC_S1_NOTACCREDITED)){
                if (processDetailPerOSCAR.get(pd.OSCAR__c) == null)
                    processDetailPerOSCAR.put(pd.OSCAR__c, new List<AMS_Process_Detail__c> {pd});
                else
                    processDetailPerOSCAR.get(pd.OSCAR__c).add(pd);
            }

        }

        //need to get all the hierarchy relationships for the account related to each OSCAR
        Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships = AMS_HierarchyHelper.getAccountsHierarchies(accountIds);

        for (List<AMS_Agencies_relationhip__c> hierarchyRelations : accountHierarchyRelationships.values()) {
            for (AMS_Agencies_relationhip__c relationship : hierarchyRelations) {

                addAccountId(relationship.Parent_Account__c);
                addAccountId(relationship.Child_Account__c);

                if(relationship.Child_Account__r.Status__c == AMS_Utils.ACC_S0_TERMINATED){
                    if(!agencyTerminatedChildAgencies.containsKey(relationship.Parent_Account__c))
                        agencyTerminatedChildAgencies.put(relationship.Parent_Account__c, new Set<Id>());

                    agencyTerminatedChildAgencies.get(relationship.Parent_Account__c).add(relationship.Child_Account__c);

                }

            }
        }

        //need to find the list of SAs directly related to the each account related to an OSCAR
        Map<Id, Set<Id>> agencyToSAs = new Map<Id, Set<Id>>();

        for(AMS_OSCAR__c oscar : oscars){
            for (List<AMS_Agencies_relationhip__c> hierarchyRelations : accountHierarchyRelationships.values()) {
                for (AMS_Agencies_relationhip__c relationship : hierarchyRelations) {

                    if(relationship.Parent_Account__c == oscar.Account__c &&
                        relationship.Child_Account__r.Location_Type__c==AMS_Utils.SA &&
                        relationship.Child_Account__r.Status__c!=AMS_Utils.ACC_S0_TERMINATED){
                        if(agencyToSAs.get(oscar.Account__c)==null)
                            agencyToSAs.put(oscar.Account__c, new Set<Id>());
                        agencyToSAs.get(oscar.Account__c).add(relationship.Child_Account__c);
                        system.debug(LoggingLevel.ERROR,'[LF]: Agenzia '+oscar.Account__c+' ha SA '+relationship.Child_Account__c);
                    }

                }
            }
        }
        system.debug(LoggingLevel.ERROR,'[LF]: FINE CALCOLO SA');

        //<Account Id, Current Location Type>
        // Get the Accounts location type in the beggining before its changed (as in the case of a change of Ownership to non IATA
        // )
        Map<Id, AMS_HierarchyHelper.AccountStruct> accountStructPerAcct = getAccountsInfoBeforeChanges(accounts);

        //Map<Id, AMS_Pax_Accreditation_Form__c> onlineAccreditations = getAccreditations(oscarOnlineAccredIds);
        /*** AMSU-121 ***/
        allOnlineAccr = allOnlineAccr == null ? getAllAccreditations(oscars) : allOnlineAccr;
        Map<Id, AMS_Pax_Accreditation_Form__c> onlineAccreditations = getAccreditations2(oscarOnlineAccredIds, allOnlineAccr);

        //Here we will save the accounts that will suffer ownership changes
        Map<Id, Set<Id>> accountsAffectedPerOnlineAccreditation = new Map<Id, Set<Id>>();

        AMS_AgencyChangesConfigHelper.ChangesConfig oscarConfig;
        AMS_AgencyChangesConfigHelper.ChangesConfig cascadingConfig; //configuration used when we need to apply a different change Code on agencies in Process Detail
        AMS_AgencyChangesConfigHelper.ChangesConfig locationConfig; //configuration used when we need to apply a different change Code for change of location to SAs

        system.debug('processAgencyChanges() --> oscars = ' + oscars);

        boolean needValidationsOnStagingArea = false;
        Set<ID> stagingAreaIDs = new Set<ID>();
        Map<ID,AMS_Pax_Accreditation_Form__c> stagingAreas = new Map<ID,AMS_Pax_Accreditation_Form__c>();
        for (AMS_OSCAR__c oscar : oscars){
            if(oscar.AMS_Online_Accreditation__c!=null)
                stagingAreaIDs.add(oscar.AMS_Online_Accreditation__c);
            if(oscar.Type_of_change__c!=null && oscar.Type_of_change__c.contains(AMS_Utils.REMOVALTRADENAME))
                needValidationsOnStagingArea = true;
        }

        if(needValidationsOnStagingArea){
            stagingAreas = new Map<ID,AMS_Pax_Accreditation_Form__c>([SELECT Id, Trade_Name__c FROM AMS_Pax_Accreditation_Form__c WHERE ID IN :stagingAreaIDs]);
        }


        for (AMS_OSCAR__c oscar : oscars) {

            AMS_OSCAR__c oldOSCAR = oldMap.get(oscar.Id);

            system.debug('processAgencyChanges() --> oscar = ' + oscar.Type_of_change__c + ' - oscar.staging = ' + oscar.AMS_Online_Accreditation__c);
            if (oscar.Type_of_change__c != null) {

                //Separate types of changes in 2 groups:
                //types of changes to be applied on all the hierarchy agencies defined in the Process Detail plus the Agency where the OSCAR was opened
                String cascadingTOCs = AMS_AgencyChangesConfigHelper.getPropagatableTypesOfChange(oscar.Type_of_change__c, true);

                //types of changes only to be applied on the Agency where the OSCAR was opened
                String nonCascadingTOCs =  AMS_AgencyChangesConfigHelper.getPropagatableTypesOfChange(oscar.Type_of_change__c, false);

                System.debug('AGENCY CHANGES: Propagate changes selected: ' + cascadingTOCs);
                System.debug('AGENCY CHANGES: Non Propagate changes selected: ' + nonCascadingTOCs);

                oscarConfig = AMS_AgencyChangesConfigHelper.getConfig(oscar);

                if (nonCascadingTOCs.length() > 0 && cascadingTOCs.length() > 0)
                    cascadingConfig = AMS_AgencyChangesConfigHelper.getConfig(cascadingTOCs, oscar.Business_Process__c);

                List<AMS_Process_Detail__c> pds = processDetailPerOSCAR.get(oscar.Id);

                Set<Id> agenciesAffected = new Set<Id>();

                if (pds != null)
                    for (AMS_Process_Detail__c pd : pds)
                        agenciesAffected.add(pd.Account__c);

                AMS_Pax_Accreditation_Form__c oscarOnlineAccreditation = onlineAccreditations.get(oscar.AMS_Online_Accreditation__c);

                Id hierarchyHO = AMS_HierarchyHelper.getHierarchyHO(accountHierarchyRelationships.get(oscar.Account__c));

                Set<String> tocList = new Set<String>();
                tocList.addAll(oscar.Type_of_change__c.split(';'));


                //this is used by change of location: create a list of SAs involved in the change and SA not involved in the change
                boolean changeContainsLocation = (nonCascadingTOCs.containsIgnoreCase(AMS_Utils.LOCATION) || nonCascadingTOCs.containsIgnoreCase(AMS_Utils.LOCATION_TYPE));
                String changeOfLocation = '';
                if (nonCascadingTOCs.containsIgnoreCase(AMS_Utils.LOCATION))
                    changeOfLocation = AMS_Utils.LOCATION;
                else if (nonCascadingTOCs.containsIgnoreCase(AMS_Utils.LOCATION_TYPE))
                    changeOfLocation = AMS_Utils.LOCATION_INSPECTION;

                Set<Id> SAsInvolved = new Set<Id>();
                Set<Id> SAsNotInvolved = new Set<Id>();
                Set<Id> allSAs = new Set<Id>();

                if(changeContainsLocation && agencyToSAs.get(oscar.Account__c)!=null){
                    locationConfig = AMS_AgencyChangesConfigHelper.getConfig(changeOfLocation, oscar.Business_Process__c);

                    for(Id sa : agencyToSAs.get(oscar.Account__c)){
                        boolean found = false;
                        for(Id ag : agenciesAffected){
                            if(sa==ag){
                                SAsInvolved.add(sa);
                                found = true;
                                break;
                            }
                        }
                        if(!found)
                            SAsNotInvolved.add(sa);
                    }
                    system.debug(LoggingLevel.ERROR,'[LF]: SAS affected: '+SAsInvolved);
                    system.debug(LoggingLevel.ERROR,'[LF]: SAS NOT affected: '+SAsNotInvolved);
                }

                if (oldOSCAR.STEP6__c <> AMS_Utils.PASSED && oscar.STEP6__c <> AMS_Utils.PASSED && oscar.Change_effective_as_of__c > Date.today()) {
                    system.debug('RB: Entering process future dates');
                    oscar.status__c = 'Accepted_Future Date';
                    oscar.Process_Start_Date__c = oscar.Change_effective_as_of__c;
                }

                if (oldOSCAR.STEP6__c <> AMS_Utils.PASSED && oscar.STEP6__c == AMS_Utils.PASSED) {

                    isSanityCheck = true;

                    if(!performOscarValidations(toclist, agenciesAffected, oscar, accounts, accountHierarchyRelationships, stagingAreas))
                        return;
                    oscar.First_Step_Completed__c = true;

                    //Location Type will always be selected as a single change.
                    if (nonCascadingTOCs.length() > 0 && nonCascadingTOCs.containsIgnoreCase(AMS_Utils.LOCATION_TYPE)) {
                        system.debug(LoggingLevel.ERROR,'[LF]: AMS_OSCARTriggerHandler() Processing change of location type in sanity checks');

                        Set<Id> accAffected;
                        //In this situation we only need to create change code for the oscar account
                        if(oscar.Change_of_location_type_behavior__c == AMS_Utils.CHLOCTYPEBEHAVIOR_NOSWAP)
                            accAffected = new Set<Id> {oscar.Account__c};
                        else{ //default swap with parent, create change code for both accounts involved in the swap
                            Id oscarAccountParent = accounts.get(oscar.Account__c).ParentId;
                            accAffected = new Set<Id> {oscar.Account__c, oscarAccountParent};
                            //need to save this parent in hierarchy account selection, because after this operation it will become a child
                            //and we need to keep track of it for the approval process
                            if( pds!= null && pds.size() > 0)
                                throw new AMSException('Change of Location Type processes should not have any account selected in the Hierarchy Account Selection');
                            
                            //DTULLO: Added Record Type
                            AMS_Process_Detail__c parentAccount = new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = oscarAccountParent,  RecordTypeId = rtAgencyInvolved);
                            insert parentAccount;

                        }

                        System.debug('Checkpoint 02.5.1');
                        changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, oscarConfig.config, getAccounts(accAffected), AMS_Utils.SANITYCHECK));
                        System.debug('Checkpoint 02.5.2');
                        accountsToUpdate.putAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, getAccounts(accAffected), oscar.Type_of_change__c, oscarOnlineAccreditation));
                        System.debug('Checkpoint 02.5.3');
                    }
                    // here there are several possible cases:
                    else if (nonCascadingTOCs.length() > 0 && cascadingTOCs.length() > 0) {
                        system.debug(LoggingLevel.ERROR,'[LF]: AMS_OSCARTriggerHandler() Processing both cascade and not cascade changes in sanity checks');
                        Set<Id> agenciesWithSingleCode = agenciesAffected.clone(); // normally this list includes all the agencies listed in the hierarchy account selection
                        Set<Id> agenciesWithMultipleCode = new Set<Id> {oscar.Account__c}; // normally only the main agency is affected by all the changes

                        // in case of change which includes location, the SAs should be affected  by the change of location so:
                        if(changeContainsLocation  && agencyToSAs.get(oscar.Account__c)!=null){
                            agenciesWithSingleCode.removeAll(SAsInvolved); // the SAs which are also listed in the hierarchy account selection should not receive a partial change
                            agenciesWithMultipleCode.addAll(SAsInvolved); // the SAs which are also listed in the hierarchy account selection will be affected by the complete change
                            // the SAs which are not listed in the hierarchy account selection will be affected by change of location only!
                        }

                        system.debug(LoggingLevel.ERROR, '[LF]: Main '+oscar.Account__c);
                        system.debug(LoggingLevel.ERROR, '[LF]: agenciesAffected '+agenciesAffected);
                        system.debug(LoggingLevel.ERROR, '[LF]: SAsInvolved '+SAsInvolved);
                        system.debug(LoggingLevel.ERROR, '[LF]: SAsNotInvolved '+SAsNotInvolved);
                        system.debug(LoggingLevel.ERROR, '[LF]: agenciesWithMultipleCode '+agenciesWithMultipleCode);
                        system.debug(LoggingLevel.ERROR, '[LF]: agenciesWithSingleCode '+agenciesWithSingleCode);

                        if(!agenciesWithSingleCode.isEmpty())
                        {
                            // Apply cascade + no cascade changes: change code + data migration
                            accountsToUpdate.putAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, getAccounts(agenciesWithSingleCode), cascadingTOCs, oscarOnlineAccreditation));
                            changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, cascadingConfig.config, getAccounts(agenciesWithSingleCode), AMS_Utils.SANITYCHECK));
                        }
                        
                        if(!agenciesWithMultipleCode.isEmpty())
                        {
                            // Apply cascade + no cascade changes: change code + data migration
                            accountsToUpdate.putAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, getAccounts(agenciesWithMultipleCode), oscar.Type_of_change__c, oscarOnlineAccreditation));
                            changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, oscarConfig.config, getAccounts(agenciesWithMultipleCode), AMS_Utils.SANITYCHECK));
                        }
                        

                        // Apply change of location to children SAs not explicitly involved in the change
                        if(SAsNotInvolved.size()>0){
                            //change code generated only for the agencies not affected by any other change
                            accountsToUpdate.putAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, getAccounts(SAsNotInvolved), changeOfLocation, oscarOnlineAccreditation));
                            changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, locationConfig.config, getAccounts(SAsNotInvolved), AMS_Utils.SANITYCHECK));
                        }

                    } else if (nonCascadingTOCs.length() > 0 && cascadingTOCs.length() == 0) {
                        system.debug(LoggingLevel.ERROR,'[LF]: AMS_OSCARTriggerHandler() Processing not cascade changes in sanity checks');
                        changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, oscarConfig.config, getAccounts(oscar.Account__c), AMS_Utils.SANITYCHECK));
                        accountsToUpdate.putAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, getAccounts(oscar.Account__c), oscar.Type_of_change__c, oscarOnlineAccreditation));

                        // in case of location (for the moment is 100% but only God knows what will happen in the future)
                        // I'll apply the change and generate a CHL also to the SAs
                        if(changeContainsLocation  && agencyToSAs.get(oscar.Account__c)!=null){
                                //We'll apply CHL to all dependent SAs either involved or not involved
                                allSAs.addAll(SAsInvolved);
                                allSAs.addAll(SAsNotInvolved);

                                changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, oscarConfig.config, getAccounts(allSAs), AMS_Utils.SANITYCHECK));
                                accountsToUpdate.putAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, getAccounts(allSAs), changeOfLocation, oscarOnlineAccreditation));
                        }

                    } else if (nonCascadingTOCs.length() == 0 && cascadingTOCs.length() > 0) {
                        system.debug(LoggingLevel.ERROR,'[LF]: AMS_OSCARTriggerHandler() Processing cascade changes in sanity checks');
                        agenciesAffected.add(oscar.Account__c);

                        changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, oscarConfig.config, getAccounts(agenciesAffected), AMS_Utils.SANITYCHECK));
                        accountsToUpdate.putAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, getAccounts(agenciesAffected), oscar.Type_of_change__c, oscarOnlineAccreditation));
                        // change of location is not affecting this scenario
                    }

                    agenciesAffected.add(oscar.Account__c);

                    Boolean isChangeOwnershipToIATA = tocList.contains(AMS_Utils.OWNERSHIP_IATA) ? true : false;
                    //All terminated agencies that would be left without parent MUST be automatically migrated, thus following their parents
                    //Exception to the above rule is when we have change of ownership to IATA, where BRs will be left as standalone
                    Set<Id> agenciesToMigrate = AMS_HierarchyHelper.addTerminatedDescendants(agenciesAffected, agencyTerminatedChildAgencies, isChangeOwnershipToIATA, accounts);
                    system.debug('AgenciesToMigrateHierarchy: ' + agenciesToMigrate);
                    system.debug('AgenciesToMigrateData: ' + agenciesAffected);

                    AMS_HierarchyHelper.HierarchyStruct hs = processHierarchyChanges(oscar, accountHierarchyRelationships, agenciesToMigrate);

                    hierarchyChanges.add(hs);

                    //check if ownership needs to be copied from online form to Accounts
                    if (AMS_Utils.ownershipIsToBeMigrated(oscar.Type_of_change__c)){
                        Set<Id> accountsListToMigrate = new Set<Id>();
                        accountsListToMigrate = checkProcessAndStatusToMigrateOwners(oscar.Type_of_change__c, oscar.Process__c, agenciesAffected);
                        accountsAffectedPerOnlineAccreditation.put(oscar.AMS_Online_Accreditation__c, accountsListToMigrate);

                        //fill map to check ownership alignment in hierarchy
                        if(cascadingTOCs.contains(AMS_Utils.OWNERSHIP_IATA)){
                            //the target agency owners will be compared with the agency owners we are trying to migrate to the target agency hierarchy
                            Set<Id> agsToCompareOwner = new Set<Id>(agenciesAffected);
                            agsToCompareOwner.add(oscar.AMS_Target_Agency__c);
                            accsToCompareOwnership.put(oscar.Id, agsToCompareOwner);
                        }

                    }

                    if (onlineAccreditations.get(oscar.AMS_Online_Accreditation__c).Branch_Office_Country__r.Due_diligence_mandatory__c && oscar.STEP17__c != AMS_Utils.NOT_APPLICABLE) {

                        if(accounts.get(oscar.Account__c).Due_Diligence_Status__c == AMS_Utils.IN_PROGRESS) oscar.STEP17__c = AMS_Utils.IN_PROGRESS;
                        else{
                            String dlResult = AMS_OSCAR_Webservice.createAMLCaseWithNoOscarUpdate(oscar);
                            if (dlResult.startsWith('ERROR')) oscar.addError(dlResult);
                            else accounts.get(oscar.Account__c).Due_Diligence_Status__c = AMS_Utils.IN_PROGRESS;
                        }
                    }

                    system.debug('RB - Sanity check already passed: ' + oscar.Sanity_Check_Passed__c);

                    if(oscar.Sanity_Check_Passed__c == true) {
                    oscar.addError('Change code already generated for this OSCAR! Please perform a withdrawal in order to pass Sanity Check, rollback data through an OSCAR Correction and Set this OSCAR Status to Closed_Withdrawn');                
                    }
            
                    oscar.Sanity_Check_Passed__c = true;                    

                } else if (oldOSCAR.RPM_Approval__c <> AMS_Utils.AUTH_APPROVAL && oscar.RPM_Approval__c == AMS_Utils.AUTH_APPROVAL) {


                    //Location Type will always be selected as a single change.
                    if (nonCascadingTOCs.length() > 0 && nonCascadingTOCs.containsIgnoreCase(AMS_Utils.LOCATION_TYPE)) {
                        System.debug('AGENCY CHANGES: Processing Location Type Change Codes on approval.');

                        Set<Id> accAffected;
                        //In this situation we only need to create change code for the oscar account
                        if(oscar.Change_of_location_type_behavior__c == AMS_Utils.CHLOCTYPEBEHAVIOR_NOSWAP)
                            accAffected = new Set<Id> {oscar.Account__c};
                        else{ //default swap with parent, create change code for both accounts involved in the swap
                            if(pds == null || (pds != null && pds.size() != 1))
                                throw new AMSException('Something went wrong! The Hierarchy Account selection for Change of Location Type must have a single entry for this Oscar. Please contact your administrator.');

                            accAffected = new Set<Id> {oscar.Account__c, pds.get(0).Account__c};
                        }

                        changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, oscarConfig.config, getAccounts(accAffected), AMS_Utils.APPROVAL));
                        accountsToUpdate.putAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, getAccounts(accAffected), oscar.Type_of_change__c, oscarOnlineAccreditation));
                    }
                    //need to apply two different Sets of Change Codes. One for Oscar Account and other for process details
                    // here there are several possible cases:
                    else if (nonCascadingTOCs.length() > 0 && cascadingTOCs.length() > 0) {
                        system.debug(LoggingLevel.ERROR,'[LF]: AMS_OSCARTriggerHandler() Processing both cascade and not cascade changes on approval');
                        Set<Id> agenciesWithSingleCode = agenciesAffected.clone(); // normally this list includes all the agencies listed in the hierarchy account selection
                        Set<Id> agenciesWithMultipleCode = new Set<Id> {oscar.Account__c}; // normally only the main agency is affected by all the changes

                        // in case of change which includes location, the SAs should be affected  by the change of location so:
                        if(changeContainsLocation  && agencyToSAs.get(oscar.Account__c)!=null){
                            agenciesWithSingleCode.removeAll(SAsInvolved); // the SAs which are also listed in the hierarchy account selection should not receive a partial change
                            agenciesWithMultipleCode.addAll(SAsInvolved); // the SAs which are also listed in the hierarchy account selection will be affected by the complete change
                            // the SAs which are not listed in the hierarchy account selection will be affected by change of location only!
                        }

                        system.debug(LoggingLevel.ERROR, '[LF]: Main '+oscar.Account__c);
                        system.debug(LoggingLevel.ERROR, '[LF]: agenciesAffected '+agenciesAffected);
                        system.debug(LoggingLevel.ERROR, '[LF]: SAsInvolved '+SAsInvolved);
                        system.debug(LoggingLevel.ERROR, '[LF]: SAsNotInvolved '+SAsNotInvolved);
                        system.debug(LoggingLevel.ERROR, '[LF]: agenciesWithMultipleCode '+agenciesWithMultipleCode);
                        system.debug(LoggingLevel.ERROR, '[LF]: agenciesWithSingleCode '+agenciesWithSingleCode);

                        if(!agenciesWithSingleCode.isEmpty())
                        {
                            // Apply cascade changes: change code + data migration
                            accountsToUpdate.putAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, getAccounts(agenciesWithSingleCode), cascadingTOCs, oscarOnlineAccreditation));
                            changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, cascadingConfig.config, getAccounts(agenciesWithSingleCode), AMS_Utils.APPROVAL));
                        }

                        if(!agenciesWithMultipleCode.isEmpty())
                        {
                            // Apply cascade + no cascade changes: change code + data migration
                            accountsToUpdate.putAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, getAccounts(agenciesWithMultipleCode), oscar.Type_of_change__c, oscarOnlineAccreditation));
                            changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, oscarConfig.config, getAccounts(agenciesWithMultipleCode), AMS_Utils.APPROVAL));
                        }

                        // Apply change of location to children SAs not explicitly involved in the change
                        if(!SAsNotInvolved.isEmpty()){
                            //change code generated only for the agencies not affected by any other change
                            accountsToUpdate.putAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, getAccounts(SAsNotInvolved), changeOfLocation, oscarOnlineAccreditation));
                            changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, locationConfig.config, getAccounts(SAsNotInvolved), AMS_Utils.APPROVAL));
                        }


                    } else if (nonCascadingTOCs.length() > 0 && cascadingTOCs.length() == 0) {
                        system.debug(LoggingLevel.ERROR,'[LF]: AMS_OSCARTriggerHandler() Processing not cascade changes on approval');
                        changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, oscarConfig.config, getAccounts(oscar.Account__c), AMS_Utils.APPROVAL));
                        accountsToUpdate.putAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, getAccounts(oscar.Account__c), oscar.Type_of_change__c, oscarOnlineAccreditation));

                        // in case of location (for the moment is 100% but only God knows what will happen in the future)
                        // I'll apply the change and generate a CHL also to the SAs
                        if(changeContainsLocation  && agencyToSAs.get(oscar.Account__c)!=null){
                            //We'll apply CHL to all dependent SAs either involved or not involved
                            allSAs.addAll(SAsInvolved);
                            allSAs.addAll(SAsNotInvolved);
                            changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, oscarConfig.config, getAccounts(allSAs), AMS_Utils.APPROVAL));
                            accountsToUpdate.putAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, getAccounts(allSAs), changeOfLocation, oscarOnlineAccreditation));
                        }

                    } else if (nonCascadingTOCs.length() == 0 && cascadingTOCs.length() > 0) {
                        system.debug(LoggingLevel.ERROR,'[LF]: AMS_OSCARTriggerHandler() Processing cascade changes on approval');
                        agenciesAffected.add(oscar.Account__c);
                        changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, oscarConfig.config, getAccounts(agenciesAffected), AMS_Utils.APPROVAL));

                        accountsToUpdate.putAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, getAccounts(agenciesAffected), oscar.Type_of_change__c, oscarOnlineAccreditation));
                        // change of location is not affecting this scenario
                    }

                    //APPLY HIERARCHY CHANGES
                    //Hierarchy changes are applied to the agencies in the process detail and also to the OSCAR Account
                    agenciesAffected.add(oscar.Account__c);

                    /*MOVED TO SANITY CHECK
                    Boolean isChangeOwnershipToIATA = tocList.contains(AMS_Utils.OWNERSHIP_IATA) ? true : false;
                    //All terminated agencies that would be left without parent MUST be automatically migrated, thus following their parents
                    //Exception to the above rule is when we have change of ownership to IATA, where BRs will be left as standalone
                    Set<Id> agenciesToMigrate = AMS_HierarchyHelper.addTerminatedDescendants(agenciesAffected, agencyTerminatedChildAgencies, isChangeOwnershipToIATA, accounts);
                    system.debug('AgenciesToMigrateHierarchy: ' + agenciesToMigrate);
                    system.debug('AgenciesToMigrateData: ' + agenciesAffected);

                    AMS_HierarchyHelper.HierarchyStruct hs = processHierarchyChanges(oscar, accounts, accountHierarchyRelationships, agenciesToMigrate);

                    hierarchyChanges.add(hs);
                    ************************/

                    //check if ownership needs to be copied from online form to Accounts
                    if (AMS_Utils.ownershipIsToBeMigrated(oscar.Type_of_change__c)){
                        accountsAffectedPerOnlineAccreditation.put(oscar.AMS_Online_Accreditation__c, agenciesAffected);

                        //fill map to check ownership alignment in hierarchy
                        if(cascadingTOCs.contains(AMS_Utils.OWNERSHIP_IATA)){
                            //the target agency owners will be compared with the agency owners we are trying to migrate to the target agency hierarchy
                            Set<Id> agsToCompareOwner = new Set<Id>(agenciesAffected);
                            agsToCompareOwner.add(oscar.AMS_Target_Agency__c);
                            accsToCompareOwnership.put(oscar.Id, agsToCompareOwner);
                        }

                    }


                } else if (oldOSCAR.STEP4__c <> AMS_Utils.PASSED && oscar.STEP4__c == AMS_Utils.PASSED) {
                    if (nonCascadingTOCs.length() > 0 && nonCascadingTOCs.containsIgnoreCase(AMS_Utils.LOCATION_TYPE)) {
                        System.debug('AGENCY CHANGES: Processing Location Type Change Codes on Withdrawal.');

                        Set<Id> accAffected;
                        //In this situation we only need to create change code for the oscar account
                        if(oscar.Change_of_location_type_behavior__c == AMS_Utils.CHLOCTYPEBEHAVIOR_NOSWAP)
                            accAffected = new Set<Id> {oscar.Account__c};
                        else{ //default swap with parent, create change code for both accounts involved in the swap
                            if(pds == null || (pds != null && pds.size() != 1))
                                throw new AMSException('Something went wrong! The Hierarchy Account selection for Change of Location Type must have a single entry for this Oscar. Please contact your administrator.');

                            accAffected = new Set<Id> {oscar.Account__c, pds.get(0).Account__c};
                        }

                        changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, oscarConfig.config, getAccounts(accAffected), AMS_Utils.WITHDRAWAL));
                    } else if (nonCascadingTOCs.length() > 0 && cascadingTOCs.length() > 0) {
                        changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, cascadingConfig.config, getAccounts(agenciesAffected), AMS_Utils.WITHDRAWAL));

                        changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, oscarConfig.config, getAccounts(oscar.Account__c), AMS_Utils.WITHDRAWAL));
                    } else if (nonCascadingTOCs.length() > 0 && cascadingTOCs.length() == 0) {
                        changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, oscarConfig.config, getAccounts(oscar.Account__c), AMS_Utils.WITHDRAWAL));
                    } else if (nonCascadingTOCs.length() == 0 && cascadingTOCs.length() > 0) {
                        agenciesAffected.add(oscar.Account__c);
                        changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, oscarConfig.config, getAccounts(agenciesAffected), AMS_Utils.WITHDRAWAL));
                    }

                }else if (!oldOSCAR.Apply_Penalty_Fee__c && oscar.Apply_Penalty_Fee__c) {
                    System.debug(loggingLevel.ERROR, '____ [cls AMS_OSCARTriggerHandler - processAgencyChanges] oscar.Apply_Penalty_Fee__c - ' + oscar.Apply_Penalty_Fee__c);
                    Agency_Applied_Change_code__c lastChangeCode = accounts.get(oscar.Account__c).Agencies_Applied_Change_codes__r[0];
                    AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

                    changeCode.name = 'LNF';
                    //changeCode.memoText = lastChangeCode.Bulletin_Information__c;
                    changeCode.reasonCode = lastChangeCode.Reason_Code__c;
                    changeCode.reasonDesc = lastChangeCode.Reason_Description__c;
                    changeCode.status = AMS_Utils.getIATANumericStatus(accounts.get(oscar.Account__c).Status__c);

                    System.debug(loggingLevel.ERROR, '____ [cls AMS_OSCARTriggerHandler - processAgencyChanges] changeCode - ' + changeCode);

                    changesContainer.add(new AMS_Utils.Container(new List<AMS_OSCAR_JSON.ChangeCode>{changeCode}, new List<Account>{accounts.get(oscar.Account__c)}, new List<AMS_Oscar__c>{oscar}));
                }

            }
        }


        Savepoint sp = Database.setSavepoint();

        List<AMS_ChangeCodesHelper.ObjectChangesStruct> objectChanges = new List<AMS_ChangeCodesHelper.ObjectChangesStruct> ();
        try {

                
            Map<Id,AMS_AccountRoleCreator.OldAndNewOwners> oldAndNewOwnersMap = new Map<Id,AMS_AccountRoleCreator.OldAndNewOwners>();
            //Migrate Ownership
            if (!accountsAffectedPerOnlineAccreditation.isEmpty()) {
                system.debug('processAgencyChanges() --> accountsAffectedPerOnlineAccreditation = ' + accountsAffectedPerOnlineAccreditation);

                oldAndNewOwnersMap = AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(accountsAffectedPerOnlineAccreditation, !isSanityCheck);

                //verify ownership alignment
                if(accsToCompareOwnership.size()>0 && !AMS_HierarchyHelper.checkHierarchyIntegrity(accsToCompareOwnership))
                    throw new AMSException('Performing this operation will result in hierarchy ownership inconsistency. Please make sure the owners being processed match with the owners of the target agency.');
            }


            //************Create Change Codes History ****************
            //
            //
            

            
            List<Account> accsToUpdateFromCC = new List<Account>();

            //insert the change codes
            if (changesContainer.size() > 0) {
                List<AMS_OSCAR_JSON.ChangeCode> changeCodes = new List<AMS_OSCAR_JSON.ChangeCode>();
                List<Account> accts = new List<Account>();
                List<AMS_OSCAR__c> theoscars = new List<AMS_OSCAR__c>();

                //merge everything
                for (AMS_Utils.Container c : changesContainer) {

                    if(c ==  null) continue;
                //All lists must have the same size in order to create correctly the change codes

                    changeCodes.addAll(c.changeCodes);
                    accts.addAll(c.accts);
                    theoscars.addAll(c.oscars);

                    integer index = 0;
                    for(Account acc : c.accts)
                    {
        
                    

                        //******* Add "Custom" changes struct for the Ownership mapping ******** INI

                        AMS_AccountRoleCreator.OldAndNewOwners oldNewOwnersByOscar = oldAndNewOwnersMap.get(theoscars[index].AMS_Online_Accreditation__c);

                        if(oldNewOwnersByOscar != null )
                        {
                            String oldOwnerCSV,newOwnerCSV = '';

                            if (oldNewOwnersByOscar.getOldOwnersByAccountId(acc.Id) != null) oldOwnerCSV = oldNewOwnersByOscar.getOldOwnersByAccountId(acc.Id).allOwnersCSV;
                            if (oldNewOwnersByOscar.getNewOwnersByAccountId(acc.Id) != null) newOwnerCSV = oldNewOwnersByOscar.getNewOwnersByAccountId(acc.Id).allOwnersCSV;

                            AMS_ChangeCodesHelper.ObjectChange objectChangesOwnership;

                            if(oldOwnerCSV != newOwnerCSV) objectChangesOwnership = new AMS_ChangeCodesHelper.ObjectChange('Account','Owners',oldOwnerCSV,newOwnerCSV);

                            if( objectChangesOwnership != null && accountsToUpdate.get(acc.Id) == null)
                            {
                                AMS_ChangeCodesHelper.ObjectChangesStruct acctChangesStruct = new AMS_ChangeCodesHelper.ObjectChangesStruct(new List <AMS_ChangeCodesHelper.ObjectChange> {objectChangesOwnership});
                                objectChanges.add(acctChangesStruct);

                                system.debug('DDD accountsToUpdate add Owners Info:' + accountsToUpdate.get(acc.Id));

                            }

                            else if ( objectChangesOwnership != null)
                                accountsToUpdate.get(acc.Id).changes.add(objectChangesOwnership);

                        }

    

                        system.debug('DDD accountsToUpdate.get(acc):' + accountsToUpdate.get(acc.Id));

                        objectChanges.add(accountsToUpdate.get(acc.Id));

                        index++;
                    }


                }
                //create change codes

                accsToUpdateFromCC = AMS_ChangeCodesHelper.createAAChangeCodes(objectChanges,changeCodes, theoscars, accts, false);
            }

            List<Account> accsToUpdateFromStagingArea = new List<Account>();
            for(Id a : accountsToUpdate.keySet()) accsToUpdateFromStagingArea.add(accountsToUpdate.get(a).acc);

            List<Account> mergedAccountUpdate = mergeAccountsToUpdate(accsToUpdateFromCC, accsToUpdateFromStagingArea);

            if (!mergedAccountUpdate.isEmpty()) {
                AMS_AccountTriggerHandler.processMinorChangesValidationFlag = true;
                update mergedAccountUpdate;
                AMS_AccountTriggerHandler.processMinorChangesValidationFlag = false;

            }
            system.debug('DDD11 hierarchyChanges.size(): ' + hierarchyChanges.size());

            if (hierarchyChanges.size() > 0) {
                List<AMS_Agencies_Hierarchy__c> allHierarchiesToInsert = new List<AMS_Agencies_Hierarchy__c>();
                List<AMS_Agencies_relationhip__c> allRelationsToUpdate = new List<AMS_Agencies_relationhip__c>();
                List<AMS_Agencies_relationhip__c> allRelationsToInsert = new List<AMS_Agencies_relationhip__c>();
                List<AMS_Agencies_relationhip__c> allRelationsToDelete = new List<AMS_Agencies_relationhip__c>();
                List<Id> allHierarchiesToDelete = new List<Id>();

                for (AMS_HierarchyHelper.HierarchyStruct hs : hierarchyChanges) {
                    if (hs.relationsToUpdate != null)
                        allRelationsToUpdate.addAll(hs.relationsToUpdate);
                    if (hs.relationsToInsert != null)
                        allRelationsToInsert.addAll(hs.relationsToInsert);
                    if (hs.relationsToDelete != null)
                        allRelationsToDelete.addAll(hs.relationsToDelete);
                    if (hs.hierarchiesToDelete != null)
                        allHierarchiesToDelete.addAll(hs.hierarchiesToDelete);
                }

                if (!allRelationsToDelete.isEmpty())
                    delete allRelationsToDelete;
                if (!allRelationsToUpdate.isEmpty())
                    update allRelationsToUpdate;
                if (!allRelationsToInsert.isEmpty())
                    insert allRelationsToInsert;

                if(!allHierarchiesToDelete.isEmpty()){
                    List<AMS_Agencies_Hierarchy__c> hierarchiesDel = new List<AMS_Agencies_Hierarchy__c>([SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Id IN :allHierarchiesToDelete]);
                    if (!hierarchiesDel.isEmpty())
                        delete hierarchiesDel;
                }


                //**** Generate Change Code History for Location Type and IATA Code


                List<AMS_Agency_A_Change_code_History__c> extraCCHistory = new List <AMS_Agency_A_Change_code_History__c>();

                system.debug('DDD11 aaccHistoryPerAcct: ' + AMS_ChangeCodesHelper.aaccHistoryPerAcct);


                for(Account acc : accsToUpdateFromCC)
                {
                    if(! AMS_AgencyRelationshipTriggerHandler.accsToUpdateSet.contains(acc))
                        AMS_AgencyRelationshipTriggerHandler.accsToUpdateSet.add(acc);                      
                }

                for(Account acc : AMS_AgencyRelationshipTriggerHandler.accsToUpdateSet)
                {
                    system.debug('DDD11 acc.Id: ' + acc.Id);

                    if(AMS_ChangeCodesHelper.aaccHistoryPerAcct.containsKey(acc.Id))
                    {
                        system.debug('DDD11 New Info Acct ID: ' + acc.id);
                        system.debug('DDD11 New Location_Type__c: '  + acc.Location_Type__c);
                        //system.debug('DDD11 New acc.parent.IATACode__c: '  + accounts.get(acc.ParentId).IATACode__c);
                    

                        //******* Add "Custom" changes struct for the Location Type mapping ******** INI
                        
                        if(accountStructPerAcct.containsKey(acc.Id) && acc.Location_Type__c !=  accountStructPerAcct.get(acc.Id).locationType)
                        {
                            
                            extraCCHistory.add( new AMS_Agency_A_Change_code_History__c(
                                                                Agency_Applied_Change_Code__c = AMS_ChangeCodesHelper.aaccHistoryPerAcct.get(acc.Id).changeCode.Id,
                                                                Object_API_Name__c            = 'Account',
                                                                Field_API_Name__c             = 'Location_Type__c',
                                                                Field_Old_Value__c            = accountStructPerAcct.get(acc.Id).locationType,
                                                                Field_New_Value__c            = acc.Location_Type__c
                                                                )
                                                );

                        }


                        //******* Add "Custom" changes struct for the Parent Iata Code mapping ******** INI

                        //If new location type is HO parent Iata code is null
                        
                        String newParentIATACode = null;

                        if(accounts.containsKey(acc.ParentId)) 
                        {
                            system.debug('DDD11 New acc.parentId: '  + accounts.get(acc.ParentId).IATACode__c);
                            newParentIATACode = accounts.get(acc.ParentId).IATACode__c;
                            
                        }
                        
                        
                        if(accountStructPerAcct.containsKey(acc.Id) && accountStructPerAcct.get(acc.Id).parentIATACode != newParentIATACode)
                        {
                            
                            extraCCHistory.add( new AMS_Agency_A_Change_code_History__c(
                                                                Agency_Applied_Change_Code__c = AMS_ChangeCodesHelper.aaccHistoryPerAcct.get(acc.Id).changeCode.Id,
                                                                Object_API_Name__c            = 'Account',
                                                                Field_API_Name__c             = 'Parent.IATACode__c',
                                                                Field_Old_Value__c            = accountStructPerAcct.get(acc.Id).parentIATACode,
                                                                Field_New_Value__c            = newParentIATACode
                                                                )
                                                );
                        }

                    }

                }

                if (!extraCCHistory.isEmpty()) 
                {

                            System.debug('The list of Change Codes History to add is (EXTRA) ' + extraCCHistory.size());

                            insert extraCCHistory;
                }
                AMS_ChangeCodesHelper.aaccHistoryPerAcct.clear();
            }

        } catch (Exception ex) {
            System.debug('DML exception: ' + ex);
            Database.rollback(sp);
            throw ex;
        }

    }

    public static AMS_HierarchyHelper.HierarchyStruct processHierarchyChanges(AMS_OSCAR__c oscar, Map<Id, List<AMS_Agencies_relationhip__c>> hierarchies, Set<Id> agenciesAffected) {

        system.debug( 'DDD2 processHierarchyChanges ');
        keepSALocationTypeFlag = false;

        //this container will store all database operations that need to be performed
        AMS_HierarchyHelper.HierarchyStruct hierarchyChanges = new AMS_HierarchyHelper.HierarchyStruct();



        Set<String> tocList = new Set<String>();
        tocList.addAll(oscar.Type_of_change__c.split(';'));

        Account oscarAccount = accounts.get(oscar.Account__c);

        if (tocList.contains(AMS_Utils.LOCATION_TYPE))
            hierarchyChanges = processChangeOfLocationType(oscar, hierarchies);
        else if (tocList.contains(AMS_Utils.OWNERSHIP_IATA)) {
            keepSALocationTypeFlag = true;
            hierarchyChanges = processChangeOfOwnershipToIATA(oscar, hierarchies, agenciesAffected);
        } else if (tocList.contains(AMS_Utils.OWNERSHIP_NON_IATA)) {
            keepSALocationTypeFlag = true;
            hierarchyChanges = processChangeOfOwnershipToNonIATA(oscar, hierarchies, agenciesAffected);
            //change of location for SA where the oscar has a target agency defined. this requires the SA to move under the target agency
        } else if ((tocList.contains(AMS_Utils.LOCATION) || tocList.contains(AMS_Utils.LOCATION_INSPECTION)) && oscarAccount.Location_Type__c.equalsIgnoreCase(AMS_Utils.SA) && oscar.AMS_Target_Agency__c != null) {
            keepSALocationTypeFlag = true;
            hierarchyChanges = processSAChangeOfLocation(oscar, hierarchies);
        }

        system.debug( 'DDD2 AMS_HierarchyHelper.hierarchyChanges: ' + hierarchyChanges);

        return hierarchyChanges;
    }

    public static AMS_HierarchyHelper.HierarchyStruct processChangeOfLocationType(AMS_OSCAR__c oscar, Map<Id, List<AMS_Agencies_relationhip__c>> hierarchies) {


        system.debug( 'DDD2 processChangeOfLocationType ');

        Id oscarAccountId = oscar.Account__c;

        //get the parent of the oscar account
        Account child = accounts.get(oscarAccountId);

        Account parent;

        if (child != null && child.parentId != null)
            parent = accounts.get(child.parentId);

        system.debug('AGENCY CHANGES: the parent that will become child: ' + parent);

        List<AMS_Agencies_relationhip__c> hierarchyRelationships = hierarchies.get(oscar.Account__c);

        if (child != null && parent != null)
            return AMS_HierarchyHelper.switchParentWithChild(child.Id, parent.Id, oscar.Change_of_location_type_behavior__c, accounts, hierarchyRelationships);

        throw new AMSException('Data inconsistency issue.');

    }

    public static AMS_HierarchyHelper.HierarchyStruct processChangeOfOwnershipToIATA(AMS_OSCAR__c oscar, Map<Id, List<AMS_Agencies_relationhip__c>> hierarchies, Set<Id> agenciesAffected) {

        System.debug('AGENCY CHANGES: Processing change of ownership. Scenario IATA Buys IATA');

        Id targetHierarchyHO = oscar.AMS_Target_Agency__c;
        //the hierarchy relationships where the agencies will be migrated to
        List<AMS_Agencies_relationhip__c> newHierarchy = hierarchies.get(targetHierarchyHO);
        List<AMS_Agencies_relationhip__c> currentHierarchy = hierarchies.get(oscar.Account__c);
        AMS_HierarchyHelper.HierarchyStruct relationshipsToManage;

        relationshipsToManage = AMS_HierarchyHelper.migrateAccountsToExistingHierarchy(oscar.Account__c, currentHierarchy, targetHierarchyHO, newHierarchy, agenciesAffected, accounts);

        if (relationshipsToManage.errorMessage != null)
            oscar.addError(relationshipsToManage.errorMessage);

        return relationshipsToManage;

    }

    public static AMS_HierarchyHelper.HierarchyStruct processChangeOfOwnershipToNonIATA(AMS_OSCAR__c oscar, Map<Id, List<AMS_Agencies_relationhip__c>> hierarchies, Set<Id> agenciesAffected) {
        //DEFINE A SET OF LOCATION CLASSES WHERE THE LOGIC SHOULD BE APPLIED

        System.debug('AGENCY CHANGES: Processing change of ownership. Scenario Non IATA Buys IATA');

        List<AMS_Agencies_relationhip__c> accountHierarchy = hierarchies.get(oscar.Account__c);
        AMS_HierarchyHelper.HierarchyStruct relationshipsToManage;

        //get the relationships that need to be updated/inserted/deleted
        relationshipsToManage = AMS_HierarchyHelper.migrateAccountsToNewHierarchy(oscar.Account__c, accounts, accountHierarchy, agenciesAffected);

        if (relationshipsToManage.errorMessage != null)
            oscar.addError(relationshipsToManage.errorMessage);

        return relationshipsToManage;
    }

    public static AMS_HierarchyHelper.HierarchyStruct processSAChangeOfLocation(AMS_OSCAR__c oscar, Map<Id, List<AMS_Agencies_relationhip__c>> hierarchies) {

        System.debug('AGENCY CHANGES: Processing change of location. OSCAR opened on SA and has a Target agency defined.');

        Id oscarAccountId = oscar.Account__c;

        //the child in the relation that needs to be moved
        Account child = accounts.get(oscarAccountId);
        //the new parent for the child
        Account parent = accounts.get(oscar.AMS_Target_Agency__c);

        List<AMS_Agencies_relationhip__c> hierarchyRelationships = hierarchies.get(oscar.Account__c);

        if (child != null && parent != null)
            return AMS_HierarchyHelper.reparentChildSA(child.Id, parent.Id, accounts, hierarchyRelationships);

        throw new AMSException('Data inconsistency issue.');

    }

    public static boolean performOscarValidations(Set<String> toclist, Set<Id> agenciesAffected, AMS_OSCAR__c oscar, Map<Id, Account> accounts, Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships, Map<ID,AMS_Pax_Accreditation_Form__c> stagingAreas) {

        boolean validationsPassed = true;
        Set<Id> agenciesToMigrate = new Set<Id>(agenciesAffected);
        agenciesToMigrate.add(oscar.Account__c);

        //Do not allow change of ownerships that leave an hierarchy without an HO
        if (tocList.contains(AMS_Utils.OWNERSHIP_IATA) || tocList.contains(AMS_Utils.OWNERSHIP_NON_IATA)) {
            //Set<Id> agenciesToMigrate = new Set<Id>(agenciesAffected);
            //agenciesToMigrate.add(oscar.Account__c);
            Set<Id> agenciesNotMigrated = AMS_HierarchyHelper.getAccountNotMigrated(accountHierarchyRelationships.get(oscar.Account__c), agenciesToMigrate);
            String error = AMS_HierarchyHelper.validateIncompleteMigration(agenciesNotMigrated);
            if (error != null){
                oscar.addError(error);
                validationsPassed=false;
            }
        }

        if (tocList.contains(AMS_Utils.OWNERSHIP_IATA) && oscar.AMS_Target_Agency__c == null){
            oscar.AMS_Target_Agency__c.addError('The field "Target Agency" is mandatory when a change of ownership to IATA agent is being performed.');
            validationsPassed= false;
        }

        if(tocList.contains(AMS_Utils.REMOVALTRADENAME) && (stagingAreas.get(oscar.AMS_Online_Accreditation__c)==null || !String.isBlank(stagingAreas.get(oscar.AMS_Online_Accreditation__c).Trade_Name__c))){
            oscar.AMS_Target_Agency__c.addError('If the type of change includes "'+AMS_Utils.REMOVALTRADENAME+'" the field Trade Name must be empty.');
            validationsPassed= false;
        }


        Account oscarAccount = accounts.get(oscar.Account__c);
        if (tocList.contains(AMS_Utils.LOCATION_TYPE)){
            //block change of location type in Head Office
            if(oscarAccount.Location_Type__c.equalsIgnoreCase(AMS_Utils.HO) || oscarAccount.Location_Type__c.equalsIgnoreCase(AMS_Utils.AO)){
                oscar.addError('OSCAR for Change of Location Type cannot be performed in an HO.');
                validationsPassed=false;
            }

            else if(oscarAccount.Location_Type__c.equalsIgnoreCase(AMS_Utils.BR)){
                if(oscar.Change_of_location_type_behavior__c == AMS_Utils.CHLOCTYPEBEHAVIOR_NOSWAP){
                    oscar.Change_of_location_type_behavior__c.addError('The field Change of location type behavior cannot have value Dont change the parent when the OSCAR is opened for a Branch.');
                    validationsPassed=false;
                }
            }
            //do not allow change of location type behaviour to be dont change the parent when the oscar agency is directly under an HO
            else if(oscarAccount.Parent.Location_Type__c.equalsIgnoreCase(AMS_Utils.HO) || oscarAccount.Parent.Location_Type__c.equalsIgnoreCase(AMS_Utils.AO)){
                if(oscar.Change_of_location_type_behavior__c == AMS_Utils.CHLOCTYPEBEHAVIOR_NOSWAP){
                    oscar.Change_of_location_type_behavior__c.addError('The field Change of location type behavior cannot have value Dont change the parent when the oscar is opened for an account directly under an HO.');
                    validationsPassed=false;
                }
            }

        }else{
            //Only allowed to be filled in for change of Location Type
            if(oscar.Change_of_location_type_behavior__c != null){
                oscar.Change_of_location_type_behavior__c.addError('The field Change of location type behavior can only be filled for changes of Location Type.');
                validationsPassed=false;
            }
        }


        //Target Agency field validations
        if (oscar.AMS_Target_Agency__c != null){
            //Target Agency field only allowed on change of ownership iata to iata and change of Location or Location with Inspection
            if (tocList.contains(AMS_Utils.LOCATION) || tocList.contains(AMS_Utils.LOCATION_INSPECTION) || tocList.contains(AMS_Utils.OWNERSHIP_IATA)){

                if(tocList.contains(AMS_Utils.LOCATION) || tocList.contains(AMS_Utils.LOCATION_INSPECTION)){
                    /*if(!oscarAccount.Location_Type__c.equalsIgnoreCase(AMS_Utils.SA)){
                        oscar.AMS_Target_Agency__c.addError('A change of location for an agency which is not an “SA” cannot specify a target agency');
                        validationsPassed=false;
                    }
                    else */if((tocList.contains(AMS_Utils.OWNERSHIP_IATA) || tocList.contains(AMS_Utils.OWNERSHIP_NON_IATA)) && oscarAccount.Location_Type__c.equalsIgnoreCase(AMS_Utils.SA)){
                        oscar.AMS_Target_Agency__c.addError('A change of location for an SA agency, which specify a target agency, cannot be mixed with a change of ownership');
                        validationsPassed=false;
                    }

                }
                //Target agency -> A validation must ensure that only accounts with location type “HO” or “BR” should be selected.
                Account target = accounts.get(oscar.AMS_Target_Agency__c);
                if(target != null)
                    if(target.Location_Type__c != AMS_Utils.BR && target.Location_Type__c != AMS_Utils.HO && target.Location_Type__c != AMS_Utils.AO){
                        oscar.AMS_Target_Agency__c.addError('The target Agency Location Type must be either HO, AO or BR');
                        validationsPassed=false;
                    }

            }
            else{
                oscar.AMS_Target_Agency__c.addError('Target Agency field can only be filled for the following types of changes: Ownership to IATA Agent, Location and Location with inspection.');
                validationsPassed=false;
            }
        }

        //When performing change of shareholding all active hierarchy agencies must be selected
        if (tocList.contains(AMS_Utils.MAJ_SHAREHOLDING) || tocList.contains(AMS_Utils.MIN_SHAREHOLDING) ) {
            System.debug('Agencies Affected: ' + agenciesToMigrate);
            System.debug('Hierarchy Agencies: ' + accountHierarchyRelationships.get(oscar.Account__c));
            if(!AMS_HierarchyHelper.isAllHierarchySelected(agenciesToMigrate, accountHierarchyRelationships.get(oscar.Account__c), accounts)){
                oscar.addError('When performing a change of shareholding all the active agencies in the hierarchy must be selected.');
                validationsPassed=false;
            }
        }
        //When performing change of shareholding all active hierarchy agencies must be selected
        if (tocList.contains(AMS_Utils.MAJ_SHAREHOLDING) || tocList.contains(AMS_Utils.MIN_SHAREHOLDING) ) {
            System.debug('Agencies Affected: ' + agenciesToMigrate);
            System.debug('Hierarchy Agencies: ' + accountHierarchyRelationships.get(oscar.Account__c));
            if(!AMS_HierarchyHelper.isAllHierarchySelected(agenciesToMigrate, accountHierarchyRelationships.get(oscar.Account__c), accounts)){
                oscar.addError('When performing a change of shareholding all the active agencies in the hierarchy must be selected.');
                validationsPassed=false;
            }
        }

        //When performing change of remittance frequency (VMFR) all active hierarchy agencies (except for BRs abroad) must be selected
        if (tocList.contains(AMS_Utils.VFMR) ) {
            System.debug('Agencies Affected: ' + agenciesToMigrate);
            System.debug('Hierarchy Agencies: ' + accountHierarchyRelationships.get(oscar.Account__c));
            if(!AMS_HierarchyHelper.isAllHierarchySelectedExcludeAbroad(agenciesToMigrate, accountHierarchyRelationships.get(oscar.Account__c), accounts)){                 
                oscar.addError('When performing a change of remittance frequency (VMFR) all the active agencies in the hierarchy must be selected. Only branches abroad can be excluded');
                validationsPassed=false;
            }
        }

        return validationsPassed;

    }


    private static void updateCaseInfo() {

        Map<Id, AMS_OSCAR__c> oldMap = (Map<Id,AMS_OSCAR__c>) Trigger.oldMap;
        Map<Id, AMS_OSCAR__c> newMap = (Map<Id,AMS_OSCAR__c>) Trigger.newMap;

        List<AMS_OSCAR__c> updatedOscars = new List<AMS_OSCAR__c>();
        for(AMS_OSCAR__c oscar : (List<AMS_OSCAR__c>)Trigger.New){
            if(
                (oscar.Status__c != null && oscar.Status__c != oldMap.get(oscar.Id).Status__c)
                || oscar.OwnerId != oldMap.get(oscar.Id).OwnerId
                || (oscar.Sanity_check_results__c == AMS_Utils.PASSED && oldMap.get(oscar.Id).Sanity_check_results__c != AMS_Utils.PASSED && oscar.Process__c != AMS_Utils.VOLRELINQUISH)
                || (oscar.Termination_Date__c != oldMap.get(oscar.Id).Termination_Date__c && oscar.Process__c == AMS_Utils.VOLRELINQUISH)
                || (oscar.Process__c == AMS_Utils.NGCHANGES && newMap.get(oscar.Id).ANG_Type_Of_Change__c != oldMap.get(oscar.Id).ANG_Type_Of_Change__c )
            ){
                updatedOscars.add(oscar);
            }
        }

        if(updatedOscars.isEmpty()) return;

        List<Case> casesToUpdate = new List<Case>();
        for(Case c : [SELECT Id, Status, OwnerId, Oscar__c, Process_Start_Date__c from CASE WHERE Oscar__c != null AND RecordType.Name = 'OSCAR Communication' AND Oscar__c IN :updatedOscars])
                        //AND ((Oscar__r.Process__c = 'BANK.ACCOUNT.CHANGES' AND ParentId = null) OR (Oscar__r.Process__c != 'BANK.ACCOUNT.CHANGES'))]) --> CB - 6 APR 2017 - AMS Enhancements AMSU-2
                        {

            AMS_OSCAR__c updatedOSCAR = newMap.get(c.Oscar__c);
            Boolean caseChanged = false;

            if ( AMS_OSCARTriggerHandler.closedStatusMapping.containsKey(updatedOSCAR.Status__c) ) {
                String closedStatus = AMS_OSCARTriggerHandler.closedStatusMapping.get(updatedOSCAR.Status__c);
                if(c.Status != closedStatus){
                    c.Status = closedStatus;
                    caseChanged = true;
                }
            }else if(c.Status != updatedOSCAR.Status__c){
                c.Status = updatedOSCAR.Status__c;
                caseChanged = true;
            }

            if(c.OwnerId != updatedOSCAR.OwnerId){
                c.OwnerId = updatedOSCAR.OwnerId;
                caseChanged = true;
            }
            if(c.Process_Start_Date__c == null && updatedOSCAR.Process__c != AMS_Utils.VOLRELINQUISH){
                c.Process_Start_Date__c = updatedOSCAR.Sanity_check_received__c;
                caseChanged = true;
            }
            if(c.Process_Start_Date__c != updatedOSCAR.Termination_Date__c && updatedOSCAR.Process__c == AMS_Utils.VOLRELINQUISH){
                c.Process_Start_Date__c = updatedOSCAR.Termination_Date__c;
                caseChanged = true;
            }
            if(newMap.get(updatedOSCAR.Id).Process__c == AMS_Utils.NGCHANGES && newMap.get(updatedOSCAR.Id).ANG_Type_Of_Change__c != oldMap.get(updatedOSCAR.Id).ANG_Type_Of_Change__c ){
                
                String newReason = fetchCaseReason(newMap.get(updatedOSCAR.Id).ANG_Type_Of_Change__c);
                
                if(newReason != null){
                    c.Reason1__c = newReason;
                    caseChanged = true;
                }
            }

            if(caseChanged) casesToUpdate.add(c);
        }

        if(!casesToUpdate.isEmpty()) update casesToUpdate;
    }

    // Create portal notifications for the HO's portal admin when NoC and Change of Bank Details OSCARs submitted by a BR contact are finalized
    private static void createHoAdminNotifications() {
        system.debug('createHoAdminNotifications: enter ');
        set<Id> setInvolvedAcctIds = new set<Id>();
        map<Id, AMS_OSCAR__c> lstOscarsToNotify = new map<Id, AMS_OSCAR__c>();
        list<Notification__c> lstNotificationsToCreate = new list<Notification__c>();

        for (AMS_OSCAR__c oscar : (List<AMS_OSCAR__c>)Trigger.new) {
            AMS_OSCAR__c oldOscar = (AMS_OSCAR__c)Trigger.oldMap.get(oscar.Id);
            if (oscar.Finalization_result__c == AMS_Utils.PASSED && oldOscar.Finalization_result__c != AMS_Utils.PASSED && ( oscar.Process__c == AMS_Utils.BANKACCCHANGES || oscar.Process__c == AMS_Utils.AGENCYCHANGES ) ) {
                setInvolvedAcctIds.add(oscar.Account__c);
                lstOscarsToNotify.put(oscar.Id, oscar);
            }
        }
        system.debug('createHoAdminNotifications: setInvolvedAcctIds :' + setInvolvedAcctIds);

        if (setInvolvedAcctIds.isEmpty()) return;

        map<Id, Account> mapInvolvedAccountsPerId = new map<Id, Account>([SELECT Id, IATACode__c, Top_Parent__c, Top_Parent__r.IATACode__c FROM Account WHERE Id IN :setInvolvedAcctIds]);

        set<Id> setBRAccountIds = new set<Id>();
        set<Id> setHOAccountIds = new set<Id>();

        for (Account acc : mapInvolvedAccountsPerId.values()) 
            if (acc.Top_Parent__c != null) {
                setBRAccountIds.add(acc.Id);
                setHOAccountIds.add(acc.Top_Parent__c);
            }
        system.debug('createHoAdminNotifications: setBRAccountIds :' + setBRAccountIds);

        if (setBRAccountIds.isEmpty()) return; // if empty it means all involved accounts are HOs so there's no OSCAR from a BR account, so we can stop

        // get HO portal admin contacts-list per account
        map<Id, list<Contact>> mapAdminContactsPerHOId = new map<Id, list<Contact>>();
        for (Contact con : [SELECT Id, Email, AccountId, User_Portal_Status__c FROM Contact WHERE AccountId IN :setHOAccountIds AND IsEmailBounced = false AND User_Portal_Status__c = 'Approved Admin']) {
            if (mapAdminContactsPerHOId.get(con.AccountId) != null) 
                mapAdminContactsPerHOId.get(con.AccountId).add(con);
            else 
                mapAdminContactsPerHOId.put(con.AccountId, new list<Contact>{con});
            
        }

        // get related cases
        map<Id, Case> mapCasesPerOscarId = new map<Id, Case>();
        for (Case c : [SELECT Id, CaseNumber, Oscar__c FROM Case WHERE Oscar__c IN :lstOscarsToNotify.keyset()]) {
            mapCasesPerOscarId.put(c.Oscar__c, c);
        }
        
        try {
            for (AMS_OSCAR__c oscar : lstOscarsToNotify.values()) {
                if (setBRAccountIds.contains(oscar.Account__c) && mapAdminContactsPerHOId.get(mapInvolvedAccountsPerId.get(oscar.Account__c).Top_Parent__c) != null) { // only notify if case is from BR & there is an admin contact on HO
                    for (Contact con : mapAdminContactsPerHOId.get(mapInvolvedAccountsPerId.get(oscar.Account__c).Top_Parent__c)) {

                        Notification__c notification = new Notification__c();
                        notification.Contact__c = con.Id;
                        notification.Type__c= 'Information';
                        notification.Notificatin_color__c = '#007FFF';
                        notification.Alert_Contact_By_Email__c = true;
                        notification.Expiry_date__c = Datetime.now().addDays(14);
                        notification.Subject__c = (oscar.Process__c == AMS_Utils.BANKACCCHANGES ? 'Change of Bank Account Details' : 'Notice of Change') + ' from branch ' + mapInvolvedAccountsPerId.get(oscar.Account__c).IATACode__c + ' finalized';
                        notification.Message__c = '<p>A ' + (oscar.Process__c == AMS_Utils.BANKACCCHANGES ? 'Change of Bank Account Details' : 'Notice of Change') + ' case submitted from one of your branch accounts, with IATA Code ' + mapInvolvedAccountsPerId.get(oscar.Account__c).IATACode__c + ', has been finalized.<br/>';
                        notification.Message__c+= 'Case number: <a href="/ISSP_Case?caseId=' + mapCasesPerOscarId.get(oscar.Id).Id + '">' + mapCasesPerOscarId.get(oscar.Id).CaseNumber + '</a></p>';

                        lstNotificationsToCreate.add(notification);
                    }
                }
            }
            system.debug('createHoAdminNotifications: lstNotificationsToCreate :' + lstNotificationsToCreate);

            if (!lstNotificationsToCreate.isEmpty()) 
                insert lstNotificationsToCreate;

        } catch (Exception e) {
            system.debug('Add notification ERROR: ' + e.getmessage());
        }
    }

    public static String fetchCaseReason(String typeOfChange){

        if(typeOfChange == null || typeOfChange == '')
            return 'Agency Changes';
        if(typeOfChange.contains('Location type')) 
            return 'CHG – Data Maintenance';
        if(typeOfChange.contains('Ownership') || typeOfChange.contains('Legal status')) 
            return 'CHO / CHS – Change of Ownership / Legal Status';
        if(typeOfChange.contains('Major shareholding')) 
            return 'CHC – Change of Shareholding';
        if(typeOfChange.contains('Location') || typeOfChange.contains('Location type to different legal entity')) 
            return 'CHL - Change of Location';
        if(typeOfChange.contains('Legal name')) 
            return 'CHN - Change of Name';
        if(typeOfChange.contains('VMFR')) 
            return 'VMFR Setup/Update';
        if(typeOfChange.contains('Minor shareholding')) 
            return 'CHG – Data Maintenance';
        if(typeOfChange.contains('Hierarchy')) 
            return 'Change of Hierarchy';
        if(typeOfChange.contains('Accreditation type'))
            return 'Accreditation Type';
        if(typeOfChange.contains('Trade name'))
            return 'Change of Trade Name';

        return null;
    }

    //TD: udpate case reason. Used for calculating KPIs
    public static void updateCaseKPIFields() {

        Map<Id, AMS_OSCAR__c> oldMap = (Map<Id,AMS_OSCAR__c>) Trigger.oldMap;

        Map<Id, AMS_OSCAR__c> mapOscars = new Map<Id, AMS_OSCAR__c>();
        for (AMS_OSCAR__c oscar : (List<AMS_OSCAR__c>)Trigger.New ) {
            if (
                    Trigger.isInsert ||
                    (
                        (oscar.Reason_For_KPI__c != oldMap.get(oscar.id).Reason_For_KPI__c) ||
                        (oscar.Process_Start_Date__c != oldMap.get(oscar.id).Process_Start_Date__c) ||
                        (oscar.Dossier_Reception_Date__c != oldMap.get(oscar.id).Dossier_Reception_Date__c)
                    )
                )
                mapOscars.put(oscar.id, oscar);
        }

        if(mapOscars.isEmpty()) return;

        try {
            List<Case> lsCaseToUpdate = new List<Case>();
            for(case ca:[select id, Reason1__c, OSCAR__c, Account.IATA_ISO_Country__r.Name, Account.Region_Formula__c from Case where OSCAR__c in:mapOscars.keySet() AND RecordType.Name = 'OSCAR Communication' AND ( ParentId = null or Parent.RecordType.Name != 'OSCAR Communication' )]){
                lsCaseToUpdate.add(new case(id = ca.id
                                            , Reason1__c = mapOscars.get(ca.OSCAR__C).Reason_For_KPI__c != null ? mapOscars.get(ca.OSCAR__C).Reason_For_KPI__c : ca.Reason1__c
                                            , Process_Start_Date__c = mapOscars.get(ca.OSCAR__C).Process_Start_Date__c
                                            , BSPCountry__c = ca.Account.IATA_ISO_Country__r.Name
                                            , Region__c = ca.Account.Region_formula__c
                                            , Dossier_reception_date__c = mapOscars.get(ca.OSCAR__C).Dossier_Reception_Date__c));
            }

            if(!lsCaseToUpdate.isEmpty())
                update lsCaseToUpdate;
        } catch (exception e) {
            system.debug('DTULLO 39 --> exception --> ' + e.getMessage());
        }
    }

    //the oscar process requires updates on the accounts on 2 situations
    //-when a change code is generated (in this situation only the status is updated)
    //-when migrating fields from staging area to master data
    //because the above situations are done in separate ocasions, we need to merge the account updates in only one list
    //to prevent double update on accounts
    private static List<Account> mergeAccountsToUpdate(List<Account> accountUpdatesFromChangeCodes, List<Account> accountUpdatesFromStagingArea){

        List<Account> mergedAccountsToUpdate = new List<Account>();

        //gather all account Ids into a set
        Map<Id, Account> mapA = new Map<Id, Account>(accountUpdatesFromStagingArea);
        Map<Id, Account> mapB = new Map<Id, Account>(accountUpdatesFromChangeCodes);


        Set<Id> allAccountsToUpdateIds = new Set<Id>();
        allAccountsToUpdateIds.addAll(mapA.keySet());
        allAccountsToUpdateIds.addAll(mapB.keySet());

        for(Id accId: allAccountsToUpdateIds){
            Account a;
            if(mapA.containsKey(accId))
                a = mapA.get(accId);
            if(mapB.containsKey(accId))
                if(a == null)
                    a = mapB.get(accId);
                else
                    a.Status__c = mapB.get(accId).Status__c;

            System.debug(loggingLevel.ERROR, '____ [cls AMS_OSCARTriggerHandler - mergeAccountsToUpdate] a - ' + a);
            if(a!=null)
                mergedAccountsToUpdate.add(a);
        }

        return mergedAccountsToUpdate;

    }

    private static void handleCargoAgencyRegulations(){

        //Check if agency is a Cargo Agent
        List<AMS_OSCAR__c> oscarsToProcess = new List<AMS_OSCAR__c>();

        Map<Id, AMS_OSCAR__c> oldMap = (Map<Id,AMS_OSCAR__c>) Trigger.oldMap;

        Map<Id,AMS_OSCAR__c> oscarAux = new Map<Id, AMS_OSCAR__c>([SELECT Id, Account__r.Sector__c, Account__r.CNS_Agency__c FROM AMS_OSCAR__c WHERE Id IN :Trigger.New]);

        //check which oscars are related to Cargo Agencies and have passed sanity check
        //for(AMS_OSCAR__c oscar:[SELECT Id, Account__r.Sector__c FROM AMS_OSCAR__c WHERE Id IN :Trigger.New]){
        for(AMS_OSCAR__c oscar:(List<AMS_OSCAR__c>)Trigger.New){
            if ((oscar.RecordTypeId == AMS_Utils.RECTYPE_NEW || oscar.RecordTypeId == AMS_Utils.RECTYPE_CERT) && oldMap.get(oscar.Id).STEP6__c <> AMS_Utils.PASSED && oscar.STEP6__c == AMS_Utils.PASSED){

                if(oscarAux.get(oscar.Id).Account__r.Sector__c == AMS_Utils.SECTOR_CARGO)
                    oscarsToProcess.add(oscar);
            }
        }
        
        if(!oscarsToProcess.isEmpty()){
            List<AMS_OSCAR__c> oscarsToValidate = new List<AMS_OSCAR__c>();                 
            for(AMS_OSCAR__c oscar : oscarsToProcess){
                
                // bypass validation for CNS if Custom Setting is not enabled
                if(!oscarAux.get(oscar.Id).Account__r.CNS_Agency__c || (oscarAux.get(oscar.Id).Account__r.CNS_Agency__c && CNS_Settings__c.getInstance().DGR_Validate_Certificates__c))
                    oscarsToValidate.add(oscar);
            }
            
            if(oscarsToValidate.isEmpty() == false)
                validateCertificates(oscarsToValidate);

            createCargoAgencyRegulations(oscarsToProcess);
        }

    }

    private static void createCargoAgencyRegulations(List<AMS_OSCAR__c> oscars){

        List<AMS_Agency_Regulation__c> agencyregulationsToCreate = new List<AMS_Agency_Regulation__c>();
        Set<Id> onlineAccreditations = new Set<Id>();
        Set<Id> agencyRegulations = new Set<Id>();

        for(AMS_OSCAR__c oscar: oscars)
            onlineAccreditations.add(oscar.AMS_Online_Accreditation__c);

        //get the accreditation contacts from the staging area
        //all the trained staff accreditation contacts must generate an Agency Regulation object
        List<AMS_Accreditation_Contact__c> acToGenerateAgencyRegulation = new List<AMS_Accreditation_Contact__c>([
                                                                            SELECT Id, First_name__c, Last_name__c, AMS_Pax_Accreditation_Form__r.SAAM_Case__r.Oscar__r.Account__c,
                                                                            Certificate_Name__c, Certificate_Issued_on__c, Type_of_Certificate__c, Certificate_Validity__c, Valid_until__c,
                                                                            Certificate_Issuer__c, AMS_Pax_Accreditation_Form__r.SAAM_Case__r.Oscar__c, Position_trained_staff__c, AgencyRegulation__c,
                                                                            Air_cargo_transport_business_exp__c, IATA_FIATA_training_history__c, Training_dangerous_goods_completed__c, Registration_number__c
                                                                            FROM AMS_Accreditation_Contact__c
                                                                            WHERE AMS_Pax_Accreditation_Form__c IN :onlineAccreditations
                                                                            AND RecordTypeId = :AMS_Utils.AccreditationContactTrainedStaffRT]);

        for(AMS_Accreditation_Contact__c ac: acToGenerateAgencyRegulation)
            if(ac.AgencyRegulation__c!=null)
                agencyRegulations.add(ac.AgencyRegulation__c);

        for(AMS_Accreditation_Contact__c ac: acToGenerateAgencyRegulation){

            AMS_Agency_Regulation__c agReg = new AMS_Agency_Regulation__c();

            if(ac.AgencyRegulation__c != null)
                agReg.Id = ac.AgencyRegulation__c;

            agReg.Certificate_Name__c = ac.Certificate_Name__c;
            agReg.Issued_on__c = ac.Certificate_Issued_on__c;
            agReg.Type_Of_Certificate__c = ac.Type_of_Certificate__c;
            agReg.Validity__c = ac.Certificate_Validity__c;
            agReg.First_Name__c = ac.First_name__c;
            agReg.Last_name__c = ac.Last_name__c;
            agReg.Issuer__c = ac.Certificate_Issuer__c;
            if(ac.AgencyRegulation__c == null)
                agReg.Account__c = ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.Oscar__r.Account__c;
            agReg.Position__c = ac.Position_trained_staff__c;
            agReg.Expiry_Date__c = ac.Valid_until__c;
            agReg.Oscar__c = ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.Oscar__c;

            //make sure the notification sent field in reset
            agReg.Notification_Sent__c = false;
            agReg.Air_cargo_transport_business_exp__c = ac.Air_cargo_transport_business_exp__c;
            agReg.IATA_FIATA_training_history__c = ac.IATA_FIATA_training_history__c;
            agReg.Training_dangerous_goods_completed__c = ac.Training_dangerous_goods_completed__c;
            agReg.Registration_Number__c = ac.Registration_number__c; //AMSU-14

            agencyregulationsToCreate.add(agReg);

        }

        if(!agencyregulationsToCreate.isEmpty())
            upsert agencyregulationsToCreate;
    }

    private static void validateCertificates(List<AMS_OSCAR__c> oscars){

        //If an agency is handling dangerous goods, then it must
        //- Have 2 DGR or DGA if it is an HO
        //- Have 1 DGR or DGA if it is a BR
        Set<Id> onlineAccreditations = new Set<Id>();
        Set<Id> oscarIds = new Set<Id>();
        Map<Id, List<AMS_Accreditation_Contact__c>> trainedStaffPerAccount = new Map<Id, List<AMS_Accreditation_Contact__c>>();
        Set<Id> isoCountries = new Set<Id>();

        for(AMS_OSCAR__c oscar: oscars){
            onlineAccreditations.add(oscar.AMS_Online_Accreditation__c);
            oscarIds.add(oscar.Id);
        }

        List<AMS_OSCAR__c> oscarsList = new List<AMS_OSCAR__c>([SELECT Id, RecordTypeId, Account__c, AMS_Online_Accreditation__r.Location_Type__c, AMS_Online_Accreditation__r.Location_Class__c, AMS_Online_Accreditation__r.Is_your_firm_handling_Dangerous_Goods__c, AMS_Online_Accreditation__r.Branch_Office_Country__c, AMS_Online_Accreditation__r.Branch_Office_Country__r.ISO_Code__c, AMS_Online_Accreditation__r.CASS_Number__c FROM AMS_OSCAR__c WHERE Id IN :oscarIds]);

        for(AMS_OSCAR__c oscar: oscarsList)
            isoCountries.add(oscar.AMS_Online_Accreditation__r.Branch_Office_Country__c);

        //get all non expired trained staff
        List<AMS_Accreditation_Contact__c> allTrainedStaff = new List<AMS_Accreditation_Contact__c>(  [SELECT Id, Type_Of_Certificate__c, Valid_until__c, AMS_Pax_Accreditation_Form__r.SAAM_Case__r.Oscar__r.Account__c
                                                                                                    FROM AMS_Accreditation_Contact__c
                                                                                                    WHERE AMS_Pax_Accreditation_Form__c IN :onlineAccreditations
                                                                                                    AND RecordTypeId = :AMS_Utils.AccreditationContactTrainedStaffRT /*AND Valid_until__c > TODAY*/]);
        Id tsAccount = null;
        for(AMS_Accreditation_Contact__c trainedStaff :allTrainedStaff){

            System.debug('OSCARTriggerHandler -> validateCertificates: Found trained staff ' + trainedStaff);

            tsAccount = trainedStaff.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.Oscar__r.Account__c;

            if(!trainedStaffPerAccount.containsKey(tsAccount))
                trainedStaffPerAccount.put(tsAccount, new List<AMS_Accreditation_Contact__c>());

            trainedStaffPerAccount.get(tsAccount).add(trainedStaff);
        }

        system.debug('validateCertificates -> isoCountries ' + isoCountries);

        //minimum requirements for location class 'R'
        Map<String, Integer> minimumHODgrRequirements = new Map<String, Integer>();
        Map<String, Integer> minimumBRDgrRequirements = new Map<String, Integer>();
        for(IATA_ISO_Country__c country : [SELECT Id, (SELECT Id, Minimum_DGR_BR__c, Minimum_DGR_HO__c, Location_Class__c
                                                       FROM AMS_Country_Specific_Attributes__r
                                                       WHERE RecordType.Name = 'DGR Minimum Requirements')
                                           FROM IATA_ISO_Country__c
                                           WHERE Id IN :isoCountries])
        {
            system.debug('validateCertificates -> country.AMS_Country_Specific_Attributes__r ' + country.AMS_Country_Specific_Attributes__r);
            for(AMS_Country_Specific_Attribute__c att : country.AMS_Country_Specific_Attributes__r){
                if(att != null){
                    minimumHODgrRequirements.put(''+country.Id+att.Location_Class__c, att.Minimum_DGR_HO__c == null ? 0 : Integer.valueOf(att.Minimum_DGR_HO__c));
                    minimumBRDgrRequirements.put(''+country.Id+att.Location_Class__c, att.Minimum_DGR_BR__c == null ? 0 : Integer.valueOf(att.Minimum_DGR_BR__c));
                }
            }
        }

        system.debug('validateCertificates -> minimumHODgrRequirements ' + minimumHODgrRequirements);
        system.debug('validateCertificates -> minimumBRDgrRequirements ' + minimumBRDgrRequirements);

        for(AMS_OSCAR__c oscar: oscarsList){
            if(oscar.RecordTypeId == AMS_Utils.RECTYPE_NEW || oscar.RecordTypeId == AMS_Utils.RECTYPE_NEWHE || oscar.RecordTypeId == AMS_Utils.RECTYPE_CERT){
                String locationClass = oscar.AMS_Online_Accreditation__r.Location_Class__c;
                String locationType = oscar.AMS_Online_Accreditation__r.Location_Type__c;
                System.debug('OSCARTriggerHandler -> validateCertificates: all trained staff ' + trainedStaffPerAccount.get(oscar.Account__c));
                String key = oscar.AMS_Online_Accreditation__r.Branch_Office_Country__c + locationClass;
                system.debug('validateCertificates - key -> ' + key);
                Integer minDgrHO = minimumHODgrRequirements.get(key) == null ? 0 : minimumHODgrRequirements.get(key);
                system.debug('validateCertificates -> minDgrHO ' + minDgrHO);
                Integer minDgrBR = minimumBRDgrRequirements.get(key) == null ? 0 : minimumBRDgrRequirements.get(key);
                system.debug('validateCertificates -> minDgrBR ' + minDgrBR);

                String countryCode = oscar.AMS_Online_Accreditation__r.Branch_Office_Country__r.ISO_Code__c;

                if(oscar.AMS_Online_Accreditation__r.CASS_Number__c != null){
                    Integer cassNumber = Integer.valueOf(oscar.AMS_Online_Accreditation__r.CASS_Number__c);

                    System.debug('CHECK CASS: ' + oscar.AMS_Online_Accreditation__r.CASS_Number__c);

                    if(oscar.AMS_Online_Accreditation__r.Is_your_firm_handling_Dangerous_Goods__c == 'No'){
                        //If an agency is non handling, it must have a certificate of awareness (DGA)
                        if(oscar.AMS_Online_Accreditation__r.Location_Type__c == AMS_Utils.HO || oscar.AMS_Online_Accreditation__r.Location_Type__c == AMS_Utils.BR){
                            System.debug('OSCARTriggerHandler -> validateCertificates: Non handling '+ oscar.AMS_Online_Accreditation__r.Location_Type__c + ' agency.');
                            checkCertifications(trainedStaffPerAccount.get(oscar.Account__c), locationType, false, locationClass, countryCode, minDgrHO, minDgrBR, cassNumber);
                        }
                    }else{
                        //RB: Here We will select only the DGR trained staff, which must have a Valid until date
                        Map<Id, List<AMS_Accreditation_Contact__c>> trainedStaffDGR = new Map<Id, List<AMS_Accreditation_Contact__c>>();        
                        List<AMS_Accreditation_Contact__c> listDGR = new List<AMS_Accreditation_Contact__c>();
                        
                        trainedStaffDGR.put(tsAccount, new List<AMS_Accreditation_Contact__c>());

                        for(AMS_Accreditation_Contact__c trainedStaffToRemove: allTrainedStaff) {
                            system.debug('DDD trainedStaffToRemove:'  + trainedStaffToRemove);              
                            if( (trainedStaffToRemove.Type_Of_Certificate__c == AMS_Utils.CERT_DGR || trainedStaffToRemove.Type_Of_Certificate__c == AMS_Utils.CERT_CATA)  && trainedStaffToRemove.Valid_until__c != null){
                                //trainedStaffDGR.put(tsAccount, new List<AMS_Accreditation_Contact__c>());
                                trainedStaffDGR.get(tsAccount).add(trainedStaffToRemove);
                            }
                        }

                        system.debug('Trained staff to remove: '+ trainedStaffDGR);
                        system.debug('All Trained staff: '+ allTrainedStaff);

                        checkCertifications(trainedStaffDGR.get(oscar.Account__c), locationType, true, locationClass, countryCode, minDgrHO, minDgrBR, cassNumber, oscar.RecordTypeId);
                    }
                }else{
                    for(AMS_OSCAR__c o : oscars){
                        if(o.Id == oscar.Id){
                            o.addError('Error! C, I, R, Q and G Location Types must have a CASS number defined.');
                            return;
                        }
                    }
                }
            }
        }
    }

    private static void checkCertifications(List<AMS_Accreditation_Contact__c> trainedStaff, String accountLocationType, boolean handling, String locationClass, String countryCode, Integer minimumHODgrRequirements, Integer minimumBRDgrRequirements, Integer cassNumber){
		checkCertifications(trainedStaff, accountLocationType, handling, locationClass, countryCode, minimumHODgrRequirements, minimumBRDgrRequirements, cassNumber, null);
		
	}
	
	private static void checkCertifications(List<AMS_Accreditation_Contact__c> trainedStaff, String accountLocationType, boolean handling, String locationClass, String countryCode, Integer minimumHODgrRequirements, Integer minimumBRDgrRequirements, Integer cassNumber, Id oscarRecordType) {
        Integer numberDGR = 0;
        Integer numberDGA = 0;
        Integer numberCATA = 0;

		
		//AMSU-34
		Date todayDate = System.today();
		Boolean incorrectExpiryDate = false;
		String incorrectExpiryDateError = ' Incorrect Expiry Date on DGR Certificate, less than 90 days!';
		
		System.debug('OSCARTriggerHandler -> checkCertifications: todayDate ' + todayDate);
		
		if(trainedStaff != null){
				for(AMS_Accreditation_Contact__c tStaff :trainedStaff){
					if(tStaff.Type_Of_Certificate__c == AMS_Utils.CERT_DGR) {
						//AMSU-34
						Date checkDate = tStaff.Valid_until__c.addDays(-90);
						if(checkDate < todayDate){
							incorrectExpiryDate = true;
						} else {
							numberDGR++;
						}
					} else if(tStaff.Type_Of_Certificate__c == AMS_Utils.CERT_CATA)
						numberCATA++;
					else if(tStaff.Type_Of_Certificate__c == AMS_Utils.CERT_DGA)
						numberDGA++;
			}
		}

        System.debug('OSCARTriggerHandler -> checkCertifications: number of DGR ' + numberDGR);
        System.debug('OSCARTriggerHandler -> checkCertifications: number of DGA ' + numberDGA);
        System.debug('OSCARTriggerHandler -> checkCertifications: number of CATA ' + numberDGA);

        System.debug('CHECK VALUES countryCode' + countryCode + ' locationClass ' + locationClass + ' accountLocationType ' + accountLocationType + ' cassNumber ' + cassNumber);

        if(handling){
			//AMSU-34
			if(oscarRecordType != null && oscarRecordType == AMS_Utils.RECTYPE_CERT){
				if(incorrectExpiryDate){
					throw new AMSException('##' + incorrectExpiryDateError + '##' );
				}
			} else { 
				if(countryCode == 'CN' && locationClass == 'C' && (numberDGR < 3 || numberCATA < 1)){
					throw new AMSException('##This agency must have at least 3 DGR and 1 CATA that are not expired.' + (incorrectExpiryDate ? incorrectExpiryDateError : '') + '##' );

				}else if(countryCode == 'IN' && locationClass == 'C' && accountLocationType == AMS_Utils.BR && cassNumber >= 900 && cassNumber <= 999){
					 //India has this particular exception to the normal behaviour, no check is to be done
				}else if(locationClass == 'C'){
					if(accountLocationType == AMS_Utils.HO && numberDGR < 2 )
						throw new AMSException('##An HO Agency handling dangerous goods must have at least 2 DGR that are not expired.' + (incorrectExpiryDate ? incorrectExpiryDateError : '') + '##' );
					else if(accountLocationType == AMS_Utils.BR && numberDGR < 1)
						throw new AMSException('##A BR Agency handling dangerous goods must have at least 1 DGR that is not expired.' + (incorrectExpiryDate ? incorrectExpiryDateError : '') + '##' );
				}else if(locationClass == 'R'){
					system.debug('validateCertificates -> locationClass == R');
					//Only America is using DGR for Cass associate.
					if(accountLocationType == AMS_Utils.HO && numberDGR/* + numberDGA*/ < minimumHODgrRequirements )
						throw new AMSException('##This agency must have at least ' + minimumHODgrRequirements + ' DGR that are not expired.' + (incorrectExpiryDate ? incorrectExpiryDateError : '') + '##' );
					else if(accountLocationType == AMS_Utils.BR && numberDGR/* + numberDGA*/ < minimumBRDgrRequirements){
						throw new AMSException('##This agency must have at least ' + minimumBRDgrRequirements + ' DGR that is not expired.' + (incorrectExpiryDate ? incorrectExpiryDateError : '') + '##' );
					}
				}
			}
        }
        else{
            if(locationClass == 'C'){
                if(accountLocationType == AMS_Utils.HO && numberDGA < 2 )
                    throw new AMSException('##An HO Agency not handling dangerous goods must have at least 2 DGA that are not expired.##');
                else if(accountLocationType == AMS_Utils.BR && numberDGA < 1)
                    throw new AMSException('##A BR Agency not handling dangerous goods must have at least 1 DGA that is not expired.##');
            }
            /*if( numberDGA < 1 )
                throw new AMSException('##An Agency not handling dangerous goods must have at least 1 DGA that is not expired.##');*/
        }

    }

    private static void updateOSCARAppointments(){

        List<AMS_OSCAR__c> oscarsToProcess = new List<AMS_OSCAR__c>();
        Set<Id> oscarsToProcessIds = new Set<Id>();
        Set<ID> accountIds = new Set<ID>();
        Map<Id, AMS_OSCAR__c> oldMap = (Map<Id,AMS_OSCAR__c>) Trigger.oldMap;

        for(AMS_OSCAR__c oscar : (List<AMS_OSCAR__c>)Trigger.New){
            if( AMS_Utils.isProcessUsingAppointments(oscar) ){
                oscarsToProcess.add(oscar);
                accountIds.add(oscar.Account__c);
                oscarsToProcessIds.add(oscar.Id);
            }
        }

        if(!oscarsToProcess.isEmpty()){

            List<AMS_Inspection__c> allInspections = new List<AMS_Inspection__c>([SELECT Id, Account__c, Account__r.Location_Class__c, OSCAR__c,OSCAR__r.Account__c, Date_Organisation_Status_attained__c,Last_synchronization__c,Accreditation_Endorsement_Status_code__c FROM AMS_Inspection__c WHERE OSCAR__c IN :oscarsToProcessIds]);

            if(allInspections.isEmpty()){
                allInspections = new List<AMS_Inspection__c>([SELECT Id, Account__c, Account__r.Location_Class__c, OSCAR__c,OSCAR__r.Account__c, Date_Organisation_Status_attained__c,Last_synchronization__c,Accreditation_Endorsement_Status_code__c FROM AMS_Inspection__c WHERE Account__c IN :accountIds]);
            }

            Map<Id, List<AMS_Inspection__c>> inspectionsPerOSCAR = new Map<Id, List<AMS_Inspection__c>>();
            Map<Id, List<AMS_Inspection__c>> inspectionsPerAccount = new Map<Id, List<AMS_Inspection__c>>();

            //get all inspections
            for(AMS_Inspection__c insp: allInspections){
                //inspections per osar
                if(!inspectionsPerOSCAR.containsKey(insp.Oscar__c)){
                    inspectionsPerOSCAR.put(insp.Oscar__c, new List<AMS_Inspection__c>());
                }
                
                inspectionsPerOSCAR.get(insp.Oscar__c).add(insp);

                //inspections per account
                if(!inspectionsPerAccount.containsKey(insp.Account__c)){
                    inspectionsPerAccount.put(insp.Account__c, new List<AMS_Inspection__c>());
                }

                inspectionsPerAccount.get(insp.Account__c).add(insp);

            }

            List<AMS_Inspection__c> allInspectionsToUpdate = new List<AMS_Inspection__c>();

            for(AMS_OSCAR__c oscar : oscarsToProcess){
                AMS_OSCAR__c oldOSCAR = oldMap.get(oscar.Id);

                if ((oldOSCAR.STEP1__c <> AMS_Utils.PASSED && oscar.STEP1__c == AMS_Utils.PASSED)||
                    (oldOSCAR.STEP10__c <> AMS_Utils.PASSED && oscar.STEP10__c == AMS_Utils.PASSED))
                {
                    allInspectionsToUpdate.addAll(AMS_Utils.modifyInspectionStatus(inspectionsPerOSCAR.get(oscar.Id), '9'));
                }
                if ((oldOSCAR.STEP3__c <> AMS_Utils.PASSED && oscar.STEP3__c == AMS_Utils.PASSED) ||
                    (oldOSCAR.STEP18__c <> AMS_Utils.PASSED && oscar.STEP18__c == AMS_Utils.PASSED) ||
                    (oldOSCAR.STEP4__c <> AMS_Utils.PASSED && oscar.STEP4__c == AMS_Utils.PASSED))
                {
                    
                    allInspectionsToUpdate.addAll(AMS_Utils.modifyInspectionStatus(inspectionsPerOSCAR.get(oscar.Id), '0'));
                }
                //For this scenario we need to retrieve the inspections per account in order to update it properly.
                //At this point the existing oscar is the new and empty one
                if (oldOSCAR.STEP31__c <> AMS_Utils.PASSED && oscar.STEP31__c == AMS_Utils.PASSED && oscar.Location_Class__c == 'M'){
                    allInspectionsToUpdate.addAll(AMS_Utils.modifyInspectionStatus(inspectionsPerAccount.get(oscar.Account__c), '0'));   
                }
            }

            //update all modified inspections
            if(!allInspectionsToUpdate.isEmpty())
                update allInspectionsToUpdate;

        }
    }

    private static void handleVRProcess() {

        List<AMS_OSCAR__c> triggerNew = (List<AMS_OSCAR__c>)Trigger.new;
        Map<Id, AMS_OSCAR__c> oldMap = (Map<Id, AMS_OSCAR__c>)Trigger.oldMap;

        Id volRelRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('VOLUNTARY RELINQUISHMENT').getRecordTypeId();
        List<AMS_Oscar__c> oscars = filterOSCARbyRT(volRelRT, triggerNew);

        if(oscars.isEmpty()) return;

        Set<Id> oscarOnlineAccredIds = new Set<Id>();
        Map<Id, Set<Id>> accountsInvolved = new Map<Id, Set<Id>>();

        for (AMS_OSCAR__c oscar : oscars) {
            addAccountId(oscar.Account__c);
            addAccountId(oscar.AMS_Target_Agency__c);
            oscarOnlineAccredIds.add(oscar.AMS_Online_Accreditation__c);
            accountsInvolved.put(oscar.Id, new Set<Id>{oscar.Account__c});
        }

        //find all agencies involved
        //DTULLO: Added Record Type
        for (AMS_Process_Detail__c pd : [SELECT Id, Account__c, OSCAR__c FROM AMS_Process_Detail__c WHERE OSCAR__c IN :oscars AND Account__c != '' and RecordType.Developername = 'Agency_Involved']) {

            accountsInvolved.get(pd.OSCAR__c).add(pd.Account__c);
        }

        //get staging area infos
        Map<Id, AMS_Pax_Accreditation_Form__c> onlineAccreditations = getAccreditations(oscarOnlineAccredIds);

        //need to get all the hierarchy relationships for the account related to each OSCAR
        Map<Id, List<AMS_Agencies_relationhip__c>> relationshipMap = AMS_HierarchyHelper.getAccountsHierarchies(accountIds);

        for (List<AMS_Agencies_relationhip__c> hierarchyRelations : relationshipMap.values()) {
            for (AMS_Agencies_relationhip__c relationship : hierarchyRelations) {

                addAccountId(relationship.Parent_Account__c);
                addAccountId(relationship.Child_Account__c);
            }
        }

        List<AMS_Utils.Container> changesContainer = new List<AMS_Utils.Container>();
        List<AMS_Oscar__c> oscarsToCheckHierarchy = new List<AMS_Oscar__c>();

        for(AMS_OSCAR__c updatedOSCAR : oscars){
            AMS_OSCAR__c oldOSCAR = oldMap.get(updatedOSCAR.Id);


            if (oldOSCAR.Form_Effective_date__c != updatedOscar.Form_Effective_date__c
                || oldOSCAR.Financial_Security_expiry_date__c != updatedOscar.Financial_Security_expiry_date__c) {

                Date formDate = updatedOscar.Form_Effective_date__c;
                Date fsDate = updatedOscar.Financial_Security_expiry_date__c;

                updatedOSCAR.Change_effective_as_of__c = formDate;

                if((fsDate != null && formDate == null) || fsDate < formDate) updatedOSCAR.Change_effective_as_of__c = fsDate;
                //  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ the first chech is necessary because the second check fails if formDate is null
            }

            if (oldOSCAR.STEP6__c != AMS_Utils.PASSED && updatedOscar.STEP6__c == AMS_Utils.PASSED){

                oscarsToCheckHierarchy.add(updatedOSCAR);

                if(updatedOSCAR.Change_effective_as_of__c > Date.today()) updatedOSCAR.Status__c = 'Accepted_Future Date';
                else updatedOSCAR.Status__c = 'On Hold_Internal';

                if(updatedOSCAR.Process__c == AMS_Utils.VOLRELINQUISH) changesContainer.add(AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.SANITYCHECK, updatedOSCAR, getAccounts(accountsInvolved.get(updatedOSCAR.Id))));
            }

            if (oldOSCAR.STEP30__c != AMS_Utils.PASSED && updatedOSCAR.STEP30__c == AMS_Utils.PASSED) {
                updatedOSCAR.Status__c = 'Accepted_Future Date';

                Set<String> nextMonthLocations = new Set<String>{'P', 'D'};
                Date terminationDate = nextMonthLocations.contains(updatedOSCAR.Location_Class__c) ? AMS_Utils.lastDayOfMonth(Date.today().addMonths(1)) : Date.today().addDays(15);
                updatedOSCAR.Termination_date__c = BusinessHours.nextStartDate(updatedOSCAR.BusinessHours__c, DateTime.newInstance(terminationDate, System.now().time())).date();

                if(updatedOSCAR.Process__c == AMS_Utils.VOLRELINQUISH){
                    updatedOSCAR.Process_Start_Date__c = updatedOSCAR.Termination_Date__c;
                    changesContainer.add(AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.SUSPENSION, updatedOSCAR, getAccounts(accountsInvolved.get(updatedOSCAR.Id))));
                }
            }

            if (oldOSCAR.STEP31__c != AMS_Utils.PASSED && updatedOSCAR.STEP31__c == AMS_Utils.PASSED) {
                changesContainer.add(AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.TERMINATION, updatedOSCAR, getAccounts(accountsInvolved.get(updatedOSCAR.Id))));
            }

            if (oldOSCAR.STEP32__c != AMS_Utils.PASSED && updatedOSCAR.STEP32__c == AMS_Utils.PASSED) {
                if(
                    (updatedOSCAR.Process__c == AMS_UTils.VOLRELINQUISH && updatedOscar.STEP6__c != AMS_Utils.PASSED) || 
                    (updatedOSCAR.Process__c == AMS_UTils.VOLRELINQUISH_CA && updatedOSCAR.STEP31__c != AMS_Utils.PASSED)
                ) updatedOSCAR.addError('Process can only be withdrawn after the process started');
                
                changesContainer.add(AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.WITHDRAWAL, updatedOSCAR, getAccounts(accountsInvolved.get(updatedOSCAR.Id))));
            }
        }

        if(!oscarsToCheckHierarchy.isEmpty()){
            Map<Id, Boolean> isChildrenSelected = AMS_HierarchyHelper.isAllChildrenSelected(oscarsToCheckHierarchy, relationshipMap, accountsInvolved);
            for(AMS_Oscar__c oscar : oscarsToCheckHierarchy) if(!isChildrenSelected.get(oscar.Id)) oscar.addError('For Voluntary Relinquishment, the analyst cannot select a parent account without its children');
        }

        //insert the change codes
        if (changesContainer.size() > 0) {

            List<Account> accsToUpdateFromCC = new List<Account>();
            List<AMS_OSCAR_JSON.ChangeCode> changeCodes = new List<AMS_OSCAR_JSON.ChangeCode>();
            List<Account> accts = new List<Account>();
            List<AMS_OSCAR__c> theoscars = new List<AMS_OSCAR__c>();

            //merge everything
            for (AMS_Utils.Container c : changesContainer) {
                if(c == null) continue;

                changeCodes.addAll(c.changeCodes);
                accts.addAll(c.accts);
                theoscars.addAll(c.oscars);
            }

            AMS_ChangeCodesHelper.createAAChangeCodes( changeCodes, theoscars, accts, true);
        }

    }

    //*************************************
    //********** access methods ***********
    //*************************************

    private static Set<Id> accountIds = new Set<Id>();
    public static void addAccountId(Id a){
        if(accountIds.add(a)) accounts = null; //if we are adding a new Id, we need to requery the accounts
    }

    private static List<Account> getAccounts(Id i){
        return getAccounts(new Set<Id>{i});
    }
    public static List<Account> getAccounts(Set<Id> ids){
        List<Account> accs = new List<Account>();
        for(Id i : ids) if(accounts.containsKey(i)) accs.add(accounts.get(i));
        return accs;
    }
    
    @testVisible private static Map<Id, Account> accounts {
        get{
            //we just need to fetch the first time (or anytime we add a new Id)
            if(accounts == null){
                accounts = new Map<Id, Account>([SELECT Id, Name, Abbreviated_address__c, Abbreviated_name__c, ANG_FA_Opt_out__c, ANG_isNewGenAgency__c, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, CASS_Number__c, CNS_Agency__c, Company_Type__c, Due_Diligence_Status__c, Email__c, Fax, GDS__c, Guaranteed_amount__c, IATA_ISO_Billing_State__c, IATA_ISO_Billing_State__r.Name, IATA_ISO_Country__c, IATA_ISO_Country__r.Name, IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_Country__r.Name, IATA_ISO_Shipping_State__r.Name, IATACode__c, In_a_Airport__c, Is_Branch_Abroad__c, Is_PCI_compliant__c, Is_your_firm_handling_Dangerous_Goods__c, Iso_State__c, ISO_State__r.Name, License_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Operation__c, Parent.IATACode__c, Parent.Location_Type__c, ParentId, Phone, Remittance_frequency__c, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet, Short_Name__c, Solicitation_Flag__c, Status__c, TradeName__c, VAT_Number_2__c, VAT_Number__c, Website,
                    (SELECT Id, ParentId, ANG_FA_Opt_out__c, Guaranteed_amount__c FROM ChildAccounts),
                    (SELECT Id, Account__c, Reason_Code__c, Reason_Description__c, Bulletin_Information__c FROM Agencies_Applied_Change_codes__r WHERE Active__c = true ORDER BY CreatedDate DESC)
                FROM Account WHERE Id IN :accountIds]);
            }
            return accounts;
        }
        set;
    }

    private static Map<Id, AMS_Pax_Accreditation_Form__c> getAccreditations(Set<Id> oscarOnlineAccredIds){
        return new Map<Id, AMS_Pax_Accreditation_Form__c>([SELECT Account_Name__c, IATACode__c, ISSP_AMS_Legal_Status__c, Short_Name__c, Trade_Name__c, ISSP_AMS_License_No__c, ISSP_AMS_VAT_number__c,
                ISSP_AMS_GDS_with_signed_contract__c, Operation__c, Branch_Office_Country__r.Name, Branch_Office_Country__r.Due_diligence_mandatory__c, Branch_Office_Street_name_number__c, Branch_Office_Postal_code__c,
                Billing_State__c, Branch_Office_City__c, ISO_Country__c, IATA_ISO_State__c, Shipping_Country__c, Shipping_Street__c, Shipping_Postal_Code__c,
                Shipping_State__c, Shipping_City__c, Branch_Office_Email__c, Website__c, Branch_Office_Phone__c, Branch_Office_FAX__c, ISSP_AMS_Premises_located_at_airport__c,
                Abbreviated_name__c, Abbreviated_address__c, Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c,
                Shipping_ISO_Country__c, Shipping_ISO_State__c, Shipping_ISO_Country__r.Name, Shipping_ISO_State__r.Name, IATA_ISO_State__r.Name, IATA_ISO_State__r.Valid_for_Address__c   
                FROM AMS_Pax_Accreditation_Form__c
                WHERE Id IN :oscarOnlineAccredIds]);
    }

    public static List<AMS_OSCAR__c> filterOSCARbyRT(Id recTypeId, List<AMS_OSCAR__c> oscars) {

        List<AMS_OSCAR__c> changeOscars = new List<AMS_OSCAR__c>();
        for (AMS_OSCAR__c oscar : oscars) {
            if (oscar.recordTypeID == recTypeId)
                changeOscars.add(oscar);
        }

        return changeOscars;
    }


    public static void sendEmailAlert(Id oscarId, String oscarCommCaseId, String agencyType, String step, boolean wasApproved) {

        if(oscarCommCaseId != null){

            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'agencymanagement@iata.org'];

            List<Contact> contList;
            contList = fetchContactInfoFromCase(oscarCommCaseId);

            if(!contList.isEmpty())
                AMS_AgencyRegulationAutoRenewal.sendEmailAlert(contList, oscarId, ANGemailTemplates(agencyType, step, wasApproved), oscarCommCaseId, owea[0], false);

        }else{

            System.debug('Could not find the case Id to send the email.');
        
        }

    }


    private static List<Contact> fetchContactInfoFromCase(String oscarCommCaseId){

         return [Select Id, Name, Email, Preferred_Language__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c from Contact where Id in (select ContactId from Case where Id = :oscarCommCaseId )];

    }
    
    public static Map<String, Id> ANGemailTemplates(String agencyType, String step, boolean wasApproved){

        Map<String, Id> multilangTemplates = new Map<String, Id>();

        String templateId = '';

        if(agencyType == AMS_Utils.NEWHELITE && step == AMS_Utils.SANITYCHECK) templateId                       = 'ANG_New_HE_SanityCheck_Passed';
        else if(agencyType == AMS_Utils.NEWHESTANDARD && step == AMS_Utils.SANITYCHECK) templateId              = 'ANG_New_HE_Cash_SanityCheck_Passed';
        else if(agencyType == AMS_Utils.NEWHELITE && step == AMS_Utils.APPROVAL && wasApproved) templateId      = 'ANG_New_HE_Accreditation_Decision_APP';
        else if(agencyType == AMS_Utils.NEWHELITE && step == AMS_Utils.APPROVAL && !wasApproved) templateId     = 'ANG_New_HE_Accreditation_Decision_DIS';
        else if(agencyType == AMS_Utils.NEWHESTANDARD && step == AMS_Utils.APPROVAL && !wasApproved) templateId = 'ANG_New_HE_Cash_Accreditation_Decision_DIS';
        else if(agencyType == AMS_Utils.NEWHESTANDARD && step == AMS_Utils.APPROVAL && wasApproved) templateId  = 'ANG_New_HE_Cash_Accreditation_Decision_APP';
        else if(agencyType == AMS_Utils.NEWAE && step == AMS_Utils.SANITYCHECK) templateId                      = 'ANG_New_AE_SanityCheck_Passed';
        else if(agencyType == AMS_Utils.NEWAE && step == AMS_Utils.APPROVAL && wasApproved) templateId          = 'ANG_New_AE_Accreditation_Decision_APP';
        else if(agencyType == AMS_Utils.NEWAE && step == AMS_Utils.APPROVAL && !wasApproved) templateId         = 'ANG_New_AE_Accreditation_Decision_DIS';
        else if(agencyType == AMS_Utils.NGCHANGES && step == AMS_Utils.SANITYCHECK) templateId                  = 'ANG_Changes_SanityCheck_Passed';
        else if(agencyType == AMS_Utils.NGCHANGES && step == AMS_Utils.APPROVAL && wasApproved) templateId      = 'ANG_Changes_APP';
        else if(agencyType == AMS_Utils.NGCHANGES && step == AMS_Utils.APPROVAL && !wasApproved) templateId     = 'ANG_Changes_DIS';
        else if(agencyType == AMS_Utils.IEPMODELAACCOUNTSETUP && step == 'Creation') templateId    = 'IEP_Model_A_Creation';
        else if(agencyType == AMS_Utils.IEPMODELAACCOUNTSETUP && step == AMS_Utils.SANITYCHECK) templateId    = 'IEP_Model_A_SanityCheck_Passed';
        else if(agencyType == AMS_Utils.IEPMODELBACCOUNTSETUP && step == 'Creation_IATA EasyPay (EDENRED)') templateId    = 'ANG_IEP_Model_B_Creation_EDENRED';
        else if(agencyType == AMS_Utils.IEPMODELBACCOUNTSETUP && step == 'Creation_IATA EasyPay (MSTS)') templateId    = 'ANG_IEP_Model_B_Creation_MSTS'; //TODO: fix link on template
        //else if(agencyType == AMS_Utils.IEPMODELBACCOUNTSETUP && step == AMS_Utils.SANITYCHECK) templateId    = 'ANG_IEP_Model_B_SanityCheck_Passed'; //TODO: create template?
		else if(agencyType == AMS_Utils.IEPBANKACCOUNTSETUP && step == 'Creation') templateId    = 'IEP_Setup_Creation';
        else if(agencyType == AMS_Utils.IEPBANKACCOUNTSETUP && step == AMS_Utils.SANITYCHECK) templateId    = 'IEP_Setup_SanityCheck_Passed';
        else if(agencyType == AMS_Utils.IEPBANKACCOUNTSETUP && step == 'closed' && wasApproved) templateId  = 'IEP_Setup_Finalization_Passed';
        else if(agencyType == AMS_Utils.IEPBANKACCOUNTSETUP && step == 'closed' && !wasApproved) templateId  = 'IEP_Setup_Finalization_Failed';
        else if(agencyType == AMS_Utils.NGOPTINOUT && step == AMS_Utils.PASSED && wasApproved) templateId  = 'ANG_Financial_Assesment_Opt_in_App';
        else if(agencyType == AMS_Utils.NGOPTINOUT && step == AMS_Utils.PASSED && !wasApproved) templateId  = 'ANG_Financial_Assesment_Opt_out_App';
        //else if(agencyType == AMS_Utils.NGOPTINOUT && step == AMS_Utils.FAILED && wasApproved) templateId  = 'ANG_Financial_Assesment_Opt_in_DIS';
        else if(agencyType == AMS_Utils.NGOPTINOUT && step == AMS_Utils.FAILED && !wasApproved) templateId  = 'ANG_Financial_Assesment_Opt_out_DIS';
        else if(agencyType == AMS_Utils.NGANNUALREVAL && step == AMS_Utils.FAILED && !wasApproved) templateId  = 'ANG_Annual_Revalidation_Failed';
        else if(agencyType == AMS_Utils.NGANNUALREVAL && step == null) templateId  = 'ANG_Anual_Renewal_Case';
        else if(agencyType == AMS_Utils.NGFOP && step == null ) templateId  = 'ANG_FOP_OSCARCREATION';
        else if(agencyType == AMS_Utils.NGFOP && step == AMS_Utils.PASSED ) templateId  = 'ANG_FOP_OSCARCREATIONPORTAL';
        else if(agencyType == ANG_OscarProcessHelper.ANG_PCI_RENEWAL && step == null ) templateId  = 'ANG_PCI_RENEWAL';
        else if(agencyType == ANG_FOPOSCARNotificationBatch.FOP_REMINDER_TEMPLATE_ID && step == null) templateId  = 'ANG_Mass_FOP_OSCAR_Reminder';
        else if(agencyType == ANG_FOPOSCARNotificationBatch.FOP_NONCOMPLIANCE_TEMPLATE_ID && step == null) templateId  = 'ANG_Mass_FOP_OSCAR_NonCompliance';
        else if(agencyType == ANG_FOPOSCARNotificationBatch.RENEWAL_FOP_REMINDER_TEMPLATE_ID&& step == null) templateId  = 'ANG_PCI_RENEWAL_Reminder';
        else if(agencyType == ANG_FOPOSCARNotificationBatch.RENEWAL_FOP_NONCOMPLIANCE_TEMPLATE_ID&& step == null) templateId  = 'ANG_PCI_RENEWAL_NonCompliance';
        
        System.debug('[ANGemailTemplates] Template to use is:'+templateId);

        //Get the templates for NG accreditation outcoume
        List<EmailTemplate> etNG = Database.query('SELECT Id, DeveloperName, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName LIKE \'' + templateId + '%\'' );

        Map<String, EmailTemplate> countryTemplates = new Map<String, EmailTemplate>();
        for(EmailTemplate et: etNG){
            if(!countryTemplates.containsKey(et.DeveloperName))
                countryTemplates.put(et.DeveloperName, et);
        }

        //map template Ids with their respective language
        List<Schema.Picklistentry> prefLanguages = Contact.getSObjectType().getDescribe().fields.getMap().get('Preferred_Language__c').getDescribe().getPickListValues();
        
        for(Schema.Picklistentry pe: prefLanguages){
            EmailTemplate langTemplate = countryTemplates.get(templateId+ '_' + pe.getValue());
            if(langTemplate == null) //English is default and must exist in the system
                countryTemplates.get(templateId+'_English');
                if(langTemplate != null)
                    multilangTemplates.put(pe.getValue(), langTemplate.Id);
        }

        //this should never happen unless picklist values are deleted form the Contact Preferred_Language__c
        if(multilangTemplates.isEmpty())
            multilangTemplates.put('English', countryTemplates.get(templateId + '_English').Id);

        return multilangTemplates;

    }
 
    public static Map<Id,AMS_HierarchyHelper.AccountStruct> getAccountsInfoBeforeChanges(Map<Id,Account> accountsMap) {


        Map<Id,AMS_HierarchyHelper.AccountStruct> locationTypeAccountID = new Map<Id,AMS_HierarchyHelper.AccountStruct> ();

        for(Id accId : accountsMap.keySet())
        {
            locationTypeAccountID.put(accId,new AMS_HierarchyHelper.AccountStruct(accountsMap.get(accId).Parent.IATACode__c,accountsMap.get(accId).Location_Type__c));

            system.debug('DDD1 Acct ID: ' + accId);

            system.debug('DDD1 Acct Old Location Type: ' + accountsMap.get(accId).Location_Type__c );

            system.debug('DDD1 Acct Old Parent IATA Code: ' + accountsMap.get(accId).Parent.IATACode__c );


        }

        return locationTypeAccountID;
    }


    public static void checkOwnershipOnProcess(List<AMS_OSCAR__c> oscars, Map<Id,AMS_OSCAR__c> oldMap){

        Map<Id, Integer> contacts = null;
        
        Map<Id, Integer> allPercentages = null;

        for(AMS_OSCAR__c oscar: oscars){

            Boolean isNewGenProcess = AMS_Utils.oscarNewGenProcesses.contains(oscar.Process__c);

            if(oldMap.get(oscar.Id).STEP6__c <> AMS_Utils.PASSED && oscar.STEP6__c == AMS_Utils.PASSED && isNewGenProcess && oscar.ANG_Type_Of_Change__c <> AMS_Utils.ANG_VMFR){

                if(contacts == null){
                    contacts = getAccreditationContacts(oscars);
                    allPercentages = getAllOWnersPercentage(oscars);
                }

                if(contacts.get(oscar.AMS_Online_Accreditation__c) > 0)
                    continue;
                else    
                    if(!validate100Ownership(oscar,allPercentages,isNewGenProcess)){
                        Double requiredOwnership = isNewGenProcess ? 99.99 : 100;
                        String errorMessage = !isNewGenProcess ? 'Agency does not have 100% ownership. Please add the owners to the agency before passing the Sanity Check.'
                                                             : 'Agency must have at least 99.99% ownership. Please add the owners to the agency before passing the Sanity Check.';
                        oscar.addError(errorMessage);
                    }

            }
        }

    }

    public static Map<Id, Integer> getAccreditationContacts(List<AMS_Oscar__c> oscars){

        Set<Id> onlineForms = new Set<Id>();

        for(AMS_OSCAR__c oscar : oscars)
            onlineForms.add(oscar.AMS_Online_Accreditation__c);

        List<AggregateResult> sumPercentageAR = [select AMS_Pax_Accreditation_Form__r.Id, count(Id) numberOfContacts from AMS_Accreditation_Contact__c  where AMS_Pax_Accreditation_Form__c in :onlineForms group by AMS_Pax_Accreditation_Form__r.Id];

        Map<Id,Integer> toReturn = new Map<Id,Integer>();

        for(AggregateResult ar: sumPercentageAR){
            toReturn.put((Id)ar.get('Id'), Integer.valueOf(ar.get('numberOfContacts')));
        }

        return toReturn;

    }

    public static Map<Id, Integer> getAllOWnersPercentage(List<AMS_Oscar__c> oscars){

        Set<Id> accounts = new Set<Id>();

        for(AMS_OSCAR__c oscar : oscars)
            accounts.add(oscar.Account__c);

        List<AggregateResult> sumPercentageAR = [select Account__r.Id, SUM(Percentage__c) percentage from AMS_Account_Role__c  where Account__c in :accounts and Active__c = true group by Account__r.Id];

        Map<Id,Integer> toReturn = new Map<Id,Integer>();

        for(AggregateResult ar: sumPercentageAR){
            toReturn.put((Id)ar.get('Id'), Integer.valueOf(ar.get('percentage')));
        }

        return toReturn;

    }

    public static boolean validate100Ownership(AMS_OSCAR__c oscar,  Map<Id, Integer> percentages, Boolean isNewGenProcess){

        return (!isNewGenProcess && percentages.get(oscar.Account__c) == 100) || (isNewGenProcess && percentages.get(oscar.Account__c) < 99.99);

    }

    public static void handleSanityCheckValidations(List<AMS_OSCAR__c> oscars, Map<Id,AMS_OSCAR__c> oldMap){

        //Validation: should not be possible to pass sanity checks without attachments - NEWGEN-1401
        for(AMS_Oscar__c oscar: oscars){

            if(oldMap.get(oscar.Id).STEP6__c <> AMS_Utils.PASSED && oscar.STEP6__c == AMS_Utils.PASSED){

                if (AMS_Utils.oscarNewGenProcesses.contains(oscar.Process__c)) {
                    if(oscar.Process__c == AMS_Utils.NGCORRECTION) {
                        if (oscar.Is_PCI_compliant__c == 'Yes' && oscar.ANG_PCI_compliance_expiry_date__c == null) {
                            oscar.addError('Please specify the PCI compliance expiry date.');
                            return;
                        }

                        if((oscar.Is_PCI_compliant__c == 'No' || oscar.Is_PCI_compliant__c == null) && oscar.ANG_PCI_compliance_expiry_date__c <> null){
                            oscar.addError('Cannot change the PCI compliance expiry date if the Agent is not PCI compliant.');
                            return;
                        }
                    }
                }
				//AMSU-34 - AMS gets to have the same validations as NG
                if(AMS_Utils.processesANGrequiredAttachValidation.contains(oscar.Process__c) || AMS_Utils.processesAMSrequiredAttachValidation.contains(oscar.Process__c)){
                    
                    boolean isToValidate = true;
                    
                    if((oscar.Process__c == AMS_Utils.NGVR && oscar.Is_NewGen__c) || (oscar.Process__c == AMS_Utils.NGCHANGES && (oscar.ANG_Type_Of_Change__c == null || oscar.ANG_Type_Of_Change__c == AMS_Utils.ANG_VMFR))
                        || oscar.Process__c == AMS_Utils.VOLRELINQUISH || oscar.Process__c == AMS_Utils.VOLRELINQUISH_CA){
                            isToValidate = false; // we can skipp this validation
                    }
                    //AMSU-113
                    //if(oscar.Process__c == AMS_Utils.PCI_COMPLIANT && oscar.Is_PCI_compliant__c != 'Yes' && oscar.Is_PCI_compliant__c != 'Nil CC' && oscar.Is_PCI_compliant__c != 'Corporate Card'){
                    if(oscar.Process__c == AMS_Utils.PCI_COMPLIANT && !AMS_Utils.oscarPCICompliantValidationAttachement.contains(oscar.Is_PCI_compliant__c) ){
                        isToValidate = false; // we can skipp this validation
                    }

                    if(isToValidate){

                        List<Case> cList = [SELECT Id from CASE WHERE Oscar__c != null AND CaseNumber = :oscar.Name AND RecordType.Name = 'OSCAR Communication' AND Oscar__c = :oscar.Id AND ((Oscar__r.Process__c = 'BANK.ACCOUNT.CHANGES' AND ParentId = null) OR (Oscar__r.Process__c != 'BANK.ACCOUNT.CHANGES'))];

                        if(cList != null && cList.size() == 1){

                            Case c = cList.get(0);
/*
                            list<WrapperAttach> attchs;
                            
                            try{
                            
                                attchs = WrapperAttach.getListAttachments(c.Id);
                            
                            }catch(Exception e){
                                System.debug(e.getStackTraceString());
                            }

                            List<AmazonFile__c> amazonFiles = [SELECT Id FROM AmazonFile__c WHERE case__c =: c.Id];
*/

                            List<AmazonFile__c> amazonFiles = new List<AmazonFile__c>();
                            list<Attachment> listAttachment = new List<Attachment>();

                            //AMSU-113 - added validation for PCI Compliant
                            if(oscar.Process__c == AMS_Utils.PCI_COMPLIANT){
                                amazonFiles = [SELECT Id FROM AmazonFile__c WHERE case__c =: c.Id AND File_Identifier_picklist__c = 'PCI_COMPLIANCE'];
                            }else{
                                amazonFiles = [SELECT Id FROM AmazonFile__c WHERE case__c =: c.Id];        
                            }

                            if(amazonFiles.isEmpty()){
                                listAttachment = [SELECT  Id,  Name, BodyLength, CreatedById, CreatedDate, ContentType, Description, IsPrivate, LastModifiedDate, LastModifiedById, OwnerId, ParentId, CreatedBy.Name, Body
                                FROM Attachment
                                WHERE ParentId = :c.Id];

                            }
                            
                            if(amazonFiles.isEmpty() && listAttachment.isEmpty()){
                                //AMSU-113 - added error msg for PCI Compliant
                                if(oscar.Process__c == AMS_Utils.PCI_COMPLIANT){
                                    oscar.addError('Error - There are no PCI Compliant attachments with associated with this case/oscar.');
                                }else{ 
                                oscar.addError('Error - There are no attachments associated with this case/oscar.');
                                }
                            }
                        }
                    }
                }

                /*** AMSU-166 ***/
                if(oscar.Process__c == AMS_Utils.COR || oscar.Process__c == AMS_Utils.AGENCYCHANGES) {
                    allOnlineAccr = allOnlineAccr == null ? getAllAccreditations(oscars) : allOnlineAccr;
                    List<String> errorMessages = AMS_Utils.validateCharacters(allOnlineAccr.get(oscar.AMS_Online_Accreditation__c), AMS_Utils.STAGING_AREA_FIELDS_TO_VALIDATE);
                    if(!errorMessages.isEmpty()) {
                        oscar.addError(String.join(errorMessages, '\n'));
                    }
                }
                
                /*** AMSU-121 Start ***/
                Boolean isNewAccreditaion = AMS_Utils.AMS_ProcessesAddressToValidate.contains(oscar.Process__c);
                Boolean isCorrection = oscar.Process__c == AMS_Utils.COR;
                Boolean isChangeOfLocation = oscar.Process__c == AMS_Utils.AGENCYCHANGES && String.isNotBlank(oscar.Type_of_change__c) && oscar.Type_of_change__c.contains(AMS_Utils.Location);
                if(isNewAccreditaion || isCorrection || isChangeOfLocation) {
                	allOnlineAccr = allOnlineAccr == null ? getAllAccreditations(oscars) : allOnlineAccr;
                	validateShippingAddress(oscar, allOnlineAccr);
                }
                /*** AMSU-121 End ***/ 

            }
        }
    }
    /*** AMSU-121 Start ***/
    private static void validateShippingAddress(AMS_OSCAR__c oscar, Map<Id, AMS_Pax_Accreditation_Form__c> accreditations) {
        AMS_Pax_Accreditation_Form__c accreditation = accreditations.get(oscar.AMS_Online_Accreditation__c);
        System.debug('Shipping validation -> ' + accreditation);
        if(accreditation != null) {
            String street = accreditation.Shipping_Street__c; 
            String city = accreditation.Shipping_City__c;
            String state = accreditation.Shipping_State__c;
            String zipCode = accreditation.Shipping_Postal_Code__c;
            String country = accreditation.Shipping_Country__c;
            Id isoState = accreditation.Shipping_ISO_State__c;
            Id isoCountry = accreditation.Shipping_ISO_Country__c;

            if(String.isBlank(street) && String.isBlank(city) && String.isBlank(state) && String.isBlank(zipCode) /* && String.isBlank(country) */ && isoState == null && isoCountry == null) {
                return;
            }

            if(!String.isBlank(street) && !String.isBlank(city) && !String.isBlank(isoState) && !String.isBlank(isoCountry)) {
                return;
            }

            oscar.addError('Incomplete shipping address.');
        }        
    }
    /*** AMSU-121 End ***/ 

    public static Set<Id> checkProcessAndStatusToMigrateOwners(String typeOfChange, String process, Set<Id> accountsList)
    {
        Set<Id> accountsToMigrateOwners = new Set<Id>();
        List<Account> accountsToMigrateOwnersAux = new List<Account>();

        accountsToMigrateOwnersAux = [SELECT Id, Status__c FROM Account WHERE Id IN :accountsList];

        if(typeOfChange != null && (typeOfChange.containsIgnoreCase(AMS_Utils.MAJ_SHAREHOLDING) || typeOfChange.containsIgnoreCase(AMS_Utils.MIN_SHAREHOLDING) || typeOfChange.containsIgnoreCase(AMS_Utils.VFMR))){
            
            for(Account acc : accountsToMigrateOwnersAux) {

                if(Integer.valueOf(AMS_Utils.getIATANumericStatus(acc.Status__c)) > 2)
                    accountsToMigrateOwners.add(acc.Id);
            }
            
        } else {

            return accountsList;
        }

        return accountsToMigrateOwners;

    }
    
    private static void processFieldsTracking(AMS_OSCAR__c oldOscar, AMS_OSCAR__c updatedOSCAR) {

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

        /*  NEWGEN-2809
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
        */
        
        if(AMS_Utils.oscarNewGenNewAppProcesses.contains(updatedOscar.Process__c) && oldOSCAR.STEP6__c <> updatedOscar.STEP6__c && updatedOscar.STEP6__c == 'Passed'){

            if(updatedOscar.Is_PCI_compliant__c == 'No' && updatedOscar.ANG_PCI_compliance_expiry_date__c <> null){
                updatedOscar.addError('Cannot change the PCI compliance expiry date if the Agent is not PCI compliant.');
                return;
            }

            if(updatedOscar.Is_PCI_compliant__c == 'Yes' && ( updatedOscar.ANG_PCI_compliance_expiry_date__c == null || updatedOscar.ANG_PCI_compliance_expiry_date__c < Date.today() ) ) {
                updatedOscar.addError('Please specify the PCI compliance expiry date.');
                return;
            }

        }

        if (oldOSCAR.Send_inspection_request__c == false && updatedOscar.Send_inspection_request__c == true)
            updatedOSCAR.STEP13__c = 'In Progress';

        if (oldOSCAR.Send_agreement__c == false && updatedOscar.Send_agreement__c == true)
            updatedOSCAR.STEP14__c = 'In Progress';

        if (oldOSCAR.Send_FS_request__c == false && updatedOscar.Send_FS_request__c == true) {
            updatedOSCAR.Bank_Guarantee_requested__c = Date.today();

            if(AMS_Utils.oscarNewGenProcesses.contains(updatedOSCAR.Process__c) && updatedOSCAR.Process__c <> AMS_Utils.NGOPTINOUT)
                updatedOSCAR.Bank_Guarantee_deadline__c = Date.today() + 40;
            else
                updatedOSCAR.Bank_Guarantee_deadline__c = Date.today() + 30;
        }

        if(AMS_Utils.oscarNewGenProcesses.contains(updatedOscar.Process__c) && oldOSCAR.STEP6__c <> updatedOscar.STEP6__c && updatedOscar.STEP6__c == 'Passed'){

            System.debug('Sending the email for the user to anounce approval of the oscar');

            //using an already existing method to send email aler to user.
            AMS_OSCARTriggerHandler.sendEmailAlert(updatedOscar.Id, updatedOscar.Oscar_Communication_Case_Id__c, updatedOscar.Process__c, AMS_Utils.SANITYCHECK, true);

        }

        if(updatedOscar.Process__c == AMS_Utils.IEPMODELBACCOUNTSETUP && oldOSCAR.STEP6__c <> updatedOscar.STEP6__c && updatedOscar.STEP6__c == 'Passed' && !updatedOscar.ANG_Share_documentation_with_vendor__c){
            updatedOscar.addError('Share documentation with vendor must be check in order to pass Sanity check.');
            return;
        }

        if(updatedOscar.Process__c == AMS_Utils.IEPMODELAACCOUNTSETUP && oldOSCAR.STEP6__c <> updatedOscar.STEP6__c && updatedOscar.STEP6__c == 'Passed'){

            System.debug('Sending the email for the user to anounce Sanity Check Passing of the IEP Model A oscar');

            //using an already existing method to send email alert to user.
            AMS_OSCARTriggerHandler.sendEmailAlert(updatedOscar.Id, updatedOscar.Oscar_Communication_Case_Id__c, updatedOscar.Process__c, AMS_Utils.SANITYCHECK, true);

        }

        //NEWGEN-3841 NEWGEN-4000 - Send Notification to update results to IEP
        if((updatedOscar.Process__c == AMS_Utils.IEPMODELAACCOUNTSETUP || updatedOscar.Process__c == AMS_Utils.IEPMODELBACCOUNTSETUP) && oldOSCAR.STEP17__c <> updatedOscar.STEP17__c && (updatedOscar.STEP17__c == 'Passed' || updatedOscar.STEP17__c == 'Failed')){
            System.debug('Finish Setup Processing step for IEP bank account setup OSCAR. Sending notification to Mulesoft');
            
            Id configID; 
            for(ANG_CalloutMapping__c cm: ANG_CalloutMapping__c.getall().values()){
                if(cm.Change_Code__c == 'MAPDF'){
                    configID = cm.id;
                    break;
                }
            }
            if(configID != null)
                insert new AMS_Agency_Updates__c(Account__c = updatedOscar.account__c, Update_Type__c = 'Update', Change_Code__c = 'MAPDF', configurationID__C = configID, Integration_System__c='Mulesoft');
        }

        //NEWGEN-2473 - if due diligence step is failed automatically close the OSCAR/case
        if(updatedOscar.Process__c == AMS_Utils.IEPBANKACCOUNTSETUP && oldOSCAR.STEP17__c <> updatedOscar.STEP17__c && updatedOscar.STEP17__c == 'Failed'){
            //updatedOscar.Status__c = 'Closed';
            
            System.debug('Sending the email for the user to anounce Finalization Falling of the IEP bank account setup oscar');
            AMS_OSCARTriggerHandler.sendEmailAlert(updatedOscar.Id, updatedOscar.Oscar_Communication_Case_Id__c, updatedOscar.Process__c, 'closed', false);
        } 
        
        //NEWGEN-2473 - Send an email notification on case closure (passed or failed)
        if(updatedOscar.Process__c == AMS_Utils.IEPBANKACCOUNTSETUP && updatedOscar.Status__c == 'Closed'){

            System.debug('Sending the email for the user to anounce Finalization Passing/Falling of the IEP bank account setup oscar');

            //using an already existing method to send email alert to user.
            AMS_OSCARTriggerHandler.sendEmailAlert(updatedOscar.Id, updatedOscar.Oscar_Communication_Case_Id__c, updatedOscar.Process__c, 'closed', (updatedOscar.STEP17__c == 'Passed' && updatedOscar.STEP41__c == 'Passed'));

        }

        //NEWGEN-3857 - Send Notification to update results to IEP
        if(updatedOscar.Process__c == AMS_Utils.IEPBANKACCOUNTSETUP && oldOSCAR.STEP41__c <> updatedOscar.STEP41__c && (updatedOscar.STEP41__c == 'Passed' || updatedOscar.STEP41__c == 'Failed')){
            System.debug('Finish Setup Processing step for IEP bank account setup OSCAR. Sending notification to Mulesoft');
            
            ID configID; 
            for(ANG_CalloutMapping__c cm: ANG_CalloutMapping__c.getall().values()){
                if(cm.Change_Code__c == 'MaddY') configID = cm.id;
            }

            insert new AMS_Agency_Updates__c(Account__c = updatedOscar.account__c, Update_Type__c = 'Update', Change_Code__c = 'MaddY', configurationID__C = configID, Integration_System__c='Mulesoft');
        }

        if (oldOSCAR.RPM_Approval__c <> updatedOscar.RPM_Approval__c && updatedOscar.RPM_Approval__c == 'Authorize Approval') {

            if(updatedOscar.Process__c == AMS_Utils.NEWHELITE || updatedOscar.Process__c == AMS_Utils.NEWHESTANDARD || updatedOscar.Process__c == AMS_Utils.NEWAE){

                if (updatedOscar.Process__c == AMS_Utils.NEWHESTANDARD && updatedOscar.STEP34__c != AMS_Utils.PASSED)
                     updatedOscar.addError('Approval can\'t be set if Request financial security step is not Passed.');

                System.debug('Sending the email for the user to anounce approval of the oscar');

                //using an already existing method to send email aler to user.
                AMS_OSCARTriggerHandler.sendEmailAlert(updatedOscar.Id, updatedOscar.Oscar_Communication_Case_Id__c, updatedOscar.Process__c, AMS_Utils.APPROVAL, true);

                if(updatedOscar.Process__c == AMS_Utils.NEWHELITE || updatedOscar.Process__c == AMS_Utils.NEWHESTANDARD)
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
                AMS_OSCAR_ApprovalHelper.processForObject('Reject', updatedOscar.Id, null, 'Automated approval based on Manager approval with comments: ' + updatedOscar.Comments_approval__c);
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
                && !tocList.contains(AMS_Utils.MIN_SHAREHOLDING)
            ){
                updatedOSCAR.addError('Penalty fees can only be applied for \n-'+AMS_Utils.OWNERSHIP_IATA+'\n-'+AMS_Utils.OWNERSHIP_NON_IATA+'\n-'+AMS_Utils.MAJ_SHAREHOLDING+'\n-'+AMS_Utils.NAME+'\n-'+AMS_Utils.LEGAL_STATUS+'\n-'+AMS_Utils.LOCATION+'\n-'+AMS_Utils.MIN_SHAREHOLDING);
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
                && !tocList.contains(AMS_Utils.ANG_LOCATION)
            ){
                updatedOSCAR.addError('Penalty fees can only be applied for \n-'+AMS_Utils.ANG_LEGAL_NAME+'\n-'+AMS_Utils.ANG_LEGAL_STATUS+'\n-'+AMS_Utils.ANG_MAJOR_SHAREHOLDING+'\n-'+AMS_Utils.ANG_LOCATION_TYPE+'\n-'+AMS_Utils.ANG_OWNERSHIP+'\n-'+AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY+'\n-'+AMS_Utils.ANG_LOCATION);
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

        if(updatedOSCAR.Process__c == AMS_utils.NGOPTINOUT && oldOSCAR.Status__c <> updatedOscar.Status__c && updatedOscar.Status__c == 'Closed' && updatedOSCAR.Step11__c <> AMS_Utils.PASSED && updatedOscar.ANG_FA_Opt_out__c == 'Opt-In'){
            updatedOscar.addError('If Financial assessment opt-in / opt-out is set to Opt-in, Conduct Financial Review is mandatory to close the case');
        }

    }

    public static void applyChangeCodesWithDependencies(AMS_OSCAR__c oldOSCAR, AMS_OSCAR__c updatedOscar,Set<Id> oscarAccountIds, Set<AMS_Oscar__c> oscarsToCreateAuth) {
    
        ID newRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
        ID newNGRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NG New HE').getRecordTypeId();

        ID corrRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CORRECTION').getRecordTypeId();
        ID certRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CERTIFICATION').getRecordTypeId(); //FM AMSU-113
        
        if (updatedOscar.recordTypeID == newRT || updatedOscar.recordTypeID == newNGRT || updatedOSCAR.recordTypeID == AMS_Utils.RECTYPE_NEWAE){
        	//TD2080607: partially refactored below code
        	boolean bGenerateCC =  false;
        	String changeCodeId = '';
            if (oldOSCAR.STEP2__c != 'Passed' && updatedOscar.STEP2__c == 'Passed') {



                /*** AMSU-31 Start ***/
                Set<String> processesToCheck = new Set<String> {AMS_Utils.new_HO, AMS_Utils.new_BR, AMS_Utils.new_SA, AMS_Utils.new_BR_ABROAD};
                Set<String> classesToCheck = new Set<String> {'P', 'D'}; 
                if(classesToCheck.contains(updatedOscar.Location_Class__c) && processesToCheck.contains(updatedOscar.Process__c)) {
                    oscarsToCreateAuth.add(updatedOscar);
                }
                /*** AMSU-31 End ***/
            	bGenerateCC = true;
                changeCodeId = 'FIN-' + updatedOscar.Business_Process__c;
            }else if (oldOSCAR.STEP2__c != 'Failed' && updatedOscar.STEP2__c == 'Failed' && updatedOscar.RPM_Approval__c=='Authorize Disapproval') {
				bGenerateCC = true;
                changeCodeId = 'DIS-' + updatedOscar.Business_Process__c;
            }else if (oldOSCAR.STEP4__c != 'Passed' && updatedOscar.STEP4__c == 'Passed') {
            	bGenerateCC = true;
                changeCodeId = 'NWD-' + updatedOscar.Business_Process__c;
            }else if (oldOSCAR.STEP5__c != 'Passed' && updatedOscar.STEP5__c == 'Passed') {
            	bGenerateCC = true;
                changeCodeId = 'REC-' + updatedOscar.Business_Process__c;
            }
            
            if(bGenerateCC){
            	AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();
            	AMS_ChangeCodes__c n = AMS_ChangeCodes__c.getInstance(changeCodeId);

                changeCode.name = n.Change_Code__c;
                changeCode.reasonCode = n.Reason_Code__c;
                //TD20180607 - Now passing the change code configuration
                changeCode.memoText = AMS_Utils.getChangeCodeMemoText(updatedOscar.Process__c, changeCodeId, n);
                changeCode.reasonDesc  = n.Reason_Code_Description__c;
                changeCode.status  = n.Account_status_change__c;
                changeCode.publishedOnEBulletin = n.Published_in_bulletin__c;

                AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {updatedOscar}, (List<Account>)JSON.deserialize('[{"Id" : "'+ updatedOscar.Account__c +'", "CNS_Agency__c" : ' + accounts.get(updatedOscar.Account__c).CNS_Agency__c + ' }]', List<Account>.class), true);
            }
        // Management of CORRECTION OSCARs
        }else if (updatedOscar.recordTypeID == corrRT){
            if (oldOSCAR.STEP6__c != 'Passed' && updatedOscar.STEP6__c == 'Passed'){

                Savepoint sp = Database.setSavepoint();

                try {

                    // Regardless the changecode is generated or not, move data to Master Data
                    // First move the account
                    system.debug(LoggingLevel.ERROR,'applyChangeCodesWithDependencies() -> move to MD account data');

                    // THen move the owners
                    Map<Id, Set<Id>> stagingToAccounts = new Map<Id, Set<Id>>();
                    //Need to apply change of ownership to all the accounts in herarchy
                    Set<Id> allHierarchyAccountIds = new Set<Id>();

                    Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships =  AMS_HierarchyHelper.getAccountsHierarchies(oscarAccountIds);

                    //AMS-1671
                    if(isEmptyAccountHierarchyRelationshipsMap(accountHierarchyRelationships)){// it means that the account does not have an hierarchy yet generated.
                        allHierarchyAccountIds.add(updatedOscar.Account__c);
                    }else{
                        for(AMS_Agencies_relationhip__c rel: accountHierarchyRelationships.get(updatedOscar.Account__c)){
                            allHierarchyAccountIds.add(rel.Parent_Account__c);
                            allHierarchyAccountIds.add(rel.Child_Account__c);
                        }
                    }

                    List<Account> accountsToCheck = [SELECT Id, Status__c, Reason__c FROM Account WHERE Id IN :allHierarchyAccountIds]; 

                    //Remove TERMINATED and NOT ACCREDITED Accounts from list
                    for(Account acc: accountsToCheck){
                        if(acc.Status__c == null || acc.Status__c.equalsIgnoreCase(AMS_Utils.ACC_S0_TERMINATED) || acc.Status__c.equalsIgnoreCase(AMS_Utils.ACC_S1_NOTACCREDITED)) allHierarchyAccountIds.remove(acc.Id);
                    }

                    //RB: Bypass hierarchy verification when hierarchy is too big with many owners
                    Apex_Setting__c idAccountOwner = Apex_Setting__c.getInstance('Stop Owner Alignment');
                    system.debug('Stop Owner Verification: '+ idAccountOwner.Text_1__c);
                    system.debug('Stop Owner Verification user ID: '+ UserInfo.getUserId());    

                    if(idAccountOwner.Text_1__c != String.valueOf(UserInfo.getUserId())) {
                        stagingToAccounts.put(updatedOscar.AMS_Online_Accreditation__c, allHierarchyAccountIds);
                        system.debug('applyChangeCodesWithDependencies() -> move to MD contact data. Pass map: '+stagingToAccounts);
                        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(stagingToAccounts, true);
                    }

                    //verify ownership alignment
                    if(idAccountOwner.Text_1__c != String.valueOf(UserInfo.getUserId()) && allHierarchyAccountIds.size()>0 && !AMS_HierarchyHelper.checkHierarchyIntegrity(new Map<Id, Set<Id>>{updatedOscar.Id => allHierarchyAccountIds}))
                        throw new AMS_ApplicationException('This operation cannot be performed because the ownership in this hierarchy is not aligned. It is advised to perform a change of ownership to align the owners in this hierarchy.');

                    if(updatedOscar.AMS_Correction_change_code__c == 'COR' || updatedOscar.AMS_Correction_change_code__c == 'CAD'){

                        //FM AMSU-1 
                        Map<Id, List<AMS_Process_Detail__c>> processDetailPerOSCAR = new Map<Id, List<AMS_Process_Detail__c>>();
                        Set<Id> accountIds = new Set<Id>();
                        Set<Id> oscarIds = new Set<Id>();
                        Set<Id> oscarOnlineAccredIds = new Set<Id>();
                        Map<Id, Account> accounts = new Map<Id, Account>();
                        String sType_of_change = '';

                        //store all the updates to be made on account as consequence of migration of data from staging area to master data
                        Map<Id,AMS_ChangeCodesHelper.ObjectChangesStruct> accountsToUpdate = new Map<Id,AMS_ChangeCodesHelper.ObjectChangesStruct>();
                        
                        accountIds.add(updatedOscar.Account__c);
                        accountIds.add(updatedOscar.AMS_Target_Agency__c);
                        oscarIds.add(updatedOscar.Id);
                        oscarOnlineAccredIds.add(updatedOscar.AMS_Online_Accreditation__c);


                        Map<Id, AMS_Pax_Accreditation_Form__c> onlineAccreditations = new Map<Id, AMS_Pax_Accreditation_Form__c>([SELECT Account_Name__c, IATACode__c, ISSP_AMS_Legal_Status__c, Short_Name__c, Trade_Name__c, ISSP_AMS_License_No__c, ISSP_AMS_VAT_number__c,
                            ISSP_AMS_GDS_with_signed_contract__c, Operation__c, Branch_Office_Country__r.Name, Branch_Office_Country__r.Due_diligence_mandatory__c, Branch_Office_Street_name_number__c, Branch_Office_Postal_code__c,
                            Billing_State__c, Branch_Office_City__c, ISO_Country__c, IATA_ISO_State__c, Shipping_Country__c, Shipping_Street__c, Shipping_Postal_Code__c,
                            Shipping_State__c, Shipping_City__c, Branch_Office_Email__c, Website__c, Branch_Office_Phone__c, Branch_Office_FAX__c, ISSP_AMS_Premises_located_at_airport__c,
                            Abbreviated_name__c, Abbreviated_address__c, Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c,
                            Shipping_ISO_Country__c, Shipping_ISO_State__c, Shipping_ISO_Country__r.Name, Shipping_ISO_State__r.Name, IATA_ISO_State__r.Name, IATA_ISO_State__r.Valid_for_Address__c, Scope_of_Change__c, 
                            Link_agent_name__c, Link_agent_name__r.Name  //AMSU-151
                            FROM AMS_Pax_Accreditation_Form__c
                            WHERE Id IN :oscarOnlineAccredIds]);

                        AMS_Pax_Accreditation_Form__c oscarOnlineAccreditation = onlineAccreditations.get(updatedOscar.AMS_Online_Accreditation__c);

                        //query the the Process Detail object for all the agencies that are being bought
                        List<AMS_Process_Detail__c> allProcessDetails = new List<AMS_Process_Detail__c>([SELECT Id, Account__c, OSCAR__c, Account__r.Status__c, RecordType.Developername FROM AMS_Process_Detail__c WHERE OSCAR__c IN :oscarIds and RecordType.Developername = 'Agency_Involved']);

                        for (AMS_Process_Detail__c pd : allProcessDetails) {
                            //TERMINATED AGENCIES IGNORED
                            if(pd.Account__c != null && pd.Account__r.Status__c != AMS_Utils.ACC_S0_TERMINATED){
                                if (processDetailPerOSCAR.get(pd.OSCAR__c) == null)
                                    processDetailPerOSCAR.put(pd.OSCAR__c, new List<AMS_Process_Detail__c> {pd});
                                else
                                    processDetailPerOSCAR.get(pd.OSCAR__c).add(pd);
                            }

                        }

                        for (List<AMS_Agencies_relationhip__c> hierarchyRelations : accountHierarchyRelationships.values()) {
                            for (AMS_Agencies_relationhip__c relationship : hierarchyRelations) {
                                if(relationship.Parent_Account__r.Status__c != AMS_Utils.ACC_S0_TERMINATED && relationship.Parent_Account__r.Status__c != AMS_Utils.ACC_S1_NOTACCREDITED && relationship.Parent_Account__r.Status__c != '' ){
                                    accountIds.add(relationship.Parent_Account__c);
                                    accounts.put(relationship.Parent_Account__c, new Account(id = relationship.Parent_Account__c, Status__c = relationship.Parent_Account__r.Status__c, Reason__c = relationship.Parent_Account__r.Reason__c));
                                }
                                if(relationship.Child_Account__r.Status__c != AMS_Utils.ACC_S0_TERMINATED && relationship.Child_Account__r.Status__c != AMS_Utils.ACC_S1_NOTACCREDITED && relationship.Child_Account__r.Status__c != '' ){
                                    accountIds.add(relationship.Child_Account__c);
                                    accounts.put(relationship.Child_Account__c, new Account(id = relationship.Child_Account__c, Status__c = relationship.Child_Account__r.Status__c, Reason__c = relationship.Child_Account__r.Reason__c));
                                }
                            }
                        }

                        System.debug('isEmptyAccountHierarchyRelationshipsMap(accountHierarchyRelationships): ' + isEmptyAccountHierarchyRelationshipsMap(accountHierarchyRelationships) );
                        System.debug('accountsToCheck: ' + accountsToCheck );
                        //if nothing from the cycle above we still need to input at least the existing accounts retrieve before
                        if(isEmptyAccountHierarchyRelationshipsMap(accountHierarchyRelationships)){// it means that the account does not have an hierarchy yet generated.
                            for(Account acc: accountsToCheck){
                                if(acc.Id != updatedOscar.Account__c && acc.Status__c !=null && acc.Status__c != AMS_Utils.ACC_S0_TERMINATED && acc.Status__c != AMS_Utils.ACC_S1_NOTACCREDITED ){
                                    //accounts.put(acc.Id, acc);
                                    accounts.put(acc.Id, new Account(id = acc.Id, Status__c = acc.Status__c, Reason__c = acc.Reason__c));
                                }else if(acc.Id == updatedOscar.Account__c && acc.Status__c !=null){
                                    //accounts.put(acc.Id, acc);
                                    accounts.put(acc.Id, new Account(id = acc.Id, Status__c = acc.Status__c, Reason__c = acc.Reason__c));
                                }
                            }
                        }

                        List<AMS_Process_Detail__c> pds = processDetailPerOSCAR.get(updatedOscar.Id);

                        Set<Id> agenciesAffected = new Set<Id>();
                        Set<Id> agenciesAffectedWithHO = new Set<Id>();
                        agenciesAffectedWithHO.add(updatedOscar.Account__c);

                        if (pds != null){
                            for (AMS_Process_Detail__c pd : pds){
                                agenciesAffected.add(pd.Account__c);
                                agenciesAffectedWithHO.add(pd.Account__c);
                            }
                        }else{
                            agenciesAffected.add(updatedOscar.Account__c);
                        }
                        System.debug('agenciesAffected: 1 -' + agenciesAffected );
                        
                        //Checks if all Hierarchy was Selected
                        Boolean isAllHierarchySelected = AMS_HierarchyHelper.isAllHierarchySelected(agenciesAffectedWithHO, accountHierarchyRelationships.get(updatedOscar.Account__c), accounts);

                        //AMSU-151 & AMSU-153 (AMSU-1) - Begin
                        Account accountCheckVAT = [SELECT Id, Is_Branch_Abroad__c, VAT_Number__c, VAT_Number_2__c, IATA_ISO_Country__r.Name, IATA_ISO_Country__r.ISO_Code__c, Location_Class__c 
                                                   FROM Account 
                                                   WHERE Id = :updatedOscar.Account__c];

                        UtilityCS__c ucsVATnumberSpecialCaseCountries = Test.isRunningTest() ? new UtilityCS__c(name ='AMS_COR_VAT_COUNTRIES',value__c = 'BR;IN;MY;TH') : UtilityCS__c.getInstance('AMS_COR_VAT_COUNTRIES');
                        UtilityCS__c ucsAccNameSpecialCaseCountries = Test.isRunningTest() ? new UtilityCS__c(name ='AMS_COR_ACC_NAME_COUNTRIES',value__c = 'CN;TW') : UtilityCS__c.getInstance('AMS_COR_ACC_NAME_COUNTRIES'); //AMSU-153
                        UtilityCS__c ucsAccLinkAgentCountries = Test.isRunningTest() ? new UtilityCS__c(name ='AMS_COR_LINK_AGENT_COUNTRIES',value__c = 'ID') : UtilityCS__c.getInstance('AMS_COR_LINK_AGENT_COUNTRIES');
                        
                        List<String> lVATnumberSpecialCaseCountries = ucsVATnumberSpecialCaseCountries.Value__c.split(';');
                        Set<String> sVATnumberSpecialCaseCountries = new Set<String>(lVATnumberSpecialCaseCountries);

                        //AMSU-153
                        List<String> lAccNameSpecialCaseCountries = ucsAccNameSpecialCaseCountries.Value__c.split(';');
                        Set<String> sAccNameSpecialCaseCountries = new Set<String>(lAccNameSpecialCaseCountries);

                        List<String> lLinkAgentSpecialCaseCountries = ucsAccLinkAgentCountries.Value__c.split(';');
                        Set<String> sLinkAgentSpecialCaseCountries = new Set<String>(lLinkAgentSpecialCaseCountries);

                        Set<String> specialLocationClasses = new Set<String> {'P', 'D'};

                        Boolean isSingleAccountHierarchy = accounts.size() < 2 ? true : false;
                        Boolean isVATnumberSpecialCase = ( sVATnumberSpecialCaseCountries.contains( accountCheckVAT.IATA_ISO_Country__r.ISO_Code__c) || accountCheckVAT.Is_Branch_Abroad__c == 'Yes');
                        Boolean isAccNameSpecialCase = sAccNameSpecialCaseCountries.contains( accountCheckVAT.IATA_ISO_Country__r.ISO_Code__c); //AMSU-153
                        Boolean isLinkAgentSpecialCase = sLinkAgentSpecialCaseCountries.contains(accountCheckVAT.IATA_ISO_Country__r.ISO_Code__c) && specialLocationClasses.contains(accountCheckVAT.Location_Class__c);
                        
                        System.debug('updatedOscar: updatedOscar.Account__r.IATA_ISO_Country__r.Name -' + updatedOscar.Account__r.IATA_ISO_Country__r.Name );
                        System.debug('updatedOscar: updatedOscar.Account__r.IATA_ISO_Country__r.ISO_Code__c -' + updatedOscar.Account__r.IATA_ISO_Country__r.ISO_Code__c );
                        System.debug('updatedOscar: updatedOscar.Account__r.Is_Branch_Abroad__c -' + updatedOscar.Account__r.Is_Branch_Abroad__c );
                        System.debug('updatedOscar: isVATnumberSpecialCase -' + isVATnumberSpecialCase );
                        System.debug('updatedOscar: isAccNameSpecialCase -' + isAccNameSpecialCase );
                        
                        if(isSingleAccountHierarchy){
                            sType_of_change = 'CorrectionSingleAccount';
                        }else if (isEmptyAccountHierarchyRelationshipsMap(accountHierarchyRelationships)) {
                            sType_of_change = 'CorrectionSingleAccount';
                        } else if(isAllHierarchySelected){
                            sType_of_change = 'CorrectionAllHierarchy';
                        }else{
                            sType_of_change = 'CorrectionPerLocation';
                        }

                        if((!isAllHierarchySelected || isSingleAccountHierarchy) && isLinkAgentSpecialCase) {//AMSU-151 Link Agent Name special case
                            sType_of_change += '-LINKAGENT';
                        }
                        if(!isAllHierarchySelected && isVATnumberSpecialCase) {
                            sType_of_change += '-ADD_VAT';
                        }
                        if(!isAllHierarchySelected && isAccNameSpecialCase) {
                            sType_of_change += '-ACCNAME';
                        }
                        if(isAllHierarchySelected && !isSingleAccountHierarchy && isVATnumberSpecialCase) {
                            sType_of_change += '-REMOVE_VAT';
                        }

                        System.debug('updatedOscar: isSingleAccountHierarchy -' + isSingleAccountHierarchy );
                        System.debug('updatedOscar: isAllHierarchySelected -' + isAllHierarchySelected );
                        System.debug('updatedOscar: isVATnumberSpecialCase -' + isVATnumberSpecialCase );
                        System.debug('updatedOscar: sType_of_change -' + sType_of_change );
                        //AMSU-151 & AMSU-153 (AMSU-1) - end

                        System.debug('updatedOscar: 1 -' + updatedOscar );
                        Id hierarchyHO = AMS_HierarchyHelper.getHierarchyHO(accountHierarchyRelationships.get(updatedOscar.Account__c));

                        if(hierarchyHO == null &&  AMS_Utils.LocationTypeAllHOTypes.contains(updatedOscar.Location_Type__c) ){
                            hierarchyHO = updatedOscar.Account__c;
                        }

                        system.debug(LoggingLevel.ERROR,'applyChangeCodesWithDependencies() -> generate the change code');
                        AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();
                        AMS_OSCAR_JSON.ChangeCode changeCodeHO = new AMS_OSCAR_JSON.ChangeCode();
                        List<Account> accts = new List<Account>();
                        Account acctHO = new Account(Id = hierarchyHO);

                        changeCode.status  = null;
    
                        /*** AMSU-153 avoid duplicates ***/
                        Set<Account> accs = new Set<Account>();
    
                        //Check if the current account is the HO, if not we add the account
                        if(updatedOscar.Account__c != hierarchyHO){
                            accs.add(new Account(Id = updatedOscar.Account__c));
                        }

                        for(Id accId : agenciesAffected){
                            if(accId != hierarchyHO){
                                accs.add(new Account(Id = accId));
                            }
                        }

                        accts.addAll(accs);

                        // If the picklist is set create a COR change code.
                        if(updatedOscar.AMS_Correction_change_code__c == 'COR') {
                        changeCode.name = 'COR';
                        changeCode.memoText = 'Correction';
                        changeCode.publishedOnEBulletin = false;

                            changeCodeHO.name = 'COR';
                            changeCodeHO.memoText = 'Correction';
                            changeCodeHO.publishedOnEBulletin = false;

                        // If the picklist is set create a CAD change code.
                        }else if(updatedOscar.AMS_Correction_change_code__c == 'CAD'){
                            System.debug( '[FM] changeCode: '+changeCode );
                            System.debug( '[FM] changeCodeHO: '+changeCodeHO );
                            AMS_ChangeCodes__c cad = AMS_ChangeCodes__c.getInstance('CADM');
                            changeCode.name = cad.Change_Code__c;
                            changeCode.memoText = cad.Bulletin_Memo_Text__c;
							changeCode.publishedOnEBulletin = false;
                            changeCode.name = 'CAD';
                            changeCodeHO.name = cad.Change_Code__c;
                            changeCodeHO.memoText = cad.Bulletin_Memo_Text__c;
                            changeCodeHO.publishedOnEBulletin = true;
                            System.debug( '[FM] changeCode: '+changeCode );
                            System.debug( '[FM] changeCodeHO: '+changeCodeHO );
                        }
                        changeCode.memoText = 'Minor Changes';
                        List<AMS_OSCAR_JSON.ChangeCode> lChangeCode = new List<AMS_OSCAR_JSON.ChangeCode>();
                        List<AMS_OSCAR__c> lOscars = new List<AMS_OSCAR__c>();

                        System.debug('accounts: ' + accounts );
                        System.debug('accts: ' + accts );
                                

                        System.debug('oscarOnlineAccreditation.Scope_of_Change__c: ' + oscarOnlineAccreditation.Scope_of_Change__c );

                        /*** AMSU-153 Start ***/
                        //if(String.isNotBlank(oscarOnlineAccreditation.Scope_of_Change__c)) {
                        if(isAllHierarchySelected){
                            //agenciesAffected.addAll(accounts.keySet());
                            agenciesAffected.add(hierarchyHO);
                        }

                        System.debug('agenciesAffected: ' + agenciesAffected );
                        /*** AMSU-153 End ***/
                        
                        accountsToUpdate.putAll(AMS_Utils.copyDataToAccountForAgencyCorrections(updatedOscar, agenciesAffected, sType_of_change, accounts, oscarOnlineAccreditation));
                        
                        System.debug('accountsToUpdate: ' + accountsToUpdate );


                        Set<Account> accountToupdateSet = new Set<Account>();                        
                        for(Id acctId : accountsToUpdate.keySet())
                        {
                            accountToupdateSet.add(accounts.get(acctId));
                        }

                        //Go throught all account
                        for(Account forAccount : accountToupdateSet){

                            System.debug('forAccount: ' + forAccount );

                            AMS_OSCAR_JSON.ChangeCode auxChangeCode = changeCode.clone();
                            AMS_OSCAR_JSON.ChangeCode auxChangeCodeHO = changeCodeHO.clone();
                            Account acct_reason = accounts.get(forAccount.Id);
                            List<String> lRes = new List<String>();
                            if(acct_reason.Reason__c != null) lRes = AMS_Utils.splitAccReason(acct_reason.Reason__c);
                            
                            System.debug('acct_reason.Reason__c: ' + acct_reason.Reason__c + '|| lRes: ' + lRes);
                            if(lRes != null && lRes.size() > 0){

                                System.debug('AMS_Utils.LocationTypeAllHOTypes: ' + AMS_Utils.LocationTypeAllHOTypes );
                                System.debug('acct_reason.Location_Type__c: ' + acct_reason.Location_Type__c );
                                System.debug('AMS_Utils.LocationTypeAllHOTypes.contains(acct_reason.Location_Type__c): ' + AMS_Utils.LocationTypeAllHOTypes.contains(acct_reason.Location_Type__c) );

                                if( AMS_Utils.LocationTypeAllHOTypes.contains(acct_reason.Location_Type__c)){
                                    auxChangeCodeHO.reasonCode = (lRes.get(0) == null ? '': lRes.get(0));
                                    auxChangeCodeHO.reasonDesc = (lRes.get(1) == null ? '': lRes.get(1));
                                    lChangeCode.add(auxChangeCodeHO);
                                }else{
                                auxChangeCode.reasonCode = (lRes.get(0) == null ? '': lRes.get(0));
                                auxChangeCode.reasonDesc = (lRes.get(1) == null ? '': lRes.get(1));
                                    lChangeCode.add(auxChangeCode);
                            }
                            }

                            System.debug('auxChangeCodeHO: ' + auxChangeCodeHO );
                            System.debug('auxChangeCode: ' + auxChangeCode );

                            //lChangeCode.add(auxChangeCode);
                            lOscars.add(updatedOscar);

                        }


                        List<Account> accountsToUpd = new List<Account>(accountToupdateSet);

                        AMS_ChangeCodesHelper.createAAChangeCodes(lChangeCode, lOscars, accountsToUpd, true);

                        update accountsToUpd ;

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
                    
                        AMS_Utils.copyDataToAccount(new List<AMS_OSCAR__c>{updatedOscar}, false);
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
        //FM AMSU-113            
        }else if (updatedOscar.recordTypeID == certRT){
            System.debug('updatedOscar.Is_PCI_compliant__c: ' + updatedOscar.Is_PCI_compliant__c);
            System.debug('updatedOscar.Change_Code__c: ' + updatedOscar.Change_Code__c);
            System.debug('oldOSCAR.STEP6__c: ' + oldOSCAR.STEP6__c);
            System.debug('updatedOscar.STEP6__c: ' + updatedOscar.STEP6__c);
            if (oldOSCAR.STEP6__c != 'Passed' && updatedOscar.STEP6__c == 'Passed' && updatedOscar.Is_PCI_compliant__c == 'No'){
            
                System.debug('updatedOscar.Is_PCI_compliant__c: entrei' );

                Savepoint sp = Database.setSavepoint();

                try {
                
                    if(updatedOscar.Change_Code__c == 'PCI') {
                        system.debug(LoggingLevel.ERROR,'applyChangeCodesWithDependencies() -> generate the change code');
                        AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

                        List<Agency_Applied_Change_code__c> accountActiveChangeCode = [SELECT Reason_Code__c, Reason_Description__c,Account__r.Status__c FROM Agency_Applied_Change_code__c WHERE Account__c =: updatedOscar.Account__c AND Active__c = TRUE];

                        if(accountActiveChangeCode.size() > 0){
                            changeCode.name = 'PCI';
                            changeCode.reasonCode = accountActiveChangeCode[0].Reason_Code__c;
                            changeCode.memoText = 'PLS NOTE AGT HAS NOT SUBMITTED PCI DSS PROOF OF COMPLIANCE BY THE DEADLINE THEREFORE A NON COMPLIANCE NOTICE HAS BEEN ISSUED';
                            changeCode.reasonDesc = accountActiveChangeCode[0].Reason_Description__c;
                            changeCode.status = AMS_Utils.getIATANumericStatus(accountActiveChangeCode[0].Account__r.Status__c);
                        } else {
                            changeCode.name = 'PCI';
                            changeCode.reasonCode = '91';
                            changeCode.memoText = 'PLS NOTE AGT HAS NOT SUBMITTED PCI DSS PROOF OF COMPLIANCE BY THE DEADLINE THEREFORE A NON COMPLIANCE NOTICE HAS BEEN ISSUED';
                            changeCode.reasonDesc  = 'ACCREDITED–MEETS–STANDARDS';
                            changeCode.status  = 'Approved';
                        }

                        Account acct = new Account(Id = updatedOscar.Account__c);
                        AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {updatedOscar}, new List<Account> {acct}, true);
                    
                        System.debug('updatedOscar.Is_PCI_compliant__c: criei CC' );
                        //AMS_Utils.copyDataToAccount(new List<AMS_OSCAR__c>{updatedOscar}, false);
                    }

                } catch (Exception ex) {
                    System.debug('Exception: ' + ex);
                    Database.rollback(sp); throw ex;
                }
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

    private static void createAgencyAuthorizations(AMS_OSCAR__c oscar){
        List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();
        ID FormOfPaymentRT = AMS_Utils.getId('Agency_Authorization__c','FormOfPayment');

        String statusForCC = 'Active';

        if(oscar.Process__c == AMS_Utils.NEWAE || oscar.Process__c == AMS_Utils.NEWHESTANDARD)
            statusForCC = (oscar.Is_PCI_compliant__c == 'Yes' || oscar.Is_PCI_compliant__c == 'Corporate Card'  ? 'Active' : 'Non-Active');
        else if(oscar.Process__c == AMS_Utils.NEWHELITE){

            if(oscar.Is_PCI_compliant__c == 'Yes' && oscar.Is_using_credit_card__c && oscar.STEP35__c == AMS_Utils.PASSED)
                statusForCC = 'Active';
            else
                statusForCC = 'Non-Active';
        }

        authorizations.add(new Agency_Authorization__c(Account__c = oscar.Account__c, ANG_FormOfPayment_ID__c = 'CC', Status__c = statusForCC, RecordTypeId = FormOfPaymentRT));
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
        
        boolean isCCCreated = false;
        
        for(Agency_Authorization__c fop: parentFormsOfPayment){
            
            if(fop.ANG_FormOfPayment_ID__c == 'CC')
                isCCCreated = true;

            if(fop.ANG_FormOfPayment_ID__c == 'CC' && oscar.Process__c == AMS_Utils.NEWAE && oscar.Is_PCI_compliant__c == 'No')
                authorizations.add(new Agency_Authorization__c(Account__c = oscar.Account__c, ANG_FormOfPayment_ID__c = fop.ANG_FormOfPayment_ID__c, Status__c = 'Non-Active', RecordTypeId = fop.RecordTypeId));
            else
                authorizations.add(new Agency_Authorization__c(Account__c = oscar.Account__c, ANG_FormOfPayment_ID__c = fop.ANG_FormOfPayment_ID__c, Status__c = fop.Status__c, RecordTypeId = fop.RecordTypeId));
        }

        if(!isCCCreated && oscar.Process__c == AMS_Utils.NEWAE){

            if(oscar.Process__c == AMS_Utils.NEWAE && oscar.Is_PCI_compliant__c == 'No')
                authorizations.add(new Agency_Authorization__c(Account__c = oscar.Account__c, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Non-Active', RecordTypeId = FormOfPaymentRT));
            else
                authorizations.add(new Agency_Authorization__c(Account__c = oscar.Account__c, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
        }

        insert authorizations;
    }

    public static void handleNewgenFOPActionsBeforeUpdate(List<AMS_OSCAR__c> oscarsToInsert, Map<Id,AMS_OSCAR__c> oldOscars){

        List<Account> accountsToUpdate = new List<Account>();

        Set<Id> oscarsToInsertSet = new Set<Id>();
        List<AMS_OSCAR__c> oscarsToInsertList = new List<AMS_OSCAR__c>();

        for(AMS_OSCAR__c oscar: oscarsToInsert){

            if(oscar.RecordTypeId == AMS_Utils.RECTYPE_NEWGENFOP){

                if((oscar.STEP40__c == AMS_Utils.PASSED && ( oscar.STEP40__c != oldOscars.get(oscar.id).STEP40__c)) || (oscar.ANG_Sanity_checks__c == AMS_Utils.PASSED && ( oscar.ANG_Sanity_checks__c != oldOscars.get(oscar.id).ANG_Sanity_checks__c))){
                    oscarsToInsertSet.add(oscar.Id);
                    oscarsToInsertList.add(oscar);
                }
            }
        }

        if(oscarsToInsertSet.isEmpty())
            return;

        Map<Id,Set<Id>> oscarAccountsMap = fetchAccountIdsToBeProcessed(oscarsToInsertSet);
        
        for(AMS_OSCAR__c oscar: oscarsToInsertList){
            if(oscarAccountsMap.get(oscar.Id) == null){
                Set<Id> accIds = new Set<Id>{oscar.Account__c};
                oscarAccountsMap.put(oscar.Id,accIds);
            }
        }

        List<Agency_Authorization__c> formsOfPaymentToUpdate = new List<Agency_Authorization__c>();


        Set<Id> accountIdsInvolvedSet = new Set<Id>();
        for(Set<Id> accIds : oscarAccountsMap.values()){

            accountIdsInvolvedSet.addAll(accIds);
        }

        ID FormOfPaymentRT = AMS_Utils.getId('Agency_Authorization__c','FormOfPayment');
        List<Agency_Authorization__c> formsOfPaymentList = [SELECT Id, Account__c, ANG_FormOfPayment_ID__c, Status__c, RecordTypeId FROM Agency_Authorization__c WHERE Account__c in :accountIdsInvolvedSet and RecordTypeId =: FormOfPaymentRT and ANG_FormOfPayment_ID__c = 'CC'];

        Set<Id> oscarsFromPortal = new Set<Id>();
        Map<Id,Id> oscarCaseMap = new Map<Id,Id>(); 

        if(!oscarsToInsertList.isEmpty()){
            Set<Id> oscarIds = new Set<Id>();

            for(AMS_OSCAR__C oscar: oscarsToInsertList)
                oscarIds.add(oscar.Id);

            for(Case c : [Select Id, OSCAR__C from Case where OSCAR__c in:oscarIds AND RecordType.Name = 'OSCAR Communication' and Origin = 'Portal']){
                oscarsFromPortal.add(c.OSCAR__C);
                oscarCaseMap.put(c.OSCAR__C, c.id);
            }
        
        }

        for(AMS_OSCAR__c oscar: oscarsToInsertList){

            if(oscar.ANG_Sanity_checks__c == AMS_Utils.PASSED && ( oscar.ANG_Sanity_checks__c != oldOscars.get(oscar.id).ANG_Sanity_checks__c)){        
                oscar.Process_Start_Date__c = Date.today();
            }

            if(oscar.STEP40__c == AMS_Utils.PASSED && ( oscar.STEP40__c != oldOscars.get(oscar.id).STEP40__c)){

                if(oscar.Is_PCI_compliant__c == null){
                    oscar.addError('In order to pass this step you need to check the Is PCI compliant field.');
                    continue;
                }

                if(oscar.Is_PCI_compliant__c == 'Yes' && oscar.ANG_PCI_compliance_expiry_date__c == null){
                    oscar.addError('For PCI compliance, you need to add an expiry date.');
                    continue;
                }

                // NEWGEN-2932
                if(oscarsFromPortal.contains(oscar.Id))
                    AMS_OSCARTriggerHandler.sendEmailAlert(oscar.Id, oscarCaseMap.get(oscar.id), oscar.Process__c, AMS_Utils.PASSED, false);
            
                for(Id accId: oscarAccountsMap.get(oscar.Id)){

                    Account acct = new Account(Id = accId);
                    Boolean accountToAdd = false;

                    if(acct.Is_PCI_compliant__c <> oscar.Is_PCI_compliant__c){
                        acct.Is_PCI_compliant__c = oscar.Is_PCI_compliant__c;
                        accountToAdd = true;
                    }

                    if(oscar.Is_PCI_compliant__c == 'Yes' || oscar.Is_PCI_compliant__c == 'Nil CC'){
                        acct.ANG_PCI_compliance_expiry_date__c = oscar.ANG_PCI_compliance_expiry_date__c;
                        accountToAdd = true;
                    }

                    if(oscar.Is_PCI_compliant__c == 'Corporate Card'){
                        acct.ANG_PCI_compliance_expiry_date__c = Date.newInstance(2099, 12, 31);
                        accountToAdd = true;
                    }

                    if(accountToAdd)
                        accountsToUpdate.add(acct);
                }


                List<Agency_Authorization__c> formsOfPaymentListPerOscar = new List<Agency_Authorization__c>();

                For(Agency_Authorization__c aa: formsOfPaymentList){
                    if(oscarAccountsMap.get(oscar.Id).contains(aa.Account__c))
                        formsOfPaymentListPerOscar.add(aa);
                }
                
                For(Agency_Authorization__c aa: formsOfPaymentListPerOscar){

                    if(aa.Status__c == 'Active' && oscar.Is_PCI_compliant__c == 'No'){
                        aa.Status__c = 'Non-Active';
                        formsOfPaymentToUpdate.add(aa);
                    }
                    else  if(aa.Status__c == 'Non-Active' && oscar.Is_PCI_compliant__c == 'Yes'){
                        aa.Status__c = 'Active';
                        formsOfPaymentToUpdate.add(aa);
                    }else if(aa.Status__c == 'Active' && oscar.Is_PCI_compliant__c == 'Nil CC'){
                        aa.Status__c = 'Not Authorized';
                        formsOfPaymentToUpdate.add(aa);
                    }
                }

            }

            if(oscar.Is_PCI_compliant__c <> 'Corporate Card' && oscar.Is_PCI_compliant__c <> 'Nil CC'){ //NEWGEN-3214
                
                String changeCodeName = oscar.Is_PCI_compliant__c == 'No' ? 'CCA' : 'CCR';

                ANG_OscarProcessHelper.EntityUpdater updater = ANG_OscarProcessHelper.createChangeCodeForFOP(null, oscar, [Select Id, Status__c, CNS_Agency__c from Account where id in:oscarAccountsMap.get(oscar.Id)], changeCodeName);
                ANG_OscarProcessHelper.updateUpdater(updater);

            }

        }

        if(!accountsToUpdate.isEmpty())
            update accountsToUpdate;

        if(!formsOfPaymentToUpdate.isEmpty())
            update formsOfPaymentToUpdate;


        

    }

    public static Map<Id,Set<Id>> fetchAccountIdsToBeProcessed(Set<Id> oscarIds){

        Map<Id,Set<Id>> toReturn = new Map<Id,Set<Id>>();

        For(AMS_Process_Detail__c pd : [Select Id, Account__c, OSCAR__r.Account__c, OSCAR__c from AMS_Process_Detail__c where OSCAR__c in :oscarIds]){
            if(toReturn.get(pd.OSCAR__c) == null){
                Set<Id> aIds = new Set<Id>{pd.Account__c,pd.OSCAR__r.Account__c};
                toReturn.put(pd.OSCAR__c,aIds);
            }
            else{
                toReturn.get(pd.OSCAR__c).add(pd.Account__c);
            }
        }

        return toReturn;

    }

    public static void updateAccountWithOptINOUT(List<AMS_OSCAR__c> oscarsToInsert, Map<Id,AMS_OSCAR__c> oldOscars){
        
        List<AMS_OSCAR__c> oscarsToProcess = new List<AMS_OSCAR__c>();

        for(AMS_Oscar__c oscar: oscarsToInsert){

            if(oscar.Process__c == AMS_Utils.NGOPTINOUT && oscar.STEP1__c != oldOscars.get(oscar.id).STEP1__c)
                oscarsToProcess.add(oscar);

        }


        if(oscarsToProcess.isEmpty())
            return;

        List<Account> accountsToUpdate = new List<Account>();

        Map<Id,AMS_Oscar__c> accountsOscars = new Map<Id,AMS_Oscar__c>();

        for(AMS_Oscar__c oscar: oscarsToProcess){
            addAccountId(oscar.account__c);
            accountsOscars.put(oscar.account__c,oscar);
        }

        for (AMS_OSCAR__c oscar : oscarsToProcess){

            Account acc = accounts.get(oscar.Account__c);
            if(oscar.STEP1__c == AMS_Utils.PASSED){        
                
                if(acc.Guaranteed_amount__c == 0){

                    oscar.addError('Cannot set Application Finalization step to "Passed" if the total FS provided (Guaranteed amount) by the HE is 0.');
                    continue;

                }
                
                Boolean valueToAgency = oscar.ANG_FA_Opt_out__c == 'Opt-Out' ? true : false;
                if(acc.ANG_FA_Opt_out__c != valueToAgency ){
                    Account a = new Account(Id = oscar.Account__c);
                    a.ANG_FA_Opt_out__c = valueToAgency;
                    accountsToUpdate.add(a);

                    for(Account acct: acc.ChildAccounts){
                        acct.ANG_FA_Opt_out__c = valueToAgency;
                        accountsToUpdate.add(acct);
                    }
                }
                
                System.debug('Sending email alert for process ' + oscar.Process__c + ' with value for Opt set to ' + oscar.ANG_FA_Opt_out__c);
                AMS_OSCARTriggerHandler.sendEmailAlert(oscar.Id, oscar.Oscar_Communication_Case_Id__c, oscar.Process__c, AMS_Utils.PASSED, oscar.ANG_FA_Opt_out__c == 'Opt-In');
                
            }else if (oscar.STEP1__c == AMS_Utils.FAILED && oscar.ANG_FA_Opt_out__c == 'Opt-Out'){

                System.debug('Sending email alert for process ' + oscar.Process__c + ' with value for Opt set to ' + oscar.ANG_FA_Opt_out__c);
                AMS_OSCARTriggerHandler.sendEmailAlert(oscar.Id, oscar.Oscar_Communication_Case_Id__c, oscar.Process__c, AMS_Utils.FAILED, oscar.ANG_FA_Opt_out__c == 'Opt-In');
                
            }

        }

        for(Account acct: accountsToUpdate){

            if(accountIds.contains(acct.Id)){

                AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

                changeCode.name = acct.ANG_FA_Opt_out__c ? 'OOT' : 'OIN';
                changeCode.memoText = acct.ANG_FA_Opt_out__c ? 'Agent has opted out from Annual financial review.' : 'Agent has opted in from Annual financial review.';
                
                changeCode.reasonCode = accounts.get(acct.Id).Agencies_Applied_Change_codes__r[0].Reason_Code__c;
                changeCode.reasonDesc  = accounts.get(acct.Id).Agencies_Applied_Change_codes__r[0].Reason_Description__c;

                AMS_ChangeCodesHelper.ObjectChange objectChange = new AMS_ChangeCodesHelper.ObjectChange('Account','ANG_FA_Opt_out__c', String.valueOf(!acct.ANG_FA_Opt_out__c), String.valueOf(acct.ANG_FA_Opt_out__c));
                //AMS_ChangeCodesHelper.ObjectChange objectChange = new AMS_ChangeCodesHelper.ObjectChange('Account','ANG_FA_Opt_out__c', String.valueOf(accountsFs.get(acct.Id).ANG_FA_Opt_out__c), String.valueOf(acct.ANG_FA_Opt_out__c));
                AMS_ChangeCodesHelper.ObjectChangesStruct objectChangeStruct = new AMS_ChangeCodesHelper.ObjectChangesStruct(new List<AMS_ChangeCodesHelper.ObjectChange>{objectChange});

                AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_ChangeCodesHelper.ObjectChangesStruct> {objectChangeStruct}, new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {accountsOscars.get(acct.Id)}, new List<Account> {acct}, true);
            }

        }

        if(!accountsToUpdate.isEmpty()){

            update accountsToUpdate;
        }
    }


    public static void updateIfapForOptinOut(){

        Map<Id, AMS_OSCAR__c> oldMap = (Map<Id,AMS_OSCAR__c>) Trigger.oldMap;
        Map<Id, AMS_OSCAR__c> newMap = (Map<Id,AMS_OSCAR__c>) Trigger.newMap;

        Set<Id> oscarCaseIdToProcess = new Set<Id>();

        for(AMS_Oscar__c oscar: newMap.values()){

            if(oscar.Process__c == AMS_Utils.NGOPTINOUT && oldMap.get(oscar.id).Status__c != newMap.get(oscar.id).Status__c && newMap.get(oscar.id).Status__c == 'Closed' && oscar.Oscar_Communication_Case_Id__c != null)
                oscarCaseIdToProcess.add(oscar.Oscar_Communication_Case_Id__c);
        }

        if(oscarCaseIdToProcess.isEmpty())
            return;
        
        List<Case> casesToUpdate = new List<Case>();

        List<Case> oscarCasesToProcess = [SELECT Id, Parent.Status, ParentId FROM Case WHERE Id IN :oscarCaseIdToProcess AND parent.RecordTypeId = :AMS_Utils.RECTYPE_CASEIFAP AND Parent.Status <> null];

        for(Case c: oscarCasesToProcess){
            if(c.Parent.Status != 'Closed Opt-out'){
                casesToUpdate.add(new Case(Id = c.ParentId, Status = 'Closed Opt-out'));
            }
        }

        if(!casesToUpdate.isEmpty())
            update casesToUpdate;
    }

    public static void handleAnnualRevalidation(List<AMS_OSCAR__c> oscars, Map<Id,AMS_OSCAR__c> oldOscars){

        Set<Id> oscarsIdsToProcess = new Set<Id>();

        for (AMS_OSCAR__c oscar : oscars){

            if(oscar.Process__c == AMS_utils.NGANNUALREVAL && oldOscars.get(oscar.Id).Status__c <> oscar.Status__c && oscar.Status__c == 'Closed' && oscar.Step6__c <> AMS_Utils.PASSED && oscar.Step6__c <> AMS_Utils.FAILED) {
                oscar.addError('The case cannot be closed if the sanity check is not passed or failed.');
            }

            if (oscar.Process__c == AMS_Utils.NGANNUALREVAL && oscar.STEP43__c == AMS_Utils.FAILED && oldOscars.get(oscar.Id).STEP43__c != AMS_Utils.FAILED){
                oscarsIdsToProcess.add(oscar.Id);
            }
        }

        if (oscarsIdsToProcess.isEmpty())
            return;

        List<Agency_Applied_Change_code__c> listNewCCs = new List<Agency_Applied_Change_code__c>();
        List<String> splittedReason = new List<String>();

        List<AMS_Oscar__c> oscarsToProcess = [SELECT Id, Account__c, Account__r.Reason__c, Account__r.Status__c, Oscar_Communication_Case_Id__c, Process__c
                                            FROM AMS_Oscar__c 
                                            WHERE Id IN :oscarsIdsToProcess ];


        for (AMS_Oscar__c oscar: oscarsToProcess){
            oscar.OSCAR_Deadline__c = Date.today().addDays(30);
            sendEmailAlert(oscar.Id, oscar.Oscar_Communication_Case_Id__c, oscar.Process__c, AMS_Utils.FAILED, false);

            AMS_ChangeCodes__c config = AMS_ChangeCodes__c.getInstance('ARV');
            splittedReason = oscar.Account__r.Reason__c.split('-',2);
            listNewCCs.add(new Agency_Applied_Change_Code__c(Change_Code__c = config.Change_Code__c, OSCAR__c = oscar.Id,  Account__c = oscar.Account__c,
                            Bulletin_Information__c = config.Bulletin_Memo_Text__c, To_Publish_in_e_Bulletin__c = config.Published_in_bulletin__c,
                            Reason_Code__c = (splittedReason.size() == 2 ? splittedReason[0].trim() : ''), Reason_Description__c = (splittedReason.size() == 2 ? splittedReason[1].trim() : ''), 
                            AccountNewStatus__c = oscar.Account__r.Status__c )); 
        }

        if(!listNewCCs.isEmpty())
            insert listNewCCs;

    }

    public static void performBackupANG(Map<Id, AMS_OSCAR__c> oldMap, Map<Id, AMS_OSCAR__c> newMap){
        
        if(ANG_AgencyChangesHelper.testRunnningForNonBackup)
            return;

        List<Id> oscarsToProcess = new List<Id>();

        if(Trigger.isInsert){

            for(ID oscarId:newMap.keySet()){

                if(newMap.get(oscarId).Process__c == AMS_Utils.NGCHANGES && newMap.get(oscarId).ANG_Type_Of_Change__c != null)
                    oscarsToProcess.add(oscarId);
            }
        }

        if(Trigger.isUpdate){

            for(ID oscarId:oldMap.keySet()){

                if(newMap.get(oscarId).Process__c == AMS_Utils.NGCHANGES && oldMap.get(oscarId).ANG_Type_Of_Change__c != newMap.get(oscarId).ANG_Type_Of_Change__c && newMap.get(oscarId).ANG_Type_Of_Change__c != null)
                    oscarsToProcess.add(oscarId);

            }
        }
       

        for(Id oscarId: oscarsToProcess){
            
            newMap.get(oscarId).Backup_In_Progress__c = true;
            
            ID jobID = System.enqueueJob(new ANG_BackupEngineHelper(oscarId,true));
            
        }

        
    }

     public static void performRollbackANG(Map<Id, AMS_OSCAR__c> oldMap, Map<Id, AMS_OSCAR__c> newMap){
        
        if(ANG_AgencyChangesHelper.testRunnningForNonBackup)
            return;

        List<Id> oscarsToProcess = new List<Id>();

        for(ID oscarId:oldMap.keySet()){

            if(newMap.get(oscarId).Process__c == AMS_Utils.NGCHANGES && oldMap.get(oscarId).Step4__c != newMap.get(oscarId).Step4__c && newMap.get(oscarId).Step4__c == AMS_Utils.PASSED)
                oscarsToProcess.add(oscarId);

        }

        for(Id oscarId: oscarsToProcess){

            ID jobID = System.enqueueJob(new ANG_RollbackEngineHelper(oscarId));
            
        }

        
    }           


}
