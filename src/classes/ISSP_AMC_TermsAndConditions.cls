public with sharing class ISSP_AMC_TermsAndConditions {

	public User userInformation {get;set;}

	public Participation_Online_Application__c controllerParticipation {
        get {
            return controllerParticipation;
        }
        set {
            controllerParticipation = value;
            userInformation();
        }
    }

    public User userInformation(){
        id userId = UserInfo.getUserId();		
        userInformation = [
							SELECT Contact.Id, Contact.Name 
							FROM User 
							WHERE Id = :userId];
		
		Contact contactRecord;
    	Contact contactInfo = OneIdProfileCompanySettings.getUserContact();
    	
    	

		//controllerParticipation.Submitted_By__C = contactInfo.id;

		return userInformation;

    }


	public ISSP_AMC_TermsAndConditions() {
		
	}
}