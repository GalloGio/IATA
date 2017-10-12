@isTest
private class ang_rhcAlertTriggerHandler_test {

	@testSetup static void setup(){
		user u=[select id from user where id =:UserInfo.getUserId()];
		system.runAs(u){
			EmailTemplate emailTemplate = new EmailTemplate(
	            isActive = true,
	            Name = 'emailTemplate',
	            DeveloperName = 'emailTemplate',
	            TemplateType = 'text',
	            FolderId = UserInfo.getUserId()
	            );
	        insert emailTemplate;
	    }
        

  // Create a new ISO Country
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR', BSP_Country_free_text__c = 'FR');
        insert country;
        
        Account a = new Account(
        	name='acc1',
			Location_Type__c='HE',
			Location_Class__c='P',
			Remittance_frequency__c='Monthly',
			ANG_Accreditation_Model__c ='Cash',
			IATA_ISO_Country__c = country.id,
        	RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency')
        );
        insert a;        

        Contact contact = new Contact(
        	FirstName='test',
        	LastName='test', 
        	AccountId=a.Id,
			User_Portal_Status__c = 'Approved Admin',
			email = 'testiata@yopmail.com'
			);
		insert contact;
        
        // Create a new Financial Institution
        Financial_Institution__c fi = new Financial_Institution__c(
        	Name = 'Test', 
        	Region__c = 'Europe', 
        	Country__c = 'Portugal', 
        	Institution_Type__c = 'Bank'
        );
        insert fi;
        
        // create a reception case
        Case c = new Case(
        		Subject = 'rception case', 
        		AccountId = a.Id, 
        		Status = 'Open', 
                RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('InternalCasesEuropeSCE') 
        );
        insert c;
                
       
       ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
        	ANG_AccountId__c =a.id,
        	CurrencyIsoCode ='USD',
        	RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
        	ANG_Financial_Security__c=0
        );
        insert rhcInfo;

         Financial_Security__c fs = new Financial_Security__c(
        	Region__c = 'Europe', 
        	Security_status__c = 'Active', 
        	Account__c = a.Id, 
        	CurrencyIsoCode = 'EUR', 
        	Security_Type__c='CCG',
        	Amount__c = 100,
            Expiry_date__c = Date.today().addYears(2), 
            Financial_Institution__c = fi.Id,
            Validity_Start_Date__c = Date.today().addDays(-2), 
            Reception_Case__c = c.Id, 
            Reception_Date__c = Date.today(), 
            Reasonforrequest__c = 'New Application'
        );
        insert fs;
       


        ANG_RHC_Alert_Templates__c rat = new ANG_RHC_Alert_Templates__c(
        	name='not50percentTemplate',
        	ang_direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP,
        	ANG_language__c='English',
        	ANG_percentage__c='50%',
        	ANG_template_api__c='emailTemplate'       
        	);

        insert rat;


        
       

	}



	private static testmethod void testRiskAlertCreationSendingEmailWithSuccess(){

		ANG_RHC_Information__c rhcInfo=[select id,ANG_AccountId__c from ANG_RHC_Information__c limit 1];
		ANG_Risk_Alert__c ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c =rhcInfo.id,
			ANG_Account__c =rhcInfo.ANG_AccountId__c,
			ANG_Direction__c=ANG_RHCHelper.RISK_ALERT_DIRECTION_UP,
			ANG_Threshold_Level__c='50%'
		);

		test.StartTest();
			insert ara;
		test.StopTest();

		system.assertEquals([select id,ANG_email_sent__c from ANG_Risk_Alert__c limit 1].get(0).ANG_email_sent__c,true,'Email was not sent');

	}

	private static testmethod void testRiskAlertCreationNoConfigurationMatched(){

		ANG_RHC_Information__c rhcInfo=[select id,ANG_AccountId__c from ANG_RHC_Information__c limit 1];
		ANG_Risk_Alert__c ara = new ANG_Risk_Alert__c(
			ANG_RHC_Information__c =rhcInfo.id,
			ANG_Account__c =rhcInfo.ANG_AccountId__c,
			ANG_Direction__c=ANG_RHCHelper.RISK_ALERT_DIRECTION_UP,
			ANG_Threshold_Level__c='88%' // no configuration exists with this percentage
		);

		test.StartTest();
			insert ara;
		test.StopTest();

		system.assertEquals([select id,ANG_email_sent__c from ANG_Risk_Alert__c limit 1].get(0).ANG_email_sent__c,false,'Email was not sent');

	}

	private static testmethod void testTicketingAuthorityRemoval(){

    	Account a = [Select Id, Remittance_frequency__c from Account limit 1];
    	System.debug('##Account: '+ a.Remittance_frequency__c);
		ANG_Risk_Alert__c ra = new ANG_Risk_Alert__c(
			Recordtypeid=Schema.SObjectType.ANG_Risk_Alert__c.getRecordTypeInfosByName().get('Risk Alert RTS').getRecordTypeId(),
			ang_Severity__c='Red',
			ANG_Account__c = a.Id
		);

		AMS_Settlement_System__c iss = new AMS_Settlement_System__c(Name = 'BSP-FR');
		insert iss;
		operational_Calendar__c op = new operational_Calendar__c( ISS_Operation__c = iss.id, 
			First_Day__c = Date.today(), Last_Day__c = Date.today(), Frequency_code__c = 'M', Remittance_Day__c = Date.today() );
		insert op;
		
		Contact con = new Contact(LastName = 'ttt', Accountid = a.id);
		insert con;
				
		test.StartTest();
			insert ra;
		test.StopTest();
		List<Case> c = [Select Id From Case Where AccountId = :a.Id and RecordType.Name='SIDRA Lite' limit 1];
		System.assertEquals(c.size(), 1, 'Sidra lite case was not created');
		List<ISSP_Web_Service_Log__c> logs = [Select Id From ISSP_Web_Service_Log__c where Case__c = :c.get(0).Id];
		System.assertEquals(logs.size(), 1, 'Response was not saved');

	}

}