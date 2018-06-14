public with sharing class IDCardAppHandler {
	public static void  updateDelivery(list<ID_Card_Application__c> listIDCardApp, List<String> iataCodesDefRT ) {
		Map<String, Account> accountPerIATACode = new Map<String, Account>();
		for (Account a : [select Id, IATACode__c, ID_Card_KeyAccount_features__c , IDCard_Key_Account__c, BillingCountry, Region_formula__c from Account where IATACode__c in :iataCodesDefRT]) {
			accountPerIATACode.put(a.IATACode__c, a);
		}

		List<ID_Card_Application__c> listIdca = new List<ID_Card_Application__c>();
		for (ID_Card_Application__c app : listIDCardApp) {
			Account acc = accountPerIATACode.get(app.IATA_Code__c);
			if(app.Application_Status__c.tolowerCase().equals('paid') && acc.Region_formula__c=='Africa & Middle East' && app.IDCard_Expedite_Delivery__c!=true){
				ID_Card_Application__c idca =new ID_Card_Application__c (id = app.id, IDCard_Expedite_Delivery__c = true);
				listIdca.add(idca);
			}
		}
		if(!listIdca.isEmpty()){
			upsert listIdca;
		}
	}	
}