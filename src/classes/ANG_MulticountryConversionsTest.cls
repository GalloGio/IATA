@isTest
private class ANG_MulticountryConversionsTest {

  @testSetup static void setup(){

    Test.startTest();

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

    Account standardHePT = new Account();
    standardHePT.Name = 'Standard HE PT';
    standardHePT.Location_Type__c = AMS_Utils.HE;
    standardHePT.Location_Class__c = 'P';
    standardHePT.IATA_ISO_Country__c = countryPT.Id;
    standardHePT.RecordTypeId = agencyRecTypeId;
    standardHePT.IATACode__c = '999999999';
    standardHePT.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
    standardHePT.Status__c = 'Approved';
    standardHePT.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;

    Account standardHeUK = new Account();
    standardHeUK.Name = 'Standard HE UK';
    standardHeUK.Location_Type__c = AMS_Utils.HE;
    standardHeUK.Location_Class__c = 'P';
    standardHeUK.IATA_ISO_Country__c = countryUK.Id;
    standardHeUK.RecordTypeId = agencyRecTypeId;
    standardHeUK.IATACode__c = '999999998';
    standardHeUK.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
    standardHeUK.Status__c = 'Approved';
    standardHeUK.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;

    Account standardHeFR = new Account();
    standardHeFR.Name = 'Standard HE FR';
    standardHeFR.Location_Type__c = AMS_Utils.HE;
    standardHeFR.Location_Class__c = 'P';
    standardHeFR.IATA_ISO_Country__c = countryFR.Id;
    standardHeFR.RecordTypeId = agencyRecTypeId;
    standardHeFR.IATACode__c = '999999997';
    standardHeFR.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
    standardHeFR.Status__c = 'Approved';
    standardHeFR.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;
    
    insert new List<Account>{standardHePT, standardHeUK, standardHeFR};

    Account standardAePT = new Account();
    standardAePT.Name = 'Standard AE PT';
    standardAePT.ParentId = standardHePT.Id;
    standardAePT.Location_Type__c = AMS_Utils.AE;
    standardAePT.Location_Class__c = 'P';
    standardAePT.IATA_ISO_Country__c = countryPT.Id;
    standardAePT.RecordTypeId = agencyRecTypeId;
    standardAePT.IATACode__c = '999999996';
    standardAePT.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
    standardAePT.Status__c = 'Approved';
    standardAePT.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;

    Account standardAeUK = new Account();
    standardAeUK.Name = 'Standard AE UK';
    standardAeUK.ParentId = standardHeUK.Id;
    standardAeUK.Location_Type__c = AMS_Utils.AE;
    standardAeUK.Location_Class__c = 'P';
    standardAeUK.IATA_ISO_Country__c = countryUK.Id;
    standardAeUK.RecordTypeId = agencyRecTypeId;
    standardAeUK.IATACode__c = '999999995';
    standardAeUK.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
    standardAeUK.Status__c = 'Approved';
    standardAeUK.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;

    Account standardAeFR = new Account();
    standardAeFR.Name = 'Standard AE FR';
    standardAeFR.ParentId = standardHeFR.Id;
    standardAeFR.Location_Type__c = AMS_Utils.AE;
    standardAeFR.Location_Class__c = 'P';
    standardAeFR.IATA_ISO_Country__c = countryUK.Id;
    standardAeFR.RecordTypeId = agencyRecTypeId;
    standardAeFR.IATACode__c = '999999994';
    standardAeFR.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
    standardAeFR.Status__c = 'Approved';
    standardAeFR.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;

    insert new List<Account>{standardAePT, standardAeUK, standardAeFR};

    Contact cont = new Contact();
    cont.AccountId = standardHePT.Id;
    cont.Firstname = 'Richard';
    cont.Lastname = 'Vaughan';
    cont.Phone = '666123456';
    cont.MobilePhone = '911111111';
    cont.Email = 'richard.vaughan@test.com';
    cont.Financial_Assessment_Contact__c = false;

    insert cont;

    AMS_OSCAR__c oscar = new AMS_OSCAR__c();
    oscar.Account__c = standardHePT.Id;
    oscar.Process__c = AMS_Utils.NGCONVERSIONTOMULTICOUNTRY;
    oscar.RecordTypeId = AMS_Utils.RECTYPE_NGCONVERSIONTOMULTICOUNTRY;

    insert oscar;

    Case oscarCase = new Case();
    oscarCase.Oscar__c = oscar.Id;
    oscarCase.RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM;
    oscarCase.AccountId = standardHePT.Id;
    oscarCase.ContactId = cont.Id;

    insert oscarCase;

    AMS_Pax_Accreditation_Form__c staging = new AMS_Pax_Accreditation_Form__c();

    staging.RecordTypeId = AMS_Utils.RECTYPE_NEWGEN_CHANGES_PAX;
    staging.Account_Name__c = standardHePT.Name;
    staging.ISSP_AMS_Legal_Status__c = 'Association';
    staging.Branch_Office_Country__c = standardHePT.IATA_ISO_Country__c;
    staging.Branch_Office_Street_name_number__c = 'sdfsdf';
    staging.Branch_Office_City__c = 'sdfsdfdf';
    staging.Branch_Office_Email__c = 'sdfsdfgdg@f3434.com';
    staging.Branch_Office_Phone__c = '123123123';
    staging.ISSP_AMS_Premises_located_at_airport__c = 'No';
    staging.Abbreviated_name__c = 'Cash ';
    staging.Abbreviated_Address__c = 'sdfsdf';
    staging.Solicitation_Flag__c = false;
    staging.Location_Class__c = standardHePT.Location_Class__c;
    staging.Location_Type__c = standardHePT.Location_Type__c;
    staging.SAAM_Case__c = oscarCase.Id;
    staging.ANG_Accreditation_type__c = AMS_Utils.ACCREDITATIONMODEL_CASH;

    insert staging;

    AMS_Accreditation_Contact__c acontact = new AMS_Accreditation_Contact__c();

    acontact.AMS_Pax_Accreditation_Form__c = staging.Id; 
    acontact.First_name__c = 'Richard'; 
    acontact.Last_name__c = 'Vaughan'; 
    acontact.Agency_owner__c = true;
    acontact.Email__c = 'richard.vaughan@test.com'; 
    acontact.PhoneNational__c = '123123123';
    acontact.Phone__c = '123123123'; 
    acontact.Contact__c = cont.Id;
    acontact.Financial_interest__c = 100;
    acontact.RecordTypeId = AMS_Utils.AccreditationContactPersonRT;

    insert acontact;

    oscar.AMS_Online_Accreditation__c = staging.Id;
    oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;

    update oscar;

    Test.stopTest();
   
  }

