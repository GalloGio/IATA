@isTest
private class ANG_RiskAlertPurgeTest {
	
	private static Boolean includeRTS = false;

	static {
		//initilize static variables
	}

	@testSetup static void createData() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;
				
		// Create an Airline HQ account
		Account a = new Account(
			Name = 'acc1',
			Location_Type__c = 'HE',
			Location_Class__c = 'P',
			Remittance_frequency__c = 'M',
			ANG_Accreditation_Model__c = 'Cash',
			IATA_ISO_Country__c = ctry.Id,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeID('Account', 'IATA_Agency')
		);
		insert a;

		ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
			ANG_AccountId__c = a.Id,
			CurrencyIsoCode = 'USD',
			RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
			ANG_Financial_Security__c = 0,
			ANG_ConsumedRHC__c = 10,
			ANG_RHC_Amount__c = 10,
			ANG_ConsumedRHC_Percent__c = 10
		);
		insert rhcInfo;

		List<ANG_Risk_Alert__c> riskAlerts = new List<ANG_Risk_Alert__c>();
		riskAlerts.add(new ANG_Risk_Alert__c(RecordTypeId = ANG_RHCHelper.RECTYPE_RISKALERT_RHC, ANG_RHC_Information__c = rhcInfo.Id, ANG_Account__c = a.Id, ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP, ANG_Threshold_Level__c = '50%', ANG_RME_Last_Update__c = System.now().addDays(-20)));
		riskAlerts.add(new ANG_Risk_Alert__c(RecordTypeId = ANG_RHCHelper.RECTYPE_RISKALERT_RHC, ANG_RHC_Information__c = rhcInfo.Id, ANG_Account__c = a.Id, ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP, ANG_Threshold_Level__c = '50%', ANG_RME_Last_Update__c = System.now().addDays(-370)));
		if(includeRTS){
			riskAlerts.add(new ANG_Risk_Alert__c(RecordTypeId = ANG_RHCHelper.RECTYPE_RISKALERT_RTS, ANG_RHC_Information__c = rhcInfo.Id, ANG_Account__c = a.Id, ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP, ANG_Threshold_Level__c = '50%', ANG_RME_Last_Update__c = System.now().addDays(-20)));
			riskAlerts.add(new ANG_Risk_Alert__c(RecordTypeId = ANG_RHCHelper.RECTYPE_RISKALERT_RTS, ANG_RHC_Information__c = rhcInfo.Id, ANG_Account__c = a.Id, ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP, ANG_Threshold_Level__c = '50%', ANG_RME_Last_Update__c = System.now().addDays(-370)));
		}
		insert riskAlerts;
	}
	
	static testMethod void test_batch() {
		System.assertEquals((includeRTS ? 4 : 2), [SELECT Id FROM ANG_Risk_Alert__c].size());

		Test.startTest();

		ANG_RiskAlertPurge purger = new ANG_RiskAlertPurge();
		purger.schedule(System.now().addMinutes(30), 'Testing');
		purger.execute(null);

		Test.stopTest();

		System.assertEquals((includeRTS ? 3 : 1), [SELECT Id FROM ANG_Risk_Alert__c].size());
	}
	
}
