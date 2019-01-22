public class AMS_OscarCaseTriggerHelper {
    
    /**
        This is helper class for both OSCAR and OSCAR Case Communication
    **/

    //used to assign new created oscars to one of 5 queues, pending on the region.
    public static Map<String, Group> queues{
        get{
            if(queues == null){
                queues = new Map<String, Group>();
                for(Group q : [SELECT Id, DeveloperName FROM Group WHERE  Type = 'Queue' AND DeveloperName IN ('AgencyManagementAP','AgencyManagementAfricaME','AgencyManagementAmericas','AgencyManagementChinaNAsia','CasesACCEuropeOffOnshore')]) queues.put(q.DeveloperName, q);
            } 
            return queues;
        }
        private set;
    }

    private static Id OSCARCaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

    //remove OSCAR from child case, if case is being cloned from OSCAR parent
    public static void removeOscarFromChild(list<Case> triggerNew){

        List<Case> casestoremoveoscar = new List<Case>();
        List<Id> parentcaseIds = new List<Id>();

        //check parent record type
        for(Case c: triggerNew){
            if(c.ParentId != null && c.Oscar__c != null && c.RecordTypeId == OSCARCaseRecordTypeID){
                parentcaseIds.add(c.ParentId);
                casestoremoveoscar.add(c);
            }
        }
                
        if(parentcaseIds.isEmpty()) return;

        Map<Id, Case> parentCase = new Map<Id, Case>([SELECT Id, Oscar__c, RecordTypeId FROM Case 
                                                    WHERE Id IN :parentcaseIds AND RecordTypeId = :OSCARCaseRecordTypeID AND OSCAR__c != null]);
        
        for(Case c: casestoremoveoscar){
            Case parent = parentCase.get(c.parentId);   
            if(parent != null && c.Oscar__c == parent.Oscar__c){
                c.Oscar__c = null;
            }         
        }
    }
    
    public static void OSCARCaseCreationRules(list<Case> triggerNew){

        List<Case> oscarCases = new List<Case>();
        Set<Id> oscarIds = new Set<Id>();

        for(Case c: triggerNew){
            if(c.RecordTypeID == OSCARCaseRecordTypeID && c.OSCAR__c != null && c.ParentId == null){
                oscarCases.add(c);
                oscarIds.add(c.OSCAR__c);
            }
        }

        if(oscarCases.isEmpty()) return;

        checkOscarUniqueness(oscarCases, oscarIds);

    }

    public static void OSCARCaseUpdateRules(list<Case> triggerNew, map<Id, Case> triggerOldMap){
        List<Case> oscarCases = new List<Case>();
        Set<Id> oscarIds = new Set<Id>();

        for(Case c: triggerNew){
            if(c.RecordTypeID == OSCARCaseRecordTypeID && triggerOldMap.get(c.id).Oscar__c == null && c.OSCAR__c != null && c.ParentId == null){
                oscarCases.add(c);
                oscarIds.add(c.OSCAR__c);
            }
        }

        if(oscarCases.isEmpty()) return;

        checkOscarUniqueness(oscarCases, oscarIds);
    }

    private static void checkOscarUniqueness(List<Case> oscarCases, Set<Id> oscarIds) {
        Map<Id, Case> caseOSCARMap = new Map<Id, Case>();

        //see if the oscars had a case before the insert/update
        if(!oscarIds.isEmpty() && !oscarCases.isEmpty()) {
            for(Case c :  [SELECT Id, OSCAR__c FROM Case WHERE OSCAR__c IN :oscarIds AND ParentId = null AND Id NOT IN :oscarCases]){
                caseOSCARMap.put(c.OSCAR__c, c);
            }
        }

        for(Case c: oscarCases){
            Case mainOscarCase = caseOSCARMap.get(c.OSCAR__c);
            if(
                mainOscarCase != null
                && mainOscarCase.Id != c.Id
                && mainOscarCase.Id != c.ParentId
            ){
                c.addError('The OSCAR assigned to this Case already has a Case Assigned.');
            }else{
                //prevents error if the oscar had no case and two or more were added
                caseOSCARMap.put(c.OSCAR__c, c);
            }
        }
    }

    public static void blockForbbidenActions(list<Case> triggerNew, map<Id, Case> triggerOldMap){
        for(Case c: triggerNew){
            if(triggerOldMap.get(c.id).RecordTypeId == OSCARCaseRecordTypeID && c.RecordTypeId != OSCARCaseRecordTypeID && triggerOldMap.get(c.id).OSCAR__c != null){
                throw new transformationException('Cannot change the record type of an OSCAR Communication case having an OSCAR assigned.');
            }
            if(triggerOldMap.get(c.id).Oscar__c != null && triggerOldMap.get(c.id).Oscar__c <> c.Oscar__c){
                c.addError('Cannot disattach OSCAR from Case.');
            }
        }
    }

    public static void populateOscarFields(list<Case> triggerNew){

        System.debug('Populating OSCAR fields');

        Set<Id> oscarIds = new Set<Id>();
        List<Case> oscarCases = new List<Case>();

         for(Case c : triggerNew){
            if(c.OSCAR__c != null && c.RecordTypeID == OSCARCaseRecordTypeID) {
                //need to verify just for the first case on the trigger, since the second one will throw an error
                if(oscarIds.add(c.Oscar__c)) oscarCases.add(c);
            }
        }

        if(oscarCases.isEmpty()) return;

        List<AMS_OSCAR__c> oscarsToUpdate = new List<AMS_OSCAR__c>();
        Map<Id, AMS_OSCAR__c> oscars = new Map<Id, AMS_OSCAR__c> ([SELECT Id,Name,BusinessHours__c, Shut_Down_TKT_System_GDS_and_BSPlink__c, Open_TKT_System__c, Certificate_Quantity__c 
                                                                   FROM AMS_OSCAR__c WHERE Id = :oscarIds]);

        for(Case c : oscarCases){
            if(!oscars.containsKey(c.Oscar__c)) continue;

            Boolean changed = false;
            AMS_OSCAR__c oscar = oscars.get(c.OSCAR__c);
            
            if(oscar.Name != c.CaseNumber){
                System.debug(loggingLevel.FINE, '____ [cls AMS_OscarCaseTriggerHelper - populateOscarFields] Renaming OSCAR - ' + oscar.Id + '('+c.CaseNumber+')');
                
                oscar.Name = c.CaseNumber;

                if(c.QuantityProduct__c != null && oscar.Certificate_Quantity__c != Integer.valueOf(c.QuantityProduct__c)){
                    oscar.Certificate_Quantity__c = Integer.valueOf(c.QuantityProduct__c);
                }

                changed = true;
            }

            if(oscar.BusinessHours__c != c.BusinessHoursId){
                oscar.BusinessHours__c = c.BusinessHoursId;
                changed = true;
            }

            if(oscar.Shut_Down_TKT_System_GDS_and_BSPlink__c != c.Shut_Down_TKT_System_GDS_and_BSPlink__c){
                oscar.Shut_Down_TKT_System_GDS_and_BSPlink__c = c.Shut_Down_TKT_System_GDS_and_BSPlink__c;
                changed = true;
            }

            if(oscar.Open_TKT_System__c != c.Open_TKT_System__c){
                oscar.Open_TKT_System__c = c.Open_TKT_System__c;
                changed = true;
            }

            if(changed) oscarsToUpdate.add(oscar);
        }

        if(!oscarsToUpdate.isEmpty()) update oscarsToUpdate;

    }

    public static void assignOscarToRegionQueue(List<AMS_OSCAR__c> oscars){
        Set<Id> accIds = new Set<Id>();
        for(AMS_OSCAR__c o : oscars) accIds.add(o.Account__c);

        assignOscarToRegionQueue(oscars, new Map<Id, Account>([SELECT Id, Region_formula__c FROM Account WHERE Id IN :accIds]));
    }

    public static void assignOscarToRegionQueue(List<AMS_OSCAR__c> oscars, Map<Id, Account> accounts){
        
        for(AMS_OSCAR__c oscar: oscars){

            Account ag = accounts.get(oscar.Account__c);

            if(ag == null) continue;

            String region = ag.Region_formula__c;

            if(String.isBlank(region)) continue;

            if(region.contains('Americas')){
                oscar.OwnerId = queues.get('AgencyManagementAmericas').Id;
                System.debug(LoggingLevel.FINE, 'cls [AMS_OscarCaseTriggerHelper - assignOscarToRegionQueue] Oscar assigned to Americas queue.');
            }
            else if(region.contains('Europe')){
                oscar.OwnerId = queues.get('CasesACCEuropeOffOnshore').Id;
                System.debug(LoggingLevel.FINE, 'cls [AMS_OscarCaseTriggerHelper - assignOscarToRegionQueue] Oscar assigned to Europe queue.');
            }
            else if(region.contains('China')){
                oscar.OwnerId = queues.get('AgencyManagementChinaNAsia').Id;
                System.debug(LoggingLevel.FINE, 'cls [AMS_OscarCaseTriggerHelper - assignOscarToRegionQueue] Oscar assigned to China queue.');
            }
            else if(region.contains('Africa')){
                oscar.OwnerId = queues.get('AgencyManagementAfricaME').Id;
                System.debug(LoggingLevel.FINE, 'cls [AMS_OscarCaseTriggerHelper - assignOscarToRegionQueue] Oscar assigned to Africa queue.');
            }
            else if(region.contains('Asia')){
                oscar.OwnerId = queues.get('AgencyManagementAP').Id;
                System.debug(LoggingLevel.FINE, 'cls [AMS_OscarCaseTriggerHelper - assignOscarToRegionQueue] Oscar assigned to Asia queue.');
            }
        }
    }


    //All cases having a parent which has Record Type OSCAR Communication must have the OSCAR field automaticaly populated
    /*public static void fillOSCARLookup(list<Case> triggerNew){

        List<Id> parentcaseIds = new List<Id>();

        for(Case c: triggerNew)
            if(c.ParentId != null)
                parentcaseIds.add(c.ParentId);

        //check parent record type
        Map<Id, Case> parentCase = new Map<Id, Case>([SELECT Id, Oscar__c, RecordTypeId FROM Case WHERE Id IN :parentcaseIds AND RecordTypeId = :OSCARCaseRecordTypeID]);

        for(Case c: triggerNew){
            Case parent = parentCase.get(c.parentId);
            if(parent!=null && parent.Oscar__c != null && parent.RecordTypeId == OSCARCaseRecordTypeID)
                c.Oscar__c = parent.Oscar__c;
        }

    }*/

    public static Set<Id> caseIrregularityCreated{
        get{
            if(caseIrregularityCreated == null) caseIrregularityCreated = new Set<Id>();
            return caseIrregularityCreated;
        }

        set;
    }

    public static void checkIrregularityThreshold() {
        List<Case> triggerNew = (List<Case>)Trigger.new;

        Id sidraRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        Id sidraLiteRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA_Lite');

        List<Case> newSidraCases = new List<Case>();
        Map<Id, Account> accounts = new Map<Id, Account>();
        for(Case c : triggerNew){
            if(c.RecordTypeId == sidraRecTypeId || c.RecordTypeId == sidraLiteRecTypeId){
                newSidraCases.add(c);
                accounts.put(c.AccountId, null);
            }
        }

        if(newSidraCases.isEmpty()) return;

        Set<Id> isoCountries = new Set<Id>();
        for(Account a : [SELECT Id, IATA_ISO_Country__c, Location_Class__c FROM Account WHERE IATA_ISO_Country__c != null AND Location_Class__c != null AND Id IN :accounts.keySet()]){
            accounts.put(a.Id, a);
            isoCountries.add(a.IATA_ISO_Country__c);
        }

        Map<String, Decimal> thresholds = new Map<String, Decimal>();
        for(IATA_ISO_Country__c country : IATAIsoCountryDAO.getIsoCountriesByIds(isoCountries)){

            for(AMS_Country_Specific_Attribute__c att : country.AMS_Country_Specific_Attributes__r){
                if(att.RecordType.DeveloperName == 'Irregularity_Threshold' && att.Threshold__c != null && att.Location_Class__c != null){
                    thresholds.put(''+country.Id+att.Location_Class__c, att.Threshold__c);
                }
            }
        }
        System.debug(loggingLevel.Debug, '____ [trg AMS_OscarCaseTriggerHelper - checkIrregularityThresold] thresholds - ' + thresholds);

        for(Case c : newSidraCases){
            Account a = accounts.get(c.AccountId);
            if(a != null){
                 c.Acc_IRR_leading_to_DEF__c = thresholds.get(''+a.IATA_ISO_Country__c+a.Location_Class__c);
                 system.debug(logginglevel.error, 'DTULLO 301 --> ' +  thresholds.get(''+a.IATA_ISO_Country__c+a.Location_Class__c));
            }
        }
    }
    

    //creates new change codes when a sidra case is closed
    public static void createSidraIrregularities() {
        List<Case> IRRCases = new List<Case>();
        List<Case> IRRWDCases = new List<Case>();

        Id sidraRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        for(Case c : (List<Case>)Trigger.new){
            Case cOld = (Trigger.isInsert ? null : (Case)Trigger.oldMap.get(c.Id));
            if(c.RecordTypeId == sidraRecTypeId){
                if(c.IRR_Withdrawal_Approval_Rejection__c == 'Approved' && (Trigger.isInsert || cOld.IRR_Withdrawal_Approval_Rejection__c != 'Approved') && caseIrregularityCreated.add(c.Id)) IRRWDCases.add(c);
                if(c.IRR_Approval_Rejection__c == 'Approved' && (Trigger.isInsert || cOld.IRR_Approval_Rejection__c != 'Approved') && caseIrregularityCreated.add(c.Id)) IRRCases.add(c);
            }
        }

        if(IRRCases.isEmpty() && IRRWDCases.isEmpty()) return;

        List<Agency_Applied_Change_code__c> irregularities = new List<Agency_Applied_Change_code__c>();

        for(Case c : IRRCases) irregularities.add(createChangeCodeFromCase(c, 'A'));
        for(Case c : IRRWDCases) irregularities.add(createChangeCodeFromCase(c, 'W'));

        insert irregularities;
    }

    private static Agency_Applied_Change_code__c createChangeCodeFromCase(Case c, String operation) {
        Agency_Applied_Change_code__c irr = new Agency_Applied_Change_code__c();
        irr.Account__c = c.AccountId;
        irr.Change_Code__c = 'IRR';
        irr.SIDRA_Case__c = c.Id;
        irr.Operation__c = operation;

        irr.Irregularities_Points__c = 0;
        if(c.IRR_Type__c == 'Single Irregularity') irr.Irregularities_Points__c = 1;
        if(c.IRR_Type__c == 'Double Irregularity') irr.Irregularities_Points__c = 2;

        return irr;
    }

    
    private static id RTSidra = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
    private static id RTSidraLite = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA_Lite');
    
    public static void CreateRiskChangeCode(){
        if(AMS_OscarCase_RiskMgmt.runOnce()){
            map<id, case> mapNewCase = new map<id, case>();
            map<id, case> mapOldCase = new map<id, case>();
            
            for(Case c : (List<Case>)Trigger.new){
                Case cOld = (Trigger.isInsert ? null : (Case)Trigger.oldMap.get(c.Id));
                if(c.RecordTypeId == RTSidra || c.RecordTypeId == RTSidraLite){
                    mapNewCase.put(c.Id, c);
                    if(cOld!=null)
                        mapOldCase.put(cOld.id, cOld);
                }
            }
            system.debug('DTULLO Helper 334 --> ' + mapNewCase.size());
            if(!mapNewCase.isEmpty())
                AMS_OscarCase_RiskMgmt.CreateRiskChangeCode(mapOldCase, mapNewCase);
        }
        
    }

    /*AMS-1580 and AMS-1585*/
    public static void copyDataFromOscar() {
        Map<Id, Case> oldMap = (Map<Id, Case>)Trigger.oldMap;

        List<Case> oscarCases = new List<Case>();
        Map<Id, AMS_OSCAR__c> oscars = new Map<Id, AMS_OSCAR__c>();

        for(Case c : (List<Case>) Trigger.New){
            if(c.RecordTypeID == OSCARCaseRecordTypeID && c.OSCAR__c != null && !Trigger.isDelete){ 
                oscarCases.add(c);
                oscars.put(c.Oscar__c, null);
            }
        }

        if(oscarCases.isEmpty()) return;
        /*** AMSU-205 added the process details list ***/
        oscars = new Map<Id, AMS_OSCAR__c>([
            SELECT Id, OwnerId, Status__c, Account__r.Name, Account__r.Location_Type__c, Location_Class__c, Account__r.Category__c, 
                Account__r.ANG_Accreditation_Model__c, Process__c, Account__r.IATACode__c, Account__r.IATA_ISO_Country__r.Name, Account__r.ANG_IsNewGenAgency__c, 
                Type_of_change__c, (SELECT AMS_IATAcode__c FROM AMS_Process_Detail__r) 
            FROM AMS_OSCAR__c WHERE Id IN :oscars.keySet()]);

        for(Case c : oscarCases){
            
            if(c.OwnerId != oscars.get(c.Oscar__c).OwnerId)
                c.OwnerId = oscars.get(c.Oscar__c).OwnerId;
            
            if(c.Status != oscars.get(c.Oscar__c).Status__c)
                c.Status = oscars.get(c.Oscar__c).Status__c;

            String typeOfCustomer = AMS_Utils.fetchTypeOfCustomer(oscars.get(c.Oscar__c).Account__r.Location_Type__c,oscars.get(c.Oscar__c).Account__r.Category__c);

            if(typeOfCustomer != null && typeOfCustomer != c.Type_of_customer__c)
                c.Type_of_customer__c = typeOfCustomer;

            String newCaseSubject = null;
            String newDescription = null;//AMSU-205
            
            if(c.reason1__c != null)
                if(oscars.get(c.Oscar__c).Process__c == AMS_Utils.NGVR && oscars.get(c.Oscar__c).Account__r.ANG_IsNewGenAgency__c)
                    newCaseSubject = c.reason1__c + ' - ' +oscars.get(c.Oscar__c).Account__r.Name;
                else if((oscars.get(c.Oscar__c).Process__c == AMS_Utils.NGFOP || oscars.get(c.Oscar__c).Process__c == AMS_Utils.NGANNUALREVAL)  && (c.Origin == 'Internal User' || c.Origin == 'Email'))
                    newCaseSubject = c.reason1__c + ' - ' + oscars.get(c.Oscar__c).Account__r.IATACode__c + ' - ' +oscars.get(c.Oscar__c).Account__r.Name;
                else if(oscars.get(c.Oscar__c).Process__c == AMS_Utils.NGANNUALREVAL || c.Origin == AMS_Utils.ANG_FOP_AUTOMATIC_RENEWAL || (oscars.get(c.Oscar__c).Process__c == AMS_Utils.NGFOP && (c.Origin == 'Portal' || c.Origin == AMS_Utils.ANG_MASSIVE_FOP)))
                    newCaseSubject = 'PCI DSS compliance - ' + oscars.get(c.Oscar__c).Account__r.IATACode__c + ' - ' +oscars.get(c.Oscar__c).Account__r.Name;
                else if(oscars.get(c.Oscar__c).Process__c == AMS_Utils.NEWHELITE)
                    newCaseSubject = 'New Head Entity - GoLite - ' + oscars.get(c.Oscar__c).Account__r.IATA_ISO_Country__r.Name;
                else if(oscars.get(c.Oscar__c).Process__c == AMS_Utils.NEWHESTANDARD)
                    newCaseSubject = 'New Head Entity - GoStandard - ' + oscars.get(c.Oscar__c).Account__r.IATA_ISO_Country__r.Name;
                else if(oscars.get(c.Oscar__c).Process__c == AMS_Utils.NEWAE)
                    newCaseSubject = 'New Associate Entity - ' + AMS_Utils.officialAccreditationTypeMap.get(oscars.get(c.Oscar__c).Account__r.ANG_Accreditation_Model__c) + ' - ' + oscars.get(c.Oscar__c).Account__r.IATA_ISO_Country__r.Name;
                else if(oscars.get(c.Oscar__c).Account__r.ANG_IsNewGenAgency__c && oscars.get(c.Oscar__c).Process__c != AMS_Utils.NGCHINACONVERSION)
                    newCaseSubject = c.reason1__c + ' - ' + AMS_Utils.officialAccreditationTypeMap.get(oscars.get(c.Oscar__c).Account__r.ANG_Accreditation_Model__c) + ' - ' + oscars.get(c.Oscar__c).Account__r.Name;
                else if(oscars.get(c.Oscar__c).Process__c == AMS_Utils.new_MSO || (c.Subject != null && c.Subject.startsWith('MSO code '))) //AMSU-119
					newCaseSubject = null;
                else if(oscars.get(c.Oscar__c).Process__c == AMS_Utils.COR && oscars.get(c.Oscar__c).Location_Class__c == 'I' && c.Origin == 'Portal') //AMSU-140
                    newCaseSubject = 'Agency Changes - ' +oscars.get(c.Oscar__c).Account__r.Name;
                else if(oscars.get(c.Oscar__c).Process__c == AMS_Utils.VOLRELINQUISH || oscars.get(c.Oscar__c).Process__c == AMS_Utils.VOLRELINQUISH_CA) { //AMSU-205
                    AMS_OSCAR__c oscar = oscars.get(c.Oscar__c); 
                    newCaseSubject = c.Reason1__c + ' - ' + oscar.Account__r.Name + ' - ' + oscar.Account__r.IATACode__c;
                    newDescription = oscar.Account__r.IATACode__c;

                    for(AMS_Process_Detail__c detail : oscar.AMS_Process_Detail__r) {
                        newDescription += '\n' + detail.AMS_IATAcode__c;
                    }
                } else {
                    AMS_OSCAR__c oscar = oscars.get(c.Oscar__c); 
                    newCaseSubject = c.reason1__c + ' - ' + oscar.Account__r.Name;
                    /*** AMSU-133 Start ***/
                    if(oscar.Process__c == AMS_Utils.AGENCYCHANGES && isTypeOfChange(new Set<String> {AMS_Utils.LOCATION, AMS_Utils.LOCATION_INSPECTION}, oscar)) {
                        newCaseSubject += String.isBlank(oscar.Account__r.IATACode__c) ? '' : ' - ' + oscar.Account__r.IATACode__c;
                    } 
                    /*** AMSU-133  End***/
                }

            if(newCaseSubject != null && c.Subject != newCaseSubject && (c.Subject == null || !c.Subject.startsWith(newCaseSubject)) && AMS_OscarMigrationFromCase.changeSubject)
                c.Subject = newCaseSubject;

            //AMSU-205
            if(newDescription <> null) {
                c.Description = newDescription;
            }
        }
    }

    /*** AMSU-133 Start ***/
    private static Boolean isTypeOfChange(Set<String> changes, AMS_OSCAR__c oscar) {
        Set<String> typesOfChange = new Set<String>();

        if(!String.isBlank(oscar.Type_of_change__c)) {
            typesOfChange.addAll(oscar.Type_of_change__c.split(';'));
        }

        for(String toc : changes) {
            if(typesOfChange.contains(toc)) {
                return true;  
            }
        }

        return false;
    }
    /*** AMSU-133  End***/
}
