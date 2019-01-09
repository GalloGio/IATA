/**
* Tests for class 
* ANG_EligibilityForNewMulticountryAgent
*/
@isTest
private class ANG_EligibilityForNewMCAgentTest {
	
	private static Id agencyRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

	@testSetup static void setup(){

		Id bspRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Settlement_System__c', 'BSP');

		AMS_Settlement_System__c bsp_pt = new AMS_Settlement_System__c(
			Name = 'BSP-PT',
			CurrencyIsoCode = 'EUR',
        	RecordtypeId = bspRecordTypeId,
        	BSP_Billing__c = 'PT',
        	DPC_System__c  ='Maestro',
        	DPC__c = 'Accelya',
        	Domestic_Only__c = false,
        	ANG_RHC_Amount_Equals_FS__c = false
		);

		AMS_Settlement_System__c bsp_gb = new AMS_Settlement_System__c(
			Name = 'BSP-GI',
			CurrencyIsoCode = 'GBP',
        	RecordtypeId = bspRecordTypeId,
        	BSP_Billing__c = 'GI',
        	DPC_System__c  ='Maestro',
        	DPC__c = 'Accelya',
        	Domestic_Only__c = false,
        	ANG_RHC_Amount_Equals_FS__c = false
		);

		AMS_Settlement_System__c bsp_fr = new AMS_Settlement_System__c(
			Name = 'BSP-FR',
			CurrencyIsoCode = 'EUR',
        	RecordtypeId = bspRecordTypeId,
        	BSP_Billing__c = 'FR',
        	DPC_System__c  ='Maestro',
        	DPC__c = 'Accelya',
        	Domestic_Only__c = false,
        	ANG_RHC_Amount_Equals_FS__c = false
		);

		List<AMS_Settlement_System__c> bspLst = new List<AMS_Settlement_System__c>{bsp_pt, bsp_gb, bsp_fr};

		insert bspLst;

        IATA_ISO_Country__c countryPT = new IATA_ISO_Country__c(
        	Name = 'Portugal',
        	ISO_Code__c = 'PT', 
        	Region__c = 'Europe', 
        	ANG_Enable_NewGen__c = true,
        	AMS_Settlement_System__c = bsp_pt.Id
        );

        IATA_ISO_Country__c countryGB = new IATA_ISO_Country__c(
        	Name = 'United Kingdom',
        	ISO_Code__c = 'GB', 
        	Region__c = 'Europe', 
        	ANG_Enable_NewGen__c = true,
        	AMS_Settlement_System__c = bsp_gb.Id
        );

 		IATA_ISO_Country__c countryFR = new IATA_ISO_Country__c(
        	Name = 'France',
        	ISO_Code__c = 'FR', 
        	Region__c = 'Europe', 
        	ANG_Enable_NewGen__c = true,
        	AMS_Settlement_System__c = bsp_fr.Id
        );

 		IATA_ISO_Country__c countryMC = new IATA_ISO_Country__c(
        	Name = 'Monaco',
        	ISO_Code__c = 'MC', 
        	Region__c = 'Europe', 
        	ANG_Enable_NewGen__c = true,
        	AMS_Settlement_System__c = bsp_fr.Id
        );

        List<IATA_ISO_Country__c> countryLst = new List<IATA_ISO_Country__c>{countryPT, countryGB, countryFR, countryMC};
		
		insert countryLst;

 		Account accountGE = new Account(
 			Name = 'GE Test Agency', 
 			RecordtypeId = agencyRecordTypeId,
            IATA_ISO_Country__c = countryFR.Id,
			Location_Type__c = 'GE',
            Location_Class__c = 'P',
            ANG_Accreditation_Model__c = 'Multicountry'
        );

        insert accountGE;

		Account accountHE = new Account(
        	Name='HE Test Agency', 
        	RecordtypeId = agencyRecordTypeId,
			IATA_ISO_Country__c = countryPT.Id,
            Location_Type__c = 'HE',
            Location_Class__c = 'P',
            Top_Parent__c = accountGE.Id,
            ParentId = accountGE.Id
        );

        insert accountHE;
        
	}

	@isTest static void verifyEligibleAgentHE(){

		Account accountHE = 
			[SELECT 
				Id, 
				ParentId, 
				Location_Type__c, 
				Location_Class__c,
				IATA_ISO_Country__r.AMS_Settlement_System__c
			 FROM
				Account
			 WHERE
			 	 Name = 'HE Test Agency' 
			 AND Location_Type__c = 'HE'
			];

		ANG_EligibilityForNewMulticountryAgent.EligibilityInputWrapper input = new ANG_EligibilityForNewMulticountryAgent.EligibilityInputWrapper();

		input.currentAgent = accountHE;
		input.currentAgentBSP = accountHE.IATA_ISO_Country__r.AMS_Settlement_System__c;

		List<ANG_EligibilityForNewMulticountryAgent.EligibilityInputWrapper> eligibilityInputLst = new List<ANG_EligibilityForNewMulticountryAgent.EligibilityInputWrapper>{input};

		List<ANG_EligibilityForNewMulticountryAgent.EligibilityOutputWrapper> eligibilityOutputLst = ANG_EligibilityForNewMulticountryAgent.verifyAgentEligibility(eligibilityInputLst);

		system.assertEquals(eligibilityOutputLst.size(), 1, 'The output should contain one element.');

		ANG_EligibilityForNewMulticountryAgent.EligibilityOutputWrapper output = eligibilityOutputLst.get(0);

		system.assert(output.isAgentEligible, 'The agent should be eligible for multicountry.');
		system.assert(!output.isParentInSameBSP, 'The agent should NOT be in the same BSP as the parent');

	}

