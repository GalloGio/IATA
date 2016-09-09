public class EF_AccountTriggerHandler {

	public static boolean run = true; 
	private static List  <Account> childAccsList = new List <Account> ();

	public static void handleAfterUpdate(List<Account> accs, Map<Id,Account> oldMap) {

		Set<Id> inactiveAccsSet = new Set<Id> ();
		
		for(Account a: accs){
			if(a.EF_Status__c=='Inactive' && oldMap.get(a.Id).EF_Status__c=='Active'){
				inactiveAccsSet.add(a.Id);
			}
		}

		//check if account has child accounts 
		Map <Id, Account> childAccsMap = new Map <Id, Account> ([Select Id, EF_Status__c, ParentId from Account where ParentId in: inactiveAccsSet]);
		
		if(!childAccsMap.isEmpty() && run){
			for(Account a: childAccsMap.values()){
				a.EF_Status__c='Inactive';				
				inactiveAccsSet.add(a.Id);
                childAccsList.add(a); //we'll update at the end, when all the other records have been updated.
                             
			}
			
			inactiveEFContracts(inactiveAccsSet);

		}else if(!inactiveAccsSet.isEmpty() && run){
            inactiveEFContracts(inactiveAccsSet);
            
		}		
	}

	public static void inactiveEFContracts(Set<Id> inactiveAccsSet){

		Id contractRTId = AMS_Utils.getId('Contract', 'EF_Client_Agreement');

		//query for Contracts, Billing Agreements and Related Contacts on the accounts inactivated.
		Map <Id,Contract> contractMap = new Map <Id,Contract> ([Select Id, EF_Status__c, 
			(Select Id, Status__c from EF_Relationships__r) from Contract where AccountId in: inactiveAccsSet and RecordTypeId =: contractRTId]);

		List <Contract> contracts2Inactivate = new List <Contract> ();
		Set <Id> BA2Inactivate = new Set <Id> ();

			for(Contract c: contractMap.values()){
				if(c.EF_Status__c != 'Inactive'){
					c.EF_Status__c = 'Inactive';
					contracts2Inactivate.add(c);
				}

				for(EF_Billing_Agreement__c ba: c.EF_Relationships__r){
					if(ba.Status__c!='Inactive'){
						BA2Inactivate.add(ba.Id);
					}
				}
			}

		if(!contracts2Inactivate.isEmpty()){
			try{ update contracts2Inactivate; 
				if(!BA2Inactivate.isEmpty() && run){ 
                    inactiveEFBillingAgreement(BA2Inactivate); 
                }
                else if (childAccsList.size()>0 && run){
                    run=false; 
                    inactiveChildAccounts(childAccsList);
                }
			}catch(Exception e){System.debug('## Error inactivating EF Contracts ' +e);}
		}
	}

	public static void inactiveEFBillingAgreement(Set <Id> BASet){

		List <EF_Contact_Relationship__c> BAContacs2InactList = new List <EF_Contact_Relationship__c> ();

		Map <Id, EF_Billing_Agreement__c> baMap = new Map <Id, EF_Billing_Agreement__c> ([select Id, Status__c, 
			(Select Id, Status__c from EF_Contact_Relationships__r) from EF_Billing_Agreement__c where Id in: BASet]);

		for(EF_Billing_Agreement__c ba: baMap.values()){
			ba.Status__c='Inactive';
			
			for(EF_Contact_Relationship__c bac: ba.EF_Contact_Relationships__r){
				if(bac.Status__c!='Inactive'){
					BAContacs2InactList.add(bac);
				}
				
			}
		}

		try{ update baMap.values(); 
                if(!BAContacs2InactList.isEmpty() && run){
                    inactiveEF_BAContacts(BAContacs2InactList);
                }else if(childAccsList.size()>0 && run){
                    run=false;
                    inactiveChildAccounts(childAccsList);
                }
			}catch(Exception e){System.debug('## [EF_AccountTriggerHandler.inactiveEFBillingAgreement ] Error ' +e );}	

	}

	public static void inactiveEF_BAContacts(List <EF_Contact_Relationship__c> bacList){

		for(EF_Contact_Relationship__c bac: bacList){
			bac.Status__c = 'Inactive';
		}

		try{ 	
            update bacList;
            if(childAccsList.size()>0 && run){
                inactiveChildAccounts(childAccsList);
            }			
		}catch(Exception e){System.debug('## [EF_AccountTriggerHandler.inactiveEF_BAContacts ] Error ' +e );}	

	}

	public static void inactiveChildAccounts (List <Account> accs){

		try{
			update accs;
            run=false;
		}catch(Exception e){System.debug('### [EF_AccountTriggerHandler.inactiveChildAccounts] Error inactivating child accounts ' + e);}

	}	
	
}