@isTest
public class CW_RemoteValidationsControllerTest {
    @TestSetup
    private static void setup(){

        IATA_ISO_Country__c isoCode = CW_TestDataFactory.newISOCountry();
		insert isoCode;

		Account acc = CW_TestDataFactory.TestAccount(isoCode.Id);
		acc.Name = 'TEST Airline HQ/operator';
		acc.Airline_designator__c = 'AA';
		acc.ICAO_designator__c = 'SSV';
        insert acc;
        
        Airport_Detail__c airport = CW_TestDataFactory.newAirport(isoCode.Id, acc.Id);
        insert airport;
        
        Account_Role__c accRole = CW_TestDataFactory.testAccountRole(
			acc.Id,
			'Test'
		);
		insert accRole;

		ICG_Account_Role_Detail__c accRoleDetail = CW_TestDataFactory.testICGAccountRoleDetail(
			accRole.Id,
			airport
		);
		insert accRoleDetail;

        Contact con1 = new Contact(FirstName = 'Test', LastName='Test', Email = 'Test@Test.com',AccountId = acc.id);
		insert con1;
        
        Order oOrder = TestDataGenerator.generateOrder(1, con1.AccountId, con1.Id, con1.Id, false)[0];
        oOrder.Type = 'Cart';
        oOrder.Remote_Validation_Status__c='Preparing Document';
      
        insert oOrder;
        OrderItem oit = TestDataGenerator.generateOrderItem(oOrder.Id, 1, false)[0];
        oit.Station__c = accRoleDetail.id;
        oit.IEC_Is_Paid__c = true;
        insert oit;
        Product2 pr = [Select id, name from product2 limit 1];
        pr.name = 'Smart Facility Remote Validation';
        pr.Smart_Facility_Remote_Validation__c = true;
        pr.SAP_Material_Number__c = '12345';
        update pr;

        Profile pf= [Select Id from profile where Name LIKE '%IATA Customer Community User%' limit 1]; 
		String orgId=UserInfo.getOrganizationId(); 
		String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
		Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
		String uniqueName=orgId+dateString+RandomId;
        
        User uu = CW_TestDataFactory.testUser('IATAICGACB', 'IATAICGXYZ', uniqueName, orgId, pf.Id, con1.id);
        insert uu;
        
    }

    @isTest
    static void getProductSmartFacilityTest(){
        User testUser = [SELECT id FROM User WHERE FirstName = 'IATAICGACB' LIMIT 1];
        System.runAs(testUser){
        test.startTest();
        String responseJSON = CW_RemoteValidationsController.getProductSmartFacilityRemoteValidation();
        List<product2> lstProducts = (List<product2>)JSON.deserialize(responseJSON,List<product2>.class);
        System.assertEquals('12345', (lstProducts[0].SAP_Material_Number__c));
        test.stopTest();
        }
    }

    @isTest
    static void getUserRemoteValidationsTest(){
        User testUser = [SELECT id FROM User WHERE FirstName = 'IATAICGACB' LIMIT 1];
        System.runAs(testUser){
            test.startTest();
            string responseJSON = CW_RemoteValidationsController.getUserRemoteValidations(new List<String>{[select id from ICG_Account_Role_Detail__c limit 1].Id});
                System.assertEquals(1, ((List<OrderItem>)JSON.deserialize(responseJSON,List<OrderItem>.class)).size());
                System.assertEquals([select id from ICG_Account_Role_Detail__c limit 1].Id, ((List<OrderItem>)JSON.deserialize(responseJSON,List<OrderItem>.class))[0].Station__c);
            test.stopTest();
        }
    }
    @isTest
    static void createRemoteValidationInternalUser(){
        test.startTest();
        	system.assertEquals(true, CW_RemoteValidationsController.createRemoteValidation([select id from ICG_Account_Role_Detail__c limit 1].Id).success);
        test.stopTest();
    }
    
    public static PricebookEntry createPricebookEntry (Pricebook2 newPricebook, Product2 prod) {
	    PricebookEntry ret = new PricebookEntry();
	    ret.pricebook2Id = newPricebook.id;
	    ret.product2id = prod.id;
	    ret.unitprice = 1250.0;
	    ret.isactive = true;
	    insert ret;
	    return ret;
	}
}