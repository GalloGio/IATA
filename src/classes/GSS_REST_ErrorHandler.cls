@RestResource(urlMapping='/GSS/v0/ExceptionHandler/*')
global with sharing class GSS_REST_ErrorHandler{

	@HttpPost
	global static void  postException() {
		try{
			//Parse the request body and extract the DeliveryConfirmation object list
			ExceptionHandler reqEx  = new ExceptionHandler();
			reqEx = (ExceptionHandler)JSON.deserialize(
				RestContext.request.requestBody.toString(),
				ExceptionHandler.class);


			//Validate input Data
			if( reqEx.ModuleProcess == '' ||  reqEx.ModuleProcess == null) throw new MyException('ExceptionHandler.ModuleProcess is required');
			if( reqEx.ExceptionMessage == '' ||  reqEx.ExceptionMessage == null) throw new MyException('ExceptionHandler.ExceptionMessage is required');

			IEC_Error_Log__c ErrorLog = new IEC_Error_Log__c();

			//Unmapped fields, can be used in the future:
			//ErrorLog.Contact__c //Lookup(Contact)
			//ErrorLog.Extra_Information__c    Long Text Area(32768)
			//ErrorLog.IATACODE__c    Text(15)

			ErrorLog.Source__c         = reqEx.ModuleProcess.left(255);
			ErrorLog.Errror_Message__c = reqEx.ExceptionMessage.left(255);
			ErrorLog.Stack_Trace__c    = reqEx.StackTrace.left(32768);
			ErrorLog.Displayed_Message__c = reqEx.DisplayedMessage.left(255);


			//    Hardcoded value Picklist to Error (Error, Warning, Info)
			ErrorLog.Type__c= 'Error';

			Insert ErrorLog;

			//Send back status code and Return Id as response
			RestContext.response.statuscode = 200;
			RestContext.response.responseBody = Blob.valueOf(json.serialize(new ReturnId(ErrorLog.Id)));

		}
		Catch (Exception e){
			String msg =
				'getMessage()' + e.getMessage() + '\n' +
				'getCause()' + e.getCause() + '\n' +
				'getLineNumber()' + e.getLineNumber() + '\n' +
				'getStackTraceString()' + e.getStackTraceString() + '\n' +
				'getTypeName()' + e.getTypeName();

			System.debug(msg);
			RestContext.response.statuscode = 400;
			RestContext.response.responseBody = Blob.valueOf(msg);
		}

	}

	//Request Class
	global class ExceptionHandler {
		//Module name like Subscription List extract, FileSpecification Extract
		public String ModuleProcess {get; set;}
		//Any error catched during the java process, the full message
		public String ExceptionMessage {get;set;}
		public String StackTrace // TextArea 32K
		{
			set;
			get { // getter will ensure it will never return null, but return blank instead
				if (StackTrace == null)  return '';
				return StackTrace;
			}
		} // end of StackTrace

		public String DisplayedMessage // Text(255) containing brief error information in English
		{
			set;
			get { // getter will ensure it will never return null, but return blank instead
				if (DisplayedMessage == null) return '';
				return DisplayedMessage;
			}
		} // end of DisplayedMessage

		//Unexposed fields can be used in the future
		//String Contact {get;set;}             //Lookup(Contact)
		//String ExtraInformation__c{get;set;}    //Long Text Area(32768)
		//String IATACODE     {get;set;}          //Text(15)


		//Constructor
		public ExceptionHandler(){}
	}

	//Response class format in JSON
	global class ReturnId {
		public string id {get;set;}
		//Constructor
		public ReturnId(string id){
			this.id = id;
		}
	}

	public class MyException extends Exception {}

}
