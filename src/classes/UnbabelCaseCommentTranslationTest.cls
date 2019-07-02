@isTest
private class UnbabelCaseCommentTranslationTest {

    @testSetup static void testSetup() {
    	
        unbabelapi.UnbabelTestDataFactory.createConfigs();

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        
        insert country;
        
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
        con.Email = 'UnbabelTest1234IATA@unbabel.com';

        insert con;

        User portalUser = ISSP_ObjectFactory.createPortalUser(con);
        insert new ISSP_CS__c(Name = 'DefaultNewAccountOwnerId', Value__c = portalUser.Id);
        
        con.OwnerId = portalUser.Id;
        update con;

        Case_excluded_w_status_action_needed__c cs = new Case_excluded_w_status_action_needed__c(Name = 'RT to Exclude', Record_Type_Name__c = 'CasesEurope');
        insert cs;

            
        ID casesEurope = Schema.SObjectType.Case.RecordTypeInfosByName.get('Cases - Europe').RecordTypeId ;

        Case newCase = ISSP_ObjectFactory.createNewCase();
        newcase.recordtypeid = casesEurope;
        newCase.Status = 'Action Needed';
        newCase.AccountId = parent.Id;
        newCase.ContactId = con.Id;

        insert newcase;

        System.runAs(portalUser){            
            //create Comment as Public in PT
            CaseComment cc = new CaseComment(
                ParentId = newcase.Id, 
                IsPublished = true, 
                CommentBody = 'Isto é um teste'
            );

            insert cc;
    
        }

    }

    @isTest static void testTranslateCustomerFirstComment_Success() {
        
        UnbabelTranslationUtils unbabelTU = new UnbabelTranslationUtils();
        
        List<User> users = createUsers(true);
        //Salesforce User
        User agentUser = users.get(0);

        //get Case
        Case cas = getCase(true,false);


        test.startTest();

        System.runAs(agentUser){

            UnbabelTranslateCaseCommentController  testTransCaseComment = initializeUnbabelPage(cas);

            testTransCaseComment.requestTranslation();

            System.assertEquals(new Apexpages.Message(ApexPages.Severity.Info,unbabelTU.SUCCESSREQUEST), ApexPages.getMessages().get(0));

            testTransCaseComment.goToCase();

        }
        
        test.stopTest();

    }

    @isTest static void testTranslateCustomerFirstComment_Success2() {

        UnbabelTranslationUtils unbabelTU = new UnbabelTranslationUtils();

        List<User> users = createUsers(false);

        //Salesforce User
        User agentUser = users.get(0);

        //get Case
        Case cas = getCase(false,false);
     
        test.startTest();

        System.runAs(agentUser){            

            UnbabelTranslateCaseCommentController  testTransCaseComment = initializeUnbabelPage(cas);

            testTransCaseComment.requestTranslation();

            System.assertEquals(new Apexpages.Message(ApexPages.Severity.Info,unbabelTU.SUCCESSREQUEST), ApexPages.getMessages().get(0));

            testTransCaseComment.goToCase();

        }

        test.stopTest();

    }


    @isTest static void testCreateAgentCommentPrivateWithUnbabel_Success() {

        List<User> users = createUsers(true);

        //Salesforce User
        User agentUser = users.get(0);

        //get Case
        Case cas = getCase(true,true);

        
        test.startTest();

        System.runAs(agentUser){
            //create Comment as Private in EN
            insert new CaseComment( ParentId = cas.Id, IsPublished = false, CommentBody = 'This is a comment from the agent for Unbabel');


            //System.assertEquals(unbabelTU.ERRORPUBLICC,e.getMessage());

        }
        
        test.stopTest();

    }


    @isTest static void testCreateAgentCommentPublicWithUnbabel_Error() {

        UnbabelTranslationUtils unbabelTU = new UnbabelTranslationUtils();

        List<User> users = createUsers(true);

        //Salesforce User
        User agentUser = users.get(0);

        //get Case
        Case cas = getCase(true,true);
            
        test.startTest();

        System.runAs(agentUser){

            //create Comment as Private in EN

            try{
                insert new CaseComment( ParentId = cas.Id, IsPublished = true, CommentBody = 'This is a comment from the agent for Unbabel');
            }catch(Exception e){
                System.assert(e.getMessage().contains(unbabelTU.ERRORPUBLICC));
            }
            
        }

        test.stopTest();

    }


