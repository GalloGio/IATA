/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class trgIDCard_Case_BeforeUpdateTest
{
    private static IDCardTestData testData;
    private static List<Contact> relatedContact;
    private static List<Case> relatedCase;
    
    TestMethod static void testTrgIDCard_Case_BeforeUpdate()
    {
        
        Amazon_Cred__c amc = new Amazon_Cred__c(Name = 'IdCard', Dev_Configuration__c = 'IdCardDev', Prod_Configuration__c = 'IdCardProd');
        insert amc;

        AWSKey__c awsk_dev = new AWSKey__c(Name = 'IdCardDev', Key__c = 'asd', Secret__c = 'asd',  IAS_configuration_name__c = 'asd', IAS_Access_Point__c = 'asd', Bucket__c = 'asd', AWS_ENDPOINT_URL__c = 'https://asd.com');
        AWSKey__c awsk_prd = new AWSKey__c(Name = 'IdCardProd', Key__c = 'asd', Secret__c = 'asd',  IAS_configuration_name__c = 'asd', IAS_Access_Point__c = 'asd', Bucket__c = 'asd', AWS_ENDPOINT_URL__c = 'https://asd.com');
        insert awsk_dev;
        insert awsk_prd;
        

        
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'sasa', Email='abciuhgrtydfmmnd@iata.org', 
        EmailEncodingKey='UTF-8', LastName='Saso', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, License_Cost_Center__c='ITO005CH01',
        TimeZoneSidKey='America/Los_Angeles', UserName='abciuhgrtydfmmnd@iata.org');
        insert u;
        
        testData = new IDCardTestData();
        
            List<ID_Card_Application__c> idCardAppToInsert = new List<ID_Card_Application__c>();
            
            idCardAppToInsert.add(testData.IDCards_IDCardApplications[3]);        
            
            insert idCardAppToInsert;
            
            Contact contactId1 = IDCardUtil.CreateContactWhenNewCardIsApproved(idCardAppToInsert[0]);   
            
            
            IDCardUtil.CreateIDCardApplicationCase(idCardAppToInsert[0], testData.IDCard_Accounts[0]);
            System.debug('*-*-*-*-*-*-*-*-*- IdCardApplication ' + idCardAppToInsert[0].Id);
            System.debug('*-*-*-*-*-*-*-*-*- Account ' + testData.IDCard_Accounts[0]);
            relatedCase = [SELECT ID_Card_Status__c FROM Case];
            System.debug('*-*-*-*-*-*-*-*-*- ' + relatedCase);
            
            relatedCase[0].ID_Card_Status__c = IDCardUtil.CASECARDSTATUS_PENDING_MNG_APPROVAL;
            update relatedCase[0];
            relatedCase[0].ID_Card_Status__c = IDCardUtil.CASECARDSTATUS_APPROVED;
            update relatedCase[0];
            
            relatedContact = [SELECT Id, LastName, FirstName, VER_Number__c, IATA_Code__c, Account.RecordType.Name, Account.Status__c, Date_of_Birth__c FROM Contact WHERE Id =:contactId1.id];  
            
            List<ID_Card__c> idCardToInsert = new List<ID_Card__c>();          
            idCardToInsert.add(IDCardUtil.CreateIDCardObjectFromApplication(idCardAppToInsert[0], relatedContact[0]));            
            insert idCardToInsert;
            
            idCardAppToInsert[0].Type_of_application__c = IDCardUtil.APPLICATIONTYPE_REISSUE;
            update idCardAppToInsert;
            relatedCase[0].OwnerId = u.Id;
            update relatedCase;
            
        Test.startTest();
            System.runAs(u)
            {
                relatedCase = [SELECT ID_Card_Status__c FROM Case];
                
                relatedCase[0].ID_Card_Status__c = IDCardUtil.CASECARDSTATUS_REJECTED;
                update relatedCase;
            }
            
        Test.stopTest();
    }
}