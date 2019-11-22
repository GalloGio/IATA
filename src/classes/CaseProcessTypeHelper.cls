/*
 *  This class is an helper with methods to handle Case Process Type actions, like calculate the KPI when the case is closed
 *  or copy the Case process to OSCAR
 */
public with sharing class CaseProcessTypeHelper {

    //This variable maps the metadata per reason and case recordtype id
    private static Map<Id,Map<String,Case_Process_Type__mdt>> mapRTsToReasons = null;

    /*
     *  Method to load Case_Process_Type__mdt  
     */
    private static Map<Id,Map<String,Case_Process_Type__mdt>> getMapRTsToReasons() {
        if(mapRTsToReasons == null) {
            mapRTsToReasons = new Map<Id,Map<String,Case_Process_Type__mdt>>();

            List<Case_Process_Type__mdt> processes = [SELECT Reason__c, Type__c, KPI_Reference_Field__c, KPI_Reference_Value__c, Record_Type__c FROM Case_Process_Type__mdt];
            for(Case_Process_Type__mdt process : processes) {
                Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', process.Record_Type__c);
                Map<String,Case_Process_Type__mdt> mapReason = mapRTsToReasons.get(rtId);
                if(mapReason == null) {
                    mapReason = new Map<String,Case_Process_Type__mdt>();
                    mapRTsToReasons.put(rtId,mapReason);
                }
                mapReason.put(process.Reason__c,process);
            }
        }

        return mapRTsToReasons;
    }

    /*
     *  Method used to calculate KPI's when the Case is closed, some closed cases aren't suitable for this process so it's applied
     *  a filter to exclude cases that don't match the criterias:
     *  - RecordType must be defined in at least one of the metadata records
     *  - Case is being closed
     *  - Subject cannot contain 'PROCOM'
     *  - ClosedDate must be 2019 or bigger
     *  - Case Region cannot be empty
     *  - Closed By Role cannot be empty
     *  - Account IATA ISO Country cannot be United States
     */
    public static void processKPI(List<Case> cases, Map<Id,Case> oldMap) {
        Datetime x1stDate = Datetime.newInstance(2019, 1, 1);
        Set<Id> accountIds = new Set<Id>();
        Set<Id> oscarIds = new Set<Id>(); //WMO-564 - ACAMBAS
        List<Case> casesToProcess = new List<Case>();

        for(Case cse : cases) {
            Case oldRecord = oldMap.get(cse.Id);
            Boolean beingClosed = cse.IsClosed && !oldRecord.IsClosed;
            Boolean hasConfig = getMapRTsToReasons().get(cse.RecordTypeId) != null && getMapRTsToReasons().get(cse.RecordTypeId).get(cse.Reason1__c) != null;
            Boolean validSubject = String.isNotBlank(cse.Subject) && !cse.Subject.contains('PROCOM');
            if(hasConfig && beingClosed && cse.ClosedDate >= x1stDate && String.isNotBlank(cse.Closed_by_Role__c) && String.isNotBlank(cse.Region__c) && validSubject) {
                casesToProcess.add(cse);
                accountIds.add(cse.AccountId);
                oscarIds.add(cse.OSCAR__c); //WMO-564 - ACAMBAS
            }
        }

        if(casesToProcess.isEmpty()) {
            return;
        }
        
        /* US Accounts must be excluded */
        Map<Id,Account> mapAccounts = new Map<Id,Account>([SELECT Id, IATA_ISO_Country__c, IATA_ISO_Country__r.ISO_Code__c FROM Account WHERE Id IN :accountIds]);
        
        Map<Id, AMS_OSCAR__c> mapOscars = new Map<Id, AMS_OSCAR__c>([SELECT Id, KPI_Aux1__c FROM AMS_OSCAR__c WHERE Id IN :oscarIds]); //WMO-564 - ACAMBAS
        
        for(Case cse : casesToProcess) {
            Account acc = mapAccounts.get(cse.AccountId);
            if(String.isNotBlank(acc.IATA_ISO_Country__c) && acc.IATA_ISO_Country__r.ISO_Code__c == 'US') {
                continue;
            }

            AMS_OSCAR__c oscar = mapOscars.get(cse.OSCAR__c); //WMO-564 - ACAMBAS
            Case_Process_Type__mdt process = getMapRTsToReasons().get(cse.RecordTypeId).get(cse.Reason1__c);
            calculateKPI(cse, oscar, process);
        }
    }

    /*
     *  Method used to populate process type on the OSCAR record based on a custom metadata type Case_Process_Type__mdt
     *  that maps a reason to a process
     */
    public static void populateOSCARAccProcess(AMS_OSCAR__c oscar) {
        Id oscarComRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
        Case_Process_Type__mdt process = getMapRTsToReasons().get(oscarComRTId).get(oscar.Case_Reason__c);        
        oscar.Accreditation_Process_Type__c = process == null ? '' : process.Type__c;
    }

    /*
     *  Method used to calculate KPI field, it uses the custom metadata type Case_Process_Type__mdt to calculate the value
     *  KPI_Reference_Field__c, this field has the API Name of a Case field that matters to calculate the KPI for a specific process
     *  KPI_Reference_Value__c, this field has the value we need to compare with Case field, if the Case field is greather than the
     *  reference value then KPI will be 0 otherwise it will be 1
     */
    private static void calculateKPI(Case cse, AMS_OSCAR__c oscar, Case_Process_Type__mdt process) {  
        //WMO-564 - ACAMBAS: Begin
        List<String> refFieldList = process.KPI_Reference_Field__c.split('\\.');
        Integer recordValue;
        
        if(refFieldList.size() == 2 && refFieldList[0] == 'AMS_Oscar__c') {
         	recordValue = Integer.valueOf(oscar.get(refFieldList[1]));
            cse.KPI_Calculation__c = recordValue == process.KPI_Reference_Value__c ? 1 : 0;
        }
        else if(refFieldList.size() == 1) { //Case
            recordValue = Integer.valueOf(cse.get(process.KPI_Reference_Field__c));          
            cse.KPI_Calculation__c = recordValue <= process.KPI_Reference_Value__c ? 1 : 0;
        }
        else {
            cse.addError('Configuration error - invalid field: ' + process.KPI_Reference_Field__c);
        }
        //WMO-564 - ACAMBAS: End   
    }

    /*
     *  Method that executes the recalculation OSCAR effective age when the case is closed
     */
    public static void processOSCAREffAge(List<Case> cases, Map<Id,Case> oldMap) {
        Id oscarCommRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
        Set<String> reasons = mapRTsToReasons.get(oscarCommRTId).keySet();
        Date x1stDay = Date.newInstance(2019, 1, 1);
        Map<Id,Case> mapOscarToCase = new Map<Id,Case>();

        for(Case cse : cases) {
            Case oldRecord = oldMap.get(cse.Id);
            if(cse.IsClosed && !oldRecord.IsClosed && cse.OSCAR__c != null && reasons.contains(cse.Reason1__c) && cse.CreatedDate >= x1stDay) {
                mapOscarToCase.put(cse.OSCAR__c, cse);
            }
        }

        if(!mapOscarToCase.isEmpty()) {
            List<String> oscarFields = new List<String>();
            List<Schema.FieldSetMember> kpiFields = SObjectType.AMS_OSCAR__c.FieldSets.KPI_Fields.getFields();
            for(Schema.FieldSetMember field : kpiFields) {
                oscarFields.add(field.getFieldPath());
            }

            Set<Id> oscarIds = mapOscarToCase.keySet();
            List<Case> casesToProcess = mapOscarToCase.values();
            String queryStr = 'SELECT ' + String.join(oscarFields, ', ') + ' FROM AMS_OSCAR__c ';
            queryStr += 'WHERE Id IN :oscarIds AND Dossier_Reception_Date__c <> null AND ';
			queryStr += 'Id NOT IN (SELECT OSCAR__c FROM Case WHERE Owner.Name LIKE \'%Recycle%\' AND Id IN :casesToProcess)';

            List<AMS_OSCAR__c> oscars = Database.query(queryStr);
            if(!oscars.isEmpty()) {
                for(AMS_OSCAR__c oscar : oscars) {
                    /* We need to preform this assignment to make sure that null fields are set before flow execution */
                    for(Schema.FieldSetMember field : kpiFields) {
						if(field.getSObjectField().getDescribe().isUpdateable()) {
							oscar.put(field.getFieldPath(), oscar.get(field.getFieldPath()));
						}
					}	

					AMS_OSCAR_Age_Calculator.calculate(mapOscarToCase.get(oscar.Id), oscar);
                }

                update oscars;
            }
        }
    }
    /**WMO-728*/
    public static void resetOscarDossierReceptionDate(List<Case> cases, Map<Id,Case> oldMap){

        Id oscarComRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
        Map<String, AMS_OSCAR_reset_dossier_reception__c> resetDossierReceptionDate_CSList = AMS_OSCAR_reset_dossier_reception__c.getall();
        Set<Id> oscarsToResetDossier = new Set<Id>();
        List<AMS_OSCAR__c> oscarsToUpdate = new List<AMS_OSCAR__c>();

        if(!resetDossierReceptionDate_CSList.isEmpty()){
            for(Case cs : cases){
                if(cs.Oscar__c != null && cs.RecordTypeId == oscarComRTId && resetDossierReceptionDate_CSList.containsKey(oldMap.get(cs.Id).Status) && !cs.isClosed){
                    oscarsToResetDossier.add(cs.Oscar__c);
                }
            }
            
            if(!oscarsToResetDossier.isEmpty()){
                for(AMS_OSCAR__c oscar : [SELECT Id, Dossier_Reception_Date__c FROM AMS_OSCAR__c WHERE Id in: oscarsToResetDossier]){
                    oscar.Dossier_Reception_Date__c = Date.today();
                    oscarsToUpdate.add(oscar);
                }
                update oscarsToUpdate;
            }
        }
    }

 }