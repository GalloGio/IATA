/**
 * 
 */
public with sharing class ISSP_SearchResultCO {

	public Enum SearchValueType { Numeric, Text, Other }

	//basto1p
	public Map<String,String> mapFieldsValue {get;set;}

	private static List<String> sortedObjNameList; 
    private static Map<String, List<Schema.FieldSetMember>> objName2tableColumnMap;  
	private static Map<String, List<Schema.FieldSetMember>> object2SearchFieldMap; 
	 //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}

	static {
        try {
			searchPreparation();	
        } 
        catch(Exception exp)  {
            ISSP_Utilities.addErrorMessage(exp); 
        }
	}

	public ISSP_SearchResultCO() {
	}
    

	public static void searchPreparation() {
		List<ISSPPortalSearchListView__c> portalSearchSettingList = ISSPPortalSearchListView__c.getAll().values();

		ISSP_PermissionFilterFactory.ProfilePermissionFilter theProfileFilter = ISSP_PermissionFilterFactory.createProfilePermissionFilter();
		ISSP_PermissionFilterFactory.PermissionSetFilter thePermissionSetFilter = ISSP_PermissionFilterFactory.createPermissionSetFilter(portalSearchSettingList, 'Permission_set__c');
		
        
		Map<String, ISSPPortalSearchListView__c> allowSearchSettingMap = new Map<string,ISSPPortalSearchListView__c>();
        for(ISSPPortalSearchListView__c searchSettingItem : portalSearchSettingList){
        	
        	Boolean resultPermission1 = true; 
        	if(!theProfileFilter.isDataEmpty(searchSettingItem, 'Profiles_Id__c'))
        		resultPermission1 = theProfileFilter.isUserPermittedFor(searchSettingItem, 'Profiles_Id__c');
        	 
        	Boolean resultPermission2 = true; 
        	if(!thePermissionSetFilter.isDataEmpty(searchSettingItem, 'Permission_set__c')) 
            	resultPermission2 = thePermissionSetFilter.isUserPermittedFor(searchSettingItem, 'Permission_set__c');
            	
            if(resultPermission1 && resultPermission2) {
            	if(String.isNotBlank(searchSettingItem.Field_Set_Table_Columns__c)) 
                	allowSearchSettingMap.put(searchSettingItem.Object_API_Name__c,searchSettingItem);
            }
        }

        objName2tableColumnMap = new Map<String, List<Schema.FieldSetMember>>();
        object2SearchFieldMap = new Map<String, List<Schema.FieldSetMember>>();
        sortedObjNameList = new List<String>();

        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 

        for(String objectName : allowSearchSettingMap.keySet()) {
        	ISSPPortalSearchListView__c searchSettingItem = allowSearchSettingMap.get(objectName);

        	Map<String, Schema.FieldSet> fieldSetMap = globalDescribeMap.get(objectName)
        															    .getDescribe()
        															    .fieldSets
        															    .getMap();

        	List<Schema.FieldSetMember> fsTableColumns = fieldSetMap.get(searchSettingItem.Field_Set_Table_Columns__c).getFields();
			objName2tableColumnMap.put(objectName, fsTableColumns); 
			
			if(String.isNotBlank(searchSettingItem.Field_Set_Filter__c)) {
				List<Schema.FieldSetMember> fsConditionFieldList = fieldSetMap.get(searchSettingItem.Field_Set_Filter__c).getFields();       	
				object2SearchFieldMap.put(objectName, fsConditionFieldList);
			}

            sortedObjNameList.add(searchSettingItem.Object_API_Name__c);
        }


	}
	public String searchText { get; set;}
	private SearchValueType oneSearchValueType {get; set;}

	public List<ResultContainer> viewList { 
		get {
			if(null == viewList) viewList = new List<ResultContainer>();
			return viewList; 
		} 
		set; 
	} 

	public PageReference searchGet() {
		try {
			String inputQuery = Apexpages.currentPage().getParameters().get('q');	
            search(inputQuery);
		} catch(Exception exp) {
			ISSP_Utilities.addErrorMessage(exp);
		}
		return null;
	}

	public PageReference searchPost() {
		try {
			String inputQuery = Apexpages.currentPage().getParameters().get('query');	
            search(inputQuery);
		} catch (Exception exp) {
			ISSP_Utilities.addErrorMessage(exp);
		}
		return null; 
	}

	/**
	 * [prepareQuery description]
	 * @param  searchText [description]
	 * @return            [description]
	 */
	public static String prepareQuery(String searchText) {
		String query = searchText.trim();
		return query;
	}


	public void search(String inputQuery) {
		this.searchText = prepareQuery(inputQuery);
		if(String.isBlank(searchText)) { 
			viewList.clear();
			return;
		}

		//slSearch(searchText);	
		qlSearch();	

	}

    
	public void qlSearch() {
	
		if(ISSP_Utilities.isNumeric(this.searchText)) 
			oneSearchValueType = SearchValueType.Numeric; 
		else
			oneSearchValueType = SearchValueType.Text;
		
		viewList.clear();
        	
		for(Integer x = 0; x < sortedObjNameList.size(); x++) {
			String objectName = sortedObjNameList[x];	
            
			List<Schema.FieldSetMember> searchFieldSetMemberList = object2SearchFieldMap.get(objectName);
			List<Schema.FieldSetMember> tableColumnList = objName2tableColumnMap.get(objectName);
			List<sObject> resultList = getSoqlSearchObjectList(objectName, searchFieldSetMemberList, tableColumnList);

			if(ISSP_Utilities.isNotEmpty(resultList))
				viewList.add(new ResultContainer(resultList));
		}		
	}

	public static String getTheFieldName(String objectName) {
		return 'Case'.equalsIgnoreCase(objectName) ? 'CaseNumber' : 'Name'; 
	}

	public List<sObject> getSoqlSearchObjectList(String objectName,
        										 List<Schema.FieldSetMember> searchFieldSetMemberList, 
		                                         List<Schema.FieldSetMember> tableColumnList) {
		String conditional = '';
		String generalFieldName = getTheFieldName(objectName);

        if(ISSP_Utilities.isNotEmpty(searchFieldSetMemberList)) {
			for(Schema.FieldSetMember fsMember: searchFieldSetMemberList) 
				conditional += operator(fsMember);
    	}

		String soqlQuery = generalFieldName;
		Boolean hasStatus = false;

		for(Schema.FieldSetMember tbMember : tableColumnList) {

			if(!generalFieldName.equalsIgnoreCase(tbMember.getFieldPath())){

				soqlQuery += ',' + tbMember.getFieldPath();

				if(tbMember.getFieldPath().equalsIgnoreCase('Status')){

					hasStatus = true;

				}
			} 	
		}

		//basto1p
		if (objectName == 'Case'){
			
			soqlQuery += ', Contact.Name';

			if (!hasStatus) {
				soqlQuery += ', Status';
			}
		}
		
		soqlQuery = 'SELECT ' + soqlQuery + ' FROM '+ objectName;
        if(String.isNotBlank(conditional)){
        	if (objectName == 'Case')
        		soqlQuery += ' WHERE (' + conditional.substring(4);
        	else
        		soqlQuery += ' WHERE ' + conditional.substring(4);
        }
        
        if (objectName == 'Case')
        	soqlQuery += ') AND Visible_on_ISS_Portal__c = true AND RecordType__c != \'IATA Financial Review\' Limit 10000';
        else
        	soqlQuery += ' Limit 10000';
        system.debug('soqlQuery >> ' + soqlQuery);

		//basto1p
		List<SObject> objList=new List<Case>();
		objList=Database.query(soqlQuery);

		if (objectName == 'Case') {
			system.debug('basto1p - getCases.casesList='+objList);


			mapFieldsValue=new Map<String, String>();
			String statusFieldValMapKey='';
			for (SObject Item : objList) {

				System.debug('basto1p - Item.get(Status)='+Item.get('Status'));
				//Add mapping for Status field
				statusFieldValMapKey = ISSP_Case.STATUS_FLD_NAME + Item.get('Status');
				mapFieldsValue.put(statusFieldValMapKey,
						ISSP_Case.getFieldMappedValue(ISSP_Case.STATUS_FLD_NAME, (String)Item.get('Status')));

				system.debug('basto1p - mapFieldsValue='+mapFieldsValue);
			}
		}
		return objList;
	}

    private String operator(Schema.FieldSetMember fsMember) {
        
        if(fsMember.getType() == Schema.DisplayType.Double
           || fsMember.getType() == Schema.DisplayType.Integer 
           || fsMember.getType() == Schema.DisplayType.PERCENT
           || fsMember.getType() == Schema.DisplayType.Currency) {
           
            return (SearchValueType.Numeric == this.oneSearchValueType) ? ' OR ' + fsMember.getFieldPath() + ' = '  + this.searchText : '';
        }
        else if(fsMember.getType() == Schema.DisplayType.Combobox
                || fsMember.getType() == Schema.DisplayType.Phone
                || fsMember.getType() == Schema.DisplayType.Picklist
                || fsMember.getType() == Schema.DisplayType.String
                || fsMember.getType() == Schema.DisplayType.TextArea 
				|| fsMember.getType() == Schema.DisplayType.URL	) {
                    
            return ' OR ' + fsMember.getFieldPath() + ' like \'%'  + this.searchText + '%\'';           
            
        }
        else if(fsMember.getType() == Schema.DisplayType.MultiPicklist) {
            return ' OR ' + fsMember.getFieldPath() + ' includes(\''  + this.searchText + '\')'; 
        }
        else
            return '';
        
    }
    /*
	public void slSearch(String searchText) {

		String soslQuery = 'FIND \'' + prepareQuery(searchText) + '\'' + ' IN ALL FIELDS RETURNING ';

		String partQuery = '';
		for(Integer x = 0; x < sortedObjNameList.size(); x++) {
			String objectName = sortedObjNameList[x];
			list<String> fieldList = objName2FieldMap.get(objectName);
			partQuery += ',' + objectName + '(' + String.join(fieldList, ',')	+ ')';
		}

		soslQuery += partQuery.substring(1);
		//todo add conditionals (where)
		soslQuery += ' limit 2000';
		system.debug('soslQuery >> ' + soslQuery);

		List<List<SObject>> resultObjList = search.query(soslQuery);
		viewList.clear();
		for(Integer rind = 0; rind < resultObjList.size(); rind++) {
			if(ISSP_Utilities.isNotEmpty(resultObjList[rind]))
				viewList.add(new ResultContainer(resultObjList[rind]));
		}
	}

	private String testQuery() {
		String query = 'FIND \'Tester\' IN ALL FIELDS RETURNING Account (Id, Name, Quality__c, Industry, Site, Field_Head_Office__c,BillingCountry,BillingCity,Location_Type__c)'
		             + ',Contact(Id, Name, Status__c, Title, AccountId, Account_site__c, Phone, Email, Financial_Assessment_Contact__c)'
					 + ',Case(Id, CaseNumber, Subject, Country_concerned_by_the_query__c, CreatedDate, Status)';
		return query;

	}*/

	public class ResultContainer {

		//public Boolean isNotEmpty 			{ get; set; }
		public String  objectLabel 			{ get; set; }
		public String  objectName  			{ get; set; }	 
		public List<SObject> theObjectList  { get; set; }
		public List<Schema.FieldSetMember>  fieldNameList	{ get; set; }

		public ResultContainer(List<SObject> objList) {

			//this.isNotEmpty = ISSP_Utilities.isNotEmpty(objList);
			//if(!this.isNotEmpty) return;

			this.theObjectList = objList;
			DescribeSObjectResult  dsoResult = objList[0].getSObjectType().getDescribe();

			this.objectName = dsoResult.getName();
			this.objectLabel = dsoResult.getLabelPlural(); 
            this.theFieldLabel = dsoResult.fields.getMap().get(theFieldName).getDescribe().getLocalName();
            
            fieldNameList = new List<Schema.FieldSetMember>();
            list<Schema.FieldSetMember> fsMembers = objName2tableColumnMap.get(this.objectName);
            for(Integer x = 0; x < fsMembers.size(); x++) {
                Schema.FieldSetMember member = fsMembers[x];
                if(!member.getFieldPath().equalsIgnoreCase(this.theFieldName))
                    fieldNameList.add(member);
            }
			//this.fieldNameList = new List<Schema.FieldSetMember>(objName2tableColumnMap.get(this.objectName));
		}

		public String theFieldName {
			get {
				return ISSP_SearchResultCO.getTheFieldName(this.objectName);
			}
		}

		public String theFieldLabel { get; set; }
        
        
	} 
}