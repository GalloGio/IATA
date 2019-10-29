@isTest
public class NDCAccountServiceDetailHelper_Test {
    
	@isTest
    public static void testNdcLogicInsert() {
		NDC_Account_Service_Detail__c det = new NDC_Account_Service_Detail__c(Contact_Email__c = 'example@example.com');
        
        test.startTest();
        insert det;
        test.stopTest();
        
        NDC_Account_Service_Detail__c detResultInsert = [SELECT NDC_Rich_Content_Types__c, NDC_Type_of_CC_Accepted__c 
                                                         FROM NDC_Account_Service_Detail__c 
                                                         WHERE Contact_Email__c = 'example@example.com'];
        
        system.assertEquals(null, detResultInsert.NDC_Rich_Content_Types__c);
    }
    
    @isTest
    public static void testNdcLogicUpdate() {
		NDC_Account_Service_Detail__c det = new NDC_Account_Service_Detail__c(Contact_Email__c = 'example@example.com');
        
        insert det;
        
        NDC_Account_Service_Detail__c detResultInsert = [SELECT NDC_Rich_Content_Types__c, NDC_Type_of_CC_Accepted__c 
                                                         FROM NDC_Account_Service_Detail__c 
                                                         WHERE Contact_Email__c = 'example@example.com'];
        
        detResultInsert.Contact_Email__c = 'updated@example.com';
        detResultInsert.Contact_Person__c = 'test';
        
        test.startTest();
        update detResultInsert;
        test.stopTest();
        
        NDC_Account_Service_Detail__c detResultUpdate = [SELECT NDC_Rich_Content_Types__c, NDC_Type_of_CC_Accepted__c 
                                                         FROM NDC_Account_Service_Detail__c 
                                                         WHERE Contact_Email__c = 'updated@example.com'];
        
        system.assertEquals(null, detResultUpdate.NDC_Rich_Content_Types__c);
    }
}