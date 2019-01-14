@isTest
public class PostCopyScriptTest {
    
    @testSetup
    static void setup() {
        
		final String PROFILE_NAME = 'System Administrator';
        
        List<PermissionSet> permissionSets = new List<PermissionSet>();
        permissionSets = [SELECT Id FROM PermissionSet WHERE Name = 'IEC_GDP_Customer' LIMIT 1];
        String customerPermissionSetId = permissionSets.get(0).Id;
        
        List<ApexClass> apexClasses = new List<ApexClass>();
        apexClasses = [SELECT Id, Name FROM ApexClass WHERE Name = 'SchdlIECCompileUsage' or Name = 'SchdlCACWSUsageUpdate' LIMIT 2];
        String schdlIECCompileUsageClassID = '';
        String schdlCACWSUsageUpdateClassID = '';
        if(apexClasses.get(0).Name.equals('SchdlIECCompileUsage')) {
            
            schdlIECCompileUsageClassID = apexClasses.get(0).Id;
            schdlCACWSUsageUpdateClassID = apexClasses.get(1).Id;
            
        } else {
            
            schdlCACWSUsageUpdateClassID = apexClasses.get(0).Id;
            schdlIECCompileUsageClassID = apexClasses.get(1).Id;
            
        }      
        
        User testUser = TestDataGenerator.generateUser(PROFILE_NAME, false);
        insert testUser;
        
        System.runAs(testUser) {
            
            AMS_BSPLink_Integration__c rec1 = new AMS_BSPLink_Integration__c(
                SetupOwnerId = UserInfo.getOrganizationId(), 
                Name = 'Test AMS_BSPLink_Integration__c');
            insert rec1;
            
            AMS_SAP_Settings__c rec2 = new AMS_SAP_Settings__c(
                SetupOwnerId = UserInfo.getOrganizationId(), 
                Name = 'Test AMS_SAP_Settings__c', 
                Batch_Size__c = '3', 
                Web_Service_endpoint__c = 'test endpoint');
            insert rec2;
            
            IEC_SAP_Settings__c rec3 = new IEC_SAP_Settings__c(
                SetupOwnerId = UserInfo.getOrganizationId(), 
                Name = 'Test IEC_SAP_Settings__c');
            insert rec3;
            
            IEC_Settings__c rec4 = new IEC_Settings__c(
                SetupOwnerId = UserInfo.getOrganizationId(), 
                Name = 'Test IEC_Settings__c',
            	Customer_Permission_Set_Id__c = customerPermissionSetId, 
                PaymentMethod_Bank_Transfer_Zuora_ID__c = '4028e4873091b2d0013091d11081363c', 
                PaymentMethod_Other_Zuora_ID__c = '4028e4862fdd7ba4012fe05551482b78', 
                Quote_Template_Zuora_ID_New_Subscription__c = '2c92a0f93db48dac013dd50e05ef1814', 
                SchdlIECCompileUsage_Class_ID__c = schdlIECCompileUsageClassID, 
                CAC_Web_Service_API_Gateway__c = 'rRBxixUokH4MrUyfbps2Q2en4a6b0Re02zAJB9Wa', 
                CAC_Web_Service_Usage_Url__c = 'https://globaldata.developer.iata.org/v1a/checkacode', 
                SchdlCACWSUsageUpdate_Class_ID__c = schdlCACWSUsageUpdateClassID);
            insert rec4;
            
            HPM_Setting__c rec5 = new HPM_Setting__c(
                Name = 'Test HPM_Setting__c');
            insert rec5;
			
			ISSP_Kavi_Settings__c rec6 = new ISSP_Kavi_Settings__c(
                Name = 'Test ISSP_Kavi_Settings__c');
            insert rec6;

        }
        
    }
    

	@isTest
	static void testDeleteCustomSettings() {
        
        final String PROFILE_NAME = 'System Administrator';

		List<AMS_BSPLink_Integration__c> listRecords1 = new List<AMS_BSPLink_Integration__c>();
		listRecords1 = [SELECT id From AMS_BSPLink_Integration__c];

		List<AMS_SAP_Settings__c> listRecords2 = new List<AMS_SAP_Settings__c>();
		listRecords2 = [SELECT id From AMS_SAP_Settings__c];

		List<IEC_SAP_Settings__c> listRecords3 = new List<IEC_SAP_Settings__c>();
		listRecords3 = [SELECT id From IEC_SAP_Settings__c];

		List<IEC_Settings__c> listRecords4 = new List<IEC_Settings__c>();
		listRecords4 = [SELECT id From IEC_Settings__c];

		List<HPM_Setting__c> listRecords5 = new List<HPM_Setting__c>();
		listRecords5 = HPM_Setting__c.getAll().values();
		
		List<ISSP_Kavi_Settings__c> listRecords6 = new List<ISSP_Kavi_Settings__c>();
		listRecords6 = ISSP_Kavi_Settings__c.getAll().values();

		Integer numRecords = listRecords1.size() + listRecords2.size() + listRecords3.size() + listRecords4.size() + listRecords5.size() + listRecords6.size();

		if(numRecords!=0) {
            
            System.assertNotEquals(numRecords, 0);

			Test.startTest();

			PostCopyScript script = new PostCopyScript();
            script.deleteCustomSettingsRecords();

			listRecords1 = new List<AMS_BSPLink_Integration__c>();
			listRecords1 = [SELECT id From AMS_BSPLink_Integration__c];

			listRecords2 = new List<AMS_SAP_Settings__c>();
			listRecords2 = [SELECT id From AMS_SAP_Settings__c];

			listRecords3 = new List<IEC_SAP_Settings__c>();
			listRecords3 = [SELECT id From IEC_SAP_Settings__c];

			listRecords4 = new List<IEC_Settings__c>();
			listRecords4 = [SELECT id From IEC_Settings__c];

			listRecords5 = new List<HPM_Setting__c>();
			listRecords5 = HPM_Setting__c.getAll().values();
			
			listRecords6 = new List<ISSP_Kavi_Settings__c>();
			listRecords6 = ISSP_Kavi_Settings__c.getAll().values();

			numRecords = listRecords1.size() + listRecords2.size() + listRecords3.size() + listRecords4.size() + listRecords5.size() + listRecords6.size();

			System.assertEquals(numRecords, 0);
            
            Test.stopTest();
                
		}
		
	}

}