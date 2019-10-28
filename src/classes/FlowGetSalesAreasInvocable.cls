public with sharing class FlowGetSalesAreasInvocable {
	@InvocableMethod(
			label = 'Get Sales Area'
			description = 'Get Sales Area based on the business context'
	)
	public static List<Response> execute(List<Request> requests){
		List<Response> responses = new List<Response>();
		Response response = new Response();
		response.salesAreaAvailable = BusinessContextUtils.getFlowPicklistValues('SA', UserInfo.getUserId(), requests[0].accountId, requests[0].selectedBusinessContext);
		responses.add(response);
		return responses;
	}

	public class Request {
		@InvocableVariable(
				label = 'Account ID'
				description = 'Account ID'
		)
		public Id accountId;

		@InvocableVariable(
				label = 'Business contexts selected by the user'
				description = 'Business contexts selected'
		)
		public String selectedBusinessContext;
	}


	public class Response {
		@InvocableVariable(
				label = 'Sales area available'
				description = 'List sales area available to select'
		)
		public String salesAreaAvailable;

		public Response(){
			salesAreaAvailable = '';
		}
	}
}