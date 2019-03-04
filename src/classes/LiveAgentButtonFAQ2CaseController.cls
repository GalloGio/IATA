/*
***************************************************************************************************************************************************** 
* Visualforce Page Name:    ClientRelationships.page    
* Apex class Name:          CLiveAgentButtonFAQ2CaseController.cls
* Test Class:               
* Description:              Apex controller related with CLiveAgentButtonFAQ2Case page to show live agent chat buttons
* Author:                   
* Date:                     
* 
* Changes control (When, Why, Who, What):
*       ------------------------------------------------------------------------------------------------------------------------------------------
*           Version date:          Case:                 Author:                                 Description:
*       ------------------------------------------------------------------------------------------------------------------------------------------
*           07-09-2017									 Right IT Services						 Live Agent V2 Project
*
*****************************************************************************************************************************************************
*/

	//
    //  Method name :   
    //  @description:   
    //  @param      :   
    //  @return     :   
    //
public with sharing class LiveAgentButtonFAQ2CaseController {

	//
	//	Variables passed by the URL
	//
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

    public String topicId {
        get{
        	string topicId = ApexPages.currentPage().getParameters().get('topicId');
        	topicId = topicId.replace('__c','');
        	topicId = topicId.replace('_',' ');
            return topicId;
        }
        set;
    }
   

    public String subTopicId{
        get{
        	String subtopic = ApexPages.currentPage().getParameters().get('subTopicId');
        	subtopic = subtopic.replace('__c','');
        	subtopic = subtopic.replace('_',' ');
            return subtopic;
        }
        set;
    }
    
    public String csButton{
        get{
            return ApexPages.currentPage().getParameters().get('csButton');
        }
        set;
    }
    public String csButtonAbreviation{
        get{
            String retVal='Button Not Found';
            LiveAgentButtonSettings__c labs = new LiveAgentButtonSettings__c();
            try{
                labs = LiveAgentButtonSettings__c.getAll().get(csButton);
                System.debug('basto1p - csButtonAbreviation csButton='+csButton+'; labs='+labs);
                retVal=labs.Language__c.trim().left(2).toUpperCase();
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'{!$Label.LiveAgentCustomSettingNotFound} '+e));
            }
            System.debug('basto1p - csButtonAbreviation retVal='+retVal);
            return retVal;
        }
        set;
    }

    public String countryConcerned{
        get{
            return ApexPages.currentPage().getParameters().get('concernedCountry');
        }
        set;
    }
    public String csButtonCategory{
        get{
            String csButtonCategoryAux=ApexPages.currentPage().getParameters().get('csButtonCategory');
            System.debug('basto1p - csButtonCategory csButtonCategoryAux='+csButtonCategoryAux);
            return csButtonCategoryAux;
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

    //ACAMBAS - WMO-436 - Begin
    public Account getAccount() {
        if (userContact != null) {
            Account acc = [SELECT Id, Name, Identify_as_Key_Customer__c FROM Account WHERE Id =: userContact.AccountId LIMIT 1][0];
            return acc;
        }
        return null;
    }
    //ACAMBAS - WMO-436 - End

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

         return RecordTypeSingleton.getInstance().getRecordTypeId('Case', caseRecordTypeName);
    }

    public IATA_ISO_Country__c country{
        get{

            if (country == null && !String.isBlank(countryConcerned)){
                country = IATAIsoCountryDAO.getIsoCountryByIsoCodes(new Set<String>{countryConcerned}).get(0);
                if(country.Case_BSP_Country__c == null || country.Case_BSP_Country__c == '')
                    country = null;
            }
            return country;
        }
        set{

        }
    }

    private String caseRecordTypeName{
        get{
            if (country.Region__c == 'Europe'){
                return 'CasesEurope';
            }else if(country.Region__c == 'Americas'){
                return 'CasesAmericas';
            }else if(country.Region__c == 'Africa & Middle East'){
                return 'CasesMENA';
            }else if(country.Region__c == 'Asia & Pacific'){
                return 'ExternalCasesIDFSglobal';
            }else if(country.Region__c == 'China & North Asia'){
                return 'Cases_China_North_Asia';
            }
            //default value in order to do not return null
            return 'InternalCasesEuropeSCE';
        }
    }
    
    
    /*******************************************************************************************************
    * @description: constructor
    *
    * @param:
    *
    * @return:
    *
    * @example
    * this.isAllowedCode('AirlineEnglishptEurope');
    *
    * @history
    * -----------------------------------------------------------------------------------------------
    * Date         Created by                                 Description
    * ????-??-??   ???????                                    Creation
    * 2017-09-11   francisco.estanqueiro@rightitservices.com  Update for live agent v2 (get all buttons names)
    ********************************************************************************************************/
    public LiveAgentButtonFAQ2CaseController() {
    	
    	String allButtonsAux = ApexPages.currentPage().getParameters().get('csButtonsListJson');			//FME
    	System.debug('#### FME #### all button '+allButtonsAux);									//FME

        AllButtons =(Map<String,vfISSP_FAQ2Case.ButtonsInfoType>)JSON.deserialize(
                                    allButtonsAux,
                                    Map<String, vfISSP_FAQ2Case.ButtonsInfoType>.class);
        System.debug('basto1p -  LiveAgentButtonFAQ2CaseController.AllButtons='+AllButtons);
    }
    
    
    //
    // AllBiuttons - to keep the buttons
    //
    Map<String,vfISSP_FAQ2Case.ButtonsInfoType> AllButtons = new Map<String,vfISSP_FAQ2Case.ButtonsInfoType>();
    
    Public Integer NumberOfButtons {
    	get{
    		return Allbuttons.size();
    	}
    	set;
    }
    
    
    //basto1p - live agent v2
    public Boolean isEmergency {
    	 get{
             Boolean result;

             result=(csButtonCategory == vfISSP_FAQ2Case.BUT_CAT_EMERGENCY);

             System.debug('basto1p - isEmergency.result='+result);

             return result;
        }
        set;
    }
    
    public LiveAgentButtonSettings__c liveAgentBtnEng {
        get{
            return getButSettingsFromButCategory(vfISSP_FAQ2Case.BUT_CAT_ENGLISH);
        }
    }

    public LiveAgentButtonSettings__c liveAgentBtnCountry {
        get{
            return getButSettingsFromButCategory(vfISSP_FAQ2Case.BUT_CAT_COUNTRY);
        }
    }

    public LiveAgentButtonSettings__c liveAgentBtnPortal {
        get{
            return getButSettingsFromButCategory(vfISSP_FAQ2Case.BUT_CAT_PORTAL);
        }
    }

    public LiveAgentButtonSettings__c getButSettingsFromButCategory(String butCategory){
        LiveAgentButtonSettings__c buttonSettings = new LiveAgentButtonSettings__c();

        try{
            System.debug('basto1p - getButSettingsFromButCategory GET butCategory='+butCategory);
            if (allButtons.containsKey(butCategory)){
                buttonSettings = LiveAgentButtonSettings__c.getAll().get(allButtons.get(butCategory).Name);
            }
            System.debug('basto1p - getButSettingsFromButCategory.buttonSettings='+buttonSettings);

        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'{!$Label.LiveAgentCustomSettingNotFound} '+e));
        }

        return buttonSettings;

    }
    
}