  @isTest static void conversionAccountSelectionTest(){
	
    AMS_OSCAR__c oscar = 
      [SELECT 
        Id,
        STEP45__c,
        Process__c, 
        Account__c, 
        RecordTypeId, 
        New_Parent__c 
       FROM 
        AMS_OSCAR__c 
       LIMIT 1
      ];

    system.debug('OSCAR: ' + oscar);

    PageReference pageRef = Page.ANG_MulticountryConversionAccountSelect;
    Test.setCurrentPage(pageRef);

    ApexPages.StandardController stdOscarCtrl = new ApexPages.StandardController(oscar);

    ANG_MulticountryConversionAccountSelCtrl controller = new ANG_MulticountryConversionAccountSelCtrl(stdOscarCtrl); 

    System.assertEquals(2, controller.noteList.size(), 'Two notes must be present');
    System.assertEquals(1, controller.heAccountSelectionLst.size(), 'Only one HE must be on the selected HE\'s');
    System.assertEquals(2, controller.accountSelectionLst.size(), 'Only two accounts must be on the selected list');

    System.assertEquals(0, controller.currentPage, 'Must be the first page (0)');
    System.assertEquals(1, controller.totalPages, 'Total pages must be 1');
    System.assertEquals(true, controller.getDisablePrevious(), 'Previous button must be disabled');
    System.assertEquals(true, controller.getDisableNext(), 'Next button must be disabled');

    System.assertEquals(false, controller.readOnly, 'The page must NOT be read only');

    controller.save();

    controller = new ANG_MulticountryConversionAccountSelCtrl(stdOscarCtrl);

    List<Account> accountLst = new List<Account>(
      [SELECT
        Id,
        Location_Type__c
       FROM
        Account
       WHERE
        Id <> :oscar.Account__c
       AND
        Location_Type__c = :AMS_Utils.HE
      ]
    );

    controller.oscar.New_Parent__c = accountLst.get(0).Id;
    controller.addHierarchyFromHE();

    //Try to add duplicated values
    controller.oscar.New_Parent__c = accountLst.get(0).Id;
    controller.addHierarchyFromHE();

    System.assertEquals(2, controller.heAccountSelectionLst.size(), 'Only two HE must be on the selected HE\'s');
    System.assertEquals(4, controller.accountSelectionLst.size(), 'Only four accounts must be on the selected list');

    //Try to click add without a selected account
    controller.oscar.New_Parent__c = null;
    controller.addHierarchyFromHE();    
    
    controller.oscar.New_Parent__c = accountLst.get(1).Id;
    controller.addHierarchyFromHE();   

    System.assertEquals(3, controller.heAccountSelectionLst.size(), 'Only three HE must be on the selected HE\'s');
    System.assertEquals(6, controller.accountSelectionLst.size(), 'Only six accounts must be on the selected list');

    controller.save();

    controller = new ANG_MulticountryConversionAccountSelCtrl(stdOscarCtrl);

    integer indexToRemove = 0;

    for(ANG_MulticountryConversionAccountSelCtrl.SelectedAccountWrapper saw : controller.heAccountSelectionLst){
      if(saw.acct.Id == oscar.Account__c){
      break;
      }
      indexToRemove++;
    }

    //Try to remove the account associated with the OSCAR
    controller.heAccountIndex = indexToRemove;
    controller.removeHeAccount();

    System.assert(findApexPagesMessage(ANG_MulticountryConversionAccountSelCtrl.CANNOT_REMOVE_HE_ERROR));

    controller.heAccountIndex = indexToRemove > 0 ? (indexToRemove-1) : (indexToRemove+1);
    controller.removeHeAccount();

    System.assertEquals(2, controller.heAccountSelectionLst.size(), 'Only two HE must be on the selected HE\'s');
    System.assertEquals(4, controller.accountSelectionLst.size(), 'Only four accounts must be on the selected list');

    controller.save();

    System.assertEquals(true, controller.closeTab, 'The tab must be closed');

    controller = new ANG_MulticountryConversionAccountSelCtrl(stdOscarCtrl);

    controller.rowsPerPage = 1;

    System.assertEquals(2, controller.heAccountSelectionLst.size(), 'Only two HE must be on the selected HE\'s');
    System.assertEquals(1, controller.accountSelectionLst.size(), 'Only one account must be on the selected list with 1 row per page');

    System.assertEquals(true, controller.getDisablePrevious(), 'Previous button must be disabled');
    System.assertEquals(false, controller.getDisableNext(), 'Next button must NOT be disabled');
    
    controller.beginning();
    controller.next();
    controller.previous();
    controller.end();

    System.assertEquals(false, controller.getDisablePrevious(), 'Previous button must NOT be disabled');
    System.assertEquals(true, controller.getDisableNext(), 'Next button must be disabled');

    Test.startTest();

    oscar.STEP45__c = AMS_Utils.PASSED;
    update oscar;

    Test.stopTest();
    
    stdOscarCtrl = new ApexPages.StandardController(oscar);

    controller = new ANG_MulticountryConversionAccountSelCtrl(stdOscarCtrl);

    System.assertEquals(true, controller.readOnly, 'The page must be read only');

  }

  private static Boolean findApexPagesMessage(String expectedMessage){
		
	  ApexPages.Message[] pageMessages = ApexPages.getMessages();
		
	  System.assertNotEquals(0, pageMessages.size());

	  Boolean messageFound = false;

	  for(ApexPages.Message message : pageMessages) {			
		  if(message.getDetail().contains(expectedMessage)){
		  	return true;
		  }
	  }

	  return false;
	
	}

}