/*
*  REST API Service returning the content of Id Card table
*  - Based on GSS_REST_FilePayload
*  - External class will call getFilePayload (@HttpGet) method
*  - URI Parameter:  FileSpecificationId, LastRetrievedRecordId, RequestSizeFactor
*  - Relevant requirement: GDP_File_Description__c.Payload_Procedure__c = 'IDCard' , GDP_File_Description__c.Product_Type__c = 'CAC'
*
*
*  Change log:
*   20151230-sl: Sonny Leman: initial version, based on GDP_REST_FilePayload.cls
*   20160103-sl: more clean up
*   20160407-sl: Add RequestSizeFactor parameter to allow reducing limit defined by Maximum_API_Request
*
*/

@RestResource(urlMapping='/GSS/v0/FileDataIDCard/*')
global with sharing class GDP_REST_FilePayloadIdCard {

	static final Integer BATCH_SIZE = 100;
	static final String RECORD_CODE_ID_CARD = 'ID_Card'; // this might not be relevant, but now is used for Record.RecordType
	static final String TOP_LEVEL_MAIN_OBJECT_TYPE = 'Agency'; // this should match what is defined in the GDP_File_Fields_Description__r.Group__c, used in LoadFieldStructure

	static final Boolean TestMode=false;
	static final String ENCODING_SCHEME = 'UTF-8'; // use in calling EncodingUtil class
	static Boolean isDebugQuery = false;

	// http response code definition
	private static final integer HTTP_STATUS_OK = 200;
	private static final integer HTTP_STATUS_BAD_REQUEST = 400;

	// ========================================================================
	// getFilePayload read GDP_File_Description record and collect the basic parameters
	// then it call other method to prepare the RestContext.Response
	// input parameters: FileSpecificationId, LastRetrievedRecordId
	// This version assume it is for CAC, and Payload_Procedure__c== 'IDCard'
	@HttpGet
	global static void getFilePayload()
	{
		// set RestContext.response default values, this is to allow dealing with uncatched exception
		RestContext.response.statuscode = HTTP_STATUS_BAD_REQUEST;

		// --------------------------------------------------------------------
		//Get and validate input parameters in the URL

		//Get REQUIRED FileSpecificationID parameter
		String fileSpecificationID = RestContext.request.params.get('FileSpecificationId');
		if(fileSpecificationID == '' || fileSpecificationID == null){
			throw new MyException('FileSpecificationId is required parameter');
		}

		//Get Optional lastRetrievedRecordId parameter
		//lastRetrievedRecordId will be used to recall the function to get more records than the BATCH_SIZE
		//the usage of value of lastRetrieveRecordId will also depend of related GDP_File_Description__c.Product_Type__c
		String lastRetrievedRecordIdParameter = RestContext.request.params.get('LastRetrievedRecordId');

		// Get Optional RequestSizeFactor parameter, and use it to set DividerFactor
		String RequestSizeFactorStr = RestContext.request.params.get('RequestSizeFactor');
		Integer RequestSizeFactor = (RequestSizeFactorStr == null) ? 0 : Integer.valueOf(RequestSizeFactorStr);
		RequestSizeFactor = (RequestSizeFactor == null) ? 0 : RequestSizeFactor;
		Integer DividerFactor = Integer.valueOf(Math.pow(2, RequestSizeFactor));

		//TODO: Load the SQL information from File Specification
		List<GDP_File_Description__c> fileSpecificationList = new List<GDP_File_Description__c>();
		fileSpecificationList = [SELECT Id
										,Field_Group__c
										,Field_API__c
										,Field_Visible__c
										,Field_Type__c
										,Field_Filter__c
										,Field_Filter_Value__c
										,Field_Object_Name__c
										,Frequency__c
										,Payload_Procedure__c
										,Product_Type__c
										,Reference__c
										,Reference__r.Field_Group__c
										,Reference__r.Field_API__c
										,Reference__r.Field_Visible__c
										,Reference__r.Field_Type__c
										,Reference__r.Field_Filter__c
										,Reference__r.Field_Filter_Value__c
										,Reference__r.Field_Object_Name__c
										,Reference__r.Reference_Clause__c
										,Reference__r.Service_Target__c
										,Reference__r.Maximum_API_Request__c
										,Reference__r.Payload_Procedure__c
										,Reference__r.Web_Service_Default_Response__c
										,Reference__r.Minimum_Digit_Search__c
										,Class__c
										,Magnitude__c
										,Geo_Coverage_Definition__c
										,Geo_Coverage_Definition__r.Country_Selection__c
									FROM GDP_File_Description__c
									WHERE id =: fileSpecificationId
								];
		// check that the given FileSpecificationId is valid
		if (fileSpecificationList.size()==0)
		{
			throw new MyException('GDP_File_Description record not found for FileSpecificationId='+ fileSpecificationId);
		}

		// this REST API only serves CAC ID_Card, i.e. Payload_Procedure__c = 'IDCard'
		if ( fileSpecificationList[0].Reference__r.Payload_Procedure__c != 'IDCard') {
			throw new MyException( 'This REST_API cannot process Payload_Procedure__c=' + fileSpecificationList[0].Reference__r.Payload_Procedure__c);
		}

		//the value of lastRetrieveRecordId is based on given http parameter and related GDP_File_Description__c.Product_Type__c
		String lastRetrievedRecordId = lastRetrievedRecordIdParameter; // default value for GSS
		//In the case that there is no lastRetrievedRecordId, return first records
		if(lastRetrievedRecordIdParameter == '' || lastRetrievedRecordIdParameter == null)
		{
			lastRetrievedRecordId = '000000000000000000';
		}

		// ----------------------------------------------------------------
		// If needed: Delta collection preparation is done by building the soql-query-where-clause Where_Magnitude_SOQL
		// to be added to the where_clause_soql
		// ----------------------------------------------------------------


		// Prepare the soql-query-where-clause

		//Geo Coverage
		String Where_Geo_Coverage_SOQL='';
		if (fileSpecificationList[0].Geo_Coverage_Definition__r.Country_Selection__c!=null)
		{
			Where_Geo_Coverage_SOQL = fileSpecificationList[0].Geo_Coverage_Definition__r.Country_Selection__c;
		}

		//Class Where Clause
		String Where_Class_SOQL = '';

		String where_Clause_SOQL = Where_Class_SOQL
							+ ' ' + Where_Geo_Coverage_SOQL;

		// --------------------------------------------------------------------
		// FileSpecification record is ready, now query the data file and build the RestContext.response
		queryIdCard(fileSpecificationList[0]
			, lastRetrievedRecordId
			, where_Clause_SOQL
			, fileSpecificationId
			, DividerFactor
			);


	} // getFilePayload


	// ========================================================================
	// query record from main object (ID_Card__c)
	// query from ID_Card and prepare RestContext.response
	private static void queryIdCard( GDP_File_Description__c fileSpecification
			, String lastRetrievedRecordId
			, String where_Clause_SOQL
			, String fileSpecificationID
			, Integer dividerFactor // should be 1 or bigger.
			)
	{

		//TODO retrieve LastModifiedDate From
		List<GDP_File_Production__c> fileproductionlist = new List<GDP_File_Production__c>();
		fileproductionlist = [Select Id,File_Specification__c, LastModifiedDate
								From GDP_File_Production__c
								Where File_Specification__c=:FileSpecificationID
								Limit 1];
		FieldStructureCls fieldstructure= new FieldStructureCls();

		//Based on the current File Specification record extract the Fields Arrays
		String DynamicSQL = '';
		String SOQL = '';

		//Extract Object fields
		//String AccountView_Field_API='';
		String mainObject_Field_API=''; // fields of the main object (in this case: ID_Card)
		String Address_Field_API='';
		String Address_FieldAPIList='';

		//Reference is imposing the configuration otherwise take the regular configuration
		fieldstructure.LoadFieldStructure(
						fileSpecification.Reference__c!=null ? fileSpecification.Reference__r.Field_API__c : fileSpecification.Field_API__c
						,fileSpecification.Reference__c!=null ? fileSpecification.Reference__r.Field_Type__c :fileSpecification.Field_Type__c
						,fileSpecification.Reference__c!=null ? fileSpecification.Reference__r.Field_Visible__c : fileSpecification.Field_Visible__c
						,fileSpecification.Reference__c!=null ? fileSpecification.Reference__r.Field_Filter__c : fileSpecification.Field_Filter__c
						,fileSpecification.Reference__c!=null ? fileSpecification.Reference__r.Field_Filter_Value__c : fileSpecification.Field_Filter_Value__c
						,fileSpecification.Reference__c!=null ? fileSpecification.Reference__r.Field_Object_Name__c : fileSpecification.Field_Object_Name__c
						,fileSpecification.Reference__c!=null ? fileSpecification.Reference__r.Field_Group__c : fileSpecification.Field_Group__c
						);

		// ----------------------------------------------------------------
		// Build the query for Main Table / GDP_Products_Account_View
		//Get Query to return results - use of escapeSingleQuotes to avoid SOQL injection
		//Build logic to retrieve next batch of records

		// Ordering is by mainObject record Id
		String Order_Clause = ' Order by Id';
		String Where_Last_Retrieved_Id = ' And Id > \'';

		// dynamicSql store the query string, it will be appended with more detail later
		// initialize dynamicSql #1

		//AccountView_Field_API=fieldstructure.ExtractFieldSQL('GDP_Products_Account_View__c');
		mainObject_Field_API=fieldstructure.ExtractFieldSQL('ID_Card__c'); // extract fields from main object

		DynamicSQL = 'Select Id,Agency_IATA_Code__c,' //, MDP_Sort_Key_Formula__c, '
							+ mainObject_Field_API.Replace('Id,','')
							+' From  ID_Card__c'   // set query from main object, i.e. ID_Card
							+' Where Id!=null ';

		String Where_Reference_Clause ='';
		if (fileSpecification.Reference__r.Reference_Clause__c!=null) Where_Reference_Clause = fileSpecification.Reference__r.Reference_Clause__c;
		if (Where_Reference_Clause.Trim()!='') Where_Reference_Clause =' AND ('+Where_Reference_Clause+')';

		//Build the object based on returned query value
		FilePayload myFilePayload = new FilePayload();
		List<string> recordValueList = new List<string>();

		List<ID_Card__c> myObjectRecordList = new List<ID_Card__c>(); // list of mainObject
		SOQL = String.escapeSingleQuotes(DynamicSQL);

		// NEW_BATCH_SIZE is used to limit the number of rows requested
		Integer NEW_BATCH_SIZE=BATCH_SIZE;
		if (filespecification.Reference__r.Maximum_API_Request__c!=null) NEW_BATCH_SIZE=Integer.ValueOf(filespecification.Reference__r.Maximum_API_Request__c);
		NEW_BATCH_SIZE =  Integer.valueOf(Math.floor(NEW_BATCH_SIZE / dividerFactor)) + 1;

		SOQL+= Where_Last_Retrieved_Id + lastRetrievedRecordId + '\''
			+ where_Clause_SOQL
			+ Where_Reference_Clause
			+ Order_Clause
			+ ' Limit ' + NEW_BATCH_SIZE ;
		System.debug('SOQL: '+ SOQL);


		myObjectRecordList  = database.query(SOQL);
		// at this point, the records with fields from the main object have been collected
		// next will be the related fields

		// --------------------------------------------------------------------
		// get the lookup fields
		// known lookup fields are: ID_Card_Application_c and Related_Contact__c


		//TODO:Build unique set of GDP_Account_View Ids
		//Retrieve the Airline and Territory and Address Information for the given list of GDP_Account_View Ids
		//Build a map to load the three level of information
		// -- Agency
		//    -- Mailing and Location Address
		//    -- Airline
		//        -- Territory
		Map<Id, DataStructureCls> datastructure = new Map<Id, DataStructureCls>();

		Set<String> AgencyCodeSet = new Set<String>();
		// for each record of main object (ID_Card__c) create an entry in dataStructure map
		for (ID_Card__c myObjectRecord : myObjectRecordList){
			DataStructureCls ds=new DataStructureCls(myObjectRecord);
			datastructure.put(myObjectRecord.Id,ds);
			AgencyCodeSet.Add(myObjectRecord.Agency_IATA_Code__c);
			//SLDELETE mainObjectIdSet.add(myObjectRecord.Id);
			System.Debug('myObjectRecord.Id >>>'+myObjectRecord.Id);
		}

		List<GDP_Products_Account_View__c> AgencyList  =  new List<GDP_Products_Account_View__c>();
		AgencyList = [Select Id,Agency_Code__c
						From GDP_Products_Account_View__c
						Where Agency_Status_Code__c >= 4
						and Agency_Code__c=:AgencyCodeSet
						Limit 5000];

		AgencyCodeSet=new Set<String>();
		for (GDP_Products_Account_View__c o: AgencyList){
			AgencyCodeSet.Add(o.Agency_Code__c);
		}
		// --------------------------------------------------------------------
		// add related list collection here, if necessary.
		// GSS_Products_Account_View has related list, but not ID_Card
		// --------------------------------------------------------------------


		//Get a map of all sObject fields
		Integer TYPE_API=0, TYPE_TYPE=1, TYPE_VISIBLE=2, TYPE_OBJECT=3, TYPE_FILTER=4, TYPE_VALUE=5;

		String[] FieldAPIList= fieldstructure.ExtractListByGroup(TYPE_API, TOP_LEVEL_MAIN_OBJECT_TYPE);
		String[] FieldTypeList= fieldstructure.ExtractListByGroup(TYPE_TYPE, TOP_LEVEL_MAIN_OBJECT_TYPE);
		String[] FieldFilterList= fieldstructure.ExtractListByGroup(TYPE_FILTER, TOP_LEVEL_MAIN_OBJECT_TYPE);
		String[] FieldFilterValueList= fieldstructure.ExtractListByGroup(TYPE_VALUE, TOP_LEVEL_MAIN_OBJECT_TYPE);
		String[] FieldVisibleList= fieldstructure.ExtractListByGroup(TYPE_VISIBLE, TOP_LEVEL_MAIN_OBJECT_TYPE);
		String[] FieldObjectList= fieldstructure.ExtractListByGroup(TYPE_OBJECT, TOP_LEVEL_MAIN_OBJECT_TYPE);

		// --------------------------------------------------------------------
		// process all collected dataStructure (mainObject plus related objects, if any)
		for (DataStructureCls myObjectRecord : datastructure.Values()){
			//Initialize RecordValue List
			//Iterate the list of ordered fields and build record based on list of fields
			//Process the Agency Record Fields

			myFilePayload.LastRecordID = myObjectRecord.mainObject.Id;
			if (!AgencyCodeSet.Contains(myObjectRecord.mainObject.Agency_IATA_Code__c)) continue;
			Integer Fieldindex=-1;
			for(string strAPIFieldName : FieldAPIList){
				string fieldContent ='';
				Fieldindex++;

				if (FieldObjectList[Fieldindex]=='Reserve') continue;

				// set special field content if needed

				// set fieldContent value, grouped based on the object
				// Note: The else block was intended for related list, but we have none for ID_Card__c
				if (FieldObjectList[Fieldindex]=='ID_Card__c' )
				{ // it is from the main object or its lookup
					system.debug('strAPIFieldName '+strAPIFieldName);
					if (strAPIFieldName.Contains('__r.'))
					{
						string[] fieldname= strAPIFieldName.Split('\\.');
						//System.Debug('fieldname >>>'+strAPIFieldName);
						try {
							fieldContent = String.valueOf(myObjectRecord.mainObject.getSObject(fieldname[0]).get(fieldname[1]));
						}catch(Exception e) {}
					} else {
						// normal case
						fieldContent = String.valueOf(myObjectRecord.mainObject.get(strAPIFieldName));
					} // end of if strApiFieldName __r
				}  // end if / FieldObjectList / for related list
				 else if (FieldObjectList[Fieldindex]=='GDP_File_Description__c' )
					{
						system.debug('strAPIFieldName '+strAPIFieldName);
						if (strAPIFieldName.Contains('__r.'))
						{
							string[] fieldname= strAPIFieldName.Split('\\.');
							//System.Debug('fieldname >>>'+strAPIFieldName);
							try {
								 fieldContent = String.valueOf(filespecification.getSObject(fieldname[0]).get(fieldname[1]));
								}catch(Exception e) {}
						}

						else{
							fieldContent = String.valueOf(filespecification.get(strAPIFieldName));
						}
					}
				else if (FieldObjectList[Fieldindex]=='GDP_File_Production__c' )
					{
						system.debug('strAPIFieldName '+strAPIFieldName);
						try {
							if (strAPIFieldName.Contains('__r.'))
							{
								string[] fieldname= strAPIFieldName.Split('\\.');
								//System.Debug('fieldname >>>'+strAPIFieldName);
								 fieldContent = String.valueOf(fileproductionlist[0].getSObject(fieldname[0]).get(fieldname[1]));

							}

							else{
								fieldContent = String.valueOf(fileproductionlist[0].get(strAPIFieldName));
							}
						}catch(Exception e) {}
					}

				// finalize fieldContent and set fieldStructure
				if (fieldContent == null) fieldContent = '';
				//TODO: validate the field format (date, number...)
				//May have transformation to do according of type below
				//DateTime YYYYMMDDHHMMSS
				//Date YYYMMDD
				//Decimal 0
				//Decimal 1
				//Decimal 2
				//Decimal 3
				//Make sure to blank when not visible
				if (FieldTypeList[Fieldindex]=='Boolean' &&  fieldContent=='true') fieldContent='Y';
				if (FieldTypeList[Fieldindex]=='Boolean' &&  fieldContent=='false') fieldContent='N';
				if (FieldTypeList[Fieldindex]=='Boolean' &&  fieldContent=='') fieldContent='N';
				if (FieldVisibleList[Fieldindex]=='1' && fieldContent!= '')  fieldContent = fieldstructure.TransformDate(FieldTypeList[Fieldindex], fieldContent);
				if (FieldVisibleList[Fieldindex]!='1' && fieldContent!= '')  fieldContent = '';

				fieldstructure.IdCardRecordValue[Fieldindex] = fieldContent;
				if (TestMode) fieldstructure.IdCardRecordValue[Fieldindex]=strAPIFieldName+':'+fieldContent;



			} // end of for(string strAPIFieldName : FieldAPIList)

			// add the record with at the main object level: ID_Card
			//Record myAgencyRecordValue  = new Record(fieldstructure.AgencyRecordValue, AGENCY_CODE, myObjectRecord.mainObject.Id);
			Record mainObjectRecordValue  = new Record(fieldstructure.IdCardRecordValue, RECORD_CODE_ID_CARD, myObjectRecord.mainObject.Id);

			myFilePayload.FileRecords.add(mainObjectRecordValue );


			// only if needed: non top level mainObject collection preparation here, in the case of ID_Card, there is none

		} // end for (DataStructureCls myObjectRecord : datastructure.Values())

		// --------------------------------------------------------------------
		// set RestContext.response values
		try{
			//Prepare response
			RestContext.response.addHeader('Content-Type', 'application/json');
			if(myObjectRecordList.size() == 0){
				RestContext.response.addHeader('done', 'true');
			}
			else
			{
				//Send the url used to retrieve next records
				RestContext.response.addHeader('done', 'false');
				RestContext.response.addHeader('nextRecordURL',
											URL.getSalesforceBaseUrl().toExternalForm()
											+ RestContext.request.resourcePath /* '/GSS/v01/IdCard/' */
											+'?FileSpecificationID='+FileSpecificationID
											+'&lastRetrievedRecordId='+myObjectRecordList[myObjectRecordList.size()-1].Id);
			}  // end else
			//Return FilePayload object
			RestContext.response.responseBody = Blob.valueOf(json.serialize(myFilePayload));
			RestContext.response.statusCode = HTTP_STATUS_OK; // statusCode = 200

		} catch(exception e){
			RestContext.response.statusCode = HTTP_STATUS_BAD_REQUEST; // statusCode = 400
			RestContext.response.responseBody  = Blob.valueOf(
				'getCause()' + e.getCause() + '\n' +
				'getMessage()' + e.getMessage() + '\n' +
				'getLineNumber()' + e.getLineNumber() + '\n' +
				'getStackTraceString()' + e.getStackTraceString() + '\n' +
				'getTypeName()' + e.getTypeName()
				);
		} // end catch

	} // end of queryIdCard (was part of getFilePayload)



	// ========================================================================
	// Supporting inner classes
	//
	// ========================================================================


	// ========================================================================
	//Master Field Structure
	// this is used to represent collected data, prior to generating the REST API response
	global class FieldStructureCls {
		public String[] FieldAPIName {get;set;}
		public String[] FieldType {get;set;}
		public String[] FieldVisible {get;set;}
		public String[] FieldFilter {get;set;}
		public String[] FieldFilterValue {get;set;}
		public String[] FieldObjectName {get;set;}
		public String[] FieldGroup {get;set;}
		//private String[] key;
		//Values
		public String[] IdCardRecordValue {get;set;} // main object record value
		public FieldStructureCls()
		{
		}


		// --------------------------------------------------------------------
		// loadFieldStructure
		public void LoadFieldStructure(String vFieldAPIName,
								String vFieldType,
								String vFieldVisible,
								String vFieldFilter,
								String vFieldFilterValue,
								String vFieldObjectName,
								String vFieldGroup){

			if (vFieldAPIName!=null) FieldAPIName=vFieldAPIName.Split('\\|'); //.ReplaceAll(', ',',').Split(',');
			if (vFieldType!=null) FieldType=vFieldType.Split('\\|'); //.ReplaceAll(', ',',').Split(',');
			if (vFieldVisible!=null) FieldVisible=vFieldVisible.Split('\\|'); //.ReplaceAll(', ',',').Split(',');
			if (vFieldFilter!=null) FieldFilter=vFieldFilter.Split('\\|'); //.ReplaceAll(', ',',').Split(',');
			if (vFieldFilterValue!=null) FieldFilterValue=vFieldFilterValue.Split('\\|'); //.ReplaceAll(', ',',').Split(',');
			if (vFieldObjectName!=null) FieldObjectName=vFieldObjectName.Split('\\|'); //.ReplaceAll(', ',',').Split(',');
			if (vFieldGroup!=null) FieldGroup=vFieldGroup.Split('\\|'); //.ReplaceAll(', ',',').Split(',');
			System.Debug('API_fieldname >>>'+FieldAPIName.Size());
			System.Debug('Type_fieldname >>>'+FieldType.Size());
			System.Debug('Visible_fieldname >>>'+FieldVisible.Size());
			System.Debug('Filter_fieldname >>>'+FieldFilter.Size());
			System.Debug('FilterValue_fieldname >>>'+FieldFilterValue.Size());
			System.Debug('Object_fieldname >>>'+FieldObjectName.Size());
			System.Debug('Group_fieldname >>>'+FieldGroup.Size());
			//build key

			// count the number of fields to prepare the IdCardRecordValue array length
			integer numOfFieldsMainObject = 0;
			integer i=-1;
			for(String stringvalue:this.FieldAPIName)
			{
				i++;
				if (FieldGroup[i]==TOP_LEVEL_MAIN_OBJECT_TYPE) numOfFieldsMainObject++;
			} // end for

			this.IdCardRecordValue = new String[numOfFieldsMainObject];

		} // end of LoadFieldStructure


		// --------------------------------------------------------------------
		public String ExtractFieldSQL(String ObjectName)
		{
			String stringreturn='';
			integer i=-1;
			integer m=0;
			Set<String> vkey = new Set<String>();
			for(String stringvalue:this.FieldAPIName)
			{
				i++;
				if (this.FieldObjectName[i]!=ObjectName) continue;
				if (vkey.contains(stringvalue)) continue;
				if (m>0) stringreturn +=',';
				stringreturn +=stringvalue;
				System.debug(' fieldsSoql>>>>'+ObjectName+'.'+stringvalue);
				vkey.add(stringvalue);
				m++;
			}
			return stringreturn;
		} // end of ExtractFieldSQL




		// --------------------------------------------------------------------
		//Load by Group
		public String[] ExtractListByGroup(Integer TypeList, String ObjectName)
		{
			String stringreturn='';
			integer i=-1;
			integer m=0;
			String[] ValueList;
			//Set<String> vkey = new Set<String>();
			Integer TYPE_API=0, TYPE_TYPE=1, TYPE_VISIBLE=2, TYPE_OBJECT=3, TYPE_FILTER=4, TYPE_VALUE=5;

			if (TypeList==TYPE_API) ValueList = this.FieldAPIName;
			if (TypeList==TYPE_TYPE) ValueList = this.FieldType;
			if (TypeList==TYPE_VISIBLE) ValueList = this.FieldVisible;
			if (TypeList==TYPE_OBJECT) ValueList = this.FieldObjectName;
			if (TypeList==TYPE_FILTER) ValueList = this.FieldFilter;
			if (TypeList==TYPE_VALUE) ValueList = this.FieldFilterValue;
			for(String stringvalue:ValueList)
			{
				i++;
				if (this.FieldGroup[i]!=ObjectName) continue;
				//if (vkey.contains(this.key[i])) continue;
				if (m>0) stringreturn +=',';
				stringreturn +=stringvalue;
				//vkey.add(key[i]);
				m++;
			}
			//if (stringreturn=='') return null;
			return stringreturn.Split(',');
		} // end of ExtractListByGroup
		//Load By Object

		// --------------------------------------------------------------------
		// transformDate is used ot convert the date format to desireable string
		public String TransformDate(String vFormat, String vValue)
		{
			if (!vFormat.Contains('Date')) return vValue;

			if (vValue.Trim().Length()<10) return vValue;

			if (vFormat=='Date YYYYMMDD')
			{
				vValue=vValue.Trim();
				vValue = vValue.Substring(0,4)+vValue.Substring(5,7)+vValue.Substring(8,10);
			}
			else if (vFormat=='Date YYYYMMDDHHMM')
			{
				vValue=vValue.Trim();
				vValue = vValue.Substring(0,4)+vValue.Substring(5,7)+vValue.Substring(8,10)+vValue.Substring(11,13)+vValue.Substring(14,16);
			}
			 return vValue;
		} // end of TransformDate

	} // end of FieldStructureCls

	// ========================================================================
	// Master data structure to hold the main object record, along with its related fields
	//Master data structure to hold all agencies data
	// mainObject = ID_Card__c
	global class DataStructureCls {
		//public GDP_Products_Account_View__c AccountView {get;set;}
		public ID_Card__c mainObject {get;set;} // main object type

		// in case needed, also define related object of ID_Card__c (i.e. those having lookup field to ID_Card)



		// --------------------------------------------------------------------
		//DataStructureCls Constructor
		//public DataStructureCls(GDP_Products_Account_View__c vAccountView)
		public DataStructureCls( ID_Card__c idCard)
		{
			this.mainObject=idCard;
			// in case needed, also initialize related object of ID_Card__c (i.e. those having lookup field to ID_Card)
		} // end of constructor DataStructureCls
	} // end of DataStructureCls class



	// ========================================================================
	//Definition of JSON response
	global class FilePayload {
		public String LastRecordID {get; set;} // this is set as the last ID_Card__c.Id in the batch
		public List<Record> FileRecords;
		public String SOQL {get;set;}

		//Constructor
		public FilePayload(){
			this.FileRecords = new list<Record>();
			this.SOQL='';
		} // end constructor
	} // end of FilePayload class

	// ========================================================================
	//Inner class
	// The field values for this record is passed as an array of String, and
	// those field values will be stored in Record field as string separated by '|'

	global class Record{
		public string RecordType{get; set;}
		//public list<string> aRecord;
		public string Record {get; set;}
		public string RecordId {get; set;}
		// --------------------------------------------------------------------
		//Inner class Constructor
		public Record(String[] rec, string recType, string recid  ) {
			this.RecordType = recType;
			this.RecordId = recid;

			//Escape Pipe characters in payload with %7C prior to joining the list with pipes
			//for (integer i = 0 ; i < rec.size(); i++ ){
			//  system.debug('rec['+i+']='+rec[i]);
			//  if(rec[i]!=null){
			//      rec[i]= rec[i].replace('|','%7C');
			//  }
			//}

			this.Record = String.join(rec, '|');
		} // end of Record constructor

		// --------------------------------------------------------------------
		public list<string> getRecordAsListOfString(){
			list<string> strOutList = new list<string>();
			strOutList.addAll(Record.split('\\|'));
			for (Integer i = 0; i < strOutList.size(); i++)
				strOutList[i]=strOutList[i].replaceAll('%7C','|');
			return strOutList;
		}
	} // end of Record class

	// ========================================================================
	//Custom Exception Class
	public class MyException extends Exception {}



} // end of GDP_REST_IdCard
