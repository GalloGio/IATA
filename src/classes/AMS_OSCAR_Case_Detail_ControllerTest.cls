@isTest
private class AMS_OSCAR_Case_Detail_ControllerTest {
	
	@testSetup static void setup(){
        //AMS_OSCAR_TestDataFactory.createOSCARtestData();
        AMS_OSCAR_TestDataFactory.createOSCARtestDataAccHier();
		AMS_OSCAR__c oscar = [SELECT Id, Account__c FROM AMS_OSCAR__c limit 1];
		Case c = [SELECT Id FROM Case WHERE Oscar__c = :oscar.Id];

		AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(
			SAAM_Case__c = c.id,
			CASS_Number__c = '123',
			Location_Class__c = 'C',
			IATA_ISO_State__c = [SELECT Id FROM IATA_ISO_State__c LIMIT 1][0].Id,
			Branch_Office_Country__c = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1][0].Id
		);
		insert accre;

		oscar.Process__c = AMS_Utils.AGENCYCHANGES;
		oscar.AMS_Online_Accreditation__c = accre.Id;
		update oscar;

		ANG_AgencyChangesConfig__c confs = new ANG_AgencyChangesConfig__c(
			Name ='Combination07',
			TC_VMFR__c = true,
			TCA_Sanity_check__c = 'CAD',
			TCA_Application_withdrawal__c = 'CWD'
			);

