trigger trgAssocAffiliationMembership on Assoc_Affiliation_Membership__c (before insert, before update) {
	if (!IECConstants.GDPReplication_ProfileIDswithAccess.contains(UserInfo.getProfileId().substring(0, 15))){
		for (Assoc_Affiliation_Membership__c obj : trigger.new) {
			if (obj.AIMS_ID__c != null || obj.WebStar_ID__c != null)
				obj.addError(Label.Cannot_Update_AIMS_values);
		}
	}
}
