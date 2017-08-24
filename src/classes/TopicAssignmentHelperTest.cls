@isTest
private class TopicAssignmentHelperTest {
	
	@isTest static void test_method_one() {
		// CREATE TEST DATA
        
        // create the custom setting values
        AMP_Account_Topics__c acceptedTopic = new AMP_Account_Topics__c(Name = 'Cargo');
        Insert acceptedTopic;

        // Create a new ISO Country
        IATA_ISO_Country__c country_qr = new IATA_ISO_Country__c(Name = 'Qatar', ISO_Code__c = 'QR', Region__c = 'Africa & Middle East');
        insert country_qr;
        
        // Create an Airline HQ account, IATA Member
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');
        Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger', 
                                RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_qr.Id, Membership_status__c = 'IATA member');
        insert acct_hq;

        // Create an Standard account
        Id Std_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('Standard_Account');
        Account std_acct = new Account(Name = 'Agency', ICCS_Membership_Status__c = 'Member', Industry='General Sales Agent', Type='Agency', 
                                RecordTypeId = Std_RT_Id, IATA_ISO_Country__c = country_qr.Id, Reason_for_creation__c = 'testing');
        insert std_acct;

        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Contact').get('Standard_Contact');
        Contact con =new contact(firstname = 'Name', lastname = 'pluto', phone = '123', accountid = acct_hq.id, email = 'asd.arg@wewt.et', RecordTypeId = ContactStd_RT_Id);
        insert con;


        test.startTest();
        	// Test for errors raised

        	FeedItem fi = new FeedItem(ParentId = acct_hq.Id, Body = 'post with unlisted topic #[Cargo Operations]');

        	Boolean isExceptionThrown = false;

        	try {
        		insert fi;
        	} catch (Exception e) {
        		isExceptionThrown = true;
        	}

        	system.assertEquals(true, isExceptionThrown);


        	// Test for no errors raised
        	// #1 , accepted topic used

        	fi = new FeedItem(ParentId = acct_hq.Id, Body = 'post w acceptable topic #[Cargo]');

        	isExceptionThrown = false;

        	try {
        		insert fi;
        	} catch (Exception e) {
        		isExceptionThrown = true;
        	}

        	system.assertEquals(false, isExceptionThrown);


            // ######## not working on Contact as the feedtracking is not enabled #######
        	// #2, not an accepptable topic, but attached to another object than an account
            /*
        	fi = new FeedItem(ParentId = con.Id, Body = 'Post with #[Unlisted Topic]');

        	isExceptionThrown = false;

        	try {
        		insert fi;
        	} catch (Exception e) {
        		isExceptionThrown = true;
        	}

        	system.assertEquals(false, isExceptionThrown);
            */

            // #3, not an accepptable topic, but attached to a non-airline HQ account
            fi = new FeedItem(ParentId = std_acct.Id, Body = 'Post with #[Unlisted Topic]');

            isExceptionThrown = false;

            try {
                insert fi;
            } catch (Exception e) {
                isExceptionThrown = true;
            }

            system.assertEquals(false, isExceptionThrown);



    	test.stopTest();
	}
}