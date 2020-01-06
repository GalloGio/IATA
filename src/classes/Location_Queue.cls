public class Location_Queue implements Queueable, Database.AllowsCallouts
{
	List<Location__c> locations;

	public Location_Queue(List<Location__c> lst)
	{
		locations = lst;
	}

	public void execute(QueueableContext context)
	{
		if(locations != null && locations.size() > 0)
		{
			IECAddress_Svc.syncCustomerMasterWithSAP(locations);
		}
	}
}
