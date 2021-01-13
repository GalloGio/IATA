public with sharing class CountryProfileInlineHistoryController {

	private final Country_Profile__c cp;
    public List<Country_Profile_History__c> customHistoryList {get; set;}
    public List<Country_Profile__History> standardHistoryList {get; set;}
    public List<CountryProfileHistoryWrapper> historiesList {get;set;}

    public CountryProfileInlineHistoryController(ApexPages.StandardController stdController) {
        
        cp = (Country_Profile__c)stdController.getRecord();
        
        //get history records, both standard and custom
        customHistoryList = new List<Country_Profile_History__c>(
                            [SELECT Id,CreatedById,CreatedBy.Name,CreatedDate,Field__c,OldValue__c,NewValue__c 
                            FROM Country_Profile_History__c
                            WHERE Country_Profile__c =: cp.Id
                            ORDER BY CreatedDate DESC]);

        standardHistoryList = new List<Country_Profile__History>(
                            [SELECT Id,CreatedById,CreatedBy.Name,CreatedDate,Field,OldValue,NewValue
                            FROM Country_Profile__History
                            WHERE ParentId =: cp.Id
                            ORDER BY CreatedDate DESC]);

        //add custom entries
        historiesList = new List<CountryProfileHistoryWrapper>();

        for(Country_Profile_History__c history : customHistoryList){
            historiesList.add(new CountryProfileHistoryWrapper(
                                history.Id,
                                history.CreatedBy.Name,
                                history.CreatedDate,
                                history.OldValue__c,
                                history.NewValue__c,
                                history.Field__c,
                                true));
        }

        //add standard entries, if date - cut 00:00:00 ending
        for(Country_Profile__History history : standardHistoryList){
            String tmpOld = '';
            String tmpNew = '';

            if( history.OldValue != null && (String.valueOf(history.Oldvalue)).endswith('00:00:00'))
                tmpOld = Date.valueOf(history.OldValue).format();
            else
                tmpOld = String.valueOf(history.OldValue);

            if( history.NewValue != null && (String.valueOf(history.NewValue)).endswith('00:00:00'))
                tmpNew = Date.valueOf(history.NewValue).format();
            else
                tmpNew = String.valueOf(history.NewValue);

            //if empty value - set to 'blank' string
            if(tmpOld == null)
                tmpOld = '<blank>';
            if(tmpNew == null)
                tmpNew = '<blank>';

            historiesList.add(new CountryProfileHistoryWrapper(
                                history.Id,
                                history.CreatedBy.Name,
                                history.CreatedDate,
                                tmpOld,
                                tmpNew,
                                //String.valueOf(history.OldValue),
                                //String.valueOf(history.NewValue),
                                history.Field,
                                false));
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
        public String fieldName {get; set;}
        public Boolean isCustom {get; set;}

        public CountryProfileHistoryWrapper(Id id,String createdByName, Datetime createdDate, String oldValue, String newValue, String fieldName, Boolean isCustom){
            this.id = id;
            this.createdByName = createdByName;
            this.createdDate = createdDate;
            this.oldValue = oldValue;
            this.newValue = newValue;
            this.fieldName = fieldName;
            this.isCustom = isCustom;
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