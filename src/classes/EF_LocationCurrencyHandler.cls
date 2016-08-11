public class EF_LocationCurrencyHandler {

	public static void manageNewLocationCurrency (List<EF_Location_Currency__c> locationCurrencyList, String action) {
		//First avoid adding the same location in two location currencies
		
		//get set for Contract
		Set <Id> contractIdSet = new Set <Id>();
		for(EF_Location_Currency__c lc: locationCurrencyList){
			contractIdSet.add(lc.Contract__c);
		}

		//get contract, with the location currencies that are already set on the contract.
		Map<Id, Contract> mapContract = new Map<Id, Contract> ([select Id, EF_Billing_Currency__c, (select Id, Location_ID__c, Location_ID__r.Name, EF_Billing_Currency__c from EF_Locations_Currencies__r) from Contract where Id in: contractIdSet]);

		//Set to hold the location names already added to the contract
		Map <Id, EF_Location_Currency__c> locationContractMap = new Map <Id, EF_Location_Currency__c>();
		for(Contract c: mapContract.values()){
			for(EF_Location_Currency__c lc: c.EF_Locations_Currencies__r){
				locationContractMap.put(lc.Location_ID__c, lc);
			}
 
		}

		
		//the contract contains already some location currencies added
		if(!locationContractMap.isEmpty()){
			//check if the location we try to add has already been set 
			for(EF_Location_Currency__c lc: locationCurrencyList){
				if(locationContractMap.containsKey(lc.Location_ID__c) ){
                    if(action=='insert'){
                        lc.Location_ID__c.addError('The location chosen has already been added to the contract.');
                    }
					

				}else{
                    System.debug('#### lc.EF_Billing_Currency__c ' + lc.EF_Billing_Currency__c);
                    System.debug('#### mapContract.get(lc.Contract__c).EF_Billing_Currency__c ' + mapContract.get(lc.Contract__c).EF_Billing_Currency__c);
                    if(!mapContract.get(lc.Contract__c).EF_Billing_Currency__c.contains(lc.EF_Billing_Currency__c)){
                        mapContract.get(lc.Contract__c).EF_Billing_Currency__c = mapContract.get(lc.Contract__c).EF_Billing_Currency__c + ';' + lc.EF_Billing_Currency__c;
                    }
				
				}
			}
		}else{// the contract has no location currencies 
            for(EF_Location_Currency__c lc: locationCurrencyList){
                
				mapContract.get(lc.Contract__c).EF_Billing_Currency__c = lc.EF_Billing_Currency__c;
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
           for(Contract c: mapContract.values()){
            String billCurr = c.EF_Billing_Currency__c;
            System.debug(billCurr);
            String resultingBillCur;
            if(billCurr.contains(';')){
                resultingBillCur = billCurr.remove(contractWithCurrToBeRemoved.get(c.Id)+';');
                }else{
                    resultingBillCur = billCurr.remove(contractWithCurrToBeRemoved.get(c.Id));
                }
           
                System.debug(resultingBillCur);            
                c.EF_Billing_Currency__c = resultingBillCur; 
            
            }
            
            try{
                update mapContract.values();
            }catch(Exception e){
                System.debug('#### exception updating contracts ' + e);
            } 
        //}
        
        
    }

}