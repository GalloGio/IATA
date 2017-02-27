@isTest
private class CNS_CaseHandlerTest {

    @testSetup
    static void createTestData()
    {

        IATA_ISO_Country__c iso_country = new IATA_ISO_Country__c (
            name='United States',
            ISO_Code__c ='US',
            ISO_Code_Numeric__c=1,
            currencyIsoCode = 'USD');
        insert iso_country;

        Account a = new Account (
            Name='test cns portal agency',
            Sector__c='Travel Agent',
            Category__c ='Non-IATA Cargo Agent',
            RecordTypeId= AMS_Utils.getId('Account', 'Standard_Account'),
            CNS_Account__c=true,
            IATA_ISO_Country__c = iso_Country.Id,
            Reason_for_creation__c ='Created by customer'
            );
        insert a;

        Contact c = new Contact (
            LastName='cns contact test',
            AccountId = a.Id,
            RecordTypeId = AMS_Utils.getId('Contact', 'Standard_Contact'),
            CNS_Contact__c=true
            );
        insert c;

        //Custom setting values
        //select Id, Topic__c, Subtopics__c, Subtopics2__c from ISSP_CNS_Topics_Subtopics__c
        List <ISSP_CNS_Topics_Subtopics__c> cnsTopics = new List <ISSP_CNS_Topics_Subtopics__c> ();
        for(Integer i=0; i< 2; i++){
            ISSP_CNS_Topics_Subtopics__c cnsT = new ISSP_CNS_Topics_Subtopics__c ();
            cnsT.Name ='CNS Topic '+i;
            cnsT.Topic__c ='CNS Topic '+i;
            cnsT.Subtopics__c ='CNS subtopic '+i+',CNS subtopic '+i+1+',CNS subtopic '+i+2;
            cnsTopics.add(cnsT);
        }

        insert cnsTopics;

    }
    
    @isTest static void manageCNSCaseOnBeforeInsertUpdateTest() {

        Account agency = [select Id, CNS_Account__c, Name, Sector__c, Category__c, RecordTypeId from Account where Name='test cns portal agency' limit 1];
        Contact cnsContct = [select Id, LastName, CNS_Contact__c, RecordTypeId, AccountId from Contact where AccountId =: agency.Id];
       // List <ISSP_CNS_Topics_Subtopics__c> cnsTopics = [];
        RecordType rtId= [select Id from RecordType where sObjectType='Case' and DeveloperName='CasesAmericas'];
       
        Case cnsCase = new Case(
            AccountId=agency.Id,
            ContactId = cnsContct.Id,
            RecordTypeId = rtId.Id,
            Origin ='Portal',
            Subject='cns case test',
            Topic__c ='CNS Topic 1'
            );
        insert cnsCase;
        
    }
    
    
    
}