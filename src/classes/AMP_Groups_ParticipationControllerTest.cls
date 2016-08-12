@isTest
private class AMP_Groups_ParticipationControllerTest {
	
	@isTest static void test_controller() {
		// CREATE TEST DATA
        
        // Create a new ISO Country        
        IATA_ISO_Country__c country_qr = new IATA_ISO_Country__c(Name = 'Qatar', ISO_Code__c = 'QR', Region__c = 'Africa & Middle East');
        insert country_qr;
        
        // Create an Airline HQ account
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');
        Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger', 
                                RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_qr.Id, Membership_status__c = 'Non-IATA member');
        insert acct_hq;


        // instantiate the groups participation page controller 
        ApexPages.StandardController std = new ApexPages.StandardController(acct_hq);
        AMP_Groups_ParticipationController controller = new AMP_Groups_ParticipationController(std);
        
        system.assertEquals(true, controller.lstParticipants.isEmpty());
	}
	
}