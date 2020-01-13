public class trgIECEBC_CampaignHandler {
	class Validation_Exception extends Exception {}

	public static void updateScheduledDateValidUntil(List<EBC_Campaign__c> newCampaigns) {
		if (!Trigger.isBefore || !Trigger.isUpdate) return ;

		BusinessHours bh;

		for(EBC_Campaign__c n : newCampaigns) {
			EBC_Campaign__c o = (EBC_Campaign__c)Trigger.oldMap.get(n.Id);

			if (o.Scheduled_Date__c == n.Scheduled_Date__c || n.Status__c == 'APPROVED') continue;

			if (bh == null) bh = [select Id from BusinessHours where Name = 'EBC Campaign Approval'];

			n.Scheduled_Date_Valid_Until__c = BusinessHours.add(bh.Id, n.Scheduled_Date__c, -1 * Integer.valueOf(3600 * (2 * 9) * 1000)); // Scheduled date - (2 days - 1 hour)
		}
	}
}
