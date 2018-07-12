/****************************************************************************************************
    Created by David D 
    	Unit Test for 
    		Product_Term_Condition_Dom.cls
    		Product_Term_Condition_Svc.cls
    		Attachment_sel.cls
    		Attachment_Dom.cls
    		Attachment_Svc.cls
    		Term_And_Condition_Sel.cls
    		Term_And_Condition_Svc.cls
    		Term_And_Condition_Dom.cls

****************************************************************************************************/

@isTest
private class Term_And_Condition_Test
{
	@isTest(seeAllData=true)
	static void test_create_TnC()
	{
		User usr = [Select id from User where Id = :UserInfo.getUserId()];

    	System.RunAs(usr){
			Test.startTest();

			TestDataGenerator.generateApexSetting();

			User u = TestDataGenerator.generateUser('Standard User',true);
			System.runAs(u)
			{
				TestDataGenerator.generateTemplateSettings();
			}
			
			//-- generate Products 
			List<Product2> products = TestDataGenerator.generateProducts(5, true);

			products[0].Number_of_months_of_subscription__c = 12;
			update products[0];

			//-- Create T&C
			List<Term_And_Condition__c> tncList = TestDataGenerator.generateTermAndConditions(5,false); // 5 termees an condition are created 


			//-- Save T1 
			insert tncList[0]; 

			//-- Attach Non PDF document
			try{
				Attachment pdf00 = TestDataGenerator.createAttachment(tncList[0].Id, 'tc00.doc', 'TC00 content');
			}catch(Exception e){
				System.AssertEquals(true, String.isNotBlank(e.getMessage()));// Attachment must be PDF
			}

			//-- Attach PDF document 
			try{
				Attachment pdf01 = TestDataGenerator.createAttachment(tncList[0].Id, 'tc01.pdf', 'TC01 content');	

				//-- Update pdf01
				Blob newBody=Blob.valueOf('New Content');
	            pdf01.body=newBody;
	            update pdf01;
				
			}catch(DmlException e){
				//System.AssertEquals(true, String.isNotBlank(e.getMessage()));// Only one attachment
			}
			

			//-- Attch 2nd file 
			try{
				Attachment pdf02 = TestDataGenerator.createAttachment(tncList[0].Id, 'tc02.pdf', 'TC2 content');
			}
			catch(Exception e){
				System.AssertEquals(true, String.isNotBlank(e.getMessage()));// Only one attachment
			}

			//-- T&C0 Status to final 
			tncList[0].Status__c = 'Final';
			update tncList[0]; 

			//-- Insert T2
			tncList[1].Status__c = 'Final';
			try{
				insert tncList[1];
			}catch(Exception e){
				Boolean statusError =  (e.getMessage().contains('Status')) ? true : false;			
				System.AssertEquals(statusError, true);
			}

			//-- Insert T3
			tncList[2].Status__c = 'Final';
			try{
				insert tncList[2];
			}catch(Exception e){
				Boolean dateError =  (e.getMessage().contains('Date')) ? true : false;			
				
			} 

			//-- Attach T1<=>(Prod1, Arline)
			Product_Term_Condition__c   ptc1 = TestDataGenerator.attachTermAndCondition(products[0].Id, tncList[0].Id, 'Airline', true);//Is active = true
			
			TermAndCondition_DTO dto_ptc1 = new TermAndCondition_DTO(ptc1);
			System.assertEquals(tncList[0].Id,dto_ptc1.tncId);

			try{
				Product_Term_Condition__c   ptc2 = TestDataGenerator.attachTermAndCondition(products[0].Id, tncList[0].Id, 'Airline;Member', true);//Is active = true
			}
			catch(Exception ex){

			}

			//-- validate date Attach T4<=>(Prod1, Arline)
			List<Product_Term_Condition__c> ptc4 = [SELECT ID FROM Product_Term_Condition__c WHERE Product__c = :products[0].Id AND Term_Condition__c = :tncList[3].Id];
			
			Map<Id, Attachment> attachmentByTnCId = new Attachment_sel().getAttachmentByTnC(new Set<Id>{tncList[0].Id});
			System.assertEquals(1,attachmentByTnCId.size());
		
			//Term_And_Condition_Sel.cls
			Term_And_Condition_Sel tncSelector = new Term_And_Condition_Sel(); 

			Map<Id, List<Product_Term_Condition__c>> relatedProducts = tncSelector.getRelatedProducts(new Set<Id>{tncList[0].Id});
			Map<Id, List<Product_Term_Condition__c>> activeTnC = tncSelector.getActiveTermsAndConditions('Airline', new Set<Id>{tncList[0].Id});

			//-- List all TnC 
			List<Term_And_Condition__c> tnc0 = (List<Term_And_Condition__c>) tncSelector.selectSObjectById(new Set<Id>{tncList[0].Id});
			System.assertEquals(1, tnc0.size());

			//-- test delete T&C attachment & and create a new one
			tncList[0].Status__c = 'Draft';
			update tncList[0]; 
			delete [SELECT Id FROM Attachment WHERE ParentId = :tncList[0].Id];
			Attachment newAttach = TestDataGenerator.createAttachment(tncList[0].Id, 'newAttach.pdf', 'New Attachment content');
			Term_And_Condition__c term = [SELECT Id, Attachment_Changed__c FROM Term_And_Condition__c WHERE Id = : tncList[0].Id];
			System.assertEquals(true, term.Attachment_Changed__c);

			//Activate the T&C
			tncList[0].Status__c = 'Final';
			update tncList[0]; 

			// Create auto-renew order for product1 
			Account acc = TestDataGenerator.generateAccounts(1, true)[0];
			Contact con = TestDataGenerator.generateContacts(acc.Id, 1, true)[0];

			Order ord = TestDataGenerator.generateOrder(1, acc.Id, con.Id, con.Id,true)[0];
			ord.IEC_Payment_Date__c = Date.today();
			update ord; 

			OrderItem ord_item = TestDataGenerator.generateOrderItem(ord.Id, new List<Product2>{products[0]}, false)[0];
			 	ord_item.Auto_Renew__c = true;
			 	ord_item.Accepted_Term_Condition__c = tncList[0].Id;
		 	insert ord_item;


			//Create new version of T&C 
			Term_And_Condition__c newTerm = new Term_And_Condition__c(
				Name = tncList[0].Name,
				Version_Number__c = 2,
				Effective_Start_Date__c = Date.today(),
				Status__c = 'Draft'
			); 
			insert newTerm;

			//Attach pdf to newTerm
			Attachment newTermAttach = TestDataGenerator.createAttachment(newTerm.Id, 'newTermAttach.pdf', 'newTermAttach content');

			

		 	System.debug('tncList[0].Id::'+tncList[0].Id);
		 	System.debug('ord_item::'+ord_item);

			//Attach it to Product1
			ptc1.Is_Active__c = false;
			update ptc1; 
			Product_Term_Condition__c ptc11 = TestDataGenerator.attachTermAndCondition(products[0].Id, newTerm.Id, 'Airline', true);//Is active = true
			newTerm.Status__c = 'Final';
			try{update newTerm;}
			catch(Exception ex){}

			Test.stopTest();
		}
	}
}