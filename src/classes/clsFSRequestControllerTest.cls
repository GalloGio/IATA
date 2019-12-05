@isTest
private class clsFSRequestControllerTest{
 

		static testMethod void testMyController() {  
		
				//Use the PageReference Apex class to instantiate a page  
				PageReference pageRef = Page.FinancialSecurityRequest;  
				
				//In this case, the Visualforce page named 'success' is the starting point of this test method.   
				Test.setCurrentPage(pageRef);  
				
				//Instantiate and construct the controller class.     
				clsFinancialSecurityRequestController controller = new clsFinancialSecurityRequestController();  

				
						 
					
				// Set some properties  
				date t = date.parse('12/27/2012');
				EmailTemplate__c e = new EmailTemplate__c();
				Insert e;
				
				controller.CaseParameter.EmailTemplate__c = e.Id;
				controller.CaseParameter.Deadline_Date__c = t;
				controller.MassSendEmail();

			 
				 BatchNumber__c batch = new BatchNumber__c();
				 insert batch;
			 controller.CaseParameter.BatchNumber__c= batch.Id;
			 
			 
				
				Apexpages.currentPage().getParameters().put('batchNumber',batch.Id);
				controller.runSearch();
				
								
				controller.SelectAll();
				List<clsFinancialSecurityRequestController.cCase> tmp = Controller.Cases;
				Controller.Cases= tmp;
				

				Apexpages.currentPage().getParameters().put('batchNumber','');
				controller.runSearch();
				controller.SelectAll();
				Apexpages.currentPage().getParameters().put('template',null);
				Apexpages.currentPage().getParameters().put('deadlineDate', ''); 
				controller.MassSendEmail();
				
				
			
				
				Apexpages.currentPage().getParameters().put('batchNumber','%');
				controller.runSearch();
				controller.SelectAll();        
				Apexpages.currentPage().getParameters().put('template',e.Id);
				Apexpages.currentPage().getParameters().put('deadlineDate', '12/27/2012');
				controller.CaseParameter.EmailTemplate__c = e.Id;
				controller.CaseParameter.Deadline_Date__c = t ;  
				controller.SelectAll();             
				controller.MassSendEmail();
				
				
			 // Boolean a = controller.FSLetterSent;
			 // a = controller.FSValueMissing;
				
				controller.SelectAll();
				controller.first();
				controller.last();
				controller.previous();
				controller.next();
				
				
			
				Boolean num = controller.isNbrRecordsDisplayed;
				Integer num2 = controller.nbrSelectedRecords; 
				Integer num3 = controller.nbrFoundRecords;
				controller.nbrFoundRecords = num3;
				Integer num4 = controller.currentPage;
				controller.currentPage = num4;
				
				controller.updateNbrSelectedRecords();
				
				
				
				Boolean boo = controller.hasNext;
				boo = controller.hasPrevious;
				boo = controller.hasFirst;
				boo = controller.hasLast;
				
				Integer nbPages = controller.pageNumber; 
				Integer nbOFPages = controller.noOfPages;
				
				

				controller.toggleSort();
				
				
				
			Case ca = new Case();
			 Insert ca;
			 List<Case> cases = [Select c.Status,c.EmailTemplate__c, c.Deadline_Date__c From Case c Where c.Id = :  ca.Id];
						
			
				
		 Test.startTest();        
				clsFinancialSecurityRequestBatch cBatch = new clsFinancialSecurityRequestBatch();
				cBatch.caseList = cases;
				cBatch.emailTemplate = '' ;
				cBatch.deadLineDate = controller.CaseParameter.Deadline_Date__c ;
			 ID batchprocessid = Database.executeBatch(cBatch,5);
		Test.stopTest();     
		
		
		} 

