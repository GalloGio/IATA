public with sharing class UserInlineHistoryController {

    private final User cp;
    public List<User_History__c> customHistoryList {get; set;}    
    public List<CountryProfileHistoryWrapper> historiesList {get;set;}

    public UserInlineHistoryController(ApexPages.StandardController stdController) {
        
        cp = (User)stdController.getRecord();
        
        //get history records, both standard and custom
        customHistoryList = new List<User_History__c>(
                            [SELECT Id,CreatedById,CreatedBy.Name,CreatedDate,What__c,Old_Value__c,New_Value__c 
                            FROM User_History__c
                            WHERE User__c =: cp.Id
                            ORDER BY CreatedDate DESC]);

        //add custom entries
        historiesList = new List<CountryProfileHistoryWrapper>();

        for(User_History__c history : customHistoryList){
            historiesList.add(new CountryProfileHistoryWrapper(
                                history.Id,
                                history.CreatedBy.Name,
                                history.CreatedDate,
                                history.Old_Value__c,
                                history.New_Value__c,
                                history.What__c,
                                true));
        }

        //sort by createddate (comparable interface methods implemented in wrapper class)
        historiesList.sort();

    }

    public class CountryProfileHistoryWrapper implements Comparable{

        public Id id {get; set;}
        public String createdByName {get; set;}
        public Datetime createdDate {get; set;}
        public String oldValue {get; set;}
        public String newValue {get; set;}
        public String what {get; set;}       

        public CountryProfileHistoryWrapper(Id id,String createdByName, Datetime createdDate, String oldValue, String newValue, String What, Boolean isCustom){
            this.id = id;
            this.createdByName = createdByName;
            this.createdDate = createdDate;
            this.oldValue = oldValue;
            this.newValue = newValue;
            this.what = What;            
        }

        public Integer compareTo(Object compareTo) {

        CountryProfileHistoryWrapper compareToDate = (CountryProfileHistoryWrapper)compareTo;
        
        Integer returnValue = 0;
        if (this.createdDate < compareToDate.createdDate) {
            returnValue = 1;
        } else if (this.createdDate > compareToDate.createdDate) {
            returnValue = -1;
        }
        
        return returnValue;       
        }

    }

}