/**
 * This class contains unit tests for validating the behavior of class vfIECGADAgencyDetailsComponent
 */
@isTest
private class vfIECGADAgencyDetailsComponent_tst {

	private static Account oAgencyAccount;
	private static GDP_Reference_Table__c oRefAgencyStatus;
	private static GDP_Reference_Table__c oRefIncorporationType;
	private static GDP_Reference_Table__c oRefLocationTypeHO;
	private static GDP_Reference_Table__c oRefLocationTypeBR;
	private static GDP_Products_Account_View__c oGDPAccount1;
	private static GDP_Products_Account_View__c oGDPAccount2;

	private static final String AGENCY1_CODE = '5555555';
	private static final String AGENCY2_CODE = '6666666';
	private static final String AGENCY1_NAME = 'Chillwave Agency';
	private static final String AGENCY2_NAME = 'Chilly Cheese Agency';

    static void setupData() {

		oRefAgencyStatus = IECTestUtil.createSampleGDPReferenceTableEntry('4', 'Valid');
        insert oRefAgencyStatus;
        
        oRefIncorporationType = IECTestUtil.createSampleGDPReferenceTableEntry('i', 'Incorporated');
        insert oRefIncorporationType;
        
        oRefLocationTypeHO = IECTestUtil.createSampleGDPReferenceTableEntry('HO', 'Head Office');
        insert oRefLocationTypeHO;
        
        oRefLocationTypeBR = IECTestUtil.createSampleGDPReferenceTableEntry('BR', 'Branch');
        insert oRefLocationTypeBR;

        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'); 
        
        oAgencyAccount = IECTestUtil.createSampleAccount();
        oAgencyAccount.Name = AGENCY1_NAME;
        oAgencyAccount.IATACode__c = AGENCY1_CODE;
        oAgencyAccount.Status__c = 'Approved';
        oAgencyAccount.RecordTypeId = rtId;
        insert oAgencyAccount;
        
        oGDPAccount1 = IECTestUtil.createSampleGDPAccount(AGENCY1_NAME, AGENCY1_CODE, oRefAgencyStatus, oRefIncorporationType, oRefLocationTypeHO);
        insert oGDPAccount1;
        
        oGDPAccount2 = IECTestUtil.createSampleGDPAccount(AGENCY2_NAME, AGENCY2_CODE, oRefAgencyStatus, oRefIncorporationType, oRefLocationTypeBR);
        // make account 1 parent of account 2
        oGDPAccount2.Parent_GDP_Account_View__c = oGDPAccount1.Id; 
        insert oGDPAccount2;
	}
	
	@isTest
	static void testDisplayAgencyDetails() {
    	setupData();
        try {
     		vfIECGADAgencyDetailsComponent controller = new vfIECGADAgencyDetailsComponent();
     		
     		// Test #1 - no agency id provided
 			// trigger the getter
 			GDP_Products_Account_View__c oTestAgency = controller.oAgency;
 			system.assertEquals(null, oTestAgency, 'Agency should not be found');
     		
     		// Test #2 - provide agency id
     		controller.sAgencyID = oGDPAccount2.Id;
     		system.assert(controller.oAgency != null && controller.oAgency.Id == oGDPAccount2.Id, 'The account 2 should be found');
     		
     		// Test #3 - don't provide parent agency id
 			controller.loadParentAgency();
 			GDP_Products_Account_View__c oTestParentAgency = controller.oParentAgency;
 			system.assertEquals(null, oTestParentAgency, 'Agency should not be found');
     		
     		// Test #4 - provide parent agency id
     		controller.sParentAgencyID = oGDPAccount2.Parent_GDP_Account_View__c;
     		controller.loadParentAgency();
     		system.assert(controller.oParentAgency != null && controller.oParentAgency.Id == oGDPAccount1.Id, 'The account 1 should be found');
     	}
     	catch (Exception ex) {
     		system.assert(false, 'testDisplayAgencyDetails should not throw any exception');
     	}
    }
}