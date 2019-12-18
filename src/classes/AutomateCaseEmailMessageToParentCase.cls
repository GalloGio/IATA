public with sharing class AutomateCaseEmailMessageToParentCase {

 /* This function is meant to be called from a process (from process builder) and is supposed to receive a list with only 1 case */
	@InvocableMethod(label='Copy Email Messages to parent case' description='Copy a Email Messages from case to his child cases')
	public static List<Boolean> copyEmailMessageToParent(List<Id> emailMessageId){
		if(emailMessageId.size() != 1){
			return new List<Boolean>{false};
		}

		EmailMessage message = [SELECT Id, ParentId,ToAddress, TextBody FROM EmailMessage WHERE Id = :emailMessageId.get(0)];

		if(message != null && message.ParentId != null){

			Case emailCase = [SELECT Id, ParentId FROM Case WHERE Id = :message.ParentId];

			if(emailCase != null && emailCase.ParentId != null){
				message.Id = null;
				message.ParentId = emailCase.ParentId;

				try {
					insert message;
				} catch (Exception e) {
					return new List<Boolean>{false};
				}
				return new List<Boolean>{true};
			}
		}
		return new List<Boolean>{false};
	}
}