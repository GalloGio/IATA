public without sharing class FlowUpdateAccountRoleWithoutSharing {
	@InvocableMethod(
		label = 'Update an account role without sharing'
		description = 'Allow user to update an account role, bypassing the sharing rules'
	)
	public static List<Response> execute(List<Request> requests){
		List<Account_Role__c> accountRolesToUpdate = new List<Account_Role__c>();
		Set<Id> accountRoleIds = new Set<Id>();
		for(Request request : requests){
			if(!accountRoleIds.contains(request.accountRoleId)){
				accountRolesToUpdate.add(new Account_Role__c(Id = request.accountRoleId, Flow_Status__c = request.flowStatus));
			}
		}
		update accountRolesToUpdate;
		List<Response> responses = new List<Response>();
		for(Account_Role__c accountRole : accountRolesToUpdate){
			responses.add(new Response(accountRole));
		}
		return responses;
	}

	public class Request {
		@InvocableVariable(
			label = 'Account role Id'
			description = 'Id of Account role to update without sharing'
		)
		public Id accountRoleId;
		@InvocableVariable(
			label = 'Flow status'
			description = 'Flow status to set'
		)
		public String flowStatus;
	}


	public class Response {
		@InvocableVariable(
			label = 'Account role after update'
			description = 'Account role after update'
		)
		public Account_Role__c accountRoleAfterDml;

		public Response(Account_Role__c accountRole){
			accountRoleAfterDml = accountRole;
		}
	}
}