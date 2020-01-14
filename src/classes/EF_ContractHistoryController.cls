public with sharing class EF_ContractHistoryController {
	public Contract con {get; set;}
	public EF_ContractHistoryController(ApexPages.StandardController controller)
	{
		if(controller != null)
		{
			this.con = [select Id, EF_History__c from Contract where Id = :controller.getId()];
		}
	}
}
