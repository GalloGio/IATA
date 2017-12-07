public class ANG_RHCAlertTriggerHandler{

	public List<ANG_Risk_Alert__c> triggerNew = (List<ANG_Risk_Alert__c>) Trigger.new;
	public List<ANG_Risk_Alert__c> triggerOld = (List<ANG_Risk_Alert__c>) Trigger.old;

	public Map<Id, ANG_Risk_Alert__c> newMap = (Map<Id,ANG_Risk_Alert__c>) Trigger.newMap;
	public Map<Id, ANG_Risk_Alert__c> oldMap = (Map<Id,ANG_Risk_Alert__c>) Trigger.oldMap;

	public static final String DEFAULT_CODE = 'WW';

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
	public void onAfterDelete(){}

	// ************************************************************
	// ********************* action methods ***********************
	// ************************************************************

	public void sendAlertNotification(){

		System.debug(loggingLevel.Debug, '____ [cls ANG_RHCAlertTriggerHandler - sendAlertNotification] Method Started');

		//fecth AMS Country Specifc Attributes for the accounts/countries involved
		Map<Id, Account> accounts = new Map<Id, Account>();
		Map<Id, Id> countries = new Map<Id, Id>();
		for(ANG_Risk_Alert__c a : triggerNew) accounts.put(a.ANG_Account__c, null);

		Map<String, AMS_Country_Specific_Attribute__c> configs = new Map<String, AMS_Country_Specific_Attribute__c>();
		Set<Id> newGenAccounts = new Set<Id>();
		Set<Id> legacyAccounts = new Set<Id>();
		for(IATA_ISO_Country__c c : [SELECT
										Id
										, ANG_Enable_NewGen__c
										, ISO_Code__c
										, (SELECT 
											ANG_Direction__c
											, ANG_Percentage__c
											, ANG_EmailTemplate_Legacy__c
											, ANG_EmailTemplate_NG__c
											, ANG_PortalNotificationTemplate__c
											, ANG_Create_Process_Case__c
											FROM AMS_Country_Specific_Attributes__r
											WHERE RecordTypeId = :ANG_RHCHelper.RECTYPE_RHCATTRIBUTE)
										, (SELECT 
											Id
											, Name
											, Short_Name__c
											, IATACode__c
											, ANG_IsNewGenAgency__c
											, Region_formula__c
											, BillingCountry
											FROM Accounts_ISO_Country__r
											WHERE Id IN :accounts.keySet())
									FROM IATA_ISO_Country__c]){
			for(Account a : c.Accounts_ISO_Country__r){
				accounts.put(a.Id, a);
				countries.put(a.Id, c.Id);
				if(c.ANG_Enable_NewGen__c) newGenAccounts.add(a.Id);
				else legacyAccounts.add(a.Id);
			}
			for(AMS_Country_Specific_Attribute__c att : c.AMS_Country_Specific_Attributes__r) configs.put((c.ISO_Code__c == DEFAULT_CODE ? c.ISO_Code__c : c.Id) + att.ANG_Direction__c + att.ANG_Percentage__c, att);
		}

		if(configs.isEmpty()) return; //no configurations set, no need to check further

		//check if any of the risk alerts match the Country Specific Attributes and gather information to query other objects
		Map<ANG_Risk_Alert__c, AMS_Country_Specific_Attribute__c> alertsToNotify = new Map<ANG_Risk_Alert__c, AMS_Country_Specific_Attribute__c>();
		Set<String> emailTemplateNames = new Set<String>();
		Set<String> notificationTemplates = new Set<String>();

		for(ANG_Risk_Alert__c a : triggerNew){
			String key = countries.get(a.ANG_Account__c) + a.ANG_Direction__c + a.ANG_Threshold_Level__c;
			if(!configs.containsKey(key)) key = DEFAULT_CODE + a.ANG_Direction__c + a.ANG_Threshold_Level__c;
			
			if(configs.containsKey(key)){
				AMS_Country_Specific_Attribute__c config = configs.get(key);

				alertsToNotify.put(a, config);

				if(String.isNotEmpty(config.ANG_EmailTemplate_Legacy__c)) emailTemplateNames.add(config.ANG_EmailTemplate_Legacy__c);
				if(String.isNotEmpty(config.ANG_EmailTemplate_NG__c)) emailTemplateNames.add(config.ANG_EmailTemplate_NG__c);
			}
		}

		if(alertsToNotify.isEmpty()) return; //no match, no need to go further

		//Fetch email templates and RHC Information 
		
		Map<String, Id> emailTemplates = new Map<String, Id>();
		if(!emailTemplateNames.isEmpty()){
			for(EmailTemplate e : [SELECT Id, Name FROM EmailTemplate WHERE Name IN :emailTemplateNames AND isActive = true]){
				emailTemplates.put(e.Name, e.Id);
			}
		}

		Map<Id, ANG_RHC_Information__c> rhcInfo = new Map<Id, ANG_RHC_Information__c>();
		for(ANG_RHC_Information__c r : [SELECT 
										Id
										, CurrencyIsoCode
										, ANG_AccountId__c
										, ANG_RHC_Amount__c
										, ANG_ConsumedRHC__c
										, ANG_ConsumedRHC_Percent__c
										FROM ANG_RHC_Information__c
										WHERE ANG_AccountId__c in :accounts.keySet()]){
			rhcInfo.put(r.ANG_AccountId__c, r);
		}

		List<Portal_Applications__c> rhcServices = [SELECT Id FROM Portal_Applications__c WHERE Name = 'RHC Information'];
		Map<String, Set<Id>> rhcContacts = ANG_ISSP_IEPMailRecipientsUtils.getRecipientsPortalServices(newGenAccounts, new Map<Id, Portal_Applications__c>(rhcServices).keySet()); //this sets use the 15 char id

		Map<Id, Set<Id>> portalAdmins = new Map<Id, Set<Id>>();
		for(Contact c : [SELECT Id, AccountId, Account.Top_Parent__c FROM Contact WHERE User_Portal_Status__c = :ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM AND (Account.Top_Parent__c IN :legacyAccounts OR AccountId IN :legacyAccounts)]){

			Id accId;
			if(legacyAccounts.contains(c.AccountId)) accId = c.AccountId;
			else if (legacyAccounts.contains(c.Account.Top_Parent__c)) accId = c.Account.Top_Parent__c;
			else continue;

			if(portalAdmins.containsKey(accId)) portalAdmins.get(accId).add(c.Id);
			else portalAdmins.put(accId, new Set<Id>{c.Id});
		}

		Map<Id, Id> contactAccounts = new Map<Id, Id>();
		List<ANG_RHCHelper.Email> mailList = new List<ANG_RHCHelper.Email>();
		List<Case> processCases = new List<Case>();
		List<String> notificationTargets = new List<String>();
		Set<Id> notifiedAlerts = new Set<Id>();
		for(ANG_Risk_Alert__c a : alertsToNotify.keySet()){
			AMS_Country_Specific_Attribute__c config = alertsToNotify.get(a);

			if(portalAdmins.containsKey(a.ANG_Account__c) && !String.isEmpty(config.ANG_EmailTemplate_Legacy__c)){
				for(Id contact : portalAdmins.get(a.ANG_Account__c)){
					notifiedAlerts.add(a.Id);
					mailList.add(new ANG_RHCHelper.Email(contact, rhcInfo.get(a.ANG_Account__c).Id, emailTemplates.get(config.ANG_EmailTemplate_Legacy__c)));
				}
			}

			String accountId = String.valueOf(a.ANG_Account__c).substring(0,15);
			if(rhcContacts.containsKey(accountId) && (!String.isEmpty(config.ANG_EmailTemplate_NG__c) || !String.isEmpty(config.ANG_PortalNotificationTemplate__c))){
				for(Id contact : rhcContacts.get(accountId)){
					contactAccounts.put(contact, a.ANG_Account__c);

					if(!String.isEmpty(config.ANG_EmailTemplate_NG__c)){
						notifiedAlerts.add(a.Id);
						mailList.add(new ANG_RHCHelper.Email(contact, rhcInfo.get(a.ANG_Account__c).Id, emailTemplates.get(config.ANG_EmailTemplate_NG__c)));
					}
					if(!String.isEmpty(config.ANG_PortalNotificationTemplate__c)) notificationTargets.add(contact + ':' + config.ANG_PortalNotificationTemplate__c);
				}
			}

			String processRecorType = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('CS_Process_IDFS_ISS');
			Database.DMLOptions dmlOpts = new Database.DMLOptions();
			dmlOpts.assignmentRuleHeader.useDefaultRule = true;

			if(config.ANG_Create_Process_Case__c){
				Account acc = accounts.get(a.ANG_Account__c);

				Case c = new Case();
				c.RecordTypeId = processRecorType;
				c.AccountId = acc.Id;
				c.ContactId = rhcContacts.containsKey(accountId) ? new List<Id>(rhcContacts.get(accountId))[0] : null;
				c.Subject = (String.isEmpty(acc.Short_Name__c) ? acc.Name.left(20) : acc.Short_Name__c.left(20)) + ' - ' + acc.IATACode__c + ' - RHC 75';
				c.Region__c = acc.Region_formula__c;
				c.BSPCountry__c = acc.BillingCountry;
				c.Origin = ANG_Risk_Helper.CASE_ORIGIN_INTERNAL_CASE;
				c.CaseArea__c = ANG_Risk_Helper.CASE_AREA_CUSTOMER_SERVICE; 
				c.Reason1__c = ANG_Risk_Helper.CASE_REASON_RHC_75;
				c.Visible_on_ISS_Portal__c = false;

				//make sure that the default assignment rule is used
				c.setOptions(dmlOpts);

				processCases.add(c);
			}
		}

		if(!processCases.isEmpty()) insert processCases;
		if(!mailList.isEmpty()) System.enqueueJob(new ANG_RHCHelper.RiskAlertMailService(mailList, notifiedAlerts));

		if(!notificationTargets.isEmpty()){
			List<Notification__c> notifications = new List<Notification__c>();
			for(Notification__c nt : ISSP_CreateNotification.createnotification(notificationTargets, false)){
				ANG_RHC_Information__c rhc = rhcInfo.get(contactAccounts.get(nt.Contact__c));

				nt.Message__c = nt.Message__c
								.replace('#RHC_CURRENCY#', rhc.CurrencyIsoCode)
								.replace('#RHC_AMOUNT_USED#', (rhc.ANG_ConsumedRHC__c == null ? 0 : rhc.ANG_ConsumedRHC__c).format())
								.replace('#RHC_AMOUNT_TOTAL#', (rhc.ANG_RHC_Amount__c == null ? 0 : rhc.ANG_RHC_Amount__c).format())
								.replace('#RHC_PERCENTAGE#', (rhc.ANG_ConsumedRHC_Percent__c == null ? 0 : rhc.ANG_ConsumedRHC_Percent__c).format());

				notifications.add(nt);
			}
			if(!notifications.isEmpty()) insert notifications;
		}
	}
}