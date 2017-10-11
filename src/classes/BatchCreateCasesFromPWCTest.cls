@isTest
public class BatchCreateCasesFromPWCTest {

    private static list<WSCreateCasesFromPWC.securityCase> createListClases( Integer quantity) {
        list<WSCreateCasesFromPWC.securityCase> listCases = new list<WSCreateCasesFromPWC.securityCase>();
        for ( Integer i = 0; i < quantity; i++ ) {
            listCases.add( new WSCreateCasesFromPWC.SecurityCase( i.format(), (Long)i, 'EUR', 1, '2015/01/01') );
        }
        return listCases;
    }

    private static list<Account> createListAccount( Integer quantity) {
        list<Account> listAccount = new list<Account>();
        for ( Integer i = 0; i < quantity; i++ ) {
            listAccount.add( new Account( Name = 'account' + i, AIMS_ID__c = String.ValueOf(i), Type = 'IATA Cargo Agent', Location_Type__c = 'HO') );
        }
        return listAccount;
    }

    private static list<Contact> createListContact( list<Account> listAccount) {
        list<Contact> listcontact = new list<Contact>();
        Integer i = 0;
        for ( Account account: listAccount ) {
            listcontact.add( new Contact( FirstName = 'Name', LastName = 'TestName ' + i, AccountId = account.Id, Financial_Assessment_Contact__c = true) );
            i++;
        }
        return listcontact;
    }
    
    private static void insertDefaultTemplate() {
    	String language = 'English';
        String country = 'WW';
        String aimsid = '12345678';

        Recordtype recordtypeFSM = [Select Id, DeveloperName From RecordType where developerName like 'FSM' and sObjectType = 'EmailTemplate__c'];

        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c( ISO_Code__c = country);
        insert isoCountry;
        System.assert( isoCountry!= null );

        EmailTemplate__c template = new EmailTemplate__c( RecordtypeId = recordtypeFSM.Id, Template_Language__c = language, IATA_ISO_Country__c = isoCountry.Id, Agent_Type__c='All');
        insert template;

    	EmailTemplateCustomHandler templateHandler = new EmailTemplateCustomHandler();
		template = templateHandler.DEFAULT_FSM_TEMPLATE;
    }

    static testmethod void testBatch() {
    	insertDefaultTemplate();
        Integer numberOfTestCases = 1;
        list<WSCreateCasesFromPWC.securityCase> listCases = createListClases(numberOfTestCases);
        String response = WSCreateCasesFromPWC.doPost( listCases );

        WSCreateCasesFromPWC.ResponsePOST responsePOST = (WSCreateCasesFromPWC.ResponsePOST)JSON.deserialize(response, WSCreateCasesFromPWC.ResponsePOST.class);
        System.assert( responsePOST != null );

        String batchName = responsePOST.UniqueId;
        BatchNumber__c batchNumber = [Select Id, Name from BatchNumber__c where Name = :batchName ];

        list<Account> listAccount = createListAccount(numberOfTestCases);
        insert listAccount;

        insert createListContact(listAccount);

        Test.startTest();
        BatchCreateCasesFromPWC batch = new BatchCreateCasesFromPWC( batchNumber.Name );
        //Database.executeBatch( batch, 10 );
        batch.processScope( listCases );
        batch.setFinishedResponseFile();
        RestRequest req = new RestRequest();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/PWC/' + batchName;
        RestContext.request = req;

        String JSONanswer = WSCreateCasesFromPWC.doGet();
        Test.stopTest();


        Attachment requestAtt = [ Select Id, Body from Attachment where parentId = :batchNumber.Id and name = :WSCreateCasesFromPWC.FILE_NAME_REQUEST ];
        System.assert( requestAtt != null);

        // Assert the asnwer
        BatchCreateCasesFromPWC.responsePWC answer = (BatchCreateCasesFromPWC.responsePWC) JSON.deserialize( JSONanswer, BatchCreateCasesFromPWC.responsePWC.class);

        System.assert( answer.status == 'FINISHED', answer);
        System.assert( answer.Msg == '');
        //System.assert( answer.ResultList.size() == numberOfTestCases );

        map<String, Case> mapCase = new map<String, Case>();
        for ( Case caseObj: [Select Id, CaseNumber, Account.Aims_Id__c from Case ]) {
            mapCase.put( caseObj.Account.Aims_Id__c, caseObj);
        }


        for ( BatchCreateCasesFromPWC.ResponsePWCCase result : answer.ResultList ) {
            System.assert( result.status == 'SUCCESS', result);
            //BatchCreateCasesFromPWC.ResponsePWCCaseSuccess resultSuccess = (BatchCreateCasesFromPWC.ResponsePWCCaseSuccess)result;
            Case caseObj = mapCase.get( result.aimsId );
            System.assert( result.caseNumber == caseObj.CaseNumber );
        }
    }

