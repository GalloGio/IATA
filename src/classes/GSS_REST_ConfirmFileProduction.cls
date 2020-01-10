@RestResource(urlMapping='/GSS/v0/ConfirmFileProduction/*')
global with sharing class GSS_REST_ConfirmFileProduction{

	@HttpPost
	global static void  postConfirmationFileProduction() {
		try{
			//Parse the request body and extract the ProductionConfirmation object list
			list<ProductionConfirmation> confirmationList  = new list<ProductionConfirmation>();
			confirmationList = (list<ProductionConfirmation>)JSON.deserialize(
				RestContext.request.requestBody.toString(),
				list<ProductionConfirmation>.class);

			//Data Validation loop
			Map<String, id> ProductionIds = new map<string,id>();
			set<id> fileSpecificationIdSet = new set<id>();

			for(ProductionConfirmation confirmation: confirmationList){
				//Data validation will throw exception in case of bad input
				//Validate Required fields

				if(confirmation.FileSpecificationId == '' || confirmation.FileSpecificationId == null) throw new MyException('FileSpecificationId is required');


				//Status should be a valid picklist entry
				if (confirmation.Status != 'Completed' && confirmation.Status != 'In Progress' && confirmation.Status != 'Failed')
					throw new MyException('Status should be one of theses values: "In Progress", "Completed", or "Failed"');

				//Build set of id to filter down the GDP_File_Production object
				fileSpecificationIdSet.add(confirmation.FileSpecificationId);

			}

		   //Query a limited subset of the File Production object to retrieve Ids of existing record for upserts

		   for (GDP_File_Production__c ffd :  [SELECT Id
													,File_Specification__c
													,Status__c
													,Size__c
													,Duration__c
													,Production_Date__c
													,Message__c
											  FROM GDP_File_Production__c
											  WHERE File_Specification__c IN : fileSpecificationIdSet
											]){

			   ProductionIds.put(ffd.File_Specification__c  , ffd.Id);
			}

			list<GDP_File_Production__c>  FileProductionList = new list<GDP_File_Production__c>();
			for(ProductionConfirmation confirmation: confirmationList){


				//Create the Production confirmation and add it to the list to upsert in Salesforce
				GDP_File_Production__c  FileProduction = new GDP_File_Production__c();
				string key = confirmation.FileSpecificationId;

				if(ProductionIds.containsKey(key)){
					FileProduction.id = ProductionIds.get(key);
				}
				else{
					//This will create an insert as the Id does not exist, and is only written once
					FileProduction.Id = null;
					FileProduction.File_Specification__c = confirmation.FileSpecificationId;
				}
				FileProduction.File_Specification__c = confirmation.FileSpecificationId;
				FileProduction.Production_Date__c    = Date.Today();
				//This information is inserted or updated
				if (confirmation.Size==null) confirmation.Size='0';
				if (confirmation.Duration==null)  confirmation.Duration='0';
				if (confirmation.Size.Trim().equals('')) confirmation.Size='0';
				if (confirmation.Duration.Trim().equals(''))  confirmation.Duration='0';
				FileProduction.Size__c      = Integer.ValueOf(confirmation.Size);
				FileProduction.Duration__c  = Integer.ValueOf(confirmation.Duration);
				FileProduction.Status__c  = confirmation.Status;
				FileProduction.Message__c = confirmation.FailureMessage;
				FileProductionList.add(FileProduction);
			}
			Upsert FileProductionList;

			//Build the response object and send back the list of Ids of the production confirmation record
			list<ReturnId> confirmationResponse = new list<ReturnId>();
			for(GDP_File_Production__c confirmation : FileProductionList){
				String Year  =String.ValueOf(confirmation.Production_Date__c.Year()).Trim();
				String Month =String.ValueOf(confirmation.Production_Date__c.Month()).Trim();
				String ProductionFileName=getProductionFileName(confirmation.Id, Year,Month);
				confirmationResponse.add(new ReturnId(confirmation.Id,ProductionFileName, confirmation.File_Specification__c ));
			}
			RestContext.response.statusCode = 200;
			RestContext.response.responseBody = Blob.valueOf(json.serialize(confirmationResponse));
		}
		catch(exception e){
			RestContext.response.statusCode = 400;
			RestContext.response.responseBody  = Blob.valueOf(
				'Cause:            ' + e.getCause() + '\n' +
				'Message:          ' + e.getMessage() + '\n' +
				'LineNumber:       ' + e.getLineNumber() + '\n' +
				'StackTraceString: ' + e.getStackTraceString() + '\n' +
				'TypeName:         ' + e.getTypeName()
			);
		}
	}

	// this has to be consistent with the naming in GSS_REST_FileSpecification.cls
	// the internal file production name is <GDP_File_Production__c.Id-18_digit>_YYYY_MM.dat
	global static String getProductionFileName(String Source, String YearProduction, String MonthProduction)
	{
		String Month = MonthProduction.trim().leftPad(2).replace(' ','0');
		return Source+'_'+YearProduction+'_' + Month +'.dat';
	}


	//Request class format in JSON
	/*
	* Example Json request to be sent in HTTP Body:
	*
		[
			{
				"Status":"Completed",
				"FileSpecificationId":"a50g0000000DYu4AAG",
				"FailureMessage":"This is a to do delivery example"
			},
			...,
			{..}
		]
	*/
	global class ProductionConfirmation {
		public string FileSpecificationId {get;set;}
		public string FailureMessage {get;set;}
		public string Status {get;set;}
		public string Size {get;set;}
		public string Duration {get;set;}

		//Constructor
		public ProductionConfirmation(){
			this.FileSpecificationId = '';
			this.FailureMessage = '';
			this.Status = '';
			this.Size='0';
			this.Duration='0';
		}
	}

	//Response class format in JSON
	global class ReturnId {
		public string id {get;set;}
		public String FileSpecification {get;set;}
		public String Productionfilename {get;set;}
		//Constructor
		public ReturnId(string id, string prodfilename, string filespec){
			this.id = id;
			this.FileSpecification=filespec;
			this.Productionfilename=prodfilename;
		}
	}

	//Custom Exception Class
	public class MyException extends Exception {}

}
