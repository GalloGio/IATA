public without sharing class TermAndConditionUtils{


	public static Term_And_Condition__c getPortalServiceLatestTC(Id portalServiceId){
		System.debug('portal service id : ' + portalServiceId);
		if(portalServiceId.getSObjectType().getDescribe().getName() != 'Portal_Applications__c'){
			throw new TermAndConditionException('Invalid Portal Service Id : ' + portalServiceId);
		}

		List<Term_And_Condition__c> tcList = [SELECT Id, Is_Latest__c, T_C_Id__c
											  FROM Term_And_Condition__c
											  WHERE NewGenApp_PortalService__c =: portalServiceId];

		// No terms and conditions are defined for this service
		if(tcList.isEmpty()){
			return null;
		}

		Term_And_Condition__c latest = null;

		for(Term_And_Condition__c tc : tcList){
			if(tc.Is_Latest__c){
				if(latest != null){
					// Multiple latest versions are defined for this service
					throw new TermAndConditionException('Multiple latest versions');
				}
				latest = tc;
			}
		}

		if(latest == null){
			// No latest versions is defined for this service
			throw new TermAndConditionException('No latest version set');
		}

		return latest;
	}

	public class TermAndConditionException extends Exception{}
}
