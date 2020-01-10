public with sharing class EF_BaHistoryController {
	public EF_Billing_Agreement__c con {get; set;}
	public EF_BaHistoryController(ApexPages.StandardController controller)
	{
		if(controller != null)
		{
			this.con = [select Id, EF_History__c from EF_Billing_Agreement__c where Id = :controller.getId()];
		}
	}
}
