@IsTest
public class TestDataFactory_Accounts {
	public static final String DEFAULTNAME = 'TEST ACCOUNT';

	public static List<Account> createDefaultAccounts (Integer numberOfRecords){
		//get standard record type
		Id recordTypeId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account', 'Others');
		//create and return Account List
		List<Account> accountList = new List<Account>();
		for (Integer x = 0; x < numberOfRecords; x ++){
			Account account = new Account(Name = DEFAULTNAME + ' ' + x, RecordTypeId = recordTypeId);
			accountList.add(account);
		}
		return accountList;
	}

	public static List<Account> createStandardAccounts (Integer numberOfRecords){
		//get standard record type
		Id recordTypeId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account', 'Standard_Account');

		//create and return Account List
		List<Account> accountList = new List<Account>();
		for (Integer x = 0; x < numberOfRecords; x ++){
			Account account = new Account(Name = DEFAULTNAME + ' ' + x, RecordTypeId = recordTypeId);
			accountList.add(account);
		}
		return accountList;
	}

	public static List<Account> createAirlineAccounts (Integer numberOfRecords){
		//get airline HQ record type
		Id recordTypeId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account', 'IATA_Airline');

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