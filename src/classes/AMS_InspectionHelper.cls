public class AMS_InspectionHelper {

    /*** AMSU-161 ***/
    public static boolean runnigFromOSCAR = false;

    // this method updates the agencies (account) depending on the inspection attached to them
    // if the Accreditation_Endorsement_Status_code__c
    public static void setStatusCodeOnAgency(list<AMS_Inspection__c> inspections){

        if(inspections.isEmpty())
            return; // no processing to be done.

        //getting available airlines...
        Map<Id,AMS_Accreditation_Organization__c> airlines = new Map<Id,AMS_Accreditation_Organization__c>( [select id, Air_Code__c from AMS_Accreditation_Organization__c where Air_Code__c in ('ARC','DOM','IATA','IATAN')]);

        //let's find out if any of the inspections belong to the agencies

        if(airlines.isEmpty())
            return; // no processing to be done.


        List<AMS_Inspection__c> iataInspections = new List<AMS_Inspection__c>();
        Set<String> agencyIds = new Set<String>();

         for(AMS_Inspection__c i:inspections){

            if(i.Account__c == null)
                continue; // should not be necessary if this is coming from the trigger because the validation is being made ... but this is a public static method.

            if(airlines.get(i.Accreditation_Endorsement_organisation__c) !=null ){
                iataInspections.add(i);
                agencyIds.add(i.Account__c);
            }

         }

        if(agencyIds.isEmpty())
            return; // no processing to be done.


        List<AMS_Inspection__c> oldInspections =
            [SELECT Id,Account__c,Accreditation_Endorsement_organisation__c,
                Accreditation_Endorsement_Status_code__c,Date_Organisation_Status_attained__c,
                Previous_status_code__c
            FROM AMS_Inspection__c
            WHERE Account__c IN :agencyIds
            AND ( Accreditation_Endorsement_organisation__r.Air_Code__c = 'ARC' OR
                Accreditation_Endorsement_organisation__r.Air_Code__c = 'IATAN')
            ORDER By Account__c, Accreditation_Endorsement_Status_code__c ASC];

        Map<Id,Account> mapAgencies = new Map<Id,Account>([select Id, Status__c, Location_Class__c from Account where id IN :agencyIds]);
        List<Account> lsAgencies = [select Id, Status__c, Location_Class__c from Account where id IN :agencyIds];
        Set<Account> accountsToUpdate = new Set<Account>();

        // Account accountToProcess;

        for(Account accountToProcess : lsAgencies ) {
            AMS_Inspection__c maxInspection;
            Integer maxStatus = -1;
            Date maxDate = null;
            for(AMS_Inspection__c i:iataInspections) {
                Integer status = Integer.valueOf(i.Accreditation_Endorsement_Status_code__c.charAt(0));
                // accountToProcess = mapAgencies.get(i.Account__c);
                if(i.Account__c == accountToProcess.Id){
                Boolean found = false;
                    // String newStatus = getDecodedStatus(i.Accreditation_Endorsement_Status_code__c,airlines.get(i.Accreditation_Endorsement_organisation__c).Air_Code__c);
                    for(AMS_Inspection__c o : oldInspections) {
                        if((accountToProcess.Location_Class__c=='W' && airlines.get(o.Accreditation_Endorsement_organisation__c).Air_Code__c.equalsIgnoreCase('ARC'))
                        || (accountToProcess.Location_Class__c!='W' && airlines.get(o.Accreditation_Endorsement_organisation__c).Air_Code__c.equalsIgnoreCase('IATAN'))
                             ) {
                            if(i.Account__c == o.Account__c && i.Accreditation_Endorsement_organisation__c == o.Accreditation_Endorsement_organisation__c) {
                                Integer oldStatus = Integer.valueOf(o.Accreditation_Endorsement_Status_code__c.charAt(0));
                                if(maxStatus < oldStatus) {
                                    maxStatus = oldStatus;
                                    maxInspection = o;
                                }
                            }
                        }
                    }
                    // for ARC
                    if((accountToProcess.Location_Class__c=='W' && airlines.get(i.Accreditation_Endorsement_organisation__c).Air_Code__c.equalsIgnoreCase('ARC'))
                    || (accountToProcess.Location_Class__c!='W' && airlines.get(i.Accreditation_Endorsement_organisation__c).Air_Code__c.equalsIgnoreCase('IATAN'))
                         ) {
                        if(maxStatus < status) {
                            accountToProcess.Date_Organisation_Status_attained__c = i.Date_Organisation_Status_attained__c;
                            status = maxStatus;
                            found = true;
                            maxInspection = i;
                        }
                        else if(maxStatus == status) {
                            if(maxDate == null || maxDate < i.Date_Organisation_Status_attained__c) {
                                accountToProcess.Date_Organisation_Status_attained__c = i.Date_Organisation_Status_attained__c;
                                maxDate = i.Date_Organisation_Status_attained__c;
                                found = true;
                                maxInspection = i;
                            }
                        }
                    }

                    if(found) {

                        }


                        }
        }
        //////
        if(maxInspection != null) {
            if((maxInspection.Accreditation_Endorsement_Status_code__c == '7' && maxInspection.Previous_status_code__c == '0') ||
              (maxInspection.Accreditation_Endorsement_Status_code__c == '7' && maxInspection.Previous_status_code__c == null) ||
            (maxInspection.Accreditation_Endorsement_Status_code__c == '7' && maxInspection.Previous_status_code__c == '2') ) {
                accountToProcess.Original_Approval_DAte__c = maxInspection.Date_Organisation_Status_attained__c;
                accountToProcess.Accreditation_date__c = maxInspection.Date_Organisation_Status_attained__c;
            }
            if(maxInspection.Accreditation_Endorsement_Status_code__c == '0' && maxInspection.Previous_status_code__c == '7' ) {
                accountToProcess.Expiry_Date__c = maxInspection.Date_Organisation_Status_attained__c;
            }
            accountToProcess.Date_Organisation_Status_attained__c = maxInspection.Date_Organisation_Status_attained__c;
                //accordng to the type of airline, the status can be diff, so let's divide and conquer.
            String newStatus = getDecodedStatus(maxInspection.Accreditation_Endorsement_Status_code__c,airlines.get(maxInspection.Accreditation_Endorsement_organisation__c).Air_Code__c);

                if(newStatus != null && accountToProcess.Status__c <> newStatus){

                    accountToProcess.Status__c = newStatus;

                }
                        accountsToUpdate.add(accountToProcess);
                    }

    }

        if(!accountsToUpdate.isEmpty())
            update new List<Account>(accountsToUpdate);

    }

    private static String getDecodedStatus(String inspectionStatusCode, String airlineCode){

        if(airlineCode.equalsIgnoreCase('IATAN') || airlineCode.equalsIgnoreCase('ARC') || airlineCode.equalsIgnoreCase('Airlines Reporting Corp'))
            return AMS_Utils.getIATANReadableStatus(inspectionStatusCode);

        if(airlineCode.equalsIgnoreCase('DOM') || airlineCode.equalsIgnoreCase('IATA'))
            return AMS_Utils.getIATAReadableStatus(inspectionStatusCode);

        return null; // this shouldn't happen ...
    }




    public static void setRecertExpiryDateOnAccount(Map<Id, AMS_Inspection__c> oldValues, Map<Id, AMS_Inspection__c> newValues)
    {
        Map<Id, AMS_Inspection__c> statusCodeChanged = AMS_InspectionHelper.findAMSInspectionsWhereStatusCodeChangedToZero(oldValues, newValues);
		Id agencyRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        List<Account> accountsToProcess = [select id, Expiry_Date__c, Location_Class__c, Status__c, Reason__c, RecordTypeId from Account where id in :statusCodeChanged.keySet()];

        if(accountsToProcess.isEmpty())
            return;

        set<Id> accountIdsToCheckAssignments = new set<Id>();
        for(Account acc : accountsToProcess){
            acc.Expiry_Date__c = statusCodeChanged.get(acc.Id).Date_Organisation_Status_attained__c;

            if (acc.Location_Class__c == 'G' || acc.Location_Class__c == 'X') 
                accountIdsToCheckAssignments.add(acc.Id);
				
			/*** AMSU-128 ***/
            if(acc.Location_Class__c == 'M' && acc.RecordTypeId == agencyRT) {
                acc.Status__c = 'Terminated';
                acc.Reason__c = '0-Terminated';
                acc.Expiry_Date__c = Date.today();
            }
        }

        update accountsToProcess;

        AMS_InspectionHelper.checkActiveAppointments(accountIdsToCheckAssignments);

    }

    private static Map<Id, AMS_Inspection__c> findAMSInspectionsWhereStatusCodeChangedToZero(Map<Id, AMS_Inspection__c> oldValues, Map<Id, AMS_Inspection__c> newValues)
    {
        Map<Id, AMS_Inspection__c> changedRecords = new Map<Id, AMS_Inspection__c>();
        for(AMS_Inspection__c current : newValues.values())
        {
            if(oldValues != null && oldValues.get(current.Id) != null)
            {
                AMS_Inspection__c currentOldRecord = oldValues.get(current.Id);
                if(current.Account__c != null && current.Accreditation_Endorsement_Status_code__c != currentOldRecord.Accreditation_Endorsement_Status_code__c && current.Accreditation_Endorsement_Status_code__c.equals('0'))
                {
                    changedRecords.put(current.Account__c, current);
                }
            } else if(current.Account__c != null && current.Accreditation_Endorsement_Status_code__c != null && current.Accreditation_Endorsement_Status_code__c.equals('0'))
            {
                // inserting with status code 0, so let's consider this an updatable record
                changedRecords.put(current.Account__c, current);
            } else
            {
                // This is just an insert of StatusCode != 0, so no need to do any updates
            }
        }
        return changedRecords;
    }

        /**  Comparison of two AMS_Inspection__c records. Used to prevent a last synchronization datetime issue caused by DST.
     *   If any of the fields apart from last sync is not equal to the old value,
     *   it means something else than the Last Sync value got updated as well.
    */
    public static boolean compareAmsInspectionRecords_IgnoringLastSyncDate(AMS_Inspection__c newRecord, AMS_Inspection__c oldRecord)
    {
        Set<String> ignoredFields = new Set<String>{'LastModifiedById', 'LastModifiedDate', 'SystemModstamp', 'Last_synchronization__c'};
        Map <String, Schema.SObjectField> inspectionFieldsMap = schema.SObjectType.AMS_Inspection__c.fields.getMap();
        List <Schema.SObjectField> inspectionFields = inspectionFieldsMap.values();
        List <String> inspectionAPIFieldNames = new List<String>();
        for (Schema.SObjectField field : inspectionFields)
        {
            inspectionAPIFieldNames.add(field.getDescribe().getName());
        }

        boolean valueChanged = false;

        for(String field : inspectionAPIFieldNames)
        {
            System.debug('*************** inspection field: '+field);
            if(!ignoredFields.contains(field))
            {
                if(newRecord.get(field) != oldRecord.get(field))
                {
                    System.debug('*************** field that CHANGED: '+field);
                    valueChanged = true;
                }
            }
        }
        if(valueChanged)
        {
            return true;
        }
        return false;
    }

    // Checks if there is any active appointment left on the account. If none, then send an email to the current user to terminate the account
    // To be called on the inactivation of appointments
    private static void checkActiveAppointments(set<Id> lstAccountIdsToCheck) {
        
        if (lstAccountIdsToCheck.isEmpty()) 
            return;

        try {
            map<Id, Boolean> mapActiveAppointmentPerAccountId = new map<Id, Boolean>();
            //AMSU-161 adding new fields to the query
            map<Id, Account> mapAccountsPerId = new map<Id, Account>([SELECT Id, Name, IATACode__c, Location_Class__c,CNS_Agency__c, Date_Organisation_Status_attained__c, Status__c, Reason__c FROM Account WHERE Id IN :lstAccountIdsToCheck]);
            Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships = new Map<Id, List<AMS_Agencies_relationhip__c>>(); //AMSU-161
            list<AMS_Inspection__c> lstActiveInspections = [SELECT Id, Account__c FROM AMS_Inspection__c WHERE Accreditation_Endorsement_Status_code__c <> '0' AND Account__c IN :lstAccountIdsToCheck];
     
            for (AMS_Inspection__c app : lstActiveInspections){ 
                if (mapActiveAppointmentPerAccountId.get(app.Account__c) == null){
                    mapActiveAppointmentPerAccountId.put(app.Account__c, true);
                }
            }

            
            //AMSU-161
            accountHierarchyRelationships = AMS_HierarchyHelper.getAccountsHierarchies(lstAccountIdsToCheck);

            System.debug('*************** accountHierarchyRelationships: '+accountHierarchyRelationships);


            list<Task> lstTasksToCreate = new list<Task>();
            OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org'];
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for (Id acctId : lstAccountIdsToCheck)
                if (mapActiveAppointmentPerAccountId.get(acctId) == null) {
                    
                    /* AMSU-161 - begin - Check if we terminate or send the message */
                    System.debug('*************** Starting appointment check! ');

                    Boolean haveActiveChildren = false;
                    
                    for (List<AMS_Agencies_relationhip__c> hierarchyRelations : accountHierarchyRelationships.values()) {

                        System.debug('*************** hierarchyRelations: '+hierarchyRelations);

                        if(hierarchyRelations != null || hierarchyRelations.size() > 0){
                        
                            for (AMS_Agencies_relationhip__c relationship : hierarchyRelations) {

                                System.debug('*************** relationship: '+relationship);

                                if(relationship.Parent_Account__c == acctId && relationship.Child_Account__r.Status__c != AMS_Utils.ACC_S0_TERMINATED && relationship.Child_Account__r.Status__c != '' ){
                                    haveActiveChildren = true;
                                }
                            }
                        }    
                    }

                    System.debug('*************** haveActiveChildren: '+haveActiveChildren);

                    if(haveActiveChildren){

                        System.debug('*************** with Active Children - Sending mail to analyst! ');

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.Subject = 'Terminate agent with no appointments';
                    mail.targetObjectId = userInfo.getUserId();
                    mail.saveAsActivity = false;
                    mail.HtmlBody = '<html><body style="font-family: Arial; font-size: 10pt;"><p>Dear ' + userInfo.getName() + ',</p>';
                    mail.HtmlBody+= '<p>You have recently deactivated the last appointment for ' + mapAccountsPerId.get(acctId).Name + '. Please terminate the agency.</p>';
                    mail.HtmlBody+= '<p>Account name: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + acctId + '">' + mapAccountsPerId.get(acctId).Name + '</a><br/>';
                    mail.HtmlBody+= 'IATA Code: ' + mapAccountsPerId.get(acctId).IATACode__c + '</p>';
                    mail.HtmlBody+= '<p>This is an automatically generated email, please do not reply.</p></body></html>';

                    if ( owea.size() > 0 ) {
                        mail.setOrgWideEmailAddressId(owea[0].Id);
                    }

                    emails.add(mail);
                    }else if(!runnigFromOSCAR){
                        //Create CLO CC code and terminate the account
                        List<AMS_Utils.Container> changesContainer = new List<AMS_Utils.Container>();
                        List<Account> auxAccts = new List<Account>();

                        AMS_OSCAR__c fakeOscar = new AMS_OSCAR__c();
                        fakeOscar.Account__c = acctId;
                        fakeOscar.Process__c = AMS_UTils.VOLRELINQUISH;
                        fakeOscar.Change_effective_as_of__c = System.today();
                        fakeOscar.Current_Step__c = 'STEP31__c';
                        fakeOscar.Documentation_remarks__c = 'OSCAR FOR VR by Appointment Termination';

                        //set to true so that account readon to be updated
                        /*
                        for(Account acct: mapAccountsPerId.values()) {
                            if(acct.Id == acctId && acct.Status__c != AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING){
                                auxAccts.add(acct);
                            }
                        }
                        */

                        System.debug('*************** fakeOscar: '+fakeOscar);
                        System.debug('*************** auxAccts: '+auxAccts);

                        changesContainer.add(AMS_ChangeCodesHelper.generateVRChangeCode(AMS_Utils.TERMINATION, fakeOscar, auxAccts));
                        
                        System.debug('*************** changesContainer: '+changesContainer);

                        //insert the change codes
                        if (changesContainer.size() > 0) {

                            List<Account> accsToUpdateFromCC = new List<Account>();
                            List<AMS_OSCAR_JSON.ChangeCode> changeCodes = new List<AMS_OSCAR_JSON.ChangeCode>();
                            List<Account> accts = new List<Account>();
                            List<AMS_OSCAR__c> theoscars = new List<AMS_OSCAR__c>();

                            //merge everything
                            for (AMS_Utils.Container c : changesContainer) {
                                if(c == null) continue;

                                c.accts[0].Reason__c = c.changeCodes[0].reasonCode + '-' + c.changeCodes[0].reasonDesc;

                                changeCodes.addAll(c.changeCodes);
                                accts.addAll(c.accts);

                                theoscars.addAll(c.oscars);
                }

                            System.debug('*************** changeCodes: '+changeCodes);
                            System.debug('*************** theoscars: '+theoscars);
                            System.debug('*************** accts: '+accts);

                            AMS_ChangeCodesHelper.createAAChangeCodes( changeCodes, theoscars, accts, true);

                            //AMS_AccountTriggerHandler.processMinorChangesValidationFlag = false;
                        }
                        
                    }

                    /* AMSU-161 - end */
                    
                }

            System.debug('*************** emails: '+emails);

            if (!emails.isEmpty() && !Test.IsRunningTest())
                Messaging.SendEmailResult [] r = Messaging.sendEmail(emails);
            
        } catch (Exception e) {
            system.debug('ERROR checkActiveAppointments: ' + e.getMessage());
            system.debug('ERROR checkActiveAppointments: ' + e.getStackTraceString());
        }
    }

    /*AMSU-161 - begin*/
    public static String validateGSAforAppointments(AMS_OSCAR__c oscar, Map<Id, AMS_Pax_Accreditation_Form__c> accreditations) {

        String sError = '';
        Boolean bInvalidAppointmentStatus = false;
        Boolean bInvalidTerritory = false;

        List<AMS_Inspection__c> oscarAppointments = [SELECT id, Account__c, Nr_of_AMS_Territories__c, Accreditation_Endorsement_Status_code__c FROM AMS_Inspection__c WHERE OSCAR__c = :oscar.id];

        if(oscarAppointments == null || oscarAppointments.size() == 0) {
            sError = 'No Appointments associated.';
        }else{
            for(AMS_Inspection__c appointment : oscarAppointments){

                if(appointment.Nr_of_AMS_Territories__c == null || appointment.Nr_of_AMS_Territories__c < 1) {
                    bInvalidTerritory = true;
                }
                
                if(appointment.Accreditation_Endorsement_Status_code__c == null || appointment.Accreditation_Endorsement_Status_code__c != '2' && (oscar.Process__c == AMS_Utils.new_GSA_BSP || oscar.Process__c == AMS_Utils.new_AHA_BSP || oscar.Process__c == AMS_Utils.new_GSSA)) {
                    bInvalidAppointmentStatus = true;
                }
                if(appointment.Accreditation_Endorsement_Status_code__c == null || appointment.Accreditation_Endorsement_Status_code__c != '9' && (oscar.Process__c == AMS_Utils.new_GSA || oscar.Process__c == AMS_Utils.new_AHA)) {
                    bInvalidAppointmentStatus = true;
                }
                
            }
        }

        if(bInvalidAppointmentStatus) {
            sError = 'Appointment in incorrect Status.';
		}
        if(bInvalidTerritory) {
            sError = 'Appointment has no Territories.';
        }

        return sError;        
    }
    
    public static void processGSA_GSSA_HASLagency(List<AMS_Inspection__c> appointments) {
        if(appointments != null && appointments.size() > 0){

            Set<Id> oscarIds = new Set<Id>();
            Set<Id> accIds = new Set<Id>();

            for(AMS_Inspection__c appt : appointments){
                oscarIds.add(appt.OSCAR__c);
                accIds.add(appt.Account__c);
            }

            Map<Id, AMS_OSCAR__c> mOscars = new Map<Id, AMS_OSCAR__c>([SELECT Id, Process__c FROM AMS_OSCAR__c WHERE id in :oscarIds]);
            Map<Id, Account> mAccounts = new Map<Id, Account>([SELECT Id, Status__c FROM Account WHERE id in :accIds]);

            for(AMS_Inspection__c appt : appointments){
                //If OSCAR__c is not null means that the appointment is being created in an OSCAR
                if(appt.OSCAR__c != null){
                    String oscProc = mOscars.get(appt.OSCAR__c).Process__c;
                    if(oscProc == AMS_Utils.new_GSA_BSP || oscProc == AMS_Utils.new_AHA_BSP || oscProc == AMS_Utils.new_GSSA){
                        appt.Accreditation_Endorsement_Status_code__c = '2';
                    }
                    if(oscProc == AMS_Utils.new_GSA || oscProc == AMS_Utils.new_AHA){
                        appt.Accreditation_Endorsement_Status_code__c = '9';
                    }
                    appt.Date_Organisation_Status_attained__c = System.today();
                }
                //If Account__c is not null means that the appointment is being created in an Account
                if(appt.Account__c != null){
                    String accStatus = mAccounts.get(appt.Account__c).Status__c;
                    if(accStatus == 'Approved'){
                        appt.Accreditation_Endorsement_Status_code__c = '9';
                    }else{
                        appt.Accreditation_Endorsement_Status_code__c = '2';
                    }
                    appt.Date_Organisation_Status_attained__c = System.today();
                }
                
            }
        }
    }
    /*AMSU-161 - end*/
}