    static testmethod void testWSPostError() {

        Test.StartTest();
        String response = WSCreateCasesFromPWC.doPost( null );
        WSCreateCasesFromPWC.ResponsePOST responsePOST = (WSCreateCasesFromPWC.ResponsePOST)JSON.deserialize(response, WSCreateCasesFromPWC.ResponsePOST.class);
        System.assert(responsePOST.Status == 'ERROR', responsePOST);
        Test.StopTest();

    }

    static testmethod void testWSGetError() {

        Test.StartTest();
        String response = WSCreateCasesFromPWC.doGet();
        BatchCreateCasesFromPWC.responsePWCError responseGet = (BatchCreateCasesFromPWC.responsePWCError)JSON.deserialize(response, BatchCreateCasesFromPWC.responsePWCError.class);
        System.assert(responseGet.Status == 'ERROR', responseGet);
        Test.StopTest();

    }

    static testmethod void testCreateCaseWithEmailTemplate() {
    	insertDefaultTemplate();
    	
        String language = 'English';
        String country = 'FR';
        String aimsid = '123456';

        Recordtype recordtypeFSM = [Select Id, DeveloperName From RecordType where developerName like 'FSM' and sObjectType = 'EmailTemplate__c'];

        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c( ISO_Code__c = country);
        insert isoCountry;
        System.assert( isoCountry!= null );

        EmailTemplate__c template = new EmailTemplate__c( RecordtypeId = recordtypeFSM.Id, Template_Language__c = language, IATA_ISO_Country__c = isoCountry.Id, Agent_Type__c='All');
        insert template;
        
        template = [Select UniqueId__c from EmailTemplate__c where id = :template.Id];
        System.assert( template.UniqueId__c == recordtypeFSM.DeveloperName + '_' + country + '_' + language, template.UniqueId__c );


        Account account = new Account( Name = 'Test Account', AIMS_ID__c = aimsid, IATA_ISO_Country__c  = isoCountry.Id, Type = 'IATA Cargo Agent', Location_Type__c = 'HO');
        insert account;

        Recordtype recordtypeStandardContact = [Select Id, DeveloperName From RecordType where Name like 'Standard' and sObjectType = 'Contact'];
        Contact contact = new Contact(
            RecordtypeId = recordtypeStandardContact.Id,
            Preferred_Language__c = language,
            Financial_Assessment_Contact__c = true,
            AccountId = account.Id,
            FirstName = 'Name',
            LastName = 'lastName'
        );
        insert contact;

        //Prepare batch call
        list<WSCreateCasesFromPWC.securityCase> listCases = new list<WSCreateCasesFromPWC.securityCase>();
        listCases.add( new WSCreateCasesFromPWC.SecurityCase( aimsid, 1000, 'EUR', 0, '') );
        String response = WSCreateCasesFromPWC.doPost( listCases );
        WSCreateCasesFromPWC.ResponsePOST responsePOST = (WSCreateCasesFromPWC.ResponsePOST)JSON.deserialize(response, WSCreateCasesFromPWC.ResponsePOST.class);
        String batchName = responsePOST.UniqueId;
        BatchNumber__c batchNumber = [Select Id, Name from BatchNumber__c where Name = :batchName ];

        Test.startTest();
        BatchCreateCasesFromPWC batch = new BatchCreateCasesFromPWC( batchNumber.Name );
        batch.processScope( listCases );
        batch.setFinishedResponseFile();
        RestRequest req = new RestRequest();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/PWC/' + batchName;
        RestContext.request = req;

        String JSONanswer = WSCreateCasesFromPWC.doGet();
        Test.StopTest();
        system.debug('$$$ ' + JSONanswer);

        list<Case> listCase = [Select Id, Reminder_EmailTemplate__c from Case where accountId = :account.Id];
        System.assert( ! listcase.isEmpty() );
        System.assert( listCase[0].Reminder_EmailTemplate__c == template.Id, listCase[0].Reminder_EmailTemplate__c );

    }

}