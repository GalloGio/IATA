public with sharing class ISSP_AMC_LocationAirportHeliportForm {

	public Participation_Online_Application__c controllerParticipation {
		get {
			return controllerParticipation;
		}
		set {
			controllerParticipation = value;
		}
	}

	public ISSP_AMC_LocationAirportHeliportForm() {}

	/*public void clearDate(){
		controllerParticipation.Planned_Open_date_for_this_airline__c = null;
		controllerParticipation.Date_when_airport_has_been_operational__c = Date.parse(null);

	}*/

	/*public void formatDate(){
		if(controllerParticipation.Planned_Open_date_for_this_airline__c != null){
			Date yourDate = controllerParticipation.Planned_Open_date_for_this_airline__c;
			controllerParticipation.Planned_Open_date_for_this_airline__c = yourDate;
		}
	}*/
}