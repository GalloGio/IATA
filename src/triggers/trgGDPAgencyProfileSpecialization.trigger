trigger trgGDPAgencyProfileSpecialization on GDP_Agency_Profile_Specialization__c (before insert, before update) { 
	if (!IECConstants.GDPReplication_ProfileIDswithAccess.contains(UserInfo.getProfileId().substring(0, 15))){
	    for (GDP_Agency_Profile_Specialization__c obj : trigger.new) {
	    	if (obj.AIMS_ID__c != null || obj.WebStar_ID__c != null)
	            obj.addError(Label.Cannot_Update_AIMS_values);
	    }
	}
}