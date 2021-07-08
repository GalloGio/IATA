@IsTest
public class TestDataFactory_Accounts {
	public static final String DEFAULTNAME = 'TEST ACCOUNT';
	
	@TestSetup
	static void makeData(){
		List<IATA_ISO_Country__c> iataISOCountryList = TestDataFactory_IATAISOCountries.createDefaultIATAISOCountries(1);
		insert iataISOCountryList;
	}

	public static List<Account> createDefaultAccounts (Integer numberOfRecords){
		//create dependent data
		makeData();
		//get standard record type
		Id recordTypeId = RecordTypeSelector.selectIdBySObjectAndName('Account', 'Others');
		//get iataISOCountry ID
		IATA_ISO_Country__c iataISOCountry = [SELECT Id FROM IATA_ISO_Country__c WHERE Name = :TestDataFactory_IATAISOCountries.DEFAULTCOUNTRYNAME].get(0);
		//create and return Account List
		List<Account> accountList = new List<Account>();
		for (Integer x = 0; x < numberOfRecords; x ++){
			Account account = new Account(Name = DEFAULTNAME + ' ' + x, RecordTypeId = recordTypeId, IATA_ISO_Country__c = iataISOCountry.Id);
			accountList.add(account);
		}
		return accountList;
	}

	public static List<Account> createStandardAccounts (Integer numberOfRecords, Id iataISOCountryId){
		//get standard record type
		Id recordTypeId = RecordTypeSelector.selectIdBySObjectAndName('Account', 'Others');
		
		//create and return Account List
		List<Account> accountList = new List<Account>();
		for (Integer x = 0; x < numberOfRecords; x ++){
			Account account = new Account(Name = DEFAULTNAME + ' ' + x, RecordTypeId = recordTypeId, IATA_ISO_Country__c = iataISOCountryId);
			accountList.add(account);
		}
		return accountList;
	}

	public static List<Account> createAirlines (Integer numberOfRecords){
		//get airline HQ record type
		Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

		//create and return Account List
		List<Account> accountList = new List<Account>();
		for (Integer x = 0; x < numberOfRecords; x ++){
			Account account = new Account(
				Name = DEFAULTNAME + ' ' + x,
				RecordTypeId = recordTypeId,
				IATACode__c = x.format().leftPad(6, '0'),
				Airline_designator__c = x.format().leftPad(2, '0'),
				Airline_Prefix__c = x.format().leftPad(3, '0')
			);
			accountList.add(account);
		}
		return accountList;
	}
}