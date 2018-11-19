@isTest
private class ISSP_AddAttachment_Test {

    @isTest static void test_method_one() {

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'airline';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';

        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'airline';
        child.Top_Parent__c = null;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;      

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';

        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        insert new ISSP_CS__c(Name = 'DefaultNewAccountOwnerId', Value__c = newUser.Id);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        Case_excluded_w_status_action_needed__c cs = new Case_excluded_w_status_action_needed__c(Name = 'RT to Exclude', Record_Type_Name__c = 'CasesEurope');
        insert cs;

        Test.startTest();   
            
        ID casesEurope = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope');
        ID saam = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        Case newCase = ISSP_ObjectFactory.createNewCase();
        newcase.recordtypeid = casesEurope;
        newCase.Status = 'Closed';
        newCase.AccountId = parent.Id;
        newCase.ContactId = con.Id;
        insert newcase;
        
        newCase.RecordTypeId = saam;       
        newCase.AccountId = parent.Id;
        newCase.ContactId = con.Id;       
        newCase.Reason1__c = 'CLO - Closure';
        newCase.Status = 'Draft';
        
        AmazonFile__c af = new AmazonFile__c();
        af.Case__c = newcase.Id;

        System.runAs(newUser) {
            Apexpages.currentPage().getParameters().put('Caseid', newcase.Id);
            ISSP_AddAttachment controller = new ISSP_AddAttachment();
            controller.upload();
            controller.vAccountConcerned = parent.Id;        
            controller.getNoNSAOffices();
            controller.submitToIATA();
            controller.sendConfirmationEmail(newCase);


            update newCase;            
            controller.upload();
            controller.vAccountConcerned = parent.Id;        
            controller.getNoNSAOffices();
            controller.submitToIATA();
            controller.sendConfirmationEmail(newCase);
            
            ISSP_AddAttachment controller1 = new ISSP_AddAttachment();
            controller1.upload();
            controller1.submitToIATA();
            controller1.sendConfirmationEmail(newCase);
        }
        Test.stopTest();
    }
}