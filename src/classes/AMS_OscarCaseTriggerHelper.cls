public class AMS_OscarCaseTriggerHelper {
    
    /**
        This is helper class for both OSCAR and OSCAR Case Communication
    **/

    //used to assign new created oscars to one of 5 queues, pending on the region.
    //public static List<Group> queues = [ select Id, DeveloperName from Group where  Type = 'Queue' and DeveloperName in ('Africa_ME_OSCAR','Americas_OSCAR','Asia_Pacific_OSCAR','China_N_Asia_OSCAR','Europe_OSCAR')];
    public static List<Group> queues = [ select Id, DeveloperName from Group where  Type = 'Queue' and DeveloperName in ('AgencyManagementAP','AgencyManagementAfricaME','AgencyManagementAmericas','AgencyManagementChinaNAsia','CasesACCEuropeOffOnshore')];


    public static void OSCARCaseCreationRules(list<Case> triggerNew){
        ID OSCARCaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('OSCAR Communication');

        List<Case> caseOSCARMap = null;

        for(Case c: triggerNew){
            if(c.RecordTypeID == OSCARCaseRecordTypeID && c.OSCAR__c != null){
                if(caseOSCARMap==null)
                    caseOSCARMap = [SELECT Id, OSCAR__c FROM Case WHERE OSCAR__c != null];
                for(Case oscarCase: caseOSCARMap){
                    if(oscarCase.Oscar__c == c.Oscar__c)
                        c.addError('The OSCAR assigned to this Case already has a Case Assigned.');
                }
                
            }
            
        }
    }

    public static void OSCARCaseUpdateRules(list<Case> triggerNew, map<Id, Case> triggerOldMap){
        ID OSCARCaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('OSCAR Communication');

        List<Case> caseOSCARMap = null;

        for(Case c: triggerNew){
            if(c.RecordTypeID == OSCARCaseRecordTypeID && triggerOldMap.get(c.id).Oscar__c == null && c.OSCAR__c != null){
                if(caseOSCARMap==null)
                    caseOSCARMap = [SELECT Id, OSCAR__c FROM Case WHERE OSCAR__c != null];
                for(Case oscarCase: caseOSCARMap){
                    if(oscarCase.Oscar__c == c.Oscar__c)
                        c.addError('The OSCAR assigned to this Case already has a Case Assigned.');
                }
                
            }
            
        }
    }

    public static void blockForbbidenActions(list<Case> triggerNew, map<Id, Case> triggerOldMap){
        ID OSCARCaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('OSCAR Communication');

        for(Case c: triggerNew){
            if(triggerOldMap.get(c.id).RecordTypeId == OSCARCaseRecordTypeID && c.RecordTypeId != OSCARCaseRecordTypeID && triggerOldMap.get(c.id).OSCAR__c != null){
                throw new transformationException('Cannot change the record type of an OSCAR Communication case having an OSCAR assigned.');
            }
            if(triggerOldMap.get(c.id).Oscar__c != null && triggerOldMap.get(c.id).Oscar__c <> c.Oscar__c){
                c.addError('Cannot disattach OSCAR from Case.');
            }
        }
    }

    public static void renameOSCAR(list<Case> triggerNew){

        System.debug('Renaming OSCAR');

        ID OSCARCaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('OSCAR Communication');

        List<AMS_OSCAR__c> oscarsToUpdate = new List<AMS_OSCAR__c>();
        Map<Id,AMS_OSCAR__c> oscars = null;

        Set<Id> oscarIds = new Set<Id>();

         for(Case c: triggerNew)
            if(c.OSCAR__c != null)
                oscarIds.add(c.Oscar__c);

        for(Case c: triggerNew){

            if(c.RecordTypeID == OSCARCaseRecordTypeID){
                if(oscars==null)
                    oscars = new Map<Id,AMS_OSCAR__c>([SELECT Id,Name FROM AMS_OSCAR__c where Id = :oscarIds]);
                AMS_OSCAR__c oscar = oscars.get(c.OSCAR__c);
                if(oscar!= null && oscar.Name != c.CaseNumber){

                    System.debug('Renaming OSCAR with ID ' + oscar.Id);
                    
                    oscar.Name = c.CaseNumber;
                    oscarsToUpdate.add(oscar);
                }

            }
        }

        update oscarsToUpdate;

    }

    public static void assignOscarToRegionQueue(List<AMS_OSCAR__c> triggerNew){

        String americas = null;
        String europe = null;
        String china = null;
        String africa = null;
        String asia = null;

        for(Group q:queues){

            if(q.DeveloperName.equals('AgencyManagementAmericas'))
                americas = q.id;
            else if(q.DeveloperName.equals('CasesACCEuropeOffOnshore'))
                europe = q.id;
            else if(q.DeveloperName.equals('AgencyManagementChinaNAsia'))
                china = q.id;
            else if(q.DeveloperName.equals('AgencyManagementAfricaME'))
                africa = q.id;
            else if(q.DeveloperName.equals('AgencyManagementAP'))
                asia = q.id;
        }

        Set<Id> agencyids = new Set<Id>();
        
            for(AMS_OSCAR__c o:triggerNew){
                if(o.Account__c != null)
                    agencyids.add(o.Account__c);
            }

        Map<Id,Account> mapAgencies = new Map<Id,Account>([select id, IATA_ISO_Country__r.Region__c from Account where id in :agencyids]);  
        
        for(AMS_OSCAR__c oscar: triggerNew){

            Account ag = mapAgencies.get(oscar.Account__c);

            if(ag == null)
                continue;

            String region = fetchRegion(ag);

            if(region == null)
                continue;

            if(region.contains('Americas')){
                oscar.OwnerId = americas;
                System.debug('Oscar assigned to Americas queue.');
            }
            else if(region.contains('Europe')){
                oscar.OwnerId = europe;
                System.debug('Oscar assigned to Europe queue.');
            }
            else if(region.contains('China')){
                oscar.OwnerId = china;
                System.debug('Oscar assigned to China queue.');
            }
            else if(region.contains('Africa')){
                oscar.OwnerId = africa;
                System.debug('Oscar assigned to Africa queue.');
            }
            else if(region.contains('Asia')){
                oscar.OwnerId = asia;
                System.debug('Oscar assigned to Asia queue.');
            }

        }

    }

    public static String fetchRegion(Account agency){

        if(agency.IATA_ISO_Country__r == null || agency.IATA_ISO_Country__r.Region__c == null)
            return null;

        return agency.IATA_ISO_Country__r.Region__c;

    }


    //All cases having a parent which has Record Type OSCAR Communication must have the OSCAR field automaticaly populated
    public static void fillOSCARLookup(list<Case> triggerNew){

        ID OSCARCaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('OSCAR Communication');

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

    }

    public static Set<Id> caseIrregularityCreated{
        get{
            if(caseIrregularityCreated == null) caseIrregularityCreated = new Set<Id>();
            return caseIrregularityCreated;
        }

        set;
    }

    public static void checkIrregularityThreshold() {
        List<Case> triggerNew = (List<Case>)Trigger.new;

        Id sidraRecTypeId = Schema.Case.sObjectType.getDescribe().getRecordTypeInfosByName().get('SIDRA').getRecordTypeId();

        List<Case> newSidraCases = new List<Case>();
        Map<Id, Account> accounts = new Map<Id, Account>();
        for(Case c : triggerNew){
            if(c.RecordTypeId == sidraRecTypeId){
                newSidraCases.add(c);
                accounts.put(c.AccountId, null);
            }
        }

        if(newSidraCases.isEmpty()) return;

        Set<Id> isoCountries = new Set<Id>();
        for(Account a : [SELECT Id, IATA_ISO_Country__c, Location_Class__c FROM Account WHERE Id IN :accounts.keySet()]){
            accounts.put(a.Id, a);
            isoCountries.add(a.IATA_ISO_Country__c);
        }

        Map<String, Decimal> thresholds = new Map<String, Decimal>();
        for(IATA_ISO_Country__c country : [SELECT
                                                        Id
                                                        , (SELECT
                                                                Id
                                                                , Threshold__c
                                                                , Location_Class__c
                                                            FROM AMS_Country_Specific_Attributes__r
                                                            WHERE RecordType.Name = 'Irregularity Threshold')
                                                    FROM IATA_ISO_Country__c
                                                    WHERE Id IN :isoCountries])
        {
            for(AMS_Country_Specific_Attribute__c att : country.AMS_Country_Specific_Attributes__r){
                thresholds.put(country.Id+att.Location_Class__c, att.Threshold__c);
            }
        }
        System.debug(loggingLevel.Debug, '____ [trg AMS_OscarCaseTriggerHelper - checkIrregularityThresold] thresholds - ' + thresholds);

        for(Case c : newSidraCases){
            Account a = accounts.get(c.AccountId);
            c.Acc_IRR_leading_to_DEF__c = thresholds.get(a.IATA_ISO_Country__c+a.Location_Class__c);
        }
    }
    

    //creates new change codes when a sidra case is closed
    public static void createSidraIrregularities() {
        List<Case> IRRCases = new List<Case>();
        List<Case> IRRWDCases = new List<Case>();

        Id sidraRecTypeId = Schema.Case.sObjectType.getDescribe().getRecordTypeInfosByName().get('SIDRA').getRecordTypeId();
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


    /*AMS-1580*/
    public static void copyOwner() {

        Map<Id, Case> oldMap = (Map<Id, Case>)Trigger.oldMap;

        Id OSCARCaseRecordTypeID = Schema.Case.sObjectType.getDescribe().getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();
        List<Case> oscarCases = new List<Case>();
        Map<Id, AMS_OSCAR__c> oscars = new Map<Id, AMS_OSCAR__c>();

        for(Case c : (List<Case>) Trigger.New){
            if(
                c.RecordTypeID == OSCARCaseRecordTypeID
                && c.OSCAR__c != null
                && (Trigger.isInsert || (Trigger.isUpdate && oldMap.get(c.Id).Oscar__c != c.Oscar__c))
            ){
            
                oscarCases.add(c);
                oscars.put(c.Oscar__c, null);
            }
        }

        if(oscarCases.isEmpty()) return;

        oscars = new Map<Id, AMS_OSCAR__c>([SELECT Id, OwnerId FROM AMS_OSCAR__c WHERE Id IN :oscars.keySet()]);

        for(Case c : oscarCases){
            c.OwnerId = oscars.get(c.Oscar__c).OwnerId;
        }
    }

}