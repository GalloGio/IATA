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

		//NOW FOR HK
		AMS_Settlement_System__c settlementHK = new AMS_Settlement_System__c(Name = 'BSP-HK',
																		   		 RecordTypeId = AMS_Utils.RECTYPE_BSP,
																		   		 ANG_RHC_Amount_Equals_FS__c = false);

		/*AMS_Settlement_System__c settlementApplyHK = new AMS_Settlement_System__c(Name = 'BSP-HK',
																		   		RecordTypeId = AMS_Utils.RECTYPE_BSP,
																		   		ANG_RHC_Amount_Equals_FS__c = false);
		*/
		settlements.add(settlementHK);
		//settlements.add(settlementApplyHK);
		insert settlements;


		list<ANG_BSP_Attributes__c> attributes = new list<ANG_BSP_Attributes__c>();
		for(AMS_Settlement_System__c bsp: settlements){
			
			if(bsp.ANG_RHC_Amount_Equals_FS__c){
				attributes.add(new ANG_BSP_Attributes__c(BSP__c = bsp.Id, Risk_Status__c='A', RHC_Amnt_Calc_Type__c='Fixed Percentage', RecordTypeId = ANG_Apply_RHC_Equal_FS_Controller.RHCConfRT, Min_FA_Points__c =0, Max_FA_Points__c=999999,FS_Percentage__c=100 ));                                       
				attributes.add(new ANG_BSP_Attributes__c(BSP__c = bsp.Id, Risk_Status__c='B', RHC_Amnt_Calc_Type__c='Fixed Percentage', RecordTypeId = ANG_Apply_RHC_Equal_FS_Controller.RHCConfRT, Min_FA_Points__c =0, Max_FA_Points__c=999999,FS_Percentage__c=100 ));
				attributes.add(new ANG_BSP_Attributes__c(BSP__c = bsp.Id, Risk_Status__c='C', RHC_Amnt_Calc_Type__c='Fixed Percentage', RecordTypeId = ANG_Apply_RHC_Equal_FS_Controller.RHCConfRT, Min_FA_Points__c =0, Max_FA_Points__c=999999,FS_Percentage__c=100 ));
			}
			else{	
				attributes.add(new ANG_BSP_Attributes__c(BSP__c = bsp.Id, Risk_Status__c='A', RHC_Amnt_Calc_Type__c='Formula', RecordTypeId = ANG_Apply_RHC_Equal_FS_Controller.RHCConfRT));
				attributes.add(new ANG_BSP_Attributes__c(BSP__c = bsp.Id, Risk_Status__c='B', RHC_Amnt_Calc_Type__c='Formula', RecordTypeId = ANG_Apply_RHC_Equal_FS_Controller.RHCConfRT));
				attributes.add(new ANG_BSP_Attributes__c(BSP__c = bsp.Id, Risk_Status__c='C', RHC_Amnt_Calc_Type__c='Formula', RecordTypeId = ANG_Apply_RHC_Equal_FS_Controller.RHCConfRT));
			}
			
			attributes.add(new ANG_BSP_Attributes__c(BSP__c = bsp.Id, FS_Percentage__c=100, Limit_Cash_Condition__c=true, RecordTypeId = ANG_Apply_RHC_Equal_FS_Controller.CCConfRT));
			
		}

		insert attributes;


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
		

		//NOW FOR HK

		IATA_ISO_Country__c countryHK = new IATA_ISO_Country__c (Name = 'HK', 
																 ISO_Code__c = 'HK',
																 AMS_Settlement_System__c = settlementHK.Id,
																 ANG_Enable_NewGen__c = true);


		countries.add(countryHK);


        insert countries;

        List<Account> agencies = new List<Account>();

        Account agency1 = new Account(Name = 'agency1',
        							 Status__c = AMS_Utils.ACC_S9_APPROVED,
        							 Location_Type__c = 'HE',
        							 RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
        							 IATA_ISO_Country__c = countryBB.Id,
        							 Location_Class__c = 'P',
        							 IATACode__c = '11111111',
        							 Remittance_frequency__c = 'M',
        							 ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH);

        Account agency2 = new Account(Name = 'agency2',
        							 Status__c = AMS_Utils.ACC_S9_APPROVED,
        							 Location_Type__c = 'HE',
        							 RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
        							 IATA_ISO_Country__c = countryAA.Id,
        							 Location_Class__c = 'P',
        							 IATACode__c = '22222222',
        							 Remittance_frequency__c = 'M',
        							 ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH);

        agencies.add(agency1);
        agencies.add(agency2);
		

		//NOW FOR HK
        Account agency1HK = new Account(Name = 'agency3',
        							 Status__c = AMS_Utils.ACC_S9_APPROVED,
        							 Location_Type__c = 'HE',
        							 RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
        							 IATA_ISO_Country__c = countryHK.Id,
        							 Location_Class__c = 'P',
        							 IATACode__c = '33333333',
        							 Remittance_frequency__c = 'M',
        							 ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH);

        Account agency2HK = new Account(Name = 'agency4',
        							 Status__c = AMS_Utils.ACC_S9_APPROVED,
        							 Location_Type__c = 'HE',
        							 RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
        							 IATA_ISO_Country__c = countryHK.Id,
        							 Location_Class__c = 'P',
        							 IATACode__c = '44444444',
        							 Remittance_frequency__c = 'M',
        							 ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH);

        agencies.add(agency1HK);
        agencies.add(agency2HK);

        insert agencies;

        List<ANG_RHC_Information__c> rhcInfos = new List<ANG_RHC_Information__c>();

        ANG_RHC_Information__c rhc1 = new ANG_RHC_Information__c(ANG_AccountId__c = agency1.Id,
																			   CurrencyIsoCode = 'USD',
																			   RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
																			   ANG_Financial_Security__c = 0,
																			   ANG_RHC_Amount_Equals_FS__c = false,
																			   ANG_RHC_Amount__c = 15,
																			   ANG_RME_Amount__c = 100);

        ANG_RHC_Information__c rhc2 = new ANG_RHC_Information__c(ANG_AccountId__c = agency2.Id,
																			   CurrencyIsoCode = 'USD',
																			   RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
																			   ANG_Financial_Security__c = 0,
																			   ANG_RHC_Amount_Equals_FS__c = true,
																			   ANG_RHC_Amount__c = 15,
																			   ANG_RME_Amount__c = 100);
        rhcInfos.add(rhc1);
        rhcInfos.add(rhc2);

        //NOW FOR THE HK ACCOUNTS
        ANG_RHC_Information__c rhc1HK = new ANG_RHC_Information__c(ANG_AccountId__c = agency1HK.Id,
																			   CurrencyIsoCode = 'USD',
																			   RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
																			   ANG_Financial_Security__c = 0,
																			   ANG_RHC_Amount_Equals_FS__c = false,
																			   ANG_RHC_Amount__c = 15,
																			   ANG_RME_Amount__c = 100);

        ANG_RHC_Information__c rhc2HK = new ANG_RHC_Information__c(ANG_AccountId__c = agency2HK.Id,
																			   CurrencyIsoCode = 'USD',
																			   RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
																			   ANG_Financial_Security__c = 0,
																			   ANG_RHC_Amount_Equals_FS__c = true,
																			   ANG_RHC_Amount__c = 15,
																			   ANG_RME_Amount__c = 100);
        rhcInfos.add(rhc1HK);
        rhcInfos.add(rhc2HK);

		insert rhcInfos;
	}
	
	/*@isTest static void revertRHC_BSP() {
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
	}*/
	
	@isTest static void revertRHC_IATACode() {
		//Revert RHC
		Test.startTest();

		ANG_Apply_RHC_Equal_FS_Controller controller = new ANG_Apply_RHC_Equal_FS_Controller();
		controller.setModeValue('IATA_Code');
		controller.setActionValue('Revert_RHC_regardless');
		controller.setIataCode('22222222');
		controller.fetchAgencies();
		controller.applyOrRevertRHC();

		Test.stopTest();

		ANG_RHC_Information__c rhcInfo = [SELECT Id, ANG_RHC_Amount__c, ANG_RME_Amount__c,ANG_RHC_Amount_Equals_FS__c,RHC_Amount_Equals_FS_Percent__c
										  FROM ANG_RHC_Information__c
										  WHERE ANG_AccountId__r.Name = 'agency2'];


		System.assertEquals(rhcInfo.ANG_RHC_Amount_Equals_FS__c, false);
		System.assertEquals(rhcInfo.RHC_Amount_Equals_FS_Percent__c, null);

		//System.assertEquals(rhcInfo.ANG_RME_Amount__c, rhcInfo.ANG_RHC_Amount__c);
	}

	@isTest static void applyRHC_IATACode() {

		ANG_RHC_Information__c rhcInfoBefore = [SELECT Id, ANG_RHC_Amount_Equals_FS__c 
										  FROM ANG_RHC_Information__c
										  WHERE ANG_AccountId__r.Name = 'agency1'];

		Test.startTest();

		ANG_Apply_RHC_Equal_FS_Controller controller = new ANG_Apply_RHC_Equal_FS_Controller();
		controller.setActionValue('Apply_RHC_regardless');
		controller.setModeValue('IATA_Code');
		controller.setIataCode('11111112');
		controller.fetchAgencies();
		controller.setIataCode('11111111');
		controller.setPercentageFS('100');
		controller.fetchAgencies();
		controller.applyOrRevertRHC();

		Test.stopTest();

		ANG_RHC_Information__c rhcInfo = [SELECT Id, ANG_Financial_Security__c, ANG_RHC_Amount__c, ANG_RHC_Amount_Equals_FS__c,RHC_Amount_Equals_FS_Percent__c 
										  FROM ANG_RHC_Information__c
										  WHERE ANG_AccountId__r.Name = 'agency1'];

		System.assertEquals(rhcInfo.ANG_RHC_Amount_Equals_FS__c, true);
		System.assertEquals(rhcInfo.RHC_Amount_Equals_FS_Percent__c, 100);
		//System.assertEquals(rhcInfo.ANG_Financial_Security__c, rhcInfo.ANG_RHC_Amount__c);
	}

	@isTest static void revertRHC_BSP_regardless() {
		
		Test.startTest();

		ANG_Apply_RHC_Equal_FS_Controller controller = new ANG_Apply_RHC_Equal_FS_Controller();
		controller.setModeValue('BSP');
		controller.setActionValue('Revert_RHC_regardless');
		controller.setBspValue('BSP-BB');
		controller.fetchAgencies();
		
		system.assert(!controller.hasAttributesToShow, 'Shouldn\'t have Attributes to show');
		system.assert(!controller.showCountrySpecificColumns, 'Shouldn\'t show the Columns for min in max points to this BSP');
		//system.assertEquals(controller.attributesToShow.size(), 3);

		controller.applyOrRevertRHC();

		Test.stopTest();

		list<ANG_BSP_Attributes__c> bsps = [SELECT ID,FS_Percentage__c,BSP__c,Max_FA_Points__c,Min_FA_Points__c, RHC_Amnt_Calc_Type__c, Remittance_Frequency__c,Risk_Status__c, UniqueKey__c, RecordTypeid FROM ANG_BSP_Attributes__c WHERE BSP__r.name = 'BSP-BB'];
		for (ANG_BSP_Attributes__c bsp: bsps){
			if(bsp.recordtypeid == ANG_Apply_RHC_Equal_FS_Controller.RHCConfRT){	
				system.assertEquals(bsp.RHC_Amnt_Calc_Type__c, 'Formula');
				system.assertEquals(bsp.FS_Percentage__c, null);
				system.assertEquals(bsp.Min_FA_Points__c, null);
				system.assertEquals(bsp.Max_FA_Points__c,null);
			}
			else
				system.assertEquals(bsp.FS_Percentage__c, 100);
		}


	}

	@isTest static void applyRHC_BSP_regardless() {

		Test.startTest();

		ANG_Apply_RHC_Equal_FS_Controller controller = new ANG_Apply_RHC_Equal_FS_Controller();
		controller.setActionValue('Apply_RHC_regardless');
		controller.setModeValue('BSP');
		controller.setBspValue('BSP-AA');
		controller.setPercentageFS('50');
		controller.fetchAgencies();

		controller.refreshPageSize();
		controller.next();
		controller.previous();
		controller.last();
		controller.first();

		controller.applyOrRevertRHC();

		Test.stopTest();

		list<ANG_BSP_Attributes__c> bsps = [SELECT ID,FS_Percentage__c,BSP__c,Max_FA_Points__c,Min_FA_Points__c, RHC_Amnt_Calc_Type__c, Remittance_Frequency__c,Risk_Status__c, UniqueKey__c, RecordTypeid FROM ANG_BSP_Attributes__c WHERE BSP__r.name = 'BSP-AA'];
		for (ANG_BSP_Attributes__c bsp: bsps){
			if(bsp.recordtypeid == ANG_Apply_RHC_Equal_FS_Controller.RHCConfRT){	
				system.assertEquals(bsp.RHC_Amnt_Calc_Type__c, 'Fixed Percentage');
				system.assertEquals(bsp.FS_Percentage__c, 50);
				system.assertEquals(bsp.Min_FA_Points__c, 0);
				system.assertEquals(bsp.Max_FA_Points__c,999999);
			}
			else
				system.assertEquals(bsp.FS_Percentage__c, 50);
		}
	}

	//for country specifics

	@isTest static void applyRHC_BSP_per_RISK_for_HK() {

		Test.startTest();

		ANG_Apply_RHC_Equal_FS_Controller controller = new ANG_Apply_RHC_Equal_FS_Controller();
		controller.setActionValue('Apply_RHC_per_RS');
		controller.setModeValue('BSP');
		controller.setBspValue('BSP-HK');
		controller.fetchAgencies();
		controller.setPercentageFS('50');

		///FOR increase code coverage
		system.assert(controller.renderConfirmButton, 'Should be available now');
		system.assert(controller.hasAttributesToShow, 'Should have Attributes to show');
		system.assert(controller.showCountrySpecificColumns, 'Should show the Columns for min in max points to this BSP');
		system.assert(controller.showCountrySpecificColumns, 'Should show the Columns for min in max points to this BSP');
		
		system.assert(!controller.hasNext, 'Should only find one account and for that, only one page');
		system.assert(!controller.hasPrevious, 'Should only find one account and for that, only one page');
		system.assert(controller.isValidPercentageFS, 'Should be a valid percentageFS');


		for(ANG_BSP_Attributes__c bsptoChange: controller.attributesToShow){
			bsptoChange.Min_FA_Points__c = 0;
			bsptoChange.Max_FA_Points__c = 20;
			bsptoChange.FS_Percentage__c = 21;
		}

		controller.applyOrRevertRHC();


		list<ANG_BSP_Attributes__c> bsps = [SELECT ID,FS_Percentage__c,BSP__c,Max_FA_Points__c,Min_FA_Points__c, RHC_Amnt_Calc_Type__c, Remittance_Frequency__c,Risk_Status__c, UniqueKey__c, RecordTypeid FROM ANG_BSP_Attributes__c WHERE BSP__r.name = 'BSP-HK'];
		for (ANG_BSP_Attributes__c bsp: bsps){
			if(bsp.recordtypeid == ANG_Apply_RHC_Equal_FS_Controller.RHCConfRT){	
				system.assertEquals(bsp.RHC_Amnt_Calc_Type__c, 'Fixed Percentage');
				system.assertEquals(bsp.FS_Percentage__c, 21);
				system.assertEquals(bsp.Min_FA_Points__c, 0);
				system.assertEquals(bsp.Max_FA_Points__c,20);
			}
			else
				system.assertEquals(bsp.FS_Percentage__c, 50);
		}
	
		//NOW REVERT


		controller.setModeValue('BSP');
		controller.setActionValue('Revert_RHC_per_RS');
		controller.setBspValue('BSP-HK');
		controller.fetchAgencies();
		
		//system.assertEquals(controller.attributesToShow.size(), 3);

		controller.applyOrRevertRHC();


		bsps = [SELECT ID,FS_Percentage__c,BSP__c,Max_FA_Points__c,Min_FA_Points__c, RHC_Amnt_Calc_Type__c, Remittance_Frequency__c,Risk_Status__c, UniqueKey__c, RecordTypeid FROM ANG_BSP_Attributes__c WHERE BSP__r.name = 'BSP-HK'];
		for (ANG_BSP_Attributes__c bsp: bsps){
			if(bsp.recordtypeid == ANG_Apply_RHC_Equal_FS_Controller.RHCConfRT){	
				system.assertEquals(bsp.RHC_Amnt_Calc_Type__c, 'Formula');
				system.assertEquals(bsp.FS_Percentage__c, null);
				system.assertEquals(bsp.Min_FA_Points__c, null);
				system.assertEquals(bsp.Max_FA_Points__c,null);
			}
			else
				system.assertEquals(bsp.FS_Percentage__c, 100);
		}

		Test.stopTest();

	}
	
}