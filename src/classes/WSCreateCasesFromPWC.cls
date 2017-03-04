@RestResource(urlMapping='/PWC/*')
global with sharing class WSCreateCasesFromPWC {
	
	public static final String BATCH_SUBJECT = 'Create Cases From PWC';
	public static final String FILE_NAME_REQUEST = 'webservice_request.txt';
	public static final String FILE_NAME_RESPONSE = 'webservice_reponse.txt';
	
	
	public static final String ERROR_CANNOT_CREATE = 'Cannot create batch';
	public static final String ERROR_NO_RESOURCE = 'No resource available';
	
	public class customException extends Exception {}
	
	@HttpPost	
	Global Static String doPost(list<SecurityCase> cases) {
		system.debug('DTULLO ' + cases);
		try {
			if ( cases.isEmpty() ) throw new customException('No cases to process');
			BatchNumber__c batchNumber = createBatchNumber();
			insert batchNumber;
			insert createAttachment( batchNumber.Id, JSON.serialize(cases));
			batchNumber = [Select Name, enqueue_Batch__c from BatchNumber__c where id = :batchNumber.Id ];
			//call batch in schedule method
			ScheduleCreateCasesFromPWC.launchSchedule(batchNumber.Name);
			return JSON.serialize( new ResponsePOST('SUCCESS', batchNumber.Name, '') );
			
		} catch ( Exception e ) {
			return JSON.serialize( new ResponsePOST('ERROR', '', e.getMessage()) );
		}
	}
	
	@HttpGet	
	Global Static String doGet() {
		try {
			RestRequest request = RestContext.request;
			String process = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
			BatchNumber__c batchNumber = [ Select Id from BatchNumber__c where Name = :process ];
			list<Attachment> listResponse = [ Select Id, Body from Attachment where parentId = :batchNumber.Id and Name = :FILE_NAME_RESPONSE];
			if ( listResponse.isEmpty() ) {
				return JSON.serialize( new BatchCreateCasesFromPWC.responsePWCError('IN_PROGRESS', '') );
			} 
			return listResponse[0].Body.toString();
			
		} catch (Exception e ) {
			return JSON.serialize( new BatchCreateCasesFromPWC.responsePWCError('ERROR', ERROR_NO_RESOURCE) );
		}
	}
	
	@TestVisible
	private static BatchNumber__c createBatchNumber( ) {
		BatchNumber__c batch = new BatchNumber__c(
			Subject__c = BATCH_SUBJECT,
			Deadline_date__c = Date.today()
		);
		return batch;
	}
	
	@TestVisible
	private static Attachment createAttachment( Id parentId, String data ) {
		Attachment att = new Attachment(
			Body = Blob.valueOf(data),
			Name = FILE_NAME_REQUEST,
			parentId = parentId
		);
		return att;
	}
	
	public class ResponsePOST {
		public String Status {get; set;}
		public String UniqueId {get; set;}
		public String ErrorMsg {get; set;}
		
		public ResponsePOST( String status, String UniqueId, String errorMsg) {
			this.Status = status;
			this.UniqueId = uniqueId;
			this.ErrorMsg = errorMsg;
		}
	}
	
	global class SecurityCase {
		public String AimsID {get; set;}
		public Decimal Amount {get; set;}
		public String CurrencyISO {get; set;}
		public Integer Reason {get; set;}
		public String ExpiryDate {get; set;}
		
		public SecurityCase( String aimsid, Decimal Amount, String curr, Integer reason, String ExpiryDate) {
			this.AIMSID = aimsid;
			this.Amount = Amount;
			this.CurrencyISO = curr;
			this.Reason = reason;
			this.ExpiryDate = ExpiryDate;
		}
		
		public Boolean extractReason() {
			return this.reason == 1;
		}
		
		public Date extractExpiryDate() {
			try {
				list<String> listDate = this.expiryDate.split('-');
				return Date.newInstance(Integer.ValueOf(listDate[0]), Integer.ValueOf(listDate[1]), Integer.ValueOf(listDate[2]));
			} catch ( Exception e) {
				return null;
			}
		} 
	}
	
}