public with sharing class ANG_AgencyChangesHelper {
	
	public class AChangeStructure{

		public Map<Id,AMS_Agencies_relationhip__c> relationsMap;
		public Map<Id,Account> accountsMap;

		public AChangeStructure(){

			relationsMap = new Map<Id, AMS_Agencies_relationhip__c>();			
			accountsMap = new Map<Id, Account>();

		}

		public AChangeStructure(Map<Id,AMS_Agencies_relationhip__c> relationsMap,  Map<Id,Account> accountsMap){

			this.relationsMap = relationsMap;
			this.accountsMap = accountsMap;

		}

		public void addAccounts(Set<Account> accounts){

			For(Account acct: accounts){
				this.accountsMap.put(acct.Id, acct);
			}
		}

		public void addAccount(Account account){
				this.accountsMap.put(account.Id, account);
		}

		public void addRelations(Set<AMS_Agencies_relationhip__c> relations){
			
			For(AMS_Agencies_relationhip__c rel: relations){
				this.relationsMap.put(rel.Id, rel);
			}

		}

		public void addRelation(AMS_Agencies_relationhip__c relation){
			this.relationsMap.put(relation.Id, relation);
		}

	}

	public static AChangeStructure applyChangeOfLocationType(AMS_OSCAR__c oscarToProcess){

		// 1) need to fetch all the relations on the hierarchy
		// 2) need to fetch all the accounts involved in this "swap"
		// 3) need to change all the relations in the hierarchy to apply the new Parent
		// 4) need to change all the parent accounts and the location type of all agencies involved
		// 5) swap IEP information between old and new HE.

		AChangeStructure toReturn = new AChangeStructure();

		Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{oscarToProcess.Account__c});

		For(AMS_Agencies_relationhip__c rel : accountHierarchyRelationships.get(oscarToProcess.Account__c)){

			System.debug('[applyChangeOfLocationType] - Found these relations to change:' + accountHierarchyRelationships.get(oscarToProcess.Account__c));

			if(rel.Child_Account__c == oscarToProcess.Account__c){
				
				System.debug('[applyChangeOfLocationType] - The AE to be changed is the following:'+ rel.Child_Account__c);

				Account parentAccount = [Select Id, Location_Type__c, ParentId, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c From Account where Id =:rel.Parent_Account__c];

				parentAccount.Location_Type__c = AMS_Utils.AE;
				parentAccount.ParentId = oscarToProcess.Account__c;

				Account childAccount = new Account(Id = rel.Child_Account__c);

				childAccount.Location_Type__c = AMS_Utils.HE;
				childAccount.ParentId = null;
				childAccount.ANG_IEP_HE_AccntNum__c = null;
				childAccount.ANG_IEP_Status__c = 'No IEP Account';
				childAccount.ANG_HE_CashCondition__c = parentAccount.ANG_HE_CashCondition__c;
				childAccount.ANG_HE_RiskHistoryAssessment__c = parentAccount.ANG_HE_RiskHistoryAssessment__c;
				childAccount.ANG_HE_RiskStatus__c = parentAccount.ANG_HE_RiskStatus__c;

				parentAccount.ANG_IEP_HE_AccntNum__c = null;
				parentAccount.ANG_IEP_Status__c = null;
				parentAccount.ANG_HE_CashCondition__c = false;
				parentAccount.ANG_HE_RiskHistoryAssessment__c = null;
				parentAccount.ANG_HE_RiskStatus__c = null;

				rel.Child_Account__c = rel.Parent_Account__c;

				toReturn.addAccount(parentAccount);
				toReturn.addAccount(childAccount);

			} else{

				Account relAccount = new Account(Id = rel.Child_Account__c, ParentId = oscarToProcess.Account__c);
				toReturn.addAccount(relAccount);

			}

			rel.Parent_Account__c = oscarToProcess.Account__c;
			toReturn.addRelation(rel);

		}

		return toReturn;

	}

	public static AChangeStructure applyChangeOfHierarchy(AMS_OSCAR__c oscarToProcess){

		AChangeStructure toReturn = new AChangeStructure();

		Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{oscarToProcess.Account__c});

		// The diff between moving to an existing Hierarchy and a new will be determined by the New_parent__c field on the Oscar  

		boolean isNewHierarchy = verifyNewHierarchy(accountHierarchyRelationships.get(oscarToProcess.Account__c),oscarToProcess.New_parent__c);

		AMS_Agencies_Hierarchy__c newH = null;

		Set<Id> accountIdsInvolvedSet = fetchAccountIdsToBeProcessed(oscarToProcess.Id);

		Set<AMS_Agencies_relationhip__c> relationsToDelete = new Set<AMS_Agencies_relationhip__c>();

		if(isNewHierarchy){

			newH = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Newgen Hierarchy');
			insert newH;

			Account newHe = new Account(Id = oscarToProcess.New_parent__c);
			newHe.Location_Type__c = AMS_Utils.HE;
			newHe.ParentId = null;
			newHe.ANG_IEP_HE_AccntNum__c = null;
			newHe.ANG_IEP_Status__c = 'No IEP Account';
			newHe.ANG_HE_CashCondition__c = false;
			newHe.ANG_HE_RiskHistoryAssessment__c = null;
			newHe.ANG_HE_RiskStatus__c = 'Not Applicable';

			toReturn.addAccount(newHe);

			System.debug('[ANG_AgencyChangesHelper][applyChangeOfHierarchy]-Inserted new Hierarchy with Id:' + newH.Id);


		}else{

			Id hierarchyId = fetchHierarchyFromExternalAccount(oscarToProcess.New_parent__c);

			if(hierarchyId == null){

				newH = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Newgen Hierarchy');
				insert newH;

				System.debug('Inserted new Hierarchy with Id:' + newH.Id + ' since the destination account is a single Account.');
			}
			else{

				newH = new AMS_Agencies_Hierarchy__c(Id = hierarchyId);

			}

			// If we migrate the accounts into an existing hierarchy, the account which the oscar is open isn't catched on the Process Details. We need to push it back and change it as well.
			Account oscarAccount = new Account(Id = oscarToProcess.Account__c);
			oscarAccount.Location_Type__c = AMS_Utils.AE;
			oscarAccount.ParentId = oscarToProcess.New_parent__c;

			oscarAccount.ANG_IEP_HE_AccntNum__c = null;
			oscarAccount.ANG_IEP_Status__c = null;
			oscarAccount.ANG_HE_CashCondition__c = false;
			oscarAccount.ANG_HE_RiskHistoryAssessment__c = null;
			oscarAccount.ANG_HE_RiskStatus__c = null;

			toReturn.addAccount(oscarAccount);

		}

		// create new relations

		for(Id accountID: accountIdsInvolvedSet){

			AMS_Agencies_relationhip__c rel = new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true, Child_Account__c = accountID , Parent_Account__c = oscarToProcess.Account__c, Hierarchy__c = newH.Id);
			toReturn.addRelation(rel);

			Account a = new Account(id = accountID, ParentId = oscarToProcess.New_parent__c, Location_Type__c = AMS_Utils.AE);

			a.ANG_IEP_HE_AccntNum__c = null;
			a.ANG_IEP_Status__c = null;
			a.ANG_HE_CashCondition__c = false;
			a.ANG_HE_RiskHistoryAssessment__c = null;
			a.ANG_HE_RiskStatus__c = null;

			toReturn.addAccount(a);

		}

		if(!isNewHierarchy){

			AMS_Agencies_relationhip__c rel = new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true, Child_Account__c = oscarToProcess.Account__c , Parent_Account__c = oscarToProcess.New_parent__c, Hierarchy__c = newH.Id);
			toReturn.addRelation(rel);

		}


		// remove old relations from the hierarchy
		For(AMS_Agencies_relationhip__c rel : accountHierarchyRelationships.get(oscarToProcess.Account__c)){

			if(accountIdsInvolvedSet.contains(rel.Child_Account__c) || rel.Child_Account__c == oscarToProcess.Account__c){
				relationsToDelete.add(rel);
			}
		}

		delete new List<AMS_Agencies_relationhip__c>(relationsToDelete);

		return toReturn;
	}

	public static Boolean verifyNewHierarchy(List<AMS_Agencies_relationhip__c> rels, Id targetAccount){

		for(AMS_Agencies_relationhip__c rel: rels){
			if(rel.Child_Account__c == targetAccount || rel.Parent_Account__c == targetAccount)
				return true;
		}

		return false;

	}

	public static Set<Id> fetchAccountIdsToBeProcessed(Id oscarId){

		Set<Id> toReturn = new Set<Id>();

		For(AMS_Process_Detail__c pd : [Select Id, Account__c from AMS_Process_Detail__c where OSCAR__c = :oscarId]){
			toReturn.add(pd.Account__c);
		}

		return toReturn;

	}

	public static Id fetchHierarchyFromExternalAccount(Id accountId){

		List<AMS_Agencies_relationhip__c> rels = [Select Id, Hierarchy__c from AMS_Agencies_relationhip__c where Parent_Account__c = :accountId];
		
		if(rels.isEmpty())
			return null;
		else
			return rels.get(0).Hierarchy__c;
	}
/*
	public class AccountWrapper{

		public Account a;
		public Boolean isChanged;

		public AccountWrapper(Account a, Boolean isChanged){

			this.a = a;
			this.isChanged = isChanged;
		}
	}
	
	public class RelationWrapper{

		public AMS_Agencies_relationhip__c r;
		public Boolean isChanged;

		public RelationWrapper(AMS_Agencies_relationhip__c r, Boolean isChanged){

			this.r = r;
			this.isChanged = isChanged;
		}
	}
*/
}