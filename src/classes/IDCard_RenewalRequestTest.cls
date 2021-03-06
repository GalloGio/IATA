//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//

@IsTest
public class IDCard_RenewalRequestTest {

	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'  \"orderId\": \"A cross-reference value from the sending system\",'+
		'  \"created\": \"2019-07-01T12:43:55Z\",'+
		'  \"typeOfCard\": \"digital/plastic\",'+
		'  \"items\": ['+
		'	  {'+
		'	  \"id\": \"RENEWAL\",'+
		'	  \"description\": \"Agent ID card renewal\",'+
		'	  \"quantity\": 1,'+
		'	  \"price\": 85.00'+
		'	},'+
		'	{'+
		'	  \"id\": \"TRAINING_1\",'+
		'	  \"training\": \"Intro to the BSP System & Language - EN\",'+
		'	  \"quantity\": 1,'+
		'	  \"price\": 170.00'+
		'	},'+
		'	{'+
		'	  \"id\": \"TRAINING_2\",'+
		'	  \"training\": \"a training course \",'+
		'	  \"quantity\": 1,'+
		'	  \"price\": 0.00'+
		'	},'+
		'	{'+
		'	  \"id\": \"EXPEDITE\",'+
		'	  \"description\": \"expedited delivery charge\",'+
		'	  \"quantity\": 1,'+
		'	  \"price\": 25.00'+
		'	},'+
		'	{'+
		'	  \"id\": \"PRINTING\",'+
		'	  \"description\": \"Physical Card\",'+
		'	  \"quantity\": 1,'+
		'	  \"price\": 5.00'+
		'	}'+
		'  ],'+
		'  \"payment\": {'+
		'	\"amount\": 460.00,'+
		'	\"discount\": 20.00,'+
		'    \"date\": \"xxxx\",'+
		'	\"currency\": \"USD\",'+
		'	\"cardNumber\": \"1234XXXXXXXX1234\",'+
		'	\"promotionCode\": \"ABC123\",'+
		'    \"transactionNumber\": \"xxxxx\"'+
		'  },'+
		'  \"specializationFields\": {'+
		'	\"ASF_Current_Function__c\": \"AF1;AF2;AF3\",'+
		'	\"ASF_Percentage_of_Annual_Booking__c\": \"N/A\",'+
		'	\"ASF_Market_Specialization__c\": \"N/A\",'+
		'	\"ASF_Market_Specialization_Comment__c\": \"some comment\",'+
		'	\"ASF_Market_Focus__c\": \"N/A\",'+
		'	\"ASF_Specializing_on_Destination__c\": \"N/A\",'+
		'	\"ASF_Completed_Travel_Courses__c\": \"N/A\",'+
		'	\"ASF_Last_Completed_Travel_Course__c\": \"N/A\",'+
		'	\"ASF_FAM_Trips__c\": \"N/A\"'+
		'  }'+
		'}';
		IDCard_RenewalRequest r = IDCard_RenewalRequest.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		IDCard_RenewalRequest.Payment objPayment = new IDCard_RenewalRequest.Payment(System.JSON.createParser(json));
		System.assert(objPayment != null);
		System.assert(objPayment.amount == null);
		System.assert(objPayment.orderDate == null);
		System.assert(objPayment.cur == null);
		System.assert(objPayment.cardNumber == null);
		System.assert(objPayment.promotionCode == null);
		System.assert(objPayment.transactionNumber == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		IDCard_RenewalRequest objIDCard_RenewalRequest = new IDCard_RenewalRequest(System.JSON.createParser(json));
		System.assert(objIDCard_RenewalRequest != null);
		System.assert(objIDCard_RenewalRequest.orderId == null);
		System.assert(objIDCard_RenewalRequest.created == null);
		System.assert(objIDCard_RenewalRequest.typeOfCard == null);
		System.assert(objIDCard_RenewalRequest.items == null);
		System.assert(objIDCard_RenewalRequest.payment == null);
		System.assert(objIDCard_RenewalRequest.specializationFields == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		IDCard_RenewalRequest.Items objItems = new IDCard_RenewalRequest.Items(System.JSON.createParser(json));
		System.assert(objItems != null);
		System.assert(objItems.id == null);
		System.assert(objItems.description == null);
		System.assert(objItems.quantity == null);
		System.assert(objItems.price == null);
		System.assert(objItems.training == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		IDCard_RenewalRequest.SpecializationFields objSpecializationFields = new IDCard_RenewalRequest.SpecializationFields(System.JSON.createParser(json));
		System.assert(objSpecializationFields != null);
		System.assert(objSpecializationFields.ASF_Current_Function == null);
		System.assert(objSpecializationFields.ASF_Percentage_of_Annual_Booking == null);
		System.assert(objSpecializationFields.ASF_Market_Specialization == null);
		System.assert(objSpecializationFields.ASF_Market_Specialization_Comment == null);
		System.assert(objSpecializationFields.ASF_Market_Focus == null);
		System.assert(objSpecializationFields.ASF_Specializing_on_Destination == null);
		System.assert(objSpecializationFields.ASF_Completed_Travel_Courses == null);
		System.assert(objSpecializationFields.ASF_Last_Completed_Travel_Course == null);
		System.assert(objSpecializationFields.ASF_FAM_Trips == null);
	}
}
