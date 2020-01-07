/**
 * Created by bkaya01 on 28/08/2019.
 */

@isTest
public class PortalCreatePasswordControllerTest {

	@isTest
	public static void unitTest(){

		//Create Bucket Account for Country c1
		Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

		Account acc = new Account();
		acc.RecordTypeId = rtHQ;
		acc.Name='Bucket Airline1';
		acc.ACLI_Status__c = 'Active Company';
		acc.MITA_Member__c = true;
		acc.BIETA_Member__c = true;
		acc.Airline_designator__c = 'AA';
		acc.IATACode__c = '4321';
		acc.Airline_Prefix__c = '765';
		acc.Sector__c = 'Airline';
		acc.Category__c = 'Passenger and Cargo';
		acc.is_general_public_account__c = true;
		insert acc;

		IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS' );
		insert isoCountry;

		string paramsJson = '{"phone":"","lastName":"test","language":"en_us","firstName":"test","email":"test+xx@gmail.com","country":"' + isoCountry.id + '","contactId":"","accountId":"' + acc.Id + '", "registrationTime":"2019-10-02 09:29:02", "lms":"yas"}';
		string enc = EncodingUtil.urlEncode(PortalPasswordHandler.EncryptString(paramsJson), 'UTF-8');
		PortalCreatePasswordController.returnWrapper result = PortalCreatePasswordController.getParameters('https://a.a.com/s/createPassword?c=' + enc);
		boolean success = PortalCreatePasswordController.isUserExist('test@iata.com','');

		PortalRegistrationFirstLevelCtrl.RegistrationParameters params = new PortalRegistrationFirstLevelCtrl.RegistrationParameters();
		//PortalRegistrationFirstLevelCtrl.RegistrationResult createResult = PortalCreatePasswordController.createUserAndSetPassword(JSON.serialize(params), 'test');
		PortalRegistrationFirstLevelCtrl.RegistrationResult createResult = PortalCreatePasswordController.createUserAndSetPassword(paramsJson, 'test');

		PortalCreatePasswordController.resendEmail(JSON.serialize(result));
	}

}
