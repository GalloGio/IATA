/**
 * @description		Execute the process to obtain data of Remote Validations stored in S3 Amazons
 */
public without sharing class CW_GxA_Integration_Queueable implements Queueable, Database.AllowsCallouts {
	private List<Id> orderIdsToProcess;

	public List<Id> assignmentsGroupIdsToProcess = new List<Id>();

	/**
	 * @param			orderIds <List<Id> ids of ICG_Capability_Assignment_Group__c to be processed>
	 */
	public CW_GxA_Integration_Queueable(List<Id> orderIds) {
		orderIdsToProcess = orderIds;
	}

	public void execute(QueueableContext context) {
		if (orderIdsToProcess == null || orderIdsToProcess.size() == 0) {
			return;
		}

		ICG_GxA_Integration_Settings__c gxaSettings = ICG_GxA_Integration_Settings__c.getOrgDefaults();
		Id remoteValidationRtId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');

		// Get the order product data linked to remote validation
		Map<Id, String> orderNumberByOrderId = new Map<Id, String>();
		Map<Id, Id> orderProductByOrderId = new Map<Id, Id>();
		Map<Id, ICG_Account_Role_Detail__c> stationByOrderId = new Map<Id, ICG_Account_Role_Detail__c>();
		for (Order currentOrder : [SELECT Id, OrderNumber, (SELECT Id, Station__c, Station__r.Global_ID__c FROM OrderItems WHERE Station__c != null AND Product2.Smart_Facility_Remote_Validation__c = true) FROM Order WHERE Id IN :orderIdsToProcess]) {
			orderNumberByOrderId.put(currentOrder.Id, currentOrder.OrderNumber);

			if (!currentOrder.OrderItems.isEmpty()) {
				orderProductByOrderId.put(currentOrder.Id, currentOrder.OrderItems[0].Id);
				stationByOrderId.put(currentOrder.Id, currentOrder.OrderItems[0].Station__r);
			}
		}

		// Create ICG_Capability_Assignment_Group__c
		List<ICG_Capability_Assignment_Group__c> assignmentGroups = new List<ICG_Capability_Assignment_Group__c>();
		for (Id currentOrderId : orderIdsToProcess) {
			// If Folder_Test__c is defined, we use this value as folder
			String folder = gxaSettings.Folder_Test__c;
			if (String.isBlank(folder)) {
				if (stationByOrderId.containsKey(currentOrderId)) {
					// Amazon S3 folder pattern ## ICG_Account_Role_Detail__c.Global_ID__c - Order.OrderNumber ## 0010000520501-08888899
					folder = String.format('{0}-{1}', new List<String>{ stationByOrderId.get(currentOrderId).Global_ID__c, orderNumberByOrderId.get(currentOrderId) });
				}
			}
			String objectKey = gxaSettings.Base_Path__c + folder + '/' + gxaSettings.Index_File__c;

			ICG_Capability_Assignment_Group__c assignmentToAdd = new ICG_Capability_Assignment_Group__c(RecordTypeId = remoteValidationRtId, GxA_Integration_Status__c = CW_GxA_Handler.GXA_STATUS_IN_PROGRESS, GxA_Object_Key__c = objectKey, GxA_Form_Submited_Date__c = Date.today(), Expiration_Date__c = Date.today(), Issue_Date__c = Date.today());
			if (orderProductByOrderId.containsKey(currentOrderId)) {
				assignmentToAdd.Order_Product__c = orderProductByOrderId.get(currentOrderId);
			}
			if (stationByOrderId.containsKey(currentOrderId)) {
				assignmentToAdd.ICG_Account_Role_Detail__c = stationByOrderId.get(currentOrderId).Id;
			}

			try {
							
				HttpResponse response;
				
				if(Test.isRunningTest()){
					CW_AmazonMockHttpResponseGenerator mockHttp = new CW_AmazonMockHttpResponseGenerator('IntegrationQueuable', 'OK');
					response = mockHttp.respond(new HttpRequest());
				}else{
					response = CW_AmazonS3Connector.awsS3GetObject(objectKey, gxaSettings.Named_Credential__C);
				}

				if (response.getStatusCode() == 200) {
					CW_GxA_Wrappers.Index currentResultObject = CW_GxA_Wrappers.parseIndex(response.getBody());
					assignmentToAdd.GxA_Result_Json__c = Json.serialize(currentResultObject);

					DateTime submittedDate = (Datetime) JSON.deserialize('"' + currentResultObject.SubmittedDate + '"', Datetime.class);
					assignmentToAdd.GxA_Form_Submited_Date__c = SubmittedDate.date();
					assignmentToAdd.Expiration_Date__c = SubmittedDate.addYears(1).date();
					assignmentToAdd.Issue_Date__c = SubmittedDate.date();
				} else {
					assignmentToAdd.GxA_Integration_Status__c = CW_GxA_Handler.GXA_STATUS_FAILED;
					assignmentToAdd.GxA_Error_Message__c = response.getStatusCode() + ' - ' + response.getStatus();
					assignmentToAdd.GxA_Error_StackTrace__c = response.getBody();
				}
			} catch (Exception ex) {
				assignmentToAdd.GxA_Integration_Status__c = CW_GxA_Handler.GXA_STATUS_FAILED;
				assignmentToAdd.GxA_Error_Message__c = ex.getMessage();
				assignmentToAdd.GxA_Error_StackTrace__c = ex.getStackTraceString();
			}

			assignmentGroups.add(assignmentToAdd);
		}

		List<Database.SaveResult> results = Database.insert(assignmentGroups, false);
		List<Id> assignmentIds = new List<Id>();
		for (ICG_Capability_Assignment_Group__c currentAssignmentGroup : assignmentGroups) {
			if (currentAssignmentGroup.Id != null) {
				assignmentIds.add(currentAssignmentGroup.Id);
			}
		}
		if (!assignmentIds.isEmpty()) {
			Database.executeBatch(new CW_GxA_Integration_Batch(assignmentIds), 1);
		}
	}
}