		insert confs;

	}
	
	@isTest static void test_OSCARCaseDetail() {
		Case c = [SELECT Id FROM Case WHERE Oscar__c IN (SELECT Id FROM AMS_OSCAR__c WHERE AMS_Online_Accreditation__c != '') LIMIT 1];

		PageReference pg = Page.AMS_OSCAR_GeneralDetailsPage;
		pg.getParameters().put('id', c.Id);
		Test.setCurrentPage(pg);
		
		Test.startTest();

			AMS_OSCAR_Case_Detail_Controller controller = new AMS_OSCAR_Case_Detail_Controller();
			controller.cancel();
			controller.save();

			System.assert(controller.saveAction, 'Error saving');
			System.assert(!controller.hasEditableFields, 'Found editable fields');
			System.assert(controller.getExistOscarInspections(), 'No inspections found');
			System.assert(!controller.getRfPicklistValues().isEmpty());

            Id idCorrRT = controller.corrRT;
            Boolean bIsVATnumberSpecialCase = controller.isVATnumberSpecialCase;
            Boolean bIsBranchAbroadSelected = controller.isBranchAbroadSelected;
            bIsVATnumberSpecialCase = controller.isVATnumberSpecialCase;
            bIsBranchAbroadSelected = controller.isBranchAbroadSelected;

		Test.stopTest();
	}

	@isTest static void test_OSCARCaseDetail2(){
        Test.startTest();
        
		Case c = [SELECT Id FROM Case WHERE Oscar__c IN (SELECT Id FROM AMS_OSCAR__c WHERE AMS_Online_Accreditation__c != '') LIMIT 1];

		Id aRTId = Schema.Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Standard Account').getRecordTypeId();

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(
			Name= 'Testland',
			Region__c = 'Americas',
			Iso_code__c = 'TL',
			ISO_Code_Numeric__c=99,
			BSP__c = 'Yes',
			ANG_Enable_NewGen__c = true,
			OSCAR_enabled__c = true
		);

		insert country;

		Account a = new Account(
			Name='TesteAccount',
			Location_Class__c = 'P',
			Location_Type__c = 'HE',
			Reason_for_creation__c = 'Headquarter is missing',
			RecordTypeId = aRTId,
			IATA_ISO_Country__c = country.id
		);

		insert a;


			AMS_Pax_Accreditation_Form__c accredForm = [SELECT Id, Branch_Office_Country__c FROM AMS_Pax_Accreditation_Form__c][0];

			accredForm.Branch_Office_Country__c = country.Id;
			accredForm.Location_Class__c = 'P';
			accredForm.CASS_Number__c = '';

			update accredForm;

			AMS_Oscar__c oscar = [SELECT Id, Process__c, Account__c, ANG_Type_Of_Change__c FROM AMS_OSCAR__c WHERE AMS_Online_Accreditation__c != ''];

			oscar.Account__c = a.Id;
			oscar.Process__c = AMS_Utils.NEWHELITE;

			update oscar;

			Id settlementRTId = Schema.AMS_Settlement_System__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('BSP').getRecordTypeId();

			AMS_Settlement_System__c settlement = new AMS_Settlement_System__c(
				Name = 'test settlement',
				RecordTypeId = settlementRTId
			);

			insert settlement;

			AMS_Operation__c opCode = new AMS_Operation__c(
				Name = 'test operation',
				Settlement__c = settlement.id,
				Allow_multiple_remittances__c = false,
				Country__c = country.id
			);

			insert opCode;

			List<ANG_BSP_Attributes__c> bSPAttributes = new List<ANG_BSP_Attributes__c>();

			ANG_BSP_Attributes__c bSPAttributes1 = new ANG_BSP_Attributes__c(
				Class_Type__c  = 'P',
				Remittance_Frequency__c = 'D',
				Operation__c = opCode.Id
			);
			bSPAttributes.add(bSPAttributes1);

				ANG_BSP_Attributes__c bSPAttributes2 = new ANG_BSP_Attributes__c(
				Class_Type__c  = 'P',
				Remittance_Frequency__c = 'V',
				Operation__c = opCode.Id
			);
			bSPAttributes.add(bSPAttributes2);
			
			insert bSPAttributes;

			AMS_Agency_Operations__c agencyOp = new AMS_Agency_Operations__c(
				Account__c = a.id,
				Operation__c = opCode.Id
			);

			insert agencyOp;


			PageReference pg = Page.AMS_OSCAR_GeneralDetailsPage;
			pg.getParameters().put('id', c.Id);
			Test.setCurrentPage(pg);

			AMS_OSCAR_Case_Detail_Controller controller = new AMS_OSCAR_Case_Detail_Controller();	
					
			controller.accreditationObj.Remittance_Frequency__c = controller.getRfPicklistValues()[0].getValue();

			controller.save();
			
			opCode.Allow_multiple_remittances__c = true;
			update opcode;

			controller = new AMS_OSCAR_Case_Detail_Controller();

			controller.oscarobj.RecordTypeId = AMS_Utils.RECTYPE_NGCHANGES;
			controller.oscarobj.Process__c = AMS_Utils.NGCHANGES;
			controller.oscarobj.ANG_Type_Of_Change__c = 'VMFR';

			System.assert(!controller.getRfPicklistValues().isEmpty());

			System.assert(controller.remittanceFrequencyToShow == '');

			controller.accreditationObj.Remittance_Frequency__c = 'V';

			System.assert(controller.remittanceFrequencyToShow.contains('Weekly'));

			controller.accreditationObj.Remittance_Frequency__c = 'V;D';

			System.assert(controller.remittanceFrequencyToShow.contains('Daily'));
			System.assert(controller.isNewAE == false);
			System.assert(controller.displayErrorMsg == false);

		Test.stopTest();
	}
	
    @isTest static void test_OSCARCaseDetail3(){
        
        AMS_OSCAR__c oscar = [SELECT Id, AMS_Online_Accreditation__c FROM AMS_OSCAR__c WHERE AMS_Online_Accreditation__c != '' LIMIT 1];

        Id aRTId = Schema.Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Standard Account').getRecordTypeId();

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(
            Name= 'Testland',
            Region__c = 'Americas',
            Iso_code__c = 'TL',
            ISO_Code_Numeric__c=99,
            BSP__c = 'Yes',
            ANG_Enable_NewGen__c = true,
            OSCAR_enabled__c = true
        );

        insert country;
        Test.startTest();
        
        Account a = new Account(
            Name='TesteAccount',
            Location_Class__c = 'P',
            Location_Type__c = 'HE',
            Reason_for_creation__c = 'Headquarter is missing',
            RecordTypeId = aRTId,
            IATA_ISO_Country__c = country.id
        );

        insert a;   

        AMS_Pax_Accreditation_Form__c accredForm = [SELECT Id, Branch_Office_Country__c FROM AMS_Pax_Accreditation_Form__c WHERE Id = :oscar.AMS_Online_Accreditation__c];

        accredForm.Branch_Office_Country__c = country.Id;
        accredForm.Location_Class__c = 'P';
        accredForm.CASS_Number__c = '';

        update accredForm;      

        Id settlementRTId = Schema.AMS_Settlement_System__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('BSP').getRecordTypeId();

        AMS_Settlement_System__c settlement = new AMS_Settlement_System__c(
            Name = 'test settlement',
            RecordTypeId = settlementRTId
        );

        insert settlement;

        AMS_Operation__c opCode = new AMS_Operation__c(
            Name = 'test operation',
            Settlement__c = settlement.id,
            Allow_multiple_remittances__c = true,
            Country__c = country.id
        );

        insert opCode;

        ANG_BSP_Attributes__c bSPAttributes = new ANG_BSP_Attributes__c(
            Class_Type__c  = 'P',
            Remittance_Frequency__c = 'V',
            Operation__c = opCode.Id
        );

        insert bSPAttributes;

        AMS_Agency_Operations__c agencyOp = new AMS_Agency_Operations__c(
            Account__c = a.id,
            Operation__c = opCode.Id
        );

        insert agencyOp;


        PageReference pg = Page.AMS_OSCAR_GeneralDetailsPage;
        pg.getParameters().put('id', oscar.Id);
        Test.setCurrentPage(pg);

        AMS_OSCAR_Case_Detail_Controller controller = new AMS_OSCAR_Case_Detail_Controller();   
                
        controller.getRfPicklistValuesAMS();


		Test.stopTest();
	}

	@isTest static void chinaConversionHideStagingAreaTest(){

		Case c = [SELECT Id, OSCAR__c FROM Case WHERE Oscar__c IN (SELECT Id FROM AMS_OSCAR__c WHERE AMS_Online_Accreditation__c != '') LIMIT 1];

		AMS_OSCAR__c oscar = new AMS_OSCAR__c();
		
		oscar.id = c.OSCAR__c;
		oscar.Process__c = AMS_Utils.NGCHINACONVERSION;
		
		update oscar;
		
		PageReference pg = Page.AMS_OSCAR_GeneralDetailsPage;
		pg.getParameters().put('id', c.Id);
		Test.setCurrentPage(pg);
		
		AMS_OSCAR_Case_Detail_Controller controller = new AMS_OSCAR_Case_Detail_Controller();
		
		system.assert(!controller.showStagingArea, 'The staging area for China Conversions should be hidden');

	}

}