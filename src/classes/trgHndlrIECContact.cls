/**  
  * Description: Trigger Handler for the Contact object of the IEC project
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
  */
public with sharing class trgHndlrIECContact {

	/**
	 * Business rule logic after a Contact has been updated
	 */
	public static void OnAfterUpdate(List<Contact> newRecords, Map<Id, Contact> newRecordsMap, List<Contact> oldRecords, Map<Id, Contact> oldRecordsMap) {

		Set<Id> toAccountSync = new Set<Id>();
		Set<Id> toContactSync = new Set<Id>();

		
		// Build list of IECAddress__c id to sync
		for (Contact oContact : newRecords) {

			Contact oldContact = oldRecordsMap.get(oContact.Id);
			
			// Make sure that only specific field have been changed to trigger the Billing Account Sync
			if (oContact.Tax_1_ID__c != oldContact.Tax_1_ID__c
				|| oContact.Tax_2_ID__c != oldContact.Tax_2_ID__c
				|| oContact.VAT_Country_Code__c != oldContact.VAT_Country_Code__c) {
				toAccountSync.add(oContact.Id);
			}

			// Make sure that only specific field have been changed to trigger the Contact Sync
			if (oContact.FirstName != oldContact.FirstName
				|| oContact.LastName != oldContact.LastName
				|| oContact.Phone != oldContact.Phone) {
				toContactSync.add(oContact.Id);
			}
		}
		if(toContactSync.isEmpty() && toAccountSync.isEmpty()) return;

		Map<Id, Zuora__CustomerAccount__c> mapContactIdToBillingAccount = IECZuoraHelper.getBillingAccountByContactId(newRecordsMap.keySet());
		if(mapContactIdToBillingAccount == null || mapContactIdToBillingAccount.isEmpty()) return;

		
		// Variables to Sync Billing Account
		List<String> lstBillingAccountZId = new List<String>();
		List<String> lstTax1ID = new List<String>();
		List<String> lstTax2ID = new List<String>();
		
		// Variables to Sync Billing/Shipping Contact
		List<String> lstContactZId = new List<String>();
		List<String> lstFirstName = new List<String>();
		List<String> lstLastName = new List<String>();
		List<String> lstEmail = new List<String>();
		List<String> lstPhone = new List<String>();


		for (Contact oContact : newRecords){

			// check if the Contact object is linked to a Billing Account (cannot sync if contact does not exists in Zuora)
			Zuora__CustomerAccount__c oBillingAccount = mapContactIdToBillingAccount.get(oContact.Id);
			if(oBillingAccount == null) continue;

			if(toAccountSync.contains(oContact.Id)){
				lstBillingAccountZId.add(oBillingAccount.Zuora__Zuora_Id__c);
				lstTax1ID.add((String.isBlank(oContact.VAT_Country_Code__c) ? '' : oContact.VAT_Country_Code__c) + oContact.Tax_1_ID__c);
				lstTax2ID.add(oContact.Tax_2_ID__c);
			}

			if(toContactSync.contains(oContact.Id)){
				// Repeat everything twice for both Bill/Sold to Contacts
				lstContactZId.add(oBillingAccount.Zuora__BillToId__c);
				lstContactZId.add(oBillingAccount.Zuora__SoldToId__c);
				lstFirstName.add(oContact.FirstName);
				lstFirstName.add(oContact.FirstName);
				lstLastName.add(oContact.LastName);
				lstLastName.add(oContact.LastName);
				lstEmail.add(oContact.Email);
				lstEmail.add(oContact.Email);
				lstPhone.add(oContact.Phone);
				lstPhone.add(oContact.Phone);
			}
		
		}		
		
		// sync (future method)
		if (!lstBillingAccountZId.isEmpty())
			IECZuoraHelper.SyncBillingAccountWithContactDetails(lstBillingAccountZId, lstTax1ID, lstTax2ID);
		
		// sync (future method)
		if (!lstContactZId.isEmpty())
			IECZuoraHelper.SyncZuoraContact(lstContactZId, lstFirstName, lstLastName, lstEmail, lstPhone);
			
	}
}