	@isTest static void verifyIneligibleAgentHE() {

		Account accountGE = [SELECT Id FROM Account WHERE Location_Type__c = 'GE'];

		IATA_ISO_Country__c countryPT = 
			[SELECT 
				Id, 
				AMS_Settlement_System__c 
			 FROM
			 	IATA_ISO_Country__c 
			 WHERE 
			 	ISO_Code__c = 'PT'
			];

		Account accountHE = new Account(
        	Name='HE Ineligible Test Agency', 
        	RecordtypeId = agencyRecordTypeId,
			IATA_ISO_Country__c = countryPT.Id,
            Location_Type__c = 'HE',
            Location_Class__c = 'P',
            Top_Parent__c = accountGE.Id,
            ParentId = accountGE.Id
        );

		insert accountHE;

		ANG_EligibilityForNewMulticountryAgent.EligibilityInputWrapper input = new ANG_EligibilityForNewMulticountryAgent.EligibilityInputWrapper();

		input.currentAgent = accountHE;
		input.currentAgentBSP = countryPT.AMS_Settlement_System__c;

		List<ANG_EligibilityForNewMulticountryAgent.EligibilityInputWrapper> eligibilityInputLst = new List<ANG_EligibilityForNewMulticountryAgent.EligibilityInputWrapper>{input};

		List<ANG_EligibilityForNewMulticountryAgent.EligibilityOutputWrapper> eligibilityOutputLst = ANG_EligibilityForNewMulticountryAgent.verifyAgentEligibility(eligibilityInputLst);

		system.assertEquals(eligibilityOutputLst.size(), 1, 'The output should contain one element.');

		ANG_EligibilityForNewMulticountryAgent.EligibilityOutputWrapper output = eligibilityOutputLst.get(0);

		system.assert(!output.isAgentEligible, 'The agent should NOT be eligible for multicountry.');
		system.assert(!output.isParentInSameBSP, 'The agent should NOT be in the same BSP as the parent');

	}

	@isTest static void verifyEligibleAgentAE() {

		Account accountGE = [SELECT Id FROM Account WHERE Location_Type__c = 'GE'];

		IATA_ISO_Country__c countryMC = 
			[SELECT 
				Id, 
				AMS_Settlement_System__c 
			 FROM
			 	IATA_ISO_Country__c 
			 WHERE 
			 	ISO_Code__c = 'MC'
			];

		Account accountAE = new Account(
        	Name='AE Test Agency', 
        	RecordtypeId = agencyRecordTypeId,
			IATA_ISO_Country__c = countryMC.Id,
            Location_Type__c = 'AE',
            Location_Class__c = 'P',
            Top_Parent__c = accountGE.Id,
            ParentId = accountGE.Id
        );

        insert accountAE;

		ANG_EligibilityForNewMulticountryAgent.EligibilityInputWrapper input = new ANG_EligibilityForNewMulticountryAgent.EligibilityInputWrapper();

		input.currentAgent = accountAE;
		input.currentAgentBSP = countryMC.AMS_Settlement_System__c;

		List<ANG_EligibilityForNewMulticountryAgent.EligibilityInputWrapper> eligibilityInputLst = new List<ANG_EligibilityForNewMulticountryAgent.EligibilityInputWrapper>{input};

		List<ANG_EligibilityForNewMulticountryAgent.EligibilityOutputWrapper> eligibilityOutputLst = ANG_EligibilityForNewMulticountryAgent.verifyAgentEligibility(eligibilityInputLst);

		system.assertEquals(eligibilityOutputLst.size(), 1, 'The output should contain one element.');

		ANG_EligibilityForNewMulticountryAgent.EligibilityOutputWrapper output = eligibilityOutputLst.get(0);

		system.assert(output.isAgentEligible, 'The agent should be eligible for multicountry.');
		system.assert(output.isParentInSameBSP, 'The agent should be in the same BSP as the parent');

	}
	
	@isTest static void verifyIneligibleAgentAE() {

		Account accountGE = [SELECT Id FROM Account WHERE Location_Type__c = 'GE'];

		IATA_ISO_Country__c countryGB = 
			[SELECT 
				Id, 
				AMS_Settlement_System__c 
			 FROM
			 	IATA_ISO_Country__c 
			 WHERE 
			 	ISO_Code__c = 'GB'
			];

		Account accountIneligibleAE = new Account(
        	Name='AE Ineligible Test Agency', 
        	RecordtypeId = agencyRecordTypeId,
			IATA_ISO_Country__c = countryGB.Id,
            Location_Type__c = 'AE',
            Location_Class__c = 'P',
            Top_Parent__c = accountGE.Id,
            ParentId = accountGE.Id
        );

		ANG_EligibilityForNewMulticountryAgent.EligibilityInputWrapper input = new ANG_EligibilityForNewMulticountryAgent.EligibilityInputWrapper();

		input.currentAgent = accountIneligibleAE;
		input.currentAgentBSP = countryGB.AMS_Settlement_System__c;

		List<ANG_EligibilityForNewMulticountryAgent.EligibilityInputWrapper> eligibilityInputLst = new List<ANG_EligibilityForNewMulticountryAgent.EligibilityInputWrapper>{input};

		List<ANG_EligibilityForNewMulticountryAgent.EligibilityOutputWrapper> eligibilityOutputLst = ANG_EligibilityForNewMulticountryAgent.verifyAgentEligibility(eligibilityInputLst);

		system.assertEquals(eligibilityOutputLst.size(), 1, 'The output should contain one element.');

		ANG_EligibilityForNewMulticountryAgent.EligibilityOutputWrapper output = eligibilityOutputLst.get(0);

		system.assert(!output.isAgentEligible, 'The agent should NOT be eligible for multicountry.');
		system.assert(!output.isParentInSameBSP, 'The agent should NOT be in the same BSP as the parent');
	
	}

}