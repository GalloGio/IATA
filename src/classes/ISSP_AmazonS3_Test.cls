@isTest
private class ISSP_AmazonS3_Test {

    static testMethod void unitTest_1() {
    	
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'airline';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        insert parent;

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
        con.AccountId= child.Id;
        con.Email = 'ABCDEF123123@xyz.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        Test.startTest();

        System.runAs(newUser)
        {

            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            //testCase.Continous_Feed_SAF__c = true;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            insert testCase;
        
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

            ISSP_AmazonS3_Ctrl ctrlId = new ISSP_AmazonS3_Ctrl();
            
            ApexPages.currentPage().getParameters().put('caseId',testCase.Id);
            
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
            String testExpiringLink = ISSP_AmazonS3_Ctrl.getExpiringLinkIfap('test.pdf');

            Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
            Amazon_Cred__c GenericAttach =  new Amazon_Cred__c(name = 'GenericAttach', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
            Amazon_Cred__c recycleBin =  new Amazon_Cred__c(name = 'RecycleBin', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
            List<Amazon_Cred__c> creds = new List<Amazon_Cred__c>();
            creds.add(Amazon_Cred);
            creds.add(GenericAttach);
            creds.add(recycleBin);
            insert creds;


            list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{
                new AWSKey__c(
                    name = 'adevconf',
                    Key__c = 'asd', 
                    Secret__c = 'asd',  
                    IAS_configuration_name__c = 'asdas', 
                    IAS_Access_Point__c = 'asd',
                    Bucket__c = 'asd',
                    AWS_ENDPOINT_URL__c = 'asd')
            };
            insert AWS_KEYs;

            AmazonFile__c aFile = new AmazonFile__c(
            Full_Name_Unique__c = 'test name',
            Case__c = testCase.Id,
            isPublic__c = true,
            File_Identifier__c = 'Test uploadedFileIdentifier',
            Review_Status__c = 'Rejected'
            );
            insert aFile;

            ctrl.createAmazonFileObject();

            String caseStatus = ctrl.getCaseStatus();

            ISSP_AmazonS3_Ctrl.AmazonFileAMS afAMS = new ISSP_AmazonS3_Ctrl.AmazonFileAMS(aFile);

            String test = afAMS.getName();
            test = afAMS.getFullName();
            test = afAMS.getStatus();

            ctrl.currentFileName = 'test';

            String testUnique = ctrl.getUniqueFileNames();

            map<String, List<ISSP_AmazonS3_Ctrl.AmazonFileAMS>> mapTest = ctrl.refreshAmazonFileMap();

            ctrl.deleteThisFile();

            ctrl.refreshAfterDelete();
            
            ISSP_AmazonS3_Ctrl ctrl2 = new ISSP_AmazonS3_Ctrl(new Apexpages.Standardcontroller(testCase));

            ISSP_AMS_Accreditation amsCtrl = new ISSP_AMS_Accreditation();
            amsCtrl.newCase = testCase;

            ISSP_AmazonS3_Ctrl ctrl3 = new ISSP_AmazonS3_Ctrl(amsCtrl);

            ISSP_AddAttachment attCtrl = new ISSP_AddAttachment();

            ISSP_AmazonS3_Ctrl ctrl4 = new ISSP_AmazonS3_Ctrl(attCtrl);

        }

        Test.stopTest();

    }
}