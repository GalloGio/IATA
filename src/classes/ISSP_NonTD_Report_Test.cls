@isTest
private class ISSP_NonTD_Report_Test {

    static testMethod void ISSP_NonTD_Report_Test_1() {
    	
    	ISSP_NonTD_Report cttr = new ISSP_NonTD_Report();
    	
    	Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        insert con;
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        ContactShare newShare = new ContactShare();
    	newShare.ContactAccessLevel = 'Edit';
    	newShare.ContactId = con.Id;
    	newShare.UserOrGroupId = thisUser.Id;
    	insert newShare;
        
        cttr.pageLoad();
        
        system.runAs(thisUser){
	        cttr.pageLoad();
        }
        
        User myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	myUser.TD_Team__c = true;
    	update myUser;
    	myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	PortalServiceAccessTriggerHandler.avoidAppTrigger = true;
        Portal_Applications__c app = new Portal_Applications__c(Name = 'Treasury Dashboard'); 
        insert app;
        Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = con.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
        insert appRight;
        PortalServiceAccessTriggerHandler.avoidAppTrigger = false;
       
        ISSP_NonTD_Report__c bo = new ISSP_NonTD_Report__c();
        bo.Posted_Date__c = system.Today();
        bo.Account__c = acc.Id;
        insert bo;
        Attachment attach = new Attachment();     
        attach.Name='[UNITTEST][FILE][SMALL]';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = bo.Id;
        insert attach;
        ISSP_NonTD_Report__Share newReportShare = new ISSP_NonTD_Report__Share();
		newReportShare.AccessLevel = 'Read';
		newReportShare.ParentId = bo.Id;
		newReportShare.UserOrGroupId = thisUser.Id;
		insert newReportShare;
        ISSP_NonTD_Report__c bo2 = new ISSP_NonTD_Report__c();
        bo2.Posted_Date__c = system.Today()-45;
        bo2.Account__c = acc.Id;
        insert bo2;
        ISSP_NonTD_Report__Share newReportShare2 = new ISSP_NonTD_Report__Share();
		newReportShare2.AccessLevel = 'Read';
		newReportShare2.ParentId = bo2.Id;
		newReportShare2.UserOrGroupId = thisUser.Id;
		insert newReportShare2;
        Attachment attach2 = new Attachment();     
        attach2.Name='[UNITTEST][FILE][SMALL]';
        Blob bodyBlob2 = Blob.valueOf('Unit Test Attachment Body');
        attach2.body = bodyBlob2;
        attach2.parentId = bo2.Id;
        insert attach2;
        ISSP_NonTD_Report__c bo3 = new ISSP_NonTD_Report__c();
        bo3.Posted_Date__c = system.Today();
        bo3.Account__c = acc.Id;
        insert bo3;
        ISSP_NonTD_Report__Share newReportShare3 = new ISSP_NonTD_Report__Share();
		newReportShare3.AccessLevel = 'Read';
		newReportShare3.ParentId = bo3.Id;
		newReportShare3.UserOrGroupId = thisUser.Id;
		insert newReportShare3;
        Attachment attach3 = new Attachment();     
        attach3.Name='[UNITTEST][FILE][SMALL]';
        Blob bodyBlob3 = Blob.valueOf('Unit Test Attachment Body');
        attach3.body = bodyBlob3;
        attach3.parentId = bo3.Id;
        insert attach3;
        
        //ISSP_UserTriggerHandler.addNonTdReportSharing(new Set<Id>{con.Id});
        
        Test.StartTest();
        system.runAs(thisUser){
        	
	        cttr.pageLoad();
	        cttr.getReports();
	        system.assertEquals(3, cttr.noOfRecords);
	        cttr.refresh();
	        
	        cttr.setSortDirection('DESC');
	        system.assertEquals('DESC', cttr.getSortDirection());
	        cttr.sortExpression = 'ASC';
	        cttr.sortExpression = 'ASC';
	        
	        cttr.reportId = bo.Id;
	        cttr.viewReport();
	        
	        List <ISSP_Document_Tracker__c> trackerList = [SELECT Id FROM ISSP_Document_Tracker__c];
	        system.assertEquals(1, trackerList.size());
	        
        }
        Test.StopTest();
        
    }
    
