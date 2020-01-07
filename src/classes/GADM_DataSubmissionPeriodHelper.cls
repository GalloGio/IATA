public without sharing class GADM_DataSubmissionPeriodHelper {
	private static Map<Id, SubmissionPeriodCurrentData> getAllPeriodsWithCurrentData(Date testDate){
		List<GADM_Data_Submission_Period__c> periods = [SELECT Id, Upcoming_Notification__c, In_Due_Notification__c, Months_Count__c,Name,Period_Length__c,Start_Date__c,Submission_Cycle_End_Day__c,Submission_Cycle_End_Month__c,Submission_Cycle_Start_Day__c,Submission_Cycle_Start_Month__c FROM GADM_Data_Submission_Period__c];
		Map<Id, SubmissionPeriodCurrentData> periodsCurrentData = new Map<Id, SubmissionPeriodCurrentData>();
		for(GADM_Data_Submission_Period__c period: periods){
			periodsCurrentData.put(period.Id, new SubmissionPeriodCurrentData(period, testDate));
		}

		return periodsCurrentData;
	}

	public static boolean isSubmissionOnTime(Id periodId, Date testDate, string ExternalActorId){
		if(periodId != null){

			Map<Id, SubmissionPeriodCurrentData> periods = getAllPeriodsWithCurrentData(testDate);
			SubmissionPeriodCurrentData	currentData = periods.get(periodId);

			List<GADM_Account_Service_Detail__c> gadmActorDetail = [SELECT Id, Submission_Period_Extension__c FROM GADM_Account_Service_Detail__c WHERE External_Actor_Id__c =: ExternalActorId];

			Date prolongedSubmissionCycleEnd = currentData.CurrentSubmissionCycleEnd;
			if(gadmActorDetail != null && gadmActorDetail.size() > 0){
				prolongedSubmissionCycleEnd = prolongedSubmissionCycleEnd.addDays((integer)(gadmActorDetail[0].Submission_Period_Extension__c == null ? 0 : gadmActorDetail[0].Submission_Period_Extension__c));
			}

			return currentData.CurrentSubmissionCycleStart <=  testDate && prolongedSubmissionCycleEnd >= testDate;
		}
		return false;
	}

	private static Map<Id, List<Data_Submission__c>> getDataSubmissions(Map<Id, List<Id>> inDuePeriodsWithAccounts, Map<Id, SubmissionPeriodCurrentData> periods){
		string query = 'SELECT Id, Account__c, CreatedDate FROM Data_Submission__c WHERE (Status__c = \'File processed\' OR Status__c = \'Accepted for Processing\' OR Status__c = \'Submitted\')';
		boolean useQuery = false;
		List<string> filters = new List<string>();
		for(Id periodId: inDuePeriodsWithAccounts.keySet()){
			SubmissionPeriodCurrentData period = periods.get(periodId);
			List<Id> accountIds = inDuePeriodsWithAccounts.get(periodId);

			DateTime dtFrom = DateTime.newInstanceGmt(
					period.CurrentSubmissionCycleStart.year(),
					period.CurrentSubmissionCycleStart.month(),
					period.CurrentSubmissionCycleStart.day(),
					0,0,0);

			DateTime dtTo = DateTime.newInstanceGmt(
					period.CurrentSubmissionCycleEnd.year(),
					period.CurrentSubmissionCycleEnd.month(),
					period.CurrentSubmissionCycleEnd.day(),
					23,59,59);

			if (period != null && accountIds != null) {
				string accounts = '\''+String.join(accountIds,'\',\'')+'\'';
				filters.add(' AND (Account__c IN (' + accounts + ') AND Submission_date__c >=' +  dtFrom.formatGMT('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + '  AND Submission_date__c <=' + dtTo.formatGMT('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' ) ');
			}
		}

		string completeQuery = '';
		if (filters.size() > 0){
			completeQuery = query + string.join(filters, 'OR');
		}

		List<Data_Submission__c> dataSubmissions = new List<Data_Submission__c>();
		if(string.isNotEmpty(completeQuery)){
			dataSubmissions = Database.query(completeQuery);
		}

		Map<Id, List<Data_Submission__c>> accountDataSubmissions = new Map<Id, List<Data_Submission__c>>();
		for(Data_Submission__c dataSubmission: dataSubmissions){
			List<Data_Submission__c> dsFromMap = accountDataSubmissions.get(dataSubmission.Account__c);

			if(dsFromMap == null){
				accountDataSubmissions.put(dataSubmission.Account__c, new List<Data_Submission__c>{dataSubmission});
			} else {
				dsFromMap.add(dataSubmission);
			}
		}

		return accountDataSubmissions;
	}

	private static Map<Id, Datetime> getAccountsNewestDataSubmission(Map<Id, Datetime> accountToTargetDateMap) {

		Map<Id, Datetime> accountToNewestSubmissionDate = new Map<Id, Datetime>();

		if(accountToTargetDateMap.isEmpty()) {
			return accountToNewestSubmissionDate;
		}

		Datetime oldest = System.today();
		for(Datetime d : accountToTargetDateMap.values()) {
			if(d < oldest) {
				oldest = d;
			}
		}

		List<Data_Submission__c> dataSubmissions = [SELECT Id, Account__c, Submission_date__c FROM Data_Submission__c WHERE Account__c = :accountToTargetDateMap.keySet() AND Submission_date__c >= :oldest AND (Status__c = 'File processed' OR Status__c = 'Accepted for Processing' OR Status__c = 'Submitted')];
		for(Data_Submission__c dataSubmission : dataSubmissions) {
			if(accountToNewestSubmissionDate.get(dataSubmission.Account__c) == null) {
				accountToNewestSubmissionDate.put(dataSubmission.Account__c, dataSubmission.Submission_date__c);
			}else{
				Datetime existing = accountToNewestSubmissionDate.get(dataSubmission.Account__c);
				if(existing < dataSubmission.Submission_date__c) {
					accountToNewestSubmissionDate.put(dataSubmission.Account__c, dataSubmission.Submission_date__c);
				}
			}
		}

		for(Id accountId : accountToTargetDateMap.keySet()) {
			if(accountToNewestSubmissionDate.get(accountId) == null) {
				accountToNewestSubmissionDate.put(accountId, null);
			}
		}

		return accountToNewestSubmissionDate;
	}

	private static Map<Id, List<Contact_Role_Service_Access__c>> getActiveUsersForAccounts(List<Id> allAccounts){
		Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');
		List<Account_Contact_Role__c> grantedAccounts = [SELECT Id, Contact__c, Contact_Roles__c, Account_Role__r.Account__c FROM Account_Contact_Role__c
		WHERE Account_Role__r.Account__c =: allAccounts AND RecordTypeId =: groupRecordTypeId AND Contact_Roles__r.Name = 'GADM User'];

		List<Contact_Role_Service_Access__c> businessUnits = [
				SELECT Id, Contact_Role__r.Contact__c, Contact_Role__r.Contact_Roles__c, Contact_Role__r.Account_Role__r.Account__c
				FROM Contact_Role_Service_Access__c
				WHERE Contact_Role__r.Account_Role__r.Account__c =: allAccounts
				AND Contact_Role__r.RecordTypeId = :groupRecordTypeId
				AND Contact_Role__r.Contact_Roles__r.Category__c = 'Business Unit'
				AND Status__c = 'Granted'
		];

		Map<Id, Set<Id>> contactToAccount  = new Map<Id, Set<Id>>();
		for(Account_Contact_Role__c acr: grantedAccounts){
			Set<Id> accounts = contactToAccount.get(acr.Contact__c);
			if(accounts == null){
				contactToAccount.put(acr.Contact__c, new Set<Id>{acr.Account_Role__r.Account__c});
			} else {
				accounts.add(acr.Account_Role__r.Account__c);
			}
		}

		Map<Id, Set<Id>> contactsToBU = new Map<Id, Set<Id>>();
		for (Contact_Role_Service_Access__c acr : businessUnits) {
			Set<Id> bus = contactsToBU.get(acr.Contact_Role__r.Contact__c);
			if (bus == null) {
				contactsToBU.put(acr.Contact_Role__r.Contact__c, new Set<Id>{
						acr.Contact_Role__r.Contact_Roles__c
				});
			} else {
				bus.add(acr.Contact_Role__r.Contact_Roles__c);
			}
		}

		Set<Id> contactIds = new Set<Id>();
		for(Account_Contact_Role__c acr: grantedAccounts){
			contactIds.Add(acr.Contact__c);
		}

		List<Contact_Role_Service_Access__c> usersAccess = [SELECT Status__c, Account__c, Contact__c, Email_Address__c, Contact_Roles_Name__c FROM Contact_Role_Service_Access__c
		WHERE Contact__c =: contactIds AND Status__c = 'Granted' AND
		(Contact_Roles_Name__c = 'GADM Data Submitter' OR Contact_Roles_Name__c = 'Service Super User' OR Contact_Roles_Name__c = 'GADM User') ];
		Set<Id> businessUnitsIds = new Set<Id>();
		Map<Id, List<Contact_Role_Service_Access__c>> accountAccess = new Map<Id, List<Contact_Role_Service_Access__c>>();
		List<Id> addedSubmitters = new List<Id>();

		Set<Id> grantedContacts = new Set<Id>();
		for(Contact_Role_Service_Access__c access: usersAccess){
			if(access.Contact_Roles_Name__c == 'GADM User' && access.Status__c == 'Granted') {
				grantedContacts.add(access.Contact__c);
			}
		}

		for(Contact_Role_Service_Access__c access: usersAccess){
			if(access.Contact_Roles_Name__c != 'GADM Data Submitter' || access.Status__c != 'Granted') {continue;}
			if(!grantedContacts.contains(access.Contact__c)) {continue;}
			Set<Id> contactAccounts = contactToAccount.get(access.Contact__c);
			if(contactAccounts != null){
				for (Id accId: contactAccounts){
					List<Contact_Role_Service_Access__c> accessFromMap = accountAccess.get(accId);
					if(accessFromMap == null){
						accountAccess.put(accId, new List<Contact_Role_Service_Access__c>{access});
					} else {
						accessFromMap.add(access);
					}
				}
			}
			addedSubmitters.add(access.Contact__c);
		}

		Map<Id, Set<Id>> accountSuperUsers = new Map<Id,Set<Id>>();
		for(Contact_Role_Service_Access__c access: usersAccess){
			if(access.Contact_Roles_Name__c != 'Service Super User' || access.Status__c != 'Granted') {continue;}
			if(!grantedContacts.contains(access.Contact__c)) {continue;}
			Set<Id> suAccounts = contactToAccount.get(access.Contact__c);
			Set<Id> suBu = contactsToBU.get(access.Contact__c);

			if(addedSubmitters.contains(access.Contact__c)){continue;}

			for(Id submId: addedSubmitters){
				Set<Id> dsAccounts = contactToAccount.get(submId);
				Set<Id> dsBus = contactsToBU.get(submId);

				for(Id dsAcc: dsAccounts){
					if(suAccounts.contains(dsAcc)){
						if (dsBus == null) {
							Set<Id> superUsersforAccount = accountSuperUsers.get(dsAcc);
							if (superUsersforAccount == null) {
								accountSuperUsers.put(dsAcc, new Set<Id>{ access.Contact__c });
							} else {
								superUsersforAccount.add(access.Contact__c);
							}
							continue;
						}
						if (suBu == null) { continue; }
						for(Id dsBu: dsBus) {
							if(suBu.contains(dsBu)){
								Set<Id> superUsersforAccount = accountSuperUsers.get(dsAcc);
								 if(superUsersforAccount == null){
									accountSuperUsers.put(dsAcc, new Set<Id>{access.Contact__c});
								 } else {
									 superUsersforAccount.add(access.Contact__c);
								 }
								break;
							}
						}
					}
				}
			}
		}

		for(Contact_Role_Service_Access__c access: usersAccess){
			if(access.Contact_Roles_Name__c != 'Service Super User' || access.Status__c != 'Granted') {continue;}
			if(!grantedContacts.contains(access.Contact__c)) {continue;}
			for(Id accountId: accountSuperUsers.keySet()){
				Set<Id> contacts = accountSuperUsers.get(accountId);
				if (contacts.contains(access.Contact__c)){
					List<Contact_Role_Service_Access__c> accessFromMap = accountAccess.get(accountId);
					if(accessFromMap == null){
						accountAccess.put(accountId, new List<Contact_Role_Service_Access__c>{access});
					} else {
						accessFromMap.add(access);
					}
				}
			}
		}

		for(Id accountId: allAccounts){
			if (!accountAccess.keySet().contains(accountId)){
				for(Contact_Role_Service_Access__c access: usersAccess) {
					if(access.Contact_Roles_Name__c != 'Service Super User' || access.Status__c != 'Granted') {continue;}
					if(!grantedContacts.contains(access.Contact__c)) {continue;}
					Set<Id> accounts = contactToAccount.get(access.Contact__c);
					if(accounts != null && accounts.contains(accountId)){
						List<Contact_Role_Service_Access__c> accessFromMap = accountAccess.get(accountId);
						if(accessFromMap == null){
							accountAccess.put(accountId, new List<Contact_Role_Service_Access__c>{access});
						} else {
							accessFromMap.add(access);
						}
					}
				}
			}
		}

		return accountAccess;
	}


	private static Map<Id, List<Id>> getActiveSuperUsersForAccount(Map<Id, List<Contact_Role_Service_Access__c>> activeUsersForAccount) {
		Map<Id, List<Id>> activeSuperUsersToAccountMap = new Map<Id, List<Id>>();

		Set<Id> contactIds = new Set<Id>();
		for(Id accountId : activeUsersForAccount.keySet()) {
			if(activeUsersForAccount.get(accountId) == null) {continue;}
			List<Contact_Role_Service_Access__c> accesses = activeUsersForAccount.get(accountId);
			for(Contact_Role_Service_Access__c access : accesses) {
				contactIds.add(access.Contact__c);
			}
		}

		Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
		List<Contact_Role_Service_Access__c> grantedAccesses = [SELECT Id, Contact_Roles_Name__c, Contact__c, Account__c FROM Contact_Role_Service_Access__c WHERE Contact__c = :contactIds AND Status__c = 'Granted' AND Service_Name__c = 'GADM' AND Contact_Role__r.RecordTypeId = :functionalRecordTypeId AND (Contact_Roles_Name__c = 'GADM User' OR Contact_Roles_Name__c = 'Service Super User')];

		Map<Id, List<Id>> accountToGadmUsersMap = new Map<Id, List<Id>>();
		for(Contact_Role_Service_Access__c access : grantedAccesses) {
			if(access.Contact_Roles_Name__c == 'GADM User') {
				if(accountToGadmUsersMap.get(access.Account__c) ==  null) {
					accountToGadmUsersMap.put(access.Account__c, new List<Id>{access.Contact__c});
				}else{
					accountToGadmUsersMap.get(access.Account__c).add(access.Contact__c);
				}

			}
		}


		Map<Id, List<Id>> accountToSuperUsersMap = new Map<Id, List<Id>>();
		for(Contact_Role_Service_Access__c access : grantedAccesses) {
			if(access.Contact_Roles_Name__c == 'Service Super User') {
				if(accountToSuperUsersMap.get(access.Account__c) == null) {
					accountToSuperUsersMap.put(access.Account__c, new List<Id>{access.Contact__c});
				}else{
					accountToSuperUsersMap.get(access.Account__c).add(access.Contact__c);
				}
			}
		}

		Set<Id> gadmAndSuperUsers = new Set<Id>();
		for(Id accountId : accountToGadmUsersMap.keySet()) {
			if(accountToGadmUsersMap.get(accountId) == null) {continue;}
			if(accountToSuperUsersMap.get(accountId) == null) {continue;}
			List<Id> superUsers = accountToSuperUsersMap.get(accountId);
			List<Id> gadmUsers = accountToGadmUsersMap.get(accountId);
			for(Id superUserId : superUsers) {
				if(gadmUsers.contains(superUserId)) {
					gadmAndSuperUsers.add(superUserId);
				}
			}

		}


		Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');
		List<Account_Contact_Role__c> accountContactRoles = [SELECT Id, Contact__c, Account_Role__r.Account__c FROM Account_Contact_Role__c WHERE Contact__c = :gadmAndSuperUsers AND Account_Role__r.Account__c = :activeUsersForAccount.keySet() AND RecordTypeId = :groupRecordTypeId AND Contact_Roles__r.Name = 'GADM User' AND Service_Rendered__c =  'GADM'];

		for(Account_Contact_Role__c contactRole : accountContactRoles) {
			if(activeSuperUsersToAccountMap.get(contactRole.Account_Role__r.Account__c) == null) {
				activeSuperUsersToAccountMap.put(contactRole.Account_Role__r.Account__c, new List<Id>{contactRole.Contact__c});
			}else{
				activeSuperUsersToAccountMap.get(contactRole.Account_Role__r.Account__c).add(contactRole.Contact__c);
			}
		}

		return activeSuperUsersToAccountMap;
	}

	private static Map<Id, Id> getActorsBySubmisionPeriod(Set<Id> periodIds){
		Map<Id, Id> accounts = new  Map<Id, Id>();
		List<GADM_Account_Service_Detail__c> details = [Select Id, Account_Role_Service__r.Account_Role__r.Account__c, Data_Submission_Period__c  From GADM_Account_Service_Detail__c WHERE Data_Submission_Period__c =: (periodIds)];
		if (details != null && details.size() > 0){
			for(GADM_Account_Service_Detail__c detail: details){
				accounts.put(detail.Account_Role_Service__r.Account_Role__r.Account__c, detail.Data_Submission_Period__c);
			}
		}
		return accounts;
	}

	private static Map<Id, GADM_Account_Service_Detail__c> getServiceDetailsByActor(Set<Id> actorIds) {
		Map<Id, GADM_Account_Service_Detail__c> toReturn = new Map<Id, GADM_Account_Service_Detail__c>();

		List<GADM_Account_Service_Detail__c> details = [SELECT Id, Account_Role_Service__r.Account_Role__r.Account__c, Periods_without_data_submission_notify__c FROM GADM_Account_Service_Detail__c WHERE Account_Role_Service__r.Account_Role__r.Account__c = :actorIds];
		for(GADM_Account_Service_Detail__c detail : details) {
			toReturn.put(detail.Account_Role_Service__r.Account_Role__r.Account__c, detail);
		}

		return toReturn;
	}

	@TestVisible
	private static Map<String, List<NotificationWrapper>> notifyContactsBySubmissionPeriods(Date testDate){
		Map<Id, SubmissionPeriodCurrentData> periods = getAllPeriodsWithCurrentData(testDate);
		Set<Id> upcomingPeriods = new Set<Id>();
		Set<Id> inDuePeriods = new Set<Id>();

		for(SubmissionPeriodCurrentData cperiod: periods.values()){
			if(cperiod.UpcomingToBeNotified){
				upcomingPeriods.add(cperiod.period.Id);
			}
			if(cperiod.InDueToBeNotified){
				inDuePeriods.add(cperiod.period.Id);
			}

		}

		Map<Id, Id> upcomingPeriodAccounts = getActorsBySubmisionPeriod(upcomingPeriods);
		Map<Id, Id> inDuePeriodAccounts = getActorsBySubmisionPeriod(inDuePeriods);

		Map<String, List<NotificationWrapper>> contactToBeNotifiedWrapperMap = new Map<String, List<NotificationWrapper>>();

		Map<Id, List<Id>> inDuePeriodsWithAccounts = new Map<Id, List<Id>>();
		for(Id accountId: inDuePeriodAccounts.keySet()){
			Id periodId = inDuePeriodAccounts.get(accountId);

			List<Id> accounts = inDuePeriodsWithAccounts.get(periodId);
			if(accounts == null){
				inDuePeriodsWithAccounts.put(periodId, new List<Id>{accountId});
			} else {
				accounts.add(accountId);
			}
		}

		List<Id> allAccounts = new List<Id>();
		allAccounts.addAll(upcomingPeriodAccounts.keySet());
		allAccounts.addAll(inDuePeriodAccounts.keySet());
		Map<Id, Account> acocunts = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id =: allAccounts]);
		Map<Id, List<Data_Submission__c>> accountDataSubmissions = getDataSubmissions(inDuePeriodsWithAccounts, periods);
		Map<Id, List<Contact_Role_Service_Access__c>> accountAccess = getActiveUsersForAccounts(allAccounts);

		List<NotificationWrapper> upcomingNotificationWrappers = new List<NotificationWrapper>();
		for(Id accountId :upcomingPeriodAccounts.keySet()){
			Id periodId = upcomingPeriodAccounts.get(accountId);
			if(periodId == null) {
				continue;
			}
			SubmissionPeriodCurrentData period = periods.get(periodId);
			if(period == null) {
				continue;
			}


			List<Contact_Role_Service_Access__c> accesses = accountAccess.get(accountId);
			if (accesses != null){

				NotificationWrapper notificationWrapper = new NotificationWrapper();
				notificationWrapper.accountName = acocunts.get(accountId).Name;
				notificationWrapper.submissionStart = period.notificationDateStart;
				notificationWrapper.submissionEnd = period.notificationDateEnd;
				notificationWrapper.contactsToNotify = accesses;

				upcomingNotificationWrappers.add(notificationWrapper);
			}
		}

		contactToBeNotifiedWrapperMap.put('Upcoming', upcomingNotificationWrappers);


		List<NotificationWrapper> inDueNotificationWrappers = new List<NotificationWrapper>();
		for(Id accountId :inDuePeriodAccounts.keySet()){
			Id periodId = inDuePeriodAccounts.get(accountId);
			if (periodId == null){
				continue;
			}
			SubmissionPeriodCurrentData period = periods.get(periodId);
			if (period == null){
				continue;
			}

			if(accountDataSubmissions.get(accountId) != null){
				continue;
			}


			List<Contact_Role_Service_Access__c> accesses = accountAccess.get(accountId);
			if (accesses != null){

				NotificationWrapper notificationWrapper = new NotificationWrapper();
				notificationWrapper.submissionStart = period.notificationDateStart;
				notificationWrapper.submissionEnd = period.notificationDateEnd;
				notificationWrapper.contactsToNotify = accesses;
				notificationWrapper.accountName = acocunts.get(accountId).Name;

				inDueNotificationWrappers.add(notificationWrapper);
			}
		}
		contactToBeNotifiedWrapperMap.put('InDue', inDueNotificationWrappers);

		Map<Id, GADM_Account_Service_Detail__c> serviceDetailToAccountMap = getServiceDetailsByActor(inDuePeriodAccounts.keySet());

		Map<Id, Datetime> accountToTargetDateMap = new Map<Id, Datetime>();
		Map<Id, Integer> monthsNotSubmittingMap = new Map<Id, Integer>();

		for(Id accountId :inDuePeriodAccounts.keySet()){

			Id periodId = inDuePeriodAccounts.get(accountId);
			if (periodId == null){
				continue;
			}

			SubmissionPeriodCurrentData period = periods.get(periodId);
			if (period == null){
				continue;
			}

			GADM_Account_Service_Detail__c detail = serviceDetailToAccountMap.get(accountId);
			if(detail == null) {
				continue;
			}

			Date periodStartDate = period.CurrentPeriodStart;
			Integer periodLength = (Integer)period.period.Period_Length__c;
			Integer periodsWithoutSubmissions = (Integer)detail.Periods_without_data_submission_notify__c;

			if(periodStartDate == null) {continue;}
			if(periodLength == null) {continue;}
			if(periodsWithoutSubmissions == null) {continue;}

			Datetime targetDate = periodStartDate.addMonths((periodLength*periodsWithoutSubmissions) * (-1));
			accountToTargetDateMap.put(accountId, targetDate);
			monthsNotSubmittingMap.put(accountId, (periodLength*periodsWithoutSubmissions));

		}


		List<Id> accountsInDueMore = new List<Id>();

		Map<Id, Datetime> accountsToNewestDataSubmissionMap = getAccountsNewestDataSubmission(accountToTargetDateMap);
		for(Id accId : accountToTargetDateMap.keySet()) {

			//account do not have any submission from target date
			if(accountsToNewestDataSubmissionMap.get(accId) == null) {

				accountsInDueMore.add(accId);

			}else{

				Datetime newestSubmissionDate = accountsToNewestDataSubmissionMap.get(accId);
				Datetime targetDate = accountToTargetDateMap.get(accId);
				if(newestSubmissionDate == null) {continue;}
				if(targetDate == null) {continue;}

				if(targetDate > newestSubmissionDate) {

					accountsInDueMore.add(accId);

				}
			}
		}


		List<NotificationWrapper> notSubmittingNotificationWrappers = new List<NotificationWrapper>();

		Map<Id, List<Id>> activeSuperUsersForAccount = getActiveSuperUsersForAccount(accountAccess);

		for(Id accountId : accountsInDueMore) {

			List<Id> contacts = activeSuperUsersForAccount.get(accountId);
			if(contacts != null && contacts.size() > 0) {

				if(acocunts.get(accountId) == null) {continue;}

				String monthsNotSubmitting = '';
				if(monthsNotSubmittingMap.get(accountId) != null) {
					monthsNotSubmitting = String.valueOf(monthsNotSubmittingMap.get(accountId));
				}

				NotificationWrapper notificationWrapper = new NotificationWrapper();
				notificationWrapper.accountName = acocunts.get(accountId).Name;
				notificationWrapper.monthsNotSubmitting = monthsNotSubmitting;
				notificationWrapper.contactsNotSubmitting = activeSuperUsersForAccount.get(accountId);

				notSubmittingNotificationWrappers.add(notificationWrapper);
			}
		}

		contactToBeNotifiedWrapperMap.put('NotSubmitting', notSubmittingNotificationWrappers);


		return contactToBeNotifiedWrapperMap;
	}


	private static Map<String, List<NotificationWrapper>> prepareNotifications(Map<String, List<NotificationWrapper>> notificationsWrapperMap) {

		List<NotificationWrapper> upcomingNotificationWrappers = notificationsWrapperMap.get('Upcoming');
		if(! upcomingNotificationWrappers.isEmpty()) {
			EmailTemplate upcomingEmailTemplate = [SELECT Id, Name, Subject, Body FROM EmailTemplate WHERE DeveloperName =: 'Data_Submission_Upcoming'];

			for(NotificationWrapper wrapper : upcomingNotificationWrappers) {
				wrapper.emailTemplate = upcomingEmailTemplate;
			}
		}

		List<NotificationWrapper> inDueNotificationWrappers = notificationsWrapperMap.get('InDue');
		if(! inDueNotificationWrappers.isEmpty()) {
			EmailTemplate inDueEmailTemplate = [SELECT Id, Name, Subject, Body FROM EmailTemplate WHERE DeveloperName =: 'Data_Submission_InDue'];

			for(NotificationWrapper wrapper : inDueNotificationWrappers) {
				wrapper.emailTemplate = inDueEmailTemplate;
			}
		}

		List<NotificationWrapper> notSubmittingNotificationWrappers = notificationsWrapperMap.get('NotSubmitting'); {
			if(! notSubmittingNotificationWrappers.isEmpty()) {
				EmailTemplate notSubmittingEmailTemplate = [SELECT Id, Name, Subject, Body FROM EmailTemplate WHERE DeveloperName =: 'Data_Submission_NotSubmitting'];

				for(NotificationWrapper wrapper : notSubmittingNotificationWrappers) {
					wrapper.emailTemplate = notSubmittingEmailTemplate;
				}
			}
		}

		return notificationsWrapperMap;
	}

	public static string notifyContacts(Date dateToCompare) {
		Map<String, List<NotificationWrapper>> notificationsWrapperMap = notifyContactsBySubmissionPeriods(dateToCompare);
		notificationsWrapperMap = prepareNotifications(notificationsWrapperMap);

		Id iataNoReplyId = null;
		OrgWideEmailAddress[] iataNoReply = [select Id from OrgWideEmailAddress where Address = 'noreply@iata.org'];
		if(iataNoReply != null && iataNoReply.size() > 0){
			iataNoReplyId = iataNoReply.get(0).Id;
		}

		string email = 'gadm@iata.org';
		List<GADM_Settings__mdt> settings = [SELECT IATA_Email_Contact__c FROM GADM_Settings__mdt WHERE DeveloperName = 'GADM'];
		if(settings != null && settings.size() > 0){
			email = settings[0].IATA_Email_Contact__c;
		}

		List<NotificationWrapper> upcomingNotificationWrappers = notificationsWrapperMap.get('Upcoming');
		List<NotificationWrapper> inDueNotificationWrappers = notificationsWrapperMap.get('InDue');
		List<NotificationWrapper> notSubmittingWrappers = notificationsWrapperMap.get('NotSubmitting');

		List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

		for(NotificationWrapper upcomingWrapper : upcomingNotificationWrappers) {
			Date periodStart = upcomingWrapper.submissionStart;
			Date periodEnd = upcomingWrapper.submissionEnd;
			List<Contact_Role_Service_Access__c> accesses = upcomingWrapper.contactsToNotify;
			for(Contact_Role_Service_Access__c access : accesses) {
				Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(upcomingWrapper.emailTemplate.Id, access.Contact__c, null);
				String bodyHtml = mail.getHtmlBody();
				String replacedHtmlBody = bodyHtml.replace('*periodStart*', String.valueOf(periodStart)).replace('*periodEnd*', String.valueOf(periodEnd)).replace('*actor*', upcomingWrapper.accountName).replace('*email*', email);
				mail.setHtmlBody(replacedHtmlBody);

				String bodyText = mail.getPlainTextBody();
				String replacedTextBody = bodyText.replace('*periodStart*', String.valueOf(periodStart)).replace('*periodEnd*', String.valueOf(periodEnd)).replace('*actor*', upcomingWrapper.accountName).replace('*email*', email);
				mail.setPlainTextBody(replacedTextBody);
				mail.setUseSignature(false);
				if(iataNoReplyId != null) {
					mail.setOrgWideEmailAddressId(iataNoReplyId);
				}
				allmsg.add(mail);
			}
		}

		for(NotificationWrapper inDueWrapper : inDueNotificationWrappers) {
			List<Contact_Role_Service_Access__c> accesses = inDueWrapper.contactsToNotify;
			Date periodStart = inDueWrapper.submissionStart;
			Date periodEnd = inDueWrapper.submissionEnd;

			for(Contact_Role_Service_Access__c access : accesses) {
				Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(inDueWrapper.emailTemplate.Id, access.Contact__c, null);
				String bodyHtml = mail.getHtmlBody();
				String replacedHtmlBody = bodyHtml.replace('*periodStart*', String.valueOf(periodStart)).replace('*periodEnd*', String.valueOf(periodEnd)).replace('*actor*', inDueWrapper.accountName).replace('*email*', email);
				mail.setHtmlBody(replacedHtmlBody);

				String bodyText = mail.getPlainTextBody();
				String replacedTextBody = bodyText.replace('*periodStart*', String.valueOf(periodStart)).replace('*periodEnd*', String.valueOf(periodEnd)).replace('*actor*', inDueWrapper.accountName).replace('*email*', email);
				mail.setPlainTextBody(replacedTextBody);
				mail.setUseSignature(false);
				if(iataNoReplyId != null) {
					mail.setOrgWideEmailAddressId(iataNoReplyId);
				}
				allmsg.add(mail);
			}
		}

		for(NotificationWrapper notSubmittingWrapper : notSubmittingWrappers) {

			List<Id> accesses = notSubmittingWrapper.contactsNotSubmitting;
			String accountName = notSubmittingWrapper.accountName;
			String monthsNotSubmitting = notSubmittingWrapper.monthsNotSubmitting;

			for(Id contactId : accesses) {
				Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(notSubmittingWrapper.emailTemplate.Id, contactId, null);
				String bodyHtml = mail.getHtmlBody();
				String replacedHtmlbody = bodyHtml.replace('*actor*', accountName).replace('*monthsNotSubmitting*', String.valueOf(monthsNotSubmitting)).replace('*email*', email);
				mail.setHtmlBody(replacedHtmlBody);

				String bodyText = mail.getPlainTextBody();
				String replacedTextbody = bodyText.replace('*actor*', accountName).replace('*monthsNotSubmitting*', String.valueOf(monthsNotSubmitting)).replace('*email*', email);
				mail.setPlainTextBody(replacedTextBody);
				mail.setUseSignature(false);
				if(iataNoReplyId != null) {
					mail.setOrgWideEmailAddressId(iataNoReplyId);
				}
				allmsg.add(mail);
			}
		}

		try {
			Messaging.sendEmail(allmsg,false);
			return 'sent';
		} catch (Exception e) {
			return e.getMessage();

		}

	}

	public class NotificationWrapper {
		public List<Contact_Role_Service_Access__c> contactsToNotify {get; set;}
		public EmailTemplate emailTemplate {get; set;}
		public Date submissionStart {get; set;}
		public Date submissionEnd {get; set;}
		public string accountName {get; set;}
		public String monthsNotSubmitting {get; set;}
		public List<Id> contactsNotSubmitting {get; set;}
	}

	public class SubmissionPeriodCurrentData{
		public GADM_Data_Submission_Period__c period {get;set;}
		public Date CurrentPeriodStart {get;set;}
		public Date PreviousPeriodStart {get; set;}
		public Date NextPeriodStart {get; set;}
		public Date CurrentPeriodEnd {get;set;}
		public Date PreviousPeriodEnd {get; set;}
		public Date NextPeriodEnd {get; set;}


		public Date CurrentSubmissionCycleStart {get;set;}
		public Date CurrentSubmissionCycleEnd {get;set;}

		public Date NextSubmissionCycleStart {get; set;}
		public Date NextSubmissionCycleEnd {get; set;}

		public Date PreviousSubmissionCycleStart {get; set;}
		public Date PreviousSubmissionCycleEnd {get; set;}

		public boolean UpcomingToBeNotified {get;set;}
		public boolean InDueToBeNotified {get;set;}

		public Date notificationDateStart {get; set;}
		public Date notificationDateEnd {get; set;}

		public SubmissionPeriodCurrentData(GADM_Data_Submission_Period__c period, Date dateToCompare){
			if(period != null){
				this.period = period;

				Date sDate = period.Start_Date__c;
				Date periodStartDate = sDate.toStartOfMonth();
				Date comparedDate = dateToCompare;
				Integer monthsCount = periodStartDate.monthsBetween(comparedDate) + 1;


				integer monthsToRemove = (math.mod(monthsCount,(integer)period.Period_Length__c) <> 0) ? 0 : 1;

				CurrentPeriodStart = period.Start_Date__c.addMonths((integer)(period.Period_Length__c*((integer)(monthsCount/period.Period_Length__c )- monthsToRemove)));
				CurrentPeriodEnd = period.Start_Date__c.addMonths((integer)(period.Period_Length__c*((integer)(monthsCount/period.Period_Length__c )- monthsToRemove))+(Integer)period.Period_Length__c).addDays(-1);

				PreviousPeriodStart = CurrentPeriodStart.addMonths((integer)period.Period_Length__c*(-1));
				NextPeriodStart = CurrentPeriodStart.addMonths((integer)period.Period_Length__c);

				PreviousPeriodEnd = CurrentPeriodEnd.addMonths((integer)period.Period_Length__c*(-1));
				NextPeriodEnd = CurrentPeriodEnd.addMonths((integer)period.Period_Length__c);

				Date startDate = CurrentPeriodStart.addMonths((integer)(period.Submission_Cycle_Start_Month__c-1));
				Date endDate = CurrentPeriodStart.addMonths((integer)(period.Submission_Cycle_End_Month__c-1));

				Date startDatePrevious = PreviousPeriodStart.addMonths((integer)(period.Submission_Cycle_Start_Month__c-1));
				Date endDatePrevious = PreviousPeriodStart.addMonths((integer)(period.Submission_Cycle_End_Month__c-1));

				Date startDateNext = NextPeriodStart.addMonths((integer)(period.Submission_Cycle_Start_Month__c-1));
				Date endDateNext = NextPeriodStart.addMonths((integer)(period.Submission_Cycle_End_Month__c-1));

				Integer numberOfDaysStart = Date.daysInMonth(startDate.year(), startDate.month());
				Integer numberOfDaysEnd = Date.daysInMonth(endDate.year(), endDate.month());

				Integer numberOfDaysStartPrevious = Date.daysInMonth(startDatePrevious.year(), startDatePrevious.month());
				Integer numberOfDaysEndPrevious = Date.daysInMonth(endDatePrevious.year(), endDatePrevious.month());

				Integer numberOfDaysStartNext = Date.daysInMonth(startDateNext.year(), startDateNext.month());
				Integer numberOfDaysEndNext = Date.daysInMonth(endDateNext.year(), endDateNext.month());

				Integer startDay = (integer)period.Submission_Cycle_Start_Day__c > numberOfDaysStart ? numberOfDaysStart : (integer)period.Submission_Cycle_Start_Day__c;
				Integer endDay = (integer)period.Submission_Cycle_End_Day__c > numberOfDaysEnd ? numberOfDaysEnd : (integer)period.Submission_Cycle_End_Day__c;
				CurrentSubmissionCycleStart =  date.newInstance(startDate.year(), startDate.month(), startDay);
				CurrentSubmissionCycleEnd =  date.newInstance(endDate.year(), endDate.month(), endDay);

				Integer startDayPrevious = (integer)period.Submission_Cycle_Start_Day__c > numberOfDaysStartPrevious ? numberOfDaysStartPrevious : (integer)period.Submission_Cycle_Start_Day__c;
				Integer endDayPrevious = (integer)period.Submission_Cycle_End_Day__c > numberOfDaysEndPrevious ? numberOfDaysEndPrevious : (integer)period.Submission_Cycle_End_Day__c;
				PreviousSubmissionCycleStart =  date.newInstance(startDatePrevious.year(), startDatePrevious.month(), startDayPrevious);
				PreviousSubmissionCycleEnd =  date.newInstance(endDatePrevious.year(), endDatePrevious.month(), endDayPrevious);

				Integer startDayNext = (integer)period.Submission_Cycle_Start_Day__c > numberOfDaysStartNext ? numberOfDaysStartNext : (integer)period.Submission_Cycle_Start_Day__c;
				Integer endDayNext = (integer)period.Submission_Cycle_End_Day__c > numberOfDaysEndNext ? numberOfDaysEndNext : (integer)period.Submission_Cycle_End_Day__c;
				NextSubmissionCycleStart =  date.newInstance(startDateNext.year(), startDateNext.month(), startDayNext);
				NextSubmissionCycleEnd =  date.newInstance(endDateNext.year(), endDateNext.month(), endDayNext);

				Date upcomingDate = CurrentSubmissionCycleStart.addDays((integer)period.Upcoming_Notification__c*-1);
				Date dueDate = CurrentSubmissionCycleEnd.addDays((integer)period.In_Due_Notification__c *-1);

				Date upcomingDateNext = NextSubmissionCycleStart.addDays((integer)period.Upcoming_Notification__c*-1);
				Date dueDateNext = NextSubmissionCycleEnd.addDays((integer)period.In_Due_Notification__c *-1);

				Date upcomingDatePrevious = PreviousSubmissionCycleStart.addDays((integer)period.Upcoming_Notification__c*-1);
				Date dueDatePrevious = PreviousSubmissionCycleEnd.addDays((integer)period.In_Due_Notification__c *-1);

				UpcomingToBeNotified = (upcomingDate == dateToCompare) || (upcomingDatePrevious == dateToCompare) || (upcomingDateNext == dateToCompare);
				if(UpcomingToBeNotified) {
					if(upcomingDate == dateToCompare) {
						notificationDateStart = CurrentSubmissionCycleStart;
						notificationDateEnd = CurrentSubmissionCycleEnd;
					} else if (upcomingDatePrevious == dateToCompare){
						notificationDateStart = PreviousSubmissionCycleStart;
						notificationDateEnd = PreviousSubmissionCycleEnd;
					} else if (upcomingDateNext == dateToCompare){
						notificationDateStart = NextSubmissionCycleStart;
						notificationDateEnd = NextSubmissionCycleEnd;
					}
				}
				InDueToBeNotified = (dueDate == dateToCompare) || (dueDatePrevious == dateToCompare) || (dueDateNext == dateToCompare);
				if(InDueToBeNotified) {
					if(dueDate == dateToCompare) {
						notificationDateStart = CurrentSubmissionCycleStart;
						notificationDateEnd = CurrentSubmissionCycleEnd;
					} else if (dueDatePrevious == dateToCompare){
						notificationDateStart = PreviousSubmissionCycleStart;
						notificationDateEnd = PreviousSubmissionCycleEnd;
					} else if (dueDateNext == dateToCompare){
						notificationDateStart = NextSubmissionCycleStart;
						notificationDateEnd = NextSubmissionCycleEnd;
					}
				}

			}
		}
	}
}
