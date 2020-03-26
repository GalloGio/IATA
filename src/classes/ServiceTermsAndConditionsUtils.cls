public without sharing class ServiceTermsAndConditionsUtils {

	@AuraEnabled
	public static Id getPortalServiceId(String portalServiceName){
		List<Portal_Applications__c> pa = [SELECT Id FROM Portal_Applications__c WHERE Name =: portalServiceName];

		if(!pa.isEmpty()){
			return pa[0].Id;
		}
		return null;
	}

	@AuraEnabled(cacheable=false)
	public static Boolean checkLatestTermsAndConditionsAccepted(Id portalServiceId, Id contactId){
        for(TermAndConditionWrapper wrappedTc : getWrappedTermsAndConditions(portalServiceId, contactId, null)){
            if(! wrappedTc.isLatestVersionAccepted){
                return false;
            }
        }
        return true;
    }

	@AuraEnabled
	public static List<TermAndConditionWrapper> getWrappedTermsAndConditions(Id portalServiceId, Id contactId, String language){
		List<TermAndConditionWrapper> wrappedTermsAndConditions = new List<TermAndConditionWrapper>();
		LabelTranslator translator = new LabelTranslator();

		if(contactId != null){
			// Retrieve the Term and Condition records for the service, including old versions
			Map<Id,List<Term_and_Condition__c>> tcs = getServiceTermsAndConditionsForContact(portalServiceId, contactId);

			for(Id tcId : tcs.keySet()){
				Term_and_Condition__c latestTc;
				Boolean isLatestVersionAccepted = false;
				Boolean isOlderVersionAccepted = false;

				for(Term_and_Condition__c tc : tcs.get(tcId)){
					// Latest version
					if(tc.Id == tcId){
						latestTc = tc;
						isLatestVersionAccepted = !tc.Term_and_Condition_Acceptances__r.isEmpty() && tc.Term_and_Condition_Acceptances__r[0].Status__c == 'Accepted';
					}
					// Older versions
					else{
						isOlderVersionAccepted = isOlderVersionAccepted || (!tc.Term_and_Condition_Acceptances__r.isEmpty() && tc.Term_and_Condition_Acceptances__r[0].Status__c == 'Accepted');
					}
				}
				TermAndConditionWrapper wrappedTc = getWrappedTermAndCondition(latestTc, language, translator, isLatestVersionAccepted, isOlderVersionAccepted);
				System.debug('Wrapped T&C : ' + wrappedTc);
				wrappedTermsAndConditions.add(wrappedTc);
			}
		}
		else{
			// Retrieve the Term and Condition records for the service
			List<Term_and_Condition__c> tcs = getServiceTermsAndConditions(portalServiceId);
			for(Term_and_Condition__c tc : tcs){
				TermAndConditionWrapper wrappedTc = getWrappedTermAndCondition(tc, language, translator, false, false);
				System.debug('Wrapped T&C : ' + wrappedTc);
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

	// Used for guest portal user (no contact)
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

	// Used for connected portal user (no contact)
	@AuraEnabled
	public static Map<Id,List<Term_and_Condition__c>> getServiceTermsAndConditionsForContact(Id portalServiceId, Id contactId){
		Map<String,Id> tcIds = new Map<String,Id>();
		Map<Id,List<Term_and_Condition__c>> tcMap = new Map<Id,List<Term_and_Condition__c>>();

		for(Service_Term_and_Condition__c stc : [SELECT Id, /*Term_Condition__r.Id, */Term_Condition__r.Name
												FROM Service_Term_and_Condition__c
												WHERE Portal_Service__r.Id =: portalServiceId]){
			tcIds.put(stc.Term_Condition__r.Name, stc.Term_Condition__r.Id);
			tcMap.put(stc.Term_Condition__r.Id, new List<Term_and_Condition__c>());
		}


		for(Term_and_Condition__c tc : [SELECT Id, Name, Custom_Label_for_Translated_Name__c, Type__c, T_C_URL__c, NewGenApp_T_C_Description__c,
												(SELECT Id, Status__c FROM Term_and_Condition_Acceptances__r WHERE Contact__r.Id =: contactId LIMIT 1)
										FROM Term_and_Condition__c
										WHERE Name IN : tcIds.keySet()]){
			tcMap.get(tcIds.get(tc.Name)).add(tc);
		}
		return tcMap;
	}

	@AuraEnabled
	public static void acceptServiceTermsAndConditions(Id portalServiceId, Id contactId){
        List<Id> tcIds = new List<Id>();
		for(Term_and_Condition__c tc : getServiceTermsAndConditions(portalServiceId)){
            tcIds.add(tc.Id);
        }
        upsertTermAndConditionAcceptances(tcIds, contactId, 'Accepted');
	}

	@AuraEnabled
	public static void rejectServiceTermsAndConditions(Id portalServiceId, Id contactId){
        List<Id> tcIds = new List<Id>();
		for(Term_and_Condition__c tc : getServiceTermsAndConditions(portalServiceId)){
            tcIds.add(tc.Id);
        }
        upsertTermAndConditionAcceptances(tcIds, contactId, 'Rejected');
	}

	@AuraEnabled
	public static void upsertTermAndConditionAcceptances(List<Id> termAndConditionIds, Id contactId, String newStatus){
        Map<Id, Term_and_Condition_Acceptance__c> existingAcceptanceRecords = new Map<Id,Term_and_Condition_Acceptance__c>();

        for(Term_and_Condition_Acceptance__c tc : [SELECT Id, Term_Condition__r.Id, Status__c, Date_Accepted__c 
                                                                    FROM Term_and_Condition_Acceptance__c 
                                                                    WHERE Contact__r.Id =: contactId
                                                                        AND Term_Condition__r.Id IN : termAndConditionIds]){
            existingAcceptanceRecords.put(tc.Term_Condition__r.Id, tc);
        }

		List<Term_and_Condition_Acceptance__c> tcAcceptances = new List<Term_and_Condition_Acceptance__c>();

		for(Id tcId : termAndConditionIds){
			if(!existingAcceptanceRecords.keySet().contains(tcId)){
				Term_and_Condition_Acceptance__c tca = new Term_and_Condition_Acceptance__c(
					Contact__c = contactId,
					Term_Condition__c = tcId,
					Status__c = newStatus,
					Date_Accepted__c = Date.today()
				);
                tcAcceptances.add(tca);
			}
            else{
                Term_and_Condition_Acceptance__c tca = existingAcceptanceRecords.get(tcId);
                if(tca.Status__c != newStatus){
                    tca.Status__c = newStatus;
                    tca.Date_Accepted__c = Date.today();
                    tcAcceptances.add(tca);
                }
            }
		}
		upsert tcAcceptances;
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