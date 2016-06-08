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


}