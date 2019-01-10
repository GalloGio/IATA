public without sharing class GDPR_CTRL {
	
	@AuraEnabled
    public static Id createLead(Lead lead) {
		// Create an individual
		Individual i = new Individual(lastname='Beckham' );
		insert i;
		// Create a lead
		Lead l = new Lead(lastname='Beckham',  email=lead.email, company='Fake', IndividualId=i.Id );
		insert l;
		return l.Id;
	}

	@AuraEnabled
    public static boolean checkUserExist(Lead lead) {
		// Check if it's a IATA user
		return [SELECT count() FROM User WHERE email =: lead.Email] > 0;
	}
}