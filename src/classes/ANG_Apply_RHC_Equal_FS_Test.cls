@isTest
private class ANG_Apply_RHC_Equal_FS_Test {

	@testSetup
	static void setup() {
		List<AMS_Settlement_System__c> settlements = new List<AMS_Settlement_System__c>();

		AMS_Settlement_System__c settlementRevert = new AMS_Settlement_System__c(Name = 'BSP-AA',
																		   		 RecordTypeId = AMS_Utils.RECTYPE_BSP,
																		   		 ANG_RHC_Amount_Equals_FS__c = true);

		AMS_Settlement_System__c settlementApply = new AMS_Settlement_System__c(Name = 'BSP-BB',
																		   		RecordTypeId = AMS_Utils.RECTYPE_BSP,
																		   		ANG_RHC_Amount_Equals_FS__c = false);
		settlements.add(settlementRevert);
		settlements.add(settlementApply);
		insert settlements;

		List<IATA_ISO_Country__c> countries = new List<IATA_ISO_Country__c>();

		IATA_ISO_Country__c countryAA = new IATA_ISO_Country__c (Name = 'AA', 
																 ISO_Code__c = 'AA',
																 AMS_Settlement_System__c = settlementRevert.Id,
																 ANG_Enable_NewGen__c = true);

		IATA_ISO_Country__c countryBB = new IATA_ISO_Country__c (Name = 'BB', 
																 ISO_Code__c = 'BB',
																 AMS_Settlement_System__c = settlementApply.Id,
																 ANG_Enable_NewGen__c = true);
		countries.add(countryAA);
		countries.add(countryBB);
        insert countries;

        List<Account> agencies = new List<Account>();

        Account agencyRevertBSP = new Account(Name = 'AgencyRevertBSP',
        							 Status__c = AMS_Utils.ACC_S9_APPROVED,
        							 Location_Type__c = 'HE',
        							 RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
        							 IATA_ISO_Country__c = countryBB.Id,
        							 Location_Class__c = 'P',
        							 Remittance_frequency__c = 'M');

        Account agencyApplyBSP = new Account(Name = 'AgencyApplyBSP',
        							 Status__c = AMS_Utils.ACC_S9_APPROVED,
        							 Location_Type__c = 'HE',
        							 RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
        							 IATA_ISO_Country__c = countryBB.Id,
        							 Location_Class__c = 'P',
        							 Remittance_frequency__c = 'M');

        Account agencyRevertIATA = new Account(Name = 'AgencyRevertIATA',
        							 Status__c = AMS_Utils.ACC_S9_APPROVED,
        							 Location_Type__c = 'HE',
        							 RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
        							 IATA_ISO_Country__c = countryAA.Id,
        							 Location_Class__c = 'P',
        							 Remittance_frequency__c = 'M',
        							 IataCode__c = '22222222');

        Account agencyApplyIATA = new Account(Name = 'AgencyApplyIATA',
        							 Status__c = AMS_Utils.ACC_S9_APPROVED,
        							 Location_Type__c = 'HE',
        							 RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
        							 IATA_ISO_Country__c = countryAA.Id,
        							 Location_Class__c = 'P',
        							 Remittance_frequency__c = 'M',
        							 IataCode__c = '11111111');
        agencies.add(agencyRevertBSP);
        agencies.add(agencyApplyBSP);
        agencies.add(agencyRevertIATA);
        agencies.add(agencyApplyIATA);
        insert agencies;

        List<ANG_RHC_Information__c> rhcInfos = new List<ANG_RHC_Information__c>();

        ANG_RHC_Information__c rhcInfoToRevertBSP = new ANG_RHC_Information__c(ANG_AccountId__c = agencyRevertBSP.Id,
																			   CurrencyIsoCode = 'USD',
																			   RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
																			   ANG_Financial_Security__c = 0,
																			   ANG_RHC_Amount_Equals_FS__c = true,
																			   ANG_RHC_Amount__c = 15,
																			   ANG_RME_Amount__c = 100);

        ANG_RHC_Information__c rhcInfoToApplyBSP = new ANG_RHC_Information__c(ANG_AccountId__c = agencyApplyBSP.Id,
																			  CurrencyIsoCode = 'USD',
																			  RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
																			  ANG_Financial_Security__c = 0,
																			  ANG_RHC_Amount_Equals_FS__c = false,
																			  ANG_RHC_Amount__c = 15,
																			  ANG_RME_Amount__c = 100);

        ANG_RHC_Information__c rhcInfoToRevertIATA = new ANG_RHC_Information__c(ANG_AccountId__c = agencyRevertIATA.Id,
																				CurrencyIsoCode = 'USD',
																				RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
																				ANG_Financial_Security__c = 0,
																				ANG_RHC_Amount_Equals_FS__c = true,
																				ANG_RHC_Amount__c = 15,
																				ANG_RME_Amount__c = 100);

        ANG_RHC_Information__c rhcInfoToApplyIATA = new ANG_RHC_Information__c(ANG_AccountId__c = agencyApplyIATA.Id,
																			   CurrencyIsoCode = 'USD',
																			   RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
																			   ANG_Financial_Security__c = 0,
																			   ANG_RHC_Amount_Equals_FS__c = false,
																			   ANG_RHC_Amount__c = 15,
																			   ANG_RME_Amount__c = 100);
        rhcInfos.add(rhcInfoToRevertBSP);
        rhcInfos.add(rhcInfoToApplyBSP);
        rhcInfos.add(rhcInfoToRevertIATA);
        rhcInfos.add(rhcInfoToApplyIATA);
		insert rhcInfos;
	}
	
