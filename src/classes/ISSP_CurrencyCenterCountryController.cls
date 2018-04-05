public with sharing class ISSP_CurrencyCenterCountryController {

    private final Country_Profile__c cp;

    public List<Task> taskList {get;set;}
    public List<Event> eventList {get;set;}
    public List<ActionWrapper> futureActionList {get;set;}
    public List<ActionWrapper> pastActionList {get;set;}

    public List<Attachment> attList {get;set;}
    public List<AttWrapper> attGI {get;set;}
    public List<AttWrapper> attBSP {get;set;}
    public List<AttWrapper> attCASS {get;set;}
    public List<AttWrapper> attEconomic {get;set;}
    public List<AttWrapper> attCurr {get;set;}
    public List<AttWrapper> attRP {get;set;}
    public List<AttWrapper> attIC {get;set;}
    public List<AttWrapper> attICCS {get;set;}
    public List<AttWrapper> attAC {get;set;}

    public Datetime previousVisit {get{
            return ISSP_CurrencyCenterUtil.getPreviousVisitDateTime();
        }set;}

    //isChangedMap - fieldname to boolean
    public Set<String> isChangedSet {get;set;}

    public String isChangedString {get{
        String tmpString = '';
        for(String s : isChangedSet) {
           tmpString += (tmpString == '' ? '' : ',') + s;
        }
        return tmpString;
    }set;}

    public Boolean isGeneralInformationChanged{get{
        Boolean result = false;
        if(
            isChangedSet.contains('Update_gi__c')||
            isChangedSet.contains('History_of_Blocked_Funds_in_Country__c')||
            isChangedSet.contains('Presence_of_BSP__c')||
            isChangedSet.contains('Presence_of_CASS__c')||
            isChangedSet.contains('Presence_of_ICCS__c')||
            isChangedSet.contains('Market_Size__c'))
            result = true;
        return result;
    }set;}

    public Boolean isBspCassChanged{get{
        Boolean result = false;
        if(
            //BSP fields
            isChangedSet.contains('BSP_General_Update__c')||
            isChangedSet.contains('BSP_Launch_Date__c')||
            isChangedSet.contains('BSP_ICCS_availability__c')||
            isChangedSet.contains('BSP_Airlines_participating__c')||
            isChangedSet.contains('BSP_Currency__c')||
            isChangedSet.contains('BSP_Clearing_Bank__c')||
            isChangedSet.contains('BSP_Settlement_Frequency__c')||
            isChangedSet.contains('BSP_Average_Monthly_Volume__c')||
            isChangedSet.contains('BSP_Payment_Card_Profile_Acceptance__c')||
            //CASS fields
            isChangedSet.contains('CASS_General_Update__c')||
            isChangedSet.contains('CASS_Launch_Date__c')||
            isChangedSet.contains('CASS_ICCS_Availability__c')||
            isChangedSet.contains('CASS_Airlines_Participating__c')||
            isChangedSet.contains('CASS_Currency__c')||
            isChangedSet.contains('CASS_Clearing_Bank__c')||
            isChangedSet.contains('CASS_Settlement_Frequency__c')||
            isChangedSet.contains('CASS_Average_Monthly_Volume__c'))
            result = true;
        return result;
    }set;}

    public Boolean isEconomicProfileChanged{get{
        Boolean result = false;
        if(
            isChangedSet.contains('General_profile_e__c')||
            isChangedSet.contains('Update_e__c')||
            isChangedSet.contains('GDP_Growth_yoy__c')||
            isChangedSet.contains('Non_Performing_Loans_share_of_total__c')||
            isChangedSet.contains('Foreign_Exchange_Reserves_change_yoy__c')||
            isChangedSet.contains('Inflation_yoy__c')||
            isChangedSet.contains('Current_Account_Balance_of_GDP__c')||
            isChangedSet.contains('Foreign_Exchange_Reserves_months__c')||
            isChangedSet.contains('Sovereign_Credit_Rating__c'))
            result = true;
        return result;
    }set;}

    public Boolean isCurrencyChanged{get{
        Boolean result = false;
        if(
            isChangedSet.contains('General_profile_c__c')||
            isChangedSet.contains('Update_c__c')||
            isChangedSet.contains('Currency_Exchange_Rate__c')||
            isChangedSet.contains('Spot_1m_Change__c')||
            isChangedSet.contains('Spot_12m_Change__c')||
            isChangedSet.contains('Forward_NDF__c')||
            isChangedSet.contains('Credit_Spread__c')||
            isChangedSet.contains('Devaluation_Risk__c')||
            isChangedSet.contains('International_Fares_Currency__c')||
            isChangedSet.contains('Acceptability_Of_Currency__c')||
            isChangedSet.contains('Alerts__c'))
            result = true;
        return result;
    }set;}

    public Boolean isRepatriationChanged{get{
        Boolean result = false;
        if(
            isChangedSet.contains('Update_rp__c')||
            isChangedSet.contains('Formal_FX_Repatriation_Procedure__c')||
            isChangedSet.contains('Quotas_or_Restrictions__c')||
            isChangedSet.contains('Withholding_Tax_on_FX_Cross_Border__c')||
            isChangedSet.contains('Documentation_Forms__c')||
            isChangedSet.contains('ICCS_Simplified_Process__c'))
            result = true;
        return result;
    }set;}

    public Boolean isImportantContactsChanged{get{
        Boolean result = false;
        if(
            isChangedSet.contains('Update_ic__c')||
            isChangedSet.contains('Central_Bank__c')||
            isChangedSet.contains('International_Banks_Domestic_Banks__c')||
            isChangedSet.contains('Minister_of_Transport_and_Tourism__c')||
            isChangedSet.contains('Civil_Aviation_Authority__c')||
            isChangedSet.contains('Travel_Agent_Association__c')||
            isChangedSet.contains('Local_BAR__c'))
            result = true;
        return result;
    }set;}

    public Boolean isIccsChanged{get{
        Boolean result = false;
        if(
            isChangedSet.contains('Clearing_Currency__c')||
            isChangedSet.contains('Availability__c')||
            isChangedSet.contains('Status_and_Figures__c')||
            isChangedSet.contains('Tax_Fees_on_Cross_Border_Payments__c')||
            isChangedSet.contains('FX_Bank_Partners__c')||
            isChangedSet.contains('History__c')||
            isChangedSet.contains('Update__c'))
            result = true;
        return result;
    }set;}

    public Boolean isAirlinesChargesChanged{get{
        Boolean result = false;
        if(
            isChangedSet.contains('AC_Fuel__c')||
            isChangedSet.contains('AC_Ground_Handling__c')||
            isChangedSet.contains('AC_Crew_Accommodation__c')||
            isChangedSet.contains('AC_Ground_Transport__c')||
            isChangedSet.contains('AC_Update__c')||
            isChangedSet.contains('AC_Airport__c')||
            isChangedSet.contains('AC_Catering__c')||
            isChangedSet.contains('AC_Pax_Accommodation__c')||
            isChangedSet.contains('AC_Line_Maintenance__c'))
            result = true;
        return result;
    }set;}

    public Boolean isNextActionChanged{get{
        Boolean result = false;
        for (ActionWrapper aw : futureActionList)
            if (aw.isNewlyUpdated)
                result = true;

        return result;
    }set;}

    public Boolean isCountryFollowed {
        get {
            list<EntitySubscription> lstSubscriptions = [SELECT Id FROM EntitySubscription WHERE SubscriberId = :UserInfo.getUserId() AND ParentId = :cp.Id LIMIT 1];
            
            return !lstSubscriptions.isEmpty();
        } set;
    }

    public ISSP_CurrencyCenterCountryController(ApexPages.StandardController stdController) {

        cp = (Country_Profile__c)stdController.getRecord();

        if(ApexPages.currentPage().getUrl().substringBetween('apex/', '?') == 'ISSP_CurrencyCenterCountryPdf')
            Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=CP-'+cp.Name+'.pdf');

        /* Start actions (tasks/events) handling */

        taskList = new List<Task>([SELECT Id, IsClosed, Status, Subject, ActivityDate, Description, 
                                    Bridge__c, Identifying_Members__c, Issuer__c, Members__c, Objectives__c, 
                                    Participants__c, Recipient__c, Responses__c, Result_Summary__c, 
                                    Sender__c, Title__c, RecordType.DeveloperName, RecordType.Name, LastModifiedDate, 
                                    (SELECT Id, Name, Description FROM Attachments) 
                                    FROM Task WHERE WhatId =: cp.Id
                                    ORDER BY ActivityDate DESC]);

        eventList = new List<Event>([SELECT Id, Subject, ActivityDate, Description, StartDateTime, EndDateTime, 
                                    Bridge__c, Identifying_Members__c, Issuer__c, Members__c, Objectives__c, 
                                    Participants__c, Recipient__c, Responses__c, Result_Summary__c, 
                                    Sender__c, Title__c, RecordType.DeveloperName, RecordType.Name, Type, Location, LastModifiedDate, 
                                    (SELECT Id, Name, Description FROM Attachments) 
                                    FROM Event WHERE WhatId =: cp.Id
                                    ORDER BY ActivityDate DESC]);

        futureActionList = new List<ActionWrapper>();
        pastActionList = new List<ActionWrapper>();

        for(Task t : taskList){
            if(!t.isClosed && t.ActivityDate >= Date.today()){
                futureActionList.add(new ActionWrapper(true,t, previousVisit));
            }
            else{
                pastActionList.add(new ActionWrapper(true,t,previousVisit));
            }
        }

        for(Event e : eventList){
            if(e.ActivityDate >= Date.today()){
                futureActionList.add(new ActionWrapper(false,e,previousVisit));
            }
            else{
                pastActionList.add(new ActionWrapper(false,e,previousVisit));
            }
        }

        futureActionList.sort();
        pastActionList.sort();

        system.debug('@@@futureActionList '+futureActionList);
        system.debug('@@@pastActionList '+pastActionList);
        /* End actions (tasks/events) handling */

        /* Start attachment handling */

        attGI = new List<AttWrapper>();
        attBSP = new List<AttWrapper>();
        attCASS = new List<AttWrapper>();
        attEconomic = new List<AttWrapper>();
        attCurr = new List<AttWrapper>();
        attRP = new List<AttWrapper>();
        attIC = new List<AttWrapper>();
        attICCS = new List<AttWrapper>();
        attAC = new List<AttWrapper>();

        attList = new List<Attachment>(
                    [SELECT Id,Name,Description
                    FROM Attachment
                    WHERE ParentId =: cp.Id
                    ORDER BY CreatedDate DESC]);

        for(Attachment a: attList){
            if(a.Description != null){
                String[] descSplit = a.Description.split('__###__',3);
                if(descSplit.size() == 3 && descSplit[0]=='1'){
                    if(descSplit[1] == 'General Information')
                        attGI.add(new AttWrapper(a.Name,descSplit[2],descSplit[1],a.id));
                    else if(descSplit[1] == 'BSP Profile')
                        attBSP.add(new AttWrapper(a.Name,descSplit[2],descSplit[1],a.id));
                    else if(descSplit[1] == 'CASS Profile')
                        attCASS.add(new AttWrapper(a.Name,descSplit[2],descSplit[1],a.id));
                    else if(descSplit[1] == 'Economic Profile')
                        attEconomic.add(new AttWrapper(a.Name,descSplit[2],descSplit[1],a.id));
                    else if(descSplit[1] == 'Currency')
                        attCurr.add(new AttWrapper(a.Name,descSplit[2],descSplit[1],a.id));
                    else if(descSplit[1] == 'Repatriation Process')
                        attRP.add(new AttWrapper(a.Name,descSplit[2],descSplit[1],a.id));
                    else if(descSplit[1] == 'Important Contacts')
                        attIC.add(new AttWrapper(a.Name,descSplit[2],descSplit[1],a.id));
                    else if(descSplit[1] == 'ICCS Content')
                        attICCS.add(new AttWrapper(a.Name,descSplit[2],descSplit[1],a.id));
                    else if(descSplit[1] == 'Airlines Charges')
                        attAC.add(new AttWrapper(a.Name,descSplit[2],descSplit[1],a.id));
                }
            }   
        }

        /* End Attachment Handling */

        //populate isChangedSet
        //get list of field names existing in history after previous visit
        List<Country_Profile_History__c> cHistoryList = new List<Country_Profile_History__c>(
            [SELECT Field__c FROM Country_Profile_History__c WHERE Country_Profile__c =: cp.Id AND CreatedDate >: previousVisit]);
        List<Country_Profile__History> sHistoryList = new List<Country_Profile__History>(
            [SELECT Field FROM Country_Profile__History WHERE ParentId =: cp.Id AND CreatedDate >: previousVisit]);
        Set<String> changedFieldNames = new Set<String>();
        //iterate both lists and add field name to combined set of strings 
        for(Country_Profile_History__c cph1 : cHistoryList){
            if(!changedFieldNames.contains(cph1.Field__c))
                changedFieldNames.add(cph1.Field__c);
        }
        for(Country_Profile__History cph2 : sHistoryList){
            if(!changedFieldNames.contains(cph2.Field))
                changedFieldNames.add(cph2.Field);
        }
        isChangedSet = changedFieldNames;
                
    }

    public PageReference checkAccess(){
        return ISSP_CurrencyCenterUtil.checkIfUserHasAccessToService();
    }

    public class AttWrapper{
        public String name {get;set;}
        public String description {get;set;}
        public String section {get;set;}
        public String recordId {get;set;}

        public AttWrapper(String name, String description, String section, String recordId){
            this.name = name;
            this.description = description;
            this.section = section;
            this.recordId = recordId;
        }
    }

    /* Singleton class ActionFieldLables + variables to retrieve field labels */
    private static ActionFieldLabels AFLinstance = null;
    public static ActionFieldLabels getAFLInstance(){
        if(AFLinstance == null) AFLinstance = new ActionFieldLabels();
        return AFLinstance;
    }
    public class ActionFieldLabels {
        public Map<String, Schema.SObjectField> eventFieldMap {get;private set;}
        public Map<String, Schema.SObjectField> taskFieldMap {get;private set;}
        public Map<String, String> eApiToLabelMap {get;private set;}
        public Map<String, String> tApiToLabelMap {get;private set;}

        private ActionFieldLabels(){
            system.debug('@@@called ActionFieldLabels constructor');
            eventFieldMap = Schema.getGlobalDescribe().get('Event').getDescribe().fields.getMap();
            taskFieldMap = Schema.getGlobalDescribe().get('Task').getDescribe().fields.getMap();
            eApiToLabelMap = new Map<String,String>();
            tApiToLabelMap = new Map<String,String>();

            for (String fieldName: eventFieldMap.keySet()) {
                eApiToLabelMap.put(fieldName,eventFieldMap.get(fieldName).getDescribe().getLabel());
            }

            for (String fieldName: taskFieldMap.keySet()) {
                tApiToLabelMap.put(fieldName,taskFieldMap.get(fieldName).getDescribe().getLabel());
            }
        }        
    }

    public class ActionWrapper implements Comparable{
        public Boolean isTask {get;set;}
        public Task task {get;set;}
        public Event event {get;set;}
        public String popoverContent {get;set;}
        public Date dueDate {get;set;}
        public Boolean isNewlyUpdated {get; set;}

        // constructor for tasks
        public actionWrapper(Boolean isTask, Task task, Datetime previousVisit){
            this.isTask = isTask;
            this.task = task;
            this.dueDate = task.ActivityDate;
            this.isNewlyUpdated = task.LastModifiedDate > previousVisit;

            /* caution: All below calls to getAFLInstance map must be with lowercase field api names
            as Schema.getGlobalDescribe() returns api names in lower case */
            if(task.RecordType.DeveloperName == 'Airlines_Industry_Communication'){
                this.popoverContent = '';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('sender__c')+'</b></p><p>'+getHtmlString(task.Sender__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('title__c')+'</b></p><p>'+getHtmlString(task.Title__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('recipient__c')+'</b></p><p>'+getHtmlString(task.Recipient__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('objectives__c')+'</b></p><p>'+getHtmlString(task.Objectives__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('activitydate')+'</b></p><p>'+getFormattedDate(task.ActivityDate)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('description')+'</b></p><p>'+getHtmlString(task.Description)+'</p>';
            }
            else if(task.RecordType.DeveloperName == 'IATA_Airlines_Survey'){
                this.popoverContent = '';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('sender__c')+'</b></p><p>'+getHtmlString(task.Sender__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('participants__c')+'</b></p><p>'+getHtmlString(task.Participants__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('objectives__c')+'</b></p><p>'+getHtmlString(task.Objectives__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('activitydate')+'</b></p><p>'+getFormattedDate(task.ActivityDate)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('description')+'</b></p><p>'+getHtmlString(task.Description)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('responses__c')+'</b></p><p>'+getHtmlString(task.Responses__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('result_summary__c')+'</b></p><p>'+getHtmlString(task.Result_Summary__c)+'</p>';
            }
            else if(task.RecordType.DeveloperName == 'Official_Letter'){
                this.popoverContent = '';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('sender__c')+'</b></p><p>'+getHtmlString(task.Sender__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('recipient__c')+'</b></p><p>'+getHtmlString(task.Recipient__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('objectives__c')+'</b></p><p>'+getHtmlString(task.Objectives__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('activitydate')+'</b></p><p>'+getFormattedDate(task.ActivityDate)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('description')+'</b></p><p>'+getHtmlString(task.Description)+'</p>';
            }
            else if(task.RecordType.DeveloperName == 'Press_Release'){
                this.popoverContent = '';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('issuer__c')+'</b></p><p>'+getHtmlString(task.Issuer__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('objectives__c')+'</b></p><p>'+getHtmlString(task.Objectives__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('activitydate')+'</b></p><p>'+getFormattedDate(task.ActivityDate)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().tApiToLabelMap.get('description')+'</b></p><p>'+getHtmlString(task.Description)+'</p>';
            }

            if (task.Attachments.size() > 0) {
                this.popoverContent += '<div class="row horizontal-separator"></div><div class="row"><div class="col-xs-12"><div class="attachments-title">' + Label.CurrencyCenter_Attachments_Section + '</div>';

                for (Attachment att : task.Attachments) {
                        this.popoverContent += '<div class="row attachments-row">';
                        this.popoverContent += '<div class="col-xs-12"><a class="attachments-name" href="/servlet/servlet.FileDownload?file=' + att.Id + '" target="_blank">' + att.Name + '</a></div>';
                        this.popoverContent += att.Description != null ? '<div class="col-xs-12 attachments-description">' + att.Description + '</div>' : '';
                        this.popoverContent += '</div>';
                    }
                                
                this.popoverContent += '</div></div>';
            }
        }

        // constructor for events
        public actionWrapper(Boolean isTask, Event event, Datetime previousVisit){
            this.isTask = isTask;
            this.event = event;
            this.dueDate = event.ActivityDate;
            this.isNewlyUpdated = event.LastModifiedDate > previousVisit;

            if(event.RecordType.DeveloperName == 'Conference_Call'){
                this.popoverContent = '';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('participants__c')+'</b></p><p>'+getHtmlString(event.Participants__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('objectives__c')+'</b></p><p>'+getHtmlString(event.Objectives__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('startdatetime')+'</b></p><p>'+getFormattedDateTime(event.StartDateTime)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('enddatetime')+'</b></p><p>'+getFormattedDateTime(event.EndDateTime)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('bridge__c')+'</b></p><p>'+getHtmlString(event.Bridge__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('description')+'</b></p><p>'+getHtmlString(event.Description)+'</p>';
            }
            else if(event.RecordType.DeveloperName == 'Meeting'){
                this.popoverContent = '';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('type')+'</b></p><p>'+getHtmlString(event.Type)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('participants__c')+'</b></p><p>'+getHtmlString(event.Participants__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('objectives__c')+'</b></p><p>'+getHtmlString(event.Objectives__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('startdatetime')+'</b></p><p>'+getFormattedDateTime(event.StartDateTime)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('enddatetime')+'</b></p><p>'+getFormattedDateTime(event.EndDateTime)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('location')+'</b></p><p>'+getHtmlString(event.Location)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('description')+'</b></p><p>'+getHtmlString(event.Description)+'</p>';
            }
            else if(event.RecordType.DeveloperName == 'Task_Force'){
                this.popoverContent = '';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('identifying_members__c')+'</b></p><p>'+getHtmlString(event.Identifying_Members__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('objectives__c')+'</b></p><p>'+getHtmlString(event.Objectives__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('startdatetime')+'</b></p><p>'+getFormattedDateTime(event.StartDateTime)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('enddatetime')+'</b></p><p>'+getFormattedDateTime(event.EndDateTime)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('members__c')+'</b></p><p>'+getHtmlString(event.Members__c)+'</p>';
                this.popoverContent += '<p><b>'+getAFLInstance().eApiToLabelMap.get('description')+'</b></p><p>'+getHtmlString(event.Description)+'</p>';
            }

            if (event.Attachments.size() > 0) {
                this.popoverContent += '<div class="row horizontal-separator"></div><div class="row"><div class="col-xs-12"><div class="attachments-title">' + Label.CurrencyCenter_Attachments_Section + '</div>';

                for (Attachment att : event.Attachments) {
                        this.popoverContent += '<div class="row attachments-row">';
                        this.popoverContent += '<div class="col-xs-12"><a class="attachments-name" href="/servlet/servlet.FileDownload?file=' + att.Id + '" target="_blank">' + att.Name + '</a></div>';
                        this.popoverContent += att.Description != null ? '<div class="col-xs-12 attachments-description">' + att.Description + '</div>' : '';
                        this.popoverContent += '</div>';
                    }
                                
                this.popoverContent += '</div></div>';
            }
        }

        public Integer compareTo(Object compareTo) {

            ActionWrapper compareToDate = (ActionWrapper)compareTo;
            
            Integer returnValue = 0;
            if (this.dueDate < compareToDate.dueDate) {
                returnValue = -1;
            } else if (this.dueDate > compareToDate.dueDate) {
                returnValue = 1;
            }
            
            return returnValue;       
        }

        public String getFormattedDate(Datetime d){
            String result = '';
            if(d != null){
                DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                result = dt.format('dd MMM yyyy');
            }            
            return result;
        }

        public String getFormattedDateTime(Datetime d){
            String result = '';
            if(d != null){
                DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day(), d.hour(), d.minute(), d.second());
                result = dt.format('dd MMM yyyy HH:mm');
            }            
            return result;
        }

        public String getHtmlString(String s){
            String result = '';
            if(s != null){
                result = s.replaceAll('\r\n', '<br/>');
            }
            return result;            
        }
    }

    public void ToggleFollow() {
        if (isCountryFollowed) {
            // Unfollow
            list<EntitySubscription> lstSubscriptions = [SELECT Id FROM EntitySubscription WHERE SubscriberId = :UserInfo.getUserId() AND ParentId = :cp.Id LIMIT 1];
            delete lstSubscriptions[0];
        } else {
            // Follow
            EntitySubscription es = new EntitySubscription(SubscriberId = UserInfo.getUserId(), ParentId = cp.Id, NetworkId = Network.getNetworkId());
            insert es;
        }
    }
}