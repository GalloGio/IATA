/*
	The generate method is designed to work on an AFTER trigger and works better with records with no relationship fields queried
	
	The loadInitialInformation method works better with a BEFORE trigger, but it can also be called independently (do no use with trigger.new in the after trigger or it'll trow an error)

	Currently, this class works with the following objects:
	- Case
	- AMS_OSCAR__c
	- Agency_Applied_Change_code__c

	To add support for new objects, fill the config variables appropriately
*/
public class ANG_RiskEventGenerator {

	private class RiskEventGeneratorException extends Exception {}

	private final String objectName;

	private final List<SObject> newObjects;
	private final Map<Id, SObject> objMap;

	public static Boolean skip{
		get{
			if(skip == null) skip = false;
			return skip;
		}
		set;
	}
    
    
    public static Boolean skipStatusAssignment{
        get{
            if(skipStatusAssignment == null) skipStatusAssignment = false;
            return skipStatusAssignment;
        }
        set;
    }

	// ***************************************
	// ********* config variables ************
	// ***************************************

	// identify the main account field on the 
	// object, the account to wich the risk
	// event will be attached
	private Map<String, String> accountFields{
		get{
			return new Map<String, String>{
				'Case' => 'AccountId',
				'AMS_OSCAR__c' => 'Account__c',
				'Agency_Applied_Change_code__c' => 'Account__c'
			};
		}
	}

	// identify the fiel wich will hold the Id
	// from the object that triggers the generation
	private Map<String, String> sourceFields{
		get{
			return new Map<String, String>{
				'Case' => 'ANG_CaseId__c',
				'AMS_OSCAR__c' => 'ANG_OscarId__c',
				'Agency_Applied_Change_code__c' => 'ANG_ChangeCode__c'
			};
		}
	}


	// ***************************************
	// ************ constructor **************
	// ***************************************

	public ANG_RiskEventGenerator(List<SObject> newObjects, Map<Id, SObject> objMap){
		this.newObjects = newObjects;
		this.objMap = objMap;

		objectName = newObjects.getSObjectType().getDescribe().getName();
	}

	public ANG_RiskEventGenerator(List<ANG_Agency_Risk_Event__c> riskEvents){
		this.newObjects = riskEvents;
	}

	// ***************************************
	// ********** access methods *************
	// ***************************************
	private List<String> objectsiInvolved{
		get{
			return new List<String>{ objectName, 'ANG_Agency_Risk_Event__c'};
		}
	}

	private Map<String, Map<String, Id>> recordTypes{
		get{
			if(recordTypes == null){
				recordTypes = TransformationHelper.RtIDsPerDeveloperNamePerObj(objectsiInvolved);
			}
			return recordTypes;
		}
		set;
	}

	private List<ANG_Risk_Event_Configuration__c> configs{
		get{
			if(configs == null){
				Map<String, Schema.SObjectField> fMap = Schema.sObjectType.ANG_Risk_Event_Configuration__c.fields.getMap();

				List<String> fields = new List<String>();
				for(Schema.SObjectField field : fMap.values()) fields.add(field.getDescribe().getName());
				
				configs = Database.query('SELECT ' + String.join(fields, ', ') + ', ANG_Risk_Event_Type__r.ANG_Risk_ID__c FROM ANG_Risk_Event_Configuration__c WHERE ANG_Object_Type__c = :objectName');
			}
			return configs;
		}
		set;
	}

	// ***************************************
	// ********** action methods *************
	// ***************************************

