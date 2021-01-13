public without sharing class FlowUpdateARBCWithoutSharing {
	@InvocableMethod(
		label = 'Update an Address Role Business Context without sharing'
		description = 'Allow user to update an Address Role Business Context, bypassing the sharing rules'
	)
	public static List<Response> execute(List<Request> requests){
		List<Address_Role_Business_Context__c> arbcToUpdate = new List<Address_Role_Business_Context__c>();
		for(Request request : requests){
			arbcToUpdate.add(new Address_Role_Business_Context__c(Id = request.addressRoleBusinessContextId, Account_Activation_Context_Status__c = request.flowStatus));
		}
		update arbcToUpdate;
		List<Response> responses = new List<Response>();
		for(Address_Role_Business_Context__c arbc : arbcToUpdate){
			responses.add(new Response(arbc));
		}
		return responses;
	}

	public class Request {
		@InvocableVariable(
			label = 'Address Role Business Context Id'
			description = 'Id of Address Role Business Context to update without sharing'
		)
		public Id addressRoleBusinessContextId;
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
		public Address_Role_Business_Context__c arbcAfterDml;

		public Response(Address_Role_Business_Context__c arbc){
			arbcAfterDml = arbc;
		}
	}
}