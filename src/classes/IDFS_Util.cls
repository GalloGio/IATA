global class IDFS_Util
{
    webService static String getIATACountryEmail (String caseBSPCountry)
    {        
        List<IATACountryEmail__c> cBSPCountry = IATACountryEmail__c.getAll().values();       
        for (IATACountryEmail__c countryEmail: cBSPCountry)
        {
            if (countryEmail.Name != null && countryEmail.CountryEmail__c != null)
            {
                if (countryEmail.Name.equalsIgnoreCase(caseBSPCountry))
                    return countryEmail.CountryEmail__c;
            }
        }         
        return '';
    } 
    
    webService static String getRecordTypeEmail (String caseRecordType, String caseBSPCountry)
    {        
        List<RecordTypeEmail__c> lstFromEmails = RecordTypeEmail__c.getAll().values();
        
        map<String, String> mapFromEmailPerRTKey = new map<String, String>();       
        for (RecordTypeEmail__c fromEmail : lstFromEmails)
        {
            if (fromEmail.Record_Type_Developer_Name__c != null && fromEmail.Email__c != null) {
            	mapFromEmailPerRTKey.put(fromEmail.Record_Type_Developer_Name__c + ' ' + fromEmail.Country_Name__c, fromEmail.Email__c);
            }
        }   
        
        if (mapFromEmailPerRTKey.get(caseRecordType + ' ' + caseBSPCountry) != null) {
            return mapFromEmailPerRTKey.get(caseRecordType + ' ' + caseBSPCountry);
        } else if (mapFromEmailPerRTKey.get(caseRecordType + ' Default') != null) {
            return mapFromEmailPerRTKey.get(caseRecordType + ' Default');
        }
        
        return '';
    } 
    
    webService static Boolean DeleteEmail (String messageID)
    {  
        try
        {
            EmailMessage email = [SELECT Id  FROM EmailMessage where Id=:messageID];
            delete email;
            return true;
        }
        catch (Exception e)
        {
            System.debug('** Delete Email issue '+e.getMessage());
            return false;
        }
    
    }   
              
}