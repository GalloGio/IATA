/**
	Class to handle the trigger actions for the object Operational_Calendar__c
**/
public with sharing class OperationalCalendarHandler {

	public static final Id ISS_RECORDTYPE_ID = Schema.SObjectType.Operational_Calendar__c.getRecordTypeInfosByDeveloperName().get('ISS_Calendar').getRecordTypeId();
	public static final list<String> AIRLINE_PROFILES = ISSP_CS__c.getValues('ISS OperationalCalendar Airline Profil').Value__c.split(',');
	public static final list<String> AGENT_PROFILES = ISSP_CS__c.getValues('ISS OperationalCalendar Agency Profile').Value__c.split(',');

	public static list<User> TEST_LIST_AIRLINE_USER = new list<User>();
	public static list<User> TEST_LIST_AGENCY_USER = new list<User>();

	private static final Map<String, Schema.SObjectField> CALENDAR_FIELD_INFO = Schema.SObjectType.Operational_Calendar__c.fields.getMap();

	public static void beforeInsert(list<Operational_Calendar__c> listNew) {
		populateMissingFields(listNew);
	}

	public static void afterUpdate(map<Id,Operational_Calendar__c> mapNew, map<Id,Operational_Calendar__c> mapOld) {
		createNotifications(mapNew,mapOld);
	}

	private static Notification_template__c OPERATIONAL_CALENDAR_TEMPLATE;
	public static Notification_template__c getOperationaCalendarTemplate() {
		if (OPERATIONAL_CALENDAR_TEMPLATE == null) {
			try {
				OPERATIONAL_CALENDAR_TEMPLATE = [
					SELECT Type__c, Subject__c, Notification_color__c, Name, Message__c, Master_Notification_template__c, Language__c, Id, Expire_in_days__c, Due_date__c, DDS_Update_Request__c, Alert_Contact_By_Email__c, Admins_Users__c, CriticalNotification__c,
						(Select Type__c, Subject__c, Notification_color__c, Name, Message__c, Master_Notification_template__c, Language__c, Id, Expire_in_days__c, Due_date__c, DDS_Update_Request__c, Alert_Contact_By_Email__c, Admins_Users__c, CriticalNotification__c
						FROM Notification_templates__r)
					FROM Notification_template__c
					WHERE Id = :ISSP_Notifications_Trigger__c.getValues('Operational Calendar').Notification_Template_Id__c
					LIMIT 1
				];
			} catch (Exception e) {
				System.debug('Notification template for operational calendars not found. No notification will be created.');
			}
		}
		return OPERATIONAL_CALENDAR_TEMPLATE;
	}

	/**
		Check updated Operational Calendar reords and select only those changing
		the Settlement_Day__c or the Remittance_Day__c
	**/
	private static void createNotifications(map<Id,Operational_Calendar__c> mapNew, map<Id,Operational_Calendar__c> mapOld) {
		try {
			map<Id,Operational_Calendar__c> mapSettlementChanges = new map<Id,Operational_Calendar__c>();
			map<Id,Operational_Calendar__c> mapRemittanceChanges = new map<Id,Operational_Calendar__c>();

			for (Operational_Calendar__c operationNew: mapNew.values()) {
				if (operationNew.Visible_on_the_portal__c==true && operationNew.RecordTypeId==ISS_RECORDTYPE_ID ) {
					Operational_Calendar__c operationOld = mapOld.get(operationNew.Id);
					if (operationNew.Settlement_Day__c!=operationOld.Settlement_Day__c) {
						mapSettlementChanges.put(operationNew.Id,operationNew);
					}
					if (operationNew.Remittance_Day__c!=operationOld.Remittance_Day__c) {
						mapRemittanceChanges.put(operationNew.Id,operationNew);
					}
				}
			}
			sendAgencyNotifications(mapRemittanceChanges);
			sendAirlineNotifications(mapSettlementChanges, mapRemittanceChanges);
		} catch (Exception e) {
			System.debug('** Error in createNotifications: ' + e.getMessage());
		}
	}

	/**
		Get the list of Airline Contacts to send notifications
	**/
	private static void sendAirlineNotifications(map<Id,Operational_Calendar__c> mapSettlementChanges, map<Id,Operational_Calendar__c> mapRemittanceChanges) {
		list<Operational_Calendar__c> listOperations = new list<Operational_Calendar__c>();
		listOperations.addAll(mapSettlementChanges.values());
		listOperations.addAll(mapRemittanceChanges.values());
		if (listOperations.isEmpty()) return;

		// create a map to group all operational calendars by their ISS Operation
		map<Id,list<Operational_Calendar__c>> mapISSOperationListCalendar = new map<Id,list<Operational_Calendar__c>>();
		for (Operational_Calendar__c operation: listOperations) {
			Id key = operation.ISS_operation__c;
			list<Operational_Calendar__c> value = mapISSOperationListCalendar.get(key);
			if (value==null){
				value = new list<Operational_Calendar__c>();
			}
			value.add(operation);
			mapISSOperationListCalendar.put(key,value);
		}

		//query users with a valid profile (airline or agent) getting all relevant
		//info, like country and settlements
		list<User> listUser = [
			SELECT Id, Contact.Name, Contact.Email,
				Contact.Account.IATA_ISO_Country__c,
				Contact.Account.Remittance_frequency__c,
				Contact.Account.Location_Class__c,
				Contact.Account.IATA_ISO_Country__r.AMS_Settlement_System__c,
				Contact.Account.IATA_ISO_Country__r.AMS_Settlement_System_CASS__c
			FROM User
			WHERE ProfileId IN :AIRLINE_PROFILES
			AND Contact.Status__c = 'Active'
			AND (
				Contact.Account.IATA_ISO_Country__r.AMS_Settlement_System__c IN :mapISSOperationListCalendar.keyset()
				OR Contact.Account.IATA_ISO_Country__r.AMS_Settlement_System_CASS__c IN :mapISSOperationListCalendar.keyset()
			)
			AND (
				Profile.Name LIKE '%Admin%'
				OR Contact.S_ICE__c > 0
				OR Contact.S_BSPlink__c > 0
				OR Contact.S_CASSlink__c > 0
			)
		];
		if (Test.isRunningTest()) listUser = TEST_LIST_AIRLINE_USER;
		// use the queries records to check those users with a calendar operation having an update
		map<Id,Operational_Calendar__c> mapContactIdForRemittance = new map<Id,Operational_Calendar__c>();
		map<Id,Operational_Calendar__c> mapContactIdForSettlement = new map<Id,Operational_Calendar__c>();
		map<Id,Contact> mapContact = new map<Id,Contact>();
		for (User user: listUser) {
			Id BSPOperationId = user.Contact.Account.IATA_ISO_Country__r.AMS_Settlement_System__c;
			Id CASSOperationId = user.Contact.Account.IATA_ISO_Country__r.AMS_Settlement_System_CASS__c;
			list<Operational_Calendar__c> listBSPOperations = mapISSOperationListCalendar.get(BSPOperationId);
			list<Operational_Calendar__c> listCASSOperations = mapISSOperationListCalendar.get(CASSOperationId);
			mapContact.put(user.ContactId, user.Contact);

			if (listBSPOperations!=null && !listBSPOperations.isEmpty()) {
				System.debug('Contact ' + user.Contact + ' has BSP  changes: ' + listBSPOperations);
				for (Operational_Calendar__c operation: listBSPOperations) {
					if (mapRemittanceChanges.keyset().contains(operation.Id)) {
						mapContactIdForRemittance.put(user.ContactId,operation);
					}
					if (mapSettlementChanges.keyset().contains(operation.Id)) {
						mapContactIdForSettlement.put(user.ContactId,operation);
					}
				}
			}
			if (listCASSOperations!=null && !listCASSOperations.isEmpty()) {
				System.debug('Contact ' + user.Contact + ' has CASS changes: ' + listCASSOperations);
				for (Operational_Calendar__c operation: listCASSOperations) {
					if (mapRemittanceChanges.keyset().contains(operation.Id)) {
						mapContactIdForRemittance.put(user.ContactId,operation);
					}
					if (mapSettlementChanges.keyset().contains(operation.Id)) {
						mapContactIdForSettlement.put(user.ContactId,operation);
					}
				}
			}
		}
		// send notifications
		createAndSendNotificationBatch(getOperationaCalendarTemplate(), 'Remittance_Day__c',mapContactIdForRemittance, mapContact);
		createAndSendNotificationBatch(getOperationaCalendarTemplate(), 'Settlement_Day__c',mapContactIdForSettlement, mapContact);
	}

	/**
		Get the list of Agency Contacts to send notifications
	**/
	private static void sendAgencyNotifications(map<Id,Operational_Calendar__c> mapRemittanceChanges) {
		list<Operational_Calendar__c> listOperations = new list<Operational_Calendar__c>();
		listOperations.addAll(mapRemittanceChanges.values());
		if (listOperations.isEmpty()) return;
		// create a map to group all operational calendars by their ISS Operation
		map<Id,list<Operational_Calendar__c>> mapISSOperationListCalendar = new map<Id,list<Operational_Calendar__c>>();
		for (Operational_Calendar__c operation: listOperations) {
			Id key = operation.ISS_operation__c;
			list<Operational_Calendar__c> value = mapISSOperationListCalendar.get(key);
			if (value==null){
				value = new list<Operational_Calendar__c>();
			}
			value.add(operation);
			mapISSOperationListCalendar.put(key,value);
		}
		//query users with a valid profile (airline or agent) getting all relevant
		//info, like country and settlements
		list<User> listUser = [
			SELECT Id, Contact.Name, Contact.Email,
				Contact.Account.IATA_ISO_Country__c,
				Contact.Account.Remittance_frequency__c,
				Contact.Account.Location_Class__c,
				Contact.Account.IATA_ISO_Country__r.AMS_Settlement_System__c,
				Contact.Account.IATA_ISO_Country__r.AMS_Settlement_System_CASS__c
			FROM User
			WHERE ProfileId IN :AGENT_PROFILES
			AND Contact.Status__c = 'Active'
			AND (
				Contact.Account.IATA_ISO_Country__r.AMS_Settlement_System__c IN :mapISSOperationListCalendar.keyset()
				OR Contact.Account.IATA_ISO_Country__r.AMS_Settlement_System_CASS__c IN :mapISSOperationListCalendar.keyset()
			)
			AND (
				Profile.Name LIKE '%Admin%'
				OR Contact.S_ICE__c > 0
				OR Contact.S_BSPlink__c > 0
				OR Contact.S_CASSlink__c > 0
			)
		];
		if (Test.isRunningTest()) listUser = TEST_LIST_AGENCY_USER;
		// use the queries records to check those users with a calendar operation having an update
		map<Id,Operational_Calendar__c> mapContactIdForRemittance = new map<Id,Operational_Calendar__c>();
		map<Id, Contact> mapContact = new map<Id, Contact>();
		for (User user: listUser) {
			String country = user.Contact.Account.IATA_ISO_Country__c;
			String frequency = user.Contact.Account.Remittance_frequency__c;
			String operationType = ISSP_OperationalCalendarController.MAP_OPERATION_TYPES.get(user.Contact.Account.Location_Class__c);
			mapContact.put(user.ContactId, user.Contact);
			//Find operations in BSP
			if (operationType!=null && operationType.contains('BSP')) {
				// Find the Operational Calendar Ids in ISS BSP
				Id bspOperationId = user.Contact.Account.IATA_ISO_Country__r.AMS_Settlement_System__c;
				list<Operational_Calendar__c> listOperationsForThisUser = mapISSOperationListCalendar.get(bspOperationId);
				if (listOperationsForThisUser!=null && !listOperationsForThisUser.isEmpty() && bspOperationId!=null) {
					System.debug('Contact ' + user.Contact + ' has BSP changes: ' + listOperationsForThisUser);
					for (Operational_Calendar__c operation: listOperationsForThisUser) {
						if (mapRemittanceChanges.keyset().contains(operation.Id)
							&& operation.frequency_code__c == frequency
							&& operation.Operation_Type__c == operationType) {
								mapContactIdForRemittance.put(user.ContactId,operation);
						}
					}
				}
			}
			//Find operations in CASS
			if (operationType!=null && operationType.contains('CASS')) {
				// Find the Operational Calendar Ids in ISS CASS
				Id cassOperationId = user.Contact.Account.IATA_ISO_Country__r.AMS_Settlement_System_CASS__c;
				list<Operational_Calendar__c> listOperationsForThisUser = mapISSOperationListCalendar.get(cassOperationId);
				if (listOperationsForThisUser!=null && !listOperationsForThisUser.isEmpty() && cassOperationId!=null) {
					System.debug('Contact ' + user.Contact + ' has CASS changes: ' + listOperationsForThisUser);
					for (Operational_Calendar__c operation: listOperationsForThisUser) {
						if (mapRemittanceChanges.keyset().contains(operation.Id)
							&& operation.Operation_Type__c == operationType) {
								mapContactIdForRemittance.put(user.ContactId,operation);
						}
					}
				}
			}

		}
		// send notifications
		createAndSendNotificationBatch(getOperationaCalendarTemplate(), 'Remittance_Day__c', mapContactIdForRemittance, mapContact);
	}

	/**
		Call the ISSP Notification batch to send emails using the incoming template
	**/
	public static void createAndSendNotificationBatch(Notification_template__c template, String fieldName, map<Id,Operational_Calendar__c> mapContactId, map<Id, Contact> mapContact) {
		if (template==null || mapContactId.isEmpty()) return;
		//Retrieve Countries
		list<String> listISOCodes = new list<String>();
		for (Operational_Calendar__c operation: mapContactId.values() ) {
			String isocode= operation.Operation_Code__c.mid(0,2);
			listISOCodes.add(isocode);
		}
		map<String,IATA_ISO_Country__c> mapCountries = new map<String,IATA_ISO_Country__c>();
		for (IATA_ISO_Country__c country: [SELECT Id, Name, ISO_Code__c FROM IATA_ISO_Country__c WHERE ISO_Code__c IN :listISOCodes]) {
			mapCountries.put(country.ISO_Code__c, country);
		}

		//Create notifications batch
		list<Id> listContactId = new list<Id>();
		listContactId.addAll(mapContactId.keyset());
		ISSP_NotificationBatch bc = new ISSP_NotificationBatch();
		bc.Query = 'SELECT ' + String.join(ISSP_NotificationUtilities.getAllContactFields(), ',')
			+ ' FROM Contact '
			+ ' WHERE Id IN (\'' + String.join(listContactId, '\',\'') + '\')';
		bc.NotificationTemplate = template;
		bc.MessagesByGroupMap = null;
		bc.ContactGroupField = null;
		bc.FieldBindingByGroupMap = new map<String,list<String>>();
		for (Id contactId: mapContactId.keyset() ) {
			try {
				Operational_Calendar__c operation = mapContactId.get(contactId);
				Contact contact = mapContact.get(contactId);
				list<String> listValues = new list<String>();
				listValues.add(contact.Name);
				listValues.add(operation.Operation_Type__c);
				String countryKey = operation.Operation_Code__c.mid(0,2);
				String countryName = mapCountries.containsKey(countryKey)? mapCountries.get(countryKey).Name: countryKey;
				listValues.add(countryName);
				listValues.add(CALENDAR_FIELD_INFO.get(fieldName).getDescribe().getLabel());
				listValues.add(operation.Period_Code__c);
				listValues.add(String.ValueOf(operation.First_Day__c));
				listValues.add(String.ValueOf(operation.Last_Day__c));
				listValues.add(String.ValueOf(operation.get(fieldName)));
				bc.FieldBindingByGroupMap.put(contactId, listValues);
			} catch (Exception e) {
				System.debug('___OperationalCalendarHandler.createAndSendNotificationBatch() contactId ' + contactId + ', error:' + e.getMessage());
			}
		}
		bc.ContactGroupField = 'Id';
		Database.executeBatch(bc, 1);
	}

	/**
		Populates some calendar fields when they are empty
		This happens when the data comes from the external service and it's
		inserted by MuleSoft
	**/
	private static void populateMissingFields(list<Operational_Calendar__c> listOperations) {
		Set<String> listCountryCodes = new Set<String>();
		list<CalendarFields> listCalendarFields = new list<CalendarFields>();
		for (Operational_Calendar__c operation: listOperations) {
			CalendarFields calendarFields = new CalendarFields(operation);
			listCalendarFields.add(calendarFields);
			listCountryCodes.add(calendarFields.country);
		}
		map<String,IATA_ISO_Country__c> mapISSoperations = new map<String,IATA_ISO_Country__c>();
		for (IATA_ISO_Country__c country: IATAIsoCountryDAO.getIsoCountryByIsoCodes(listCountryCodes)) {
			mapISSoperations.put( country.ISO_Code__c, country);
		}

		//populate Calendar fields from class CalendarFields
		for (CalendarFields calendarFields: listCalendarFields) {
			IATA_ISO_Country__c countryObject = mapISSoperations.get(calendarFields.country);
			// set the ISS operation
			if (countryObject!=null) {
				if (calendarFields.bspCass == 'BSP') {
					calendarFields.setISSOperation(countryObject.AMS_Settlement_System__c);
				}
				if (calendarFields.bspCass == 'CASS') {
					calendarFields.setISSOperation(countryObject.AMS_Settlement_System_CASS__c);
				}
			}
			calendarFields.setCurrency();
			calendarFields.setFrequency();
			calendarFields.setOperationType();
			calendarFields.setOperationPeriodCode();
		}
	}

	public static final map<String,String> MAP_BSP_OPERATION_TYPES = new map<String,String>{
		'I' => 'BSP International',
		'D' => 'BSP Domestic'
	};
	public static final map<String,String> MAP_CASS_OPERATION_TYPES = new map<String,String>{
		'E' => 'CASS Export',
		'I' => 'CASS Import'
	};
	/**
		Class to manage the calculated fields for an Operational_Calendar__c record
	**/
	public class CalendarFields {
		public String country;
		public String bspCass;
		public String currencyCode;
		public String operationType;
		public String frequency;
		public String ISSOperationName;
		public Operational_Calendar__c operation;

		public CalendarFields(Operational_Calendar__c operation) {
			this.operation = operation;
			if (String.isBlank(operation.Operation_Code__c)) return;
			list<String> listParts = operation.Operation_Code__c.split('_');
			if (listParts.size()<5) return;
			this.country = listParts[0];
			if (listParts[1]=='BSP') {
				this.bspCass = 'BSP';
				this.operationType = MAP_BSP_OPERATION_TYPES.get(listParts[4]);
			}
			if (listParts[1]=='CAS') {
				this.bspCass = 'CASS';
				this.operationType = MAP_CASS_OPERATION_TYPES.get(listParts[2]);
			}
			this.ISSOperationName = this.bspCass + '-' + this.country;
			this.currencyCode = listParts[3];
			this.frequency = operation.Period_Code__c==null? '': operation.Period_Code__c.right(1);
		}

		public void setISSOperation(Id ISSOperationId) {
			if (String.isBlank(operation.ISS_operation__c)) {
				operation.ISS_operation__c = ISSOperationId;
			}
		}

		public void setCurrency() {
			if (String.isBlank(operation.Operation_Currency__c)) {
				operation.Operation_Currency__c = this.currencyCode;
			}
		}

		public void setFrequency() {
			if (String.isBlank(operation.Frequency_code__c)) {
				operation.Frequency_code__c = this.frequency;
			}
		}

		public void setOperationType() {
			if (String.isBlank(operation.Operation_Type__c)) {
				operation.Operation_Type__c = this.operationType;
			}
		}

		public void setOperationPeriodCode() {
			if (String.isBlank(operation.Operation_Period_code__c)) {
				operation.Operation_Period_code__c = this.operation.Operation_Code__c + '__RM_' + this.operation.Period_Code__c;
			}
		}
	}

}
