public class AMS_CertificateForPrintController {

	public List<List<wrapaccount>> certificates{
		get{
			if(accountIds.isEmpty()) return null;
			else{
				List<List<wrapaccount>> allAccounts = new List<List<wrapaccount>>();
				List<wrapaccount> accounts = new List<wrapaccount>();
				for(Account acc : [SELECT Id, Name, TradeName__c, Sector__c, Legal_name__c, IATACode__c, CASS_Number__c, Check_Digit__c, Location_Class__c, Region_formula__c, BillingCity, IATA_ISO_Country__r.Name FROM Account WHERE Id IN :accountIds order by iata_iso_country__r.name, Name]){ 
					wrapaccount newAccount = new wrapaccount(acc);
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

	public class wrapaccount{
		public account accn{get;set;}
		public String textSize{get;set;}
		public String topSizePosition{get;set;}
		public String bottomtSizePosition{get;set;}
		public String tradeNameTextSize{get;set;}
		public String bottomBigNameSmallTradeName{get;set;}
		public String topBigNameSmallTradeName{get;set;}
		
		public wrapaccount(account a){
			accn=a;
			Integer tradeNameSize =  0;
			if(!String.isBlank(a.TradeName__c)){
				tradeNameSize =  a.TradeName__c.length();
			}
			Integer nameSize =  a.Name.length();

			if(nameSize > 32 && nameSize < 65 && tradeNameSize < 59){
				textSize = String.valueOf(2.0);
			}else if(nameSize > 64){
				textSize = String.valueOf((64 * 2.9)/nameSize);	 
			}else{
				textSize = String.valueOf(2.9);	 
			}

			if(nameSize > 64 || tradeNameSize > 58 || (nameSize > 32 && nameSize < 65 && tradeNameSize < 59)){
				topSizePosition = String.valueOf(103);
				bottomtSizePosition = String.valueOf(50);
			}else if(nameSize > 32 && nameSize < 65){
				topSizePosition = String.valueOf(73); 
				bottomtSizePosition = String.valueOf(80);
			}else{
				topSizePosition = String.valueOf(103);
				bottomtSizePosition = String.valueOf(50);	 
			}

			if(nameSize > 32 && nameSize < 65 && tradeNameSize < 59){
				tradeNameTextSize = String.valueOf(25);
			}else if(nameSize > 64 || tradeNameSize > 58){
				tradeNameTextSize = String.valueOf(20);	 
			}else{
				tradeNameTextSize = String.valueOf(30); 
			}

			if(nameSize > 32 && nameSize < 64 && tradeNameSize > 58){
				topBigNameSmallTradeName = String.valueOf(52); 
				bottomBigNameSmallTradeName = String.valueOf(10);
			}else{
				topBigNameSmallTradeName = String.valueOf(22); 
				bottomBigNameSmallTradeName = String.valueOf(40);
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
