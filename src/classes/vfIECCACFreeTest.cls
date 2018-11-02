@isTest
private class vfIECCACFreeTest {
	
	@isTest static void vfIECCACFreeTest() {
		List<ID_Card__c> listIDCard = new List<ID_Card__c>(); 
		ID_Card__c oIDCard = IECTestUtil.createSampleIDCard('John', 'Doe', '55780005', 'test', '55780005', 'Valid ID Card');
        oIDCard.Valid_To_Date__c = Date.today().addYears(1);
        oIDCard.Valid_From_Date__c = Date.today();
        listIDCard.add(oIDCard);

        oIDCard = IECTestUtil.createSampleIDCard('John', 'Doe', '5578000523', 'test', '12312312', 'Valid ID Card');
        listIDCard.add(oIDCard);
        insert listIDCard;
        GDP_Reference_Table__c oRefAgencyStatus = IECTestUtil.createSampleGDPReferenceTableEntry('4', 'Valid');
        insert oRefAgencyStatus;

        GDP_Reference_Table__c oAgencyPassengerClass =  IECTestUtil.createSampleGDPReferenceTableEntry('P', 'Passenger');
        oAgencyPassengerClass.Code__c = 'P';
        oAgencyPassengerClass.Name = 'Passenger';
        oAgencyPassengerClass.System__c = 'Global';
        oAgencyPassengerClass.Table__c = 'ORGCLASS';
        insert oAgencyPassengerClass;

        GDP_Products_Account_View__c gdp = new GDP_Products_Account_View__c(IATA_Code__c = '5578000', Check_Digit__c = '5');
		insert gdp;

		GDP_Products_Account_View__c gdp2 = new GDP_Products_Account_View__c(IATA_Code__c = '1231231', Check_Digit__c = '5');
		insert gdp2;

		GDP_Products_Account_View__c gdp3 = new GDP_Products_Account_View__c(IATA_Code__c = '12312312321', Check_Digit__c = '5');
		insert gdp3;

		Accreditation__c oAccreditation1 = IECTestUtil.CreateSampleAccreditation(null, gdp, 'GDP');
        oAccreditation1.Status__c = oRefAgencyStatus.Id;
        oAccreditation1.Class__c = oAgencyPassengerClass.Id;
        insert oAccreditation1;

        gdp.Related_Accreditation_Class__c = oAccreditation1.Id;
        update gdp;

		CAC_and_GAD_Settings__c CacGadSettings = new CAC_and_GAD_Settings__c();
        CacGadSettings.Name = 'Excluded Values';
        CacGadSettings.Excluded_CAC_Location_Classes__c = 'A;I;L;Q;R;U;Y;Z';
        CacGadSettings.Excluded_GAD_Location_Classes__c = 'A;I;L;Q;R;U;Y;Z;C;X';
        insert CacGadSettings;

		
		IEC_Settings__c iecSettings = IEC_Settings__c.getOrgDefaults();
		vfIECCACFree cont = new vfIECCACFree();
		//has account 7 digis
		cont.sValidationCode = '1231231';
		cont.validateCode();
		//error account 7 digis
		cont.sValidationCode = '1231232';
		cont.validateCode();
		cont.sValidationCode = '12312312';
		cont.validateCode();
		cont.sValidationCode = '55780005';
		cont.validateCode();
		cont.sValidationCode = '12312312321';
		cont.validateCode();
		//exists idcard 10 digits
		cont.sValidationCode = '5578000523';		
		cont.validateCode();
		//don't 10 digis
		cont.sValidationCode = '1231231231';		
		cont.validateCode();
		cont.pageLoad();
		cont.sValidationCode = '123123123214214';
		cont.iRECAPTCHACount = 21;
		cont.validateCode();
		//error code with letter
		cont.sValidationCode = '1231231d';
		cont.whichcountry= 'CN';
		cont.validateCode();


	}	
}