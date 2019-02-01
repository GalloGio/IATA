/*
 * This class is the controller for the AirlineSuspensionCase and AirlinePreSuspensionCase VF pages. 
 */
 
global with sharing class AirlineSuspensionCaseController {
    public Airline_Suspension__c asrecord {public get; private set;}
    public Case c {public get; private set;}
    public String mode {public get; private set;}
    public Boolean errors {public get; private set;}
    public MailMergeTemplate template { public get {
            try {
                return [SELECT Id, Name FROM MailMergeTemplate WHERE Name = 'AS Pre Suspension Checklist' LIMIT 1];  
            } catch (Exception e) {
                system.debug('ERROR getting the template: ' + e.getMessage());
                return null;
            }
        } private set;
    }
    public Id GDStemplateId { public get {
            try {
                EmailTemplate et = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'Airline_Suspension_GDS_Message' LIMIT 1];
                return et.id; 
            } catch (Exception e) {
                system.debug('ERROR getting the GDS template: ' + e.getMessage());
                return null;
            }
        } private set;
    }
    public Id InternalTemplateId { public get {
            String tplName = 'Airline_Suspension_Internal';
            
            try {
                tplName += asrecord.BSP_Participations_locked__c == 'No BSP Participation' ? '' : '_BSP';
                tplName += asrecord.CASS_Participations_locked__c == 'No CASS Participation' ? '' : '_CASS';
                
                tplName += asrecord.Settle_Directly_To__c == 'IATA' ? '_Settle_to_IATA' : '_Settle_to_Airline';
                tplName += '_Cloned';
                
                EmailTemplate et = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = :tplName LIMIT 1];
                return et.id;  
            } catch (Exception e) {
                system.debug('ERROR getting the internal template "' + tplName + '": ' + e.getMessage());
                return null;
            }
        } private set;
    }
    public String AirlineSuspensionDocFolderId { public get {
            try {
                return String.valueOf([SELECT Id FROM Folder WHERE Name = 'Airline Suspension Document Templates' LIMIT 1].Id).left(15);  
            } catch (Exception e) {
                system.debug('ERROR getting the Airline Suspension Document Templates folder id: ' + e.getMessage());
                return null;
            }
        } private set;
    }
    
    
    public String SuspensionEmailRecipients {
        public get {
            map<String, String> mapEmailListPerRegion = new map<String, String>{
                                'Africa & Middle East' => Label.AirlineSuspensionEmailRecipientsAfricaMiddleEast,
                                'Americas' => Label.AirlineSuspensionEmailRecipientsAmericas,
                                'Asia & Pacific' => Label.AirlineSuspensionEmailRecipientsAsiaPacific,
                                'China & North Asia' => Label.AirlineSuspensionEmailRecipientsChinaNorthAsia,
                                'Europe' => Label.AirlineSuspensionEmailRecipientsEurope
                                };
                                
            String tmpStr = '';
            
            if (asrecord.Regions_Involved__c != null) {
                for (String region : asrecord.Regions_Involved__c.split(',')) {
                    tmpStr += (tmpStr != '' ? ',' : '') + mapEmailListPerRegion.get(region.trim());
                }
            }
            
            return tmpStr;
        } private set;
    }
    
    
    public AirlineSuspensionCaseController (ApexPages.StandardController controller) {
        if (controller.getRecord().Id != null ) {
            c = [SELECT Id, Status, AccountId, Account.Name, Account.Membership_status__c, Account.ICCS_Membership_Status__c, RecordType.DeveloperName FROM Case WHERE Id = :controller.getRecord().Id];
            
            List<Airline_Suspension__c> lstASRecords = [SELECT Id, Case__c, X2_weeks_average_net_cash_settlement__c, X4_weeks_average_net_cash_settlement__c, X6_weeks_average_net_cash_settlement__c, Airline_Headquarter_Region__c,
                                                Debt_with_central_billing__c, IATA_member__c, ICCS_membership_Status__c, HQ_Reqion_SVP_Agree__c, SVP_Agreement_Rejection_Date__c, Approval_Comments__c, Reason_for_Suspension__c, 
                                                ICH_participant__c, Recommendation_from_HAPM__c, SVP_FDS_Approval__c, Weblink_participant__c, BSP_Participations_locked__c, Settle_Directly_To__c, Sent_for_SVP_FDS_Approval__c,  
                                                CASS_Participations_locked__c, Regions_Involved__c, Reported_period_net_cash_sales__c, Number_of_months_on_reported_period__c, SH_Alert_Received_24hrs_after_Event__c, 
                                                Communications_Sent_to_the_Market__c, Confirmation_BSPlink_CASSlink_suspension__c,  Suspension_Instructions_Sent_to_AP_Team__c, Suspension_Instructions_Sent_to_GDS__c, 
                                                Suspension_Instructions_to_CS_Teams_Sent__c, Suspension_Letter_Sent__c, ChildSuspensionCasesGenerated__c, Participates_in_IATA_Governance_Groups__c, ICCS_membership_Status_locked_value__c, 
                                                IATA_member_locked_value__c, Receipt_Confirmation_from_GDS__c, Receipt_Confirmation_from_GDS_2__c, Receipt_Confirmation_from_GDS_3__c, 
                                                Receipt_Confirmation_from_GDS_4__c, Receipt_Confirmation_from_GDS_5__c, GDS_Name__c, GDS_Name_2__c, GDS_Name_3__c, GDS_Name_4__c, GDS_Name_5__c, 
                                                Amount_of_Cash_Deposit__c, Confirmation_of_the_Event__c, Occurence_of_Event__c 
                                                FROM Airline_Suspension__c WHERE Case__c = :controller.getRecord().Id];
            
            if (lstASRecords.size() == 1) {
                asrecord = lstASRecords[0];
                
                // if SVP_FDS_Approval__c != null => pre-suspension locked; otherwise, fill the BSP and CASS participation info
                if (asrecord.SVP_FDS_Approval__c == null) {
                    
                    map<String,List<String>> tempResultsMap = getParticipations('BSP');
                    if (tempResultsMap.get('countries').size() != 0) {
                        asrecord.BSP_Participations_locked__c = String.join(tempResultsMap.get('countries'), ', ');
                    } else {
                        asrecord.BSP_Participations_locked__c = 'No BSP Participation';
                    }
                    
                    Set<String> tempSet = new Set<String>(tempResultsMap.get('regions'));
                    
                    
                    tempResultsMap = getParticipations('CASS');
                    if (tempResultsMap.get('countries').size() != 0) {
                        asrecord.CASS_Participations_locked__c = String.join(tempResultsMap.get('countries'), ', ');
                    } else {
                        asrecord.CASS_Participations_locked__c = 'No CASS Participation';
                    }
                    
                    tempSet.addAll(tempResultsMap.get('regions'));
                    asrecord.Regions_Involved__c = String.join(new List<String>(tempSet), ', ');
                    
                    
                    asrecord.IATA_member_locked_value__c = c.Account.Membership_status__c == 'IATA member' ? 'Yes' : 'No';
                    asrecord.ICCS_membership_Status_locked_value__c = c.Account.ICCS_Membership_Status__c != null ? c.Account.ICCS_Membership_Status__c : 'Not member';
                }
                
            } else if (lstASRecords.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No associated Airline Suspension record found! Please contact support.'));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'More than 1 associated Airline Suspension record found! Please contact support.'));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Case'));
        }
        
        mode = 'view';
    }
    
    
    /*
     * Returns a map with the list of countries in which the airline appears either as the provider or the consumer, or the parent of a provider or a consumer of at least one of the type of service
     * that are passed as a parameter ('BSP' or 'CASS') and a list of the regions involved (Set<String>)
     */
    private map<String,List<String>> getParticipations (String participationType) {
        List<String> lstParticipationTypes = AirlineSuspensionChildCaseCreationBatch.MAP_PARTICIPATION_TYPE_PER_NAME.get(participationType);
        List<Services_Rendered__c> lstServicesRendered = new List<Services_Rendered__c>();
        
        if (c.RecordType.DeveloperName == 'Airline_Deactivation') {
            // if deactivation, only look through the services rendered where the account on the case is the consumer
            lstServicesRendered = [SELECT Id, ISO_Country_formula__c, Services_Rendered_to_Airline__r.IATA_ISO_Country__r.Region__c FROM Services_Rendered__c 
                                    WHERE Services_Rendered_Status__c = 'Active' 
                                    AND Services_Rendered_Type__c IN :lstParticipationTypes 
                                    AND Services_Rendered_To_Airline__c =: c.AccountId 
                                    ORDER BY ISO_Country_formula__c];
        } else {
            // if suspension, look at all the services rendered received or provided by the airline hq and its branches
            lstServicesRendered = [SELECT Id, ISO_Country_formula__c, Services_Rendered_to_Airline__r.IATA_ISO_Country__r.Region__c FROM Services_Rendered__c 
                                    WHERE Services_Rendered_Status__c = 'Active' 
                                    AND Services_Rendered_Type__c IN :lstParticipationTypes 
                                    AND (Services_Rendered_To_Airline__c =: c.AccountId 
                                        OR Services_Rendered_To_Airline__r.ParentId =: c.AccountId  
                                        OR Services_rendered_By__r.ParentId =: c.AccountId  
                                        OR Services_rendered_By__c =: c.AccountId ) 
                                    ORDER BY ISO_Country_formula__c];
        }
        
        Set<String> setCountries = new Set<String>();
        Set<String> setRegions = new Set<String>();
        // use sets to eliminate duplicates
        for (Services_Rendered__c sr : lstServicesRendered) {
            setCountries.add(sr.ISO_Country_formula__c);
            setRegions.add(sr.Services_Rendered_to_Airline__r.IATA_ISO_Country__r.Region__c);
        }       
        
        map<String,List<String>> mapResult = new map<String,List<String>>();
        mapResult.put('countries', new List<String>(setCountries));
        mapResult.put('regions', new List<String>(setRegions));
        
        return mapResult;
    }
    
    
    public void EditSuspension () {
        mode = 'edit';
    }
    
    
    public PageReference SaveSuspension () {
        try {
            update asrecord;
            
            PageReference curPage = ApexPages.currentPage();
            curPage.setRedirect(true);
            return curPage;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0)));
            return null;
        }
        
    }
    
    
    public PageReference CancelSuspensionEdit() {
        PageReference curPage = ApexPages.currentPage();
        curPage.setRedirect(true);
        return curPage;
    }
    
    
    /*
     * Launches the batch process that generates child cases and sets the ChildSuspensionCasesGenerated flag to 'pending'
     */
    public void CreateCountrySuspensionCases () {
        Id batchInstanceId = Database.executeBatch(new AirlineSuspensionChildCaseCreationBatch(c.Id, false), 5);
        
        asrecord.ChildSuspensionCasesGenerated__c = 'Pending';
        update asrecord;
    }
    
    
    /*
     * Closes all the child suspension cases with a status of "Abandoned" (to be used in case of cases mistakenly generated)
     */
    public void CloseAllChildSuspensionCases () {
            AirlineSuspensionChildCaseCreationBatch asb = new AirlineSuspensionChildCaseCreationBatch(c.Id, true);
            Id batchInstanceId = Database.executeBatch(asb, 5);
            
            asrecord.ChildSuspensionCasesGenerated__c = 'Pending';
            update asrecord;
        
    }

    /**
        Get all core group names
    **/
    public List<SelectOption> getGroupNamesOptions() {
        List<SelectOption> listOptions = new List<SelectOption>();
        for(AMPCoreGroups__c a : [SELECT Name, Order__c from AMPCoreGroups__c ORDER BY Order__c ASC]) {
            listOptions.add(new SelectOption(a.Name,a.Name));
        }
        return listOptions;
    }
    
    /*
    public void CreateAttachmentToParentCase () {
        String attBody;
        try {
            attBody = testCongaBackgroundMode(asrecord.Id, template.Id);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
        
        if (attBody != null) {
            Attachment att = new Attachment();
            att.ParentId = c.Id;
            att.Name = 'Pre-suspension+Checklist.doc';
            att.Body = Blob.valueOf(attBody);
            
            insert att;
        } 
    }
    
    @RemoteAction
    global static String testCongaBackgroundMode(Id asrecordId, Id templateId) {
    
        String sessId = UserInfo.getSessionId();
        String servUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/29.0/' + UserInfo.getOrganizationId();
        
        String url2 = 'https://www.appextremes.com/apps/conga/pm.aspx?sessionId=' + sessId + 
                    '&serverUrl=' + servUrl + 
                    '&id=' + asrecordId + 
                    '&fp0=0&ds1=0&ds4=1&ds5=0&OFN=Pre-suspension+Checklist' + 
                    '&EmailRelatedToId=' + asrecordId + 
                    '&TemplateId=' + templateId +
                    '&DS7=3';
                    
        System.debug(url2);
    
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url2);
        req.setMethod('GET');
        req.setTimeout(60000);
        
        // Send the request, and return a response
        HttpResponse res = http.send(req);
        
        System.debug(res);
        
        return res.getBody();
    } */
}