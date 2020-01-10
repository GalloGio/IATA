public with sharing class FlowGetBusinessContextsInvocable {
	@InvocableMethod(
			label = 'Get Available Business Contexts or Sales Areas'
			description = 'Get available business contexts or sales areas for an account based on custom permissions for the running user'
	)
	public static List<Response> execute(List<Request> requests){
		List<Response> responses = new List<Response>();
		Response response = new Response();
		response.picklistValues = BusinessContextUtils.getFlowPicklistValues(requests[0].useCase, UserInfo.getUserId(), requests[0].accountId, requests[0].selectedBusinessContext);
		responses.add(response);
		return responses;
	}

	public class Request {
		@InvocableVariable(
				label = 'Account ID'
				description = 'Account ID'
				required = true
		)
		public Id accountId;

		@InvocableVariable(
				label = 'Use Case'
				description = 'Values are \'BC\' for Business context picklist and \'SA\' for Sales area picklist'
				required = true
		)
		public String useCase;

		@InvocableVariable(
				label = 'Business contexts selected by the user'
				description = 'Business contexts selected, required if use case is \'SA\''
		)
		public String selectedBusinessContext;
	}


	public class Response {
		@InvocableVariable(
				label = 'Concatened picklist values'
				description = 'Concatened picklist values, example : value1:label1;value2:label2; etc...'
		)
		public String picklistValues;

		public Response(){
			picklistValues = '';
		}
	}
}