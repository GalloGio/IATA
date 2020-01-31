global class ISSP_WS_Create_NonTD_Reports {


	global class ResponseOne {
		WebService Boolean isSuccess;
		WebService String responseErrorCode;
		WebService String responseErrorMessage;
	}

	global class inputData {
		// requesting system
		WebService String requestingSystem;
		// contact segmentation inputs
		WebService String iataCode;
		WebService Blob InboundFile;
		WebService String InboundFileName;

	}

	WebService static ResponseOne createNonTDReport (inputData inputMessage) {
		ResponseOne retResponse = new ResponseOne();
		retResponse.isSuccess = true;

		// Create log object record
		ISSP_Web_Service_Log__c newLog = new ISSP_Web_Service_Log__c();
		newLog.Success__c = true;
		newLog.Web_Service__c = 'ISSP_WS_Create_NonTD_Reports';
		newLog.Method__c = 'createNonTDReport';
		newLog.System__c = inputMessage.requestingSystem;
		String errorCode = '';
		String errorMessage = '';

		// log inputs
		String description = 'User Id: ' + UserInfo.getUsername() + '\n';
		description = description + 'Requesting System: ' + inputMessage.requestingSystem + '\n';
		description = description + 'IATA Code: ' + inputMessage.iataCode + '\n';

		newLog.Input_Description__c = description;

		if (inputMessage.iataCode == '' ||  inputMessage.iataCode == null){
			errorCode = 'A001';
			errorMessage = ISSP_Int_Error__c.getValues('A001').Error_Message__c;

			retResponse.isSuccess = false;
			retResponse.responseErrorCode = errorCode;
			retResponse.responseErrorMessage = errorMessage;
			system.debug('ERROR: A001');

			//insert log record
			newLog.Success__c = false;
			newLog.Error_Code__c = errorCode;
			newLog.Error_Message__c = errorMessage;
			newLog.Finished__c = system.now();
			insert newLog;

			return retResponse;
		}

		//////////////////////////////////////////////////
		list<Account> accList = [select Id,IATACode__c from Account where IATACode__c =: inputMessage.iataCode And RecordType.Name = 'Airline Headquarters'];
		if (!accList.isEmpty()){

			if (inputMessage.InboundFileName == '' || inputMessage.InboundFileName == null){
				errorCode = 'B001';
				errorMessage = ISSP_Int_Error__c.getValues('B001').Error_Message__c;

				retResponse.isSuccess = false;
				retResponse.responseErrorCode = errorCode;
				retResponse.responseErrorMessage = errorMessage;
				system.debug('ERROR: B001');

				//insert log record
				newLog.Success__c = false;
				newLog.Error_Code__c = errorCode;
				newLog.Error_Message__c = errorMessage;
				newLog.Finished__c = system.now();
				insert newLog;

				return retResponse;
			}

			if (inputMessage.InboundFile.size() == 0){
				errorCode = 'B002';
				errorMessage = ISSP_Int_Error__c.getValues('B002').Error_Message__c;

				retResponse.isSuccess = false;
				retResponse.responseErrorCode = errorCode;
				retResponse.responseErrorMessage = errorMessage;
				system.debug('ERROR: B002');

				//insert log record
				newLog.Success__c = false;
				newLog.Error_Code__c = errorCode;
				newLog.Error_Message__c = errorMessage;
				newLog.Finished__c = system.now();
				insert newLog;

				return retResponse;
			}

			//Create new NonTD Report
			ID inboundAccountID = accList[0].ID ;
			ISSP_NonTD_Report__c newReport = new ISSP_NonTD_Report__c(Posted_Date__c = System.Today() , Account__c = inboundAccountID);
			try{
				insert newReport;

	 			//Create Attachment ,Assign it to new Report
				Attachment newAttach = new Attachment();
				newAttach.ParentId = newReport.Id;
				newAttach.Body = inputMessage.InboundFile;
				newAttach.Name = inputMessage.InboundFileName;
				insert newAttach;
			}
			catch (Exception e){
				errorCode = 'A099';
				errorMessage = ISSP_Int_Error__c.getValues('B002').Error_Message__c + e;

				retResponse.isSuccess = false;
				retResponse.responseErrorCode = errorCode;
				retResponse.responseErrorMessage = errorMessage;
				system.debug('ERROR: A099');

				//insert log record
				newLog.Success__c = false;
				newLog.Error_Code__c = errorCode;
				newLog.Error_Message__c = errorMessage;
				newLog.Finished__c = system.now();
				insert newLog;

				return retResponse;
			}

			//Handling sharing settings for Contacts related to the givin Account
			List<Contact> SharingContacts_List = new List<Contact>([select Id , Name , AccountID From Contact Where AccountId =: inboundAccountID OR Account.Top_Parent__c = :inboundAccountID]);

			if (SharingContacts_List != null && !SharingContacts_List.isEmpty()){

				Set<Id> ContactIDs_set = new Set<Id>();
				Set <Id> contactIds_haveAccess = new Set <Id>();
				for (Contact con : SharingContacts_List)
				{
					ContactIDs_set.add(con.id);
				}

				//send notification to NonTD Report subscribers
				List <Portal_Application_Right__c> accessList = [SELECT Id, Contact__c FROM Portal_Application_Right__c
																	WHERE Portal_Application__r.Name LIKE 'Treasury Dashboard%'
																	AND Right__c = 'Access Granted'
																	AND Contact__c IN: ContactIDs_set];
				system.debug('ACCESS LIST: ' + accessList);
				if (!accessList.isEmpty()){
					for (Portal_Application_Right__c thisAccess : accessList){
						contactIds_haveAccess.add(thisAccess.Contact__c);
					}

					//Get all users related to contacts
					List<User> UserSharing_List = new List<User> ([SELECT ID,EMAIL FROM User WHERE contactid IN: contactIds_haveAccess]);

					//Create Public Group contains all the relevant Users as GroupMembers
					ISSP_NonTD_Report_Email_Inteface helperInterface = new ISSP_NonTD_Report_Email_Inteface();

					//give access to specific record to User or Group of Users
					helperInterface.setNonTDReportSharingSetting(UserSharing_List , newReport , 'Read');
				}
			}
		}
		else
		{
			errorCode = 'A001';
			errorMessage = ISSP_Int_Error__c.getValues('A001').Error_Message__c;

			retResponse.isSuccess = false;
			retResponse.responseErrorCode = errorCode;
			retResponse.responseErrorMessage = errorMessage;
			system.debug('ERROR: A001');

			//insert log record
			newLog.Success__c = false;
			newLog.Error_Code__c = errorCode;
			newLog.Error_Message__c = errorMessage;
			newLog.Finished__c = system.now();
			insert newLog;

			return retResponse;
		}

  		newLog.Finished__c = system.now();
		insert newLog;
		return retResponse;
	}
}
