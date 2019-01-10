public with sharing class GDPR_Logout_CTRL {
	
	@AuraEnabled
    public static Boolean killToken(String individualId) {
		list<Individual> inds = [SELECT id FROM Individual WHERE Id =: individualId];
		if(!inds.isEmpty()) {
			Individual ind = inds[0];
			//ind.token__c = '';
			//ind.date__c = null;
			try {
				update ind;
			} catch(Exception e) {
				return false;
			}
			return true;
		}
        return false;
    }
    
}