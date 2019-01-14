public with sharing class EF_Utilities
{
	public EF_Utilities() {		
	}

	public static void storeUpdateComments(List<sObject> objectList)
	{
		for(sObject o : objectList)
		{
			if(o.get('EF_Comments__c') != null)
			{
				String currentTime = System.now().format('dd MMM yyyy HH:mm ');
				String currentUser = UserInfo.getName();
				String comments = (String) o.get('EF_Comments__c');
				String commentsHistory = (String) o.get('EF_History__c');
				String oldHistory = '';
				if(commentsHistory == null)
					commentsHistory = '';
				oldHistory = commentsHistory;
				commentsHistory = currentTime + ' by ' + currentUser + ': ' + comments.trim() + '\n';
				commentsHistory = commentsHistory + oldHistory.trim();
				
				o.put('EF_History__c', commentsHistory);
				o.put('EF_Comments__c', '');
			}
		}
	}

	public static boolean findIfKeyFieldsChanged(sObject newValue, sObject oldValue, Map <String, Schema.SObjectField> objectFields, List<String> ignoredFields)
    {
        Set<String> toIgnore = new Set<String>{'LastModifiedById', 'LastModifiedDate', 'SystemModstamp'};
        toIgnore.addAll(ignoredFields);
        List <Schema.SObjectField> fieldsList = objectFields.values();
        List <String> APIFieldNames = new List<String>();
        for (Schema.SObjectField field : fieldsList)
        {
            APIFieldNames.add(field.getDescribe().getName());
        }
        boolean valueChanged = false;
        for(String field : APIFieldNames)
        {
            if(!toIgnore.contains(field))
            {
                if(newValue.get(field) != oldValue.get(field))
                {
                	System.debug('*********** changed: '+field + ': '+oldValue.get(field)+' -> '+newValue.get(field));
                    valueChanged = true;
                }
            }
        }
        return valueChanged;
    }

	public static List <EF_Critical_Field_Notification__c> getCriticalFields ()
	{
		//List<EF_Critical_Field_Notification__c> fieldList = [select id, name, Airline_Billing_Agreement_Fields__c, Account_Airline_Fields__c, Account_Client_Fields__c, Contact_Fields__c,Contract_Fields__c  from EF_Critical_Field_Notification__c];
		List<EF_Critical_Field_Notification__c> fieldList = EF_Critical_Field_Notification__c.getAll().values();
		return fieldList;	
	}
	
}