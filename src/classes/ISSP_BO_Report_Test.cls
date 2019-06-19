@isTest
private class ISSP_BO_Report_Test {

    static testMethod void ISSP_BO_Report_Test_1() {
    	
    	Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.Sector__c = 'Airline';
        insert acc;
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        insert con;
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        //thisUser.Mgmt_Report_Team__c = true;
    	//update thisUser;
    	
    	ContactShare newShare = new ContactShare();
    	newShare.ContactAccessLevel = 'Edit';
    	newShare.ContactId = con.Id;
    	newShare.UserOrGroupId = thisUser.Id;
    	insert newShare;
    	
        ISSP_BO_Report cttr = new ISSP_BO_Report();
        ISSP_BO_Report__c bo = new ISSP_BO_Report__c();
        bo.Report_Date__c = system.Today();
        insert bo;
        Attachment attach = new Attachment();     
        attach.Name='[UNITTEST][FILE][SMALL]';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = bo.Id;
        insert attach;
        ISSP_BO_Report__c bo2 = new ISSP_BO_Report__c();
        bo2.Report_Date__c = system.Today()-45;
        insert bo2;
        Attachment attach2 = new Attachment();     
        attach2.Name='[UNITTEST][FILE][SMALL]';
        Blob bodyBlob2 = Blob.valueOf('Unit Test Attachment Body');
        attach2.body = bodyBlob2;
        attach2.parentId = bo2.Id;
        insert attach2;
        ISSP_BO_Report__c bo3 = new ISSP_BO_Report__c();
        bo3.Report_Date__c = system.Today();
        insert bo3;
        Attachment attach3 = new Attachment();     
        attach3.Name='[UNITTEST][FILE][SMALL]';
        Blob bodyBlob3 = Blob.valueOf('Unit Test Attachment Body');
        attach3.body = bodyBlob3;
        attach3.parentId = bo3.Id;
        insert attach3;
        
        cttr.pageLoad();
        
        system.runAs(thisUser){
	        cttr.pageLoad();
        }
        
        User myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	myUser.Mgmt_Report_Team__c = true;
    	update myUser;
    	myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        Portal_Applications__c app = new Portal_Applications__c(Name = 'Management Information Report'); 
        insert app;
        Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = con.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
        insert appRight;
        
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
    
    static testMethod void ISSP_BO_Email_Interface_1(){
    	
    	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	thisUser.Mgmt_Report_Team__c = true;
    	update thisUser;
    	thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	system.runAs(thisUser){
	    	Account acc = ISSP_ObjectFactory.createNewAccount();
            acc.Sector__c = 'Airline';
			insert acc;
			Contact contact = ISSP_ObjectFactory.createNewContact();
	        contact.AccountId = acc.Id;
	        insert contact;
	    	Portal_Applications__c app = new Portal_Applications__c(Name = 'Management Information Report'); 
	        insert app;
	        Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = contact.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
	        insert appRight;
	        Notification_template__c notificationTemplate = new Notification_template__c();
	        notificationTemplate.Subject__c = 'Test 001';
	        notificationTemplate.Type__c = 'Action';
	        notificationTemplate.Admins_Users__c = 'User';
	        notificationTemplate.Message__c = 'test {0}';
	        notificationTemplate.Notification_color__c = '#007FFF';
	        insert notificationTemplate;
	        ISSP_Notifications_Trigger__c ntr = new ISSP_Notifications_Trigger__c();
            ntr.Name = 'Management Information Report';    
            ntr.Notification_Template_Id__c = notificationTemplate.Id;
           	insert ntr;
    	}
    	
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
         
        // setup the data for the email
        email.subject = 'Test Job Applicant';
        email.plainTextBody = 'test';
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
		attachment.body = blob.valueOf('my attachment text');
		attachment.fileName = 'textfileone.txt';
		attachment.mimeTypeSubType = 'text/plain';
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

        // call the email service class and test it with the data in the testMethod
        ISSP_BO_Email_Interface emailProcess = new ISSP_BO_Email_Interface();
        emailProcess.handleInboundEmail(email, env);
    }
}