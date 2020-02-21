@isTest
public class IDCard_TestDataHelper
{
	public static IATA_ISO_Country__c createIsoCountry()
	{
		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Portugal';
		country.AIMS_Area_Name__c = 'PORTUGAL';
		country.ISO_Code_Numeric__c = 620;
		country.AIMS_Area_ID__c = '2';
		country.ISO_Code__c = 'PT';
		insert country;
		return country;
	}

	public static IATA_ISO_Country__c createUSIsoCountry()
	{
		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'USA';
		country.AIMS_Area_Name__c = 'USA';
		country.ISO_Code_Numeric__c = 621;
		country.AIMS_Area_ID__c = '2';
		country.ISO_Code__c = 'US';
		insert country;
		return country;
	}

	public static Price_Table__c createPriceTable()
	{
		IATA_ISO_Country__c country = createIsoCountry();

		Price_Table__c p1 = new Price_Table__c();
		p1.CurrencyIsoCode = 'EUR';
		p1.ISO_Country__c = country.Id;
		p1.Type_Class_of_Agent__c = 'Passenger';
		p1.Expedite_Delivery_added_to_IDCard_Price__c = false;
		p1.Expedite__c = 25;
		p1.IATA_Package__c = 100;
		p1.ID_Card_Fee__c = 20;
		p1.Cost_of_Printer__c = 10;
		insert p1;
		return p1;
	}

	public static Price_Table__c createUSPriceTable()
	{
		IATA_ISO_Country__c country = createUSIsoCountry();

		Price_Table__c p1 = new Price_Table__c();
		p1.CurrencyIsoCode = 'USD';
		p1.ISO_Country__c = country.Id;
		p1.Type_Class_of_Agent__c = 'Passenger';
		p1.Expedite_Delivery_added_to_IDCard_Price__c = false;
		p1.Expedite__c = 30;
		p1.IATA_Package__c = 105;
		p1.ID_Card_Fee__c = 25;
		p1.Cost_of_Printer__c = 15;
		insert p1;
		return p1;
	}

	public static Account createAccount()
	{
		Price_Table__c price = createPriceTable();

		Account acc = new Account();
		acc.Name = 'Account Test';
		acc.IATACode__c = '12345678';
		acc.Type = 'IATA Passenger Sales Agent';
		acc.IATA_ISO_Country__c = price.ISO_Country__c;
		acc.Location_Type__c = 'HO';
		acc.Location_Class__c = 'P';
		acc.Status__c = 'Approved';
		acc.BillingCountry = 'Portugal';
		acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		insert acc;
		return acc;
	}

	public static Account createUSAccount()
	{
		Price_Table__c price = createUSPriceTable();

		Account acc = new Account();
		acc.Name = 'Account Test';
		acc.IATACode__c = '87654321';
		acc.Type = 'IATAN Passenger Sales Agent (USA Only)';
		acc.IATA_ISO_Country__c = price.ISO_Country__c;
		acc.Location_Type__c = 'HO';
		acc.Location_Class__c = 'P';
		acc.Status__c = 'Approved';
		acc.BillingCountry = 'USA';
		acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		insert acc;
		return acc;
	}
}
