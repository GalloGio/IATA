public class ANG_RHCInformationTriggerHandler{

	//public final Double UPPERFLUCTUATION = 1;
	//public final Double LOWERFLUCTUATION = 2;

	public List<ANG_RHC_Information__c> triggerNew = (List<ANG_RHC_Information__c>) Trigger.new;
	public List<ANG_RHC_Information__c> triggerOld = (List<ANG_RHC_Information__c>) Trigger.old;

	public Map<Id, ANG_RHC_Information__c> newMap = (Map<Id,ANG_RHC_Information__c>) Trigger.newMap;
	public Map<Id, ANG_RHC_Information__c> oldMap = (Map<Id,ANG_RHC_Information__c>) Trigger.oldMap;

	public static Boolean skipConvertAndSumFSAmounts = false;

	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************

	public void onBeforeInsert(){
		convertAndSumFS();
		sumRHCAmount();
	}
	public void onAfterInsert(){
		Map<Id, ANG_RHC_Information__c> tempMap =new Map<Id, ANG_RHC_Information__c>();
		for(ANG_RHC_Information__c rhcrec:triggerNew){
			tempMap.put(rhcrec.id, new ANG_RHC_Information__c());
		}
		new ANG_AgencyEventsGenerator(filterByIATACode(triggerNew),tempMap,'RHC_Information','ANG_AccountId__c').run();
	}
	public void onBeforeUpdate(){
		convertAndSumFS();
		sumRHCAmount();
		//analyzeConsumedRHCAdjustment(); as per NEWGEN-1085

		List<ANG_RHC_Information__c> updatedFlagsForRHCEqsFS = new List<ANG_RHC_Information__c>();

		for(ANG_RHC_Information__c rhc : triggerNew)
			if(rhc.ANG_RHC_Amount_Equals_FS__c != oldMap.get(rhc.id).ANG_RHC_Amount_Equals_FS__c)
				updatedFlagsForRHCEqsFS.add(rhc);

		if (!updatedFlagsForRHCEqsFS.isEmpty()) ANG_RHCHelper.calculateRHCAmount(updatedFlagsForRHCEqsFS, true);

		assessOscarAccreditationForecastRHC(filterByIATACode(triggerNew));

	}
	public void onAfterUpdate(){
		new ANG_AgencyEventsGenerator(filterByIATACode(triggerNew),oldMap,'RHC_Information','ANG_AccountId__c').run();
		refreshRMEData();
		handleRhcUpdate();

		//NEWGEN-6810
		//If the tier changes, create a SAAM case and assign to Regional Risk Queue
		set<Id> setAccntId = new set<Id>();
		for(ANG_RHC_Information__c rhc : triggerNew)
			if(rhc.Tier__c != oldMap.get(rhc.id).Tier__c)
				setAccntId.add(rhc.ANG_AccountId__c);
		
		CreateSAAMCase(setAccntId);
	}

	public void onBeforeDelete(){}
	public void onAfterDelete(){}

	// ************************************************************
	// ********************* action methods ***********************
	// ************************************************************
	private static void CreateSAAMCase(set<Id> setAccntId){
		if(setAccntId.isEmpty())	return;

		map<id, Account> mapAccnt = new map<id, account>([select id, Name, Short_Name__c, IATACode__c, Region_formula__c from Account where id in:setAccntId]);
		list<case> CaseToCreate = new list<case>();

		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.assignmentRuleHeader.useDefaultRule= true;

		List<Portal_Applications__c> rhcServices = [SELECT Id FROM Portal_Applications__c WHERE Name =:ANG_RHCHelper.RISK_PROFILE_AND_RHC_PORTAL_SERVICE];
		Map<String, Set<Id>> rhcContacts = ANG_ISSP_IEPMailRecipientsUtils.getRecipientsPortalServices(setAccntId, new Map<Id, Portal_Applications__c>(rhcServices).keySet()); //this sets use the 15 char id

		for(id AccntId:setAccntId){
			Account acc = mapAccnt.get(AccntId);
			Case c = new Case();
				c.RecordTypeId = AMS_Utils.RECTYPE_SAAM;
				c.AccountId = AccntId;
				c.ContactId = rhcContacts.containsKey(AccntId) ? new List<Id>(rhcContacts.get(AccntId))[0] : null;
				c.Subject = 'RHC Tier change ' + (String.isEmpty(acc.Short_Name__c) ? acc.Name.left(20) : acc.Short_Name__c.left(20));
				c.Region__c = acc.Region_formula__c;
				c.Origin = ANG_Risk_Helper.CASE_ORIGIN_INTERNAL_CASE;
				c.CaseArea__c = ANG_Risk_Helper.CASE_AREA_RISK_MANAGEMENT_PROCESS;
				c.Reason1__c = ANG_Risk_Helper.CASE_REASON_RHC_TIER_CHANGE;
				c.Visible_on_ISS_Portal__c = false;
			c.setOptions(dmo);
			CaseToCreate.add(c);
		}

		if(!CaseToCreate.isEmpty())
			insert CaseToCreate;
	}

	public static List<ANG_RHC_Information__c> filterByIATACode(List<ANG_RHC_Information__c> changeCodes){

		List<ANG_RHC_Information__c> toReturn = new List<ANG_RHC_Information__c>();

		for(ANG_RHC_Information__c rhc : changeCodes)
			if(rhc.ANG_IATA_Code__c <> null)
				toReturn.add(rhc);

		return toReturn;
	}

	private void convertAndSumFS(){

		//In case of rollback RHC record for countries that
		//have the flag RHC Location Type == 'Include All AEs'
		if(skipConvertAndSumFSAmounts){
			return;
		}

		set<id> accIdSet = new set<id>();
		map<id,ANG_RHC_Information__c> accRhcMap = new map<id,ANG_RHC_Information__c>();
		for(ANG_RHC_Information__c rhc:triggerNew){
			if(Trigger.isInsert || Trigger.isUpdate && rhc.currencyIsoCode != oldMap.get(rhc.id).currencyIsoCode){
				accIdSet.add(rhc.ANG_AccountId__c);
				accRhcMap.put(rhc.ANG_AccountId__c,rhc);
			}
		}

		if(!accIdSet.isEmpty()){
			Map<id,list<Financial_Security__c>> accFSmap =new map<id,list<Financial_Security__c>>();
			for(account acc:[SELECT Id, (SELECT Id, amount__c,CurrencyIsoCode,Security_Status__c FROM Financial_Securities__r) FROM Account WHERE Id IN :accIdSet]){
				accFSmap.put(acc.id,acc.Financial_Securities__r);
			}
			list<Financial_Security__c> fsList= new list<Financial_Security__c>();
			for(id accid :accFSmap.KeySet()){
				ANG_Risk_Helper.convertFSAmountToTargetCur(accFSmap.get(accid),accRhcMap.get(accid).CurrencyIsoCode);
				accRhcMap.get(accid).ANG_Financial_Security__c = ANG_Risk_Helper.sumFSConvertedAmounts(accFSmap.get(accid));
				fsList.addAll(accFSmap.get(accid));
			}
			if(!fsList.isEmpty()){
				update fsList;
			}
		}
	}

	private void sumRHCAmount() {
		map<id, ANG_RHC_Information__c> rhcToSum = new map<id, ANG_RHC_Information__c>();
		map<id, ANG_RHC_Information__c> rhcToNotRecalculate = new map<id, ANG_RHC_Information__c>();
		for(ANG_RHC_Information__c rhcInfo : triggerNew){
			if(
				rhcinfo.ANG_Enable_Calculation__c &&
				(
					Trigger.isInsert
					|| rhcInfo.ANG_CashCondition__c != oldMap.get(rhcInfo.Id).ANG_CashCondition__c
					|| rhcInfo.ANG_RME_Amount__c != oldMap.get(rhcInfo.Id).ANG_RME_Amount__c
					|| rhcInfo.ANG_Financial_Security__c != oldMap.get(rhcInfo.Id).ANG_Financial_Security__c
					|| rhcInfo.ANG_Minimum_Financial_Security__c != oldMap.get(rhcInfo.Id).ANG_Minimum_Financial_Security__c
					|| rhcInfo.ANG_RHC_Amount_Equals_FS__c != oldMap.get(rhcInfo.Id).ANG_RHC_Amount_Equals_FS__c
				)
			){
				rhcToSum.put(rhcInfo.id, rhcInfo);
			}

			if(Trigger.isUpdate && rhcinfo.ANG_Enable_Calculation__c && (rhcInfo.ANG_RHC_Amount_Provisional__c != oldMap.get(rhcInfo.Id).ANG_RHC_Amount_Provisional__c)){
				if(!rhcToSum.containsKey(rhcInfo.id))
					rhcToNotRecalculate.put(rhcInfo.id, rhcInfo);
			}
		}

		if(!rhcToSum.isEmpty()) ANG_RHCHelper.calculateRHCAmount(rhcToSum.values());
		if(!rhcToNotRecalculate.isEmpty()) ANG_RHCHelper.calculateRHCAmount(rhcToNotRecalculate.values(), false);

		for(ANG_RHC_Information__c rhc : triggerNew){
			if(Trigger.isInsert || oldMap.get(rhc.id).ANG_RHC_Amount__c != rhc.ANG_RHC_Amount__c) rhc.ANG_RHC_Effective_Date__c=System.Today();
		}
	}

	private void refreshRMEData() {

		Set<Id> accIds = new Set<Id>();
		for(ANG_RHC_Information__c r : triggerNew){
			if(!r.ANG_CashCondition__c && oldMap.get(r.Id).ANG_CashCondition__c) accIds.add(r.ANG_AccountId__c);
		}
		/* **** INC424176 ****
			 ****  Disable the Provisional RHC re-calculation call from RME ****
		if(!accIds.isEmpty()) {
			if(Limits.getLimitQueueableJobs() <= Limits.getQueueableJobs()) Database.executeBatch(new ANG_UpdateRHCInformationBatch(accIds, ANG_UpdateRHCInformationBatch.Process.PROVISIONAL, true, 1));
			else System.enqueueJob(new ANG_UpdateRHCInformationQueueable(accIds, ANG_UpdateRHCInformationBatch.Process.PROVISIONAL, true, 1));
		}*/

		if(!accIds.isEmpty()) {
			if(Limits.getLimitQueueableJobs() <= Limits.getQueueableJobs()) {
				Database.executeBatch(new ANG_UpdateRHCInformationBatch(accIds, ANG_UpdateRHCInformationBatch.Process.CONSUMED, false, 1));
			} else {
				if(System.isBatch() && Limits.getQueueableJobs() == 1) {
					Datetime execTime = Datetime.now().addSeconds(5);
					String hour = String.valueOf(execTime.hour());
					String min = String.valueOf(execTime.minute());
					String ss = String.valueOf(execTime.second());
					String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
					System.schedule('ANG_UpdateRHCInformationScheduler ' + String.valueOf(Math.random()), nextFireTime,
						new ANG_UpdateRHCInformationScheduler(accIds, ANG_UpdateRHCInformationBatch.Process.CONSUMED, false, 1));
				} else {
					System.enqueueJob(new ANG_UpdateRHCInformationQueueable(accIds, ANG_UpdateRHCInformationBatch.Process.CONSUMED, false, 1));
				}
			}
		}
	}

		public static void assessOscarAccreditationForecastRHC(List<ANG_RHC_Information__c> rhcLst){

		if(!AMS_OscarTriggerHandler.applyRHCForecast || rhcLst.size() > 1)
			return;

		System.debug('[ANG_RHCInformationTriggerHandler] Applying ANG_RHC_Amount__c = ANG_RHC_Amount_Forecasted__c to new Oscar Accredited RHC Info.');

		ANG_RHC_Information__c rhc = rhcLst.get(0);
		rhc.ANG_RHC_Amount__c = rhc.ANG_RHC_Amount_Forecasted__c;
		rhc.ANG_RHC_Effective_Date__c = System.today();

	}

	private void handleRhcUpdate(){

		Set<Id> toNotify = new Set<Id>();

		for(ANG_RHC_Information__c rhc : triggerNew){
			if(!ANG_RHCHelper.updateNotificationAlreadySent.contains(rhc.ANG_AccountId__c) && rhc.ANG_RHC_Amount__c != oldMap.get(rhc.Id).ANG_RHC_Amount__c){
				Boolean sendNotification = true;

				for(AMS_Country_Specific_Attribute__c att : IATAIsoCountryDAO.getIsoCountryByIsoCodes(new Set<String>{rhc.ANG_Account_Country_ISO_Code__c}).get(0).AMS_Country_Specific_Attributes__r){
					if(att.recordtypeid == AMS_Utils.RECTYPE_CSA_RISK_NOTIFICATION && att.Block_notification_on_RHC_amount_update__c){
						sendNotification = false;
						break;
					}
				}

				if(sendNotification) toNotify.add(rhc.ANG_AccountId__c);
			}
		}

		if(!toNotify.isEmpty()){
			ANG_RHCHelper.handleRiskOrForecastedRhcAmountUpdates(toNotify);
		}

	}
}