	public void generate() {

		//for cases were no risk event should be generated;
		if(skip) return;

		//prevent recursion
		skip = true;

		// make initial filter (recordType) and fetch necessary fields to query
		Boolean reQuery = false;
		List<SObject> objToEvaluate = new List<SObject>();
		Set<Id> objectIds = new Set<Id>();
		Set<String> fields = new Set<String>();

		for(SObject o : newObjects){
			for(ANG_Risk_Event_Configuration__c config : configs){
				if((Id)o.get('RecordTypeId') == recordTypes.get(objectName).get(config.ANG_Object_Record_Type__c)){
					if(objectIds.add(o.Id)) objToEvaluate.add(o);
					
					for(ANG_RiskEventConfigurationFields f : ANG_RiskEventConfigurationFields.getList()){
						String fieldToCheck = (String)config.get(f.fieldName);
						if (fieldToCheck != null && fields.add(fieldToCheck) && fieldToCheck.contains('.')) reQuery = true; 
					}
				}
			}
		}

		if(objToEvaluate.isEmpty()) return; //No objects found with the correct record type, no need to match further (or no configs...)

		if(reQuery){
			// if any of the conditions fields includes a relationship (.) requery de object to get the relationships
			try{
				objToEvaluate = Database.query('SELECT Id, '+ String.join(new List<String>(fields), ', ')+' FROM '+objectName+' WHERE Id IN :objectIds');
			}catch(System.QueryException e){
				if(!e.getMessage().startsWith('No such column ')) throw e; 
				else {
					String friendlyMessage = 'Please review the #configurations# for #objects#. Some of the fields mentioned were not found';
					friendlyMessage = friendlyMessage.replace('#configurations#', Schema.SObjectType.ANG_Risk_Event_Configuration__c.getLabelPlural());
					friendlyMessage = friendlyMessage.replace('#objects#', Schema.getGlobalDescribe().get(objectName).getDescribe().getLabelPlural());
					throw new RiskEventGeneratorException(friendlyMessage);
				}
			}
		}		


		// for each object on the list, verify that it matches a config and create a risk event
		List<ANG_Agency_Risk_Event__c> riskEvents = new List<ANG_Agency_Risk_Event__c>();
		for(SObject o : objToEvaluate){
			for(ANG_Risk_Event_Configuration__c config : configs){
				if(checkRequisites(o, config)){
					
					ANG_Agency_Risk_Event__c risk = new ANG_Agency_Risk_Event__c();
					risk.ANG_Risk_Type__c = config.ANG_Risk_Event_Type__c;
					risk.ANG_AccountId__c = (id)o.get(accountFields.get(objectName));
					risk.ANG_Created_from__c = objectName;
					risk.put(sourceFields.get(objectName), o.Id);
					risk.ANG_UniqueKey__c = o.Id+config.ANG_Risk_Event_Type__r.ANG_Risk_ID__c;

					riskEvents.add(risk);
				}
			}
		}

		if(!riskEvents.isEmpty()) upsert riskEvents ANG_Agency_Risk_Event__c.fields.ANG_UniqueKey__c;
	}

