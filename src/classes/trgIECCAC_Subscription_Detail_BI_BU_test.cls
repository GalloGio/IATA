/**
* @author Alexandre Jaimes
* @date 2016
* @group CACW
* @description This is the Test class to test trigger trgIECCAC_Subscription_Detail_BI_BU
*/
@isTest
private class trgIECCAC_Subscription_Detail_BI_BU_test {

	static testMethod void TestInsertCACSubsrciptionDetail(){
		//Arrange
		CAC_Subscription_Detail__c CAC_SubDetail = new CAC_Subscription_Detail__c();
		CAC_SubDetail.Name = 'Test Subscription Name';
		CAC_SubDetail.Service_Activation_Date__c = Date.Today();
		CAC_SubDetail.Status__c = 'Active';
		CAC_SubDetail.Service_Token__c = '';

		//Act Insert
		Insert CAC_SubDetail;


		//Assert
		CAC_SubDetail = [Select Id, Service_Token__c, Service_Activation_Date__c
						 FROM CAC_Subscription_Detail__c WHERE Id =:CAC_SubDetail.Id][0];
		System.AssertNotEquals(CAC_SubDetail.Service_Token__c,'', 'Inserting a new record should create a Service Token');

		//Act Update
		String ServiceTokenBeforeUpdate = CAC_SubDetail.Service_Token__c;
		CAC_SubDetail.Service_Activation_Date__c = Date.Today().AddDays(-1);
		Update CAC_SubDetail;

		//Assert
		CAC_SubDetail = [Select Id, Service_Token__c
						 FROM CAC_Subscription_Detail__c WHERE Id =:CAC_SubDetail.Id][0];
		System.AssertNotEquals(CAC_SubDetail.Service_Token__c,ServiceTokenBeforeUpdate,'Updating the activation date should change the Service Token');

	}


}
