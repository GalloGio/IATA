public without sharing class ServiceTermsAndConditionsUtils {

	public static final String TC_ACCEPTANCE_STATUS_PENDING = 'Pending';
	public static final String TC_ACCEPTANCE_STATUS_ACCEPTED = 'Accepted';
	public static final String TC_ACCEPTANCE_STATUS_REJECTED = 'Rejected';

	@AuraEnabled
	public static Id getPortalServiceId(String portalServiceName){
		List<Portal_Applications__c> pa = [SELECT Id FROM Portal_Applications__c WHERE Name =: portalServiceName];

		if(!pa.isEmpty()){
			return pa[0].Id;
		}
		return null;
	}

	@AuraEnabled(cacheable=false)
	public static Boolean checkLatestTermsAndConditionsAccepted(Id contactId, Id portalServiceId){
		for(TermAndConditionWrapper wrappedTc : getWrappedTermsAndConditions(contactId, portalServiceId, null)){
			if(! wrappedTc.isLatestVersionAccepted){
				return false;
			}
		}
		return true;
	}

	@AuraEnabled
	public static List<TermAndConditionWrapper> getWrappedTermsAndConditions(Id contactId, Id portalServiceId, String language){
		List<TermAndConditionWrapper> wrappedTermsAndConditions = new List<TermAndConditionWrapper>();
		LabelTranslator translator = new LabelTranslator();

		if(contactId != null){
			// Retrieve the Term and Condition records for the service, including old versions
			Map<Id,List<Term_and_Condition__c>> tcs = getServiceTermsAndConditionsForContact(contactId, portalServiceId);

			for(Id tcId : tcs.keySet()){
				Term_and_Condition__c latestTc;
				Boolean isLatestVersionAccepted = false;
				Boolean isOlderVersionAccepted = false;

				for(Term_and_Condition__c tc : tcs.get(tcId)){
					// Latest version
					if(tc.Id == tcId){
						latestTc = tc;
						isLatestVersionAccepted = !tc.Term_and_Condition_Acceptances__r.isEmpty() && tc.Term_and_Condition_Acceptances__r[0].Status__c == TC_ACCEPTANCE_STATUS_ACCEPTED && tc.Term_and_Condition_Acceptances__r[0].Is_Superseded__c == false;
					}
					// Older versions
					else{
						isOlderVersionAccepted = isOlderVersionAccepted || (!tc.Term_and_Condition_Acceptances__r.isEmpty() && tc.Term_and_Condition_Acceptances__r[0].Status__c == TC_ACCEPTANCE_STATUS_ACCEPTED);
					}
				}
				TermAndConditionWrapper wrappedTc = getWrappedTermAndCondition(latestTc, language, translator, isLatestVersionAccepted, isOlderVersionAccepted);
				wrappedTermsAndConditions.add(wrappedTc);
			}
		}
		else{
			// Retrieve the Term and Condition records for the service
			List<Term_and_Condition__c> tcs = getServiceTermsAndConditions(portalServiceId);
			for(Term_and_Condition__c tc : tcs){
				TermAndConditionWrapper wrappedTc = getWrappedTermAndCondition(tc, language, translator, false, false);
				wrappedTermsAndConditions.add(wrappedTc);
			}
		}

		return wrappedTermsAndConditions;
	}

	@AuraEnabled
	public static TermAndConditionWrapper getWrappedTermAndCondition(Term_and_Condition__c tc, String language, LabelTranslator translator, Boolean isLatestVersionAccepted, Boolean isOlderVersionAccepted){
			String label = '';
			String customLabel = tc.Custom_Label_for_Translated_Name__c;
			if(customLabel != null && customLabel != ''){
				String translatedString = translator.translate(customLabel,language);
				if(translatedString != ''){
					label = translatedString;
				}
				else{
					label = customLabel;
				}
			}
			else{
				label = tc.Name;
			}

			TermAndConditionWrapper wrappedTc = new TermAndConditionWrapper();
			wrappedTc.id = tc.Id;
			wrappedTc.label = label;
			wrappedTc.isLatestVersionAccepted = isLatestVersionAccepted;
			wrappedTc.isOlderVersionAccepted = isOlderVersionAccepted;
			wrappedTc.isUrl = tc.Type__c == 'URL';
			wrappedTc.url = tc.T_C_URL__c;
			wrappedTc.description = tc.NewGenApp_T_C_Description__c;

			return wrappedTc;
	}

	@AuraEnabled
	public static List<Term_and_Condition__c> getServiceTermsAndConditions(Id portalServiceId){
		List<Id> tcIds = new List<Id>();

		for(Service_Term_and_Condition__c stc : [SELECT Id, Term_Condition__r.Id
												FROM Service_Term_and_Condition__c
												WHERE Portal_Service__r.Id =: portalServiceId]){
			tcIds.add(stc.Term_Condition__r.Id);
		}

		List<Term_and_Condition__c> tcs =
			[SELECT Id, Name, Custom_Label_for_Translated_Name__c, Type__c, T_C_URL__c, NewGenApp_T_C_Description__c
			FROM Term_and_Condition__c
			WHERE Id in: tcIds];

		return tcs;
	}

	// Used for connected portal user
	@AuraEnabled
	public static Map<Id,List<Term_and_Condition__c>> getServiceTermsAndConditionsForContact(Id contactId, Id portalServiceId){
		Map<Id,Id> tcIds = new Map<Id,Id>();
		Map<Id,List<Term_and_Condition__c>> tcMap = new Map<Id,List<Term_and_Condition__c>>();

		for(Service_Term_and_Condition__c stc : [SELECT Id, Term_Condition__r.Id, Term_Condition__r.Initial_Version__c
												FROM Service_Term_and_Condition__c
												WHERE Portal_Service__r.Id =: portalServiceId]){
			Id initialVersion = stc.Term_Condition__r.Initial_Version__c != null ? stc.Term_Condition__r.Initial_Version__c : stc.Term_Condition__r.Id;
			tcIds.put(initialVersion, stc.Term_Condition__r.Id);
			tcMap.put(stc.Term_Condition__r.Id, new List<Term_and_Condition__c>());
		}

		for(Term_and_Condition__c tc : [SELECT Id, Initial_Version__c, Name, Custom_Label_for_Translated_Name__c, Type__c, T_C_URL__c, NewGenApp_T_C_Description__c,
												(SELECT Id, Status__c, Is_Superseded__c FROM Term_and_Condition_Acceptances__r WHERE Contact__r.Id =: contactId LIMIT 1)
										FROM Term_and_Condition__c
										WHERE Id IN : tcIds.keySet() OR Initial_Version__c IN : tcIds.keySet()]){
			Id initialVersion = tc.Initial_Version__c != null ? tc.Initial_Version__c : tc.Id;
			tcMap.get(tcIds.get(initialVersion)).add(tc);
		}
		return tcMap;
	}

	@AuraEnabled
	public static void createTermsConditionsAcceptancesForNewUser(Id contactId, String termsAndConditionsIds){
		// We use the T&C Ids instead of the service Id, because the T&C versions might have changed since the moment where the user accepted the T&C
		// and the moment where he creates the password. If that's the case, the user will have to accept the new versions after the login
		List<Id> tcIds = (List<Id>) termsAndConditionsIds.split(',');

		upsertTermAndConditionAcceptances(contactId, tcIds, TC_ACCEPTANCE_STATUS_ACCEPTED);
	}

	@AuraEnabled
	public static void createPendingTermsAndConditionsAcceptances(Id contactId, Id portalServiceId){
		List<Id> tcIds = new List<Id>();
		for(Term_and_Condition__c tc : getServiceTermsAndConditions(portalServiceId)){
			tcIds.add(tc.Id);
		}
		upsertTermAndConditionAcceptances(contactId, tcIds, TC_ACCEPTANCE_STATUS_PENDING);
	}

	@AuraEnabled
	public static void acceptServiceTermsAndConditions(Id contactId, Id portalServiceId){
		List<Id> tcIds = new List<Id>();
		for(Term_and_Condition__c tc : getServiceTermsAndConditions(portalServiceId)){
			tcIds.add(tc.Id);
		}
		upsertTermAndConditionAcceptances(contactId, tcIds, TC_ACCEPTANCE_STATUS_ACCEPTED);
	}

	@AuraEnabled
	public static void upsertTermAndConditionAcceptances(Id contactId, List<Id> tcIds, String status){
		// Retrieve the Term and Condition records
		List <Term_and_Condition__c> tcRecords = [SELECT Id, Initial_Version__c FROM Term_and_Condition__c WHERE Id IN: tcIds];

		// Retrieve their initial versions
		List<Id> initialVersions = new List<Id>();

		for(Term_and_Condition__c tcRecord : tcRecords){
			if(tcRecord.Initial_Version__c != null){
				initialVersions.add(tcRecord.Initial_Version__c);
			}
			else{
				initialVersions.add(tcRecord.Id);
			}
		}

		// Retrieve the Term and Condition Acceptance records related to the Term and Condition hierarchies of the initial versions
		List<Term_and_Condition_Acceptance__c> existingAcceptanceRecordsList = [SELECT Id, Status__c, Status_Date__c, Is_Superseded__c, Term_Condition__r.Id, Term_Condition__r.Initial_Version__c
																			FROM Term_and_Condition_Acceptance__c
																			WHERE Contact__r.Id =: contactId
																				AND (Term_Condition__r.Initial_Version__c IN : initialVersions
																					OR (Term_Condition__r.Initial_Version__c = null AND Term_Condition__r.Id IN: initialVersions))];

		Set<Id> termsAndConditionsWithExistingAcceptances = new Set<Id>();
		for(Term_and_Condition_Acceptance__c existingAcceptanceRecord : existingAcceptanceRecordsList){
			termsAndConditionsWithExistingAcceptances.add(existingAcceptanceRecord.Term_Condition__r.Id);
		}

		// List of Terms and Conditions we will upsert
		List<Term_and_Condition_Acceptance__c> recordsToUpsert = new List<Term_and_Condition_Acceptance__c>();

		for(Term_and_Condition_Acceptance__c tca : existingAcceptanceRecordsList){
			if(tcIds.contains(tca.Term_Condition__r.Id)){
				// If some of these records are the ones we have to upsert, we have to update their Status and Status Date
				// if status is already Accepted, we won't set it to Pending
				if(tca.Status__c != status && !(tca.Status__c == TC_ACCEPTANCE_STATUS_ACCEPTED && status == TC_ACCEPTANCE_STATUS_PENDING)){
					tca.Status__c = status;
					tca.Status_Date__c = System.today();
					recordsToUpsert.add(tca);
				}
			}
			else{
				// For the other records, if the status we want to set is Accepted or Pending, they have to mark them as superseded
				if((status == TC_ACCEPTANCE_STATUS_ACCEPTED || status == TC_ACCEPTANCE_STATUS_PENDING) && tca.Is_Superseded__c == false){
					tca.Is_Superseded__c = true;
					recordsToUpsert.add(tca);
				}
			}
		}

		// Now we have to create the missing records
		for(Id tcId : tcIds){
			if(!termsAndConditionsWithExistingAcceptances.contains(tcId)){
				recordsToUpsert.add(new Term_and_Condition_Acceptance__c(
					Contact__c = contactId,
					Term_Condition__c = tcId,
					Status__c = status,
					Status_Date__c = System.today()
				));
			}
		}

		upsert recordsToUpsert;
	}

	public class TermAndConditionWrapper{
		@AuraEnabled
		public String id {get; set;}

		@AuraEnabled
		public String label {get; set;}

		@AuraEnabled
		public Boolean isLatestVersionAccepted { get; set; }

		@AuraEnabled
		public Boolean isOlderVersionAccepted { get; set; }

		@AuraEnabled
		public Boolean isUrl { get; set; }

		@AuraEnabled
		public String url { get; set; }

		@AuraEnabled
		public String description { get; set; }

		public TermAndConditionWrapper(){}
	}
}