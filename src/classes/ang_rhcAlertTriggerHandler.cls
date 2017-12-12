public class ang_rhcAlertTriggerHandler {

	public List<ANG_Risk_Alert__c> triggerNew = (List<ANG_Risk_Alert__c>) Trigger.new;
	public List<ANG_Risk_Alert__c> triggerOld = (List<ANG_Risk_Alert__c>) Trigger.old;

	public Map<Id, ANG_Risk_Alert__c> newMap = (Map<Id,ANG_Risk_Alert__c>) Trigger.newMap;
	public Map<Id, ANG_Risk_Alert__c> oldMap = (Map<Id,ANG_Risk_Alert__c>) Trigger.oldMap;

	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************

	public void onBeforeInsert(){
	}
	public void onAfterInsert() {
		sendAlertNotification();
		handleRedAlerts();
	}

	public void onBeforeUpdate(){
	}
	public void onAfterUpdate() {
	}

	public void onBeforeDelete(){}
	public void onAfterDelete() {}




	private map<id,account> raAccMap{get;private set;}
	private static final String ALL_COUNTRIES_ISOCODE ='WW';
	

	// ************************************************************
	// ****************** Action Methods ********************
	// ************************************************************



    public static String mapRemittanceFrequency(Account acc){

        if(acc.IATA_ISO_Country__r.iso_code__c  == 'BR') return 'W';
        if(acc.Remittance_frequency__c == 'Monthly') return 'M';
        if(acc.Remittance_frequency__c == 'Fortnightly') return 'F';
        if(acc.Remittance_frequency__c == '4 times per month') return 'W';
        if(acc.Remittance_frequency__c == 'Weekly') return 'W';
        if(acc.Remittance_frequency__c == 'Daily' ) return 'D';
        if(acc.Remittance_frequency__c == 'Every 3 days') return 'B';

        /*
        -------ignore china for now-------

        if(acc.Remittance_frequency__c == 'Daily' && acc.Region_formula__c == 'Europe' && acc.IATA_ISO_Country__r.iso_code__c  != 'UA') return 'D';
        if(acc.Remittance_frequency__c == 'Daily' && acc.IATA_ISO_Country__r.iso_code__c  == 'CN') return 'T';
        if(acc.Remittance_frequency__c == 'Every 3 days' && acc.IATA_ISO_Country__r.iso_code__c  == 'CN') return 'E';
        if(acc.Remittance_frequency__c == 'Every 3 days' && acc.IATA_ISO_Country__r.iso_code__c  == 'UA') return 'B';*/

        if(acc.Remittance_frequency__c == 'Every 10 days') return 'W';
        
        return '';
    }


	public void sendAlertNotification(){
		
		system.debug(' ang_rhcAlertTriggerHandler sendAlertNotifications STARTED');

		//GET Templates from custom setting 
		list<ANG_RHC_Alert_Templates__c> alertTemplateList = new list<ANG_RHC_Alert_Templates__c>();
		set<string> templateNameSet= new set<string>();
		for(ANG_RHC_Alert_Templates__c rat: ANG_RHC_Alert_Templates__c.getAll().values()){
			if(rat.Ang_direction__c ==ANG_RHCHelper.RISK_ALERT_DIRECTION_UP){
				alertTemplateList.add(rat);
        		templateNameSet.add(rat.ANG_template_api__c);
        	}
        }

        if(alertTemplateList.isEmpty()) return;

        //Get emailTemplates ID's Mapping
        map<string,id> templateMap = new map<string,id>();
        for(emailTemplate et :[Select id,developerName from emailTemplate where developerName in :templateNameSet and isActive=true]){
        	templateMap.put(et.developerName,et.id);
        }

        if(templateMap.isEmpty()) return;

		map<id,ANG_RHC_Alert_Templates__c> alertTemplateMap = new map<id,ANG_RHC_Alert_Templates__c>();
		map<id,ANG_Risk_Alert__c> riskAlertMap = new map<id,ANG_Risk_Alert__c>();
		for(ANG_Risk_Alert__c ralert :triggerNew){
			for(ANG_RHC_Alert_Templates__c at:alertTemplateList){
				if(ralert.ANG_Direction__c==ANG_RHCHelper.RISK_ALERT_DIRECTION_UP && ralert.ANG_Threshold_Level__c==at.ANG_percentage__c){
					if(!alertTemplateMap.containsKey(ralert.ANG_Account__c)){
						alertTemplateMap.put(ralert.ANG_Account__c,at);
						riskAlertMap.put(ralert.ANG_Account__c,ralert);
						continue;
					}
				}
			}
		}


		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		set<id> accIdSet = new set<id>();

		for(Contact c : [SELECT Id, AccountId, Account.Top_Parent__c FROM Contact WHERE User_Portal_Status__c = :ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM AND (Account.Top_Parent__c IN :alertTemplateMap.keySet() OR AccountId IN :alertTemplateMap.keySet())]){

			id accId;
			if(alertTemplateMap.containsKey(c.AccountId)) accId=c.AccountId;
			else if (!accIdSet.contains(c.Account.Top_Parent__c)) accId=c.Account.Top_Parent__c;
			else continue;

			accIdSet.add(accId);

			string templateID = templateMap.get(alertTemplateMap.get(accId).ANG_template_api__c);

			if(templateID==null) continue;         
            ANG_RHCHelper.sendMailUpdateRiskAlert(c.id,riskAlertMap.get(accId).ANG_RHC_Information__c,templateID,riskAlertMap.get(accId).id);
		}

	}

	public void handleRedAlerts(){
		List<ANG_Risk_Alert__c> redAlerts = new List<ANG_Risk_Alert__c>();
		List<RiskAlertParentCaseWrapper> wrapperList = new List<RiskAlertParentCaseWrapper>();
		
		

		set<id> accIdSet= new set<id>();
		for(ANG_Risk_Alert__c ra :triggerNew ){
			if(ra.recordtypeId==RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('ANG_Risk_Alert__c').get('Risk_Alert_RTS'))accIdSet.add(ra.ANG_Account__c);
		}

		if(accIdSet.isEmpty())return;

		List<Id> listIDAccsToRetriveCons = new List<Id>();
		map<string,AMS_Country_Specific_Attribute__c> rtsConfigMap= new map<string,AMS_Country_Specific_Attribute__c>();//iso_countr_isoCode__c =>AMS_Country_Specific_Attribute__c
		for(AMS_Country_Specific_Attribute__c csa: [
			SELECT IATA_ISO_Country__r.ISO_Code__c,ANG_Send_Email_Agent__c,ANG_Create_Sidra_Lite__c,ANG_Remove_Ticketing_Authority__c 
			FROM AMS_Country_Specific_Attribute__c 
			WHERE recordtypeId=: RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('AMS_Country_Specific_Attribute__c').get('RTS_Risk_Alert_Notification') ]){
			rtsConfigMap.put(csa.IATA_ISO_Country__r.ISO_Code__c,csa);
		}

		if(rtsConfigMap.isEmpty())return;

		//NEEDED QUERY BECAUSE WE WEREN'T GETTING ALL FIELDS NEEDED FROM TRIGGER
		raAccMap= new map<id,account>();
		Map<Id,List<Contact>> contactsPerAccount = new Map<Id,List<Contact>>();

		for(Account acc :[
			SELECT id,Name, IATACode__c, Location_Class__c, ANG_IsNewGenAgency__c, Top_Parent__c, CurrencyIsoCode, Guaranteed_amount__c, IATA_ISO_Country__r.BSP__c,IATA_ISO_Country__r.BSP_Country_free_text__c,Remittance_frequency__c,IATA_ISO_Country__c,IATA_ISO_Country__r.Name,
					IATA_ISO_Country__r.ISO_Code__c, Region_formula__c,
        
		(SELECT ID,Name,ANG_Account__c,CurrencyIsoCode,ANG_Sidra_Lite__c,ANG_Agent_Sales__c,ANG_Is_Case_Created__c,ANG_Direction__c,ANG_email_sent__c,ANG_EventId__c,ANG_RHC_Information__c,ANG_RME_Last_Update__c,ANG_Severity__c,ANG_Threshold_Level__c
		FROM Risk_Alerts__r 
		WHERE ID IN :triggerNew
		AND ANG_Severity__c = 'Red'
		AND recordTypeId = :RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('ANG_Risk_Alert__c').get('Risk_Alert_RTS') 
		),
		(SELECT Id, User_Portal_Status__c, AccountId, Account.Top_Parent__c, Financial_Assessment_Contact__c
		FROM contacts
		WHERE Status__c = 'Active'
		)
		FROM ACCOUNT
		where ID IN :accIdSet]){
			for(ANG_Risk_Alert__c ra: acc.Risk_Alerts__r){
				redAlerts.add(ra);	
				raAccMap.put(ra.id,acc);	
			}

			contactsPerAccount.put(acc.id,acc.contacts);
			listIDAccsToRetriveCons.add( (acc.Top_Parent__c != null ? acc.Top_Parent__c : acc.id ) );
		}

		 	


		if(!redAlerts.isEmpty()){
            // NEWGEN-2005
            sendNotificationToSeniors(redAlerts);
            // END - NEWGEN-2005

			AssignmentRule AR = new AssignmentRule();
	        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
	        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
	        Database.DMLOptions dmlOpts = new Database.DMLOptions();
	        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;


			Case smapParentCase;
			List<Case> sidraLiteCases;
			List<Case> smapParentCases = new List<Case>();
			Map<String,case> mapCaseRiskAlert = new Map<String,case>();
			Set<Id> accountsIds = new Set<Id>();
			Map<Id,Operational_Calendar__c> mapAccountOpCalendar = fetchCalendar(redAlerts);


			for(ANG_Risk_Alert__c ra: redAlerts){
				string configKey=rtsConfigMap.containsKey(raAccMap.get(ra.id).IATA_ISO_Country__r.ISO_Code__c)?raAccMap.get(ra.id).IATA_ISO_Country__r.ISO_Code__c:ALL_COUNTRIES_ISOCODE ;//checks if key exists in map, if not uses default key
   				if(rtsConfigMap.get(configKey).ANG_Create_Sidra_Lite__c){
					smapParentCase = new Case(
                       Region__c = raAccMap.get(ra.id).Region_formula__c,
                       Subject = 'Real Time Sales RED Alert - ' +   raAccMap.get(ra.id).IATA_ISO_Country__r.ISO_Code__c + ' - ' + raAccMap.get(ra.id).IATACode__c ,
                       AccountId = ra.ANG_Account__c,
                       Status = 'Accepted',
                       BSP_CASS__c = 'BSP',
                       Origin = 'Risk Monitoring Engine',
                       BSPCountry__c = raAccMap.get(ra.id).IATA_ISO_Country__r.Name,
                       Decision__c = 'Prejudiced Collection of Funds',
                       RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('sMAP_sales_Monitoring_Alert_Process')
                    );
                    if( (!raAccMap.get(ra.id).ANG_IsNewGenAgency__c && (raAccMap.get(ra.id).location_class__c  == 'P' || raAccMap.get(ra.id).location_class__c  == 'D')) && !mapAccountOpCalendar.containsKey(ra.ANG_Account__c)){
                    	system.debug("##SAMP not supose to have calendar");
                    }else{
                    	smapParentCase.Next_Remittance_Date__c = mapAccountOpCalendar.get(ra.ANG_Account__c).Remittance_Day__c;
                    	smapParentCase.Start_Date_of_Sales_Period__c = mapAccountOpCalendar.get(ra.ANG_Account__c).First_Day__c;
                    	smapParentCase.End_Date_of_Sales_Period__c = mapAccountOpCalendar.get(ra.ANG_Account__c).Last_Day__c;
                    	smapParentCase.Suspension_Date__c=  Date.today();
                   	}

                   	smapParentCase.setOptions(dmlOpts);
					wrapperList.add(new RiskAlertParentCaseWrapper(ra.Id, smapParentCase));

					//we'll get the portal approved admin or if none the ifap contact 
					//if has parent, use parent contacts. else, use theirs
					Id accId = (raAccMap.get(ra.id).Top_Parent__c != null ? raAccMap.get(ra.id).Top_Parent__c: ra.ANG_Account__c);

					for(Contact con :contactsPerAccount.get(accId)){						
						if(con.User_Portal_Status__c == ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM){
							smapParentCase.ContactId = con.Id;
							break;
						}else if(con.Financial_Assessment_Contact__c){
							smapParentCase.ContactId = con.Id;							
						}
					}
					
					//fallback to have one contact for the sidra lite case
					if(smapParentCase.ContactId == null){
						smapParentCase.ContactId = contactsPerAccount.get(accId)[0].Id;
					}

					smapParentCases.add(smapParentCase);
					accountsIds.add(ra.ANG_Account__c);
				}
			}


			if(!smapParentCases.isEmpty()){
				//insert smapParentCases --> all or none = false;
	            //need to store result to later interate the correct ones and then atribute the sidra case to the Alert  
				List<Database.SaveResult> resultInsSMAPcases;
				try{
					resultInsSMAPcases = Database.insert(smapParentCases, false);
				}catch(Exception e){
					System.debug('## Case not created: '+e);
				}

		        for(Case parentCase :smapParentCases){
		            mapCaseRiskAlert.put(parentCase.Id,parentCase);            
		        }

		        //Create SIDRA CASE NOW
		        Case sidraLiteCase;
		        Map<Id,Case> mapSMAPtoSIDRA = new Map<Id,Case>(); 
		        sidraLiteCases = new List<Case>();

		        //map to get account's IsoCode- used to control RTS actions
		       	map<id,string>  accIsoCode = new map<id,string>();

		        for(Case parentCase :[Select Id, IATAcode__c,AccountId, Account.Name,Account.IATACode__c, Account.Site,Account.IATA_ISO_Country__r.ISO_Code__c, Region__c, BSPCountry__c, ParentId FROM Case WHERE Id IN: smapParentCases]){
		        	
		        	accIsoCode.put(parentCase.AccountId,parentCase.Account.IATA_ISO_Country__r.ISO_Code__c);

		            //NEWGEN-1933 fill fields on sidra case
		            sidraLiteCase = WSSidraLite.createCase(parentCase.id);
		            sidraLiteCase.Subject = 'RTS Alert' + ' - ' + parentCase.Account.IATACode__c + ' - ' + parentCase.Account.Name;
		            sidraLiteCase.Case_Remarks__c = '';
		            sidraLiteCase.Description = '';                    
		            sidraLiteCase.Region__c = parentCase.Region__c; 
		            sidraLiteCase.BSPCountry__c = parentCase.BSPCountry__c;
		            sidraLiteCase.BSP_CASS__c = 'BSP';
		            sidraLiteCase.Status = 'Open'; 
		            sidraLiteCase.Origin = 'Risk Monitoring Engine'; 
		            sidraLiteCase.SIDRA_Lite_Reason__c = 'Prejudiced Collection of Funds'; 
		            sidraLiteCase.Priority = 'High'; 
					sidraLiteCase.DEF_Approval_Rejection__c = 'Approved';
					sidraLiteCase.Reason_for_Default__c = 'Under Review';
					sidraLiteCase.Update_AIMS_DEF__c = Date.today();
                    sidraLiteCase.CS_Rep_Acc_DEF__c = userInfo.getUserId();
		            sidraLiteCase.Shut_Down_TKT_System_GDS_and_BSPlink__c = Datetime.now(); //already done on callout
		            sidraLiteCase.ContactId = smapParentCase.ContactId;
		            
		            //END -NEWGEN-1933
		            sidraLiteCases.add(sidraLiteCase);
		            mapSMAPtoSIDRA.put(parentCase.id,sidraLiteCase);
				}


				if (!sidraLiteCases.isEmpty()) {
					insert sidraLiteCases;
					List<ANG_Risk_Alert__c> riskAlertsToUpdate = new List<ANG_Risk_Alert__c>();
					// Iterate through each returned result
					for (Database.SaveResult sr : resultInsSMAPcases) {
						if (sr.isSuccess()) {
							for (RiskAlertParentCaseWrapper w: wrapperList) {
								if (w.smap.Id == sr.getId()) {
									//because trigger is running on after inset we need a new instace and DML operation to update 
									riskAlertsToUpdate.add(new ANG_Risk_Alert__c(id = w.riskAlertId, 
										ANG_Sidra_Lite__c = mapSMAPtoSIDRA.get(sr.getId()).Id));
									break;
								}
							}
						}
					}

					if(!riskAlertsToUpdate.isEmpty())
						update riskAlertsToUpdate;	

					//Newgen-2179 - Generate Change code (Requires a update)
                    AMS_OscarCase_RiskMgmt.EndRun();
                                       
                    list<Case> sidrasToGenerateChangeCode = new list<Case>();
                    for(Case sidraToUpdate : sidraLiteCases){
                        sidraToUpdate.DEF_Approval_Rejection__c = 'Approved';
                        sidraToUpdate.SIDRA_Lite_Default_Date__c = Date.today();
                        sidraToUpdate.Reason_for_Default__c = 'Under Review';
                        sidraToUpdate.Update_AIMS_DEF__c = Date.today();
                        sidraToUpdate.CS_Rep_Acc_DEF__c = userInfo.getUserId();
                        sidrasToGenerateChangeCode.add(sidraToUpdate);
                    }
                    update sidrasToGenerateChangeCode;  
                    //Newgen-2179 - END

					List<Id> caseIds = new List<Id>();
					List<Id> accountIds = new List<Id>();
					for (Case sLiteCase : sidraLiteCases) {
						string configKey=rtsConfigMap.containsKey(accIsoCode.get(sLiteCase.AccountId))?accIsoCode.get(sLiteCase.AccountId):ALL_COUNTRIES_ISOCODE ;
   						if(rtsConfigMap.get(configKey).ANG_Remove_Ticketing_Authority__c){
							caseIds.add(sLiteCase.Id);
							accountIds.add(sLiteCase.AccountId);
						}
					}
					
			        AMS_CaseTriggerHandler.SelectAgencyOnSidraCase(sidraLiteCases);
					bspLinkCallout(caseIds, accountIds);
	            }
			}
		}
	}


	Private Map<Id,operational_Calendar__c> fetchCalendar(List<ANG_Risk_Alert__c> ras){

		Set<String> isoCodes = new Set<String>();
		Set<String> rfs = new Set<String>();
		Map<Id,operational_Calendar__c> ocMap = new Map<Id,operational_Calendar__c>();
		for(ANG_Risk_Alert__c ra : ras){

			isoCodes.add('BSP-' +(raAccMap.get(ra.id).IATA_ISO_Country__r.BSP__c == 'Yes' ? 
							raAccMap.get(ra.id).IATA_ISO_Country__r.BSP_Country_free_text__c : 
							raAccMap.get(ra.id).IATA_ISO_Country__r.ISO_Code__c));

			rfs.add(mapRemittanceFrequency(raAccMap.get(ra.id)));
		}

		List<Operational_Calendar__c> ops = [SELECT id,ISS_Operation__r.Name,Frequency_Code__c,First_Day__c, Last_Day__c, Remittance_Day__c   
			FROM Operational_Calendar__c 
			WHERE Frequency_Code__c IN :rfs
				AND First_Day__c <= :Date.today() 
				AND Last_Day__c >= :Date.today() 
				AND ISS_Operation__r.Name IN :isoCodes
			];
		for(ANG_Risk_Alert__c ra : ras){
			for(Operational_Calendar__c op: ops){
				
				String isoCode = 'BSP-' + (raAccMap.get(ra.id).IATA_ISO_Country__r.BSP__c == 'Yes' ? 
							raAccMap.get(ra.id).IATA_ISO_Country__r.BSP_Country_free_text__c : 
							raAccMap.get(ra.id).IATA_ISO_Country__r.ISO_Code__c);
				
                if(op.ISS_Operation__r.Name == isoCode &&
                    op.Frequency_Code__c == mapRemittanceFrequency(raAccMap.get(ra.id))
                ){

					ocMap.put(ra.ANG_Account__c,op);
					break;
				}
			}
		}
		return ocMap;		
	}

    // NEWGEN-2005
    private void sendNotificationToSeniors(List<ANG_Risk_Alert__c> riskAlerts) {
        List<RTS_Senior_Manager__c> sManagers = RTS_Senior_Manager__c.getAll().values();
        List<EmailTemplate> eTemplates = [SELECT Id, Subject,Body FROM EmailTemplate WHERE DeveloperName = 'RTS_Notification_Manager'];
        List<OrgWideEmailAddress> orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org'];
        if (sManagers.isEmpty() || eTemplates.isEmpty() || orgWideEmail.isEmpty()) {
            System.debug('Warning: Senior Management or email template or org wide email not found');
            return;
        }
        List<String> toAddresses = new List<String>(); 
        for (RTS_Senior_Manager__c sManager: sManagers) {
            if (sManager.Active__c)
            	toAddresses.add(sManager.Email__c);
        }
        EmailTemplate template = eTemplates.get(0);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject(template.Subject); 
        mail.setOrgWideEmailAddressId(orgWideEmail.get(0).Id);
        for (ANG_Risk_Alert__c riskAlert: riskAlerts) {
            String tBody = template.Body;
            String agentSales = (riskAlert.ANG_Agent_Sales__c == null ? '' : String.valueOf(riskAlert.ANG_Agent_Sales__c));
            String iataCode = (raAccMap.get(riskAlert.id).IATACode__c == null ? '' : raAccMap.get(riskAlert.id).IATACode__c);
            String gAmount = (raAccMap.get(riskAlert.id).Guaranteed_amount__c == null ? '' : String.valueOf(raAccMap.get(riskAlert.id).Guaranteed_amount__c.setScale(2)));
            tBody = tBody.replace('{{agentName}}', raAccMap.get(riskAlert.id).Name);
            tBody = tBody.replace('{{iataCode}}', iataCode);
            tBody = tBody.replace('{{iataCountry}}', raAccMap.get(riskAlert.id).IATA_ISO_Country__r.Name);
            tBody = tBody.replace('{{agentSales}}', agentSales);
            tBody = tBody.replace('{{currencyIsoCode}}', (agentSales == '' ? '' : riskAlert.CurrencyIsoCode));
            tbody = tBody.replace('{{fsAmount}}', gAmount);
            
            mail.setPlainTextBody(tBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    // END - NEWGEN-2005
		

	//Remove Ticketing Authority (Deactivate in BSPLink) - NEWGEN-1925

	@Future(callout=true)
	public static void bspLinkCallout(List<Id> sidraLiteCaseIds, List<Id> accountIds) {
		List<ISSP_Web_Service_Log__c> logs = new List<ISSP_Web_Service_Log__c>();
		ISSP_Web_Service_Log__c log;
		Boolean hasError = false;
		Boolean hasSuccess = false;
		String errorMessage = '';
		String successMessage = '';
		Integer size = sidraLiteCaseIds.size();
		List<AMS_BSPLinkIntegration.Response> responses;

		
		map<id,account> accIsoCode= new map<id,account>([Select id, IATA_ISO_Country__c from account where id in:accountIds ]);//map to get account's IsoCode- used to control RTS actions


		map<string,AMS_Country_Specific_Attribute__c> rtsConfigMap= new map<string,AMS_Country_Specific_Attribute__c>();//iso_countr_isoCode__c =>AMS_Country_Specific_Attribute__c
		for(AMS_Country_Specific_Attribute__c csa:  [
			SELECT IATA_ISO_Country__r.ISO_Code__c,ANG_Send_Email_Agent__c,ANG_Create_Sidra_Lite__c,ANG_Remove_Ticketing_Authority__c 
			FROM AMS_Country_Specific_Attribute__c 
			WHERE recordtypeId=: RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('AMS_Country_Specific_Attribute__c').get('RTS_Risk_Alert_Notification') ]){
			rtsConfigMap.put(csa.IATA_ISO_Country__c,csa);
		}
		
        //NEWGEN-2006
        List<Notification__c> notifications = new List<Notification__c>();
        List<Contact> agents = [
            SELECT Id, Name, AccountId, Account.Top_Parent__c FROM Contact WHERE AccountId in (
                SELECT id FROM Account WHERE Top_Parent__c in :accountIds OR Id in :accountIds
            ) AND User_Portal_Status__c = :ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM];
        Map<Id, List<Contact>> mapAccContacts = new Map<Id, List<Contact>>();

        for (Contact c: agents) {
            Id heId =  c.Account.Top_Parent__c != null ? c.Account.Top_Parent__c : c.AccountId;
            if (!mapAccContacts.containsKey(heId))
                mapAccContacts.put(heId, new List<Contact>());
            mapAccContacts.get(heId).add(c);
        }
        //END - NEWGEN-2006

		for (Integer i = 0; i < size; i++) {
			log = new ISSP_Web_Service_Log__c();
			log.Case__c = sidraLiteCaseIds[i];
			log.System__c = 'bsplink';
			errorMessage = 'Following locations were not deactivated in BSPLink:\n';
			successMessage = 'Following locations were deactivated successfully in BSPLink:\n';
			responses = AMS_BSPLinkIntegration.ProcessBSPLinkFromCase('Deactivation', (new List<Id>{accountIds[i]}) ,'FromSidra', sidraLiteCaseIds[i]);
			for (AMS_BSPLinkIntegration.Response r: responses) {
				if (r.result == 'Ok') {
					successMessage = successMessage + '\n ' + r.IATACode;
                    //NEWGEN-2006
                    if (!mapAccContacts.get(accountIds[i]).isEmpty()) {
                        for (Contact c: mapAccContacts.get(accountIds[i])) {
                        	string configKey=rtsConfigMap.containsKey(accIsoCode.get(accountIds[i]).IATA_ISO_Country__c)?accIsoCode.get(accountIds[i]).IATA_ISO_Country__c:ALL_COUNTRIES_ISOCODE ;
                        	if(rtsConfigMap.get(configKey).ANG_Send_Email_Agent__c){
	                            notifications.add(new Notification__c(
	                                Contact__c = c.Id,
		                            Subject__c = Label.RTS_TAR_Notification_Title,
	                                Message__c = '<div style="text-align: justify">' + Label.RTS_TAR_Notification_Message.replace('{{name}}', c.Name) + Label.RTS_TAR_Notification_MessageB + '</div>',
	                                Alert_Contact_By_Email__c = true
	                            ));
	                        }
	                    }
                    }
                    //END - NEWGEN-2006
					hasSuccess = true;
				} else if (r.result == 'Error') {
					hasError = true;
					if (r.IATACode == '-') {
						errorMessage = errorMessage + '\n' + r.description;
					} else {
						errorMessage = errorMessage + '\n ' + r.IATACode + ': ' + r.description;
					}
				}
			}
			if (!hasError) {
				log.Error_Message__c = successMessage;
				log.Success__c = true; 
			}
			if (!hasSuccess) {
				log.Error_Message__c = errorMessage;
			}
			if (hasError && hasSuccess) {
				log.Error_Message__c = successMessage + '\n\n' + errorMessage;
			}
			logs.add(log);
		}// end for loop
        if (!notifications.isEmpty()) {
            insert notifications;
        }
		insert logs;
	}

	private class RiskAlertParentCaseWrapper {
		public Id riskAlertId;
		public Case smap;
		public RiskAlertParentCaseWrapper(Id riskAlertId, Case smap) {
			this.riskAlertId = riskAlertId;
			this.smap = smap;
		}
	}


}