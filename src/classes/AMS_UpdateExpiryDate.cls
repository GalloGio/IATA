/*
*WARNING: This batch is only to run once, to clean the expiry date on agency and account
*delete this batch after the process finished
*/

global class AMS_UpdateExpiryDate implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {//Iterable<sObject>
        //return [select id, Recert_Expiry_Date__c from AMS_Agency__c where Agency_Status__c = 'Terminated' and legacy_system__c LIKE 'AIMS%'];
        return Database.getQueryLocator('select id, Recert_Expiry_Date__c from AMS_Agency__c where Agency_Status__c = \'Terminated\' and legacy_system__c LIKE \'AIMS%\'');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<AMS_Agency__c> agenciesToUpdate = new List<AMS_Agency__c>();
        Set<ID> agencyIDS = new Set<ID>();
        Map<String, AMS_Agency__c> agencies = new Map<String, AMS_Agency__c>();
        for(sObject s:scope){
            agencyIDS.add(s.ID);
            agencies.put(s.ID, (AMS_Agency__c)s);
        }
        system.debug('agencies -->' + [select id, Accreditation_Endorsement_organisation__c, Account__r.Main_Accreditation_Organization__c, Account__r.Date_Organisation_Status_attained__c, Accreditation_Endorsement_Status_code__c, Agency__c, Date_Organisation_Status_attained__c
                                                from AMS_Inspection__c LIMIT 2]);
        List<AMS_Inspection__c> inspections = [select id, Accreditation_Endorsement_organisation__c, Account__r.Main_Accreditation_Organization__c,  Account__r.Date_Organisation_Status_attained__c, Accreditation_Endorsement_Status_code__c, Agency__c, Date_Organisation_Status_attained__c
                                                from AMS_Inspection__c where Accreditation_Endorsement_Status_code__c = '0'
                                                                        AND Agency__c IN :agencyIDS
                                                                        AND (Account__r.Main_Accreditation_Organization__c = 'IATA' OR Account__r.Main_Accreditation_Organization__c = 'DOM')];

        Map<String, AMS_Inspection__c> agencyToInspection = new Map<String, AMS_Inspection__c>();
        for(AMS_Inspection__c i:inspections){
            if(agencyToInspection.get(i.Agency__c) == null){
                agencyToInspection.put(i.Agency__c, i);
            }
            else{
                if(agencyToInspection.get(i.Agency__c).Account__r.Date_Organisation_Status_attained__c < i.Account__r.Date_Organisation_Status_attained__c){
                    agencyToInspection.put(i.Agency__c,i);
                }
            }
        }

        for(AMS_Inspection__c i:agencyToInspection.values()){
            if(agencies.get(i.Agency__c) != null){
                agencies.get(i.Agency__c).Recert_Expiry_Date__c = i.Account__r.Date_Organisation_Status_attained__c;
                agenciesToUpdate.add(agencies.get(i.Agency__c));
            }
        }

        if(agenciesToUpdate.size() > 0)
            update agenciesToUpdate;
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}