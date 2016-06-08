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
                    agencyIds.add(i.Account__c);
                }

            }

            //Map<Id,AMS_Agency__c> mapAgencies = new Map<Id,AMS_Agency__c>([select id, Account__c, Account__r.Status__c, Account__r.Id, Agency_Status__c from AMS_Agency__c where id IN :agencyIds]);
            Map<Id,Account> mapAgencies = new Map<Id,Account>([select Id, Status__c from Account where id IN :agencyIds]);

            for(AMS_Inspection__c i:iataInspections){
                if(mapAgencies.get(i.Account__c) != null){
                    mapAgencies.get(i.Account__c).Status__c = AMS_Utils.getIATAReadableStatus(i.Accreditation_Endorsement_Status_code__c);
                }
            }
            if(mapAgencies.values().size() > 0)
                update mapAgencies.values();
        }

        if(iata.size() > 0){
            for(AMS_Inspection__c i:inspections){
                if(iata.get(i.Accreditation_Endorsement_organisation__c)!=null){
                    iataInspections.add(i);
                    agencyIds.add(i.Account__c);
                }

            }

            //Map<Id,AMS_Agency__c> mapAgencies = new Map<Id,AMS_Agency__c>([select id, Account__c, Account__r.Status__c, Account__r.Id, Agency_Status__c from AMS_Agency__c where id IN :agencyIds]);
            Map<Id,Account> mapAgencies = new Map<Id,Account>([select Id, Status__c from Account where id IN :agencyIds]);
            
            for(AMS_Inspection__c i:iataInspections){
                if(mapAgencies.get(i.Account__c) != null){
                    mapAgencies.get(i.Account__c).Status__c = AMS_Utils.getIATAReadableStatus(i.Accreditation_Endorsement_Status_code__c);
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
                    agencyIds.add(i.Account__c);
                }

            }

            //Map<Id,AMS_Agency__c> mapAgencies = new Map<Id,AMS_Agency__c>([select id, Account__c, Account__r.Status__c, Account__r.Id, Agency_Status__c from AMS_Agency__c where id IN :agencyIds]);
            Map<Id,Account> mapAgencies = new Map<Id,Account>([select Id, Status__c from Account where id IN :agencyIds]);

            for(AMS_Inspection__c i:iataInspections){
                if(mapAgencies.get(i.Account__c) != null){
                    mapAgencies.get(i.Account__c).Status__c = AMS_Utils.getIATANReadableStatus(i.Accreditation_Endorsement_Status_code__c);
                }
            }
            if(mapAgencies.values().size() > 0)
                update mapAgencies.values();
        }
        
        
    }
    
        /*public static String getIATAReadableStatus(String endorsmentCode){
        
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
            }*/
            
            
	public static void setRecertExpiryDateOnAccount(Map<Id, AMS_Inspection__c> oldValues, Map<Id, AMS_Inspection__c> newValues)
	{
		Map<Id, AMS_Inspection__c> statusCodeChanged = AMS_InspectionHelper.findAMSInspectionsWhereStatusCodeChangedToZero(oldValues, newValues);
		List<Account> accountsToProcess = new List<Account>();
		accountsToProcess = [select id, Expiry_Date__c from Account where id in :statusCodeChanged.keySet()];
		if(accountsToProcess.size() > 0)
		{
			for(Account acc : accountsToProcess)
			{
				acc.Expiry_Date__c = statusCodeChanged.get(acc.Id).Date_Organisation_Status_attained__c;
			}
			update accountsToProcess;
		}
	}
	
	private static Map<Id, AMS_Inspection__c> findAMSInspectionsWhereStatusCodeChangedToZero(Map<Id, AMS_Inspection__c> oldValues, Map<Id, AMS_Inspection__c> newValues)
	{
		Map<Id, AMS_Inspection__c> changedRecords = new Map<Id, AMS_Inspection__c>();
		for(AMS_Inspection__c current : newValues.values())
		{
			if(oldValues != null && oldValues.get(current.Id) != null)
			{
				AMS_Inspection__c currentOldRecord = oldValues.get(current.Id);
				if(current.Accreditation_Endorsement_Status_code__c != currentOldRecord.Accreditation_Endorsement_Status_code__c && current.Accreditation_Endorsement_Status_code__c.equals('0'))
				{
					changedRecords.put(current.Account__c, current);
				}
			} else if(current.Accreditation_Endorsement_Status_code__c.equals('0'))
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
    
}