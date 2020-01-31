public without sharing class RCRMContractRevenueStreamController {
	public Contract con {get; set;}
	public List<Revenue_Stream_Line__c> lstRSLs {get; set;}

	public Boolean showSaveButton {
		public get {
			// Only the Product Manager on the contract can edit the revenue stream
			Boolean tmpResult = con.RCRM_Product_Manager__c == UserInfo.getUserId();

			return tmpResult;
		} private set;
	}

	public RCRMContractRevenueStreamController (final ApexPages.StandardController controller) {
		con = [SELECT Id, Renewal_Status__c, OwnerId, RCRM_Product_Manager__c, SAP_Contract_Number__c FROM Contract WHERE Id = :controller.getRecord().Id];

		// Get the current + next 3 revenue stream lines
		Date firstDayOfCurrentYear = date.newInstance(date.today().year(), 1, 1);
		Date lastDayOfY3 = date.newInstance(date.today().year() + 3, 12, 31); // Last day of current year + 3
		lstRSLs = [SELECT Id, Year__c, Start_date__c, End_Date__c, Annualized_value__c, Revenue_Type__c, Product__r.Name FROM Revenue_Stream_Line__c
						WHERE Contract__c = :con.Id AND Start_Date__c >= :firstDayOfCurrentYear AND Start_Date__c <= :lastDayOfY3 ORDER BY Product__r.Name, Start_Date__c];

	}

	public void SaveRS() {
		try {
			update lstRSLs;

			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Revenue Stream successfully updated.'));
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
		}
	}

	public void SaveSAPContractNumber() {
		try {
			update con;

			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'SAP Contract Number successfully updated.'));
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
		}
	}

}
