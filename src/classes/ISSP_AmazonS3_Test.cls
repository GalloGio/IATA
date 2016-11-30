@isTest
private class ISSP_AmazonS3_Test {

    static testMethod void unitTest_1() {
    	
    	Account account = ISSP_ObjectFactory.createNewAccount();
        account.Name = 'Account1';
        insert account;
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        insert contact;
        String recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'DPC Service Request'].Id;
        Case c = new Case();
        c.Subject = 'test 1';
        c.Status = 'Open';
        c.AccountId = account.id;
        c.ContactId = contact.id;
        c.Region__c = 'Europe';
        c.RecordTypeId = recordTypeId;
        c.CaseArea__c = 'test';
        c.Reason1__c = 'test';
        insert c;
        
        UtilityCS__c newCS = new UtilityCS__c();
        newCS.Name = 'Emails';
        newCS.value__c = 'test@test.test';
        insert newCS;
        
        ISSP_CS__c cs1 = new ISSP_CS__c();
        cs1.Name = 'ISSP AMS AMAZON S3 MAX FILE SIZE';
        cs1.Value__c = '100';
        insert cs1;
        
        ISSP_CS__c cs2 = new ISSP_CS__c();
        cs2.Name = 'ISSP AMS AMAZON S3 ALLOWED EXTS';
        cs2.Value__c = 'pdf';
        insert cs2;
        
        Amazon_Cred__c cred = new Amazon_Cred__c();
        cred.Name = 'GenericAttach';
        cred.Dev_Configuration__c = 'GenericDev';
        cred.Prod_Configuration__c = 'GenericProd';
        insert cred;
        
        AWSKey__c key = new AWSKey__c();
        key.AWS_ENDPOINT_URL__c = 'test';
        key.Bucket__c = 'test';
        key.IAS_Configation_name__c = 'test';
        key.IAS_configuration_name__c = 'test';
        key.Key__c = 'test';
        key.Name = UserInfo.getOrganizationId().substring(0,15) == '00D2000000008TF'  ? cred.Prod_Configuration__c : cred.Dev_Configuration__c ;
        key.Secret__c = 'test';
        insert key;
        
        ApexPages.currentPage().getParameters().put('caseId',c.Id);
        
        ISSP_AmazonS3_Ctrl ctrl = new ISSP_AmazonS3_Ctrl();
        //ctrl.filenameupload = 'test';
        //ctrl.filetypeupload = 'test';
        //ctrl.sendFileInfo();
        
        if (ctrl.canUploadAndDelete){
        	Boolean thisTest = true;
        }
        
        //ISSP_AmazonS3_Ctrl.createUploadFile(c.Id, 'test', 'pdf', 'test', '500');
        //ISSP_AmazonS3_Ctrl.createUploadFile(c.Id, 'test', 'pdf', 'test', '10');
        //ISSP_AmazonS3_Ctrl.createUploadFile(c.Id, 'test.pdf', 'pdf', 'test', '10');
        //ISSP_AmazonS3_Ctrl.getExpiringLinkIfap('test.pdf');
        
        ctrl.currentFileName = 'test';
        ctrl.deleteThisFile();
        
        ISSP_AmazonS3_Ctrl ctrl2 = new ISSP_AmazonS3_Ctrl(new Apexpages.Standardcontroller(c));
        
        //ISSP_AmazonS3_Ctrl ctrl3 = new ISSP_AmazonS3_Ctrl(new ISSP_AMS_Accreditation());
    }
}