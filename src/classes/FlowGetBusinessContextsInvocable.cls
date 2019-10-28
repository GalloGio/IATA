public with sharing class FlowGetBusinessContextsInvocable {
	@InvocableMethod(
			label = 'Get Available Business Context'
			description = 'Get Available Business Context'
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
				label = 'Business context available'
				description = 'List business context available to select'
		)
		public String businessContextAvailable;

		public Response(){
			businessContextAvailable = '';
		}
	}
}