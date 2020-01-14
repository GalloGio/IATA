public class ZuoraSubscription_DTO {

	public Zuora__Subscription__c zSubscription {get; set;}
	public integer iSubscriptionDaysLeft		{get; set;}
	public decimal dUnitsPurchased				{get; set;}
	public boolean bShowUsage 					{get; set;}
	public decimal dUnitsConsumed				{get; set;}
	public decimal dUnitsLeft					{get; set;}
	public String sAttachTermsId				{get; set;}
	public Zuora__ZInvoice__c invoice			{get; set;}
	public Zuora__Payment__c payment			{get; set;}
	public boolean bDisplayUpgradeBtn			{get; set;}
	public ID idSelectedRatePlanInfo			{get; set;} // Initially set from Subscription History, but then swapped if applicable
	public ID idSelectedProdInfo				{get; set;} // Initially set from Subscription History, but then swapped if applicable
	public boolean bDisplaySimProdBtn			{get; set;}
	public boolean bDisplayNewBtn				{get; set;}
	public boolean bDisplayRenewBtn 			{get; set;}
	public String productName					{get; set;}
	public String ratePlanName 					{get; set;}

}
