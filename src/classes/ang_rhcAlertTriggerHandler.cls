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
		List<RiskAlertParentCaseWrapper> wrapperList = new List<RiskAlertParentCaseWrapper>();
		List<Id> listIDAccsToRetriveCons = new List<Id>(); 

		//NEEDED QUERY BECAUSE WE WEREN'T GETTING ALL FIELDS NEEDED FROM TRIGGER
		for(ANG_Risk_Alert__c ra :[
			SELECT ID,Name,ANG_Account__c,ANG_Sidra_Lite__c,ANG_Agent_Sales__c,ANG_Direction__c,ANG_email_sent__c,
					ANG_EventId__c,ANG_RHC_Information__c,ANG_RME_Last_Update__c,ANG_Severity__c,ANG_Threshold_Level__c,
					ANG_Account__r.IATA_ISO_Country__r.BSP__c,ANG_Account__r.IATA_ISO_Country__r.BSP_Country_free_text__c,
					ANG_Account__r.Remittance_frequency__c,ANG_Account__r.IATA_ISO_Country__c,ANG_Account__r.IATA_ISO_Country__r.Name,
					ANG_Account__r.IATA_ISO_Country__r.ISO_Code__c, ANG_Account__r.Region_formula__c, ANG_Account__r.Top_Parent__c  
				FROM ANG_Risk_Alert__c 
				WHERE ID IN :triggerNew
				AND ANG_Severity__c = 'Red' 
				AND recordTypeid = :Schema.SObjectType.ANG_Risk_Alert__c.getRecordTypeInfosByName().get('Risk Alert RTS').getRecordTypeId() ]){

				redAlerts.add(ra);
				listIDAccsToRetriveCons.add( (ra.ANG_Account__r.Top_Parent__c != null ? ra.ANG_Account__r.Top_Parent__c : ra.ANG_Account__c ) );

			//}
		}

		if(!redAlerts.isEmpty()){
			//create Sidra Lites

			Map<Id,List<Contact>> contactsPerAccount = new Map<Id,List<Contact>>();

			List<Contact> contacts = new List<Contact>();
			contacts = [SELECT Id, User_Portal_Status__c, AccountId, Account.Top_Parent__c, Financial_Assessment_Contact__c 
						FROM Contact WHERE AccountId IN :listIDAccsToRetriveCons  AND Status__c = 'Active'];

			for (Contact con :contacts){
				if(contactsPerAccount.keyset().contains(con.AccountId)){
					contactsPerAccount.get(con.AccountId).add(con);
				}
				else{
					contactsPerAccount.put(con.AccountId,new List<Contact>{con});
				}
			}

			//create Parent Case
			Case smapParentCase;
			List<Case> sidraLiteCases;
			List<Case> smapParentCases = new List<Case>();
			Map<String,case> mapCaseRiskAlert = new Map<String,case>();
			Set<Id> accountsIds = new Set<Id>();
			Map<Id,Operational_Calendar__c> mapAccountOpCalendar = fetchCalendar(redAlerts);
			for(ANG_Risk_Alert__c ra: redAlerts){

				//TODO: confirm all this fileds 
				smapParentCase = new Case(
					Region__c =	ra.ANG_Account__r.Region_formula__c,
					Subject = '',
					AccountId = ra.ANG_Account__c,
					Status = 'Accepted',
					BSP_CASS__c = 'BSP',
					Origin = 'Risk Monitoring Engine',
					BSPCountry__c = ra.ANG_Account__r.IATA_ISO_Country__r.Name,
					Decision__c = 'Prejudiced Collection of Funds',
					RecordTypeId = SidraLiteManager.RECORDTYPE_SMAP,
					Next_Remittance_Date__c = mapAccountOpCalendar.get(ra.ANG_Account__c).Remittance_Day__c,
					Start_Date_of_Sales_Period__c = mapAccountOpCalendar.get(ra.ANG_Account__c).First_Day__c,
					End_Date_of_Sales_Period__c = mapAccountOpCalendar.get(ra.ANG_Account__c).Last_Day__c, 
					Suspension_Date__c=  Date.today()
				);
				wrapperList.add(new RiskAlertParentCaseWrapper(ra.Id, smapParentCase));

				//we'll get the portal approved admin or if none the ifap contact 
				//if has parent, use parent contacts. else, use theirs
				Id accId = (ra.ANG_Account__r.Top_Parent__c != null ? ra.ANG_Account__r.Top_Parent__c: ra.ANG_Account__c);
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
			if(!smapParentCases.isEmpty()){
				//insert smapParentCases --> all or none = false;
				//need to store result to later interate the correct ones and then atribute the sidra case to the Alert  
				Database.SaveResult[] resultInsSMAPcases = Database.insert(smapParentCases, false);

			for(Case parentCase :smapParentCases){
				mapCaseRiskAlert.put(parentCase.Id,parentCase);			
			}

			//Create SIDRA CASE NOW
			Case sidraLiteCase;
			Map<Id,Case> mapSMAPtoSIDRA = new Map<Id,Case>(); 
			sidraLiteCases = new List<Case>();

			for(Case parentCase :[Select Id, IATAcode__c, Account.Name,Account.IATACode__c, Account.Site, Region__c, BSPCountry__c, ParentId FROM Case WHERE Id IN: smapParentCases]){

				//NEWGEN-1933 fill fields on sidra case
				sidraLiteCase = WSSidraLite.createCase(parentCase.id);
				//TODO: confirm on "sidraCase.Subject" if account site or account IATA code
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
				//sidraLiteCase.Shut_Down_TKT_System_GDS_and_BSPlink__c = Datetime.now(); already done on callout
				sidraLiteCase.ContactId = smapParentCase.ContactId;
				
				//END -NEWGEN-1933
				sidraLiteCases.add(sidraLiteCase);
				mapSMAPtoSIDRA.put(parentCase.id,sidraLiteCase);

			}


			if (!sidraLiteCases.isEmpty()) {
				insert sidraLiteCases;

				for(ANG_risk_Alert__c ra : redAlerts){
					ra.ANG_Sidra_Lite__c = sidraLiteCases[0].id;
					system.debug('## writhing this: ' + ra.ANG_Sidra_Lite__c);
				}
				update redAlerts;

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


	Private Map<Id,operational_Calendar__c> fetchCalendar(List<ANG_Risk_Alert__c> ras){

		Set<String> isoCodes = new Set<String>();
		Set<String> rfs = new Set<String>();
		Map<Id,operational_Calendar__c> ocMap = new Map<Id,operational_Calendar__c>();
		for(ANG_Risk_Alert__c ra : ras){

			isoCodes.add('BSP-' +(ra.ANG_Account__r.IATA_ISO_Country__r.BSP__c == 'Yes' ? 
							ra.ANG_Account__r.IATA_ISO_Country__r.BSP_Country_free_text__c : 
							ra.ANG_Account__r.IATA_ISO_Country__r.ISO_Code__c));

			rfs.add(mapRemittanceFrequency.get(ra.ANG_Account__r.Remittance_frequency__c));

		}

		List<Operational_Calendar__c> ops = [SELECT id,ISS_Operation__r.Name,Frequency_Code__c,First_Day__c, Last_Day__c, Remittance_Day__c   
			FROM Operational_Calendar__c 
			WHERE Frequency_Code__c IN :rfs
				AND First_Day__c <= :Date.today() 
				AND Last_Day__c >= :Date.today() 
				AND ISS_Operation__r.Name IN :isoCodes
			];
			system.debug('##OPS' + isoCodes);
			system.debug('##OPS' + ops);
			system.debug('##rfs' + rfs);
		for(ANG_Risk_Alert__c ra : ras){
			for(Operational_Calendar__c op: ops){
				
				String isoCode = 'BSP-' + (ra.ANG_Account__r.IATA_ISO_Country__r.BSP__c == 'Yes' ? 
							ra.ANG_Account__r.IATA_ISO_Country__r.BSP_Country_free_text__c : 
							ra.ANG_Account__r.IATA_ISO_Country__r.ISO_Code__c);
				
				if(op.ISS_Operation__r.Name == isoCode &&
					op.Frequency_Code__c == mapRemittanceFrequency.get(ra.ANG_Account__r.Remittance_frequency__c)
				){
					ocMap.put(ra.ANG_Account__c,op);
					break;
				}
			}
		}
		return ocMap;
	}

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