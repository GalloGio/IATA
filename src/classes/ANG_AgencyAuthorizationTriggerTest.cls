@isTest
private class ANG_AgencyAuthorizationTriggerTest {
	
	@testSetup static void setup(){

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HE',Name='Test1 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');
        
        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='HE',Name='Test2 Agency OK',Short_Name__c='Test2 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');
        
        insert a2;
	}

	@isTest static void testTriggerValidationOnInsert() {

		List<Account> accts = [select Id from Account ];

        List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();
        
        ID BSPLinkRT = AMS_Utils.getId('Agency_Authorization__c','BSPLink');

		ID FormOfPaymentRT = AMS_Utils.getId('Agency_Authorization__c','FormOfPayment');

		Account acct1 = accts.get(0);

    	authorizations.add(new Agency_Authorization__c(Account__c = acct1.Id, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
    	authorizations.add(new Agency_Authorization__c(Account__c = acct1.Id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
    	authorizations.add(new Agency_Authorization__c(Account__c = acct1.Id, ANG_FormOfPayment_ID__c = 'EP', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));

		insert authorizations;

		// should be ok. Then if we insert any authorization with the same Recordt Type / Form of payment, should be kicking an error, both on Insert and Update.

		authorizations = new List<Agency_Authorization__c>();

		authorizations.add(new Agency_Authorization__c(Account__c = acct1.Id, ANG_FormOfPayment_ID__c = 'EP', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
		authorizations.add(new Agency_Authorization__c(Account__c = acct1.Id, ANG_FormOfPayment_ID__c = 'EP', Status__c = 'Active', RecordTypeId = BSPLinkRT));

		try{
			
			insert authorizations;

			System.assertEquals(true,false);

		}catch(Exception e){

			System.assertEquals(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, There is already an Agency Authorization with the same Type/FormOfPayment'),true);

		}

		List<Agency_Authorization__c> aaFromAccounts = [Select ID,Account__c,ANG_FormOfPayment_ID__c, RecordTypeId from Agency_Authorization__c];

		System.assertEquals(3,aaFromAccounts.size());

		authorizations = new List<Agency_Authorization__c>();

		authorizations.add(new Agency_Authorization__c(Account__c = acct1.Id, ANG_FormOfPayment_ID__c = 'EP', Status__c = 'Active', RecordTypeId = BSPLinkRT));

		insert authorizations;

		aaFromAccounts = [Select ID,Account__c,ANG_FormOfPayment_ID__c, RecordTypeId from Agency_Authorization__c];

		System.assertEquals(4,aaFromAccounts.size());


	}

	@isTest static void testTriggerValidationOnUpdate() {

		List<Account> accts = [select Id from Account ];

        List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();
        
        ID BSPLinkRT = AMS_Utils.getId('Agency_Authorization__c','BSPLink');

		ID FormOfPaymentRT = AMS_Utils.getId('Agency_Authorization__c','FormOfPayment');

		Account acct1 = accts.get(0);

    	authorizations.add(new Agency_Authorization__c(Account__c = acct1.Id, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
    	authorizations.add(new Agency_Authorization__c(Account__c = acct1.Id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
    	authorizations.add(new Agency_Authorization__c(Account__c = acct1.Id, ANG_FormOfPayment_ID__c = 'EP', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));

		insert authorizations;

		// should be ok. Then if we insert any authorization with the same Recordt Type / Form of payment, should be kicking an error, both on Insert and Update.

		authorizations = new List<Agency_Authorization__c>();

		authorizations.add(new Agency_Authorization__c(Account__c = acct1.Id, Status__c = 'Active', RecordTypeId = BSPLinkRT));

		insert authorizations;

		List<Agency_Authorization__c> aaFromAccountsBSPLink = [Select ID,Account__c,ANG_FormOfPayment_ID__c, RecordTypeId, Status__c from Agency_Authorization__c where RecordTypeId = :BSPLinkRT];

		System.assertEquals(1,aaFromAccountsBSPLink.size());

		try{
			
			Agency_Authorization__c aa = aaFromAccountsBSPLink.get(0);

			aa.RecordTypeId = FormOfPaymentRT;

			aa.ANG_FormOfPayment_ID__c = 'EP';

			update aa;

			System.assertEquals(true,false);

		}catch(Exception e){

			System.assertEquals(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, There is already an Agency Authorization with the same Type/FormOfPayment'),true);

		}

		Agency_Authorization__c aa = aaFromAccountsBSPLink.get(0);

		aa.RecordTypeId = FormOfPaymentRT;

		List<Agency_Authorization__c> aaFromAccountsFormOfPayment = [Select ID,Account__c,ANG_FormOfPayment_ID__c, RecordTypeId, Status__c from Agency_Authorization__c where RecordTypeId = :FormOfPaymentRT and ANG_FormOfPayment_ID__c = 'EP'];

		Agency_Authorization__c aa2 = aaFromAccountsFormOfPayment.get(0);

		aa2.RecordTypeId = BSPLinkRT;
		aa2.ANG_FormOfPayment_ID__c = null;


		authorizations = new List<Agency_Authorization__c>{aa,aa2};

		update authorizations;

		List<Agency_Authorization__c> aaFromAccounts = [Select ID,Account__c,ANG_FormOfPayment_ID__c, RecordTypeId from Agency_Authorization__c];

		System.assertEquals(4,aaFromAccounts.size());

		aaFromAccounts = [Select ID,Account__c,ANG_FormOfPayment_ID__c, RecordTypeId from Agency_Authorization__c where RecordTypeId = :FormOfPaymentRT];

		System.assertEquals(3,aaFromAccounts.size());
			
	}
	
	@isTest static void testTriggerValidationOnInsertMultipleAccounts() {

		List<Account> accts = [select Id from Account];

        List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();
        
        ID BSPLinkRT = AMS_Utils.getId('Agency_Authorization__c','BSPLink');

		ID FormOfPaymentRT = AMS_Utils.getId('Agency_Authorization__c','FormOfPayment');

		Account acct1 = accts.get(0);

    	authorizations.add(new Agency_Authorization__c(Account__c = acct1.Id, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
    	authorizations.add(new Agency_Authorization__c(Account__c = acct1.Id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
    	authorizations.add(new Agency_Authorization__c(Account__c = acct1.Id, ANG_FormOfPayment_ID__c = 'EP', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));

		Account acct2 = accts.get(1);

    	authorizations.add(new Agency_Authorization__c(Account__c = acct2.Id, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
    	authorizations.add(new Agency_Authorization__c(Account__c = acct2.Id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
    	authorizations.add(new Agency_Authorization__c(Account__c = acct2.Id, ANG_FormOfPayment_ID__c = 'EP', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));

		insert authorizations;

	}


}