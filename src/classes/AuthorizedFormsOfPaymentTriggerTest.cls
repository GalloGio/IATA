@isTest
public class AuthorizedFormsOfPaymentTriggerTest {

	@testSetup
	private static void setup(){

		GDP_Products_Account_View__c gdpProdAccView = new GDP_Products_Account_View__c();
		insert gdpProdAccView;
		
		
		List<Authorized_Forms_Of_Payment__c> fopList = new List<Authorized_Forms_Of_Payment__c>();

		Authorized_Forms_Of_Payment__c fopCA = new Authorized_Forms_Of_Payment__c(Form_of_Payment_Code__c = AMS_Utils.CA,
																							    Status__c = 'Active',//9
																	 Related_GDP_Products_Account_View__c = gdpProdAccView.Id,
																						   AMS_GDP_Key__c = '12332112331111');

		Authorized_Forms_Of_Payment__c fopCC = new Authorized_Forms_Of_Payment__c(Form_of_Payment_Code__c = AMS_Utils.CC, 
																							    Status__c = 'Non-Active',//1
																	 Related_GDP_Products_Account_View__c = gdpProdAccView.Id,
																	 					   AMS_GDP_Key__c = '12332112332222');

		
		fopList.add(fopCA);
		fopList.add(fopCC);

		insert fopList;

	}


	/**
	* Test the after insert trigger on object Authorized_Forms_Of_Payment__c
	* Consists on inserting a new form of payment.
	*/
	@isTest
	public static void testInsertAuthFormOfPayment(){

		List<GDP_Products_Account_View__c> gdpProdAccViewList = [Select Id from GDP_Products_Account_View__c limit 1];

		Authorized_Forms_Of_Payment__c fopEP = new Authorized_Forms_Of_Payment__c(Form_of_Payment_Code__c = AMS_Utils.EP, 
																							    Status__c = 'Not Authorized',//0
																	 Related_GDP_Products_Account_View__c = gdpProdAccViewList.get(0).Id,
																	 					   AMS_GDP_Key__c = '12332112333333');
		insert fopEP;

		List<GDP_Products_Account_View__c> gdpProdAccViewListAfterInsert = [Select Id, CA_FoP_Status__c, CC_FoP_Status__c, EP_FoP_Status__c from GDP_Products_Account_View__c limit 1];
		List<Authorized_Forms_Of_Payment__c> fopListAfterInsert = [Select Status_Code__c, Form_of_Payment_Code__c from Authorized_Forms_Of_Payment__c 
														where Related_GDP_Products_Account_View__c = :gdpProdAccViewListAfterInsert.get(0).Id];


		for(Authorized_Forms_Of_Payment__c fop : fopListAfterInsert){

			if(fop.Form_of_Payment_Code__c == AMS_Utils.CA){

				System.assertEquals(fop.Status_Code__c, gdpProdAccViewListAfterInsert.get(0).CA_FoP_Status__c, 'FoP Status not ok for CA');

			}

			if(fop.Form_of_Payment_Code__c == AMS_Utils.CC){

				System.assertEquals(fop.Status_Code__c, gdpProdAccViewListAfterInsert.get(0).CC_FoP_Status__c, 'FoP Status not ok for CC');

			}

			if(fop.Form_of_Payment_Code__c == AMS_Utils.EP){

				System.assertEquals(fop.Status_Code__c, gdpProdAccViewListAfterInsert.get(0).EP_FoP_Status__c, 'FoP Status not ok for EP');
			
			}

		}

	}


	/**
	* Test the after update trigger on object Authorized_Forms_Of_Payment__c
	* Consists on changing an already existing form of payment, CC -> EP
	*/
	@isTest
	public static void testUpdateAuthFormOfPayment(){

		List<GDP_Products_Account_View__c> gdpProdAccViewList = [Select Id from GDP_Products_Account_View__c limit 1];

		List<Authorized_Forms_Of_Payment__c> fopListBeforeUpdate = [Select Status_Code__c, Status__c, Form_of_Payment_Code__c from Authorized_Forms_Of_Payment__c 
														where Related_GDP_Products_Account_View__c = :gdpProdAccViewList.get(0).Id 
														and Form_of_Payment_Code__c = :AMS_Utils.CC];

		fopListBeforeUpdate.get(0).Form_of_Payment_Code__c = AMS_Utils.EP;
		fopListBeforeUpdate.get(0).Status__c = 'Not Authorized';
		update fopListBeforeUpdate.get(0);

		List<GDP_Products_Account_View__c> gdpProdAccViewListAfterUpdate = [Select Id, CA_FoP_Status__c, CC_FoP_Status__c, EP_FoP_Status__c from GDP_Products_Account_View__c limit 1];
		
		List<Authorized_Forms_Of_Payment__c> fopListAfterUpdate = [Select Status_Code__c, Form_of_Payment_Code__c from Authorized_Forms_Of_Payment__c 
														where Related_GDP_Products_Account_View__c = :gdpProdAccViewListAfterUpdate.get(0).Id];

		for(Authorized_Forms_Of_Payment__c fop : fopListAfterUpdate){

			if(fop.Form_of_Payment_Code__c == AMS_Utils.CA){

				System.assertEquals(fop.Status_Code__c, gdpProdAccViewListAfterUpdate.get(0).CA_FoP_Status__c, 'FoP Status not ok for CA');

			}

			if(fop.Form_of_Payment_Code__c == AMS_Utils.EP){

				System.assertEquals(fop.Status_Code__c, gdpProdAccViewListAfterUpdate.get(0).EP_FoP_Status__c, 'FoP Status not ok for EP');
			
			}

		}

		System.assertEquals(null, gdpProdAccViewListAfterUpdate.get(0).CC_FoP_Status__c);

	}

	/**
	* Test the after delete trigger on object Authorized_Forms_Of_Payment__c
	* Consists on deleting an already existing form of payment, CC
	*/
	@isTest
	public static void testDeleteAuthFormOfPayment(){

		List<GDP_Products_Account_View__c> gdpProdAccViewList = [Select Id from GDP_Products_Account_View__c limit 1];

		System.debug('angielaz, teste before delete--> gdpProdAccViewList.get(0): ' + gdpProdAccViewList.get(0));

		List<Authorized_Forms_Of_Payment__c> fopListBeforeUpdate = [Select Status_Code__c, Form_of_Payment_Code__c from Authorized_Forms_Of_Payment__c 
														where Related_GDP_Products_Account_View__c = :gdpProdAccViewList.get(0).Id 
														and Form_of_Payment_Code__c = :AMS_Utils.CC];

		delete fopListBeforeUpdate.get(0);

		List<GDP_Products_Account_View__c> gdpProdAccViewListAfterDelete = [Select Id, CA_FoP_Status__c, CC_FoP_Status__c, EP_FoP_Status__c from GDP_Products_Account_View__c limit 1];
		
		System.debug('angielaz, teste after delete--> gdpProdAccViewListAfterDelete.get(0): ' + gdpProdAccViewListAfterDelete.get(0));

		System.assertEquals(null, gdpProdAccViewListAfterDelete.get(0).CC_FoP_Status__c);


	}

}