public with sharing class FlowGetBusinessContextsInvocable {
	@InvocableMethod(
			label = 'Get Available Business Context'
			description = 'Get available business contexts for an account based on custom permissions for the running user'
	)
	public static List<Response> execute(List<Request> requests){
		List<Response> responses = new List<Response>();
		Response response = new Response();
		response.businessContextAvailable = BusinessContextUtils.getFlowPicklistValues('BC', UserInfo.getUserId(), requests[0].accountId, null);
		responses.add(response);
		return responses;
	}

	public class Request {
		@InvocableVariable(
				label = 'Account ID'
				description = 'Account ID'
		)
		public Id accountId;
	}


	public class Response {
		@InvocableVariable(
				label = 'Business contexts available'
				description = 'Concatenation of the list of business contexts available'
		)
		public String businessContextAvailable;

		public Response(){
			businessContextAvailable = '';
		}
	}
}