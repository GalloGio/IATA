public class AMS_CertificateForPrintController {

	/*public List<List<Account>> certificates{
		get{
			if(accountIds.isEmpty()) return null;
			else{
				List<List<Account>> allAccounts = new List<List<Account>>();
				List<Account> accounts = new List<Account>();
				for(Account acc : [SELECT Id, Name, TradeName__c, Sector__c, Legal_name__c, IATACode__c, CASS_Number__c, Check_Digit__c, Location_Class__c, Region_formula__c, BillingCity, IATA_ISO_Country__r.Name FROM Account WHERE Id IN :accountIds order by iata_iso_country__r.name, Name]){
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
	}*/

	public List<List<wrapaccount>> certificates{
		get{
			if(accountIds.isEmpty()) return null;
			else{
				List<List<wrapaccount>> allAccounts = new List<List<wrapaccount>>();
				List<wrapaccount> accounts = new List<wrapaccount>();
				for(Account acc : [SELECT Id, Name, TradeName__c, Sector__c, Legal_name__c, IATACode__c, CASS_Number__c, Check_Digit__c, Location_Class__c, Region_formula__c, BillingCity, IATA_ISO_Country__r.Name FROM Account WHERE Id IN :accountIds order by iata_iso_country__r.name, Name]){ 
					wrapaccount newAccount = new wrapaccount(acc, calcTextSize(acc.Name), calcTopPosition(acc.Name), calcBottomPosition(acc.Name), calcTradeNameSize(acc.Name, acc.TradeName__c));
					accounts.add(newAccount);

					if(accounts.size() == 1000){
						allAccounts.add(accounts.clone());
						accounts = new List<wrapaccount>();
					}
				}
				allAccounts.add(accounts.clone());
				return allAccounts;
			}
		}
	}

	public Decimal calcTextSize(String accountName){
		Integer nameSize =  accountName.length();
		if(nameSize > 64){
			return (64 * 2.9)/nameSize;	 
		}else{
			return 2.9;	 
		}
	}

	public Integer calcTopPosition(String accountName){
		Integer nameSize =  accountName.length();
		if(nameSize > 32 && nameSize < 65){
			return 73;	 
		}else{
			return 103;	 
		}
	}

	public Integer calcBottomPosition(String accountName){
		Integer nameSize =  accountName.length();
		if(nameSize > 32 && nameSize < 65){
			return 80;	 
		}else{
			return 50;	 
		}
	}
	public Integer calcTradeNameSize(String accountName, String tradeName){
		Integer tradeNameSize =  0;
		if(!String.isBlank(tradeName)){
			tradeNameSize =  tradeName.length();
		}
		Integer nameSize =  accountName.length();
		if(nameSize > 64 || tradeNameSize > 58){
			return 20;	 
		}else{
			return 30;	 
		}
	}

	public class wrapaccount{
		public account accn{get;set;}
		public String textSize{get;set;}
		public String topSizePosition{get;set;}
		public String bottomtSizePosition{get;set;}
		public String tradeNameTextSize{get;set;}
		
		public wrapaccount(account a, Decimal size, Integer topPosition, Integer bottomPosition, Integer tradeNameSize){
			accn=a;
			textSize = String.valueOf(size);
			topSizePosition = String.valueOf(topPosition);
			bottomtSizePosition = String.valueOf(bottomPosition);
			tradeNameTextSize = String.valueOf(tradeNameSize);
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
