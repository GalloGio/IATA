public class InterviewsController {
	@AuraEnabled
   	public static String getPausedId() {
		// Get the ID of the running user
      	String currentUser = UserInfo.getUserId();
        String labelPrefix = ClaimEU261Helper.PREFIX_FLOWS + '%';
      	// Find all of that user's paused interviews for the Survey customers flow
      	List<FlowInterview> interviews =
        	[ SELECT Id FROM FlowInterview
           	WHERE CreatedById = :currentUser AND InterviewLabel like :labelPrefix];
      	
      	if (interviews == null || interviews.isEmpty()) { return null;} return interviews.get(0).Id;
   	}
    
   	@AuraEnabled
	public static List<FlowInterview> getInterviews() {
        String currentUser = UserInfo.getUserId();
        String labelPrefix = ClaimEU261Helper.PREFIX_FLOWS + '%';
		return [SELECT Id, OwnerId, Owner.Name, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, CurrentElement, InterviewLabel, PauseLabel, Guid 
                FROM FlowInterview
                WHERE CreatedById = :currentUser AND InterviewLabel like :labelPrefix];
    }

    @AuraEnabled
    public static FlowInterview deleteInterview(Id interviewId) {
      FlowInterview interview = null;
      if(interviewId != null){
        interview = [Select Id from FlowInterview Where Id = :interviewId];
        delete interview;
      }
      return interview;
        
    }
}