public class clsCustomCaseListController{
        List<Case> cList;
        User u = [Select id, contactid from User where id =: +UserInfo.getUserId()];
         ID IFAPcaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Review');

        public List<Case> getCList() {
                //if(cList== null) cList= [select casenumber, subject, status, CreatedDate, Deadline_Date__c, IFAP_Financial_Year__c from Case where contactid =: u.contactId];
                if(cList== null) cList= [select casenumber, subject, status, CreatedDate, Deadline_Date__c, IFAP_Financial_Year__c from Case where recordTypeId =: IFAPcaseRecordTypeID  and contactid =: u.contactId and status NOT IN ('Closed')];
                return cList;

        }

}