	@isTest static void revertRHC_BSP() {
		// Revert RHC
		Test.startTest();

		ANG_Apply_RHC_Equal_FS_Controller controller = new ANG_Apply_RHC_Equal_FS_Controller();
		controller.setModeValue('BSP');
		controller.setActionValue('Revert_RHC');
		controller.setBspValue('BSP-AA');
		controller.fetchAgencies();
		controller.applyOrRevertRHC();
		controller.getBatchStatus();

		Test.stopTest();

		for (ANG_RHC_Information__c rhcInformation: [SELECT Id, ANG_RHC_Amount__c, ANG_RME_Amount__c, ANG_Financial_Security__c
										  			  FROM ANG_RHC_Information__c
													  WHERE ANG_AccountId__r.IATA_ISO_Country__r.AMS_Settlement_System__r.Name = 'BSP-AA']) {
			System.assertEquals(rhcInformation.ANG_RHC_Amount__c, rhcInformation.ANG_RME_Amount__c + rhcInformation.ANG_Financial_Security__c);
		}
	}

	@isTest static void applyRHC_BSP() {
		// Apply RHC
		Test.startTest();
		
		ANG_Apply_RHC_Equal_FS_Controller controller = new ANG_Apply_RHC_Equal_FS_Controller();
		controller.setModeValue('BSP');
		controller.setActionValue('Apply_RHC');
		controller.setBspValue('BSP-BB');
		controller.fetchAgencies();
		controller.applyOrRevertRHC();
		controller.getBatchStatus();

		controller.first();
		controller.last();
		controller.next();
		controller.previous();
		controller.refreshPageSize();

		Test.stopTest();

		for (ANG_RHC_Information__c rhcInformation: [SELECT Id, ANG_Financial_Security__c, ANG_RHC_Amount__c
										  			  FROM ANG_RHC_Information__c
													  WHERE ANG_AccountId__r.IATA_ISO_Country__r.AMS_Settlement_System__r.Name = 'BSP-BB']) {
			System.assertEquals(rhcInformation.ANG_Financial_Security__c, rhcInformation.ANG_RHC_Amount__c);
		}
	}
	
	@isTest static void revertRHC_IATACode() {
		//Revert RHC
		Test.startTest();

		ANG_Apply_RHC_Equal_FS_Controller controller = new ANG_Apply_RHC_Equal_FS_Controller();
		controller.setModeValue('IATA_Code');
		controller.setActionValue('Revert_RHC');
		controller.setIataCode('22222222');
		controller.fetchAgencies();
		controller.applyOrRevertRHC();

		Test.stopTest();

		ANG_RHC_Information__c rhcInfo = [SELECT Id, ANG_RHC_Amount__c, ANG_RME_Amount__c
										  FROM ANG_RHC_Information__c
										  WHERE ANG_AccountId__r.Name = 'AgencyRevertIATA'];

		System.assertEquals(rhcInfo.ANG_RME_Amount__c, rhcInfo.ANG_RHC_Amount__c);
	}

	@isTest static void applyRHC_IATACode() {
		// Apply RHC
		ANG_RHC_Information__c rhcInfoBefore = [SELECT Id, ANG_RHC_Amount_Equals_FS__c 
										  FROM ANG_RHC_Information__c
										  WHERE ANG_AccountId__r.Name = 'AgencyApplyIATA'];

		Test.startTest();

		ANG_Apply_RHC_Equal_FS_Controller controller = new ANG_Apply_RHC_Equal_FS_Controller();
		controller.setModeValue('IATA_Code');
		controller.setActionValue('Apply_RHC');
		controller.setIataCode('11111112');
		controller.fetchAgencies();
		controller.setIataCode('11111111');
		controller.fetchAgencies();
		controller.applyOrRevertRHC();

		Test.stopTest();

		ANG_RHC_Information__c rhcInfo = [SELECT Id, ANG_Financial_Security__c, ANG_RHC_Amount__c, ANG_RHC_Amount_Equals_FS__c 
										  FROM ANG_RHC_Information__c
										  WHERE ANG_AccountId__r.Name = 'AgencyApplyIATA'];

		System.debug('rui:' + rhcInfo.ANG_RHC_Amount_Equals_FS__c);

		System.assertEquals(rhcInfo.ANG_Financial_Security__c, rhcInfo.ANG_RHC_Amount__c);
	}
	
}