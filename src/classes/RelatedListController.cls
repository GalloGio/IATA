public with sharing class RelatedListController {

	String objectLabel;
	String objectLabelPlural;
	Boolean showUpdateButton;
	public Boolean massUpdateValues {get; set;}
	public Boolean isEditable {get; set;}
	public ApexPages.StandardSetController ssc {get; set;}
	public String sortByField {get; set;}
	public List<String> fieldNames {get; set;}
	public Map<Id,String> errorMap {get; set;}
	public Map<String,String> fieldAlignMap {get; set;}
	public Map<String,String> nameLabelMap {get; set;}
	public Map<String,Boolean> updatableFieldsMap {get; private set;}
	public Map<String,String> fieldSortDirectionMap {get; set;}
	transient Schema.DescribeSObjectResult objectDescribe;
	public Id deleteRecordId {get; set;}
	public Boolean isAllOrNone {get; set;}
	public Boolean hasErrors {get; private set;}
	public Boolean inlineEditMode {
	get{
		if (getshowUpdateButton() && defaultEditMode){
			inlineEditMode = defaultEditMode;
		}
		return inlineEditMode;}
	set;
	}
	public List<String> updatableFields;
	//----Variables set from attributes defined in the component----
	public Boolean defaultEditMode {get; set;}
	public String objectApiName {get; set;}
	public String csvFields {get; set;}
	public String csvEditableFields {get; set;}
	public List<String> listFields {get; set;}
	public String parentFieldApiName {get; set;}
	public Id parentId {get; set;}
	public String filterCriteria {get; set;}
	public String orderByFieldNameOnLoad {get; set;}
	public String sortOrder {get; set;}
	public Integer pageSetSize {get; set;}

	public List<sObject> topRecord {get {

		if (this.topRecord == null) {

			return new List<sObject> { Schema.getGlobalDescribe().get(objectApiName).newSObject() };
		}

		return this.topRecord;
	} set;}

	public List<sObject> getRecords(){
		if(ssc == null){
			//Do validation to ensure required attributes are set and attributes have correct values
			//fieldList or csvFields must be defined
			Boolean validationPass = true;


			if(listFields == null && csvFields == null){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'fieldList or csvFields attribute must be defined.'));
				validationPass = false;
			}


			//Ensure sortDirection attribute has value of 'asc' or 'desc'
			if(sortOrder != null && sortOrder != 'asc' && sortOrder != 'desc'){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'sortOrder attribute must have value of "asc" or "desc"'));
				validationPass = false;
			}


			//Ensure parentId is not null
			if(parentId == null){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'parentId attribute can not be null'));
				validationPass = false;
			}


			//Proceed with returning the related list if validation passed
			if(validationPass == false){
				return null;
			}else{
				//Build the query string dynamically
				String queryString = 'SELECT ';

				/*If field CSV was defined use this and also add fields to the fieldNames
				List so they can be used with Visualforce dynamic binding to define coloumns*/
				if(csvFields != null){
					csvFields = csvFields.removeStart('[').removeEnd(']').replaceAll(' ', ''); //accepts json lists
					queryString += csvFields;
					fieldNames = csvFields.split(',');
				}else{
					//Add fields to fieldNames list so it can be used with VF dynamic binding to define coloumns
					fieldNames = listFields.clone();

					//Loop through list of field names in fieldList and add to query
					for(String fld : listFields){
						queryString += fld + ',';
					}

					//Remove the very last comma that was added to the end of the field selection part of the query string
					queryString = queryString.substring(0,queryString.length() - 1);
				}

				//add from object and parent criteria
				queryString += ' FROM ' + objectApiName + ' WHERE ' + parentFieldApiName + ' = \'' + parentId + '\'';

				//Add any addtional filter criteria to query string if it was defined in component
				if(filterCriteria != null){
					queryString += 'AND ' + filterCriteria;
				}

				//Add order by field to query if defined in component
				//If sortByField != null then user has clicked a header and sort by this field
				if(sortByField != null){
					queryString += 'order by ' + sortByField;
				}else if(orderByFieldNameOnLoad != null){
					queryString += 'order by ' + orderByFieldNameOnLoad;
				}

				//If sortByField != null then user has clicked a header, sort based on values stored in map
				if(sortByField != null){
					/*Use a map to store the sort direction for each field, on first click of header sort asc
					and then alternate between desc*/
					if(fieldSortDirectionMap == null){
						fieldSortDirectionMap = new Map<String,String>();
					}

					String direction = '';

					//check to see if field has direction defined, if not or it is asc, order by asc
					if(fieldSortDirectionMap.get(sortByField) == null || fieldSortDirectionMap.get(sortByField) == 'desc' ){
						direction = 'asc';
						fieldSortDirectionMap.put(sortByField,'asc');
					}else{
						direction = 'desc';
						fieldSortDirectionMap.put(sortByField,'desc');
					}

					queryString += ' ' + direction;
				}else if(sortOrder != null){
					//Add sort direction to query if defined in component
					queryString += ' ' + sortOrder;
				}

				//Add limit clause to end of the query
				queryString += ' limit ' + (Limits.getLimitQueryRows() - Limits.getQueryRows());

				system.debug('query string: ' + queryString);

				//Query records and setup standard set controller for pagination
				ssc = new ApexPages.StandardSetController(Database.query(queryString));

				//Check to see if more than 10,000 records where return, if so display warning as standard set controller can only process 10,000 recores
				if(ssc.getCompleteResult() == false){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'There were more related records than could be processed. This is a partially complete list.'));
				}

				//Set pagination size based on value set in component
				if(pageSetSize != null){
					ssc.setpageSize(pageSetSize);
				}

				/*For the fields that will be displayed identify the field type and set styleClass for
				cell alignment. Numbers, Currency, %, etc should align right in table. put in map FieldName -> class name*/
				//Get the meta data info for the fields is the related object
				Map<String, Schema.SObjectField> fieldMap = getObjectDescribe().fields.getMap();

				//For the fields in the related list populate fieldAlignMap map with the name of the correct style class. Also populate name->label map for header display
				fieldAlignMap = new Map<String,String>();
				nameLabelMap = new Map<String,STring>();
				updatableFieldsMap = new Map<String,Boolean>();
				for(String fld : fieldNames){
					String fieldType = fieldMap.get(fld).getDescribe().getType().name();

					if(fieldType == 'CURRENCY' || fieldType == 'DOUBLE' || fieldType == 'PERCENT' || fieldType == 'INTEGER'){
						fieldAlignMap.put(fld,'alignRight');
					}else{
						fieldAlignMap.put(fld,'alignLeft');
					}

					//Add to name->label map
					String label = fieldMap.get(fld).getDescribe().getLabel();
					nameLabelMap.put(fld,label);

					//populate map of updatable fields
					updatableFieldsMap.put(fld,getIsEditable(fld));
				}
			}
		}
		return ssc.getRecords();
	}

	public Boolean getShowNewButton(){
		//Display new button if user has create permission for related object
		return getObjectDescribe().isCreateable();
	}

	public Boolean getshowUpdateButton(){
		//Display edit button if user has update permission for related object
		return getObjectDescribe().isUpdateable();
	}

	public Boolean getIsEditable(String fieldName){
		Set<String> fieldsSet = new Set<String>(getUpdatableFields());
		return fieldsSet.contains(fieldName);
	}

	public List<String> getUpdatableFields(){
		if(csvEditableFields != null){
			updatableFields = csvEditableFields.split(',');
		}else if(updatableFields == null){
			updatableFields =  new List<String>();
		}
		return updatableFields;
	}

	public void setUpdatableFields(List<String> editableFields){
		if(updatableFields == null && csvEditableFields == null && editableFields != null){
			updatableFields = editableFields;
		}
	}

	public DescribeSObjectResult getObjectDescribe(){
		/*Returns object describe for related list object. This is used in many places so we are using a dedicated method that only invokes
		Schema describe calls once as these count against Apex limits. Because this methodo returns a DescribeSObjectResult all the get
		methods for this object can be used directly in Visualforce: {!objectDescribe.label}*/
		if(objectDescribe == null){
			objectDescribe = Schema.getGlobalDescribe().get(objectApiName).getDescribe();
		}
		return objectDescribe;
	}

	public void sortByField(){
		//Making ssc variable null will cause getRecords method to requery records based on new sort by field clicked by user
		ssc = null;
	}

	public void deleteRecord(){
		//Delete the selected object
		for(sObject obj : ssc.getRecords()){
			if(obj.get('Id') == deleteRecordId){
				delete obj; break;
			}
		}

		/*There is no way to modify the collecton used in a standard set controller so we will make it null and call getRecord
		method. This will reload the set of records*/
		//Save the current page number so we can keep user on same page in the set after delete
		Integer pageNumber = ssc.getPageNumber();

		//Make ssc variable null and execute get method
		ssc = null;
		getRecords();

		/*Set the correct page number. If record deleted was a single record on the last page set the number of pages in
		the new set will decrease by 1, need to check for this. If the total number of pages is less than than the previous
		page number set the current page to the previous last page - 1 */
		Decimal rSize = ssc.getResultSize();
		Decimal pageSetSize = ssc.getpageSize();

		if(( rSize / pageSetSize).round(System.RoundingMode.UP) < pageNumber){
			ssc.setPageNumber(pageNumber - 1);
		}else{
			ssc.setPageNumber(pageNumber);
		}
	}

	public PageReference cancelChanges(){
		ssc = null;
		String idUrl =  ApexPages.currentPage().getParameters().get('id');
		String retUrl =  ApexPages.currentPage().getParameters().get('retURL');
		String prUrl;
		if(retUrl != null) prUrl =''+retUrl;
		else if(idUrl != null) prUrl ='/'+idUrl;
		PageReference pageRef = new PageReference(prURL);
		return pageRef;
	}

	public void updateRecords(){
		hasErrors = false;
		inlineEditMode = false;
		errorMap = new Map<Id,String>();
		Set<Id> recordIds = new Set<Id>(new Map<Id,SObject>(getRecords()).keySet());

		for (id key: recordIds){
			errorMap.put(key,'');
		}

		try{
			List<DataBase.SaveResult> results = Database.update(ssc.getRecords(), isAllOrNone);

			for(Integer i = 0; i < results.size(); i++){

				if (results[i].isSuccess()){
					continue;
				}

				List<Database.Error> errors = results[i].getErrors();

				if (errors != null && !errors.isEmpty()){
					hasErrors = true;
					inlineEditMode = true;
					String errorString = null;

					for(Integer j = 0; j < errors.size(); j++){
						if (j == 0){
							errorString = errors[j].getFields()+': '+ errors[j].getMessage();
						}else{
							errorString += '\n'+ errors[j].getFields()+': '+ errors[j].getMessage();
						}
					}
					errorMap.put(getRecords()[i].Id, errorString);
				}else{
					inlineEditMode = false;
				}
			}

		}catch (Exception e){
			inlineEditMode = true;
			//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'An error occured while updating\n'+e.getMessage()));
		}
	}

	public void changeInlineEditMode(){
		if (defaultEditMode == true){
			inlineEditMode = true;

		}else if (inlineEditMode == false || inlineEditMode == null){
			inlineEditMode = true;

		}else{
			inlineEditMode = false;
		}
	}

}
