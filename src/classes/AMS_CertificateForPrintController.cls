public class AMS_CertificateForPrintController {

	public List<List<Account>> certificates{
		get{
			if(accountIds.isEmpty()) return null;
			else{
				List<List<Account>> allAccounts = new List<List<Account>>();
				List<Account> accounts = new List<Account>();
				for(Account acc : [SELECT Id, Name, TradeName__c, Legal_name__c, IATACode__c, CASS_Number__c, Check_Digit__c, Location_Class__c, Region_formula__c, BillingCity, IATA_ISO_Country__r.Name FROM Account WHERE Id IN :accountIds order by iata_iso_country__r.name, Name]){
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

	private List<Id> accountIds{
		get{
			if(accountIds == null){
				accountIds = new List<Id>();

				String accountList = ApexPages.currentPage().getParameters().get('AccountIds');
				if(accountList == null){
					String reqId = ApexPages.currentPage().getParameters().get('Id');
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