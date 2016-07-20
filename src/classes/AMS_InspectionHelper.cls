public class AMS_InspectionHelper {

    public static void setStatusCodeOnAgency(list<AMS_Inspection__c> inspections){
        
        List<AMS_Inspection__c> iataInspections = new List<AMS_Inspection__c>();
        Set<String> agencyIds = new Set<String>();
        
        Map<Id,AMS_Accreditation_Organization__c> dom = new Map<Id,AMS_Accreditation_Organization__c>( [select id from AMS_Accreditation_Organization__c where Air_Code__c = 'DOM']);
        Map<Id,AMS_Accreditation_Organization__c> iata = new Map<Id,AMS_Accreditation_Organization__c>( [select id from AMS_Accreditation_Organization__c where Air_Code__c = 'IATA']);
        Map<Id,AMS_Accreditation_Organization__c> iatan = new Map<Id,AMS_Accreditation_Organization__c>( [select id from AMS_Accreditation_Organization__c where Air_Code__c = 'IATAN']);
        
        if(dom.size() > 0){
            for(AMS_Inspection__c i:inspections){
                if(dom.get(i.Accreditation_Endorsement_organisation__c)!=null){
                    iataInspections.add(i);
                    agencyIds.add(i.agency__c);
                }

            }

            Map<Id,AMS_Agency__c> mapAgencies = new Map<Id,AMS_Agency__c>([select id, Account__c, Account__r.Status__c, Account__r.Id, Agency_Status__c from AMS_Agency__c where id IN :agencyIds]);

            for(AMS_Inspection__c i:iataInspections){
                if(mapAgencies.get(i.Agency__c) != null){
                    mapAgencies.get(i.Agency__c).Agency_Status__c = getIATAReadableStatus(i.Accreditation_Endorsement_Status_code__c);
                }
            }
            if(mapAgencies.values().size() > 0)
                update mapAgencies.values();
        }

        if(iata.size() > 0){
            for(AMS_Inspection__c i:inspections){
                if(iata.get(i.Accreditation_Endorsement_organisation__c)!=null){
                    iataInspections.add(i);
                    agencyIds.add(i.agency__c);
                }

            }

            Map<Id,AMS_Agency__c> mapAgencies = new Map<Id,AMS_Agency__c>([select id, Account__c, Account__r.Status__c, Account__r.Id, Agency_Status__c from AMS_Agency__c where id IN :agencyIds]);

            for(AMS_Inspection__c i:iataInspections){
                if(mapAgencies.get(i.Agency__c) != null){
                    mapAgencies.get(i.Agency__c).Agency_Status__c = getIATAReadableStatus(i.Accreditation_Endorsement_Status_code__c);
                }
            }
            if(mapAgencies.values().size() > 0)
                update mapAgencies.values();
        }
        
        // reseting...
        iataInspections = new List<AMS_Inspection__c>();
        agencyIds = new Set<String>();
        
        if(iatan.size() > 0){
            for(AMS_Inspection__c i:inspections){
                if(iatan.get(i.Accreditation_Endorsement_organisation__c)!=null){
                    iataInspections.add(i);
                    agencyIds.add(i.agency__c);
                }

            }

            Map<Id,AMS_Agency__c> mapAgencies = new Map<Id,AMS_Agency__c>([select id, Account__c, Account__r.Status__c, Account__r.Id, Agency_Status__c from AMS_Agency__c where id IN :agencyIds]);
            
            for(AMS_Inspection__c i:iataInspections){
                if(mapAgencies.get(i.Agency__c) != null){
                    mapAgencies.get(i.Agency__c).Agency_Status__c = getIATANReadableStatus(i.Accreditation_Endorsement_Status_code__c);
                }
            }
            if(mapAgencies.values().size() > 0)
                update mapAgencies.values();
        }
        
        
    }
    
        public static String getIATAReadableStatus(String endorsmentCode){
        
                    if(endorsmentCode == '0'){
                        return 'Terminated';
                    }
            
     
                    if(endorsmentCode == '1'){
                       return 'Not accreditated';
                    }
                   if(endorsmentCode == '2'){
                        return 'New application pending';
                   }
                    if(endorsmentCode == '3'){
                        return 'Not in operation';
                   }
                    
 
                    if(endorsmentCode == '4'){
                        return 'Listed';
                    }
                    
                    if(endorsmentCode ==  '5'){
                       return 'Cash basis/no commission';
                    }
                    
                    if(endorsmentCode == '6'){
                        return 'Cash basis/with commission';
                    }
            
                    if(endorsmentCode == '7'){
                        return 'Under review';
                    }
            
                    if(endorsmentCode == '8'){
                        return 'Changes processed';
                    }
                    if(endorsmentCode == '9'){
                        return 'Accredited';
                    }
            
                    return null;
            }
    
            public static String getIATANReadableStatus(String endorsmentCode){
        
                    if(endorsmentCode == '0'){
                        return 'Terminated';
                    }
                    if(endorsmentCode == '2'){
                        return 'New application pending';
                    }
                   
                    if(endorsmentCode == '4'){
                        return 'Listed';
                    }
                    
                    if(endorsmentCode ==  '5'){
                       return 'Listed(BSP)';
                    }
                    
                    if(endorsmentCode == '6'){
                        return 'Under review';
                    }
            
                    if(endorsmentCode == '7'){
                        return 'Accredited';
                    }
            
                    return null;
            }
    
}