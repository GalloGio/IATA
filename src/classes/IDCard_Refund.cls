public class IDCard_Refund{

	public Case c {get;set;}

	public IDCard_Refund(ApexPages.StandardController ctrl) {
		c = (Case)ctrl.getRecord();
		String cId = c.ID;
		List<Case> cs = [SELECT Id, Reasons_of_Reject__c, Refund__c, Related_ID_Card_Application__c FROM Case where Id =: cId];
		c = cs[0];
	}

	public PageReference save() {
		upsert c;
		return new PageReference('/' + c.Related_ID_Card_Application__c);
	}
}
