trigger ISSP_Portal_Application_Right on Portal_Application_Right__c (after insert, after update, before delete, after delete) {

	if (PortalServiceAccessTriggerHandler.avoidAppTrigger) return;

	//we skip this trigger if IFAP portal service so we avoid too many SOQL queries
	if (!trigger.isDelete) {
		for (Portal_Application_Right__c access : trigger.new) {
			if (access.Application_Name__c == 'IFAP' )
				return;
		}
	}

	//TF - give permission set automatically for SIS
	system.debug('STARTING TRIGGER');
	Set <Id> contactIdSet = new Set <Id>();
	Set <Id> contactRemoveIdSet = new Set <Id>();
	//Mconde - IFG
	Set <Id> contactSCIMIdSet = new Set <Id>();
	Set <Id> contactSCIMRemoveIdSet = new Set <Id>();
	List<SCIMServProvManager.SCIMProvisioningRow> scimElements = new List<SCIMServProvManager.SCIMProvisioningRow>();

	//Mconde End

	Set <Id> contactRemove2FAIdSet = new Set <Id>();
	Set <Id> contactFedIdSet = new Set <Id>();
	Map <Id, String> contactFedIdMap = new Map <Id, String>();
	Set <Id> contactBaggageAdd = new Set <Id>();
	Set <Id> contactKaviAdd = new Set <Id>();
	Set <Id> removeKaviPermissionSet = new Set <Id>();
	Set <Id> contactBaggageRemove = new Set <Id>();
	Set <Id> manageAccessTDidSet = new Set <Id>();
	Set <Id> ContactDelRightSet = new Set <Id>();
	Set <Id> contactIdIATAAccreditationSet = new Set <Id>();
	Set <Id> contactIdRemoveIATAAccreditationSet = new Set <Id>();

	List<Portal_Application_Right__c> ebulletinServices = new List<Portal_Application_Right__c>();

	//Mconde start
	if ( (trigger.isInsert) || (trigger.isUpdate) ) {
		SCIMServProvManager.initIATAServAccessMapOfApps(trigger.new);
		if (SCIMServProvManager.portalAppsAccessSet.size() > 0 && (!System.isFuture() && !System.isBatch())) {
			SCIMServProvManager.reviewIFGUserStatusAndContactSharing(SCIMServProvManager.portalAppsAccessSet);
		}
	}
	//Mconde end

	system.debug('bastos1p - trigger input records:' + trigger.new);

	//ANG project
	ANG_PortalApplicationRightHandler handler = new ANG_PortalApplicationRightHandler();
	if (Trigger.isAfter && Trigger.isInsert) handler.onAfterInsert();
	if (Trigger.isAfter && Trigger.isUpdate) handler.onAfterUpdate();
	if (Trigger.isBefore && Trigger.isDelete) handler.onBeforeDelete();
	if (Trigger.isAfter && Trigger.isDelete) handler.onAfterDelete();
	//end of ANG

	if(Trigger.isDelete) {
	
		Set<Id> disableContactIdSet = new Set<Id>();

		for(Portal_Application_Right__c access : trigger.old){
		
			if(Trigger.isAfter && access.Application_Name__c == 'Standards Setting Workspace'){
				disableContactIdSet.add(access.Contact__c);
			}

		}
		
		if(!disableContactIdSet.isEmpty()){
			HigherLogicIntegrationHelper.pushPersonCompanyMembers(HigherLogicIntegrationHelper.DISABLE_EXISTING_MEMBERS, disableContactIdSet, null);
            HigherLogicIntegrationHelper.assignHLPermissionSet(disableContactIdSet, HigherLogicIntegrationHelper.REMOVE_ACCESS);
		}
		
		return;
		
	}
	//methods below this line should not run for delete cases

	for (Portal_Application_Right__c access : trigger.new) {
		system.debug('ONE RECORD');
		system.debug('APP NAME: ' + access.Application_Name__c);
		if (access.Application_Name__c == 'SIS') {
			if (trigger.isInsert && access.Right__c == 'Access Granted') {
				system.debug('IS INSERT AND GRANTED');
				contactIdSet.add(access.Contact__c);
			}
			else if (trigger.isUpdate){
				Portal_Application_Right__c oldAccess = trigger.oldMap.get(access.Id);
				if (access.Right__c != oldAccess.Right__c) {
					if (access.Right__c == 'Access Granted') {
						system.debug('IS UPDATE AND GRANTED');
						contactIdSet.add(access.Contact__c);
					}
					else if (access.Right__c == 'Access Denied'){
						system.debug('IS UPDATE AND DENIED');
						contactRemoveIdSet.add(access.Contact__c);
					}
				}
			}
		}
		//MConde -IFG ACCESS APPROVAL HANDLE - ADD/Remove Permission SET
		else if (SCIMServProvManager.isSCIMUserServiceProv(access)) {

			if (trigger.isInsert && access.Right__c == SCIMServProvManager.IATA_STS_ACCESS_GRANTED) {
				system.debug('mconde IS INSERT AND GRANTED');
				system.debug('mconde - Add permission SET SCIM to Grant list - APP Trigger insert');
				//contactSCIMIdSet.add(access.Contact__c);
				SCIMServProvManager.SCIMProvisioningRow aScimRow =
				    new SCIMServProvManager.SCIMProvisioningRow(access.Contact__c,
				            SCIMServProvManager.getSCIMAppNameFromId(access.Portal_Application__c),
				            access.id,
				            LightningConnectedAppHelper.OID_USER_APP_ACTION_ADD);
				scimElements.add(aScimRow);
            }
            else if (trigger.isUpdate){
				system.debug('basto1p - Add or remove permission SET IFG APP Trigger Update');
				Portal_Application_Right__c oldAccess = trigger.oldMap.get(access.Id);
				if (access.Right__c != oldAccess.Right__c) {
					if (access.Right__c == SCIMServProvManager.IATA_STS_ACCESS_GRANTED) {
						system.debug('basto1p - Add permission SET IFG to GRant list - APP Trigger Update');
						//contactSCIMIdSet.add(access.Contact__c);
						SCIMServProvManager.SCIMProvisioningRow aScimRow =
						    new SCIMServProvManager.SCIMProvisioningRow(access.Contact__c,
						            SCIMServProvManager.getSCIMAppNameFromId(access.Portal_Application__c),
						            access.id,
						            LightningConnectedAppHelper.OID_USER_APP_ACTION_ADD);
						scimElements.add(aScimRow);
                    }
                    else if (access.Right__c == SCIMServProvManager.IATA_STS_ACCESS_DENIED){
						system.debug('basto1p - Remove permission SET IFG add to Deny list -   APP Trigger Update');
						//contactSCIMRemoveIdSet.add(access.Contact__c);
						SCIMServProvManager.SCIMProvisioningRow aScimRow =
						    new SCIMServProvManager.SCIMProvisioningRow(access.Contact__c,
						            SCIMServProvManager.getSCIMAppNameFromId(access.Portal_Application__c),
						            access.id,
						            LightningConnectedAppHelper.OID_USER_APP_ACTION_REMOVE);
						scimElements.add(aScimRow);

					}
				}
			}
		}
		else if (access.Application_Name__c.startsWith('Treasury Dashboard')){
			String tdAppName = '';
			if (access.Application_Name__c == 'Treasury Dashboard') {
				tdAppName = 'ISSP_Treasury_Dashboard_Basic';
			}
			else{
				tdAppName = 'ISSP_Treasury_Dashboard_Premium';
			}
			if (trigger.isInsert && access.Right__c == 'Access Granted') {
				system.debug('Adding id from insert');
				contactFedIdMap.put(access.Contact__c, tdAppName);
				contactFedIdSet.add(access.Contact__c);
				manageAccessTDidSet.add(access.Id);
			}
			else if (trigger.isUpdate){
				Portal_Application_Right__c oldAccess = trigger.oldMap.get(access.Id);
				if (access.Right__c != oldAccess.Right__c) {
					if (access.Right__c == 'Access Denied') {
						contactRemove2FAIdSet.add(access.Contact__c);
					}
					else if (access.Right__c == 'Access Granted'){
						system.debug('Adding id from update');
						contactFedIdMap.put(access.Contact__c, tdAppName);
						contactFedIdSet.add(access.Contact__c);
						manageAccessTDidSet.add(access.Id);
					}
				}
			} else if (Trigger.isDelete) {
				contactRemove2FAIdSet.add(trigger.oldMap.get(access.Id).Contact__c);
			}
		}
		else if (access.Application_Name__c == 'Baggage Proration'){
			if (trigger.isInsert && access.Right__c == 'Access Granted') {
				contactBaggageAdd.add(access.Contact__c);
			}
			else if (trigger.isUpdate){
				Portal_Application_Right__c oldAccess = trigger.oldMap.get(access.Id);
				if (access.Right__c != oldAccess.Right__c) {
					if (access.Right__c == 'Access Granted') {
						contactBaggageAdd.add(access.Contact__c);
					}
					else if (access.Right__c == 'Access Denied'){
						contactBaggageRemove.add(access.Contact__c);
					}
				}
			}
		}
		else if (access.Application_Name__c == 'Standards Setting Workspace'){
			if (trigger.isInsert && access.Right__c == 'Access Granted') {
				contactKaviAdd.add(access.Contact__c);
			} 
			else if (trigger.isUpdate){
				Portal_Application_Right__c oldAccess = trigger.oldMap.get(access.Id);
				if (access.Right__c != oldAccess.Right__c) {
					if (access.Right__c == 'Access Granted') {
						contactKaviAdd.add(access.Contact__c);
					}else if (access.Right__c == 'Access Denied'){
						//Should update user status in Higherlogic status to inactive (below9)
						removeKaviPermissionSet.add(access.Contact__c);
					}
				}
			}
		}
		else if (access.Application_Name__c.startsWith('IATA Accreditation')){

			if (trigger.isInsert && access.Right__c == 'Access Granted') {
				system.debug('IS INSERT AND GRANTED');
				contactIdIATAAccreditationSet.add(access.Contact__c);
			}
			else if (trigger.isUpdate){
				Portal_Application_Right__c oldAccess = trigger.oldMap.get(access.Id);
				if (access.Right__c != oldAccess.Right__c) {
					if (access.Right__c == 'Access Granted') {
						system.debug('IS UPDATE AND GRANTED');
						contactIdIATAAccreditationSet.add(access.Contact__c);
					}
					else if (access.Right__c == 'Access Denied'){
						system.debug('IS UPDATE AND DENIED');
						contactIdRemoveIATAAccreditationSet.add(access.Contact__c);
					}
				}
			}
		}
		else if (access.Application_Name__c.contains('Bulletin')){

			if (trigger.isUpdate) {
				Portal_Application_Right__c oldAccess = trigger.oldMap.get(access.Id);
				if (access.Right__c != oldAccess.Right__c) {
					if (access.Right__c == 'Access Denied') {
						system.debug('IS UPDATE AND DENIED');
						//disable the ebulletin profiles for the user
						ebulletinServices.add(access);
					}
				}
			}
		}
		/*
		else if (access.Application_Name__c == 'ASD'){
			system.debug('IS ASD');
			if (trigger.isUpdate){
				system.debug('IS UPDATE');
				Portal_Application_Right__c oldAccess = trigger.oldMap.get(access.Id);
				system.debug('CURRENT: ' + access.Right__c);
				system.debug('OLD: ' + oldAccess.Right__c);
				if (access.Right__c != oldAccess.Right__c){
					system.debug('DIFFERENT RIGHT');
					if (access.Right__c == 'Access Denied'){
						system.debug('IS REJECTED');
						String contactId = String.valueOf(access.Contact__c);
						contactId = contactId.substring(0,15);
						system.debug('To call webservice: ' + contactId);
						ISSP_WS_Utilities.invokeAsdDisableUser(contactId);
					}
				}
			}
		}
		*/
	}


	//disable the ebulletin profiles for the user
	if (!ebulletinServices.isEmpty()) {

		Set<Id> contactsId = new Set<Id>();
		List<User> usersWithAccess = new List<User>();
		List<AMS_eBulletin_Profile__c> bProfiles = new List<AMS_eBulletin_Profile__c>();
		List<AMS_eBulletin_Profile__c> bProfilesToUpdate = new List<AMS_eBulletin_Profile__c>();

		for (Portal_Application_Right__c service : ebulletinServices) {
			contactsId.add(service.Contact__c);
		}

		if (!contactsId.isEmpty()) {

			usersWithAccess = [SELECT id FROM User WHERE contactid IN :contactsId];

			if (!usersWithAccess.isEmpty()) {

				bProfiles = [SELECT id, Opt_in__c, Opt_out_Bulletin__c FROM AMS_eBulletin_Profile__c WHERE User__c IN :usersWithAccess AND Opt_in__c = true AND Opt_out_Bulletin__c = false];

				if (!bProfiles.isEmpty()) {

					for (AMS_eBulletin_Profile__c ebProf : bProfiles) {
						ebProf.Opt_in__c = false;
						ebProf.Opt_out_Bulletin__c = true;
						bProfilesToUpdate.add(ebProf);
					}

					if (!bProfilesToUpdate.isEmpty()) {
						System.debug('ISSP_Portal_Application_Right - trigger - eBulletin Profiles to Update: ' + bProfilesToUpdate);
						update bProfilesToUpdate;
					}

				}

			}

		}
	}

	if (!contactIdSet.isEmpty() || !contactRemoveIdSet.isEmpty()) {
		system.debug('WILL START FUTURE METHOD');
		if (!ISSP_UserTriggerHandler.preventSISIntegration) {
			//call external WS to update SIS user
			ISSP_UserTriggerHandler.calloutSIS_ActivateDeactivateUsers(contactIdSet, contactRemoveIdSet);
		}
		ISSP_UserTriggerHandler.preventSISIntegration = true;
		if (!ISSP_UserTriggerHandler.preventTrigger) {
			ISSP_UserTriggerHandler.updateSIS_permissionSet(contactIdSet, contactRemoveIdSet);
		}
		ISSP_UserTriggerHandler.preventTrigger = true;
	}

	//deleteTwoFactor
	if (!contactRemove2FAIdSet.isEmpty()) {
		ISSP_UserTriggerHandler.deleteTwoFactor(contactRemove2FAIdSet);
	}

	//update Federation
	if (!contactFedIdMap.isEmpty()) {
		ISSP_UserTriggerHandler.updateFederation(contactFedIdMap);
	}

	//Add NonTD Report Permission
	if (!contactFedIdSet.isEmpty()) {
		ISSP_UserTriggerHandler.addNonTdReportSharing(contactFedIdSet);
	}

	//Remove  NonTD Report Permission
	if (!contactRemove2FAIdSet.isEmpty()) {
		ISSP_UserTriggerHandler.removeNonTdReportSharing(contactRemove2FAIdSet);
	}
	
	Id provAcctId = ProvisionKaviAccess.getFakeAccount().Id;

	if (!contactKaviAdd.isEmpty()){
		
		String action = HigherLogicIntegrationHelper.PUSH_MEMBERS;
		
		string kaviUser = [SELECT Kavi_User__c from Contact where Id in:contactKaviAdd limit 1].Kavi_User__c;
		
		if (kaviUser != null ){
			action = HigherLogicIntegrationHelper.PUSH_INTERNAL_MEMBERS;
		}

		HigherLogicIntegrationHelper.pushPersonCompanyMembers(action, contactKaviAdd, provAcctId);

		//RN-ENHC0012059 grant and remove the permission set to the user	
		HigherLogicIntegrationHelper.assignHLPermissionSet(contactKaviAdd, HigherLogicIntegrationHelper.GRANT_ACCESS); 
		
	}
	
	//RN-ENHC0012059 grant and remove the permission set to the user
	if(!removeKaviPermissionSet.isEmpty()){
		HigherLogicIntegrationHelper.pushPersonCompanyMembers(HigherLogicIntegrationHelper.PUSH_EXISTING_MEMBERS, removeKaviPermissionSet, provAcctId);
		HigherLogicIntegrationHelper.assignHLPermissionSet(removeKaviPermissionSet, HigherLogicIntegrationHelper.REMOVE_ACCESS);
	}

	/*
	if (!contactBaggageAdd.isEmpty()){
		system.debug('calling addBaggageSharing');
		ISSP_UserTriggerHandler.addBaggageSharing(contactBaggageAdd);
		ISSP_UserTriggerHandler.giveBaggagePermissionSet(contactBaggageAdd);
	}
	if (!contactBaggageRemove.isEmpty()){
		system.debug('calling removeBaggageSharing');
		ISSP_UserTriggerHandler.removeBaggageSharing(contactBaggageRemove);
		ISSP_UserTriggerHandler.removeBaggagePermissionSet(contactBaggageRemove);
	}
	*/

	if (!manageAccessTDidSet.isEmpty()) {
		system.debug('To manageAccessTD');
		PortalServiceAccessTriggerHandler.manageAccessTD(manageAccessTDidSet, contactFedIdSet);
	}

	if (!contactIdIATAAccreditationSet.isEmpty() || !contactIdRemoveIATAAccreditationSet.isEmpty()) {
		system.debug('WILL START FUTURE METHOD');

		// Validate: Give permission set only to Accounts with record type == 'Standard Account'
		List<Contact> lsContact = [SELECT Id FROM Contact where Account.recordtype.name = 'Standard Account' and id in :contactIdIATAAccreditationSet];
		contactIdIATAAccreditationSet = (new Map<Id, SObject>(lsContact)).keySet(); //Replace current set with the filtered results from the query

		if (!ISSP_UserTriggerHandler.preventTrigger)
			ISSP_UserTriggerHandler.updateUserPermissionSet('ISSP_New_Agency_permission_set', contactIdIATAAccreditationSet, contactIdRemoveIATAAccreditationSet);
		ISSP_UserTriggerHandler.preventTrigger = true;
	}

	system.debug('basto1p - Before IFG handle - ISSP_UserTriggerHandler.preventTrigger=' + ISSP_UserTriggerHandler.preventTrigger);
	//basto1p -IFG ACCESS APPROVAL HANDLE - ADD/REmove Permission SET
	if (!scimElements.isEmpty()) {
		system.debug('SCIM ELEMENTS =' + scimElements);
        if (!ISSP_UserTriggerHandler.preventTrigger)
        {
			SCIMServProvManager worker = new SCIMServProvManager(scimElements);

			//Fill federation Ids if they are empty
			//since they are mandatory for user SCIM provisioning
			worker.populateFederationIds();

			//Handle users provisioning
			worker.sendToSCIMProvisioning();
			ISSP_UserTriggerHandler.preventTrigger = true;
			system.debug('Call SCIM Manager');
		}
	}

	if (!trigger.isDelete) {
		if (Trigger.new.size() > 1)
			return;

		Portal_Application_Right__c par = Trigger.new.get(0);
		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Portal_Application_Right__c', 'Biller_Direct');

		if (par.Invoice_Type__c != null && par.Invoice_Type__c != '' && par.Right__c == 'Access Granted' && par.RecordTypeId == rtId) {
			User user = [select Id, SAP_Account_Access_1__c, SAP_Account_Access_2__c, SAP_Account_Access_3__c, SAP_Account_Access_4__c from user where ContactId = :par.Contact__c];
			par = [select Id, Invoice_Type__c, Contact__c,
			       Contact__r.AccountId,   Contact__r.Account.Top_Parent__c
			       from Portal_Application_Right__c
			       where Id = : par.Id
			                  limit 1];


			map<string, string> invoiceTypeSapAccoutId = new map<string, string>();
			string topParentId = par.Contact__r.Account.Top_Parent__c != null ?
			                     par.Contact__r.Account.Top_Parent__c :
			                     par.Contact__r.AccountId;

			list<string> invoiceTypeSet = par.Invoice_Type__c.split(';');
			map<string, string> invoiceTypeMap = new map<string, string>();

			list<SAP_Account__c> SAPAccountList = [select Id, SAP_Account_type__c, SAP_ID__c from
			                                       SAP_Account__c where
			                                       SAP_Account_type__c in:invoiceTypeSet
			                                       and Account__c = :topParentId];

			for (SAP_Account__c sapAcc : SAPAccountList) {
				if (invoiceTypeMap.get(sapAcc.SAP_Account_type__c) == null)
					invoiceTypeMap.put(sapAcc.SAP_Account_type__c, sapAcc.SAP_ID__c);
				else
					Trigger.new.get(0).Invoice_Type__c.addError(Label.ISSP_invoiceType_error.replace('{!invoiceType}', sapAcc.SAP_Account_type__c));
			}

			list<string> invoiceTypeList = par.Invoice_Type__c.split(';');

			for (integer i = 0; i < invoiceTypeList.size(); i++) {
				string invoiceType = invoiceTypeList.get(i);
				string SAPAccountId = invoiceTypeMap.get(invoiceType);
				if (SAPAccountId == null)
					Trigger.new.get(0).Invoice_Type__c.addError(Label.ISSP_invoiceType_is_not_available.replace('{!invoiceType}', invoiceType));
				else
					user.put('SAP_Account_Access_' + string.valueOf(i + 1) + '__c', SAPAccountId);

			}

			update user;
		}
	}
}
