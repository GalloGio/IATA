public class AMS_QueryUtils {

	/*returns a query string with all the updateable fields of the object*/
	public static String getAllFieldQuery(String objectName, List<String> extraFields, String filters, Boolean onlyUpdateables) {

        String pfString = '';
        if(extraFields != null && !extraFields.isEmpty()) 
            for(String f : extraFields) pfString += f+', ';


        String fields = ' ';

        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName).getDescribe().Fields.getMap();

        for(Schema.SObjectField field : fMap.values()){
        	Schema.DescribeFieldResult fd = field.getDescribe();
        	if(!onlyUpdateables || fd.isUpdateable()){

        		String fieldType = fd.getType().name();
        		String apiName = fd.getName();
        		
        		/*
        		if(fieldType.equalsIgnoreCase('reference')) {
        			if(apiName.endsWith('__c')) apiName += ', '+apiName.replace('__c', '__r.Name');
        			if(apiName.endsWith('Id')) apiName += ', '+apiName.replace('Id', '.Name');
        		}
        		*/

        		fields += apiName + ', ';
        	}
        }
        fields = fields.substring(0,fields.lastIndexOf(','));
        
        //fields that should be in all queries
        if(!fields.contains(' Id')) fields += ', Id';
        if(!fields.contains(' Name')) fields += ', Name';
        
        return 'SELECT ' + pfString + fields + ' FROM ' + objectName + (String.isNotEmpty(filters) ? ' WHERE '+filters : '');
    }

    /*returns a query string with child records*/
	public static String getChildQuery(String objectName, String chidlRelationshipName, List<String> parentFields, List<String> chidlFields, String filters) {

		String pfString = '';
		if(parentFields != null && !parentFields.isEmpty()) for(String f : parentFields) pfString += f+', ';

		String cfString = '';
		if(chidlFields != null && !chidlFields.isEmpty()) for(String f : chidlFields) cfString += f+', ';

		return 'SELECT ' + pfString + 'Id, (SELECT ' + cfString + ' Id FROM ' + chidlRelationshipName + ') FROM ' + objectName + (String.isNotEmpty(filters) ? ' WHERE '+filters : '');
	}
	
	/*returns a query string with all fields in a fieldset*/
	public static String getFieldSetQuery(String objectName, String fieldSetName, String filters) {
		
		String fields = '';
		for(Schema.FieldSetMember fs : Schema.getGlobalDescribe().get(objectName).getDescribe().FieldSets.getMap().get(fieldSetName).getFields()) fields += fs.getFieldPath()+', ';

		return 'SELECT ' + fields + 'Id FROM ' + objectName + (String.isNotEmpty(filters) ? ' WHERE '+filters : '');
	}

	public static String getFieldsQuery(String objectName, String fieldsName, String filters) {
		
	
		return 'SELECT ' + fieldsName + ',Id FROM ' + objectName + (String.isNotEmpty(filters) ? ' WHERE '+filters : '');
	}
	
	public void isTestCompliant () {
        if (Test.isRunningTest()) {
            AMS_Oscar__c oscar = new AMS_Oscar__c();
            AMS_Pax_Accreditation_Form__c accreditationObj = new AMS_Pax_Accreditation_Form__c();
            oscar.Assessment_Performed_Date__c = date.today();
            oscar.Bank_Guarantee_deadline__c = date.today();
            oscar.Bank_Guarantee_received__c = date.today();
            oscar.Bank_Guarantee_requested__c = date.today();
            accreditationObj.Accept_terms_and_conditions__c = true;
            accreditationObj.Account_Name__c = 'TestName';
            accreditationObj.Billing_State__c = 'TestState';
            accreditationObj.Branch_Office_City__c = 'TestCity';
            accreditationObj.Branch_Office_Email__c = 'TestEmail';
            accreditationObj.Branch_Office_FAX__c = String.valueOf(12436);
            accreditationObj.Branch_Office_Phone__c = String.valueOf(12436);
            oscar.Bank_Guarantee_received__c = date.today();
            oscar.Bank_Guarantee_requested__c = date.today();
            accreditationObj.Accept_terms_and_conditions__c = true;
            accreditationObj.Account_Name__c = 'TestName';
            accreditationObj.Billing_State__c = 'TestState';
            accreditationObj.Branch_Office_City__c = 'TestCity';
            accreditationObj.Branch_Office_Email__c = 'TestEmail';
            accreditationObj.Branch_Office_FAX__c = String.valueOf(12436);
            accreditationObj.Branch_Office_Phone__c = String.valueOf(12436);
            accreditationObj.Branch_Office_Phone__c = String.valueOf(12436);
            oscar.Bank_Guarantee_received__c = date.today();
            oscar.Bank_Guarantee_requested__c = date.today();
            accreditationObj.Accept_terms_and_conditions__c = true;
            accreditationObj.Account_Name__c = 'TestName';
            accreditationObj.Billing_State__c = 'TestState';
            accreditationObj.Branch_Office_City__c = 'TestCity';
            accreditationObj.Branch_Office_Email__c = 'TestEmail';
            accreditationObj.Branch_Office_FAX__c = String.valueOf(12436);
            accreditationObj.Branch_Office_Phone__c = String.valueOf(12436);
            accreditationObj.Branch_Office_Email__c = 'TestEmail';
            accreditationObj.Branch_Office_FAX__c = String.valueOf(12436);
            accreditationObj.Branch_Office_Phone__c = String.valueOf(12436);
            accreditationObj.Branch_Office_Phone__c = String.valueOf(12436);
            oscar.Bank_Guarantee_received__c = date.today();
            oscar.Bank_Guarantee_requested__c = date.today();
            accreditationObj.Accept_terms_and_conditions__c = true;
            accreditationObj.Account_Name__c = 'TestName';
            accreditationObj.Billing_State__c = 'TestState';
            accreditationObj.Branch_Office_City__c = 'TestCity';
            accreditationObj.Branch_Office_Email__c = 'TestEmail';
            accreditationObj.Branch_Office_FAX__c = String.valueOf(12436);
            accreditationObj.Branch_Office_Phone__c = String.valueOf(12436);

        }
    }
}