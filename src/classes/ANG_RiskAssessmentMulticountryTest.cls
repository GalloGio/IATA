@isTest
public class ANG_RiskAssessmentMulticountryTest {

  @TestSetup
  static void setup(){
    
    Test.startTest();

    List<ANG_Agency_Risk_Calculation__c> rulesLst = new List<ANG_Agency_Risk_Calculation__c>();
    
    ANG_Agency_Risk_Calculation__c cashAdjustOnlyRule = new ANG_Agency_Risk_Calculation__c(
      ANG_Occurrence_Num__c = 0,
      ANG_Adjusted__c = ANG_Risk_Helper.ADJ_YES,
      RecordTypeId = ANG_Risk_Helper.RECTYPE_RULES,
      ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH
    );

    ANG_Agency_Risk_Calculation__c cashWithoutAdjRule = new ANG_Agency_Risk_Calculation__c(
      ANG_Occurrence_Num__c = 1,
      ANG_Adjusted__c = ANG_Risk_Helper.ADJ_NO,
      RecordTypeId = ANG_Risk_Helper.RECTYPE_RULES,
      ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH
    );

    ANG_Agency_Risk_Calculation__c cashMixedAdjustRule = new ANG_Agency_Risk_Calculation__c(
      ANG_Occurrence_Num__c = 2,
      ANG_Adjusted__c = ANG_Risk_Helper.ADJ_MIXED,
      RecordTypeId = ANG_Risk_Helper.RECTYPE_RULES,
      ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH
    );

    ANG_Agency_Risk_Calculation__c multicountryAdjustOnlyRule = new ANG_Agency_Risk_Calculation__c(
      ANG_Occurrence_Num__c = 0,
      ANG_Adjusted__c = ANG_Risk_Helper.ADJ_YES,
      RecordTypeId = ANG_Risk_Helper.RECTYPE_RULES,
      ANG_RF_Sum_Type__c = ANG_RiskAssessmentEngine.APPLY_CEILING_SUM,
      ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY
    );

    ANG_Agency_Risk_Calculation__c multicountryWithoutAdjRule = new ANG_Agency_Risk_Calculation__c(
      ANG_Occurrence_Num__c = 1,
      ANG_Adjusted__c = ANG_Risk_Helper.ADJ_NO,
      RecordTypeId = ANG_Risk_Helper.RECTYPE_RULES,
      ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY
    );

    ANG_Agency_Risk_Calculation__c multicountryMixedAdjustRule = new ANG_Agency_Risk_Calculation__c(
      ANG_Occurrence_Num__c = 2,
      ANG_Adjusted__c = ANG_Risk_Helper.ADJ_MIXED,
      RecordTypeId = ANG_Risk_Helper.RECTYPE_RULES,
      ANG_RF_Sum_Type__c = ANG_RiskAssessmentEngine.APPLY_SUM_ONLY,
      ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY
    );

    rulesLst.add(cashAdjustOnlyRule);
    rulesLst.add(cashWithoutAdjRule);
    rulesLst.add(cashMixedAdjustRule);
    rulesLst.add(multicountryAdjustOnlyRule);
    rulesLst.add(multicountryWithoutAdjRule);
    rulesLst.add(multicountryMixedAdjustRule);

    insert rulesLst;

    List<ANG_Agency_Risk_Calculation__c> adjustmentsAndRemittanceValuesLst = new List<ANG_Agency_Risk_Calculation__c>();

    ANG_Agency_Risk_Calculation__c cashMonthlyAdjustOnly = new ANG_Agency_Risk_Calculation__c(
      ANG_Calculation_Rule__c = cashAdjustOnlyRule.Id,
      ANG_Occurrence_Num__c = 1,
      ANG_Parent_Occurences__c = 0,
      RecordTypeId = ANG_Risk_Helper.RECTYPE_ADJUSTMENT,
      ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
      ANG_Remittance_Frequency__c = 'M'
    );

    ANG_Agency_Risk_Calculation__c cashFortnightlyAdjustOnly = new ANG_Agency_Risk_Calculation__c(
      ANG_Calculation_Rule__c = cashAdjustOnlyRule.Id,
      ANG_Occurrence_Num__c = 2,
      ANG_Parent_Occurences__c = 0,
      RecordTypeId = ANG_Risk_Helper.RECTYPE_ADJUSTMENT,
      ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
      ANG_Remittance_Frequency__c = 'F'
    );

    ANG_Agency_Risk_Calculation__c cashMonthlyMixed = new ANG_Agency_Risk_Calculation__c(
      ANG_Calculation_Rule__c = cashMixedAdjustRule.Id,
      ANG_Occurrence_Num__c = 1,
      ANG_Parent_Occurences__c = 1,
      RecordTypeId = ANG_Risk_Helper.RECTYPE_ADJUSTMENT,
      ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
      ANG_Remittance_Frequency__c = 'M'
    );

    ANG_Agency_Risk_Calculation__c cashFortnightlyMixed = new ANG_Agency_Risk_Calculation__c(
      ANG_Calculation_Rule__c = cashMixedAdjustRule.Id,
      ANG_Occurrence_Num__c = 1,
      ANG_Parent_Occurences__c = 1,
      RecordTypeId = ANG_Risk_Helper.RECTYPE_ADJUSTMENT,
      ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
      ANG_Remittance_Frequency__c = 'F'
    );

    ANG_Agency_Risk_Calculation__c multicountryMixedRange500 = new ANG_Agency_Risk_Calculation__c(
      ANG_Calculation_Rule__c = multicountryMixedAdjustRule.Id,
      ANG_Occurrence_Num__c = 3,
      ANG_Max_Range__c = 500,
      ANG_Min_Range__c = 0,
      RecordTypeId = ANG_Risk_Helper.RECTYPE_ADJUSTMENT,
      ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY
    );

    ANG_Agency_Risk_Calculation__c multicountryMixedRange750 = new ANG_Agency_Risk_Calculation__c(
      ANG_Calculation_Rule__c = multicountryMixedAdjustRule.Id,
      ANG_Occurrence_Num__c = 3,
      ANG_Max_Range__c = 750,
      ANG_Min_Range__c = 501,
      RecordTypeId = ANG_Risk_Helper.RECTYPE_ADJUSTMENT,
      ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY
    );

    ANG_Agency_Risk_Calculation__c multicountryMixedRange1000 = new ANG_Agency_Risk_Calculation__c(
      ANG_Calculation_Rule__c = multicountryMixedAdjustRule.Id,
      ANG_Occurrence_Num__c = 3,
      ANG_Max_Range__c = 1000,
      ANG_Min_Range__c = 751,
      RecordTypeId = ANG_Risk_Helper.RECTYPE_ADJUSTMENT,
      ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY
    );

    ANG_Agency_Risk_Calculation__c multicountryMixedRange2000 = new ANG_Agency_Risk_Calculation__c(
      ANG_Calculation_Rule__c = multicountryMixedAdjustRule.Id,
      ANG_Occurrence_Num__c = 3,
      ANG_Max_Range__c = 2000,
      ANG_Min_Range__c = 1001,
      RecordTypeId = ANG_Risk_Helper.RECTYPE_ADJUSTMENT,
      ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY
    );

    ANG_Agency_Risk_Calculation__c multicountryMixedRange5000 = new ANG_Agency_Risk_Calculation__c(
      ANG_Calculation_Rule__c = multicountryMixedAdjustRule.Id,
      ANG_Occurrence_Num__c = 3,
      ANG_Max_Range__c = 5000,
      ANG_Min_Range__c = 2001,
      RecordTypeId = ANG_Risk_Helper.RECTYPE_ADJUSTMENT,
      ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY
    );

    ANG_Agency_Risk_Calculation__c multicountryMixedRangeMAX = new ANG_Agency_Risk_Calculation__c(
      ANG_Calculation_Rule__c = multicountryMixedAdjustRule.Id,
      ANG_Occurrence_Num__c = 3,
      ANG_Max_Range__c = 999999999,
      ANG_Min_Range__c = 5001,
      RecordTypeId = ANG_Risk_Helper.RECTYPE_ADJUSTMENT,
      ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY
    );

    adjustmentsAndRemittanceValuesLst.add(cashMonthlyAdjustOnly);
    adjustmentsAndRemittanceValuesLst.add(cashFortnightlyAdjustOnly);
    adjustmentsAndRemittanceValuesLst.add(cashMonthlyMixed);
    adjustmentsAndRemittanceValuesLst.add(cashFortnightlyMixed);
    adjustmentsAndRemittanceValuesLst.add(multicountryMixedRange500);
    adjustmentsAndRemittanceValuesLst.add(multicountryMixedRange750);
    adjustmentsAndRemittanceValuesLst.add(multicountryMixedRange1000);
    adjustmentsAndRemittanceValuesLst.add(multicountryMixedRange2000);
    adjustmentsAndRemittanceValuesLst.add(multicountryMixedRange5000);
    adjustmentsAndRemittanceValuesLst.add(multicountryMixedRangeMAX);
   
    Id rfValuesRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ANG_Agency_Risk_Calculation__c', ANG_RiskAssessmentEngine.REMITTANCE_FREQUENCY_VALUES_REC_TYPE_NAME);

    ANG_Agency_Risk_Calculation__c nbrOfRemittancesMonthly = new ANG_Agency_Risk_Calculation__c(
      ANG_Occurrence_Num__c = 12,
      ANG_Remittance_Frequency__c = 'M',
      RecordTypeId = rfValuesRecTypeId
    );

    ANG_Agency_Risk_Calculation__c nbrOfRemittancesFortnightly = new ANG_Agency_Risk_Calculation__c(
      ANG_Occurrence_Num__c = 24,
      ANG_Remittance_Frequency__c = 'F',
      RecordTypeId = rfValuesRecTypeId
    );

    ANG_Agency_Risk_Calculation__c nbrOfRemittances4TimesPerMonth = new ANG_Agency_Risk_Calculation__c(
      ANG_Occurrence_Num__c = 48,
      ANG_Remittance_Frequency__c = 'W',
      RecordTypeId = rfValuesRecTypeId
    );

    ANG_Agency_Risk_Calculation__c nbrOfRemittancesEvery10Days = new ANG_Agency_Risk_Calculation__c(
      ANG_Occurrence_Num__c = 48,
      ANG_Remittance_Frequency__c = 'R',
      RecordTypeId = rfValuesRecTypeId
    );

    ANG_Agency_Risk_Calculation__c nbrOfRemittancesWeekly = new ANG_Agency_Risk_Calculation__c(
      ANG_Occurrence_Num__c = 52,
      ANG_Remittance_Frequency__c = 'V',
      RecordTypeId = rfValuesRecTypeId
    );

    ANG_Agency_Risk_Calculation__c nbrOfRemittancesEvery5Days = new ANG_Agency_Risk_Calculation__c(
      ANG_Occurrence_Num__c = 73,
      ANG_Remittance_Frequency__c = 'S',
      RecordTypeId = rfValuesRecTypeId
    );
    
    ANG_Agency_Risk_Calculation__c nbrOfRemittancesTwiceAWeek = new ANG_Agency_Risk_Calculation__c(
      ANG_Occurrence_Num__c = 96,
      ANG_Remittance_Frequency__c = 'B',
      RecordTypeId = rfValuesRecTypeId
    );

    ANG_Agency_Risk_Calculation__c nbrOfRemittancesEvery3Days = new ANG_Agency_Risk_Calculation__c(
      ANG_Occurrence_Num__c = 105,
      ANG_Remittance_Frequency__c = 'T',
      RecordTypeId = rfValuesRecTypeId
    );

    ANG_Agency_Risk_Calculation__c nbrOfRemittancesDaily = new ANG_Agency_Risk_Calculation__c(
      ANG_Occurrence_Num__c = 122,
      ANG_Remittance_Frequency__c = 'D',
      RecordTypeId = rfValuesRecTypeId
    );

    adjustmentsAndRemittanceValuesLst.add(nbrOfRemittancesMonthly);
    adjustmentsAndRemittanceValuesLst.add(nbrOfRemittancesFortnightly);
    adjustmentsAndRemittanceValuesLst.add(nbrOfRemittances4TimesPerMonth);
    adjustmentsAndRemittanceValuesLst.add(nbrOfRemittancesEvery10Days);
    adjustmentsAndRemittanceValuesLst.add(nbrOfRemittancesWeekly);
    adjustmentsAndRemittanceValuesLst.add(nbrOfRemittancesEvery5Days);
    adjustmentsAndRemittanceValuesLst.add(nbrOfRemittancesTwiceAWeek);
    adjustmentsAndRemittanceValuesLst.add(nbrOfRemittancesEvery3Days);
    adjustmentsAndRemittanceValuesLst.add(nbrOfRemittancesDaily);

    insert adjustmentsAndRemittanceValuesLst;

    List<ANG_Risk_Event_Type__c> riskEventTypesLst = new List<ANG_Risk_Event_Type__c>();

    ANG_Risk_Event_Type__c authCashPayment = new ANG_Risk_Event_Type__c(
      Name = 'Auth. Cash Payment',
      ANG_Description__c = 'Authorisation to use Cash Payment Method for less than 24 Months',
      ANG_Expiration__c = 24,
      ANG_Risk_ID__c = '1',
      Limit_Cash_conditions__c = TRUE,
      ANG_Agency_Risk_Calculation__c = cashWithoutAdjRule.Id
    );

    ANG_Risk_Event_Type__c commonOwnershipDefault = new ANG_Risk_Event_Type__c(
      Name = 'Common ownership default',
      ANG_Description__c = 'Default due to common ownership',
      ANG_Expiration__c = 24,
      ANG_Risk_ID__c = '10',
      ANG_Agency_Risk_Calculation__c = cashWithoutAdjRule.Id
    );

    ANG_Risk_Event_Type__c paymentDefault = new ANG_Risk_Event_Type__c(
      Name = 'Payment Default',
      ANG_Description__c = 'Payment Default',
      ANG_Expiration__c = 24,
      ANG_Risk_ID__c = '4',
      Limit_Cash_conditions__c = TRUE,
      ANG_Agency_Risk_Calculation__c = cashWithoutAdjRule.Id
    );

    ANG_Risk_Event_Type__c majorChange = new ANG_Risk_Event_Type__c(
      Name = 'Major change (owner or legal)',
      ANG_Description__c = 'Major change of ownership or change of legal status',
      ANG_Expiration__c = 24,
      ANG_Risk_ID__c = '6',
      ANG_Agency_Risk_Calculation__c = cashWithoutAdjRule.Id
    );

    ANG_Risk_Event_Type__c lateShortPayment = new ANG_Risk_Event_Type__c(
      Name = 'Late/Short payment',
      ANG_Description__c = 'Late or short payment',
      ANG_Expiration__c = 12,
      ANG_Risk_ID__c = '2',
      ANG_Agency_Risk_Calculation__c = cashAdjustOnlyRule.Id
    );

    ANG_Risk_Event_Type__c wrongCurrencyPayment = new ANG_Risk_Event_Type__c(
      Name = 'Wrong currency payment',
      ANG_Description__c = 'Payment in the wrong currency',
      ANG_Expiration__c = 12,
      ANG_Risk_ID__c = '3',
      ANG_Agency_Risk_Calculation__c = cashAdjustOnlyRule.Id
    );

    ANG_Risk_Event_Type__c prejudicedCollection = new ANG_Risk_Event_Type__c(
      Name = 'Prejudiced collection',
      ANG_Description__c = 'Prejudiced collection of funds',
      ANG_Expiration__c = 12,
      ANG_Risk_ID__c = '11',
      ANG_Agency_Risk_Calculation__c = cashMixedAdjustRule.Id
    );

    ANG_Risk_Event_Type__c failFinancialStatements = new ANG_Risk_Event_Type__c(
      Name = 'Fail Financial Statements',
      ANG_Description__c = 'Failure to provide financial statements',
      ANG_Expiration__c = 12,
      ANG_Risk_ID__c = '5',
      ANG_Agency_Risk_Calculation__c = cashMixedAdjustRule.Id
    );

    ANG_Risk_Event_Type__c unreportedMajorChange = new ANG_Risk_Event_Type__c(
      Name = 'Unreported Major Change',
      ANG_Description__c = 'Unreported change of ownership, legal status, legal name or shareholding',
      ANG_Expiration__c = 12,
      ANG_Risk_ID__c = '7',
      ANG_Agency_Risk_Calculation__c = cashMixedAdjustRule.Id
    );

    ANG_Risk_Event_Type__c changeHeLocation = new ANG_Risk_Event_Type__c(
      Name = 'Change HE location',
      ANG_Description__c = 'Change of Head Entity\'s location to another country',
      ANG_Expiration__c = 12,
      ANG_Risk_ID__c = '8',
      ANG_Agency_Risk_Calculation__c = cashMixedAdjustRule.Id
    );

    ANG_Risk_Event_Type__c failFinancialSecurity = new ANG_Risk_Event_Type__c(
      Name = 'Fail Financial Security',
      ANG_Description__c = 'Failure to provide a Financial Security',
      ANG_Expiration__c = 12,
      ANG_Risk_ID__c = '9',
      ANG_Agency_Risk_Calculation__c = cashMixedAdjustRule.Id
    );

    riskEventTypesLst.add(authCashPayment);
    riskEventTypesLst.add(commonOwnershipDefault);
    riskEventTypesLst.add(paymentDefault);
    riskEventTypesLst.add(majorChange);
    riskEventTypesLst.add(lateShortPayment);
    riskEventTypesLst.add(wrongCurrencyPayment);
    riskEventTypesLst.add(prejudicedCollection);
    riskEventTypesLst.add(failFinancialStatements);
    riskEventTypesLst.add(unreportedMajorChange);
    riskEventTypesLst.add(changeHeLocation);
    riskEventTypesLst.add(failFinancialSecurity);

    insert riskEventTypesLst;

    AMS_Settlement_System__c bspPT = new AMS_Settlement_System__c(
			Name = 'BSP-PT',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			CurrencyIsoCode = 'EUR'
		);

		AMS_Settlement_System__c bspGB = new AMS_Settlement_System__c(
			Name = 'BSP-GB',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			CurrencyIsoCode = 'EUR'
		);

		AMS_Settlement_System__c bspFR = new AMS_Settlement_System__c(
			Name = 'BSP-FR',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			CurrencyIsoCode = 'EUR'
		);

		AMS_Settlement_System__c bspSG = new AMS_Settlement_System__c(
			Name = 'BSP-SG',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			CurrencyIsoCode = 'EUR'
		);

		insert new List<AMS_Settlement_System__c>{bspPT, bspGB, bspFR, bspSG};

		IATA_ISO_Country__c countryPT = new IATA_ISO_Country__c();
		
		countryPT.Name = 'Portugal';
		countryPT.ISO_Code__c = 'PT';
		countryPT.ANG_Enable_NewGen__c = true;
		countryPT.AMS_Settlement_System__c = bspPT.Id;
		countryPT.Multicountry_Enabled__c = true;

		IATA_ISO_Country__c countryUK = new IATA_ISO_Country__c();
		
		countryUK.Name = 'United Kingdom';
		countryUK.ISO_Code__c = 'GB';
		countryUK.ANG_Enable_NewGen__c = true;
		countryUK.AMS_Settlement_System__c = bspGB.Id;
		countryUK.Multicountry_Enabled__c = true;

		IATA_ISO_Country__c countryFR = new IATA_ISO_Country__c();
		
		countryFR.Name = 'France';
		countryFR.ISO_Code__c = 'FR';
		countryFR.ANG_Enable_NewGen__c = true;
		countryFR.AMS_Settlement_System__c = bspFR.Id;
		countryFR.Multicountry_Enabled__c = true;

		IATA_ISO_Country__c countrySG = new IATA_ISO_Country__c();
		
		countrySG.Name = 'Singapore';
		countrySG.ISO_Code__c = 'SG';
		countrySG.ANG_Enable_NewGen__c = true;
		countrySG.AMS_Settlement_System__c = bspSG.Id;
		countrySG.Multicountry_Enabled__c = true;

		insert new List<IATA_ISO_Country__c>{countryPT, countryUK, countryFR, countrySG};

    Id agencyRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account accountGE = new Account();
		accountGE.Name = 'Multicountry GE PT';
		accountGE.Location_Type__c = AMS_Utils.GE;
		accountGE.Location_Class__c = 'P';
		accountGE.IATA_ISO_Country__c = countryPT.Id;
		accountGE.RecordTypeId = agencyRecTypeId;
		accountGE.IATACode__c = '99999999';
		accountGE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountGE.Status__c = 'Approved';
		accountGE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
    accountGE.Remittance_frequency__c = 'D';

    insert accountGE;

    Account accountUkHE = new Account();
		accountUkHE.Name = 'Multicountry HE UK';
		accountUkHE.ParentId = accountGE.Id;
		accountUkHE.Location_Type__c = AMS_Utils.HE;
		accountUkHE.Location_Class__c = 'P';
		accountUkHE.IATA_ISO_Country__c = countryUK.Id;
		accountUkHE.RecordTypeId = agencyRecTypeId;
		accountUkHE.IATACode__c = '99999998';
		accountUkHE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountUkHE.Status__c = 'Approved';
		accountUkHE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
    accountUkHE.Remittance_frequency__c = 'D';

		Account accountFrHE = new Account();
		accountFrHE.Name = 'Multicountry HE FR';
		accountFrHE.ParentId = accountGE.Id;
		accountFrHE.Location_Type__c = AMS_Utils.HE;
		accountFrHE.Location_Class__c = 'P';
		accountFrHE.IATA_ISO_Country__c = countryFR.Id;
		accountFrHE.RecordTypeId = agencyRecTypeId;
		accountFrHE.IATACode__c = '99999997';
		accountFrHE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountFrHE.Status__c = 'Approved';
		accountFrHE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
    accountFrHE.Remittance_frequency__c = 'D';

		Account accountAE = new Account();
		accountAE.Name = 'Multicountry AE PT';
		accountAE.ParentId = accountGE.Id;
		accountAE.Location_Type__c = AMS_Utils.AE;
		accountAE.Location_Class__c = 'P';
		accountAE.IATA_ISO_Country__c = countryPT.Id;
		accountAE.RecordTypeId = agencyRecTypeId;
		accountAE.IATACode__c = '99999996';
		accountAE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountAE.Status__c = 'Approved';
		accountAE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
    accountAE.Remittance_frequency__c = 'D';

		Account accountAE_2 = new Account();
		accountAE_2.Name = 'Multicountry AE PT 2';
		accountAE_2.ParentId = accountGE.Id;
		accountAE_2.Location_Type__c = AMS_Utils.AE;
		accountAE_2.Location_Class__c = 'P';
		accountAE_2.IATA_ISO_Country__c = countryPT.Id;
		accountAE_2.RecordTypeId = agencyRecTypeId;
		accountAE_2.IATACode__c = '99999995';
		accountAE_2.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountAE_2.Status__c = 'Approved';
		accountAE_2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
    accountAE_2.Remittance_frequency__c = 'D';

		insert new List<Account>{accountUkHE, accountFrHE, accountAE, accountAE_2};

    Account accountUkAE = new Account();
		accountUkAE.Name = 'Multicountry AE UK';
		accountUkAE.ParentId = accountUkHE.Id;
		accountUkAE.Location_Type__c = AMS_Utils.AE;
		accountUkAE.Location_Class__c = 'P';
		accountUkAE.IATA_ISO_Country__c = countryUK.Id;
		accountUkAE.RecordTypeId = agencyRecTypeId;
		accountUkAE.IATACode__c = '12300094';
		accountUkAE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountUkAE.Status__c = 'Approved';
		accountUkAE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
    accountUkAE.Remittance_frequency__c = 'D';

		Account accountUkAE_2 = new Account();
		accountUkAE_2.Name = 'Multicountry AE UK 2';
		accountUkAE_2.ParentId = accountUkHE.Id;
		accountUkAE_2.Location_Type__c = AMS_Utils.AE;
		accountUkAE_2.Location_Class__c = 'P';
		accountUkAE_2.IATA_ISO_Country__c = countryUK.Id;
		accountUkAE_2.RecordTypeId = agencyRecTypeId;
		accountUkAE_2.IATACode__c = '12300093';
		accountUkAE_2.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountUkAE_2.Status__c = 'Approved';
		accountUkAE_2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
    accountUkAE_2.Remittance_frequency__c = 'D';

		Account accountFrAE = new Account();
		accountFrAE.Name = 'Multicountry AE FR';
		accountFrAE.ParentId = accountFrHE.Id;
		accountFrAE.Location_Type__c = AMS_Utils.AE;
		accountFrAE.Location_Class__c = 'P';
		accountFrAE.IATA_ISO_Country__c = countryFR.Id;
		accountFrAE.RecordTypeId = agencyRecTypeId;
		accountFrAE.IATACode__c = '12300092';
		accountFrAE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountFrAE.Status__c = 'Approved';
		accountFrAE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
    accountFrAE.Remittance_frequency__c = 'D';

		Account accountFrAE_2 = new Account();
		accountFrAE_2.Name = 'Multicountry AE FR 2';
		accountFrAE_2.ParentId = accountFrHE.Id;
		accountFrAE_2.Location_Type__c = AMS_Utils.AE;
		accountFrAE_2.Location_Class__c = 'P';
		accountFrAE_2.IATA_ISO_Country__c = countryFR.Id;
		accountFrAE_2.RecordTypeId = agencyRecTypeId;
		accountFrAE_2.IATACode__c = '12300091';
		accountFrAE_2.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountFrAE_2.Status__c = 'Approved';
		accountFrAE_2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
    accountFrAE_2.Remittance_frequency__c = 'D';

		insert new List<Account>{accountUkAE, accountUkAE_2, accountFrAE, accountFrAE_2};

    Test.stopTest();

  }

