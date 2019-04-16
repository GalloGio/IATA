@isTest
private class ANG_LocalFinancialCriteriaTest {
	
	private static final Decimal FS_AMOUNT = 4000;
	private static final String COUNTRY_CURRENCY = 'USD';
	private static final Decimal COUNTRY_MIN_RHC_AMOUNT = 5000;
	private static final Decimal CASH_CONDITION_PERCENTAGE = 80;
	private static final Decimal FIXED_PERCENTAGE_RISK_A = 150;
	private static final Decimal FIXED_PERCENTAGE_RISK_B = 170;
	private static final Decimal FIXED_PERCENTAGE_RISK_C = 190;
	private static final Decimal FIXED_PERCENTAGE_RISK_A1 = 95;
	private static final Decimal FIXED_PERCENTAGE_RISK_A2 = 110;
	private static final Decimal FIXED_PERCENTAGE_RISK_B1 = 125;
	private static final Decimal FIXED_PERCENTAGE_RISK_B2 = 135;

	@testSetup
	static void setup() {

        Test.startTest();

		AMS_Settlement_System__c bspSG = new AMS_Settlement_System__c(
			Name = 'BSP-SG',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			ANG_RHC_Amount_Equals_FS__c = true
		);

		AMS_Settlement_System__c bspHK = new AMS_Settlement_System__c(
			Name = 'BSP-HK',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			ANG_RHC_Amount_Equals_FS__c = false
		);

		AMS_Settlement_System__c bspMO = new AMS_Settlement_System__c(
			Name = 'BSP-MO',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			ANG_RHC_Amount_Equals_FS__c = false
		);

		AMS_Settlement_System__c bspFR = new AMS_Settlement_System__c(
			Name = 'BSP-FR',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			ANG_RHC_Amount_Equals_FS__c = false
		);

		insert new List<AMS_Settlement_System__c>{bspSG, bspHK, bspMO, bspFR};

		IATA_ISO_Country__c countryWW = new IATA_ISO_Country__c(
			Name = 'All Countries',
			ISO_Code__c = 'WW'
		);		

		IATA_ISO_Country__c countrySG = new IATA_ISO_Country__c (
			Name = 'Singapore', 
			ISO_Code__c = 'SG',
			AMS_Settlement_System__c = bspSG.Id,
			ANG_Enable_NewGen__c = true
		);

		IATA_ISO_Country__c countryHK = new IATA_ISO_Country__c (
			Name = 'Hong Kong SAR, China', 
			ISO_Code__c = 'HK',
			AMS_Settlement_System__c = bspHK.Id,
			ANG_Enable_NewGen__c = true
		);

		IATA_ISO_Country__c countryMO = new IATA_ISO_Country__c (
			Name = 'Macao SAR, China', 
			ISO_Code__c = 'MO',
			AMS_Settlement_System__c = bspMO.Id,
			ANG_Enable_NewGen__c = true
		);

		IATA_ISO_Country__c countryFR = new IATA_ISO_Country__c (
			Name = 'France', 
			ISO_Code__c = 'FR',
			AMS_Settlement_System__c = bspFR.Id,
			ANG_Enable_NewGen__c = true
		);

        insert new List<IATA_ISO_Country__c>{countryWW, countrySG, countryHK, countryMO, countryFR};

		Id recTypeCSA = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Minimum_RHC_Amount');

        AMS_Country_Specific_Attribute__c csa = new AMS_Country_Specific_Attribute__c(
        	CurrencyIsoCode = COUNTRY_CURRENCY,
        	RecordTypeId = recTypeCSA,
        	IATA_ISO_Country__c = countryWW.Id,
        	ANG_Minimum_RHC_Amount__c = COUNTRY_MIN_RHC_AMOUNT
        );

        insert csa;

        List<ANG_BSP_Attributes__c> bspAttrLst = new List<ANG_BSP_Attributes__c>();

        bspAttrLst.add(
        	createBSPAttribute(
        		bspSG.Id, 
        		ANG_RHCHelper.RECTYPE_CASH_CONDITION_CONFIG, 
        		CASH_CONDITION_PERCENTAGE, 
        		NULL, 
        		NULL, 
        		NULL, 
        		NULL, 
        		TRUE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspSG.Id, 
        		ANG_RHCHelper.RECTYPE_RHC_AMOUNT_CONFIG, 
        		FIXED_PERCENTAGE_RISK_A, 
        		ANG_RHCHelper.RHC_AMOUNT_CALC_TYPE_FIXED_PERC, 
        		'A', 
        		0, 
        		999999999, 
        		FALSE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspSG.Id, 
        		ANG_RHCHelper.RECTYPE_RHC_AMOUNT_CONFIG, 
        		FIXED_PERCENTAGE_RISK_B, 
        		ANG_RHCHelper.RHC_AMOUNT_CALC_TYPE_FIXED_PERC, 
        		'B', 
        		0, 
        		999999999, 
        		FALSE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspSG.Id, 
        		ANG_RHCHelper.RECTYPE_RHC_AMOUNT_CONFIG, 
        		FIXED_PERCENTAGE_RISK_C, 
        		ANG_RHCHelper.RHC_AMOUNT_CALC_TYPE_FIXED_PERC, 
        		'C', 
        		0, 
        		999999999, 
        		FALSE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspMO.Id, 
        		ANG_RHCHelper.RECTYPE_CASH_CONDITION_CONFIG, 
        		CASH_CONDITION_PERCENTAGE, 
        		NULL, 
        		NULL, 
        		NULL, 
        		NULL, 
        		TRUE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspMO.Id, 
        		ANG_RHCHelper.RECTYPE_RHC_AMOUNT_CONFIG, 
        		FIXED_PERCENTAGE_RISK_A1, 
        		ANG_RHCHelper.RHC_AMOUNT_CALC_TYPE_FIXED_PERC, 
        		'A', 
        		0, 
        		174, 
        		FALSE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspMO.Id, 
        		ANG_RHCHelper.RECTYPE_RHC_AMOUNT_CONFIG, 
        		FIXED_PERCENTAGE_RISK_A2, 
        		ANG_RHCHelper.RHC_AMOUNT_CALC_TYPE_FIXED_PERC, 
        		'A', 
        		175, 
        		999999999, 
        		FALSE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspMO.Id, 
        		ANG_RHCHelper.RECTYPE_RHC_AMOUNT_CONFIG, 
        		FIXED_PERCENTAGE_RISK_B1, 
        		ANG_RHCHelper.RHC_AMOUNT_CALC_TYPE_FIXED_PERC, 
        		'B', 
        		0, 
        		84, 
        		FALSE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspMO.Id, 
        		ANG_RHCHelper.RECTYPE_RHC_AMOUNT_CONFIG, 
        		FIXED_PERCENTAGE_RISK_B2, 
        		ANG_RHCHelper.RHC_AMOUNT_CALC_TYPE_FIXED_PERC, 
        		'B', 
        		85, 
        		999999999, 
        		FALSE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspMO.Id, 
        		ANG_RHCHelper.RECTYPE_RHC_AMOUNT_CONFIG, 
        		FIXED_PERCENTAGE_RISK_C, 
        		ANG_RHCHelper.RHC_AMOUNT_CALC_TYPE_FIXED_PERC, 
        		'C', 
        		0, 
        		999999999, 
        		FALSE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspHK.Id, 
        		ANG_RHCHelper.RECTYPE_CASH_CONDITION_CONFIG, 
        		CASH_CONDITION_PERCENTAGE, 
        		NULL, 
        		NULL, 
        		NULL, 
        		NULL, 
        		TRUE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspHK.Id, 
        		ANG_RHCHelper.RECTYPE_RHC_AMOUNT_CONFIG, 
        		FIXED_PERCENTAGE_RISK_A1, 
        		ANG_RHCHelper.RHC_AMOUNT_CALC_TYPE_FIXED_PERC, 
        		'A', 
        		0, 
        		174, 
        		FALSE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspHK.Id, 
        		ANG_RHCHelper.RECTYPE_RHC_AMOUNT_CONFIG, 
        		FIXED_PERCENTAGE_RISK_A2, 
        		ANG_RHCHelper.RHC_AMOUNT_CALC_TYPE_FIXED_PERC, 
        		'A', 
        		175, 
        		999999999, 
        		FALSE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspHK.Id, 
        		ANG_RHCHelper.RECTYPE_RHC_AMOUNT_CONFIG, 
        		FIXED_PERCENTAGE_RISK_B1, 
        		ANG_RHCHelper.RHC_AMOUNT_CALC_TYPE_FIXED_PERC, 
        		'B', 
        		0, 
        		84, 
        		FALSE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspHK.Id, 
        		ANG_RHCHelper.RECTYPE_RHC_AMOUNT_CONFIG, 
        		FIXED_PERCENTAGE_RISK_B2, 
        		ANG_RHCHelper.RHC_AMOUNT_CALC_TYPE_FIXED_PERC, 
        		'B', 
        		85, 
        		999999999, 
        		FALSE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspHK.Id, 
        		ANG_RHCHelper.RECTYPE_RHC_AMOUNT_CONFIG, 
        		FIXED_PERCENTAGE_RISK_C, 
        		ANG_RHCHelper.RHC_AMOUNT_CALC_TYPE_FIXED_PERC, 
        		'C', 
        		0, 
        		999999999, 
        		FALSE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspFR.Id, 
        		ANG_RHCHelper.RECTYPE_CASH_CONDITION_CONFIG, 
        		CASH_CONDITION_PERCENTAGE, 
        		NULL, 
        		NULL, 
        		NULL, 
        		NULL, 
        		TRUE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspFR.Id, 
        		ANG_RHCHelper.RECTYPE_RHC_AMOUNT_CONFIG, 
        		NULL, 
        		ANG_RHCHelper.RHC_AMOUNT_CALC_TYPE_FORMULA, 
        		'A', 
        		NULL, 
        		NULL, 
        		FALSE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspFR.Id, 
        		ANG_RHCHelper.RECTYPE_RHC_AMOUNT_CONFIG, 
        		NULL, 
        		ANG_RHCHelper.RHC_AMOUNT_CALC_TYPE_FORMULA, 
        		'B', 
        		NULL, 
        		NULL, 
        		FALSE
        	)
        );

		bspAttrLst.add(
        	createBSPAttribute(
        		bspFR.Id, 
        		ANG_RHCHelper.RECTYPE_RHC_AMOUNT_CONFIG, 
        		NULL, 
        		ANG_RHCHelper.RHC_AMOUNT_CALC_TYPE_FORMULA, 
        		'C', 
        		NULL, 
        		NULL, 
        		FALSE
        	)
        );

		insert bspAttrLst;

        Account agentSG = new Account(
        	Name = 'Agent SG',
        	IATACode__c ='999999999',
        	Status__c = AMS_Utils.ACC_S9_APPROVED,
        	Location_Type__c = AMS_Utils.HE,
        	RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
        	IATA_ISO_Country__c = countrySG.Id,
        	Location_Class__c = 'P',
        	Remittance_frequency__c = 'M',
        	ANG_HE_RiskStatus__c = 'A'
        );

		Account agentHK = new Account(
        	Name = 'Agent HK',
        	IATACode__c ='999999998',
        	Status__c = AMS_Utils.ACC_S9_APPROVED,
        	Location_Type__c = AMS_Utils.HE,
        	RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
        	IATA_ISO_Country__c = countryHK.Id,
        	Location_Class__c = 'P',
        	Remittance_frequency__c = 'M',
        	ANG_HE_RiskStatus__c = 'A'
        );

		Account agentMO = new Account(
        	Name = 'Agent MO',
        	IATACode__c ='999999997',
        	Status__c = AMS_Utils.ACC_S9_APPROVED,
        	Location_Type__c = AMS_Utils.HE,
        	RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
        	IATA_ISO_Country__c = countryMO.Id,
        	Location_Class__c = 'P',
        	Remittance_frequency__c = 'M',
        	ANG_HE_RiskStatus__c = 'A'
        );

		Account agentFR = new Account(
        	Name = 'Agent FR',
        	IATACode__c ='999999996',
        	Status__c = AMS_Utils.ACC_S9_APPROVED,
        	Location_Type__c = AMS_Utils.HE,
        	RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
        	IATA_ISO_Country__c = countryFR.Id,
        	Location_Class__c = 'P',
        	Remittance_frequency__c = 'M',
        	ANG_HE_RiskStatus__c = 'A'
        );

        insert new List<Account>{agentSG, agentHK, agentMO, agentFR};
        
        Test.stopTest();
        
	}

