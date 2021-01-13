public class AMS_OSCAR_HistoryController {

	public String oscarId {get;set;}
	public AMS_IntegerCarrier nhist{get;set;}

	public AMS_OSCAR_HistoryController() {
	}

	public List<AMS_OSCAR_Event__c> getOSCARHistory(){

		List<AMS_OSCAR_Event__c> oscarhistory = null;

		oscarhistory = [SELECT CreatedDate, CreatedBy.Name, New_Value__c, Old_Value__c, Related_Step__c FROM AMS_OSCAR_Event__c WHERE OSCAR__c =: oscarId ORDER BY CreatedDate DESC];

		nhist.value = oscarhistory.size();
		return oscarhistory;

	}
}
