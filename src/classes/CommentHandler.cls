public with sharing class CommentHandler {

	/**
		Update Division, Region and Area from the parent Objective
	**/
	public static void setObjectiveInfo(Comment__c comment) {
		if ( comment.Parent_Objective__c != null ) {
			Objective__c obj = [
			Select Division__c, Region__c, Sub_region__c, Area__c
				from Objective__c
				where id = :comment.Parent_Objective__c ];

			comment.Division__c = obj.Division__c;
			comment.Region__c = obj.Region__c;
			comment.Sub_region__c = obj.Sub_region__c;
			comment.Area__c = obj.Area__c;
		}
	}

}