	private static ANG_BSP_Attributes__c createBSPAttribute(String bspId, String recTypeId, Decimal percentage, String calcType, String riskStatus, Decimal minFaPoints, Decimal maxFaPoints, Boolean limitCash){

		ANG_BSP_Attributes__c attr = new ANG_BSP_Attributes__c();

		attr.BSP__c = bspId;
		attr.RecordTypeId = recTypeId;
		attr.RHC_Amnt_Calc_Type__c = calcType;
		attr.FS_Percentage__c = percentage;
		attr.Limit_Cash_Condition__c = limitCash;

		if(riskStatus != NULL){
			attr.Risk_Status__c =riskStatus;
		}

		if(minFaPoints != NULL){
    		attr.Min_FA_Points__c = minFaPoints;
		}

		if(maxFaPoints != NULL){
    		attr.Max_FA_Points__c = maxFaPoints;
		}

		return attr;

	}

	private static Financial_Security__c createFinancialData(Id acctId){
		Financial_Institution__c fi = new Financial_Institution__c(
			Name = 'Financial Institution', 
			Region__c = 'Asia & Pacific', 
			Country__c = 'Hong Kong', 
			Institution_Type__c = 'Bank'
		);

        insert fi;

        Case cc = new Case(AccountId = acctId);
        insert cc;

      	Financial_Security__c fs = new Financial_Security__c(
      		CurrencyIsoCode = 'EUR', 
      		Account__c = acctId, 
      		Amount__c = FS_AMOUNT, 
      		Expiry_date__c = System.Today().AddDays(100), 
      		Financial_Institution__c = fi.Id, 
      		Security_Status__c = 'Active', 
      		Security_Type__c = 'Bank Guarantee', 
      		Region__c = 'Asia & Pacific', 
      		Reception_Date__c = System.today(), 
      		Reasonforrequest__c = 'New Application',
      		Reception_Case__c = cc.Id
     	);

        insert fs; 

        return fs;
	}

