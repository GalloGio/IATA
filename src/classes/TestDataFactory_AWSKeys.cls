@istest
public class TestDataFactory_AWSKeys {
    public static void createAllEntries() {
		List<Amazon_Cred__c> creds = new List<Amazon_Cred__c>();
		creds.add(new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf'));
		creds.add(new Amazon_Cred__c(name = 'GenericAttach', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf'));
		creds.add(new Amazon_Cred__c(name = 'RecycleBin', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf'));
		creds.add(new Amazon_Cred__c(Name = 'IdCard', Prod_Configuration__c = 'IdCardProd', Dev_Configuration__c = 'IdCardDev'));
		creds.add(new Amazon_Cred__c(Name = 'ACLI', Prod_Configuration__c = 'adevconf', Dev_Configuration__c = 'adevconf'));
		creds.add(new Amazon_Cred__c(Name = 'endpoint', Prod_Configuration__c = 'adevconf', Dev_Configuration__c = 'adevconf'));
		insert creds;


		map<string, AWSKey__c> mapAWSKeys = new map<string, AWSKey__c>();

		for(Amazon_Cred__c cred:creds){
			mapAWSKeys.put(cred.Prod_Configuration__c, new AWSKey__c(
				name = cred.Prod_Configuration__c,
				key_encrypted__c = 'asd',
				secret_encrypted__c = 'asd',
				IAS_configuration_name__c = 'asdas',
				IAS_Access_Point__c = 'asd',
				Bucket__c = 'asd',
				AWS_ENDPOINT_URL__c = 'asd'));

			mapAWSKeys.put(cred.Dev_Configuration__c, new AWSKey__c(
				name = cred.Dev_Configuration__c,
				key_encrypted__c = 'asd',
				secret_encrypted__c = 'asd',
				IAS_configuration_name__c = 'asdas',
				IAS_Access_Point__c = 'asd',
				Bucket__c = 'asd',
				AWS_ENDPOINT_URL__c = 'asd'));
		}

		mapAWSKeys.put('production', new AWSKey__c(
				name = 'production',
				key_encrypted__c = 'asd',
				secret_encrypted__c = 'asd',
				IAS_configuration_name__c = 'asdas',
				IAS_Access_Point__c = 'asd',
				Bucket__c = 'asd',
				AWS_ENDPOINT_URL__c = 'asd'
		));
		mapAWSKeys.put('sandbox', new AWSKey__c(
				name = 'sandbox',
				key_encrypted__c = 'asd',
				secret_encrypted__c = 'asd',
				IAS_configuration_name__c = 'asdas',
				IAS_Access_Point__c = 'asd',
				Bucket__c = 'asd',
				AWS_ENDPOINT_URL__c = 'asd'
		));
		
				
		insert mapAWSKeys.values();
    }
}
