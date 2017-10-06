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

		for(ANG_Risk_Alert__c ra :triggerNew){
			if(ra.ANG_Severity__c == 'Red' &&  ra.recordTypeid == Schema.SObjectType.ANG_Risk_Alert__c.getRecordTypeInfosByName().get('Risk Alert RTS').getRecordTypeId()){
				redAlerts.add(ra);
			}
		}

		if(!redAlerts.isEmpty()){
			//create Sidra Lites

			Id smapCaseRTId = AMS_Utils.RECTYPE_SMAP;
			Case smapCase;
			List<Case> sidraLiteCases;

			List<Case> smapCases = new List<Case>();

			for(ANG_Risk_Alert__c ra: triggerNew){

				//confirm all this fileds 
				smapCase = new Case(
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
					Suspension_Date__c=  date.newinstance(2017, 2, 17)


				);
				System.debug('##SMAP case: ' + smapCase);
				smapCases.add(smapCase);
			} 
			//if not empty

			if(!smapCases.isEmpty()){
				insert smapCases;


				Case sidraCase;
				sidraLiteCases = new List<Case>();

				for(Case sCase :[Select Id, IATAcode__c, Account.Name, Account.Site, Region__c, BSPCountry__c, ParentId FROM Case WHERE Id IN: smapCases]){

					//fill fields on sidra case - see story NEWGEN-1933
					sidraCase = WSSidraLite.createCase(sCase.id);

					sidraCase.Subject = 'RTS Alert' + ' - '+ sCase.Account.Site + ' - ' + sCase.Account.Name;
					sidraCase.Case_Remarks__c = '';
					sidraCase.Description = '';					
					sidraCase.Region__c = sCase.Region__c; 
					sidraCase.BSPCountry__c = sCase.BSPCountry__c;
					sidraCase.BSP_CASS__c = 'BSP'; // ?  BSP/CASS: This should be populated with the BSP/CASS of the Agent (Note: this should always be BSP) 
					sidraCase.Status = 'Open'; 
					sidraCase.Origin = 'Risk Monitoring Engine'; 
					sidraCase.SIDRA_Lite_Reason__c = 'Prejudiced Collection of Funds'; 
					sidraCase.Priority = 'High'; 
					//sidraCase.Accountid = sCase.Accountid;

					//confirm if i can use this logic to get the contact or if i show run all hiearchy
					List<Contact> contacts = new List<Contact>();
					if(sCase.ParentId != null){
						contacts = [SELECT id FROM CONTACT WHERE ACCOUNTID = :sCase.Parent.Id AND User_Portal_Status__c = 'Approved Admin'];
					}

					else{
						contacts = [SELECT id FROM CONTACT WHERE ACCOUNTID = :sCase.id AND User_Portal_Status__c = 'Approved Admin'];
					}

					if(!contacts.isEmpty())
						sidraCase.Contact = contacts[0];

					//sidraCase.IsComplaint__c	: blank ... but is a checkbox..... 
					//sidraCase.R_S_feedback_pending__c : TBD?
					//sidraCase.New_interaction__c : TBD ??



			//------------FORMULAS - PROBABLY NO NEED TO DO ANYTHING --------
					//sidraCase.Case_Email_Domain_Validation__c = ''; 
					//sidraCase.Account_Location_Type__c = 'HO'; //  ?:  Note: this is based on the Agent and should always be HO 
					//sidraCase.Status_SIDRA__c = ''; 
					//sidraCase.Key_Customer_Case__c 
					//sidraCase.Account_Type__c.... soooo.... 
					//sidraCase.CaseNumber: formula field (BUT IT IS A AUTO NUMBER  O.o) 
					//sidraCase.AIMS_status__c : formula field 
					//sidraCase.IATA_Code__c : formula field 


					sidraLiteCases.add(sidraCase);
				}

				if(!sidraLiteCases.isEmpty()){
					insert sidraLiteCases;
				}
			}

			//Remove Ticketing Authority (Deactivate in BSPLink) - NEWGEN-1925
		}
	}
}