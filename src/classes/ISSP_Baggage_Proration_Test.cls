@isTest
public class ISSP_Baggage_Proration_Test 
{

    @isTest static void ISSP_Baggage_Proration_Test1() 
    {
        Account airlineIssuing;
        Account airlineRecieving;
        Contact con1;
        Contact con2;
        User newUser1;
        User newUser2;
       


            insert new ISSP_CS__c(Name = 'Baggage History - Number Of Months',Value__c = '12');
            insert new ISSP_Baggage_Claim_List_View__c(Name = '1.All',Field_Set_API_Name__c = 'Baggage_Claim_Set_1',Label_API_name__c = 'ISSP_Baggage_All_Claims');
            System.debug('before account insert: ');
            airlineIssuing = ISSP_TestBaggageObjectCreator.CreateAccount('SILVERWINGS','SI');
            System.debug('airlineIssuing: ' + airlineIssuing.Id);
            airlineRecieving = ISSP_TestBaggageObjectCreator.CreateAccount('GOLDENWINGS','GO');
            System.debug('airlineRecieving: ' + airlineRecieving.Id);

            List<Contact> lCont = new List<Contact>();
            con1 = ISSP_ObjectFactory.createNewContact();
            con1.AccountId= airlineIssuing.Id;
            con1.Email = 'Test1@test11.com';
            lCont.add(con1);
            // insert con1;

            con2 = ISSP_ObjectFactory.createNewContact();
            con2.AccountId= airlineIssuing.Id;
            con2.Email = 'Test2@test22.com';
            lCont.add(con2);
            // insert con2;

            insert lCont;


            System.debug('con2 Id: ' + con2.Id);

            Portal_Applications__c app = new Portal_Applications__c(Name = 'Baggage Proration'); 
            insert app;
            Portal_Application_Right__c appRight1 = new Portal_Application_Right__c(Contact__c = con1.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
            insert appRight1;
            Portal_Application_Right__c appRight2 = new Portal_Application_Right__c(Contact__c = con2.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
            insert appRight2;
            

            System.debug('con1 Id: ' + con1.Id);
            newUser1 = ISSP_ObjectFactory.createPortalBasicAirlineUser(con1);

            
  Test.startTest();
        System.runAs(newUser1)
        {        
            PIR_Form__c pirFormArchived = ISSP_TestBaggageObjectCreator.CreatePirForm(airlineIssuing.Id, 'testArchived');
            Baggage_Claim__c prorateRequestExpired = ISSP_TestBaggageObjectCreator.CreateProrateRequest(pirFormArchived.Id, airlineRecieving.Id, 'GO');
            PIR_Form__c pirFormNotArchived = ISSP_TestBaggageObjectCreator.CreatePirForm(airlineIssuing.Id, 'testNotArchived');
            Baggage_Claim__c prorateRequestNotExpired = ISSP_TestBaggageObjectCreator.CreateProrateRequest(pirFormNotArchived.Id, airlineRecieving.Id, 'GO');
            Flight_Information__c flightInfo = ISSP_TestBaggageObjectCreator.CreateFlightInfo(pirFormNotArchived.Id);
            PIR_Bag_Information__c bagInfo = ISSP_TestBaggageObjectCreator.CreateBagInfo(pirFormNotArchived.Id);
            //Baggage_Claim_Comment__c comment = ISSP_TestBaggageObjectCreator.CreateProrateRequestComment(prorateRequestNotExpired.Id);

          prorateRequestExpired.Date_Time_Proceed_to_payment__c = system.now().addMonths(-13);
            update prorateRequestExpired;

            ApexPages.currentPage().getParameters().put('action' ,'new' );


            ISSP_Baggage_Proration ctrl = new ISSP_Baggage_Proration();
            List<PIR_Form__c> formList = ctrl.formList;
            ctrl.refreshFormList();
            //ctrl.pageLoad_Form();
            ctrl.fetchPirFormInfo();
            //ctrl.saveForm();
            

            ApexPages.currentPage().getParameters().put('id' ,pirFormNotArchived.Id );
            //ctrl.pageLoad_Form();
            ctrl.isNew = false;
            ctrl.isEdit = true;
            //ctrl.saveForm();
            ctrl.getFormCommentsList();

            ApexPages.currentPage().getParameters().put('id' ,null );
            ApexPages.currentPage().getParameters().put('parentId' ,pirFormNotArchived.Id );
            ctrl.pageLoad_Claim();
            ApexPages.currentPage().getParameters().put('id' ,prorateRequestNotExpired.Id );
            ctrl.pageLoad_ClaimList();
            List<Baggage_Claim__c> claimList = ctrl.getClaimList();
            ctrl.refresh();
            ctrl.pageLoad_Claim();
            ctrl.airlineCode = 'GO';
            ctrl.fetchAirlineAccountDetails();
            ctrl.pageLoad_List();
            ctrl.getBaggageFields();
            ctrl.getSortDirection();
            ctrl.setSortDirection('ASC');
            String cse = ctrl.claimsSortExpression;
            ctrl.getClaimsSortDirection();
            ctrl.setClaimsSortDirection('ASC');
            ctrl.claimsSortExpression = 'CreatedDate';
            ctrl.isNew = true;
            // ctrl.saveClaim();
            ctrl.isNew = false;
            ctrl.isEdit = true;
            // ctrl.saveClaim();
            ctrl.getClaimCommentsList();
            ctrl.getFormClaimsList();

            
            //airlineRecieving.Email_Prorate__c = null;
            //update airlineRecieving;
            //ctrl.saveClaim();

            //ApexPages.currentPage().getParameters().put('id' ,null );
            //ApexPages.currentPage().getParameters().put('parentId' ,prorateRequestNotExpired.Id );
            //ctrl.isNew = true;
            //ctrl.pageLoad_Comment();
            //ctrl.saveComment();
            //ApexPages.currentPage().getParameters().put('id' ,comment.Id );
            //ctrl.pageLoad_Comment();
            

        }

        Test.stopTest();
    }


    /*
    @isTest static void ISSP_Baggage_Proration_Test2() 
    {
        Account airlineIssuing;
        Account airlineRecieving;
        Contact con1;
        Contact con2;
        User newUser1;
        User newUser2;
       


            insert new ISSP_CS__c(Name = 'Baggage History - Number Of Months',Value__c = '12');
            insert new ISSP_Baggage_Claim_List_View__c(Name = '1.All',Field_Set_API_Name__c = 'Baggage_Claim_Set_1',Label_API_name__c = 'ISSP_Baggage_All_Claims');
            System.debug('before account insert: ');
            airlineIssuing = ISSP_TestBaggageObjectCreator.CreateAccount('SILVERWINGS','SI');
            System.debug('airlineIssuing: ' + airlineIssuing.Id);
            airlineRecieving = ISSP_TestBaggageObjectCreator.CreateAccount('GOLDENWINGS','GO');
            System.debug('airlineRecieving: ' + airlineRecieving.Id);

            List<Contact> lCont = new List<Contact>();
            con1 = ISSP_ObjectFactory.createNewContact();
            con1.AccountId= airlineIssuing.Id;
            con1.Email = 'Test1@test11.com';
            lCont.add(con1);
            // insert con1;

            con2 = ISSP_ObjectFactory.createNewContact();
            con2.AccountId= airlineIssuing.Id;
            con2.Email = 'Test2@test22.com';
            lCont.add(con2);
            // insert con2;

            insert lCont;


            System.debug('con2 Id: ' + con2.Id);

            Portal_Applications__c app = new Portal_Applications__c(Name = 'Baggage Proration'); 
            insert app;
            Portal_Application_Right__c appRight1 = new Portal_Application_Right__c(Contact__c = con1.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
            insert appRight1;
            Portal_Application_Right__c appRight2 = new Portal_Application_Right__c(Contact__c = con2.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
            insert appRight2;
            

            System.debug('con1 Id: ' + con1.Id);
            

            newUser2 = ISSP_ObjectFactory.createPortalBasicAirlineUser(con2);
Test.startTest();
        
        User newAdminUser = ISSP_ObjectFactory.createAdminUser();
        System.runAs(newAdminUser)
        {
            PIR_Form__c pirForm = ISSP_TestBaggageObjectCreator.CreatePirForm(airlineIssuing.Id, 'test');
            Flight_Information__c flightInfo1 = ISSP_TestBaggageObjectCreator.CreateFlightInfo(pirForm.Id);
            PIR_Bag_Information__c bagInfo1 = ISSP_TestBaggageObjectCreator.CreateBagInfo(pirForm.Id);
            Flight_Information__c flightInfo2 = ISSP_TestBaggageObjectCreator.CreateFlightInfo(pirForm.Id);
            PIR_Bag_Information__c bagInfo2 = ISSP_TestBaggageObjectCreator.CreateBagInfo(pirForm.Id);
            Baggage_Claim__c prorateRequest = ISSP_TestBaggageObjectCreator.CreateProrateRequest(pirForm.Id, airlineRecieving.Id, 'GO');
            Baggage_Claim_Comment__c comment = ISSP_TestBaggageObjectCreator.CreateProrateRequestComment(prorateRequest.Id);
            ISSP_Baggage_Proration ctrl = new ISSP_Baggage_Proration();
            ApexPages.currentPage().getParameters().put('action' ,'new' );
            ApexPages.currentPage().getParameters().put('id' ,null );
            ApexPages.currentPage().getParameters().put('parentId' ,prorateRequest.Id );
            ctrl.isNew = true;
            ctrl.pageLoad_Comment();
            ctrl.saveComment();
            ApexPages.currentPage().getParameters().put('id' ,comment.Id );
            ctrl.pageLoad_Comment();

            prorateRequest.Airline_receiving__c = airlineIssuing.Id;
            update prorateRequest;

        }


        Test.stopTest();
    }
    */

    // Added by OA
    /**
     * @author Ofir A.
     * @description This function ilustrate sending http soap request by mock response, 
     * and should cover send request method and parse method
     */
    @isTest static void ISSP_Baggage_Proration_Test_withMock() {
        insert new ISSP_CS__c(Name = 'Baggage History - Number Of Months',Value__c = '12');
        Test.setMock(HttpCalloutMock.class, new ISSP_Baggage_Proration_WS_Mock());
        
        ISSP_Baggage_Proration cont = new ISSP_Baggage_Proration();
        cont.PIR = new PIR_Form__c();
        cont.PIR.PIR_File_Ref__c='12345';
        cont.PIR.Airport_Arrival__c='xxx';
        cont.PIR.Airline_Code__c='xx';
        cont.PIR.PIR_File_Type__c='DELAYED';

        test.startTest();
        ISSP_Baggage_Proration.PIRFromWrapper wrapper = ISSP_Baggage_Proration.AutoFillData(cont.PIR);
        test.stopTest();
    }
    // End modifications

    /**
     * @author Israel Chayon
     * @description This function ilustrate the integration with net tracer for getting the incident information
     */
    @isTest static void ISSP_retrieveAndFillIncidentInformation_Test() {
        insert new ISSP_CS__c(Name = 'Baggage History - Number Of Months',Value__c = '12');

        Test.startTest();
        ISSP_Baggage_Proration cont = new ISSP_Baggage_Proration();
        cont.PIR = new PIR_Form__c();
        cont.PIR.PIR_File_Ref__c='test';
        cont.bag_Information_List = new List<PIR_Bag_Information__c>();
        cont.Flight_Information_List = new List<Flight_Information__c>();
        Test.setMock(WebServiceMock.class, new ISSP_GetIncidentWebServiceMock());
        cont.retrieveAndFillIncidentInformation('1', '2', '3');
        Test.stopTest();
    }

    /**
     * @author Israel Chayon
     * @description This function ilustrate the integration with net tracer for getting the incident information
     */
    @isTest static void ISSP_fillIncidentInformationMethods_Test() {
        insert new ISSP_CS__c(Name = 'Baggage History - Number Of Months',Value__c = '12');

        Test.startTest();
        ISSP_Baggage_Proration cont = new ISSP_Baggage_Proration();
        try {
            cont.getNetTracerSessionId();
        }
        catch(Exception x) {

        }
        try {
            cont.logOffNetTracer('1');
        }
        catch(Exception x) {

        }
        try {
            cont.fillIncidentInformation('1', '2');
        }
        catch(Exception x) {

        }
        Test.stopTest();
    }

    static testMethod void ISSP_Baggage_Proration_Test_Aura() {
        Test.setMock(HttpCalloutMock.class, new ISSP_Baggage_Proration_WS_Mock());

        insert new ISSP_CS__c(Name = 'Baggage History - Number Of Months',Value__c = '12');
		Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();
		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.recordtypeid = RecordTypeId;
        acc.Airline_designator__c = 'xpto';
		insert acc;
		Account acc2 = ISSP_ObjectFactory.createNewAccount();
		acc2.recordtypeid = RecordTypeId;
		insert acc2;
		PIR_Form__c pirF = new PIR_Form__c();
		pirF.Airline_issuing__c = acc.Id;
		pirF.PIR_File_Ref__c = '123';
		insert pirF;
		PIR_Form__c pirF2 = new PIR_Form__c();
		pirF2.Airline_issuing__c = acc.Id;
		pirF2.PIR_File_Ref__c = '122';
		Baggage_Claim__c bg = new Baggage_Claim__c();
		bg.Airline_receiving__c = acc2.Id;
		bg.Parent_PIR_Form__c = pirF.Id;
        insert bg;
		Flight_Information__c flightInfo = new Flight_Information__c();

        flightInfo.PIR_Ref__c = pirF.Id;
        flightInfo.PIR_Segment_1__c = '1';
        flightInfo.PIR_Flight_Date__c  = date.today();
        flightInfo.PIR_Percentage__c = 20;
        insert flightInfo;

		PIR_Bag_Information__c bagInfo = new PIR_Bag_Information__c();
        bagInfo.PIR_Form__c = pirF.Id;
        bagInfo.Bag_Number__c = '1';
        insert bagInfo;

        Baggage_Claim_Comment__c bcc = new Baggage_Claim_Comment__c(Baggage_Claim__c = bg.id, Comments__c = 'test');
        insert bcc;

		List<Baggage_Claim__c> bgList = new List<Baggage_Claim__c>();
		bgList.add(bg);

        List<Flight_Information__c> flightInfoList = new List<Flight_Information__c>();
		flightInfoList.add(flightInfo);
		
		List<PIR_Bag_Information__c> bagInfoList = new List<PIR_Bag_Information__c>();
		bagInfoList.add(bagInfo);

		List<Baggage_Claim_Comment__c> CommentList = new List<Baggage_Claim_Comment__c>();
		CommentList.add(bcc);
        

        ISSP_Baggage_Proration.PIRFromWrapper auxWrapper = new ISSP_Baggage_Proration.PIRFromWrapper(pirF, acc,flightInfoList ,bagInfoList, bgList, CommentList);
        ISSP_Baggage_Proration.PIRFromWrapper auxWrapper2 = new ISSP_Baggage_Proration.PIRFromWrapper(pirF2, acc,flightInfoList ,bagInfoList, bgList, CommentList);
        ISSP_Baggage_Proration.BaggageClaimWrapper auxWrapper3 = new ISSP_Baggage_Proration.BaggageClaimWrapper(flightInfoList, bagInfoList, bg, CommentList);
        ISSP_Baggage_Proration.PIRFCommentWrapper auxWrapper4 = new ISSP_Baggage_Proration.PIRFCommentWrapper('test', bg.Id);
        Test.startTest();
            //ISSP_Baggage_Proration.getPIRFormList();
            ISSP_Baggage_Proration.getListViewNameList();
            ISSP_Baggage_Proration.getPIRForm(pirF.Id);
            ISSP_Baggage_Proration.getPIRForm('');
            ISSP_Baggage_Proration.AutoFillData(pirF);
            String auxStr = JSON.serialize(auxWrapper);
            ISSP_Baggage_Proration.saveForm(auxStr, 'Update');
            String auxStr2 = JSON.serialize(auxWrapper2);
            ISSP_Baggage_Proration.saveForm(auxStr2, 'NEW');
            //ISSP_Baggage_Proration.getBaggageClaimComment(String.valueOf(pirF.Id));
            ISSP_Baggage_Proration.getBaggageClaim(String.valueOf(bg.Id));
            ISSP_Baggage_Proration.getFlightInformationList(String.valueOf(pirF.Id));
            ISSP_Baggage_Proration.getBagInformationList(String.valueOf(pirF.Id));
            ISSP_Baggage_Proration.getPickListValuesIntoList();
            ISSP_Baggage_Proration.getPickListValuesBaggageInformationPIRColor();
            ISSP_Baggage_Proration.getPickListValuesBaggageInformationType();
            ISSP_Baggage_Proration.getAllClaimCommentsList(String.valueOf(bg.Id));
            ISSP_Baggage_Proration.fetchAirlineAccountDetailsAura('xpto', null);
            String auxStr3 = JSON.serialize(auxWrapper3);
            ISSP_Baggage_Proration.UpdateClaim(auxStr3, bg);
            String auxStr4 = JSON.serialize(auxWrapper4);
            ISSP_Baggage_Proration.saveNewComment(auxStr4);

            try{
                List<PIR_Form__c> auxPIRlist = ISSP_Baggage_Proration.getPIRFormList();
            }catch(Exception e){
                System.debug(e);
            }
            try{
                List<Baggage_Claim__c> bcReq = ISSP_Baggage_Proration.getRequests('ALL', new map<string,ISSP_Baggage_Claim_List_View__c>(), '', 'ASC');
            }catch(Exception e){
                System.debug(e);
            }
            try{
                Baggage_Claim_Comment__c auxCom = ISSP_Baggage_Proration.getBaggageClaimComment(pirF.Id);
            }catch(Exception e){
                System.debug(e);
            }
            try{
                ISSP_Baggage_Proration.calculateFinalAmountAura(bg, flightInfoList);
            }catch(Exception e){
                System.debug(e);
            }
            try{
                String auxFile = ISSP_Baggage_Proration.getExpiringLink('test' );
            }catch(Exception e){
                System.debug(e);
            }
            try{
                Map<String, String> auxMap = ISSP_Baggage_Proration.getselectOptions('PIR_Form__c', 'PIR_Currency_of_conversion__c');
            }catch(Exception e){
                System.debug(e);
            }
            
    	Test.stopTest();
	}
}