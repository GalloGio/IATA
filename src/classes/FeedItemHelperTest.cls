@isTest
private class FeedItemHelperTest {
	
	@isTest static void test_CheckPostTopics() {
		// CREATE TEST DATA
        
                // Create a new ISO Country
                IATA_ISO_Country__c country_qr = new IATA_ISO_Country__c(Name = 'Qatar', ISO_Code__c = 'QR', Region__c = 'Africa & Middle East');
                insert country_qr;
                        
                // Create an Airline HQ account
                Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');
                Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger', 
                                        RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_qr.Id, Membership_status__c = 'IATA member');
                insert acct_hq;

                Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Contact').get('Standard_Contact');
                Contact con =new contact(firstname = 'Name', lastname = 'pluto', phone = '123', accountid = acct_hq.id, email = 'asd.arg@wewt.et', RecordTypeId = ContactStd_RT_Id);
                insert con;


                test.startTest();

                	// Test for errors raised

                	FeedItem fi = new FeedItem(ParentId = acct_hq.Id, Body = 'body with NO hashtags');

                	Boolean isExceptionThrown = false;

                	try {
                		insert fi;
                	} catch (Exception e) {
                		isExceptionThrown = true;
                	}

                	system.assertEquals(true, isExceptionThrown);


                	// Test for no errors raised
                	// #1 , hashtags used

                	fi = new FeedItem(ParentId = acct_hq.Id, Body = 'body WITH #hashtags');

                	isExceptionThrown = false;

                	try {
                		insert fi;
                	} catch (Exception e) {
                		isExceptionThrown = true;
                	}

                	system.assertEquals(false, isExceptionThrown);


                	// #2, NO hashtags but attached to another object than an account
                        // ######## not working on Contact as the feedtracking is not enabled #######
                        /*
                	fi = new FeedItem(ParentId = con.Id, Body = 'body with NO hashtags');

                	isExceptionThrown = false;

                	try {
                		insert fi;
                	} catch (Exception e) {
                		isExceptionThrown = true;
                	}

                	system.assertEquals(false, isExceptionThrown);*/


                test.stopTest();
	}
	
}