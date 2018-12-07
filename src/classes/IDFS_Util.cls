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

    public static final String STR_DEFAULT = 'Default';
    webService static String getRecordTypeEmail (String caseRecordType, String caseBSPCountry, String caseGroup)
    {
        List<RecordTypeEmail__c> lstFromEmails = RecordTypeEmail__c.getAll().values();

        map<String, String> mapFromEmailPerRTKey = new map<String, String>();
        for (RecordTypeEmail__c fromEmail : lstFromEmails)
        {
            if (fromEmail.Record_Type_Developer_Name__c != null && fromEmail.Email__c != null
                && fromEmail.Case_Group__c != null) {
                String key = fromEmail.Record_Type_Developer_Name__c + ' ' + fromEmail.Country_Name__c + ' ' + fromEmail.Case_Group__c;
                mapFromEmailPerRTKey.put(key, fromEmail.Email__c);
            }
        }
        
        String email;
        email = mapFromEmailPerRTKey.get(caseRecordType + ' ' + caseBSPCountry + ' ' + caseGroup);
        if (email!=null) return email;
        
        email = mapFromEmailPerRTKey.get(caseRecordType + ' ' + caseBSPCountry + ' ' + STR_DEFAULT);
        if (email!=null) return email;
        
        email = mapFromEmailPerRTKey.get(caseRecordType + ' ' + STR_DEFAULT + ' ' + caseGroup);
        if (email!=null) return email;
        
        email = mapFromEmailPerRTKey.get(caseRecordType + ' ' + STR_DEFAULT + ' ' + STR_DEFAULT);
        if (email!=null) return email;
        
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

    public class IDFS_Exception extends Exception{}

    /**
        Function to create an Internal case using IDFS Complaint
        This is used in a custom button 'Request Operational Improvement'
    **/
    webService static String createInternalCase(String caseId) {
        system.savepoint sp = Database.setSavePoint();
        try {
            Case cse = [
                Select Id, Subject, Region__c, Reason1__c, Country__c, CaseArea__c, BSPCountry__c, Complaint_Analysis__c
                from Case where id =:caseId];

            Id rtInternalCase = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'InternalCasesEuropeSCE');//InternalCasesEuropeSCE

            Case newCase = new Case(
                RecordtypeId = rtInternalCase,
                Subject = 'Root Cause Analysis - Operational Improvement Request',
                ParentId = cse.Id,
                Region__c = cse.Region__c,
                BSPCountry__c = cse.BSPCountry__c,
                CaseArea__c = 'Business Delivery',
                Reason1__c = 'Operational Improvement',
                Description = cse.Complaint_Analysis__c
            );
            applyAssignmentRule(newCase, 'FDS Support Assignment');
            insert newCase;
            return newCase.Id;

        } catch (Exception e) {
            Database.rollback(sp);
            throw new IDFS_Exception( e.getdmlMessage(0) );
        }
    }

    /**
        Find the a case assignment rule and applies it to the input case
        this case must be inserted in database after this method is called
    **/
    public static void applyAssignmentRule(Case cse, String assignmentRuleName) {
        try {
            AssignmentRule asignmentRule = [
                select id
                from AssignmentRule
                where SobjectType = 'Case'
                and Active = true
                and Name = :assignmentRuleName];

            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId = asignmentRule.id;
            cse.setOptions(dmlOpts);

        } catch (Exception e) {
            System.debug('ERROR in applyAssignmentRule, Case assignment rule "' + assignmentRuleName + '" not found');
        }
    }

}