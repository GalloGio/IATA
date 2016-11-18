public class AMS_CertificateForPrintController {

	public List<List<Account>> certificates{
		get{
			if(accountIds.isEmpty()) return null;
			else{
				List<List<Account>> allAccounts = new List<List<Account>>();
				List<Account> accounts = new List<Account>();
				for(Account acc : [SELECT Id, Name, TradeName__c, IATACode__c, Location_Class__c, BillingCity, IATA_ISO_Country__r.Name FROM Account WHERE Id IN :accountIds]){
					accounts.add(acc);
					
					if(accounts.size() == 1000){
						allAccounts.add(accounts.clone());
						accounts = new List<Account>();
					}
				}
				allAccounts.add(accounts.clone());
				return allAccounts;
			}
		}
	}
	public List<List<Account>> certificatesTesting{
		get{
			if(accountIds.isEmpty()) certificatesTesting = new List<List<Account>>();
			else{
				Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name, TradeName__c, IATACode__c, Location_Class__c, BillingCity, IATA_ISO_Country__r.Name FROM Account WHERE Id IN :accountIds]);
				List<List<Account>> allAccounts = new List<List<Account>>();
				List<Account> accounts = new List<Account>();
				for(Id accId : accountIds){
					Account acc = accountMap.get(accId);
					accounts.add(acc);
					
					if(accounts.size() == 1000){
						allAccounts.add(accounts.clone());
						accounts = new List<Account>();
					}
				}
				allAccounts.add(accounts.clone());
				certificatesTesting =  allAccounts;
			}
			return certificatesTesting;
		}
		set;
	}

	private List<Id> accountIds{
		get{
			if(accountIds == null){
				accountIds = new List<Id>();

				String accountList = ApexPages.currentPage().getParameters().get('AccountIds');
				if(accountList == null){
					String reqId = ApexPages.currentPage().getParameters().get('Id');
					system.debug(reqId);
					AMS_Certificate_Request__c req = [SELECT Id, AccountIds__c FROM AMS_Certificate_Request__c WHERE Id = :reqId];
					accountList = req.AccountIds__c;
				}				
				accountIds = (List<Id>)JSON.deserialize(accountList, List<Id>.class);
			}
			return accountIds;
		}
		set;
	}

	public AMS_CertificateForPrintController() {
		
	}
}