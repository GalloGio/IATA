/*
*  REST API Service for reporting the File Delivery status
*  - External class will call postConfirmationFileDelivery (@HttpPost) method
*  - URI Parameter:  none
*  - REST API Input (body): {DeliveryConfirmation}
*  - REST API response: { list<ReturnId> }
*  Change log:
*   20160105: Sonny Leman: Change field name ProductCharge to SubscriptionDetail to reflect the actual information
*   20160116: Sonny Leman: Subscription is not required, some GDP_File_Delivery error is not ALL_OR_NOTHING
*   20160310: Sonny Leman: Update GSS_Subscription_Detail on successful delivery (for Submission Date fields)
*   20160311: Sonny Leman: cover the case that SubscriptionId is empty
*   20160322: Sonny Leman: cover the possibility that a SubscriptionDetail Id might be related to more than 2 frequency (when master was delivered)
*/

@RestResource(urlMapping='/GSS/v0/ConfirmFileDelivery/*')
global with sharing class GSS_REST_ConfirmFileDelivery{

	@HttpPost
	global static void  postConfirmationFileDelivery() {
		Map<Id, GSS_Subscription_Detail__c> deliveredSubDetIdToObjectMap = new Map<Id, GSS_Subscription_Detail__c>(); // map of the successfully delivered GSS_Subscription_Detail
		Map<Id,String> deliveredSubDetIdToFrequencyMap = new Map<Id,String>();

		try{
			//Parse the request body and extract the DeliveryConfirmation object list
			list<DeliveryConfirmation> confirmationList  = new list<DeliveryConfirmation>();
			confirmationList = (list<DeliveryConfirmation>)JSON.deserialize(
				RestContext.request.requestBody.toString(),
				list<DeliveryConfirmation>.class);

			//Data Validation loop
			Map<String, id> Sid_FSid_PCid_2_DeliveryId = new map<string,id>();
			set<id> subscriptionIdSet      = new set<id>(); // TODO: verify if this is needed
			set<id> fileSpecificationIdSet = new set<id>();
			set<id> subscriptionDetailIdSet     = new set<id>();

			for(DeliveryConfirmation confirmation: confirmationList){
				//Data validation will throw exception in case of bad input
				//Validate Required fields
				//if(confirmation.SubscriptionId == '' || confirmation.SubscriptionId == null)   throw new MyException('SubscriptionId is required');

				if(confirmation.FileSpecificationId == '' || confirmation.FileSpecificationId == null)    throw new MyException('FileSpecificationId is required');

				if(confirmation.SubscriptionDetailId == '' || confirmation.SubscriptionDetailId == null)  throw new MyException('SubscriptionDetailId is required');

				//Status should be a valid picklist entry
				if (confirmation.Status != 'Completed' && confirmation.Status != 'In Progress' && confirmation.Status != 'Failed')
					throw new MyException('Status should be one of theses values: "In Progress", "Completed", or "Failed"');

				//Build set of id to filter down the GDP_File_Delivery object
				if ((confirmation.SubscriptionId != null) && (confirmation.SubscriptionId.trim().length()>=15))
				{
					subscriptionIdSet.add(confirmation.SubscriptionId); // TODO: verify if this is needed, as SubscriptionId can be null
				}
				fileSpecificationIdSet.add(confirmation.FileSpecificationId);
				subscriptionDetailIdSet.add(confirmation.SubscriptionDetailId);

			} // end for

		   //Query a limited subset of the File Delivery object to retrieve Ids of existing record for upserts
		   for (GDP_File_Delivery__c ffd :  [SELECT Id
													, Subscription__c
													, File_Specification__c
													, GSS_Subscription_Detail__c
															 /*, Delivery_Date__c, Message__c, Status__c*/
													 FROM GDP_File_Delivery__c
													   WHERE GSS_Subscription_Detail__c IN : subscriptionDetailIdSet
														 // AND Subscription__c IN : subscriptionIdSet // TODO: verify if this is needed, because incoming SubscriptionId might be null
														 AND File_Specification__c IN : fileSpecificationIdSet
														 AND Delivery_Date__c = TODAY
											]){

			   Sid_FSid_PCid_2_DeliveryId.put(ffd.Subscription__c +'|'+ ffd.File_Specification__c +'|'+ ffd.GSS_Subscription_Detail__c , ffd.Id);
			} // end for soql


			list<GDP_File_Delivery__c>  FileDeliveryList = new list<GDP_File_Delivery__c>();
			for(DeliveryConfirmation confirmation: confirmationList){


				//Create the delivery confirmation and add it to the list to upsert in Salesforce
				GDP_File_Delivery__c  FileDelivery = new GDP_File_Delivery__c();

				//looking at the GDP_File_Delivery object if the logical
				//unique key exists i.e. Subscription_Product_Charge +  Date
				//If this key already exists, update that record, if not, insert a new record.
				//this will avoid creating duplicate entries in the GDP_File_Delivery object

				string key = confirmation.SubscriptionId  +'|'+ confirmation.FileSpecificationId   +'|'+ confirmation.SubscriptionDetailId;

				if(Sid_FSid_PCid_2_DeliveryId.containsKey(key)){
					FileDelivery.id = Sid_FSid_PCid_2_DeliveryId.get(key);
				}
				else{
					//This will create an insert as the Id does not exist, and is only written once
					FileDelivery.Id = null;
					FileDelivery.Delivery_Date__c               = Date.Today();
					FileDelivery.Delivery_Date_Text__c          = DateTime.now().format('dd MMM yyyy');
					if ((confirmation.SubscriptionId != null) && (confirmation.SubscriptionId.trim().length()>=15))
					{ // delivery confirmation might not have SubscriptionId, so it is better to put null, than blank
						FileDelivery.Subscription__c            = confirmation.SubscriptionId;
					}
					FileDelivery.File_Specification__c          = confirmation.FileSpecificationId;
					FileDelivery.GSS_Subscription_Detail__c     = confirmation.SubscriptionDetailId;
					FileDelivery.Notification__c = '0';  // default: Do Not Notify
				}

				//This information is inserted or updated
				FileDelivery.Notification__c = '0'; // default: Do Not Notify
				FileDelivery.Status__c                   = confirmation.Status;
				FileDelivery.Message__c                  = confirmation.FailureMessage;
				FileDelivery.File_Name__c                = confirmation.FileName;
				if (confirmation.FileSizeNumber != null) {
					FileDelivery.File_Size__c               = confirmation.FileSizeNumber;
				}

				FileDeliveryList.add(FileDelivery);
			}
			Upsert FileDeliveryList;  // first upsert of incoming FileDelivery record


			Set<id> CompletedSet  = new Set<id>();
			//Build the response object and send back the list of Ids of the delivery confirmation record
			list<ReturnId> confirmationResponse = new list<ReturnId>();
			for(GDP_File_Delivery__c confirmation : FileDeliveryList){
				confirmationResponse.add(new ReturnId(confirmation.Id));
				// Load the FileDelivery with Status equals to Completed
				if (confirmation.Status__c =='Completed')  CompletedSet.Add(confirmation.Id);
			}


			// Process the File_Delivery with Completed Status to set Notification, List_of_files_delivered__c
			// Query The FileDelivery to reorder the notification and get other fields
			if (CompletedSet.Size()>0)
			{
				// get the details of the file delivery records
				List<GDP_File_Delivery__c>  fdList = new List<GDP_File_Delivery__c>();
				fdList = [SELECT Id
								,Subscription__c
								,Subscription__r.Zuora__CustomerAccount__r.Contact__c
								,File_Specification__c
								,File_Specification__r.Description__c
								,GSS_Subscription_Detail__r.GDP_File_Description__r.Master_File_Description__c
								,Notification__c
								,GSS_Subscription_Detail__c
								,GSS_Subscription_Detail__r.FileRecipientEmail__c
								,GSS_Subscription_Detail__r.FileRecipientFirstName__c
								,GSS_Subscription_Detail__r.FileRecipientLastName__c
								,GSS_Subscription_Detail__r.Calendar_Semi_Monthly_First_Option__c
								,GSS_Subscription_Detail__r.Calendar_Semi_Monthly_Second_Option__c
								,GSS_Subscription_Detail__r.Calendar_Weekly_Option__c
								,GSS_Subscription_Detail__r.Calendar_Monthly_Option__c
								,GSS_Subscription_Detail__r.GDP_File_Description__r.Frequency__c
								,Technical_Contact_Email__c
								,Technical_Contact_Name__c
								,List_of_files_delivered__c
								,Quantity_of_file_in_delivery__c
								,Delivery_Date__c
								,Message__c
								,File_Name__c
								,Status__c
					 FROM GDP_File_Delivery__c
					   WHERE Id=:CompletedSet
					   Order By Subscription__c,
								Id desc];

				if (fdList.Size()>0)
				{
					//With the delta files the Master is sent first,
					//and after the 12 months the master and the delta files are sent alltogether
					//The Master is the one to intercepte for the update of the Masterfile_delivery date to update
					integer delta_state=0;
					Set<Id> SubscriptionDetailIds = new Set<Id>();
					//List<GSS_Subscription_Detail__c> SubscriptionDetailList =new List<GSS_Subscription_Detail__c>();
					for(GDP_File_Delivery__c filedelivered:fdList)  {
						// preparation to set Calendar_Next_Submission_Date and Calendar_New_Submission_Effective_Date:
						//if ( (fileDelivered.GSS_Subscription_Detail__r.GDP_File_Description__r.Frequency__c != 'Daily')
						if(filedelivered.GSS_Subscription_Detail__c != null)
						{  // collect the subscription detail to be updated
							//
							GSS_Subscription_Detail__c deliveredSubscription = new GSS_Subscription_Detail__c(
								Id = filedelivered.GSS_Subscription_Detail__c
								, Calendar_Semi_Monthly_First_Option__c = filedelivered.GSS_Subscription_Detail__r.Calendar_Semi_Monthly_First_Option__c
								, Calendar_Semi_Monthly_Second_Option__c = filedelivered.GSS_Subscription_Detail__r.Calendar_Semi_Monthly_Second_Option__c
								, Calendar_Weekly_Option__c = filedelivered.GSS_Subscription_Detail__r.Calendar_Weekly_Option__c
								, Calendar_Monthly_Option__c = filedelivered.GSS_Subscription_Detail__r.Calendar_Monthly_Option__c
								//, Calendar_New_Submission_Effective_Date__c
								//, Calendar_Next_Submission_Date__c = filedelivered.GSS_Subscription_Detail__r.Calendar_Next_Submission_Date__c
							);
							deliveredSubDetIdToObjectMap.put(deliveredSubscription.Id, deliveredSubscription);
							// Frequency is based on the original File_Description, not its Master file (which might be referred by the fileDelivered).
							deliveredSubDetIdToFrequencyMap.put(deliveredSubscription.Id, fileDelivered.GSS_Subscription_Detail__r.GDP_File_Description__r.Frequency__c);
						} // end if GSS_Subscription_Detail exists

						// preparation for setting Master_File_Delivery and Next_Master_File_Delivery__c:
						if (filedelivered.GSS_Subscription_Detail__r.GDP_File_Description__r.Master_File_Description__c==null) continue;
						if (filedelivered.File_Specification__c!=filedelivered.GSS_Subscription_Detail__r.GDP_File_Description__r.Master_File_Description__c) continue;
						SubscriptionDetailIds.add(filedelivered.GSS_Subscription_Detail__c);
					}

					/*
					// Note: the following update on SubscriptionDetailList is merged into updateGssSubscriptionDetail
					// considering this Master_File_Delivery__c does not any other info.
					SubscriptionDetailList = [SELECT Id
													,Master_File_Delivery__c
													,Next_Master_File_Delivery__c
												FROM GSS_Subscription_Detail__c
												WHERE Id=:SubscriptionDetailIds];
					for(GSS_Subscription_Detail__c filedetail:SubscriptionDetailList)   {
						filedetail.Master_File_Delivery__c = Date.Today();
						filedetail.Next_Master_File_Delivery__c = Date.Today().addMonths(12);
					}
					*/

					// build subscriptionId to Notification mapping based inserted GDP_File_Delivery
					Map<Id, Notification>  subIdToNotificationMap = new Map<Id, Notification>(); // map SubscriptionId to Notification
					for(GDP_File_Delivery__c filedelivered:fdList)
					{
						 filedelivered.Notification__c='0'; // Do Not Notify
						 filedelivered.Technical_Contact_Email__c='';
						 filedelivered.List_of_files_delivered__c='';
						 filedelivered.Quantity_of_file_in_delivery__c=0;
						 filedelivered.Technical_Contact_Name__c='';

						 Notification newNotification = new Notification();
						 if (!subIdToNotificationMap.ContainsKey(filedelivered.Subscription__c)){
							 newNotification.NumberOfFile = 0;
							 newNotification.ListOfFileDelivered='';
							 newNotification.ContactEmail='';
							 if (filedelivered.GSS_Subscription_Detail__r.FileRecipientEmail__c!=null) newNotification.ContactEmail=filedelivered.GSS_Subscription_Detail__r.FileRecipientEmail__c;
							 newNotification.ContactName='';
							 if (filedelivered.GSS_Subscription_Detail__r.FileRecipientFirstName__c!=null) newNotification.ContactName =filedelivered.GSS_Subscription_Detail__r.FileRecipientFirstName__c;
							 if (filedelivered.GSS_Subscription_Detail__r.FileRecipientLastName__c !=null) newNotification.ContactName +=' '+filedelivered.GSS_Subscription_Detail__r.FileRecipientLastName__c;
							 newNotification.FileDeliveryId=filedelivered.Id;
						 } else {
							 newNotification=subIdToNotificationMap.Get(filedelivered.Subscription__c);
						 } // end if

						 newNotification.NumberOfFile = newNotification.NumberOfFile + 1;
						 String linefeed ='';
						 if (newNotification.NumberOfFile>1) linefeed = '\n';
						 newNotification.ListOfFileDelivered += linefeed + ' - '+ filedelivered.File_Name__c + ': ' + filedelivered.File_Specification__r.Description__c;

						 subIdToNotificationMap.put(filedelivered.Subscription__c, newNotification);
					} // end for

					// Only one GDP_File_Delivery record per Zuora_Subscription that will trigger the notification
					for(GDP_File_Delivery__c filedelivered:fdList)
					{
						 if (subIdToNotificationMap.ContainsKey(filedelivered.Subscription__c)){
							 Notification newNotification = new Notification();
							 newNotification=subIdToNotificationMap.Get(filedelivered.Subscription__c);

							 if (newNotification.FileDeliveryId==filedelivered.Id)
							 { // this is the specific GDP_File_Delivery record that responsible for triggering email
								 filedelivered.Notification__c='1'; // Notify client by email
								 filedelivered.Quantity_of_file_in_delivery__c = newNotification.NumberOfFile;
								 filedelivered.List_of_files_delivered__c  = newNotification.ListOfFileDelivered;
								 filedelivered.Technical_Contact_Email__c=newNotification.ContactEmail;
								 filedelivered.Technical_Contact_Name__c =newNotification.ContactName;
							 }
						 }
					} // end for

					updateConfirmation(fdList);

					if (deliveredSubDetIdToObjectMap.size()>0) {
						updateGssSubscriptionDetail(deliveredSubDetIdToObjectMap, deliveredSubDetIdToFrequencyMap, SubscriptionDetailIds);
					}
				}
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
		} // end catch
	} // end postConfirmationFileDelivery


	// ========================================================================
	// this updateConfirmation update GDP_File_Delivery as much as it can
	private static void updateConfirmation(List<GDP_File_Delivery__c> fdList
						//, Map<Id,GSS_Subscription_Detail__c> fdIdToSubscriptionDetailObjectMap
						)
	{
		// update GDP_File_Delivery list
		Database.SaveResult[] result = Database.update(fdList, false);
		// for the time being, error on updating will only be reported in salesforce log
		if (result!=null)
		{
			Integer idx = 0;
			for (Database.Saveresult sr : result)
			{
				if (sr.isSuccess()==false)
				{
					// fdIdToSubscriptionDetailObjectMap.remove(fdList[idx]); //
					System.debug( 'error saving ['+idx+']=' + fdList[idx]
						+ ': error: ' + sr.getErrors() );
				}
				idx++;
			}
		}
	} // end of updateConfirmation


	// ========================================================================
	// this is to update GSS_Subscription_Detail after successful delivery.
	// The fields Calendar_Next_Submission_Date__c & Calendar_New_Submission_Effective_Date are corrected here.
	// In addition, update related to Master_File_Delivery and Next_Master_File_Delivery fields is executed here
	// masterRelatedGssSubDetIdSet: set of GSS_Subscription_Detail.Id of those delta subscription receiving master file today
	private static void updateGssSubscriptionDetail(Map<Id,GSS_Subscription_Detail__c> deliveredGssSubDetIdToObjectMap
			, Map<Id,String> deliveredGssSubDetIdToFrequencyMap
			, Set<Id> masterRelatedGssSubDetIdSet
		)
	{
		// first part, update related to the delta subscription and their Master_File_Delivery and Next_Master_File_Delivery.
		// this is done when today is the master file is delivered
		for (Id subDetId : masterRelatedGssSubDetIdSet)
		{
			GSS_Subscription_Detail__c deliveredSubDet = deliveredGssSubDetIdToObjectMap.get(subDetId);
			// this should give non null values, but just in case
			if (deliveredSubDet != null) {
				deliveredSubDet.Master_File_Delivery__c = Date.today();
				deliveredSubDet.Next_Master_File_Delivery__c = Date.today().addMonths(12);
			}
		} // end for

		// second part: set delivery date
		// given a collection of GSS_Subscription_Detail and related frequency,
		// set the values for Calendar_Next_Submission_Date__c and Calendar_New_Submission_Effective_Date
		// req input fields: Calendar_*_Option, frequency
		Date nextDay = Date.today().addDays(1);
		for ( GSS_Subscription_Detail__c subDet : deliveredGssSubDetIdToObjectMap.values())
		{
			subDet.Calendar_New_Submission_Effective_Date__c = null;
			subDet.Calendar_Next_Submission_Date__c = trgHndlrIECgssSubscriptionDetail.calculateCalendarNextSubmissionDate(subDet
					, deliveredGssSubDetIdToFrequencyMap.get(subDet.Id)
					, nextDay);
		} // end for deliveredSubDetIdToObjectMap

		// we try to update those it can, instead of doing all or nothing update.
		// update deliveredSubDetIdToObjectMap.values();
		Database.SaveResult[] result = Database.update(deliveredGssSubDetIdToObjectMap.values(), false);
		// for the time being, error on updating will only be reported in salesforce log
		if (result!=null)
		{
			Integer idx = 0;
			for (Database.Saveresult sr : result)
			{
				if (sr.isSuccess()==false)
				{
					// fdIdToSubscriptionDetailObjectMap.remove(fdList[idx]); //
					System.debug( 'error saving ['+idx+']=' + deliveredGssSubDetIdToObjectMap.values()[idx]
						+ ': error: ' + sr.getErrors() );
				}
				idx++;
			}
		}

	} // updateGssSubscriptionDetail



	//Request class format in JSON
	/*
	* Example Json request to be sent in HTTP Body:
	*
	[{"SubscriptionId":"a1Rg0000000kcQHEAY","Status":"Completed","SubscriptionDetailId":"a1Qg0000001zMgcEAE","FileSpecificationId":"a50g0000000DYu4AAG","FileDeliveryId":"a0Mg0000005YimHEAS","FailureMessage":"This is a to do delivery example"},{"SubscriptionId":"a1Rg0000000kcQHEAY","Status":"BogusStatus","SubscriptionDetailId":"a1Qg0000001zMgcEAE","FileSpecificationId":"a50g0000000DYu4AAG","FileDeliveryId":"","FailureMessage":"This is a to do delivery example"}]
	*
	*/
	global class DeliveryConfirmation {
		public string SubscriptionId {get;set;}
		public string FileSpecificationId {get;set;}
		public string SubscriptionDetailId {get;set;}
		public string FailureMessage {get;set;}
		public string Status {get;set;}
		public string FileDeliveryId {get;set;}
		public string FileName {get;set;}
		public string FileSize {get;set;}

		public decimal FileSizeNumber {
			get { // return the file size in  decimal
				decimal result = null;
				try {
					string fs = FileSize.trim();
					result = Decimal.valueOf(fs);
				} catch (Exception ex) {
					// in case error in conversion, keep it as null.
					result = null;//
				}
				return result;
			}
			private set;
		}

		//Constructor
		public DeliveryConfirmation(){
			this.SubscriptionId = '';
			this.FileSpecificationId = '';
			this.SubscriptionDetailId = '';
			this.FailureMessage = '';
			this.Status = '';
			this.FileDeliveryId = '';
			this.FileSize = '';
			this.FileName = '';
		}
	}

	//Response class format in JSON
	global class ReturnId {
		public string id {get;set;}
		//Constructor
		public ReturnId(string id){
			this.id = id;
		}
	}

	// notification class is used to store information before putting updating GDP_File_Delivery
	global class Notification
	{
		public String ListOfFileDelivered {get;set;}
		public Integer NumberOfFile {get;set;}
		public String ContactEmail {get;set;}
		public String ContactName {get;set;}
		public Id FileDeliveryId {get;set;}
		public Notification()
		{}
	}
	//Custom Exception Class
	public class MyException extends Exception {}

}
