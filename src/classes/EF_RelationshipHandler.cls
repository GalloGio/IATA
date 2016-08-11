public class EF_RelationshipHandler 
{

    //checks if location chosen has been set in Contract Location Currency.
    public static void checkLocationCurrency (List<EF_Relationship__c> relationshipList){

        //check if relationship records have location.
        List <EF_Relationship__c> relWithLocation = new List <EF_Relationship__c>();

        for(EF_Relationship__c rel: relationshipList){
            if(rel.EF_Location_ID__c!=null){
                relWithLocation.add(rel);
            }
        }

        Set <Id> contractIdSet = new Set <Id>();

        if(!relWithLocation.isEmpty()){

            for(EF_Relationship__c r: relWithLocation){
                contractIdSet.add(r.Contract__c);
            }

            Map <Id, Contract> contractMap = new Map <Id, Contract>([Select Id, (Select Id, Location_ID__c, Location_ID__r.Name, Contract__c, CurrencyISOCode from EF_Locations_Currencies__r),
            (select Id, EF_Location_ID__c, EF_Location_ID__r.Name, Contract__c from EF_Relationships__r) from Contract where Id in: contractIdSet]);
			
            //create a map in which we store all the locations present in contract
            Map <Id, EF_Location_Currency__c> mapLocationsInLocationCurrency = new Map <Id, EF_Location_Currency__c> ();
            
            for(Contract c: contractMap.values()){
                for(EF_Location_Currency__c lc: c.EF_Locations_Currencies__r){
                    mapLocationsInLocationCurrency.put(lc.Location_ID__c, lc);
                }
            }

            //create a map in which we store all the relationships already present in contract
            Map <Id, EF_Relationship__c> mapRelationshipsInContract = new Map <Id, EF_Relationship__c> ();
            for(Contract c: contractMap.values()){
                for(EF_Relationship__c r: c.EF_Relationships__r){
                    mapRelationshipsInContract.put(r.EF_Location_ID__c, r);
                }
            }
           
            //check if location chosen in relationship is present in Contract Location Currencies
            for(EF_Relationship__c r: relWithLocation){
                
                if(mapLocationsInLocationCurrency.isEmpty() && r.EF_Location_ID__c!=null){
                   r.EF_Location_ID__c.addError('Please set before location currencies on contract.');
                }else{
                    if(!mapLocationsInLocationCurrency.containsKey(r.EF_Location_ID__c)){
                        r.EF_Location_ID__c.addError('Location chosen is not allowed. It has not been defined in Contract as a valid location.');
                    }else{
                        if(mapRelationshipsInContract.containsKey(r.EF_Location_ID__c)){

                            r.EF_Location_ID__c.addError('Location chosen has already been set for another relationship');
                        }else{
                            for(EF_Location_Currency__c lc: contractMap.get(r.Contract__c).EF_Locations_Currencies__r){
                                System.debug('#### REL loc Id ' + r.EF_Location_ID__c + r.EF_Location_ID__r.Name + ' --- location Currency ' + lc.Location_ID__c + lc.Location_ID__r.Name);
                                if(r.EF_Location_ID__c== lc.Location_ID__c){
	                                // set currency in relationship as the one defined on the locationCurrency
	                                r.CurrencyISOCode = lc.CurrencyISOCode;
								}
							}
						}
					}
				}
            }
        }// end if relationship has location
    }
    
    //checks if currencues chosen has been set in Contract Currencies.
    public static void checkCurrencyFromContract (List<EF_Relationship__c> relationshipList, Map<Id,EF_Relationship__c> relationshipOldMap){
		
		String errorMessage = Label.EF_Currency_Not_In_Contract_Error;
        List<EF_Relationship__c> workdata = new List<EF_Relationship__c>();
        Set<Id> contractIdSet = new Set<Id>();

        for (EF_Relationship__c rel: relationshipList) {
            if ((rel.Data_Currency__c != null && relationshipOldMap!= null && relationshipOldMap.containsKey(rel.Id) && rel.Data_Currency__c != relationshipOldMap.get(rel.Id).Data_Currency__c) ||
            	(rel.Payment_Currency__c != null && relationshipOldMap != null && relationshipOldMap.containsKey(rel.Id) && rel.Payment_Currency__c != relationshipOldMap.get(rel.Id).Payment_Currency__c)) {
                
                workdata.add(rel);
                contractIdSet.add(rel.Contract__c);
            }
        }
        
        if (workdata.size() > 0) {
        	
            Map <Id, Contract> contractMap = new Map <Id, Contract>([Select Id, EF_Data_Currency__c, EF_Payment_Currency__c from Contract where Id in: contractIdSet]);
			Contract cont;
			Set<String> values;
			
			for (EF_Relationship__c rel : workdata) {
				
				cont = contractMap.get(rel.Contract__c);
				
				// Data_Currency__c validation
				if (cont.EF_Data_Currency__c != null) {
					
					values = new Set<String>(cont.EF_Data_Currency__c.split(';'));
				} else {
					
					values = new Set<String>();
				}
				
				if (values.contains(rel.Data_Currency__c) == false) {
					
					rel.Data_Currency__c.addError(errorMessage);
				}
				
				values = null;
				
				// Payment_Currency__c validation
				if (cont.EF_Payment_Currency__c != null) {
					
					values = new Set<String>(cont.EF_Payment_Currency__c.split(';'));
				} else {
					
					values = new Set<String>();
				}
				
				if (values.contains(rel.Payment_Currency__c) == false) {
					
					rel.Payment_Currency__c.addError(errorMessage);
				}
			}
        }
    }
}