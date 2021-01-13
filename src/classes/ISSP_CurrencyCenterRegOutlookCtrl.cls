public with sharing class ISSP_CurrencyCenterRegOutlookCtrl {

    public List<Comment__c> commentsList {get;set;}
    public String selectedRegion {get;set;}

    public list<String> lstRegions {get; set;}


    public ISSP_CurrencyCenterRegOutlookCtrl() {
        selectedRegion = ApexPages.currentPage().getParameters().get('region');
        commentsList = [SELECT Id, ICCS_Description__c, ICCS_Source__c, ICCS_Title__c, 
                        (SELECT Id, Name, Description FROM Attachments ORDER BY CreatedDate) 
                        FROM Comment__c 
                        WHERE RecordType.DeveloperName = 'X4_Regional_Outlook_News' AND Region__c =: selectedRegion AND ICCS_Publish__c = true];

        lstRegions = new list<String>{'Americas','Africa & Middle East', 'Asia & Pacific', 'China & North Asia', 'Europe'};
    }

}