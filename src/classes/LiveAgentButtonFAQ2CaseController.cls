public with sharing class LiveAgentButtonFAQ2CaseController {

    public String selectedTopics {
        get{
            return ApexPages.currentPage().getParameters().get('selTopics');
        }
        set;
    }
    public String topicLabel {
        get{
            return ApexPages.currentPage().getParameters().get('topiclbl');
        }
        set;
    }
    public String subTopicLabel{
        get{
            return ApexPages.currentPage().getParameters().get('subtopiclbl');
        }
        set;
    }
    public String csButton{
        get{
            return ApexPages.currentPage().getParameters().get('csButton');
        }
        set;
    }
    public String countryConcerned{
        get{
            return ApexPages.currentPage().getParameters().get('concernedCountry');
        }
        set;
    }
    public LiveAgentButtonSettings__c liveAgentBtn {
        get{
            LiveAgentButtonSettings__c labs = new LiveAgentButtonSettings__c();
            try{
                labs = LiveAgentButtonSettings__c.getAll().get(csButton);
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'{!$Label.LiveAgentCustomSettingNotFound} '+e));
            }
            return labs ;
        }
    }
    public String buttonLanguage{
        get{
            try{
                buttonLanguage = liveAgentBtn.Language__c;
            }catch(Exception e){
                buttonlanguage = 'en';
            }
        return buttonLanguage;
        }
        set;
    }
    public Contact userContact {
        get{
            if (userContact == null){
                User user = DAL_ISSP.getUser(Userinfo.getUserId());
                userContact = DAL_ISSP.getContact(user.contactId);
            }
            return userContact;
        }
        set;
    }

    public Id getContactId() {
        if (userContact != null){
            return userContact.Id;
        }
        return null;
    }

    public Id getAccountId() {
        if (userContact != null){
            return userContact.AccountId;
        }
        return null;
    }

    public String getContactFirstName() {
        if (userContact != null){
            if (userContact.FirstName != null && userContact.FirstName != ''){
                return userContact.FirstName;
            }
        }
        return 'Guest';
    }

    public String getCaseRecordTypeId() {

         return RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get(caseRecordTypeName);
    }

    private String countryRegion{
        get{
            IATA_ISO_Country__c country = [SELECT Id, Name, ISO_Code__c, Region__c
                                            FROM IATA_ISO_Country__c
                                            WHERE Case_BSP_Country__c != null AND Case_BSP_Country__c != '' AND Name = :countryConcerned
                                            LIMIT 1][0];
            return country.Region__c;
        }
        set;
    }

    private String caseRecordTypeName{
        get{
            if (countryRegion == 'Europe'){
                return 'CasesEurope';
            }else if(countryRegion == 'Americas'){
                return 'CasesAmericas';
            }else if(countryRegion == 'Africa & Middle East'){
                return 'CasesMENA';
            }else if(countryRegion == 'Asia & Pacific'){
                return 'ExternalCasesIDFSglobal';
            }else if(countryRegion == 'China & North Asia'){
                return 'Cases_China_North_Asia';
            }
            return null;
        }
    }

    public LiveAgentButtonFAQ2CaseController() {

    }
}