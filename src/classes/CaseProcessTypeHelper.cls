/*
 *  This class is an helper with methods to handle Case Process Type actions, like calculate the KPI when the case is closed
 *  or copy the Case process to OSCAR
 */
public with sharing class CaseProcessTypeHelper {

	private static final String ALL_REASONS = 'ALL'; // keyword that represents all kind of reasons in the Case_Process_Type__mdt
	private static final Id CASE_RT_OSCAR = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

	// Values for the standard field Case.Status marked as a closed
	private static Set<String> CLOSED_STATUSES {
		get {
			if (CLOSED_STATUSES==null) {
				CLOSED_STATUSES = new Set<String>();
				for (CaseStatus status : [SELECT ApiName  FROM CaseStatus WHERE IsClosed = true AND ApiName NOT IN ('Abandoned','Closed_Rejected','Closed_Withdrawn','Closed_ Not Accepted')]) {
					CLOSED_STATUSES.add(status.ApiName);
				}
			}
			return CLOSED_STATUSES;
		}
		private set;
	}

	//This variable maps the metadata per reason and case recordtype id
	private static Map<Id,Map<String,list<Case_Process_Type__mdt>>> mapRTsToReasons = null;

	/*
	 *  Method to load Case_Process_Type__mdt
	 */
	private static Map<Id,Map<String,list<Case_Process_Type__mdt>>> getMapRTsToReasons() {
		if(mapRTsToReasons == null) {
			mapRTsToReasons = new Map<Id,Map<String,list<Case_Process_Type__mdt>>>();

			List<Case_Process_Type__mdt> processes = [SELECT Reason__c, Type__c, KPI_Reference_Field__c, KPI_Reference_Value__c, Record_Type__c, Other_Conditions__c FROM Case_Process_Type__mdt];
			for(Case_Process_Type__mdt process : processes) {
				Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', process.Record_Type__c);
				Map<String,list<Case_Process_Type__mdt>> mapReason = mapRTsToReasons.get(rtId);
				if(mapReason == null) {
					mapReason = new Map<String,list<Case_Process_Type__mdt>>();
					mapRTsToReasons.put(rtId,mapReason);
				}

				list<Case_Process_Type__mdt> listProcessReason = mapReason.get(process.Reason__c);
				if (listProcessReason==null) {
					listProcessReason = new list<Case_Process_Type__mdt>();
				}
				listProcessReason.add(process);
				mapReason.put(process.Reason__c,listProcessReason);
			}
		}

		return mapRTsToReasons;
	}

	// list of all Oscar and Account fields used in the custom meta
	private static map<String,List<String>> mapRelatedFields = null;

	/**
	 *  Method to populate mapRelatedFields, a collection of all fields for the related object OSCAR and Account
	 * in the field Other_Conditions__c
	 */
	private static map<String,List<String>> getRelatedFields() {
		if (mapRelatedFields==null) {
			Set<String> setOscarFields = new Set<String>{'Case_Reason__c'};
			Set<String> setAccountFields = new Set<String>{'Id'};
			Set<String> setParentCaseFields = new Set<String>{'Id'};
			for(Case_Process_Type__mdt process : [SELECT Other_Conditions__c, KPI_Reference_Field__c FROM Case_Process_Type__mdt]) {
				// possible field used in KPI_Reference_Field__c
				list<String> parts = process.KPI_Reference_Field__c.split('[.]');
				if (parts.size() == 2 && parts[0] == 'AMS_Oscar__c') {
					setOscarFields.add(parts[1]);
				}
				// More possible fields used in Other_Conditions__c
				String condition = process.Other_Conditions__c;
				setOscarFields.addAll(extractRelatedFields(condition, 'OSCAR__r'));
				setAccountFields.addAll(extractRelatedFields(condition, 'Account'));
				setParentCaseFields.addAll(extractRelatedFields(condition, 'Parent'));
			}
			mapRelatedFields = new map<String,List<String>>();
			mapRelatedFields.put('OSCAR__r', new list<String>(setOscarFields));
			mapRelatedFields.put('Account', new list<String>(setAccountFields));
			mapRelatedFields.put('Case', new list<String>(setParentCaseFields));
		}
		return mapRelatedFields;
	}

	/**
	 * From the input condition extracts all fields for a specific relation name
	 * Example: in condition: 'Oscar__r.Name IN ('name') AND Account.Id IN ('12345678')'
	 * Its result when we look for the relation name Oscar__r will be: {'Name'}
	 * and for the 'Account' relation: {'Id'}
	 */
	private static set<String> extractRelatedFields(String condition, String relationName) {
		set<String> setFieldNames = new set<String>();
		if (String.isNotBlank(condition)) {
			for (String part: condition.split(' ')) {
				if (part.startsWithIgnoreCase(relationName + '.')) {
					String fieldName = part.replace( relationName + '.','');
					setFieldNames.add(fieldName);
				}
			}
		}
		return setFieldNames;
	}

	/*
	 *  Method used to calculate KPI's when the Case is closed, some closed cases aren't suitable for this process so it's applied
	 *  a filter to exclude cases that don't match the criterias:
	 *  - RecordType must be defined in at least one of the metadata records
	 *  - Case is being closed
	 *  - Subject cannot contain 'PROCOM'
	 */
	private static Set<String> SET_CASE_KPI_PROCESSED = new Set<String>();
	public static void processKPI(List<Case> cases, Map<Id,Case> oldMap) {
		Set<Id> oscarIds = new Set<Id>(); //WMO-564 - ACAMBAS
		Set<Id> accountIds = new Set<Id>();
		Set<Id> parentCaseIds = new Set<Id>();
		List<Case> casesToProcess = new List<Case>();

		for(Case cse : cases) {
			if (!SET_CASE_KPI_PROCESSED.contains(cse.Id)) {
				Case oldRecord = oldMap.get(cse.Id);
				Boolean beingClosed = cse.Status!=oldRecord.Status && CLOSED_STATUSES.contains(cse.Status) && !CLOSED_STATUSES.contains(oldRecord.Status);
				Boolean hasConfig = getMapRTsToReasons().get(cse.RecordTypeId) != null &&
					(getMapRTsToReasons().get(cse.RecordTypeId).get(cse.Reason1__c) != null || getMapRTsToReasons().get(cse.RecordTypeId).get(ALL_REASONS) != null);
				Boolean validSubject = String.isNotBlank(cse.Subject) && !cse.Subject.contains('PROCOM');
				Boolean isOscar = cse.RecordTypeId == CASE_RT_OSCAR;
				if(hasConfig && beingClosed && validSubject &&
						( (isOscar && cse.OSCAR__c!=null) || !isOscar)) {
					SET_CASE_KPI_PROCESSED.add(cse.Id);
					casesToProcess.add(cse);
					if (cse.OSCAR__c!=null) { 
						oscarIds.add(cse.OSCAR__c); //WMO-564 - ACAMBAS
					} else {
						accountIds.add(cse.AccountId);
						parentCaseIds.add(cse.ParentId);
					}
				}
			}
		}

		if(casesToProcess.isEmpty()) {
			return;
		}

		Map<Id, AMS_OSCAR__c> mapOscars = getMapOscar(oscarIds);
		Map<Id, Account> mapAccount = getMapAccount(accountIds);
		Map<Id, Case> mapParentCase = getMapParentCase(parentCaseIds);

		for(Case cse : casesToProcess) {
			AMS_OSCAR__c oscar = mapOscars.get(cse.OSCAR__c); //WMO-564 - ACAMBAS
			if (oscar!=null) {
				cse.OSCAR__r = oscar;
				cse.Account = oscar.Account__r;
			}
			// add related account object inside case
			Account account = mapAccount.get(cse.AccountId);
			if (account!=null) {
				cse.Account = account;
			}
			// add related Parent Case object inside case
			Case parentCase = mapParentCase.get(cse.ParentId);
			if (parentCase!=null) {
				cse.Parent = parentCase;
			}
			Case_Process_Type__mdt process = getRightProcess(cse);
			if (process!=null) {
				calculateKPI(cse, oscar, process);
			}
		}
	}

	/**
	 * Creates a map of AMS_Oscar records based on the input Ids
	 * Fields in the SELECT are based on those used in the Custom metadata Case_Process_Type__mdt
	 */
	private static map<Id,AMS_OSCAR__c> getMapOscar(Set<Id> oscarIds) {
		if (oscarIds.isEmpty()) return new map<Id,AMS_OSCAR__c>();
		set<String> setOscarFields = new set<String>(getRelatedFields().get('OSCAR__r')); //adding oscar records
		setOscarFields.add('Id');
		setOscarFields.add('Account__r.Id');
		setOscarFields.addAll(getRelatedFieldNames('Account','Account__r.')); // adding account records from the Account__r lookup
		List<String> listFields = new List<String>(setOscarFields);
		String query = 'SELECT ' + String.join(listFields,',') + ' FROM AMS_OSCAR__c';
		query += ' WHERE Id IN (\'' + String.join(new list<Id>(oscarIds),'\',\'') + '\')';
		list<AMS_OSCAR__c> listOscar = Database.query(query);
		return new map<Id,AMS_OSCAR__c>(listOscar);
	}

	/**
	 * Creates a map of Account records based on the input Ids
	 * Fields in the SELECT are based on those used in the Custom metadata Case_Process_Type__mdt
	 */
	private static map<Id,Account> getMapAccount(Set<Id> setAccount) {
		if (setAccount.isEmpty()) return new map<Id,Account>();
		List<String> listAccountFields = new List<String>(getRelatedFieldNames('Account',''));// adding account records from the Account lookup
		String query = 'SELECT ' + String.join(listAccountFields,',') + ' FROM Account';
		query += ' WHERE Id IN (\'' + String.join(new list<Id>(setAccount),'\',\'') + '\')';
		list<Account> listAccount = Database.query(query);
		return new map<Id,Account>(listAccount);
	}

	/**
	 * Creates a map of Account records based on the input Ids
	 * Fields in the SELECT are based on those used in the Custom metadata Case_Process_Type__mdt
	 */
	private static map<Id,Case> getMapParentCase(Set<Id> setParentCase) {
		if (setParentCase.isEmpty()) return new map<Id,Case>();
		List<String> listParentCaseFields = new List<String>(getRelatedFieldNames('Case',''));// adding account records from the Parent Case lookup
		String query = 'SELECT ' + String.join(listParentCaseFields,',') + ' FROM Case';
		query += ' WHERE Id IN (\'' + String.join(new list<Id>(setParentCase),'\',\'') + '\')';
		list<Case> listCase = Database.query(query);
		return new map<Id,Case>(listCase);
	}

	/**
	 * Returns the list of meaningful Object fields required from a specific lookup field name
	 */
	private static Set<String> getRelatedFieldNames(String objectName, String lookupName) {
		Set<String> setFieldNames = new Set<String>();
		for (String fieldname: getRelatedFields().get(objectName)) {
			setFieldNames.add(lookupName + fieldname);
		}
		return setFieldNames;
	}

	/**
	 * Find the right process to be used in the input Case
	 */
	public static Case_Process_Type__mdt getRightProcess(Case cse) {
		list<Case_Process_Type__mdt> listProcess = getMapRTsToReasons().get(cse.RecordTypeId).get(cse.Reason1__c);
		if (listProcess==null) {
			listProcess = getMapRTsToReasons().get(cse.RecordTypeId).get(ALL_REASONS);
		}
		if (listProcess!=null) {
			for (Case_Process_Type__mdt process: listProcess) {
				if (processOtherConditions(cse,process.Other_Conditions__c)) {
					return process;
				}
			}
		}
		return null;
	}

	/**
	 * Checks if the input case validates the input condition
	 */
	public static Boolean processOtherConditions(Case cse, String conditions) {
		try {
			// if there is no condition to process we assume that it passes
			if (String.isBlank(conditions)) return true;
			// find AND operation
			list<String> listParts = conditions.split(' AND ');
			if (listParts.size()>1) {
				for (String part: listParts) {
					if (!processOtherConditions(cse,part)) return false;
				}
				return true;
			}
			// find NOT IN operation
			listParts = conditions.split(' NOT IN ');
			if (listParts.size()==2) {
				String fieldName = listParts[0];
				String fieldValue = getFieldValue(cse, fieldName);
				set<String> values = stringToSet(listParts[1]);
				return ! values.contains(fieldValue);
			}
			// find IN operation
			listParts = conditions.split(' IN ');
			if (listParts.size()==2) {
				String fieldName = listParts[0];
				String fieldValue = getFieldValue(cse, fieldName);
				set<String> values = stringToSet(listParts[1]);
				return values.contains(fieldValue);
			}
		} catch (Exception e) {
			TransformationHelper.sendEmailSupport( 'CaseProcessTypeHelper - ProcessOtherConditions Exception', 'Exception: ' + e + ' || case: ' + JSON.serialize(cse) + ' || conditions ' + conditions + ' || StackTrace: ' + e.getStackTraceString());
		}
		return false;
	}

	/**
	 * Transforms the string use in a IN operation to a set<String>
	 * Example: "('elem1','elem2')"  to set {'elem1','elem2'}
	 */
	private static set<String> stringToSet(String str) {
		return new set<String>(str.replaceAll('[(][ ]*\'','').replaceAll('\'[ ]*[)]','').split('\'[ ]*,[ ]*\''));
	}

	/**
	 * get the field value, as a String, for the input object,
	 * allowing field names like 'AMS_OSCAR.Step1__c' or 'OSCAR__r.AMS_Online_Accreditation__r.ANG_Accreditation_type__c'
	 */
	private static String getFieldValue(Sobject obj, String fieldname) {
		if (obj==null) return null;
		list<String> parts = fieldname.split('[.]');
		if (parts.size()==1) {
			return String.ValueOf(obj.get(fieldName));
		}
		String objectName = parts.remove(0);
		fieldName = String.join(parts,'.');
		return getFieldValue(obj.getSObject(objectName), fieldName); 
	}

	/**
	 *  Method used to populate process type on the OSCAR record based on a custom metadata type Case_Process_Type__mdt
	 *  that maps a reason to a process
	 */
	public static void populateOSCARAccProcess(AMS_OSCAR__c oscar) {
		// making a fake case to contain the oscar record to be able to call getRightProcess()
		Case cse = new Case(
			RecordTypeId = CASE_RT_OSCAR,
			Reason1__c = oscar.Case_Reason__c,
			OSCAR__r = oscar
		);
		Case_Process_Type__mdt process = getRightProcess(cse);
		oscar.Accreditation_Process_Type__c = process == null ? '' : process.Type__c;
	}

	/**
	 * Returns a set of oscar field names which are important to recalculate the Accreditation_Process_Type__c
	 * These fields are basically avery field used in the Case_Process_Type__mdt record used for the input oscar
	 */
	public static set<String> getRelevantFields(AMS_OSCAR__c oscar) {
		 // Case_Reason__c is always a relevant field
		set<String> setFields = new set<String>{'Case_Reason__c'};
		list<Case_Process_Type__mdt> listProcess = getMapRTsToReasons().get(CASE_RT_OSCAR).get(oscar.Case_Reason__c);
		if (listProcess!=null) {
			// other possible fields are inside Other_Conditions__c
			for (Case_Process_Type__mdt process: listProcess) {
				setFields.addAll(extractRelatedFields(process.Other_Conditions__c, 'OSCAR__r'));
			}
		}
		return setFields;
	}
	
	/*
	 *  Method used to calculate KPI field, it uses the custom metadata type Case_Process_Type__mdt to calculate the value
	 *  KPI_Reference_Field__c, this field has the API Name of a Case field that matters to calculate the KPI for a specific process
	 *  KPI_Reference_Value__c, this field has the value we need to compare with Case field, if the Case field is greather than the
	 *  reference value then KPI will be 0 otherwise it will be 1
	 */
	private static void calculateKPI(Case cse, AMS_OSCAR__c oscar, Case_Process_Type__mdt process) {
		//WMO-564 - ACAMBAS: Begin
		List<String> refFieldList = process.KPI_Reference_Field__c.split('\\.');

		if(refFieldList.size() == 2 && refFieldList[0] == 'AMS_Oscar__c') {
			Double recordValue = Double.valueOf(oscar.get(refFieldList[1]));
			cse.KPI_Calculation__c = recordValue == process.KPI_Reference_Value__c ? 1 : 0;
		}
		else if(refFieldList.size() == 1) { //Case
			Double recordValue = Double.valueOf(cse.get(process.KPI_Reference_Field__c));
			cse.KPI_Calculation__c = recordValue <= process.KPI_Reference_Value__c ? 1 : 0;
		}
		else {
			cse.addError('Configuration error - invalid field: ' + process.KPI_Reference_Field__c);
		}
		//WMO-564 - ACAMBAS: End
	}

	/*
	 *  Method that executes the recalculation OSCAR effective age when the case is closed
	 */
	public static void processOSCAREffAge(List<Case> cases, Map<Id,Case> oldMap) {
		Set<String> reasons = mapRTsToReasons.get(CASE_RT_OSCAR).keySet();
		Date x1stDay = Date.newInstance(2019, 1, 1);
		Map<Id,Case> mapOscarToCase = new Map<Id,Case>();

		for(Case cse : cases) {
			Case oldRecord = oldMap.get(cse.Id);
			if(cse.IsClosed && !oldRecord.IsClosed && cse.OSCAR__c != null && reasons.contains(cse.Reason1__c) && cse.CreatedDate >= x1stDay) {
				mapOscarToCase.put(cse.OSCAR__c, cse);
			}
		}

		if(!mapOscarToCase.isEmpty()) {
			List<String> oscarFields = new List<String>();
			List<Schema.FieldSetMember> kpiFields = SObjectType.AMS_OSCAR__c.FieldSets.KPI_Fields.getFields();
			for(Schema.FieldSetMember field : kpiFields) {
				oscarFields.add(field.getFieldPath());
			}

			Set<Id> oscarIds = mapOscarToCase.keySet();
			List<Case> casesToProcess = mapOscarToCase.values();
			String queryStr = 'SELECT ' + String.join(oscarFields, ', ') + ' FROM AMS_OSCAR__c ';
			queryStr += 'WHERE Id IN :oscarIds AND Dossier_Reception_Date__c <> null AND ';
			queryStr += 'Id NOT IN (SELECT OSCAR__c FROM Case WHERE Owner.Name LIKE \'%Recycle%\' AND Id IN :casesToProcess)';

			List<AMS_OSCAR__c> oscars = Database.query(queryStr);
			if(!oscars.isEmpty()) {
				for(AMS_OSCAR__c oscar : oscars) {
					/* We need to preform this assignment to make sure that null fields are set before flow execution */
					for(Schema.FieldSetMember field : kpiFields) {
						if(field.getSObjectField().getDescribe().isUpdateable()) {
							oscar.put(field.getFieldPath(), oscar.get(field.getFieldPath()));
						}
					}

					AMS_OSCAR_Age_Calculator.calculate(mapOscarToCase.get(oscar.Id), oscar);
				}

				update oscars;
			}
		}
	}

 }
