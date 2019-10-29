public with sharing class ISSP_AMC_DeclarationSubmittedBy {


	public User userInformation {get;set;}

    public Participation_Online_Application__c controllerParticipation {
        get {
            return controllerParticipation;
        }
        set {
            controllerParticipation = value;
        }
    }

    public User userInformation(){
        id userId = UserInfo.getUserId();
        userInformation = [SELECT Contact.Name, Contact.Title 
        FROM User 
        WHERE Id = :userId
        ];
            
        return userInformation;
    }
   

	public ISSP_AMC_DeclarationSubmittedBy() {

		userInformation();
	}
}