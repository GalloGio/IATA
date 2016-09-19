public class EF_LocationCurrencyHandler {

	public static void manageNewLocationCurrency (List<EF_Location_Currency__c> locationCurrencyList, String action) {
                
		//First avoid adding the same location in two location currencies
		
		//get set for Contract
		Set <Id> contractIdSet = new Set <Id>();
		for(EF_Location_Currency__c lc: locationCurrencyList){
			contractIdSet.add(lc.Contract__c);
		}
		//get contract, with the location currencies that are already set on the contract.
		Map<Id, Contract> mapContract = new Map<Id, Contract> ([select Id, EF_Billing_Currency__c, (select Id, Location_ID__c, Location_ID__r.Name, EF_Billing_Currency__c from EF_Locations_Currencies__r) from Contract where Id in: contractIdSet order by id]);
        
		//Set to hold the location names already added to the contract
		Map <Id, EF_Location_Currency__c> locationContractMap = new Map <Id, EF_Location_Currency__c>();
        
        for(Contract c: mapContract.values()) {
            if (c.EF_Locations_Currencies__r != null && c.EF_Locations_Currencies__r.size() != 0) {
                for(EF_Location_Currency__c lc: c.EF_Locations_Currencies__r){
                    locationContractMap.put(lc.Location_ID__c, lc);
                }
            }
		} 
                
		//the contract contains already some location currencies added
		if(!locationContractMap.isEmpty()) {            
			//check if the location we try to add has already been set 
			for(EF_Location_Currency__c lc: locationCurrencyList) {
				if(locationContractMap.containsKey(lc.Location_ID__c) ) {
                    if(action == 'insert') {
                        lc.Location_ID__c.addError('The location chosen has already been added to the contract.');
                    }
                } else {
                    //System.debug(Logginglevel.ERROR, '#### lc.EF_Billing_Currency__c ' + lc.EF_Billing_Currency__c);
                    //System.debug(Logginglevel.ERROR, '#### mapContract.get(lc.Contract__c).EF_Billing_Currency__c ' + mapContract.get(lc.Contract__c).EF_Billing_Currency__c);                                 
                    if(mapContract.get(lc.Contract__c).EF_Billing_Currency__c!= null && !mapContract.get(lc.Contract__c).EF_Billing_Currency__c.contains(lc.EF_Billing_Currency__c)){
                        mapContract.get(lc.Contract__c).EF_Billing_Currency__c = mapContract.get(lc.Contract__c).EF_Billing_Currency__c + ';' + lc.EF_Billing_Currency__c;
                    }				
				}
			}
		} else {// the contract has no location currencies 
            for(EF_Location_Currency__c lc: locationCurrencyList) {
				mapContract.get(lc.Contract__c).EF_Billing_Currency__c = lc.EF_Billing_Currency__c;
            }			
		}
        
        try{
            update mapContract.values();
        }catch(Exception e){
            System.debug('#### exception updating contracts ' + e);
        }		
	}
    
	public static void manageUpdateLocationCurrency () {
        
        List<EF_Location_Currency__c> locationCurrencyListNew = (List<EF_Location_Currency__c>) Trigger.new;
        Map<Id, EF_Location_Currency__c> locationCurrencyMapOld = (Map<Id, EF_Location_Currency__c>) Trigger.oldMap;
               
		Set <Id> contractIdSet = new Set <Id>();
		for(EF_Location_Currency__c lc: locationCurrencyListNew){
			contractIdSet.add(lc.Contract__c);
		}

		Map<Id, Contract> mapContract = new Map<Id, Contract> ([select Id, EF_Billing_Currency__c, (select Id, Location_ID__c, Location_ID__r.Name, EF_Billing_Currency__c from EF_Locations_Currencies__r) from Contract where Id in: contractIdSet order by id]);

		Map <Id, EF_Location_Currency__c> locationContractMap = new Map <Id, EF_Location_Currency__c>();
		for(Contract c: mapContract.values()){
			for(EF_Location_Currency__c lc: c.EF_Locations_Currencies__r){
				locationContractMap.put(lc.Location_ID__c, lc);
			}
		} 
        
		if(!locationContractMap.isEmpty()){            
			for(EF_Location_Currency__c lc: locationCurrencyListNew) {
                
                // Only add new currencies.
                if(!mapContract.get(lc.Contract__c).EF_Billing_Currency__c.contains(lc.EF_Billing_Currency__c)) {
                    String aux = mapContract.get(lc.Contract__c).EF_Billing_Currency__c.remove(locationCurrencyMapOld.get(lc.id).EF_Billing_Currency__c);                    
                    mapContract.get(lc.Contract__c).EF_Billing_Currency__c = aux + ';' + lc.EF_Billing_Currency__c;
                } else {
                    // The list can't have the same currency twice.
                    String aux = mapContract.get(lc.Contract__c).EF_Billing_Currency__c.remove(locationCurrencyMapOld.get(lc.id).EF_Billing_Currency__c);
                    mapContract.get(lc.Contract__c).EF_Billing_Currency__c = aux;
                }
			}
		}
        
        //Add the currencies that haven't been modified but were deleted by previous block.
                
        List<EF_Location_Currency__c> locationCurrencyList = [Select id, EF_Billing_Currency__c, Contract__c From EF_Location_Currency__c where Contract__c in :contractIdSet];
        
        for(EF_Location_Currency__c lc: locationCurrencyList) {
            if(!mapContract.get(lc.Contract__c).EF_Billing_Currency__c.contains(lc.EF_Billing_Currency__c) && !locationCurrencyMapOld.containsKey(lc.id)) {                
                mapContract.get(lc.Contract__c).EF_Billing_Currency__c = mapContract.get(lc.Contract__c).EF_Billing_Currency__c + ';' + lc.EF_Billing_Currency__c;
            }
        }               
        
        try{
            update mapContract.values();
        }catch(Exception e){
            System.debug('#### exception updating contracts ' + e);
        }		
	}       
    
    
    public static void manageDeleteLocationCurrency (List <EF_Location_Currency__c> deletedLocationCurrencyList){
        
        //get set for Contract
		Set <Id> contractIdSet = new Set <Id>();
        Set <Id> locationIdSet = new Set <Id>();
        Map <Id, String> contractWithCurrToBeRemoved = new Map <Id, String> ();
        
		for(EF_Location_Currency__c lc: deletedLocationCurrencyList){
            locationIdSet.add(lc.Location_ID__c);
			contractIdSet.add(lc.Contract__c);
            contractWithCurrToBeRemoved.put(lc.Contract__c, lc.EF_Billing_Currency__c);
		}
        
        

		//get contract, with the location currencies that are already set on the contract.
		Map<Id, Contract> mapContract = new Map<Id, Contract> ([select Id, EF_Billing_Currency__c, 
                                                                (select Id, Location_ID__c, Location_ID__r.Name, EF_Billing_Currency__c from EF_Locations_Currencies__r), 
                                                                (select Id, EF_Location_ID__c, EF_Location_ID__r.Name, Contract__c from EF_Relationships__r where EF_Location_ID__c in: locationIdSet) 
                                                              from Contract where Id in: contractIdSet]);
        Boolean weCanDelete = false;
        /*for(){
            
        }*/
        
        //if(weCanDelete){
        if(contractWithCurrToBeRemoved != null) {
			for(Contract c: mapContract.values()) {
				String billCurr = c.EF_Billing_Currency__c;

                String resultingBillCur = '';
               
                if(contractWithCurrToBeRemoved.containsKey(c.Id) && billCurr != null) {
					resultingBillCur = billCurr.remove(contractWithCurrToBeRemoved.get(c.Id));
                    c.EF_Billing_Currency__c = resultingBillCur;       
               }
			}
		}
            
        try{
            update mapContract.values();
        }catch(Exception e){
            System.debug('#### exception updating contracts ' + e);
        }         
    }

}