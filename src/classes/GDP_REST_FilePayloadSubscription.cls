/*
*  REST API Service returning the content of Subscription table
*  - Based on GSS_REST_FilePayload
*  - External class will call getFilePayloadSubscription (@HttpGet) method
*  - URI Parameter:  FileSpecificationId, LastRetrievedRecordId, RequestSizeFactor
*  - Original writer: Abdellah Bellahssan
*
*  Change log:
*   20160407-sl: Add RequestSizeFactor parameter to allow reducing limit defined by Maximum_API_Request
*
*/


@RestResource(urlMapping='/GSS/v0/FileDataSubscription/*')
global with sharing class GDP_REST_FilePayloadSubscription {
	static final Integer BATCH_SIZE = 100;
	static final String AGENCY_CODE='AG';
	static final Integer MAX_TERRITORY=22;
	static final Boolean TestMode=false;
	static final String ENCODING_SCHEME = 'UTF-8'; // use in calling EncodingUtil class

	@HttpGet
	global static void getFilePayloadSubscription() {

		//try{
			//Get and validate input parameters in the URL
			//Get REQUIRED FileSpecificationID parameter
			String FileSpecificationID = RestContext.request.params.get('FileSpecificationId');
			if(FileSpecificationID == '' || FileSpecificationID == null)    throw new MyException('FileSpecificationID is required parameter');



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
			List<GDP_File_Description__c> filespecificationlist = new List<GDP_File_Description__c>();
			filespecificationlist = [SELECT Id
											,Field_Group__c
											,Field_API__c
											,Field_Visible__c
											,Field_Type__c
											,Field_Filter__c
											,Field_Filter_Value__c
											,Field_Object_Name__c
											,Frequency__c
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
											,Magnitude__c
										 FROM GDP_File_Description__c
										 WHERE id =: FileSpecificationID
										   ];
			//TODO: Make sure to have File Specification or Reference File Specification to process
			if (filespecificationlist.size()==0)
			{

			}
			// NEW_BATCH_SIZE is used to limit the number of rows requested
			Integer NEW_BATCH_SIZE=BATCH_SIZE;
			if (filespecificationlist[0].Reference__r.Maximum_API_Request__c!=null) NEW_BATCH_SIZE=Integer.ValueOf(filespecificationlist[0].Reference__r.Maximum_API_Request__c);
			NEW_BATCH_SIZE =  Integer.valueOf(Math.floor(NEW_BATCH_SIZE / dividerFactor)) + 1;

			//TODO retrieve LastModifiedDate From
			List<GDP_File_Production__c> fileproductionlist = new List<GDP_File_Production__c>();
			fileproductionlist = [Select Id,File_Specification__c, LastModifiedDate
									From GDP_File_Production__c
									Where File_Specification__c=:FileSpecificationID
									Limit 1];

			//the value of lastRetrieveRecordId is based on given http parameter and related GDP_File_Description__c.Product_Type__c
			String lastRetrievedRecordId = lastRetrievedRecordIdParameter; // default value for GSS
			//In the case that there is no lastRetrievedRecordId, return first records
			if (lastRetrievedRecordIdParameter == '' || lastRetrievedRecordIdParameter == null) lastRetrievedRecordId = '000000000000000000';

			FieldStructureCls fieldstructure= new FieldStructureCls();

			//Based on the current File Specification record extract the Fields Arrays
			String DynamicSQL = '';
			String SOQL = '';
			//Extract Address Fields
			String ObjectView_Field_API='';


			//Reference is imposing the configuration otherwise take the regular configuration
			fieldstructure.LoadFieldStructure(
							filespecificationlist[0].Reference__c!=null ? filespecificationlist[0].Reference__r.Field_API__c : filespecificationlist[0].Field_API__c
							,filespecificationlist[0].Reference__c!=null ? filespecificationlist[0].Reference__r.Field_Type__c :filespecificationlist[0].Field_Type__c
							,filespecificationlist[0].Reference__c!=null ? filespecificationlist[0].Reference__r.Field_Visible__c : filespecificationlist[0].Field_Visible__c
							,filespecificationlist[0].Reference__c!=null ? filespecificationlist[0].Reference__r.Field_Filter__c : filespecificationlist[0].Field_Filter__c
							,filespecificationlist[0].Reference__c!=null ? filespecificationlist[0].Reference__r.Field_Filter_Value__c : filespecificationlist[0].Field_Filter_Value__c
							,filespecificationlist[0].Reference__c!=null ? filespecificationlist[0].Reference__r.Field_Object_Name__c : filespecificationlist[0].Field_Object_Name__c
							,filespecificationlist[0].Reference__c!=null ? filespecificationlist[0].Reference__r.Field_Group__c : filespecificationlist[0].Field_Group__c
							);

			// ----------------------------------------------------------------
			// Build the query for GDP_Products_Account_View
			//Get Query to return results - use of escapeSingleQuotes to avoid SOQL injection
			//Build logic to retrieve next batch of records

			// MDP uses different record sorting
			String Order_Clause = ' Order by Id'; // this is the default, i.e. for non MDP
			String Where_Last_Retrieved_Id = ' And Id > \'';


			ObjectView_Field_API=fieldstructure.ExtractFieldSQL('CAC_Subscription_Detail__c');

			DynamicSQL = 'Select Id,'
								+ ObjectView_Field_API.Replace('Id,','')
								+' From CAC_Subscription_Detail__c '
								+' Where Id!=null ';

			String Where_Reference_Clause ='';
			if (filespecificationlist[0].Reference__r.Reference_Clause__c!=null) Where_Reference_Clause = filespecificationlist[0].Reference__r.Reference_Clause__c;
			if (Where_Reference_Clause.Trim()!='') Where_Reference_Clause =' AND ('+Where_Reference_Clause+')';
			//Build the object based on returned query value
			FilePayload myFilePayload = new FilePayload();
			List<string> recordValueList = new List<string>();
			Set<Id> idobjectviewset = new Set<Id>();

			List<CAC_Subscription_Detail__c> myObjectRecordList = new List<CAC_Subscription_Detail__c>();
			SOQL = String.escapeSingleQuotes(DynamicSQL);
			//SOQL+=' AND Id > \'' + lastRetrievedRecordId + '\''
			SOQL+= Where_Last_Retrieved_Id + lastRetrievedRecordId + '\''
								 + Where_Reference_Clause
								 + Order_Clause
								 +' Limit ' + NEW_BATCH_SIZE ;
			System.debug('SOQL: '+ SOQL);
			myObjectRecordList  = database.query(SOQL);

			//TODO:Build unique set of GDP_Account_View Ids
			//Retrieve the Airline and Territory and Address Information for the given list of GDP_Account_View Ids
			//Build a map to load the three level of information
			// -- Agency
			//    -- Mailing and Location Address
			//    -- Airline
			//        -- Territory
			Map<Id, DataStructureCls> datastructure = new Map<Id, DataStructureCls>();
			for (CAC_Subscription_Detail__c myObjectRecord : myObjectRecordList){
				  DataStructureCls ds=new DataStructureCls(myObjectRecord);
				  datastructure.put(myObjectRecord.Id,ds);
				  idobjectviewset.add(myObjectRecord.Id);
				  System.Debug('myObjectRecord.Id >>>'+myObjectRecord.Id);
			}

			//TODO:Sub objects to read
			String[] ObjectList = new string[]  {};


			for(String stringObjectName:ObjectList)
			{
				String Object_Field_API=fieldstructure.ExtractFieldSQL(stringObjectName);
				If (Object_Field_API!='')
				{
					//Build the DynamicSQL for the addresses
					//TODO: Filter Field to Extract to inject in the Query Filter Filer = Filter Value
					String FilterClause = fieldstructure.ExtractFilterSOQL(stringObjectName);
					String Object_Filters=fieldstructure.ExtractFilterSQL(stringObjectName, Object_Field_API);
					//Query Builder
					DynamicSQL = 'Select Id,Related_CAC_Subscription_Detail__c,'
									+ String.escapeSingleQuotes(Object_Field_API)
									+ String.escapeSingleQuotes(Object_Filters)
									+' From '+stringObjectName
									+' WHERE Related_CAC_Subscription_Detail__c in :idobjectviewset'
									+ FilterClause
									+' Order by Related_CAC_Subscription_Detail__c';
					List<SObject> mySObjectList = new List<SObject>();
					SOQL = String.escapeSingleQuotes(DynamicSQL);
					System.debug('DynamicSQL: '+ DynamicSQL);
					mySObjectList  = database.query(DynamicSQL);
					String mapkey='';
					String uniquekey='';
					//TODO: Build the uniqueness of the key per object
					String[] ObjectUniqueFilterValue = fieldstructure.ExtractUniqueFilterValue(stringObjectName);
					// key value = Object name + id or Filter value
					Set<String> filterkey = new Set<String>();
					for (SObject objectRecord: mySObjectList ){
						System.Debug('objectRecord >>>'+objectRecord);
						Id objectkey=(Id) objectRecord.get('Related_CAC_Subscription_Detail__c');
						DataStructureCls ds = (DataStructureCls) datastructure.get(objectkey);
						mapkey=objectRecord.Id;
						uniquekey =  mapkey;
						//TODO: Let see if filter value exist if so the unique key = object name + filter value
						//TODO: Making sure the key is built according to the filter value

						if (filterkey.Contains(uniquekey)) continue;
						//Assign each object to the right Map
						if (stringObjectName=='GDP_Phone__c') {ds.Phones.Put(mapkey,(GDP_Phone__c) objectRecord); continue;}
						if (stringObjectName=='Agency_Owner__c') {ds.Owners.Put(mapkey,(Agency_Owner__c) objectRecord); continue;}


					}
				}
			}
			//Just in case where the list is not empty

			//Get a map of all sObject fields
			Integer TYPE_API=0, TYPE_TYPE=1, TYPE_VISIBLE=2, TYPE_OBJECT=3, TYPE_FILTER=4, TYPE_VALUE=5;


			String[] FieldAPIList= fieldstructure.ExtractListByGroup(TYPE_API,'Agency');
			String[] FieldTypeList= fieldstructure.ExtractListByGroup(TYPE_TYPE,'Agency');
			String[] FieldFilterList= fieldstructure.ExtractListByGroup(TYPE_FILTER,'Agency');
			String[] FieldFilterValueList= fieldstructure.ExtractListByGroup(TYPE_VALUE,'Agency');
			String[] FieldVisibleList= fieldstructure.ExtractListByGroup(TYPE_VISIBLE,'Agency');
			String[] FieldObjectList= fieldstructure.ExtractListByGroup(TYPE_OBJECT,'Agency');


			for (DataStructureCls myObjectRecord : datastructure.Values()){
				//Initialize RecordValue List
				//Iterate the list of ordered fields and build record based on list of fields
				//Process the Agency Record Fields
				Integer Fieldindex=-1;
				for(string strAPIFieldName : FieldAPIList){
					string fieldContent ='';
					Fieldindex++;
					if (FieldObjectList[Fieldindex]=='Reserve') continue;

					if (FieldObjectList[Fieldindex]==''){ //No objects are associated with functions

					}
					else if (FieldObjectList[Fieldindex]=='CAC_Subscription_Detail__c' )
					{
						system.debug('strAPIFieldName '+strAPIFieldName);

						if (strAPIFieldName.Contains('__r.'))
						{
							string[] fieldname= strAPIFieldName.Split('\\.');
							//System.Debug('fieldname >>>'+strAPIFieldName);
							try {
								 fieldContent = String.valueOf(myObjectRecord.ObjectView.getSObject(fieldname[0]).get(fieldname[1]));
								}catch(Exception e) {}
						}

						else{
							fieldContent = String.valueOf(myObjectRecord.ObjectView.get(strAPIFieldName));
						}
					}
					else if (FieldObjectList[Fieldindex]=='GDP_File_Description__c' )
					{
						system.debug('strAPIFieldName '+strAPIFieldName);
						if (strAPIFieldName.Contains('__r.'))
						{
							string[] fieldname= strAPIFieldName.Split('\\.');
							//System.Debug('fieldname >>>'+strAPIFieldName);
							try {
								 fieldContent = String.valueOf(filespecificationlist[0].getSObject(fieldname[0]).get(fieldname[1]));
								}catch(Exception e) {}
						}

						else{
							fieldContent = String.valueOf(filespecificationlist[0].get(strAPIFieldName));
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
					 else
					{
						//System.Debug('Index_fieldname >>>'+Fieldindex);
						string ObjectMapId  = myObjectRecord.RetrieveObjectMapId(FieldObjectList[Fieldindex]
																				,FieldFilterList[Fieldindex]
																				,FieldFilterValueList[Fieldindex]);
						if (ObjectMapId!='')
						{
							if (strAPIFieldName.Contains('__r.'))
							{
								string[] fieldname= strAPIFieldName.Split('\\.');
								//System.Debug('fieldname >>>'+strAPIFieldName);
								try {
									if (FieldObjectList[Fieldindex]=='GDP_Phone__c') fieldContent = String.valueOf(myObjectRecord.Phones.get(ObjectMapId).getSObject(fieldname[0]).get(fieldname[1]));
									if (FieldObjectList[Fieldindex]=='Agency_Owner__c') fieldContent = String.valueOf(myObjectRecord.Owners.get(ObjectMapId).getSObject(fieldname[0]).get(fieldname[1]));


								}catch(Exception e) {}
							}
							else
							{
								if (FieldObjectList[Fieldindex]=='GDP_Phone__c') fieldContent = String.valueOf(myObjectRecord.Phones.Get(ObjectMapId).get(strAPIFieldName));
								if (FieldObjectList[Fieldindex]=='Agency_Owner__c') fieldContent = String.valueOf(myObjectRecord.Owners.Get(ObjectMapId).get(strAPIFieldName));

							}
						}
					}


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
					fieldstructure.AgencyRecordValue[Fieldindex]=fieldContent;
					if (TestMode) fieldstructure.AgencyRecordValue[Fieldindex]=strAPIFieldName+':'+fieldContent;



				}
				//Addition of the Agency record Line
				Record myAgencyRecordValue  = new Record(fieldstructure.AgencyRecordValue, AGENCY_CODE,myObjectRecord.ObjectView.Id);
				myFilePayload.FileRecords.add(myAgencyRecordValue );
				myFilePayload.LastRecordID = myObjectRecord.ObjectView.Id;




			}

			RestContext.response.statuscode = 200;

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
											+ RestContext.request.resourcePath /* '/GSS/v0/FileData/' */
											+'?FileSpecificationID='+FileSpecificationID
											+'&lastRetrievedRecordId='+myObjectRecordList[myObjectRecordList.size()-1].Id);
			}  // end else
			//Return FilePayload object
			RestContext.response.responseBody = Blob.valueOf(json.serialize(myFilePayload));
		}
		catch(exception e){
			RestContext.response.statuscode = 400;
			RestContext.response.responseBody  = Blob.valueOf(

				'getCause()' + e.getCause() + '\n' +
				'getMessage()' + e.getMessage() + '\n' +
				'getLineNumber()' + e.getLineNumber() + '\n' +
				'getStackTraceString()' + e.getStackTraceString() + '\n' +
				'getTypeName()' + e.getTypeName()
			);
		} // end catch

	} // end of getFilePayload
	//Transform Date

	//Master Field Structure
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
		public String[] AgencyRecordValue {get;set;}
		public FieldStructureCls()
		{
		}
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
			//Agency
			integer mAgency=0;
			integer i=-1;
			for(String stringvalue:this.FieldAPIName)
			{
				i++;
				if (FieldGroup[i]=='Agency') mAgency++;
			}

			this.AgencyRecordValue = new String[mAgency];

		} // end of LoadFieldStructure

		public String[] ExtractUniqueFilterValue(String ObjectName)
		{
			String stringreturn='';
			integer i=-1;
			integer m=0;
			String skey='';
			Set<String> vkey = new Set<String>();
			for(String stringvalue:this.FieldAPIName)
			{
				i++;
				if (this.FieldObjectName[i]!=ObjectName) continue;
				if (FieldFilter[i].Trim()=='' || FieldFilterValue[i].Trim()=='') continue;
				skey=FieldFilter[i].Trim() + '~'+ FieldFilterValue[i].Trim();
				if (vkey.contains(skey)) continue;
				if (m>0) stringreturn +='|';
				stringreturn +=skey;
				vkey.add(skey);
				m++;
			}
			return stringreturn.Split('|');
		} // end of ExtractUniqueFilterValue

		public String ExtractFilterSOQL(String ObjectName)
		{
			String stringreturn='';
			integer i=-1;
			integer m=0;
			String skey='';
			Set<String> vkey = new Set<String>();
			// Make the describe call
			// Get the fields
			integer vtype=0;

			//Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
			//Map <String, Schema.SObjectField> fieldMap = schemamap.get(ObjectName).getDescribe().fields.getMap();
			Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap();

			system.debug('this.FieldObjectName >>>'+this.FieldObjectName.Size());
			system.debug('this.FieldAPIName >>>'+this.FieldAPIName.Size());
			system.debug('this.FieldFilter >>>'+this.FieldFilter.Size());

			for(String stringvalue:this.FieldAPIName)
			{
				try{
					i++;
					system.debug('stringvalue >>>'+stringvalue + 'Filter>>>'+ FieldFilter[i].Trim());
					if (this.FieldObjectName[i]!=ObjectName) continue;
					if (FieldFilter[i].Trim()=='' || FieldFilterValue[i].Trim()=='') continue;
					skey=FieldFilter[i].Trim() +  FieldFilterValue[i].Trim();
					if (vkey.contains(skey)) continue;
					if (m>0) stringreturn +=' OR ';
					//TODO: Verify against DescribeObject what is the type of the field filter
					vtype=0;

					Schema.DisplayType fielddataType=fieldMap.get(FieldFilter[i].toLowerCase()).getDescribe().getType();

					//Anything that does not need to be in between \'\'
					if (fielddataType==Schema.DisplayType.Currency) vtype=2;
					if (fielddataType==Schema.DisplayType.Percent) vtype=2;
					if (fielddataType==Schema.DisplayType.Boolean) vtype=2;
					if (fielddataType==Schema.DisplayType.Double) vtype=2;
					if (fielddataType==Schema.DisplayType.Integer) vtype=2;
					if (fielddataType==Schema.DisplayType.Picklist) vtype=1;
					if (fielddataType==Schema.DisplayType.MultiPicklist) vtype=1;

					system.debug('stringvalue >>>'+FieldFilter[i].toLowerCase()+' '+vtype);
					if (vtype==0)
						stringvalue =  '(' + FieldFilter[i] + '=\''+ FieldFilterValue[i] +'\')';
					else if (vtype==1)
						stringvalue =  '(' + FieldFilter[i] + ' IN (\''+ FieldFilterValue[i] +'\'))';
					else
						stringvalue =  '(' + FieldFilter[i] + '='+ FieldFilterValue[i] +')';
					system.debug('stringvalue >>>'+stringvalue);
					stringreturn +=stringvalue;
					vkey.add(skey);
					m++;
				}catch(Exception e) {}
			}
			if (stringreturn!='') stringreturn = ' AND ( '+stringreturn+' )';
			return stringreturn;
		}
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
		public String ExtractFilterSQL( String ObjectName, String SQOLField)
		{
			String stringreturn='';
			integer i=-1;
			integer m=0;
			Set<String> vkey = new Set<String>();
			String[] fieldinsoql=SQOLField.Split('\\,');
			for(String stringvalue:fieldinsoql)
			{
				vkey.add(stringvalue);
			}
			for(String stringvalue:this.FieldFilter)
			{
				i++;
				if (this.FieldObjectName[i]!=ObjectName) continue;
				if (vkey.contains(stringvalue)) continue;
				if (m>0) stringreturn +=',';
				stringreturn +=stringvalue;
				vkey.add(stringvalue);
				m++;
			}
			if (stringreturn!='') stringreturn =','+stringreturn;
			return stringreturn;
		} // end of ExtractFieldSQL
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

	}
	//Master data structure to hold all agencies data
	global class DataStructureCls {
		public CAC_Subscription_Detail__c ObjectView {get;set;}
		public Map<String, GDP_Phone__c> Phones {get;set;} //Related_CAC_Subscription_Detail__c //Phone_Type__c
		public Map<String, Agency_Owner__c> Owners {get;set;} //Related_CAC_Subscription_Detail__c //Percent__c


		//Find the unique key
		//Is there a unique Key to use or nothing
		//Object Name
		//Filter Field
		//Filter Value
		public String RetrieveObjectMapId(String vObjectName, String vFilter, String vFilterValue){
			boolean selected=true;
			String ObjectMapId='';
			if (vObjectName=='GDP_Phone__c'){
				if (Phones.Size()==0) return '';
				for(GDP_Phone__c objectrecord:Phones.Values()){
					// 2015-11-16 [Samy] : Fixing issue with repeating accreditation even if there is only one on record
					if ((vFilter=='' || vFilterValue=='')) { ObjectMapId=String.ValueOf(objectrecord.id); selected=false;}
					else if (String.ValueOf(objectrecord.get(vFilter))==vFilterValue) return String.ValueOf(objectrecord.id);
				}
			}
			else if (vObjectName=='Agency_Owner__c'){
				if (Owners.Size()==0) return '';
				for(Agency_Owner__c objectrecord:Owners.Values()){
					// 2015-11-16 [Samy] : Fixing issue with repeating accreditation even if there is only one on record
					if ((vFilter=='' || vFilterValue=='')) { ObjectMapId=String.ValueOf(objectrecord.id); selected=false;}
					else if (String.ValueOf(objectrecord.get(vFilter))==vFilterValue) return String.ValueOf(objectrecord.id);
				}
				return ObjectMapId;
			}

			return ObjectMapId;
		}

		//DataStructureCls Constructor
		public DataStructureCls(CAC_Subscription_Detail__c vObjectView)
		{
			this.ObjectView=vObjectView;


		}
	}

	//Definition of JSON response
	global class FilePayload {
		public String LastRecordID {get; set;} // this can be set by GDP_Product_Account_View__c.Id or urlEncode(MDP_Sort_Key_Formula__c)
		public List<Record> FileRecords;
		public String SOQL {get;set;}

		//Constructor
		public FilePayload(){
			this.FileRecords = new list<Record>();
			this.SOQL='';
		}
	}

	//Inner class
	//TODO this can be ajusted as needed and concatenated split by pipe or other. For now it is a list of string (discussed with Sony)
	global class Record{
		public string RecordType{get; set;}
		//public list<string> aRecord;
		public string Record {get; set;}
		public string RecordId {get; set;}
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
		}

		public list<string> getRecordAsListOfString(){
			list<string> strOutList = new list<string>();
			strOutList.addAll(Record.split('\\|'));
			for (Integer i = 0; i < strOutList.size(); i++)
				strOutList[i]=strOutList[i].replaceAll('%7C','|');
			return strOutList;
		}
	}
	//Custom Exception Class
	public class MyException extends Exception {}

}
