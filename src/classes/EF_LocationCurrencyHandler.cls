public class EF_LocationCurrencyHandler {

	private static boolean run = true;

	public static void handleApprovedAndRejectedApprovals(List<EF_Location_Currency__c> newValues, Map<Id, EF_Location_Currency__c> oldValues)
	{
		List<String> fields = new List<String>{'EF_Billing_Currency__c'};
		List<Contract> approvedList = EF_BaContractApprovalHelper.identifyApprovedRecords(newValues, oldValues);
		List<Contract> rejectedList = EF_BaContractApprovalHelper.identifyRejectedOrRecalledRecords(newValues, oldValues);
		if(approvedList.size() > 0)
		{
			EF_BaContractApprovalHelper.copyValuesFromTempStorageOnrecordApproval(approvedList, fields, 'EF_Location_Currency__c');
		}
		if(rejectedList.size() > 0)
		{
			EF_BaContractApprovalHelper.removeTempStorageRecordOnRecordRejection(rejectedList, 'EF_Location_Currency__c');
		}
	}

	public static void handleWithApprovalUpdates(Map<Id, EF_Location_Currency__c> newMaterials, Map<Id, EF_Location_Currency__c> oldMaterials)
	{
		if(EF_ContractHandler.isUserCsSpecialist())
		{
			List<EF_Approval__c> approvalStorageList = new List<EF_Approval__c>();
			List<String> fields = new List<String>{'EF_Billing_Currency__c'};
			List<String> editFields = new List<String>{'EF_Billing_Currency__c'};
			User currentUser = [select Id, Email, EF_Contract_Approver_Email__c, EF_Billing_Agreement_Approver_Email__c from User where Id = :UserInfo.getUserId()];
			for(EF_Location_Currency__c mat : newMaterials.values())
			{
				if(EF_BaContractApprovalHelper.identifyRecordChanges(mat, oldMaterials.get(mat.Id), fields, false))
				{
					EF_Approval__c approval = EF_BaContractApprovalHelper.fillTemporaryApprovalStorage(new EF_Approval__c(), (sObject) mat, editFields, 'EF_Location_Currency__c');
					mat.Require_Approval__c = true;
					approvalStorageList.add(approval);
					EF_BaContractApprovalHelper.rollbackPreviousValues(mat, oldMaterials.get(mat.Id), editFields);
				}
			}

			if(approvalStorageList.size() > 0)
			{
				insert approvalStorageList;
			}
		}
	}

	// If user is a CS Specialist, make the Contract inactive and require approval
	public static void handleWithApprovalInserts(List<EF_Location_Currency__c> currencyList)
	{
		if(EF_ContractHandler.isUserCsSpecialist())
		{
			List<String> fields = new List<String>{'Location_ID_Name__c', 'EF_Billing_Currency__c'};
			List<String> editFields = new List<String>{'Location_ID__c', 'EF_Billing_Currency__c'};

			for(EF_Location_Currency__c cur : currencyList)
			{
				cur.Require_Approval__c = true;
				EF_BaContractApprovalHelper.identifyRecordChanges(cur, null, fields, true);
			}
		}
	}

	public static void startApprovalProcesses(List<EF_Location_Currency__c> cList)
	{
		for(EF_Location_Currency__c c : cList)
		{
			if(c.Require_Approval__c)
			{
				EF_BaContractApprovalHelper.submitForApproval(c.Id, UserInfo.getUserId(), '');
			}
		}
	}

	public static void manageNewLocationCurrency (List<EF_Location_Currency__c> locationCurrencyList, String action) {
		//First avoid adding the same location in two location currencies

		//get set for Contract
		Set <Id> contractIdSet = new Set <Id>();
		for(EF_Location_Currency__c lc: locationCurrencyList){
			contractIdSet.add(lc.Contract__c);
		}
		//get contract, with the location currencies that are already set on the contract.
		Map<Id, Contract> mapContract = new Map<Id, Contract> ([select Id, EF_Billing_Currency__c, (select Id, Location_ID__c, Location_ID__r.Name, EF_Billing_Currency__c from EF_Locations_Currencies__r) from Contract where Id in: contractIdSet order by id]);

		//Set to hold the location names already added to the contract
		Map <Id, EF_Location_Currency__c> locationContractMap = new Map <Id, EF_Location_Currency__c>();

		for(Contract c: mapContract.values()) {
			if (c.EF_Locations_Currencies__r != null && c.EF_Locations_Currencies__r.size() != 0) {
				for(EF_Location_Currency__c lc: c.EF_Locations_Currencies__r){
					locationContractMap.put(lc.Location_ID__c, lc);
				}
			}
		}

		List <EF_Location_Currency__c> newLocCurr = new List <EF_Location_Currency__c>  ();

		//the contract contains already some location currencies added
		if(!locationContractMap.isEmpty())
		{
			//check if the location we try to add has already been set
			for(EF_Location_Currency__c lc: locationCurrencyList) {
				if(locationContractMap.containsKey(lc.Location_ID__c) ) {
					if(action == 'insert') {
						lc.Location_ID__c.addError('The location chosen has already been added to the contract.');
					}
				} else {
					newLocCurr.add(lc);
					//System.debug(Logginglevel.ERROR, '#### lc.EF_Billing_Currency__c ' + lc.EF_Billing_Currency__c);
					//System.debug(Logginglevel.ERROR, '#### mapContract.get(lc.Contract__c).EF_Billing_Currency__c ' + mapContract.get(lc.Contract__c).EF_Billing_Currency__c);
					if(mapContract.get(lc.Contract__c).EF_Billing_Currency__c!= null && !mapContract.get(lc.Contract__c).EF_Billing_Currency__c.contains(lc.EF_Billing_Currency__c))
					{
						mapContract.get(lc.Contract__c).EF_Billing_Currency__c = mapContract.get(lc.Contract__c).EF_Billing_Currency__c + ';' + lc.EF_Billing_Currency__c;
					}
				}
			}
		} else {// the contract has no location currencies
			for(EF_Location_Currency__c lc: locationCurrencyList)
			{
				Contract c = mapContract.get(lc.Contract__c);
				if(mapContract.get(lc.Contract__c) != null)
				{
					if(mapContract.get(lc.Contract__c).EF_Billing_Currency__c == null)
					{
						mapContract.get(lc.Contract__c).EF_Billing_Currency__c = lc.EF_Billing_Currency__c;
					} else
					{
						if(!mapContract.get(lc.Contract__c).EF_Billing_Currency__c.contains(lc.EF_Billing_Currency__c))
							mapContract.get(lc.Contract__c).EF_Billing_Currency__c = mapContract.get(lc.Contract__c).EF_Billing_Currency__c+';'+lc.EF_Billing_Currency__c;
					}
				}
				newLocCurr.add(lc);
			}
		}

		try{
			update mapContract.values();
			if(!newLocCurr.isEmpty()){
				notifyOnCreation(newLocCurr);
			}
		}catch(Exception e){
			System.debug('#### exception updating contracts ' + e);
		}
	}

	public static void manageUpdateLocationCurrency () {

		List<EF_Location_Currency__c> locationCurrencyListNew = (List<EF_Location_Currency__c>) Trigger.new;
		Map<Id, EF_Location_Currency__c> locationCurrencyMapOld = (Map<Id, EF_Location_Currency__c>) Trigger.oldMap;
		List <EF_Location_Currency__c> locs2Notify = new List <EF_Location_Currency__c> ();

		Set <Id> contractIdSet = new Set <Id>();
		for(EF_Location_Currency__c lc: locationCurrencyListNew){
			contractIdSet.add(lc.Contract__c);
		}

		Map<Id, Contract> mapContract = new Map<Id, Contract> ([select Id, EF_Billing_Currency__c, (select Id, Location_ID__c, Location_ID__r.Name, Location_ID_Name__c,  EF_Billing_Currency__c from EF_Locations_Currencies__r) from Contract where Id in: contractIdSet order by id]);

		Map <Id, EF_Location_Currency__c> locationContractMap = new Map <Id, EF_Location_Currency__c>();
		for(Contract c: mapContract.values()){
			for(EF_Location_Currency__c lc: c.EF_Locations_Currencies__r){
				locationContractMap.put(lc.Location_ID__c, lc);
			}
		}

		if(!locationContractMap.isEmpty()){
			for(EF_Location_Currency__c lc: locationCurrencyListNew) {

				locs2Notify.add(lc);
				// Only add new currencies.
				if(mapContract.get(lc.Contract__c).EF_Billing_Currency__c!=null){
				if(!mapContract.get(lc.Contract__c).EF_Billing_Currency__c.contains(lc.EF_Billing_Currency__c)) {
					String aux = mapContract.get(lc.Contract__c).EF_Billing_Currency__c.remove(locationCurrencyMapOld.get(lc.id).EF_Billing_Currency__c);
					mapContract.get(lc.Contract__c).EF_Billing_Currency__c = aux + ';' + lc.EF_Billing_Currency__c;
				} else {
					// The list can't have the same currency twice.
					String aux = mapContract.get(lc.Contract__c).EF_Billing_Currency__c.remove(locationCurrencyMapOld.get(lc.id).EF_Billing_Currency__c);
					mapContract.get(lc.Contract__c).EF_Billing_Currency__c = aux;
				}
				}else{
					mapContract.get(lc.Contract__c).EF_Billing_Currency__c = lc.EF_Billing_Currency__c;
				}

			}
		}

		//Add the currencies that haven't been modified but were deleted by previous block.

		List<EF_Location_Currency__c> locationCurrencyList = [Select id, EF_Billing_Currency__c, Contract__c, Location_ID_Name__c From EF_Location_Currency__c where Contract__c in :contractIdSet];

		for(EF_Location_Currency__c lc: locationCurrencyList) {

			if(!mapContract.get(lc.Contract__c).EF_Billing_Currency__c.contains(lc.EF_Billing_Currency__c) && !locationCurrencyMapOld.containsKey(lc.id)) {
				mapContract.get(lc.Contract__c).EF_Billing_Currency__c = mapContract.get(lc.Contract__c).EF_Billing_Currency__c + ';' + lc.EF_Billing_Currency__c;
			}
		}

		try{
			update mapContract.values();
			if(!locs2Notify.isEmpty()){
				notifyOnUpdate(locs2Notify, locationCurrencyMapOld);
			}

		}catch(Exception e){
			System.debug('#### exception updating contracts ' + e);
		}
	}


	 /*
	 *  on DELETION of whole Location Currency record => don't allow if the same location ID exists on BA
		on UPDATE of Billing Currency on Location Currency record => don't allow if the same location ID exists on BA
	*/
	public static void validateLocationCurrencyRemoval(Map<Id, EF_Location_Currency__c> newLines, Map<Id, EF_Location_Currency__c> locationOldMap)
	{
		boolean isDeletion = false;
		if(newLines == null)
			isDeletion = true;

		List<EF_Location_Currency__c> locCurrDeleted = new List<EF_Location_Currency__c>();

		Map<Id, String> contractWithCurrToBeRemoved = new Map<Id, String>();
		Set<Id> contractIdSet = new Set<Id>();

		if(locationOldMap != null)
		{
			Set<Id> contractIds = new Set<Id>();
			for(EF_Location_Currency__c locationCurrencyId : locationOldMap.values())
			{
				contractIds.add(locationCurrencyId.Contract__c);
			}

			List<EF_Billing_Agreement__c> baList = [select id, name, Billing_Currency__c, EF_Location_ID__c, Contract__c from EF_Billing_Agreement__c where EF_Status__c = 'Active' and Contract__c in :contractIds];

			Set<Id> locationIds = new Set<Id>();

			Map<Id, Set<Id>> contractLocationIdsMap = new Map<Id, Set<Id>>();
			//Map<Id, List<Id>> errorLocationIdListingMap = new Map<Id, List<Id>>();

			for(EF_Billing_Agreement__c ba : baList)
			{
				if(contractLocationIdsMap.containsKey(ba.Contract__c))
				{
					if(ba.EF_Location_ID__c != null)
					{
						contractLocationIdsMap.get(ba.Contract__c).add(ba.EF_Location_ID__c);
					}
				}
				else
				{
					if(ba.EF_Location_ID__c != null)
					{
						locationIds.add(ba.EF_Location_ID__c);
						contractLocationIdsMap.put(ba.Contract__c, locationIds);
					}
				}
			}

			if(isDeletion)
			{
				for(EF_Location_Currency__c loc : locationOldMap.values())
				{
					if(locationIds.contains(loc.Location_ID__c) && loc.Skip_Validation__c != true)
					{
						throw new EF_BaContractApprovalHelper.ApprovalException('Can not delete the Location Currency, because it is being used on one or more Billing Agreement records.');
					}
					else
					{
						locCurrDeleted.add(loc);
						contractWithCurrToBeRemoved.put(loc.Contract__c, loc.EF_Billing_Currency__c);
					}
				}
			}
			else
			{
				Map <String, Schema.SObjectField> locationCurrencyFields = schema.SObjectType.EF_Location_Currency__c.fields.getMap();
				for(EF_Location_Currency__c loc : newLines.values())
				{
					// if only changing the Skip Validation value from true to false, we can skip this part of the code
					if(EF_Utilities.findIfKeyFieldsChanged((sObject) loc, (sObject) locationOldMap.get(loc.Id), locationCurrencyFields, new List<String>{'Skip_Validation__c'}))
					{

						if(locationIds.contains(loc.Location_ID__c) && !loc.Skip_Validation__c)
						{
							throw new EF_BaContractApprovalHelper.ApprovalException('Can not update the Location Currency, because the current value '+locationOldMap.get(loc.Id).EF_Billing_Currency__c+' is being used on one or more Billing Agreement records.');
						}
						else
						{
							if(loc.Skip_Validation__c)
								contractIdSet.add(loc.Contract__c);

							contractWithCurrToBeRemoved.put(loc.Contract__c, loc.EF_Billing_Currency__c);
						}
					}
				}
			}

			if(!contractWithCurrToBeRemoved.isEmpty())
			{
				updateContractBillingCurrency(contractWithCurrToBeRemoved, locationOldMap.keySet());
			}

			if(!contractIdSet.isEmpty())
			{
				updateBaCurrenciesOnSkipValidation(contractIdSet, newLines);
			}

			if(!locCurrDeleted.isEmpty()){
				notifyOnDelete(locCurrDeleted);
			}
		}
	}

	public static void updateBaCurrenciesOnSkipValidation(Set<Id> contractIdSet, Map<Id, EF_Location_Currency__c> currencyIdMap)
	{
		Map<Id, EF_Location_Currency__c> currencyMap = new Map<Id, EF_Location_Currency__c>();
		for(EF_Location_Currency__c location : currencyIdMap.values())
		{
			currencyMap.put(location.Location_ID__c, location);
		}

		Set<Id> locationIdSet = new Set<Id>();
		for(EF_Location_Currency__c cur : currencyMap.values())
		{
			locationIdSet.add(cur.Location_ID__c);
		}

		List<EF_Billing_Agreement__c> baList = [select Skip_Approval__c, Contract__c, Billing_Currency__c, EF_Location_ID__c from EF_Billing_Agreement__c where Contract__c in :contractIdSet and EF_Location_ID__c in :locationIdSet];
		if(baList.size() > 0)
		{
			for(EF_Billing_Agreement__c ba : baList)
			{
				ba.Billing_Currency__c = currencyMap.get(ba.EF_Location_ID__c).EF_Billing_Currency__c;
				ba.Skip_Approval__c = true;
				ba.Require_Approval__c = false;
				ba.Requested_Changes__c = '';
			}
			update baList;

			for(EF_Billing_Agreement__c ba : baList)
			{
				ba.Skip_Approval__c = false;
				ba.Requested_Changes__c = '';
				ba.Require_Approval__c = false;
			}
		}
	}

	public static void updateContractBillingCurrency (Map <Id, String> contractWithCurrToBeRemoved, Set <Id> locationIdSet){

		//get contract, with the location currencies that are already set on the contract.
		Map<Id, Contract> mapContract = new Map<Id, Contract> ([select Id, EF_Billing_Currency__c,
																(select Id, Location_ID__c, Location_ID__r.Name, EF_Billing_Currency__c from EF_Locations_Currencies__r),
																(select Id, EF_Location_ID__c, EF_Location_ID__r.Name, Contract__c from EF_Relationships__r where EF_Location_ID__c in: locationIdSet)
															  from Contract where Id in: contractWithCurrToBeRemoved.keySet()]);


			if(contractWithCurrToBeRemoved != null)
			{
				for(Contract c: mapContract.values()) {
					String billCurr = c.EF_Billing_Currency__c;

					String resultingBillCur = '';

					if(contractWithCurrToBeRemoved.containsKey(c.Id) && billCurr != null) {
						resultingBillCur = billCurr.remove(contractWithCurrToBeRemoved.get(c.Id));
						c.EF_Billing_Currency__c = resultingBillCur;
						c.EF_Comments__c ='System. Update of Billing Currency';
				   }
				}
			}

		try{
			update mapContract.values();
		}catch(Exception e){
			System.debug('#### exception updating contracts ' + e);
		}


	}

	private static void notifyOnCreation (List <EF_Location_Currency__c> locList) {

		String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
		User u = [select EF_Contract_Approver_Email__c, EF_Billing_Agreement_Approver_Email__c, FirstName, LastName from User where Id = :UserInfo.getUserId()];
		String emailBody = 'Dear team member, <br/><br/>the following Location Currencies have been CREATED by '+u.FirstName+' '+u.LastName+':<br/><br/>';
		emailBody = emailBody + '<table width="600px" border="1"><tr border="1"><th border="1">Location Currency</th><th border="1">Billing Currency:</th></tr>';
		String htmlRow  = '';

		for(EF_Location_Currency__c lc: locList){
			emailBody = emailBody + '<tr><td border="1"><a href="'+baseUrl+'/'+lc.Contract__c+'">'+lc.location_ID_Name__c+'</a></td><td border="1">'+lc.EF_Billing_Currency__c+'</td></tr>';
		}

		emailBody = emailBody + '</table>';

		// send an email to Contract approver if there were changes to Contracts' Location Currencies
		if(u.EF_Contract_Approver_Email__c != null && !u.EF_Contract_Approver_Email__c.endsWithIgnoreCase('.inactive'))
			Utility.sendEmail(new List<String>{u.EF_Contract_Approver_Email__c}, 'E&F CRM: Creation of Location Currency ', emailBody, true, null);


	}
	private static void notifyOnDelete (List <EF_Location_Currency__c> oldLocList) {

		String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
		User u = [select EF_Contract_Approver_Email__c, EF_Billing_Agreement_Approver_Email__c, FirstName, LastName from User where Id = :UserInfo.getUserId()];
		String emailBody = 'Dear team member, <br/><br/>the following Location Currencies have been DELETED by '+u.FirstName+' '+u.LastName+':<br/><br/>';
		emailBody = emailBody + '<table width="600px" border="1"><tr border="1"><th border="1">Location Currency</th><th border="1">Billing Currency:</th></tr>';
		String htmlRow  = '';

		for(EF_Location_Currency__c lc: oldLocList){
			emailBody = emailBody + '<tr><td border="1"><a href="'+baseUrl+'/'+lc.Contract__c+'">'+lc.location_ID_Name__c+'</a></td><td border="1">'+lc.EF_Billing_Currency__c+'</td></tr>';
		}

		emailBody = emailBody + '</table>';

		// send an email to Contract approver if there were changes to Contracts' Location Currencies
		if(u.EF_Contract_Approver_Email__c != null && !u.EF_Contract_Approver_Email__c.endsWithIgnoreCase('.inactive'))
			Utility.sendEmail(new List<String>{u.EF_Contract_Approver_Email__c}, 'E&F CRM: Deletion of Location Currency ', emailBody, true, null);


	}

	private static void notifyOnUpdate (List <EF_Location_Currency__c> newValocList, Map <Id,EF_Location_Currency__c> oldValLocMap) {

		String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();

		User u = [select EF_Contract_Approver_Email__c, EF_Billing_Agreement_Approver_Email__c, FirstName, LastName from User where Id = :UserInfo.getUserId()];

		String emailBody = 'Dear team member, <br/><br/>the following Location Currencies have been UPDATED by '+u.FirstName+' '+u.LastName+':<br/><br/>';
		emailBody = emailBody + '<table width="600px" border="1"><tr border="1"><th border="1">Location Currency</th><th border="1">New Billing Currency:</th><th border="1">Old Billing Currency:</th></tr>';

		for(EF_Location_Currency__c lc: newValocList){

			 emailBody = emailBody + '<tr><td border="1"><a href="'+baseUrl+'/'+lc.Id+'">'+lc.location_ID_Name__c+'</a></td><td border="1">'+lc.EF_Billing_Currency__c+'</td><td border="1">'+oldValLocMap.get(lc.Id).EF_Billing_Currency__c+'</td></tr>';
		}

		emailBody = emailBody + '</table>';
		if(u.EF_Contract_Approver_Email__c != null && !u.EF_Contract_Approver_Email__c.endsWithIgnoreCase('.inactive'))
			Utility.sendEmail(new List<String>{u.EF_Contract_Approver_Email__c}, 'E&F CRM: Changes to Location Currency ', emailBody, true, null);

	}

	public static boolean runOnce()
	{
		if(run)
		{
			run = false;
			return true;
		}
		else
		{
			return run;
		}
	}
}
