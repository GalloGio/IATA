public class ang_rhcAlertTriggerHandler{

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



	public static map<String,String> mapRemittanceFrequency = new map<String,String> {
       	'Daily' => 'D',
       	'4 times per month' => 'E',
		'Fortnightly' => 'F',
		'Monthly' => 'M',
		'Every 5 days' => 'R',
		'Every 3 days' => 'T',
		'Weekly' => 'W',
		'Every 10 days' => 'X'
    };   

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
		Map<String,ANG_Risk_Alert__c> mapAccountRiskAlert = new Map<String,ANG_Risk_Alert__c>();

		for(ANG_Risk_Alert__c ra :triggerNew){
			if(ra.ANG_Severity__c == 'Red' &&  ra.recordTypeid == Schema.SObjectType.ANG_Risk_Alert__c.getRecordTypeInfosByName().get('Risk Alert RTS').getRecordTypeId()){
				redAlerts.add(ra);
				mapAccountRiskAlert.put(ra.ANG_Account__c,ra);
			}
		}

		if(!redAlerts.isEmpty()){
			//create Sidra Lites

			Case smapParentCase;
			List<Case> sidraLiteCases;
			List<Case> smapParentCases = new List<Case>();
			Map<String,case> mapCaseRiskAlert = new Map<String,case>();

			for(ANG_Risk_Alert__c ra: redAlerts){

				//TODO: confirm all this fileds 
				smapParentCase = new Case(
					Region__c =	ra.ANG_Account__r.Region__c,
					Subject = '',
					AccountId = ra.ANG_Account__c,
					Status = 'Accepted',
					BSP_CASS__c = 'BSP',
					Origin = 'Other',
					Decision__c = 'Prejudiced Collection of Funds',
					RecordTypeId = SidraLiteManager.RECORDTYPE_SMAP,
					Next_Remittance_Date__c =  date.newinstance(2018, 2, 17),
					Start_Date_of_Sales_Period__c=  date.newinstance(2018, 2, 17),
					End_Date_of_Sales_Period__c=  date.newinstance(2018, 2, 17),
					Suspension_Date__c=  Date.today()
				);
				smapParentCases.add(smapParentCase);
			} 

			if(!smapParentCases.isEmpty()){
				//insert smapParentCases;
				Database.SaveResult[] srList = Database.insert(smapParentCases, false);

			for(Case parentCase :smapParentCases){
				mapCaseRiskAlert.put(parentCase.Id,parentCase);			
			}

				List<ANG_Risk_Alert__c> riskAlertsToUpdate = new List<ANG_Risk_Alert__c>();
				// Iterate through each returned result
				for (Database.SaveResult sr : srList) {
				    if (sr.isSuccess()) {
				    	//because trigger is running on after inset we need a new instace and DML operation to update 
				    	riskAlertsToUpdate.add(new ANG_Risk_Alert__c(id = mapAccountRiskAlert.get(mapCaseRiskAlert.get(sr.getId()).AccountId).id, ANG_Is_Case_Created__c = true));
					}
				}

				if(!riskAlertsToUpdate.isEmpty())
					update riskAlertsToUpdate;

				Case sidraLiteCase;
				sidraLiteCases = new List<Case>();

				for(Case parentCase :[Select Id, IATAcode__c, Account.Name, Account.Site, Region__c, BSPCountry__c, ParentId FROM Case WHERE Id IN: smapParentCases]){

					//NEWGEN-1933 fill fields on sidra case
					sidraLiteCase = WSSidraLite.createCase(parentCase.id);
					//TODO: confirm on "sidraCase.Subject" if account site or account IATA code
					sidraLiteCase.Subject = 'RTS Alert' + ' - ' + parentCase.Account.Site + ' - ' + parentCase.Account.Name;
					sidraLiteCase.Case_Remarks__c = '';
					sidraLiteCase.Description = '';					
					sidraLiteCase.Region__c = parentCase.Region__c; 
					sidraLiteCase.BSPCountry__c = parentCase.BSPCountry__c;
					sidraLiteCase.BSP_CASS__c = 'BSP';
					sidraLiteCase.Status = 'Open'; 
					sidraLiteCase.Origin = 'Risk Monitoring Engine'; 
					sidraLiteCase.SIDRA_Lite_Reason__c = 'Prejudiced Collection of Funds'; 
					sidraLiteCase.Priority = 'High'; 
					sidraLiteCase.Shut_Down_TKT_System_GDS_and_BSPlink__c = Datetime.now();

					//TODO: confirm if I can use this logic to get the contact or if i should run all hiearchy
					List<Contact> contacts = new List<Contact>();
					if (parentCase.ParentId != null) {
						contacts = [SELECT Id FROM Contact WHERE AccountId = :parentCase.Account.Top_Parent__c AND User_Portal_Status__c = :ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM];
					} else {
						contacts = [SELECT Id FROM Contact WHERE AccountId = :parentCase.AccountID AND User_Portal_Status__c = :ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM];
					}

					if(!contacts.isEmpty())
						sidraLiteCase.Contact = contacts[0];
					
					//END -NEWGEN-1933
					sidraLiteCases.add(sidraLiteCase);

				}

				if (!sidraLiteCases.isEmpty()) {
					insert sidraLiteCases;
					List<Id> caseIds = new List<Id>();
					List<Id> accountIds = new List<Id>();
					for (Case sLiteCase : sidraLiteCases) {
						caseIds.add(sLiteCase.Id);
						accountIds.add(sLiteCase.AccountId);
					}
					
                    AMS_CaseTriggerHandler.SelectAgencyOnSidraCase(sidraLiteCases);
					bspLinkCallout(caseIds, accountIds);
                }


			}

		}
	}

	//Remove Ticketing Authority (Deactivate in BSPLink) - NEWGEN-1925

	Private operational_Calendar__c fetchCalendar(ANG_Risk_Alert__c ra){

		return [select id from Operational_Calendar__c 
			where ISS_operation__c =:ra.ANG_Account__r.IATA_ISO_Country__r.AMS_Settlement_System__c 
			AND Frequency_Code__c = :mapRemittanceFrequency.get(ra.ANG_Account__r.Remittance_frequency__c)
			LIMIT 1];
	}

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

        //NEWGEN-2006
        List<Notification__c> notifications = new List<Notification__c>();
        List<Contact> agents = [
            SELECT Id, AccountId, Account.Top_Parent__c FROM Contact WHERE AccountId in (
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
                            notifications.add(new Notification__c(
                                Contact__c = c.Id,
                                Subject__c = Label.RTS_TAR_Notification_Title,
                                Message__c = Label.RTS_TAR_Notification_Message,
                                Alert_Contact_By_Email__c = true
                            ));
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
}