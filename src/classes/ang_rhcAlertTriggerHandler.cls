public class ang_rhcAlertTriggerHandler{

	public List<ANG_Risk_Alert__c> triggerNew = (List<ANG_Risk_Alert__c>) Trigger.new;
	public List<ANG_Risk_Alert__c> triggerOld = (List<ANG_Risk_Alert__c>) Trigger.old;

	public Map<Id, ANG_Risk_Alert__c> newMap = (Map<Id,ANG_Risk_Alert__c>) Trigger.newMap;
	public Map<Id, ANG_Risk_Alert__c> oldMap = (Map<Id,ANG_Risk_Alert__c>) Trigger.oldMap;

	private static String RHC_AMOUNT_USED = '#RHC_AMOUNT_USED#';
	private static String RHC_AMOUNT_TOTAL = '#RHC_AMOUNT_TOTAL#';
	private static String RHC_PERCENTAGE = '#RHC_PERCENTAGE#';
	private static String RHC_INFORMATION = 'RHC Information';

	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************

	public void onBeforeInsert(){
	}
	public void onAfterInsert() {
		sendAlertNotification();
	}

	public void onBeforeUpdate(){
	}
	public void onAfterUpdate() {
	}

	public void onBeforeDelete(){}
	public void onAfterDelete() {}






	public void sendAlertNotification(){
		
		system.debug(' ang_rhcAlertTriggerHandler sendAlertNotifications STARTED');

		Set<String> RHC_Inf_Ids = new Set<String>();
		for(ANG_Risk_Alert__c ralert : triggerNew) {
			RHC_Inf_Ids.add(ralert.ANG_RHC_Information__c);
		}

		List<ANG_RHC_Information__c> RHC_Inf_List = [Select Id,
															ANG_AccountId__r.IATACode__c,
															ANG_RHC_Amount__c,
															ANG_ConsumedRHC__c,
															ANG_ConsumedRHC_Percent__c
													   From ANG_RHC_Information__c
													  Where id in : RHC_Inf_Ids];

		Map<Id, ANG_RHC_Information__c> RHC_Map = new Map<Id, ANG_RHC_Information__c>();
		for(ANG_RHC_Information__c rhc : RHC_Inf_List) {
			RHC_Map.put(rhc.id, rhc);
		}

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

					// Create a notification on the portal.

					ANG_RHC_Information__c rhc = RHC_Map.get(ralert.ANG_RHC_Information__c);

					String replaceStr = RHC_AMOUNT_USED + '!' + rhc.ANG_ConsumedRHC__c.format() + '|' +
										RHC_AMOUNT_TOTAL + '!' + rhc.ANG_RHC_Amount__c.format() + '|' +
										RHC_PERCENTAGE + '!' + rhc.ANG_ConsumedRHC_Percent__c.format();

			        ISSP_WS_CreateNotification.inputData myInputData = new ISSP_WS_CreateNotification.inputData();

			        myInputData.iataCode = rhc.ANG_AccountId__r.IATACode__c;
			        myInputData.serviceName = RHC_INFORMATION;
			        myInputData.listOfUsers = new List<String>();
			        myInputData.templateName = at.ANG_Portal_Notification_Template__c;
			        myInputData.daysToExpire = 0;
			        myInputData.emailAlert = false;
			        myInputData.criticalNotification = false;
			        myInputData.replaceStr = replaceStr;

					ISSP_WS_CreateNotification.createNotification(myInputData);

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
}