  private static ANG_Agency_Risk_Event__c generateRiskEvent(Id acctId, Id topParentAcctId, Id riskEventTypeId, Date issuedDate){
    
    ANG_Agency_Risk_Event__c are = new ANG_Agency_Risk_Event__c(
      ANG_AccountId__c = acctId,
      ANG_HE_AccountId__c = topParentAcctId,
      ANG_Risk_Type__c = riskEventTypeId,
      ANG_Issued_Date__c = issuedDate,
      ANG_Event_Status__c = ANG_Risk_Helper.STATUS_ACTIVE
    );

    return are;

  }

  @isTest static void failRiskAssessmentOneOccurrenceRiskTypesTest(){

    Account acct = [SELECT Id FROM Account WHERE Location_Type__c = :AMS_Utils.GE LIMIT 1];
    
    List<ANG_Risk_Event_Type__c> riskEventTypesLst = new List<ANG_Risk_Event_Type__c>(
      [SELECT
        Id,
        ANG_Risk_ID__c
       FROM
        ANG_Risk_Event_Type__c
       WHERE
        ANG_Risk_ID__c IN ('1', '4', '6', '10')
      ]
    );

    ANG_Agency_Risk_Event__c are = generateRiskEvent(acct.Id, acct.Id, riskEventTypesLst.get(0).Id, System.today());

    insert are;

    acct = [SELECT Id, ANG_HE_RiskHistoryAssessment__c FROM Account WHERE Id = :acct.Id];

    System.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED, acct.ANG_HE_RiskHistoryAssessment__c, 'Risk Assessment must FAIL');

  }

  @isTest static void failRiskAssessmentTwoOccurrenceRiskTypesTest(){

    Account acct = [SELECT Id FROM Account WHERE Location_Type__c = :AMS_Utils.GE LIMIT 1];

    List<ANG_Risk_Event_Type__c> riskEventTypesLst = new List<ANG_Risk_Event_Type__c>(
      [SELECT
        Id,
        ANG_Risk_ID__c
       FROM
        ANG_Risk_Event_Type__c
       WHERE
        ANG_Risk_ID__c IN ('5', '7', '8', '9', '11')
      ]
    );

    ANG_Agency_Risk_Event__c are1 = generateRiskEvent(acct.Id, acct.Id, riskEventTypesLst.get(0).Id, System.today());
    ANG_Agency_Risk_Event__c are2 = generateRiskEvent(acct.Id, acct.Id, riskEventTypesLst.get(1).Id, System.today());

    insert new List<ANG_Agency_Risk_Event__c>{are1, are2};

    acct = [SELECT Id, ANG_HE_RiskHistoryAssessment__c FROM Account WHERE Id = :acct.Id];

    System.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED, acct.ANG_HE_RiskHistoryAssessment__c, 'Risk Assessment must FAIL');

  }

  @isTest static void failRiskAssessmentOneOccurrenceMixedRiskTypesTest(){

    List<Account> acctLst = new List<Account>(
      [SELECT 
        Id, 
        Top_Parent__c,
        Location_Type__c
       FROM 
        Account 
       WHERE 
        Location_Type__c = :AMS_Utils.GE 
       OR 
        Location_Type__c = :AMS_Utils.HE
      ]
    );  

    Account accountGE = NULL;

    integer i = 0;
    for(Account acct : acctLst){
      if(acct.Location_Type__c == AMS_Utils.GE){
        accountGE = acct;
        break;
      }
      i++;
    }

    acctLst.remove(i);

    List<ANG_Risk_Event_Type__c> riskEventTypesLst = new List<ANG_Risk_Event_Type__c>(
      [SELECT
        Id,
        ANG_Risk_ID__c
       FROM
        ANG_Risk_Event_Type__c
       WHERE
        ANG_Risk_ID__c IN ('2', '3', '5', '7', '8', '9', '11')
      ]
    );

    Map<String, Id> riskEventTypeMap = new Map<String, Id>();

    for(ANG_Risk_Event_Type__c ret : riskEventTypesLst){
      riskEventTypeMap.put(ret.ANG_Risk_ID__c, ret.Id);
    }

    ANG_Agency_Risk_Event__c are1 = generateRiskEvent(accountGE.Id, accountGE.Id, riskEventTypeMap.get('5'), System.today());
    insert are1;

    Account acct = [SELECT Id, ANG_HE_RiskHistoryAssessment__c FROM Account WHERE Id = :accountGE.Id];

    System.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_PASSED, acct.ANG_HE_RiskHistoryAssessment__c, 'Risk Assessment must PASS');

    acct = acctLst.get(0);

    ANG_Agency_Risk_Event__c are2 = generateRiskEvent(acct.Id, acct.Top_Parent__c, riskEventTypeMap.get('2'), System.today());

    acct = acctLst.get(1);

    ANG_Agency_Risk_Event__c are3 = generateRiskEvent(acct.Id, acct.Top_Parent__c, riskEventTypeMap.get('3'), System.today());
    
    insert new List<ANG_Agency_Risk_Event__c>{are2, are3};

    acct = [SELECT Id, ANG_HE_RiskHistoryAssessment__c FROM Account WHERE Id = :accountGE.Id];

    System.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_PASSED, acct.ANG_HE_RiskHistoryAssessment__c, 'Risk Assessment must PASS');    

    ANG_Agency_Risk_Event__c are4 = generateRiskEvent(accountGE.Id, accountGE.Id, riskEventTypeMap.get('3'), System.today());
    insert are4;

    acct = [SELECT Id, ANG_HE_RiskHistoryAssessment__c FROM Account WHERE Id = :accountGE.Id];

    System.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED, acct.ANG_HE_RiskHistoryAssessment__c, 'Risk Assessment must FAIL');    

  }

  @isTest static void failRiskAssessmentAdjustedOnlyRiskTypesTest(){

    List<Account> acctLst = new List<Account>(
      [SELECT 
        Id, 
        Top_Parent__c,
        Location_Type__c
       FROM 
        Account 
       WHERE 
        Location_Type__c = :AMS_Utils.GE 
       OR 
        Location_Type__c = :AMS_Utils.HE
      ]
    );  

    Account accountGE = NULL;

    integer i=0;

    for(Account acct : acctLst){
      if(acct.Location_Type__c == AMS_Utils.GE){
        accountGE = acct;
        break;
      }
      i++;
    }

    acctLst.remove(i);

    List<ANG_Risk_Event_Type__c> riskEventTypesLst = new List<ANG_Risk_Event_Type__c>(
      [SELECT
        Id,
        ANG_Risk_ID__c
       FROM
        ANG_Risk_Event_Type__c
       WHERE
        ANG_Risk_ID__c IN ('2', '3')
      ]
    );
    
    Account acctGE;

    ANG_Agency_Risk_Event__c are1 = generateRiskEvent(accountGE.Id, accountGE.Id, riskEventTypesLst.get(0).Id, System.today());
    
    insert are1;

    Account acct = [SELECT Id, ANG_HE_RiskHistoryAssessment__c FROM Account WHERE Id = :accountGE.Id];

    System.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_PASSED, acct.ANG_HE_RiskHistoryAssessment__c, 'Risk Assessment must PASS');

    acct = acctLst.get(0);

    ANG_Agency_Risk_Event__c are2 = generateRiskEvent(acct.Id, acct.Top_Parent__c, riskEventTypesLst.get(0).Id, System.today());

    acct = acctLst.get(1);

    ANG_Agency_Risk_Event__c are3 = generateRiskEvent(acct.Id, acct.Top_Parent__c, riskEventTypesLst.get(1).Id, System.today());
    
    insert new List<ANG_Agency_Risk_Event__c>{are2, are3};

    acct = [SELECT Id, ANG_HE_RiskHistoryAssessment__c FROM Account WHERE Id = :accountGE.Id];

    System.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED, acct.ANG_HE_RiskHistoryAssessment__c, 'Risk Assessment must FAIL');    

  }

}