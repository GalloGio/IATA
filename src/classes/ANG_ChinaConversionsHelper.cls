global class ANG_ChinaConversionsHelper {

	public static void convertAccountsHierarchy(AMS_Oscar__c oscar) {

		//system.debug('### convertAccountsHierarchy!!!');

		String accountId = oscar.account__c;
		String caseReason = oscar.ANG_Type_Of_Change__c;
		List<AMS_Agencies_relationhip__c> allRelations = getAllAccountRelations(accountId);
		Map<Id, Account> allAccounts = getAllHierarchyAccounts(accountId);

		//system.debug('### accountId: ' + accountId);
		//system.debug('### caseReason: ' + caseReason);
		//system.debug('### allRelations: ' + allRelations);
		//system.debug('### allAccounts: ' + allAccounts);

		for(Account acc : allAccounts.values()) {

            if(caseReason == AMS_Utils.CONVERTTONEWGENPILOT) {
        		if(acc.Location_Type__c == 'HO' || acc.Location_Type__c == 'AO') {
					acc.Location_Type__c = 'HE';
				}
				else {//if(acc.Location_Type__c == 'BR' || acc.Location_Type__c == 'SA') {
					acc.Location_Type__c = 'AE';
					acc.ParentId = acc.Top_Parent__c;	
				}
				/*else if(acc.Location_Type__c != 'HO' && acc.Location_Type__c != 'BR' && acc.Location_Type__c != 'SA' && acc.Status__c == AMS_Utils.ACC_S0_TERMINATED) {
					acc.Location_Type__c = 'AE';
					acc.ParentId = acc.Top_Parent__c;
				}*/
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
				//deleteRiskEvents(accountId);
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
				deleteRiskEvents(accountId);
			}
			else {
				oscar.addError('Type of change unknown: ' + caseReason);
            }
		}

		update allAccounts.values();

		updateAccountRelations(allRelations, caseReason);
    }

    public static void deleteAccountsFoPs(Set<Id> accntIds) {
    	Id formOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');

		List<Agency_Authorization__c> accountsWithFoPs = [SELECT Id 
														  FROM Agency_Authorization__c 
														  WHERE Account__c IN :accntIds AND RecordTypeId = :formOfPaymentRT];
        delete accountsWithFoPs;
    }

    public static void deleteAccountsFoPs(String accountId) {
    	Map<Id, Account> allAccounts = getAllHierarchyAccounts(accountId);
    	Id formOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');

		List<Agency_Authorization__c> accountsWithFoPs = [SELECT Id 
														  FROM Agency_Authorization__c 
														  WHERE Account__c IN :allAccounts.keyset() AND RecordTypeId = :formOfPaymentRT];

        delete accountsWithFoPs;
    }

    public static void deleteRiskEvents(String accountId) {
    	Map<Id, Account> allAccounts = getAllHierarchyAccounts(accountId);
		List<ANG_Agency_Risk_Event__c> riskEvents = [SELECT Id 
													 FROM ANG_Agency_Risk_Event__c 
													 WHERE ANG_AccountId__c IN :allAccounts.keyset()];

        delete riskEvents;
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
				 where Child_Account__c = :accountId or Child_Account__r.Top_Parent__c = :accountId or Parent_Account__c = :accountId];

		return allRelations;
    }

    public static Map<Id, Account> getAllHierarchyAccounts(Id accountId) {
		return new Map<Id, Account>([SELECT Id, Name, Location_Class__c, Location_Type__c, ANG_Accreditation_Model__c, Status__c, ParentId, Top_Parent__c,
											ANG_IsNewGenAgency__c, ANG_RiskStatus__c, ANG_RiskHistoryAssessment__c
									 FROM Account
									 WHERE Id = :accountId OR ParentId = :accountId OR Top_Parent__c = :accountId]);
    }

    public static List<Account> getAllAccountsFromRelationships(Id accountId) {
		List<AMS_Agencies_relationhip__c> allRelations = getAllAccountRelations(accountId);

		Set<Id> accountIdsSet = new Set<Id>();

		for(AMS_Agencies_relationhip__c rel : allRelations) {
			accountIdsSet.add(rel.Parent_Account__c);
			accountIdsSet.add(rel.Child_Account__r.Top_Parent__c);
			accountIdsSet.add(rel.Child_Account__c);
		}

		List<Account> accountsList = [SELECT Id, Name, Location_Class__c, Location_Type__c, ANG_Accreditation_Model__c, Status__c, ParentId, Top_Parent__c,
											ANG_IsNewGenAgency__c, ANG_RiskStatus__c, ANG_RiskHistoryAssessment__c
									  FROM Account
									  WHERE Id in :accountIdsSet];

		return accountsList;
    }

}