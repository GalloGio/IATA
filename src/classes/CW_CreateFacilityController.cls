public without sharing class CW_CreateFacilityController {
	final static String ONESOURCE = 'One Source';
	final static String APPROVAL_IATA_AFTER_ADMIN_APPROVAL_NEW_ACCOUNT = 'Approval_IATA_After_appr_new_account';
	final static String APPROVE_REJECT_IATA_ADMIN_NO_COMPANY_ADMIN = 'Approve_Reject_to_IATA_Admin_no_Comp_adm';
	final static String APPROVE_REJECT_TO_COMPANY_ADMIN = 'Approve_Reject_to_company_admin';
	final static String STATION_CREATION_REQ_CONF_NEW_ACCOUNT = 'Station_Creation_Req_Conf_Req_new_acc';
	final static String STATION_CREATION_REQ_CONF_TO_REQUESTOR = 'Station_Creation_Req_Conf_to_Requestor';

	@AuraEnabled
	public static string createFacility(String accountId, String station, String logoInfo, String geoLocationInfo, String ardRelIds, String nearestAirportCode, Boolean isCompanyAdmin, Boolean isInternalUser, Boolean isNewAccount, String stationsToAdd, String stationsToRemove) {
		CW_Utilities.ResponseBody res = new CW_Utilities.ResponseBody();
		Savepoint sp;
		try {
			sp = CW_DBTransactionHandler.setSavepoint();
			
			ICG_Account_Role_Detail__c ard = (ICG_Account_Role_Detail__c) JSON.deserialize(station, ICG_Account_Role_Detail__c.class);			
			ard.Account_Role__c = CW_CreateFacilityController.getAccountRoleForAccount(accountId, false);
			if(ard.Account_Role__c == null) {
				res.success = false;
				res.message = 'This account has no available Role to be parent of a station';
				return JSON.serialize(res);
			}
			
			ard = CW_CreateFacilityController.handleGeoLocations(ard, geoLocationInfo);            
			ard.Nearest_Airport__c = CW_CreateFacilityController.getNearestAirportForFacility(nearestAirportCode);
			
			insert ard;

			Id conDoc = CW_CreateFacilityController.createFacilityLogo(logoInfo, ard.Id);
			if(conDoc != null){
				ard.logoUrl__c = CW_CreateFacilityController.generateLogoURL(conDoc);
			}

			List<Contact> companyAdmins = CW_Utilities.getCompanyAdminContactsFromAccountId(accountId);
			if(!isInternalUser && hasNoCompanyAdminsOrNotNeeded(companyAdmins, isCompanyAdmin)){
				ard.Status__c = 'Pending for IATA Approval';
			}

			update ard;

			CW_CreateFacilityController.createFacilityRelations(ardRelIds, ard.Id);

			CW_HandledAirlinesController.saveAirlinesHandled(stationsToAdd, stationsToRemove, ard.Id);

			res.success = true;

			Boolean addEmailFailureMessage = !CW_CreateFacilityController.handleEmailsAndNotifications(isInternalUser, ard, companyAdmins, isCompanyAdmin, isNewAccount);
			res.message = Label.icg_registration_request_submitted1 + ' ' + Label.icg_registration_request_submitted2;	

			if (addEmailFailureMessage == true) {
				res.message += ' ' + Label.icg_something_went_wrong_emails;
			}
			res.obj = ard;
		} catch (Exception ex) {
			CW_DBTransactionHandler.doRollback(sp);
			res.success = false;
			res.message = ex.getMessage();
		}
		return JSON.serialize(res);
	}

	private static Boolean hasNoCompanyAdminsOrNotNeeded(List<Contact> companyAdmins, Boolean isCompanyAdmin){
		return companyAdmins.isEmpty() || isCompanyAdmin == true;
	}

	private static Boolean handleEmailsAndNotifications(Boolean isInternalUser, ICG_Account_Role_Detail__c facility, List<Contact> companyAdmins, Boolean isCompanyAdmin, Boolean isNewAccount) {

		ICG_Account_Role_Detail__c createdArd = [Select id, Status__c,CreatedById, CreatedBy.Email, CreatedBy.ContactId, CreatedBy.Contact.Email, Account_Role__r.Account__r.RecordType.DeveloperName from ICG_Account_Role_Detail__c where id = :facility.Id];
		Set<Id> whoIdsRequestor = new Set<Id>();
		String whoId = createdArd.CreatedBy.ContactId != null ? createdArd.CreatedBy.ContactId : createdArd.CreatedById;
		whoIdsRequestor.add(whoId);
		String templateName;
		//If the user is company admin of station and status os "Pending for Approval", the status mut change and the approver/rejector will be the user
		Boolean accountAlreadyApproved = createdArd.Account_Role__r.Account__r.RecordType.DeveloperName != 'Standard_Account';

		//Send email to approvers
		Set<Id> whoIdsAdmins = new Set<Id>();
		List<String> contactIds = new List<String>();
		for(Contact c : companyAdmins){
			whoIdsAdmins.add(c.Id);
			contactIds.add(c.Id);
		}
		if(hasNoCompanyAdminsOrNotNeeded(companyAdmins, isCompanyAdmin)){
			whoIdsAdmins = CW_EmailManager.getIataAdminsIds();
			templateName = (isNewAccount || !accountAlreadyApproved) ? APPROVAL_IATA_AFTER_ADMIN_APPROVAL_NEW_ACCOUNT : APPROVE_REJECT_IATA_ADMIN_NO_COMPANY_ADMIN;
		}else{
			templateName = APPROVE_REJECT_TO_COMPANY_ADMIN;
		}

		List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
		List<ICG_Notification__c> notifications = new List<ICG_Notification__c>();

		if(!isInternalUser){
			emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails(templateName, facility.Id, whoIdsAdmins));
			templateName = (isNewAccount || !accountAlreadyApproved) ? STATION_CREATION_REQ_CONF_NEW_ACCOUNT : STATION_CREATION_REQ_CONF_TO_REQUESTOR;
			emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails(templateName, facility.Id, whoIdsRequestor));
		}

		String subject = 'Station Creation request submitted';
		String body = subject;
		contactIds.add(createdArd.CreatedBy.ContactId);
		notifications.addAll(CW_NotificationsController.setNotificationCustom(subject, body, 'Requested', contactIds, facility, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA, false));

		if(notifications.size() > 0){
			insert notifications;
		}

		return CW_EmailManager.sendInternalEmails(emailsToBeSent, true);
	}

	private static void createFacilityRelations(String ardRelIds, String facilityId) {
		if (!String.isBlank(ardRelIds)) {
			List<ICG_Account_Role_Detail_Relationship__c> ardrelationship = new List<ICG_Account_Role_Detail_Relationship__c>();
			for (String airId : ardRelIds.split(';')) {
				//Handled airline points to Account, ICG ARD points to Account Role Detail.
				if(String.isNotBlank(airId) && Id.valueOf(airId).getSobjectType() == Schema.Account.SObjectType) {
					ardrelationship.add(new ICG_Account_Role_Detail_Relationship__c(ICG_Account_Role_Detail__c = facilityId, Handled_Airline__c = airId));
				}
			}
			if (!ardrelationship.isEmpty()) {
				insert ardrelationship;
			}
		}
	}

	@AuraEnabled
	public static Id getNearestAirportForFacility(String nearestAirportCode) {
		if(nearestAirportCode != null && nearestAirportCode != ''){
			List<Airport_Detail__c> airportDetail = [Select Id from Airport_Detail__c where Code__c =:nearestAirportCode];
			if (!airportDetail.isEmpty()){
				return airportDetail[0].Id;
			} 
		}

		return null;
	}

	private static Id getAccountRoleForAccount(String accountId, Boolean isCreateCompanyMode) {
		List<Account_Role__c> aroles = [SELECT id FROM Account_Role__c WHERE Account__c = :accountId AND Functional_Role__c = :ONESOURCE];
		if (aroles.isEmpty()) {
			try {
				Account_Role__c ar = createOneSourceAccRole(accountId);
				insert ar;

				if (!isCreateCompanyMode){
					Account acc = [SELECT Name FROM Account WHERE Id = :accountId];

					Account_Role_Relationship__c newArr = new Account_Role_Relationship__c();
					newArr.From__c = ar.Id;
					newArr.Ops_Hierarchy_Group__c = acc.Name;
					
					insert newArr;
				}

				return ar.Id;
			} catch (Exception ex) {
				return null;
			}
		} else {
			return aroles[0].Id;
		}
	}

	private static Id createFacilityLogo(String logoInfo, Id facilityId){
		LogoInfo facilityLogo;
		if (logoInfo != null && logoInfo.length() > 4){
			facilityLogo = (LogoInfo) JSON.deserialize(logoInfo, LogoInfo.class);
		}

		if (facilityLogo != null) {
			ContentVersion conVer = new ContentVersion();
			conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
			conVer.PathOnClient = facilityLogo.fileName; // The files name, extension is very important here which will help the file in preview.
			conVer.Title = facilityLogo.fileName; // Display name of the files
			conVer.VersionData = EncodingUtil.base64Decode(facilityLogo.base64Data); // converting your binary string to Blog
			conVer.Is_Company_Logo__c = true;
			insert conVer;
			// First get the content document Id from ContentVersion
			Id conDoc = conVer.ContentDocumentId != null ? conVer.ContentDocumentId : [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conVer.Id].ContentDocumentId;

			//Create ContentDocumentLink
			ContentDocumentLink cDe = new ContentDocumentLink();
			cDe.ContentDocumentId = conDoc;
			cDe.LinkedEntityId = facilityId; // you can use objectId,GroupId etc
			cDe.ShareType = 'I';
			cDe.Visibility = 'AllUsers';
			insert cDe;

			return conDoc;
		}

		return null;
	}

	@AuraEnabled
	public static string createDummyCompany(String account, String opsHierarchy, Boolean isNewHierarchy) {
		CW_Utilities.ResponseBody res = new CW_Utilities.ResponseBody();
		Savepoint sp;
		try {
			sp = CW_DBTransactionHandler.setSavepoint();
			
			Account acc = (Account) JSON.deserialize(account, Account.class);
			acc.Reason_for_creation__c = 'Created by customer';
			acc.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account','Standard_Account');
			//Since we need to create a portal user, we need to assign the account to a user with a specified role, otherwise an error is thrown
			if (!Test.isRunningTest()) {
				acc.ownerid = ISSP_Constant.newAccountOwnerId;
			}
			insert acc;

			Account_Role__c ar = createOneSourceAccRole(acc.Id);
			insert ar;

			//Create Ops Hierarchy
			if(opsHierarchy != null && opsHierarchy != ''){
				List<Account_Role_Relationship__c> arrs = [Select id, From__c, To__c, Relationship_Name__c, Ops_Hierarchy_Group__c from Account_Role_Relationship__c Where Relationship_Name__c =:opsHierarchy OR Ops_Hierarchy_Group__c =:opsHierarchy];
				Account_Role_Relationship__c newArr = new Account_Role_Relationship__c();
				newArr.From__c = ar.Id;
				if(!arrs.isEmpty()){
					Account_Role_Relationship__c parentArr;
					Boolean existsOpsGroupName = false;
					for(Account_Role_Relationship__c arr : arrs){
						if (arr.Relationship_Name__c == opsHierarchy) parentArr = arr;
						if(arr.Ops_Hierarchy_Group__c == opsHierarchy) existsOpsGroupName = true;
					}
					if(parentArr != null){
						newArr.To__c = parentArr.From__c;
						newArr.Ops_Hierarchy_Group__c = parentArr.Ops_Hierarchy_Group__c;
						insert newArr;
					}else if(existsOpsGroupName){
						newArr.Ops_Hierarchy_Group__c = opsHierarchy;
						insert newArr;
					}
				}
				else{
					User usr = [Select Id, AccountId, Account.Name from User where Id = :UserInfo.getUserId() limit 1];
					String accountId = usr.AccountId;
					Id userAccRole = getAccountRoleForAccount(accountId, true);
					List<Account_Role_Relationship__c> userarr = [Select id, From__c, To__c, Relationship_Name__c, Ops_Hierarchy_Group__c from Account_Role_Relationship__c Where From__r.Account__c =:accountId];
					String userGroup;
					for(Account_Role_Relationship__c arr : userarr){
						userGroup = arr.Ops_Hierarchy_Group__c;
					}
					
					//If user account has no account role relationships means is an single account
					//Relate new account and single account with ops hierarchy group
					if(String.isBlank(userGroup)){
						userGroup = usr.Account.Name;
						if(userAccRole == null) {
							Account_Role__c arol = createOneSourceAccRole(accountId);
							insert arol;
							userAccRole = arol.Id;
						}
						Account_Role_Relationship__c newUserArr = new Account_Role_Relationship__c();
						newUserArr.From__c = userAccRole;
						newUserArr.Ops_Hierarchy_Group__c = userGroup;
						insert newUserArr;
					}
					newArr.Ops_Hierarchy_Group__c = userGroup;
					if(isNewHierarchy == true){
						newArr.To__c = ar.Id;
						newArr.Relationship_Name__c = opsHierarchy;
					}
					insert newArr;

				}
			}
			res.success = true;
			res.message = acc.id;
		} catch (Exception ex) {
			CW_DBTransactionHandler.doRollback(sp);
			res.success = false;
			res.message = ex.getMessage();
		}
		return JSON.serialize(res);
	}

	@AuraEnabled
	public static Map<String, Object> updateFacility(String jsonInput, String logoInfo, String geoLocationInfo) {
		Map<String, Object> returnValue = new Map<String, Object>();

		try {			
			ICG_Account_Role_Detail__c facilityToUpdate =(ICG_Account_Role_Detail__c) JSON.deserialize(jsonInput,ICG_Account_Role_Detail__c.class);

			facilityToUpdate = CW_CreateFacilityController.handleGeoLocations(facilityToUpdate, geoLocationInfo);

			Id conDoc = CW_CreateFacilityController.createFacilityLogo(logoInfo, facilityToUpdate.Id);
			if(conDoc != null){
				facilityToUpdate.logoUrl__c = CW_CreateFacilityController.generateLogoURL(conDoc);
			}
			update facilityToUpdate;

			returnValue.put('result', new Map<String, String>{ 'status' => 'OK' });
		} catch (Exception e) {
			returnValue.put('result', new Map<String, String>{ 'status' => 'error' });
			returnValue.put('exception', new Map<String, String>{ 'message' => e.getMessage(), 'trace' => e.getStackTraceString() });
		}
		return returnValue;
	}

	@AuraEnabled
	public static void updateAccountCoordinates(String accId, Double latitude, Double longitude){
		Account acc = [Select id, Business_Geo_Coordinates__Latitude__s, Business_Geo_Coordinates__Longitude__s from Account where Id =:accId];
		if (acc.Business_Geo_Coordinates__Latitude__s == null || acc.Business_Geo_Coordinates__Longitude__s == null){
			CW_CreateFacilityController.updateGeoLocationsForAccount(acc, latitude, longitude);
		}
	}

	private static void updateGeoLocationsForAccount(Account acc, Double latitude, Double longitude) {
		acc.Business_Geo_Coordinates__Latitude__s = latitude;
		acc.Business_Geo_Coordinates__Longitude__s = longitude;
		update acc;
	}

	private static ICG_Account_Role_Detail__c handleGeoLocations(ICG_Account_Role_Detail__c facilityToUpdate, String geoLocationInfo) {
		GeoLocationInfo geoLocation;
		
		if (!String.isBlank(geoLocationInfo) && geoLocationInfo.length() > 4){			
			geoLocation = (GeoLocationInfo) JSON.deserialize(geoLocationInfo, GeoLocationInfo.class);
		}
		
		if(geoLocation != null && geoLocation.companyId != null) {            
			Account acc = [Select id, Business_Geo_Coordinates__Latitude__s, Business_Geo_Coordinates__Longitude__s from Account where Id =:geoLocation.companyId];			
			Boolean accountCoordinatesAreDifferent = acc != null && (acc.Business_Geo_Coordinates__Latitude__s != geoLocation.latitude || acc.Business_Geo_Coordinates__Longitude__s != geoLocation.longitude);			
			Boolean newCoordinatesAreValid = geoLocation.latitude != null && geoLocation.longitude != null;
			
			if(accountCoordinatesAreDifferent && newCoordinatesAreValid){
				facilityToUpdate.Station_Geo_Coordinates__Latitude__s = geoLocation.latitude;
				facilityToUpdate.Station_Geo_Coordinates__Longitude__s = geoLocation.longitude;
			}

			Boolean accountCoordinatesAreNotSet = acc != null && acc.Business_Geo_Coordinates__Latitude__s == null || acc.Business_Geo_Coordinates__Longitude__s == null;
			
			if (accountCoordinatesAreNotSet && newCoordinatesAreValid){
				CW_CreateFacilityController.updateGeoLocationsForAccount(acc, geoLocation.latitude, geoLocation.longitude);
			}
		}
		
		return facilityToUpdate;
	}

	private static String generateLogoURL(Id conDoc) {
		String URL_Base = ISSP_CS__c.getValues('ICG_URL_Base').Value__c;
		return URL_Base.removeEnd('/s/') + '/sfc/servlet.shepherd/document/download/' + conDoc;
	}

	private static Account_Role__c createOneSourceAccRole(Id accountId){
		Account_Role__c ar = new Account_Role__c();
		ar.Account__c = accountId;
		ar.Account_Role_Name__c = ONESOURCE;
		ar.Functional_Role__c = ONESOURCE;
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
				if(rtype == 'Airline' && ard.RecordType.DeveloperName == rtype){
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

	public class GeoLocationInfo {
		public Double longitude;
		public Double latitude;
		public String companyId;
	}
}