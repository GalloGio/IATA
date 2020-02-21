public with sharing class ISSP_Contact_User {

	public User thisUser {get; set;}

	public ISSP_Contact_User(Apexpages.Standardcontroller ctrl){
		thisUser = new User();
		List <User> userList = [SELECT Id, Portal_User_Frozen_Checkbox__c FROM User
								WHERE ContactId = :ctrl.getId()];
		if (!userList.isEmpty()){
			thisUser = userList[0];
		}
	}
}
