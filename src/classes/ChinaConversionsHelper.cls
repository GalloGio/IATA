global with sharing class ChinaConversionsHelper {

	public static void convertAccountsHierarchy(AMS_Oscar__c oscar) {

		String accountId = oscar.account__c;
		String caseReason = oscar.ANG_Type_Of_Change__c;
		List<AMS_Agencies_relationhip__c> allRelations = getAllAccountRelations(accountId);
		Map<Id, Account> allAccounts = getAllHierarchyAccounts(allRelations);

		for(Account acc : allAccounts.values()) {

            if(caseReason == AMS_Utils.CONVERTTONEWGENPILOT) {
        		if(acc.Location_Type__c == 'HO') {
					acc.Location_Type__c = 'HE';
				}
				else if(acc.Location_Type__c == 'BR' || acc.Location_Type__c == 'SA') {
					acc.Location_Type__c = 'AE';
					acc.ParentId = acc.Top_Parent__c;	
				}
				else if(acc.Location_Type__c != 'HO' && acc.Location_Type__c != 'BR' && acc.Location_Type__c != 'SA' && acc.Status__c == AMS_Utils.ACC_S0_TERMINATED) {
					acc.Location_Type__c = 'AE';
					acc.ParentId = acc.Top_Parent__c;
				}
				acc.ANG_Accreditation_Model__c = 'Cashless';
			}
			else if(caseReason == AMS_Utils.CONVERTTOLEGACY) {
				if(acc.Location_Type__c == 'HE') {
					acc.Location_Type__c = 'HO';
				}
				else {
					acc.Location_Type__c = 'BR';
				}
				acc.ANG_Accreditation_Model__c = '';
			}
			else if(caseReason == AMS_Utils.CONVERTTOINTERNATIONAL) {
				if(acc.Location_Type__c == 'HE') {
					acc.Location_Type__c = 'HO';
				}
				else {
					acc.Location_Type__c = 'BR';
				}
				acc.ANG_Accreditation_Model__c = '';

				deleteAccountsFoPs(allAccounts.keyset());
			}
			else {
				oscar.addError('Type of change unknown: ' + caseReason);
            }
		}

		update allAccounts.values();

		updateAccountRelations(allRelations, caseReason);
    }

    public static void deleteAccountsFoPs(Set<Id> accntIds) {
    	Id formOfPaymentRT = AMS_Utils.getId('Agency_Authorization__c','FormOfPayment');
		List<Agency_Authorization__c> accountsWithFoPs = [SELECT Id 
														  FROM Agency_Authorization__c 
														  WHERE Account__c IN :accntIds AND RecordTypeId = :formOfPaymentRT];
        delete accountsWithFoPs;
    }

    public static void deleteAccountsFoPs(String accountId) {

    	List<AMS_Agencies_relationhip__c> allRelations = getAllAccountRelations(accountId);

		Map<Id, Account> allAccounts = getAllHierarchyAccounts(allRelations);

    	Id formOfPaymentRT = AMS_Utils.getId('Agency_Authorization__c','FormOfPayment');

		List<Agency_Authorization__c> accountsWithFoPs = [SELECT Id 
														  FROM Agency_Authorization__c 
														  WHERE Account__c IN :allAccounts.keyset() AND RecordTypeId = :formOfPaymentRT];
        
        delete accountsWithFoPs;
    }

    public static void updateAccountRelations(List<AMS_Agencies_relationhip__c> accntRelations, String caseReason) {
    	
		for(AMS_Agencies_relationhip__c r : accntRelations) {
			if(caseReason == AMS_Utils.CONVERTTONEWGENPILOT) {
				r.Is_Newgen_Relation__c = true;
			}
			else {
				r.Is_Newgen_Relation__c = false;
			}

			//convert relations in the 3rd level (ex: SA) to 2nd level of the hierarchy (ex: AE)
			if(r.Child_Account__r.ParentId != r.Child_Account__r.Top_Parent__c) {			
				r.Parent_Account__c = r.Child_Account__r.Top_Parent__c;
			}
		}

		update accntRelations;
    }

    public static List<AMS_Agencies_relationhip__c> getAllAccountRelations(Id accountId) {
    	List<AMS_Agencies_relationhip__c> allRelations = 
				[SELECT Id, Child_Account__c, Child_Account__r.Name, Child_Account__r.Top_Parent__c, Child_Account__r.ParentId, Parent_Account__c, Child_Account__r.Top_Parent__r.Location_Type__c, Is_Newgen_Relation__c
				 from AMS_Agencies_relationhip__c 
				 where Child_Account__c = :accountId or Child_Account__r.Top_Parent__c = :accountId or Child_Account__r.ParentId = :accountId];

		return allRelations;
    }

    public static Map<Id, Account> getAllHierarchyAccounts(List<AMS_Agencies_relationhip__c> accntRelations) {
    	Set<Id> hierarchyAccounts = new Set<Id>();

		for(AMS_Agencies_relationhip__c r : accntRelations) {
			if(!hierarchyAccounts.contains(r.Parent_Account__c)) {
				hierarchyAccounts.add(r.Parent_Account__c);	
			}
			if(!hierarchyAccounts.contains(r.Child_Account__c)) {
				hierarchyAccounts.add(r.Child_Account__c);	
			}
			if(!hierarchyAccounts.contains(r.Child_Account__r.Top_Parent__c)) {
				hierarchyAccounts.add(r.Child_Account__r.Top_Parent__c);	
			}
		}

		return new Map<Id, Account>([SELECT Id, Name, Location_Type__c, ANG_Accreditation_Model__c, Status__c, ParentId, Top_Parent__c
									 FROM Account
									 WHERE Id in :hierarchyAccounts]);
    }

}