	@isTest static void rhcAmountEqualsFsCalcTypeTest() {

		Account acct = [SELECT Id FROM Account WHERE Name = 'Agent FR'];

      	Financial_Security__c fs = createFinancialData(acct.Id);

		ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
			ANG_AccountId__c = acct.Id,
			CurrencyIsoCode = 'EUR',
			RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
			ANG_RHC_Amount_Equals_FS__c = TRUE,
			RHC_Amount_Equals_FS_Percent__c = 200
		);

		insert rhcInfo;

		ANG_RHC_Information__c rhcUpdated = 
			[SELECT 
				ANG_RHC_Amount__c, 
				ANG_RHC_Amount_Forecasted__c 
			 FROM 
			 	ANG_RHC_Information__c 
			 WHERE 
			 	Id = :rhcInfo.Id
			];

		Decimal expectedAmount = (FS_AMOUNT * rhcInfo.RHC_Amount_Equals_FS_Percent__c/100);
		
		System.assert(rhcUpdated.ANG_RHC_Amount__c == expectedAmount);
		System.assert(rhcUpdated.ANG_RHC_Amount__c == rhcUpdated.ANG_RHC_Amount_Forecasted__c);

	}
	
	@isTest static void rhcCashConditionCalcTypeTest() {

		Account acct = [SELECT Id FROM Account WHERE Name = 'Agent SG'];

		Financial_Security__c fs = createFinancialData(acct.Id);

		ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
			ANG_AccountId__c = acct.Id,
			CurrencyIsoCode = 'EUR',
			RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
			RHC_Amount_Equals_FS_Percent__c = 200,
			ANG_CashCondition__c = TRUE
		);

		insert rhcInfo;

		ANG_RHC_Information__c rhcUpdated = 
			[SELECT 
				ANG_RHC_Amount__c, 
				ANG_RHC_Amount_Forecasted__c 
			 FROM 
			 	ANG_RHC_Information__c 
			 WHERE 
			 	Id = :rhcInfo.Id
			];

		Decimal expectedAmount = (FS_AMOUNT * CASH_CONDITION_PERCENTAGE/100);
		
		System.assert(rhcUpdated.ANG_RHC_Amount__c == expectedAmount);
		System.assert(rhcUpdated.ANG_RHC_Amount__c == rhcUpdated.ANG_RHC_Amount_Forecasted__c);

	}
	
	@isTest static void rhcWithoutCashConditionCalcTypeTest() {

		Account acct = [SELECT Id FROM Account WHERE Name = 'Agent SG'];

		Financial_Security__c fs = createFinancialData(acct.Id);

		ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
			ANG_AccountId__c = acct.Id,
			CurrencyIsoCode = 'EUR',
			RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
			RHC_Amount_Equals_FS_Percent__c = 200,
			ANG_CashCondition__c = FALSE
		);

		insert rhcInfo;

		ANG_RHC_Information__c rhcUpdated = 
			[SELECT 
				ANG_RHC_Amount__c, 
                ANG_CashCondition__c,
				ANG_RHC_Amount_Forecasted__c 
			 FROM 
			 	ANG_RHC_Information__c 
			 WHERE 
			 	Id = :rhcInfo.Id
			];

		Decimal expectedAmount = (FS_AMOUNT * FIXED_PERCENTAGE_RISK_A/100);
		
		System.assert(rhcUpdated.ANG_RHC_Amount__c == expectedAmount);
		System.assert(rhcUpdated.ANG_RHC_Amount__c == rhcUpdated.ANG_RHC_Amount_Forecasted__c);

	}

	@isTest static void rhcFixedPercentageCalcTypeRiskStatusATest() {

		Account agentHK =
			[SELECT 
				Id,
				Name,
				ANG_HE_RiskStatus__c, 
				Financial_Assessment_Points__c 
			 FROM 
			 	Account
			 WHERE
			 	Name = 'Agent HK'
			];

		rhcFixedPercentageCalcTypeRiskStatusTest(agentHK, 'A', 100, 200, FIXED_PERCENTAGE_RISK_A1, FIXED_PERCENTAGE_RISK_A2);

	}

	@isTest static void rhcFixedPercentageCalcTypeRiskStatusBTest() {

		Account agentMO =
			[SELECT 
				Id,
				Name,
				ANG_HE_RiskStatus__c, 
				Financial_Assessment_Points__c 
			 FROM 
			 	Account
			 WHERE
			 	Name = 'Agent MO'
			];

		rhcFixedPercentageCalcTypeRiskStatusTest(agentMO, 'B', 74, 100, FIXED_PERCENTAGE_RISK_B1, FIXED_PERCENTAGE_RISK_B2);

	}

	@isTest static void rhcFixedPercentageCalcTypeRiskStatusCTest() {
		
		Account agentMO =
			[SELECT 
				Id,
				Name,
				ANG_HE_RiskStatus__c, 
				Financial_Assessment_Points__c 
			 FROM 
			 	Account
			 WHERE
			 	Name = 'Agent MO'
			];

		rhcFixedPercentageCalcTypeRiskStatusTest(agentMO, 'C', 100, NULL, FIXED_PERCENTAGE_RISK_C, NULL);

	}

	private static void rhcFixedPercentageCalcTypeRiskStatusTest(Account acct, String riskStatus, Integer initPoints, Integer updatedPoints, Decimal firstPercentage, Decimal secondPercentage){

		acct.ANG_HE_RiskStatus__c = riskStatus;
		acct.Financial_Assessment_Points__c = initPoints;

		update acct;

      	Financial_Security__c fs = createFinancialData(acct.Id);

		ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
			ANG_AccountId__c = acct.Id,
			CurrencyIsoCode = 'EUR',
			RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
			RHC_Amount_Equals_FS_Percent__c = 214
		);

		insert rhcInfo;

		ANG_RHC_Information__c rhcUpdated = 
			[SELECT 
				ANG_RHC_Amount__c, 
				ANG_RHC_Amount_Forecasted__c 
			 FROM 
			 	ANG_RHC_Information__c 
			 WHERE 
			 	Id = :rhcInfo.Id
			];

		Decimal expectedAmount = (FS_AMOUNT * firstPercentage/100);
		
		System.assert(rhcUpdated.ANG_RHC_Amount__c == expectedAmount);
		System.assert(rhcUpdated.ANG_RHC_Amount__c == rhcUpdated.ANG_RHC_Amount_Forecasted__c);

		if(updatedPoints == NULL) return;

		acct.Financial_Assessment_Points__c = updatedPoints;
		update acct;

		fs.Amount__c = (FS_AMOUNT*2);
        update fs; 

		rhcUpdated = 
			[SELECT 
				ANG_RHC_Amount__c, 
				ANG_RHC_Amount_Forecasted__c 
			 FROM 
			 	ANG_RHC_Information__c 
			 WHERE 
			 	Id = :rhcInfo.Id
			];

		expectedAmount = (FS_AMOUNT * 2 * secondPercentage/100);
		
		System.assert(rhcUpdated.ANG_RHC_Amount__c == expectedAmount);
		System.assert(rhcUpdated.ANG_RHC_Amount__c == rhcUpdated.ANG_RHC_Amount_Forecasted__c);

	}

	@isTest static void rhcFormulaCalcTypeTest() {

		Account acct = [SELECT Id FROM Account WHERE Name = 'Agent FR'];

      	Financial_Security__c fs = createFinancialData(acct.Id);

		ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
			ANG_AccountId__c = acct.Id,
			CurrencyIsoCode = 'EUR',
			RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
			RHC_Amount_Equals_FS_Percent__c = 200
		);

		insert rhcInfo;

		ANG_RHC_Information__c rhcUpdated = 
			[SELECT 
				ANG_RHC_Amount__c, 
				ANG_RHC_Amount_Forecasted__c 
			 FROM 
			 	ANG_RHC_Information__c 
			 WHERE 
			 	Id = :rhcInfo.Id
			];

		Decimal expectedMinRHCAmount = ANG_Risk_Helper.currencyConverter(COUNTRY_CURRENCY, COUNTRY_MIN_RHC_AMOUNT, rhcInfo.CurrencyIsoCode);

		System.assert(rhcUpdated.ANG_RHC_Amount__c == expectedMinRHCAmount);
		System.assert(rhcUpdated.ANG_RHC_Amount__c == rhcUpdated.ANG_RHC_Amount_Forecasted__c);

		rhcInfo.ANG_RME_Amount__c = 2000;
		rhcInfo.ANG_RHC_Amount_Provisional__c = 2000;
		update rhcInfo;

		rhcUpdated = 
			[SELECT 
				ANG_RHC_Amount__c, 
				ANG_RHC_Amount_Forecasted__c,
				ANG_Exceeding_Financial_Security__c
			 FROM 
			 	ANG_RHC_Information__c 
			 WHERE 
			 	Id = :rhcInfo.Id
			];

		Decimal expectedAmount = rhcUpdated.ANG_Exceeding_Financial_Security__c + rhcInfo.ANG_RME_Amount__c;

		System.assert(rhcUpdated.ANG_RHC_Amount__c == expectedAmount);
		System.assert(rhcUpdated.ANG_RHC_Amount__c == rhcUpdated.ANG_RHC_Amount_Forecasted__c);

	}

    @isTest static void triggerRhcCalculationOnPointsChangeTest() {
        
        Account agentHK =
            [SELECT 
                Id,
                Financial_Assessment_Points__c 
             FROM 
                Account
             WHERE
                Name = 'Agent HK'
            ];

        agentHK.Financial_Assessment_Points__c = 100;
        update agentHK;

        Financial_Security__c fs = createFinancialData(agentHK.Id);

        ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
            ANG_AccountId__c = agentHK.Id,
            CurrencyIsoCode = 'EUR',
            RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
            RHC_Amount_Equals_FS_Percent__c = 100
        );

        insert rhcInfo;

        ANG_RHC_Information__c rhcUpdated = 
            [SELECT 
                ANG_RHC_Amount__c, 
                ANG_RHC_Amount_Forecasted__c 
             FROM 
                ANG_RHC_Information__c 
             WHERE 
                Id = :rhcInfo.Id
            ];

        Decimal expectedAmount = (FS_AMOUNT * FIXED_PERCENTAGE_RISK_A1/100);
        
        System.assert(rhcUpdated.ANG_RHC_Amount__c == expectedAmount);
        System.assert(rhcUpdated.ANG_RHC_Amount__c == rhcUpdated.ANG_RHC_Amount_Forecasted__c);

        agentHK.Financial_Assessment_Points__c = 176;

        update agentHK;

        rhcUpdated = 
            [SELECT 
                ANG_RHC_Amount__c, 
                ANG_RHC_Amount_Forecasted__c 
             FROM 
                ANG_RHC_Information__c 
             WHERE 
                Id = :rhcInfo.Id
            ];

        expectedAmount = (FS_AMOUNT * FIXED_PERCENTAGE_RISK_A2/100);
        
        System.assert(rhcUpdated.ANG_RHC_Amount__c == expectedAmount);
        System.assert(rhcUpdated.ANG_RHC_Amount__c == rhcUpdated.ANG_RHC_Amount_Forecasted__c);

    }

}