			static testMethod void testTrackedEmails() {  
				
				Account account1 = new Account();
				account1.Name = 'Test account';
				account1.BillingCity = 'Montreal';
				account1.BillingCountry = 'Canada';
				account1.BillingStreet = 'some street';
				account1.IATACode__c = '1234567';
				account1.Type = 'IATA Passenger Sales Agent';
				account1.Location_Type__c = 'HO';
				account1.Status__c = 'Approved';
				insert account1;
				
				// create test contact
				Contact contact1 = new Contact();
				contact1.FirstName = 'Dummy';
				contact1.LastName = 'Contact';
				contact1.Type_of_Contact__c = 'IFAP Contact';
				contact1.AccountId = account1.Id;
				contact1.Email = 'some@email.org';
				contact1.Financial_Assessment_Contact__c = true;
				insert contact1;

				BatchNumber__c batch = new BatchNumber__c();
				insert batch;
				
				EmailTemplate__c e = new EmailTemplate__c();
				e.Is_Reminder__c = false;
				e.Template_Type__c = 'FS - Financial Security';
				e.FA_Result__c = 'Satisfactory - New Financial Security';
				insert e;

				
				Case cse = new Case();
				cse.AccountId = account1.Id;
				cse.ContactId = contact1.Id;
				cse.BatchNumber__c = batch.Id;
				cse.Status = 'Assessment Performed';
				cse.Financial_Review_Result__c = 'Satisfactory';
				insert cse;
				
				Signaturit_Events_WS__c ws = new Signaturit_Events_WS__c(name = 'test', events_url__c = 'http://test.com', oauth_url__c = '');
		insert ws;
				
				//Use the PageReference Apex class to instantiate a page  
				PageReference pageRef = Page.FinancialSecurityRequest;  
				
				//In this case, the Visualforce page named 'success' is the starting point of this test method.   
				Test.setCurrentPage(pageRef);  
				
				//Instantiate and construct the controller class.     
				clsFinancialSecurityRequestController controller = new clsFinancialSecurityRequestController();  
				
				controller.CaseParameter.BatchNumber__c= batch.Id;
				
				Apexpages.currentPage().getParameters().put('batchNumber',batch.name);
				controller.runSearch();
				
				controller.SelAllIsChecked = true;
				
				controller.SelectAll();
				List<clsFinancialSecurityRequestController.cCase> tmp = Controller.Cases;
				Controller.Cases= tmp;
				
				controller.MassSendTrackedEmail();
		
				cse.Financial_Security_Amount__c = 12345;
				cse.Financial_Security_Currency__c = 'EUR';
				cse.FS_EmailTemplate__c = e.Id;
		update cse;
		
				controller.CaseParameter.EmailTemplate__c = e.Id;
				controller.CaseParameter.Deadline_Date__c = Date.today().addMonths(2);
				
			controller.MassSendTrackedEmail();
		}
	static testMethod void caseBatchTest() {	

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name = 'Portugal', ISO_Code__c = 'PT', AIMS_Area_ID__c = '2');
		insert ctry;

		Account account1 = new Account();
		account1.Name = 'Test account';
		account1.BillingCity = 'Montreal';
		account1.BillingCountry = 'Canada';
		account1.BillingStreet = 'some street';
		account1.IATACode__c = '1234567';
		account1.Type = 'IATA Passenger Sales Agent';
		account1.Location_Type__c = 'HO';
		account1.Status__c = 'Approved';
		account1.IATA_ISO_Country__c = ctry.Id;
		insert account1;		

		EmailTemplate__c e = new EmailTemplate__c();
		e.Is_Reminder__c = false;
		e.IATA_ISO_Country__c = ctry.Id;
		e.Template_Type__c = 'FS - Financial Security';
		e.FA_Result__c = 'Satisfactory - New Financial Security';
		insert e;

		BatchNumber__c batch = new BatchNumber__c();
		insert batch;

		Case caseParam = new Case(Status = 'Open',
								IFAP_Country_ISO__c = ctry.ISO_Code__c,
								AccountId =  account1.Id,
								BatchNumber__c = batch.Id,
								Financial_Review_Type__c = 'New applications',
								Financial_Security_Amount__c = 12345,
								Financial_Security_Currency__c = 'EUR',
								RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review'));

		insert caseParam;		
					
		caseParam.Financial_Review_Result__c = 'Satisfactory - New Financial Security';
		caseParam.FS_EmailTemplate__c = e.Id;
		caseParam.FS_Deadline_Date__c = System.today();
		caseParam.Status = 'Assessment Performed';
		update caseParam;	

		Test.startTest();			

			clsFinancialSecurityRequestController controller = new clsFinancialSecurityRequestController();  
			controller.CaseParameter.BatchNumber__c = batch.Id;			
			controller.CaseParameter.EmailTemplate__c =  e.Id;
			controller.CaseParameter.Deadline_Date__c = System.today().addDays(40);
			controller.runSearch();
			controller.SelAllIsChecked = true;
			controller.SelectAll();
			controller.MassSendEmail();

		Test.stopTest();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		boolean b = false;

		for(Apexpages.Message msg:msgs){
			if (msg.getDetail().contains('Financial Security Request is sent. Please note that the emails will take time to be recieved.')) b = true;
		}

		System.assert(b);		

		}

}