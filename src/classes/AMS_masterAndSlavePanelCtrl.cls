/**
This Controller can be used either form a Component, or a VF page as an extension.
It is loading all details from a slave obkject based on his master

*/
global class AMS_masterAndSlavePanelCtrl{

	transient global  List<Schema.DescribeSObjectResult> describeSobjectsResult {get;set;}

	transient global  SObject slaveObject {get;private set;}

	transient global  SObject masterObject {get;private set;}

	transient global  List<Pair> objectFieldsData {get;set;}

	transient global  String genericObjectLabel {get;set;}


	/**
	constructor if loaded from Component
	*/
	public AMS_masterAndSlavePanelCtrl(){

	}

	/**
	constructor if loaded from VF page
	*/
	public AMS_masterAndSlavePanelCtrl(ApexPages.StandardController stdController) {
		masterObject = stdController.getRecord();
		loadSlaveObject();

	}

	public void setMasterObject(SObject o){
		masterObject = o;
		loadSlaveObject();
	}

	/**
	Load slave Data
	*/
	private void loadSlaveObject(){
		slaveObject= null;

		List<QueryDataWrapper> queryData = loadDynamicQueryDataFromJSON();

		objectFieldsData = new List<Pair>();

		for(QueryDataWrapper qd: queryData){
			String theQuery = queryBuilder(qd);
			System.debug('Generated query: ' + theQuery);
			List<SObject> slaves = database.query(theQuery);
			if(slaves != null && slaves.size()>0){
				slaveObject = slaves.get(0);
				buildObjectDataMap(slaveObject, qd.fieldsToGet);
			}
		}

	}

	/**
	Parse the JSON file containing the information necessary to build the query
	that will retrieve field values from the slave object
	*/
	private List<QueryDataWrapper> loadDynamicQueryDataFromJSON(){

		List<QueryDataWrapper> queryDataList = new List<QueryDataWrapper>();

		boolean continueParsing = true;

		String masterObjectApiName = masterObject.getSObjectType().getDescribe().getName();

		StaticResource sr = [select Body from StaticResource where Name = 'AMS_JSON_dynamic_query'];
		String jsonstring = sr.Body.toString();
		// Create a JSON Parser from String.
		JSONParser parser = JSON.createParser(jsonstring);
		//find the master object
		while(parser.nextToken() != null && parser.getCurrentToken() != JSONToken.END_ARRAY && continueParsing){
			if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'master'){
				parser.nextToken();
					if(parser.getText() == masterObjectApiName)
						continueParsing = false;
					while(parser.nextToken() != JSONToken.END_OBJECT){
						if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'slaves'){
							while(parser.nextToken() != JSONToken.END_ARRAY){
								QueryDataWrapper queryData = new QueryDataWrapper();
								queryData.masterObj = masterObjectApiName;
								while(parser.nextToken() != JSONToken.END_OBJECT){
									if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'slave'){
										parser.nextToken();
										queryData.slave = parser.getText();
									}
									if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'masterHasRefToSlave'){
										parser.nextToken();
										queryData.masterHasRefToSlave = parser.getText();
									}

									if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'fieldToQuery'){
										parser.nextToken();
										queryData.fieldToQuery = parser.getText();
									}

									if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'fieldsToGet'){
										parser.nextToken();
										Set<String> fields = new Set<String>();
										while(parser.nextToken() != null && parser.getCurrentToken() != JSONToken.END_ARRAY){
											//get the fields to display
											fields.add(parser.getText().toLowerCase());
										}
										queryData.fieldsToGet = fields;
									}
								}
								//only save the query data when the master object is found
								if(!continueParsing)
									queryDataList.add(queryData);
							}
						}
					}
			}

		}

		for(QueryDataWrapper qd: queryDataList)
		{
			System.debug('qd slave: ' + qd.slave);
			System.debug('qd masterHasRefToSlave: ' + qd.masterHasRefToSlave);
			System.debug('qd fieldToQuery: ' + qd.fieldToQuery);
			System.debug('qd fieldsToGet: ' + qd.fieldsToGet);
		}

		return queryDataList;

	}

	/**
	Dynamically build the query
	*/
	private String queryBuilder(QueryDataWrapper qd){
		String query = 'SELECT Name, ';

		for(String s: qd.fieldsToGet){
			query += s + ', ';
		}
		query = query.substring(0, query.length()-2);
		query += ' FROM ' + qd.slave + ' WHERE ';

		if(qd.masterHasRefToSlave == 'Y')
			query += ' Id IN (SELECT ' + qd.fieldToQuery + ' FROM ' + qd.masterObj + ' WHERE Id = \'' + masterObject.Id + '\')';
		else
			query += qd.fieldToQuery + ' = \'' + masterObject.Id + '\'';

		return query;
	}

	/***

	This method is filling the 2 maps with label & Value

	*/
	private void buildObjectDataMap(SObject anObject, Set<String> fields){

		String anObjectName = slaveObject.getSObjectType().getDescribe().name;
		system.debug('[AMS_EmployeeAndPersonPanelCtrl]Object name '+anObjectName);

		List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{anObjectName});
		for(Schema.DescribeSObjectResult dr:describeSobjectsResult ){
			genericObjectLabel = dr.getName();
			system.debug('[AMS_EmployeeAndPersonPanelCtrl]generic object Name  '+genericObjectLabel);
			Map<String, Schema.SObjectField> allFields = dr.fields.getMap();

			for(String rawField: fields)
			{
				String field = normalize(rawField);
				if(allFields.keySet().contains(field))
				{
					Schema.DescribeFieldResult des = allFields.get(field).getDescribe();
					String fieldValue = getFieldValue(rawField);
					Schema.DisplayType fldType = des.getType();

					//avoid date fields to be displayed as datetime
					if(fldType == Schema.DisplayType.Date)
						if(fieldValue != '')
							fieldValue = fieldValue.substring(0,10);

					system.debug('[AMS_EmployeeAndPersonPanelCtrl] new value : '+des.getName()+ '  /   '+des.getLabel()+' / '+fieldValue);
					Pair p = new Pair(des.getLabel(), fieldValue);
					objectFieldsData.add(p);
				}

			}
		}
	}

	public class QueryDataWrapper{
		public String masterObj{get;set;}
		public String slave{get;set;}
		public String fieldToQuery{get;set;}
		public String masterHasRefToSlave{get;set;}
		public Set<String> fieldsToGet{get;set;}
	}

	public class Pair{
		public String first{get;set;}
		public String second{get;set;}

		public Pair(String first, String second){
			this.first = first;
			this.second = second;
		}

	}

	public String getFieldValue(String field){

		String fieldValue;
		if(field.containsIgnoreCase('.')){
			String theField = field.substringAfter('.');
			String relation = field.substringBefore('.');
			SObject obj = (SObject)slaveObject.getSObject(relation);
			if(obj != null)
				fieldValue = String.valueOf(obj.get(theField));
		}
		else
			fieldValue = String.valueOf(slaveObject.get(normalize(field)));

		if(fieldValue==null)
			fieldValue = '';

		return fieldValue;

	}

	/***
	Return the api name of the field.
	*/
	public static String normalize(String field){

		String fieldName;
		if(field.containsIgnoreCase('.')){
			if(!field.containsIgnoreCase('__r'))
				return field.substringBefore('.') + 'id';
			else
				return field.substringBefore('.').replace('__r','__c');
		}

		return field;
	}

}
