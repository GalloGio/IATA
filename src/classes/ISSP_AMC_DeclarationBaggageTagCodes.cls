public class ISSP_AMC_DeclarationBaggageTagCodes {


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
        userInformation = [SELECT Contact.Name 
        FROM User 
        WHERE Id = :userId
        ];
            
        return userInformation;
    }
    

	public ISSP_AMC_DeclarationBaggageTagCodes() {
		userInformation();
	}




    
}