    static testMethod void ISSP_NonTD_Email_Interface_1(){
    	
    	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	thisUser.TD_Team__c = true;
    	update thisUser;
    	thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	system.runAs(thisUser){
	    	Account acc = ISSP_ObjectFactory.createNewAccount();
	    	Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
	    	acc.recordTypeId = recordTypeId;
	    	acc.IATACode__c = '100';
			insert acc;
			Contact contact = ISSP_ObjectFactory.createNewContact();
	        contact.AccountId = acc.Id;
	        insert contact;
	        User newUser = ISSP_ObjectFactory.createPortalUser(contact);
	        PortalServiceAccessTriggerHandler.avoidAppTrigger = true;
	        Portal_Applications__c app = new Portal_Applications__c(Name = 'Treasury Dashboard'); 
	        insert app;
	        Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = contact.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
	        insert appRight;
    	}
    	
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
         
        // setup the data for the email
        email.subject = '100';
        email.plainTextBody = 'test';
        
        // call the email service class and test it with the data in the testMethod
        ISSP_NonTD_Report_Email_Inteface emailProcess = new ISSP_NonTD_Report_Email_Inteface();
        emailProcess.handleInboundEmail(email, env);
        
        email.subject = '';
        emailProcess.handleInboundEmail(email, env);
        
        email.subject = '100';
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
		attachment.body = blob.valueOf('my attachment text');
		attachment.fileName = 'textfileone.txt';
		attachment.mimeTypeSubType = 'text/plain';
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

        emailProcess.handleInboundEmail(email, env);
    }
    
    static testMethod void ISSP_NonTD_Email_Interface_2(){
    	
    	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	thisUser.TD_Team__c = true;
    	update thisUser;
    	thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	system.runAs(thisUser){
	    	Account acc = ISSP_ObjectFactory.createNewAccount();
	    	Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
	    	acc.recordTypeId = recordTypeId;
	    	acc.IATACode__c = '100';
			insert acc;
			Contact contact = ISSP_ObjectFactory.createNewContact();
	        contact.AccountId = acc.Id;
	        insert contact;
	        PortalServiceAccessTriggerHandler.avoidAppTrigger = true;
	        Portal_Applications__c app = new Portal_Applications__c(Name = 'Treasury Dashboard'); 
	        insert app;
	        Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = contact.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
	        insert appRight;
    	}
    	
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
         
        // setup the data for the email
        email.subject = '101';
        email.plainTextBody = 'test';
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
		attachment.body = blob.valueOf('my attachment text');
		attachment.fileName = 'textfileone.txt';
		attachment.mimeTypeSubType = 'text/plain';
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

        // call the email service class and test it with the data in the testMethod
        ISSP_NonTD_Report_Email_Inteface emailProcess = new ISSP_NonTD_Report_Email_Inteface();
        emailProcess.handleInboundEmail(email, env);
    }
    
    static testMethod void ISSP_NonTD_WS_1(){
    	
    	User myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	myUser.TD_Team__c = true;
    	update myUser;
    	
    	List <ISSP_Int_Error__c> errorList = ISSP_NonTD_Report_Test.createErrors();
    	insert errorList;
    	
    	Account acc = ISSP_ObjectFactory.createNewAccount();
    	Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
	    acc.recordTypeId = recordTypeId;
    	acc.IATACode__c = '100';
        insert acc;
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        insert con;
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        
        ISSP_WS_Create_NonTD_Reports.inputData myInput = new ISSP_WS_Create_NonTD_Reports.inputData();
        ISSP_WS_Create_NonTD_Reports.createNonTDReport(myInput);
        
        myInput.iataCode = '101';
        ISSP_WS_Create_NonTD_Reports.createNonTDReport(myInput);
        
        myInput.iataCode = '100';
        ISSP_WS_Create_NonTD_Reports.createNonTDReport(myInput);
        
        myInput.InboundFileName = 'test';
        myInput.InboundFile = Blob.valueOf('');
        ISSP_WS_Create_NonTD_Reports.createNonTDReport(myInput);
        
        myInput.InboundFile = Blob.valueOf('1234');
        ISSP_WS_Create_NonTD_Reports.createNonTDReport(myInput);
        
        PortalServiceAccessTriggerHandler.avoidAppTrigger = true;
        Portal_Applications__c app = new Portal_Applications__c(Name = 'Treasury Dashboard'); 
        insert app;
        Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = con.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
        insert appRight;
        ISSP_WS_Create_NonTD_Reports.createNonTDReport(myInput);
        
    }
    
    public static List <ISSP_Int_Error__c> createErrors(){
		List <ISSP_Int_Error__c> errorList = new List <ISSP_Int_Error__c>();
		ISSP_Int_Error__c newError1 = new ISSP_Int_Error__c();
    	newError1.Name = 'A001';
    	newError1.Error_Message__c = 'A001';
    	errorList.add(newError1);
    	ISSP_Int_Error__c newError2 = new ISSP_Int_Error__c();
    	newError2.Name = 'B001';
    	newError2.Error_Message__c = 'B001';
    	errorList.add(newError2);
    	ISSP_Int_Error__c newError3 = new ISSP_Int_Error__c();
    	newError3.Name = 'B002';
    	newError3.Error_Message__c = 'B002';
    	errorList.add(newError3);
    	ISSP_Int_Error__c newError4 = new ISSP_Int_Error__c();
    	newError4.Name = 'A099';
    	newError4.Error_Message__c = 'A099';
    	errorList.add(newError4);
    	
    	return errorList;
	}
}