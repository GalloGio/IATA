public class AMS_AgencyAChangeCodeHandler {

	public static void handleAfterInsert(List<Agency_Applied_Change_code__c> aacc) {

		verifyActiveAACCuniqueness(aacc);

	}

	public static void handleAfterUpdate(List<Agency_Applied_Change_code__c> aacc) {

		verifyActiveAACCuniqueness(aacc);
	}

	public static void handleBeforeInsert(List<Agency_Applied_Change_code__c> aacc){

		migrateFieldsFromStagingToAccount(aacc);
	}

	public static void verifyActiveAACCuniqueness(List<Agency_Applied_Change_code__c> aaccodes){

		List<Agency_Applied_Change_code__c> aACCtoUpdate = new List<Agency_Applied_Change_code__c>();

	    Set<Id> agencyIds = new Set<Id>();

	    for(Agency_Applied_Change_code__c aacc : aaccodes){
	        
	        if(aacc.Active__c){
	       		
	       		agencyIds.add(aacc.Account__c);
	        }
	    }

		if(agencyIds.size() > 0){

			List<Agency_Applied_Change_code__c> elementsToUpdate = new List<Agency_Applied_Change_code__c>();
			
			for(Agency_Applied_Change_code__c aacc : [select id, Active__c , Account__c from Agency_Applied_Change_code__c where Active__c = true AND Account__c IN :agencyIds]){
		
		    	if(Trigger.newMap.containsKey(aacc.id) == false) {
		    		
		    		aacc.Active__c = false;
		    		elementsToUpdate.add(aacc);
		    	}	
			}
		
			if(elementsToUpdate.size() > 0){
				
				update elementsToUpdate;
			}
		}

	}


	public static void migrateFieldsFromStagingToAccount(List<Agency_Applied_Change_code__c> aacc){

		// this method aaplies only to change codes that have an OSCAR filled. That OSCAR must be of record type NEW and have process of type NEW.HO.1.0, NEW.BR OR NEW.BR.ABROAD
		// when creating a change code of type FIN or DIS, it should copy the information from staging Area (AMS_Pax_Accreditation_Form__c) into Master Data (Account)

		Id rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();

		Set<Id> oscarIds = new Set<Id>();

		for(Agency_Applied_Change_code__c code: aacc){
			if(code.OSCAR__c != null && ( code.change_code__c == 'FIN' || code.change_code__c == 'DIS')){
				oscarIds.add(code.OSCAR__c);
			}
		}

		//let's first find the OSCAR that need to be migrated
		List<AMS_OSCAR__c> oscarsToCopyData = new List<AMS_OSCAR__c>();

		//aacclist = [SELECT ID, OSCAR__c, OSCAR__r.Account__c , OSCAR__r.AMS_Online_Accreditation__c from Agency_Applied_Change_code__c where id in :aaccIds and OSCAR__r.RecordTypeId = :rtNew and OSCAR__r.Process__c in ('NEW.HO.1.0','NEW.BR','NEW.BR.ABROAD') ];

		oscarsToCopyData = [SELECT ID, Account__c, AMS_Online_Accreditation__c, RecordTypeId from AMS_OSCAR__C where Id in :oscarIds and RecordTypeId = :rtNew and Process__c in ('NEW.HO.1.0','NEW.BR','NEW.BR.ABROAD')  ];

		if(!oscarsToCopyData.isEmpty()){
			AMS_Utils.copyDataToAccount(oscarsToCopyData);
		}else{
			System.debug('Nothing to migrate here.');
		}

		
	}

}