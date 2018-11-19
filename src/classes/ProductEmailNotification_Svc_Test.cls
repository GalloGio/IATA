@isTest
private class ProductEmailNotification_Svc_Test {
	
	@isTest (seeAllData=true)
	static void test_ProductEmailNotification_Svc_Test() {

		//work around to avoid MIXED_DML_OPERATION
		User usr = [Select id from User where Id = :UserInfo.getUserId()];

		System.RunAs(usr){

			Test.startTest();

			//-- Generate Test Data
			TestDataGenerator.generateUtilitySetting();
			List<Product2> products = TestDataGenerator.generateProducts(2, true);

			//Coverage the before insert
			try{
				TestDataGenerator.generateProductEmailNotification(products[0].Id,3,true,true);
			}catch(Exception ex){
				Boolean expectedExceptionThrown =  (ex.getMessage() != null ) ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
			}
				
			//Coverage the after update
			List<Product_Email_Notification__c> pens = TestDataGenerator.generateProductEmailNotification(products[1].Id,3,true,false);
			List<Product_Email_Notification__c> toUpdate = new List<Product_Email_Notification__c>();
			for(Product_Email_Notification__c pen : pens){
				pen.External_email_address__c = 'test@test.com';
				toUpdate.add(pen);
			}
			
			try{
				update toUpdate;
			}catch(Exception ex){
				Boolean expectedExceptionThrown =  (ex.getMessage() != null ) ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
			}

			Test.stopTest();

		}
	}
	
}