    @isTest static void testCreateAgentCommentPublicWithoutUnbabel_Success() {


        List<User> users = createUsers(true);

        //Salesforce User
        User agentUser = users.get(0);

        //get Case
        Case cas = getCase(true,false);

        test.startTest();

        System.runAs(agentUser){
            //create Comment as Private in EN
            insert new CaseComment( ParentId = cas.Id, IsPublished = true, CommentBody = 'This is a comment from the agent for Unbabel');
        }

        test.stopTest();

    }



     @isTest static void testCommentTranslationHandling_Success() {

         CaseComment cc = [select Id, ParentId, CommentBody,IsPublished from CaseComment limit 1];

    	unbabelapi__Unbabel_Translation_Request__c tr = new unbabelapi__Unbabel_Translation_Request__c();
                      
        tr.unbabelapi__Unbabel_Class__c = 'Unbabel_CaseCommentTranslationHandler';
        tr.unbabelapi__Unbabel_Status__c = 'Translation Requested';
        tr.unbabelapi__Unbabel_Translation_Requested_Datetime__c = System.now();    	
	    tr.unbabelapi__Unbabel_From_Language__c = 'en' ; 
	    tr.unbabelapi__Unbabel_To_Language__c = 'pt' ;                                
	    tr.unbabelapi__Unbabel_Translation_Type__c = 'Machine';
	    tr.unbabelapi__Unbabel_sObject_Id__c = cc.Id;
	    tr.unbabelapi__Unbabel_sObject__c = 'CaseComment';
	        	
    	
    	insert tr;
        
	
		unbabelapi.UnbabelRestEnvelope env = new unbabelapi.UnbabelRestEnvelope(true,'',cc);
		
    	unbabelapi.UnbabelRestEnvelope envError = new unbabelapi.UnbabelRestEnvelope(false,'error',cc);
		
		
    	Unbabel_CaseCommentTranslationHandler ccTh = new Unbabel_CaseCommentTranslationHandler();
       	
    	test.startTest();
    	
    	unbabelapi.UnbabelRestEnvelope  result = ccTh.execute(env,tr);
    	 
    	system.assert(result.isSuccess);
    	
    	
   		unbabelapi.UnbabelRestEnvelope  resultError = ccTh.execute(envError,tr);
    	 
    	system.assert(!resultError.isSuccess);
    	
    	test.stopTest();


         
     }


     @isTest static void testCommentTranslationHandling_Error() {


    	unbabelapi.UnbabelRestEnvelope env = new unbabelapi.UnbabelRestEnvelope();
    	
    	Unbabel_CaseCommentTranslationHandler ccTh = new Unbabel_CaseCommentTranslationHandler();
    	
    	unbabelapi__Unbabel_Translation_Request__c tr = new unbabelapi__Unbabel_Translation_Request__c();
    	
    	
    	test.startTest();
    	

    	unbabelapi.UnbabelRestEnvelope  resultNull = ccTh.execute(null,tr);
		
		system.assert(!resultNull.isSuccess);
		
    	unbabelapi.UnbabelRestEnvelope  resultInvalid = ccTh.execute(env,tr);
		
		system.assert(!resultInvalid.isSuccess);
		
    	
    	test.stopTest();

         
     }



    /**
     * 
     *     Helper Methods
     * 
     */

    private static List<User> createUsers(Boolean setLang){

        //create Salesforce User
        User agentUser = ISSP_ObjectFactory.createAdminUser();
        if(setLang) agentUser.unbabelapi__Unbabel_Language__c = 'en:English';

        update agentUser;

        //get Portal User
        List<User> userList = new List<User>([Select id from user where email = 'UnbabelTest1234IATA@unbabel.com' limit 1]);
        User portalUser = userList[0];

        return new List<User>{agentUser,portalUser};

    }

    private static Case getCase(Boolean removeUnbabelLanguage, Boolean setUnbabelFlag){

        List<Case> caseList = [select Id,status,unbabelsc__Unbabel_Language__c from Case limit 1]; 

        Case cas = caseList[0];

        if(removeUnbabelLanguage) cas.unbabelsc__Unbabel_Language__c = null;

        if(setUnbabelFlag) cas.Publish_with_Unbabel__c = true;

        if(removeUnbabelLanguage || setUnbabelFlag) update cas;
 

        return cas;
    }


    private static UnbabelTranslateCaseCommentController initializeUnbabelPage(Case cas){

        ApexPages.StandardController sc = new ApexPages.StandardController(cas);
        
        UnbabelTranslateCaseCommentController  testTransCaseComment = new UnbabelTranslateCaseCommentController(sc);
        
        PageReference pageRef = Page.UnbabelTranslateCaseComment;

        pageRef.getParameters().put('id', String.valueOf(cas.Id));
        
        Test.setCurrentPage(pageRef);

        return testTransCaseComment;
    }

}