	public void loadInitialInformations(){		
		Set<Id> riskTypes = new Set<Id>();
		Set<Id> accountIds = new Set<Id>();
		Map<Id, Id> oscars = new Map<Id, Id>();

		for(ANG_Agency_Risk_Event__c re : (List<ANG_Agency_Risk_Event__c>)newObjects){
			//check list of objects to query
			riskTypes.add(re.ANG_Risk_Type__c);
			accountIds.add(re.ANG_AccountId__c);

			if(re.ANG_Issued_Date__c == null) re.ANG_Issued_Date__c = System.today();
			if(re.ANG_OscarId__c != null) oscars.put(re.ANG_OscarId__c, null);

			// sets the Unique Key (this field is also set on the generate method to match the upsert and on a workflow rule if source id is empty)
			if(re.ANG_Source_Id__c != null) re.ANG_UniqueKey__c = Id.valueOf(re.ANG_Source_Id__c)+re.ANG_Risk_ID__c;
		}

		Map<Id, ANG_Risk_Event_Type__c> types = new Map<Id, ANG_Risk_Event_Type__c>([SELECT Id, ANG_Expiration__c FROM ANG_Risk_Event_Type__c WHERE Id IN :riskTypes]);
		Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Top_Parent__c FROM Account WHERE Id IN :accountIds]);

		for(Case c : [SELECT Id, OSCAR__c FROM Case WHERE OSCAR__c IN :oscars.keySet() AND RecordType.DeveloperName = 'OSCAR_Communication']) oscars.put(c.OSCAR__c, c.Id);

		for(ANG_Agency_Risk_Event__c re : (List<ANG_Agency_Risk_Event__c>)newObjects){

			//fetch HE account
			Account mainAccount = accounts.get(re.ANG_AccountId__c);
			if(Trigger.isExecuting && Trigger.isInsert) re.ANG_HE_AccountId__c = mainAccount.Top_Parent__c == null ? mainAccount.Id : mainAccount.Top_Parent__c;			

			if(re.ANG_OscarId__c != null) re.ANG_CaseId__c = oscars.get(re.ANG_OscarId__c);

			//correct expiration date
			re.ANG_Expiration_Date__c = re.ANG_Issued_Date__c.addMonths(Integer.valueOf(types.get(re.ANG_Risk_Type__c).ANG_Expiration__c));

			if((String.isEmpty(re.ANG_Event_Status__c) || !re.ANG_Event_Status__c.contains('_')) && !skipStatusAssignment ){
				if(re.ANG_Issued_Date__c > System.today() || re.ANG_Expiration_Date__c <= System.today()) re.ANG_Event_Status__c = 'Inactive';
				else re.ANG_Event_Status__c = 'Active';
				
				if(re.ANG_Expiration_Date__c <= System.today()) re.ANG_Expired__c = true;
			}
			
		}

		if(!Trigger.isExecuting || !Trigger.isBefore) upsert newObjects;
	}



	// ***************************************
	// ********** helper methods *************
	// ***************************************

	private Boolean checkRequisites(SObject newObject, ANG_Risk_Event_Configuration__c config) {

		//counter that checks if conditions were skipped
		Integer conditionsChecked = 0;

		SObject oldObject = objMap == null ? null : objMap.get(newObject.Id);

		//make checks against configs
		for(ANG_RiskEventConfigurationFields f : ANG_RiskEventConfigurationFields.getList()){
			String fieldName = (String)config.get(f.fieldName);
			if(fieldName == null) continue; //no condition was set

			Object fieldValue	= getValue(newObject, fieldName);
			String condition 	= (String)config.get(f.conditionField);
			String checkValue	= (String)config.get(f.valueField);

			Boolean configResult = false;

			//check if values match conditions
			if(condition.equalsIgnoreCase('Equal to') && new Set<String>(checkValue.split(';')).contains(String.valueOf(fieldValue))) 			configResult = true;
			else if(condition.equalsIgnoreCase('Not equal to') && !new Set<String>(checkValue.split(';')).contains(String.valueOf(fieldValue)))	configResult = true;

			else if(condition.equalsIgnoreCase('Blank') && fieldValue == null)					configResult = true;
			else if(condition.equalsIgnoreCase('Not blank') && fieldValue != null)				configResult = true;

			else if(condition == '>' && (Decimal)fieldValue > Decimal.valueOf(checkValue))		configResult = true;
			else if(condition == '<' && (Decimal)fieldValue < Decimal.valueOf(checkValue))		configResult = true;
			else if(condition == '>=' && (Decimal)fieldValue >= Decimal.valueOf(checkValue))	configResult = true;
			else if(condition == '<=' && (Decimal)fieldValue <= Decimal.valueOf(checkValue))	configResult = true;

			else if(condition.containsIgnoreCase('today') && fieldValue != null){
				//create a new instance so DateTime fields don't mess with the comparison
				Date d = Date.valueOf(fieldValue);
				Date dateToCheck = Date.newInstance(d.year(), d.month(), d.day());

				if(condition.equalsIgnoreCase('Equal to today') && dateToCheck == System.today())		configResult = true;
				if(condition.equalsIgnoreCase('Greater than today') && dateToCheck > System.today())	configResult = true;
				if(condition.equalsIgnoreCase('Less than today') && dateToCheck < System.today())		configResult = true;
			}

			if(!configResult) return false; //means that the conditions didn't match, no need to check others

			//check to see if field was updated (for relationship fields we check if the relationship has changed)
			if(fieldName.contains('.')){
				String relField = fieldName.substringBefore('.');
				if(relField.endsWith('__r')) relField = relField.replace('__r', '__c');
				else relField += 'Id';

				if(oldObject != null && newObject.get(relField) == oldObject.get(relField)) configResult = false;
			}
			else if(oldObject != null && fieldValue == oldObject.get(fieldName)) configResult = false;

			//only increment counter if conditions match AND the field is updated
			if(configResult) conditionsChecked++;
		}

		if(conditionsChecked == 0) return false;

		return true;
	}

	private Object getValue(SObject obj, String fieldName) {
		if(fieldName.contains('.')){
			SObject parent = obj.getSObject(fieldName.substringBefore('.'));
			if(parent == null) return null;
			return getValue(parent, fieldName.substringAfter('.'));
		}
		else return obj.get(fieldName);
	}
}