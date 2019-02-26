public class ISSP_FinancialSecInformationController {	
	public String communityName{get;set;}
	public List<FinSecWrapper> listFinSec {get;set;}
	public Decimal totalSecuredAmount {get;set;}
	public Decimal totalConvertedAmount {get;set;}
	public String localCurrency {get;set;}
	public String currencyCode {get;set;}
	public Boolean hasAccessToFS {get;set;}
	public Boolean showConvertedAmount {get;set;}

	public ISSP_FinancialSecInformationController() {
		this.communityName = ApexPages.currentPage().getParameters().get('CommunityName');
		User u = [SELECT Contact.Financial_Assessment_Contact__c, Contact.User_Portal_Status__c FROM User WHERE Id = :UserInfo.getUserId()];
		this.hasAccessToFS = u.Contact.Financial_Assessment_Contact__c || u.Contact.User_Portal_Status__c == 'Approved Admin';
		this.listFinSec = new List<FinSecWrapper>();
		loadRecords();
	}

	public PageReference redirect() {
		return this.hasAccessToFS ? null : new PageReference('/ISSP_Homepage?mid=M0S1');
	}

	private void loadRecords() {
		Set<String> typesToExclude = new Set<String> {'Manifestacion de Bienes', 'Others'};
		Set<String> statusToInclude = new Set<String> {'Active', 'Close to Expiry Date', 'Expired', 'Encashment in progress'}; /* WMO-412 */
		Date minRangeDate = Date.today().addDays(-7);
		Id accountId = [SELECT Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()].Contact.AccountId;

		List<Financial_Security__c> records = [SELECT Id, Financial_Institution__c, Financial_Institution__r.Name, Security_Type__c, 
													Security_Status__c, Amount__c, Validity_Start_Date__c, Expiry_Date__c, CurrencyIsoCode,
													convertCurrency(Amount__c) convertedAmount
									   		   FROM Financial_Security__c 
						   			   		   WHERE Security_Type__c NOT IN :typesToExclude 
						   			   		   		AND Security_Status__c IN :statusToInclude
						   			   		   		AND (Expiry_Date__c > :minRangeDate OR Unlimited_Security__c = true) 
                                                   	AND Account__c = :accountId AND Account__r.RecordType.DeveloperName = 'IATA_Agency'
						   			   		   	ORDER BY Expiry_Date__c DESC];
		
		this.totalSecuredAmount = 0.0;
		this.totalConvertedAmount = 0.0;
		this.localCurrency = UserInfo.getDefaultCurrency();
		Set<String> currencyCodes = new Set<String>();
		for(Financial_Security__c fs : records) {
			FinSecWrapper fsw = new FinSecWrapper(fs);
			this.listFinSec.add(fsw);
			if(fs.Security_Status__c <> 'Expired') {
				this.totalConvertedAmount += (Decimal) fs.get('convertedAmount');
				this.totalSecuredAmount += fs.Amount__c;
				currencyCodes.add(fsw.CurrencyIsoCode);
				this.currencyCode = fsw.CurrencyIsoCode;
			}
		}

		this.showConvertedAmount = currencyCodes.size() > 1;
	}

	public class FinSecWrapper {
		public String financialInstitution {get;set;}
		public String securityType {get;set;}
		public String securityStatus {get;set;}
		public Decimal amount {get;set;}
		public String currencyIsoCode {get;set;}
		public Date validityStartDate {get;set;}
		public Date expiryDate {get;set;}
		public String cssRow {get;set;}

		public FinSecWrapper(Financial_Security__c fs) {
			this.financialInstitution = fs.Financial_Institution__r.Name;
			this.securityType = fs.Security_Type__c;
			this.securityStatus = fs.Security_Status__c;
			this.amount = fs.Amount__c;
			this.currencyIsoCode = fs.CurrencyIsoCode;
			this.validityStartDate = fs.Validity_Start_Date__c;
			this.expiryDate = fs.Expiry_Date__c;
			this.cssRow = setCSSRow(fs.Security_Status__c);
		}

		private String setCSSRow(String status) {
			if(status == 'Expired') {
				return 'expiredRow';
			} else if(status == 'Close to Expiry Date' || status == 'Pending Validation') {
				return 'closeExpireRow';
			} else {
				return 'activeRow';
			}
		}
	}
}