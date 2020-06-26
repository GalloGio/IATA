public without sharing class CW_CreateFacilityController {
	@AuraEnabled
	public static string createFacility(String accountId, String station, String logoInfo, String ardRelIds, String nearestAirportCode, Boolean isCompanyAdmin, Boolean isInternalUser, Boolean isNewAccount, String stationsToAdd, String stationsToRemove) {
		CW_Utilities.ResponseBody res = new CW_Utilities.ResponseBody();
		Savepoint sp = null;
		try {
			LogoInfo facilityLogo;
			//If logo exists and is not {} nor null
			if (logoInfo != null && logoInfo.length() > 4)
				facilityLogo = (LogoInfo) JSON.deserialize(logoInfo, LogoInfo.class);
			ICG_Account_Role_Detail__c ard = (ICG_Account_Role_Detail__c) JSON.deserialize(station, ICG_Account_Role_Detail__c.class);
			List<Account_Role__c> aroles = [SELECT id FROM Account_Role__c WHERE Account__c = :accountId AND Functional_Role__c = :'One Source'];
			if (aroles.size() < 1) {
				try {
					Account_Role__c ar = createOneSourceAccRole(accountId);
					insert ar;
					ard.Account_Role__c = ar.Id;
				} catch (Exception ex) {
					res.success = false;
					res.message = 'This account has no available Role to be parent of a station';
					return JSON.serialize(res);
				}
			} else {
				ard.Account_Role__c = aroles[0].id;
			}
			if(nearestAirportCode != null && nearestAirportCode != ''){
				List<Airport_Detail__c> airportDetail = [Select Id from Airport_Detail__c where Code__c =:nearestAirportCode];
				if (!airportDetail.isEmpty()) ard.Nearest_Airport__c = airportDetail[0].Id;
			}
			if (!Test.isRunningTest())
				sp = Database.setSavepoint();

			insert ard;
			if (facilityLogo != null) {
				ContentVersion conVer = new ContentVersion();
				conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
				conVer.PathOnClient = facilityLogo.fileName; // The files name, extension is very important here which will help the file in preview.
				conVer.Title = facilityLogo.fileName; // Display name of the files
				conVer.VersionData = EncodingUtil.base64Decode(facilityLogo.base64Data); // converting your binary string to Blog
				conVer.Is_Company_Logo__c = true;
				insert conVer;
				// First get the content document Id from ContentVersion
				Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conVer.Id].ContentDocumentId;

				//Create ContentDocumentLink
				ContentDocumentLink cDe = new ContentDocumentLink();
				cDe.ContentDocumentId = conDoc;
				cDe.LinkedEntityId = ard.Id; // you can use objectId,GroupId etc
				cDe.ShareType = 'I';
				cDe.Visibility = 'AllUsers';
				insert cDe;

				String URL_Base = ISSP_CS__c.getValues('ICG_URL_Base').Value__c;
				ard.logoUrl__c = URL_Base.removeEnd('/s/') + '/sfc/servlet.shepherd/document/download/' + conDoc;
				update ard;
			}
			if (!String.isBlank(ardRelIds)) {
				List<ICG_Account_Role_Detail_Relationship__c> ardrelationship = new List<ICG_Account_Role_Detail_Relationship__c>();
				for (String airId : ardRelIds.split(';')) {
					//Handled airline points to Account, ICG ARD points to Account Role Detail.
					ardrelationship.add(new ICG_Account_Role_Detail_Relationship__c(ICG_Account_Role_Detail__c = ard.id, Handled_Airline__c = airId.startsWith('001') ? airId : null));
				}
				if (!ardrelationship.isEmpty())
					insert ardrelationship;
			}

			CW_HandledAirlinesController.saveAirlinesHandled(stationsToAdd, stationsToRemove, ard.Id);
			
			if(ard.Id != null && isInternalUser != true){
				ICG_Account_Role_Detail__c createdArd = [Select id, Status__c,CreatedById, CreatedBy.Email, CreatedBy.ContactId, CreatedBy.Contact.Email from ICG_Account_Role_Detail__c where id = :ard.Id];
				String whoId = createdArd.CreatedBy.ContactId != null ? createdArd.CreatedBy.ContactId : createdArd.CreatedById;
				String templateName;
				Boolean updateArd = false;

				//Send email to approvers
				List<String> whoEmails = new List<String>();
				List<String> contactIds = new List<String>();
				for(Contact c : CW_Utilities.getCompanyadminContactsFromAccountId(accountId)){
					if(c.email != null) whoEmails.add(c.email);
					contactIds.add(c.Id);
				}
				if(whoEmails.isEmpty() || isCompanyAdmin == true){
					whoEmails = new List<String>();
					templateName = 'Approve_Reject_to_IATA_Admin_no_Comp_adm';
					for(User u : CW_Utilities.getIATAStakeHoldersUsersList()){
						if(u.email != null) whoEmails.add(u.email);
					}
					createdArd.Status__c = 'Pending for IATA Approval';
					updateArd = true;
				}else{
					templateName = 'Approve_Reject_to_company_admin';
				}
				Boolean submitted = !whoEmails.isEmpty() ? CW_Utilities.sendEmailTemplate(templateName, ard.Id, whoId, whoEmails) : false;

				List<ICG_Notification__c> notifications = new List<ICG_Notification__c>();

				String subject = 'New Station is pending approval';
				String body = subject;
				notifications.addAll(CW_NotificationsController.setNotificationCustom(subject, body, 'Requested', contactIds, ard, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA, false));
				if (submitted) {
					res.success = true;
					res.message = 'Your request has been submitted and is pending for approval from your Company Admin / IATA. You will receive a confirmation once your request has been processed.';
				} else {
					res.success = false;
					res.message = 'Something went wrong. Please contact IATA. Comment: Approval Process not triggered';
					if (sp != null && !Test.isRunningTest())
						Database.rollback(sp);
				}

				//Send email to requestor
				String whoEmail = createdArd.CreatedBy.ContactId != null ? createdArd.CreatedBy.Contact.Email : createdArd.CreatedBy.Email;
				templateName = isNewAccount == true ? 'Station_Creation_Req_Conf_Req_new_acc' : 'Station_Creation_Req_Conf_to_Requestor';
				CW_Utilities.sendEmailTemplate(templateName, ard.Id, whoId, new List<String> {whoEmail});
				notifications.addAll(CW_NotificationsController.setNotificationCustom(subject, body, 'Requested', new List<String> {createdArd.CreatedBy.ContactId}, ard, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA,false));

				if(updateArd == true) update createdArd;

				if(notifications.size() > 0){
					insert notifications;
				}

			}else if(ard.Id != null){
				res.success = true;
			}
			
		} catch (Exception ex) {
			if (sp != null && !Test.isRunningTest())
				Database.rollback(sp);
			res.success = false;
			res.message = ex.getMessage();
		}
		return JSON.serialize(res);
	}

	@AuraEnabled
	public static string createDummyCompany(String account, String opsHierarchy) {
		CW_Utilities.ResponseBody res = new CW_Utilities.ResponseBody();
		Savepoint sp = null;
		try {
			if (!Test.isRunningTest()) sp = Database.setSavepoint();
			
			Account acc = (Account) JSON.deserialize(account, Account.class);
			acc.Reason_for_creation__c = 'Created by customer';
			acc.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account','Standard_Account');
			insert acc;

			Account_Role__c ar = createOneSourceAccRole(acc.Id);
			insert ar;

			//Create Ops Hierarchy
			if(opsHierarchy != null && opsHierarchy != ''){
				List<Account_Role_Relationship__c> arrs = [Select id, From__c, To__c, Relationship_Name__c, Ops_Hierarchy_Group__c from Account_Role_Relationship__c Where Relationship_Name__c =:opsHierarchy OR Ops_Hierarchy_Group__c =:opsHierarchy];
				if(!arrs.isEmpty()){
					Account_Role_Relationship__c parentArr;
					Boolean existsOpsGroupName = false;
					for(Account_Role_Relationship__c arr : arrs){
						if (arr.Relationship_Name__c == opsHierarchy) parentArr = arr;
						if(arr.Ops_Hierarchy_Group__c == opsHierarchy) existsOpsGroupName = true;
					}
					if(parentArr != null){
						Account_Role_Relationship__c newArr = new Account_Role_Relationship__c();
						newArr.From__c = ar.Id;
						newArr.To__c = parentArr.From__c;
						newArr.Ops_Hierarchy_Group__c = parentArr.Ops_Hierarchy_Group__c;
						insert newArr;
					}else if(existsOpsGroupName){
						Account_Role_Relationship__c newArr = new Account_Role_Relationship__c();
						newArr.From__c = ar.Id;
						newArr.Ops_Hierarchy_Group__c = opsHierarchy;
						insert newArr;
					}
				}
			}
			res.success = true;
			res.message = acc.id;
		} catch (Exception ex) {
			if (sp != null && !Test.isRunningTest())
				Database.rollback(sp);
			res.success = false;
			res.message = ex.getMessage();
		}
		return JSON.serialize(res);
	}

	@AuraEnabled
	public static Map<String, Object> updateFacility(String jsonInput, String logoInfo) {
		
		Map<String, Object> returnValue = new Map<String, Object>();

		try {
			LogoInfo facilityLogo;
			if (logoInfo != null && logoInfo.length() > 4){
				facilityLogo = (LogoInfo) JSON.deserialize(logoInfo, LogoInfo.class);
			}
			
			ICG_Account_Role_Detail__c facilityToUpdate =(ICG_Account_Role_Detail__c) JSON.deserialize(jsonInput,ICG_Account_Role_Detail__c.class);
			update facilityToUpdate;

			if (facilityLogo != null) {
				ContentVersion conVer = new ContentVersion();
				conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
				conVer.PathOnClient = facilityLogo.fileName; // The files name, extension is very important here which will help the file in preview.
				conVer.Title = facilityLogo.fileName; // Display name of the files
				conVer.VersionData = EncodingUtil.base64Decode(facilityLogo.base64Data); // converting your binary string to Blog
				conVer.Is_Company_Logo__c = true;
				insert conVer;
				// First get the content document Id from ContentVersion
				Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conVer.Id].ContentDocumentId;

				//Create ContentDocumentLink
				ContentDocumentLink cDe = new ContentDocumentLink();
				cDe.ContentDocumentId = conDoc;
				cDe.LinkedEntityId = facilityToUpdate.Id; // you can use objectId,GroupId etc
				cDe.ShareType = 'I';
				cDe.Visibility = 'AllUsers';
				insert cDe;

				String URL_Base = ISSP_CS__c.getValues('ICG_URL_Base').Value__c;
				facilityToUpdate.logoUrl__c = URL_Base.removeEnd('/s/') + '/sfc/servlet.shepherd/document/download/' + conDoc;
				update facilityToUpdate;
			}



			returnValue.put('result', new Map<String, String>{ 'status' => 'OK' });
		} catch (Exception e) {
			returnValue.put('result', new Map<String, String>{ 'status' => 'error' });
			returnValue.put('exception', new Map<String, String>{ 'message' => e.getMessage(), 'trace' => e.getStackTraceString() });
		}
		return returnValue;
	}

	@AuraEnabled
	public static void updateAccountCoordinates(String accId, Double latitude, Double longitude){
		Account acc = new Account(
			Id = accId,
			Business_Geo_Coordinates__Latitude__s = latitude,
			Business_Geo_Coordinates__Longitude__s = longitude
		);
		update acc;
	}

	private static Account_Role__c createOneSourceAccRole(Id accountId){
		Account_Role__c ar = new Account_Role__c();
		ar.Account__c = accountId;
		ar.Account_Role_Name__c = 'One Source';
		ar.Functional_Role__c = 'One Source';
		ar.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c','Master');
		return ar;
	}

	@AuraEnabled
	public static string getOnAirportStations(String rtype, String accountName, String airportId, String accountId){
		List<ICG_Account_Role_Detail_Relationship__c> operatingStations = new List<ICG_Account_Role_Detail_Relationship__c>();
		List<ICG_Account_Role_Detail__c> onAirportStations = new List<ICG_Account_Role_Detail__c>();
		if(accountId != null){
			Account acc = [Select id, Name, ICAO_designator__c, Airline_designator__c, IATACode__c FROM Account where id = :accountId];
			operatingStations.addAll([SELECT Id, Handled_Airline__c, Handled_Airline__r.IATACode__c, Handled_Airline__r.Name, Handled_Airline__r.Airline_designator__c, Handled_Airline__r.ICAO_designator__c, ICG_Account_Role_Detail__c,ICG_Account_Role_Detail__r.Name, ICG_Account_Role_Detail__r.RecordType.DeveloperName FROM ICG_Account_Role_Detail_Relationship__c 
			WHERE ICG_Account_Role_Detail__r.Nearest_Airport__r.Code__c =:airportId AND ((Handled_Airline__r.Airline_designator__c != null AND Handled_Airline__r.Airline_designator__c =:acc.Airline_designator__c) 
			OR (Handled_Airline__r.ICAO_designator__c != null AND Handled_Airline__r.ICAO_designator__c = :acc.ICAO_designator__c) OR (Handled_Airline__r.IATACode__c  != null AND Handled_Airline__r.IATACode__c = :acc.IATACode__c) OR Handled_Airline__c =:accountId)]);
		}else{
			operatingStations.addAll([SELECT Id, Handled_Airline__c, Handled_Airline__r.IATACode__c, Handled_Airline__r.Name, Handled_Airline__r.Airline_designator__c, Handled_Airline__r.ICAO_designator__c, ICG_Account_Role_Detail__r.Name, ICG_Account_Role_Detail__c,ICG_Account_Role_Detail__r.RecordType.DeveloperName FROM ICG_Account_Role_Detail_Relationship__c WHERE ICG_Account_Role_Detail__r.Nearest_Airport__r.Code__c =:airportId AND (Handled_Airline__r.Name = :accountName)]);
		}
		onAirportStations.addAll([SELECT id, Name, RecordType.DeveloperName, Nearest_Airport__c FROM ICG_Account_Role_Detail__c WHERE Is_On_Airport__c = true AND Nearest_Airport__r.Code__c = :airportId]);


		List<CW_SearchEngine.HandledElement> onAirportStationsElements = new List<CW_SearchEngine.HandledElement>();
		if (onAirportStations.size() > 0) {
			for (ICG_Account_Role_Detail__c ard : onAirportStations) {
				//If the onairport station is in the same airport as facility, then add.
				Boolean selected =  false;
				if(rtype == 'Airline'){
					for (ICG_Account_Role_Detail_Relationship__c ardr : operatingStations) {
						//If the handled airline is the facility company airline and it's in the same airport, then add.
						if (ard.Id == ardr.ICG_Account_Role_Detail__c){
							selected  = true;
						}
					}
				}else{
					selected = true;
				}
				CW_SearchEngine.HandledElement airlineHandled = new CW_SearchEngine.HandledElement();
				airlineHandled.selected = selected;
				airlineHandled.value = ard.Id;
				airlineHandled.label = ard.Name;
				airlineHandled.recordTypeDevName = ard.RecordType.Developername;
				onAirportStationsElements.add(airlineHandled);
					
			}
		}
		return JSON.serialize(onAirportStationsElements);
	}


	public class LogoInfo {
		public String fileName;
		public String base64Data;
		public String contentType;
	}
}