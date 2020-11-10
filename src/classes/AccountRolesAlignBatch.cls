public class AccountRolesAlignBatch implements Queueable {

	private Map<Id,sObject> contactMap;

	public AccountRolesAlignBatch(Map<Id,sObject> contactMap) {
		this.contactMap = contactMap;
	}

	public void execute(QueueableContext context) {

		switchAccountRoles(contactMap);

		System.debug('____ [AccountRolesAlignBatch - execute] switch Account Roles');
	}

	@InvocableMethod(label='switchAccountRoles')
	public static void switchAccountRoles(List<Contact> contactList){
		Map<Id,sObject> contactMap = new Map<Id,sObject>();
		for(Contact c : contactList){
			contactMap.put(c.Id, c);
		}
		AccountRolesAlignBatch.switchAccountRoles(contactMap);
	}

	public static void switchAccountRoles(Map<Id,sObject> contactMap){
		Savepoint sp = Database.setSavepoint();
		try{
			Set<Id> contactIds = contactMap.keySet();
			Set<Id> acrContactIds = contactMap.keySet();
			Set<String> accountIds = new Set<String>();
			Set<String> existingAccRolesIds = new Set<String>();

			String RECTYPE_Master_AccRole = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Master');


			Map<Id,Account_Role__c> mapAR = new Map<Id,Account_Role__c>();
			Map<Id,Account_Contact_Role__c> mapContactVsACR = new Map<Id,Account_Contact_Role__c>();
			Map<Id,Account_Role__c> mapContactVsAR = new Map<Id,Account_Role__c>();
			List<Account_Role__c> arToInsert = new List<Account_Role__c>();


			//get Account Contact Roles to be updated associated with the contacts
			List<Account_Contact_Role__c> listACR = [SELECT Id,Account_Role__c,Contact__c
												FROM Account_Contact_Role__c
												WHERE Contact__c in :contactIds
												AND Contact_Role_Name__c = 'Trainee'
												AND Functional_Role__c =  'Training' FOR UPDATE];

			//Get AccountIds from Contacts
			for(Id contactId : contactIds){
				Contact cont = (Contact)contactMap.get(contactId);
				accountIds.add(cont.AccountId);
			}

			//Check already existing Account Roles
			List<Account_Role__c> listExistingAR = [SELECT Id,Account__c,RecordTypeId,Account_Role_Name__c,Functional_Role__c
												FROM Account_Role__c
												WHERE Account__c in :accountIds
												AND Account_Role_Name__c = 'Training'
												AND Functional_Role__c =  'Training'];

			//create map with the account id as key
			for(Account_Role__c ar : listExistingAR){
				mapAR.put(ar.Account__c, ar);
			}

			//Set the existing AR associated with the correct contact
			//if not existing create the new AR
			for(Id contactId : contactIds){
				Contact cont = (Contact)contactMap.get(contactId);
				if(mapAR.containsKey(cont.AccountId)){
					mapContactVsAR.put(contactId, mapAR.get(cont.AccountId));
				}else{
					Account_Role__c ar = new Account_Role__c();
					ar.Account__c = cont.AccountId;
					ar.RecordTypeId = RECTYPE_Master_AccRole;
					ar.Account_Role_Name__c =  'Training';
					ar.Functional_Role__c =  'Training';
					arToInsert.add(ar);
				}
			}

			//create new AR to associate with the existing ACR
			insert arToInsert;

			//add to existing map with the account id as key
			for(Account_Role__c ar : arToInsert){
				mapAR.put(ar.Account__c, ar);
			}

			//Set the inserted AR associated with the correct contact
			for(Id contactId : contactIds){
				Contact cont = (Contact)contactMap.get(contactId);
				if(mapAR.containsKey(cont.AccountId) && !mapContactVsAR.containsKey(contactId)  ){
					mapContactVsAR.put(contactId, mapAR.get(cont.AccountId));
				}
			}

			//set the new AR ids to the existing ACR
			for(Account_Contact_Role__c acr : listACR){
				//Set the new AR Id
				acr.Account_Role__c = mapContactVsAR.get(acr.Contact__c).Id;
			}

			//Update the ACR with the new AR
			update listACR;

		}catch(exception e){
			Database.rollback(sp);
			TransformationHelper.sendEmailSupport( 'AccountRolesAlignBatch Exception', 'Exception: ' + e + ' || StackTrace: ' + e.getStackTraceString());
		}

	}
}