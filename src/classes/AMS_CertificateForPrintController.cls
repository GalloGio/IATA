public class AMS_CertificateForPrintController {

	public List<List<wrapaccount>> certificates{
		get{
			if(accountIds.isEmpty()) return null;
			else{
				List<List<wrapaccount>> allAccounts = new List<List<wrapaccount>>();
				List<wrapaccount> accounts = new List<wrapaccount>();
				for(Account acc : [SELECT Id, Name, TradeName__c, Sector__c, Legal_name__c, IATACode__c, CASS_Number__c, Check_Digit__c, Location_Class__c, Region_formula__c, BillingCity, IATA_ISO_Country__r.Name FROM Account WHERE Id IN :accountIds order by iata_iso_country__r.name, Name]){ 
					wrapaccount newAccount = new wrapaccount(acc, calcTextSize(acc.Name, acc.TradeName__c), calcTopPosition(acc.Name, acc.TradeName__c), calcBottomPosition(acc.Name, acc.TradeName__c), calcTradeNameSize(acc.Name, acc.TradeName__c), calcTopBigNameSmallTradeName(acc.Name, acc.TradeName__c), calcBottomBigNameSmallTradeName(acc.Name, acc.TradeName__c));
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

	public Decimal calcTextSize(String accountName, String tradeName){
		Integer tradeNameSize =  0;
		if(!String.isBlank(tradeName)){
			tradeNameSize =  tradeName.length();
		}
		Integer nameSize =  accountName.length();
		if(nameSize > 32 && nameSize < 65 && tradeNameSize < 59){
			return 2.0;
		}else if(nameSize > 64){
			return (64 * 2.9)/nameSize;	 
		}else if(nameSize < 65 && tradeNameSize > 58){
			return 2.5;	 
		}else{
			return 2.9;	 
		}
	}

	public Integer calcTopPosition(String accountName, String tradeName){
		Integer tradeNameSize =  0;
		if(!String.isBlank(tradeName)){
			tradeNameSize =  tradeName.length();
		}
		Integer nameSize =  accountName.length();
		if(nameSize > 64 || tradeNameSize > 58 || (nameSize > 32 && nameSize < 65 && tradeNameSize < 59)){
			return 103;
		}else if(nameSize > 32 && nameSize < 65){
			return 73;	 
		}else{
			return 103;	 
		}
	}

	public Integer calcBottomPosition(String accountName, String tradeName){
		Integer tradeNameSize =  0;
		if(!String.isBlank(tradeName)){
			tradeNameSize =  tradeName.length();
		}
		Integer nameSize =  accountName.length();

		if(nameSize > 64 || tradeNameSize > 58 || (nameSize > 32 && nameSize < 65 && tradeNameSize < 59)){
			return 50;
		}else if(nameSize > 32 && nameSize < 65){
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
		if(nameSize > 32 && nameSize < 65 && tradeNameSize < 59){
			return 25;
		}else if(nameSize > 64 || tradeNameSize > 58){
			return 20;	 
		}else{
			return 30;	 
		}
	}

	public Integer calcTopBigNameSmallTradeName(String accountName, String tradeName){
		Integer tradeNameSize =  0;
		if(!String.isBlank(tradeName)){
			tradeNameSize =  tradeName.length();
		}
		Integer nameSize =  accountName.length();

		if(nameSize > 32 && nameSize < 64 && tradeNameSize > 58){
			return 42; 
		}else{
			return 22;	 
		}
	}

	public Integer calcBottomBigNameSmallTradeName(String accountName, String tradeName){
		Integer tradeNameSize =  0;
		if(!String.isBlank(tradeName)){
			tradeNameSize =  tradeName.length();
		}
		Integer nameSize =  accountName.length();

		if(nameSize > 32 && nameSize < 64 && tradeNameSize > 58){
			return 20; 
		}else{
			return 40;	 
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
		
		public wrapaccount(account a, Decimal size, Integer topPosition, Integer bottomPosition, Integer tradeNameSize, Integer topBigNameSmallTradeNameAux, Integer bottomBigNameSmallTradeNameAux){
			accn=a;
			textSize = String.valueOf(size);
			topSizePosition = String.valueOf(topPosition);
			bottomtSizePosition = String.valueOf(bottomPosition);
			tradeNameTextSize = String.valueOf(tradeNameSize);
			topBigNameSmallTradeName = String.valueOf(topBigNameSmallTradeNameAux);
			bottomBigNameSmallTradeName = String.valueOf(bottomBigNameSmallTradeNameAux);
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
