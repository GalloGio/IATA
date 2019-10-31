@isTest
public class ams2gdp_TestDataGenerator
{
	public static List<Account> generateAccounts(Integer nb, Boolean doInsert)
	{
		List<Account> accounts = new List<Account>();
		List<IATA_ISO_Country__c> countries = generateISOCountryState();

        for(Integer i = 0; i < nb; i++)
        {
            accounts.add(new Account(
                Name = 'test account ' + i ,
                Sector__c = 'IATA',
                Category__c = 'IATA HEAD OFFICE',
                CurrencyIsoCode = 'USD',
                BillingStreet ='42 Edmond',
                BillingCity= 'Montreal',
                BillingPostalCode ='h1v1f8',
                BillingState='Quebec',
                BillingCountry='Canada',
                ShippingStreet ='42 Edmond',
                ShippingCity= 'Montreal',
				Status__c = 'Terminated',
                ShippingPostalCode ='h1v1f8',
                ShippingState='Quebec',
                ShippingCountry='Canada',
                Customer_Type__c = 'Member Airline',
                Location_Class__c = 'C'+i,
                Phone_Number__c = '+1-888-123-456'+i,
                Phone = '+1-888-123-456'+i,
                Fax = '+1-999-123-45'+i,
                GDS__c = 'ABAC;UALA',
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
                IATACode__c = 'I'+i,
                IATA_ISO_Country__c=countries[0].Id
            ));
        }

        if(doInsert){
            insert accounts;
            List<Accreditation__c> accreditations = new List<Accreditation__c>();
            GDP_Reference_Table__c tblStatus = new GDP_Reference_Table__c(Code__c='4');
            GDP_Reference_Table__c tblEndorse = new GDP_Reference_Table__c(Code__c='IATA');
            insert new List<GDP_Reference_Table__c>{tblStatus,tblEndorse};

            for(Account acc: accounts)
            {
            	accreditations.add(new Accreditation__c(
            		Related_Account__c = acc.Id,
            		Accreditation_ID__c = 1,
            		Status__c = tblStatus.Id
        		));
            }
            insert accreditations;
        }

        return accounts;
	}

	public static List<GDP_Reference_Table__c> generateReferenceTables(Integer nb, Boolean doInsert)
	{
		List<GDP_Reference_Table__c> result = new List<GDP_Reference_Table__c>();

		for(Integer x=0; x<nb; x++)
		{
			result.add(new GDP_Reference_Table__c(
				Name = 'Ref '+x
				, Code__c = 'C'+x
				, Definition__c = 'Ref '+x
			));
		}

		if(doInsert)
			insert result;

		return result;
	}

	public static List<GDP_Reference_Table__c> generateReferenceTables(String table, Integer nb, Boolean doInsert)
	{
		List<GDP_Reference_Table__c> result = new List<GDP_Reference_Table__c>();

		for(Integer x=0; x<nb; x++)
		{
			result.add(new GDP_Reference_Table__c(
				Name = 'Ref '+x
				, Code__c = 'C'+x
				, Table__c = table
				, Definition__c = 'Ref '+x
			));
		}

		if(doInsert)
			insert result;

		return result;
	}
	public static List<GDP_Reference_Table__c> generateReferenceTableswithTableName(Integer nb, Boolean doInsert)
	{
		List<GDP_Reference_Table__c> result = new List<GDP_Reference_Table__c>();
		List<String> tableName=new List<String>{'APENL2','APEN4L','APEN4A','APSALE','APSPEC','APDEST','APEN2C','APEN4S','APPRAC','APEN4H'};
		List<String> codeValues=new List<String>{'L1','L2','A1','4','AD','A2','C1','S1','RT','H1'};

		for(Integer x=0; x<nb; x++)
		{
			result.add(new GDP_Reference_Table__c(
				Name = 'Ref '+x
				, Code__c = codeValues[x]
				, Table__c = tableName[x]
				, Definition__c = 'Ref '+x
			));
		}

		if(doInsert)
			insert result;

		return result;
	}

	public static List<AMS_Affiliation__c> generateAffiliations(Integer  nb, Boolean doInsert)
	{
		List<AMS_Affiliation__c> result = new List<AMS_Affiliation__c>();
		for(Integer x=0; x<nb; x++)
		{
			result.add(new AMS_Affiliation__c(
				Affiliation_Code__c = 'C'+x
			));
		}

		if(doInsert)
			insert result;


		return result;
	}

	public static List<AMS_Agency_Affiliation__c> generateAMS_Agency_Affiliations(Integer nb, Boolean doInsert)
	{
		List<AMS_Agency_Affiliation__c> result = new List<AMS_Agency_Affiliation__c>();

		List<Account> accounts = generateAccounts(nb,true);
		List<AMS_Affiliation__c> affiliations = generateAffiliations(nb,true);


		for(Integer x=0; x<nb; x++)
		{
			result.add(new AMS_Agency_Affiliation__c(
				Account__c = accounts[x].Id
				, Affiliation__c = affiliations[x].Id
				, Legacy_System__c = (Math.mod(x, 2)==0) ? 'Webstar' : 'AIMS'
				, Legacy_External_ID__c = (Math.mod(x, 2)==0) ? 'ABCD123'+x : 'ABCD123'+x+'-'+affiliations[x].Affiliation_Code__c
			));
		}

		if(doInsert)
			insert result;

		return result;
	}

	public static List<AMS_Accreditation_Organization__c> generateAccreditationEndorsementOrganisations(Integer nb, Boolean doInsert)
	{
		List<AMS_Accreditation_Organization__c> result = new List<AMS_Accreditation_Organization__c>();
		List<String> air_codes = new List<String>{'IATA','IATAN','DOM', 'VM', 'AB'};

		for(Integer x=0; x<nb; x++)
		{
			result.add(new AMS_Accreditation_Organization__c(
				Name = 'Accreditation Organization '+x,
				Air_Code__c = air_codes[Math.mod(x,air_codes.size())]
			));
		}

		if(doInsert)
			insert result;

		return result;
	}

	public static List<AMS_Airport__c> generateAMS_Airports(Integer nb, Boolean doInsert)
	{
		List<AMS_Airport__c> result = new List<AMS_Airport__c>();

		for(Integer x=0; x<nb; x++)
		{
			result.add(new AMS_Airport__c(
				Name = 'Airport '+x,
				Code__c='Ac'+x
			));
		}

		if(doInsert)
			insert result;

		return result;
	}

	public static List<AMS_Territory__c> generateAMS_Territories(Integer nb, Boolean doInsert)
	{
		List<AMS_Territory__c> result = new List<AMS_Territory__c>();
		List<AMS_Inspection__c> appointments=generateAMS_Inspections(nb,true);
		List<Account> accounts = generateAccounts(nb,true);
		List<AMS_Accreditation_Organization__c> accreditations =  generateAccreditationEndorsementOrganisations(nb,true);
		List<IATA_ISO_Country__c> countries = generateISOCountryState();

			for(Integer x=0; x<nb; x++)
		{
			result.add(new AMS_Territory__c(Appointment__c = appointments[x].Id,
				ISO_Country__c=(Math.mod(x, 3)==0) ?countries[0].Id:countries[0].Id

			));
		}


		if(doInsert)
			insert result;

		return result;
	}



	public static List<AMS_Inspection__c> generateAMS_Inspections(Integer nb, Boolean doInsert)
	{
		List<AMS_Inspection__c> result = new List<AMS_Inspection__c>();

		List<AMS_Accreditation_Organization__c> accreditations =  generateAccreditationEndorsementOrganisations(nb,true);
		List<Account> accounts = generateAccounts(nb,true);


		for(Integer x=0; x<nb; x++)
		{
			result.add(new AMS_Inspection__c(
				Accreditation_Endorsement_organisation__c = accreditations[x].Id
				, Accreditation_Endorsement_Status_code__c = 'C'+x
				, Account__c = accounts[x].Id
				, Legacy_System__c = (Math.mod(x, 2)==0) ? 'Webstar' : 'AIMS'
				, Legacy_External_ID__c = (Math.mod(x, 2)==0) ? 'ABCD123'+x : 'ABCD123'+accreditations[x].Air_Code__c
			));
		}

		if(doInsert)
			insert result;

		return result;
	}

	public static List<IATA_ISO_Country__c> generateISOCountryState() {
        List<IATA_ISO_Country__c> listCountry = new List<IATA_ISO_Country__c>();
        List<IATA_ISO_State__c> listState = new List<IATA_ISO_State__c>();

        try
        {
            listCountry.add(new IATA_ISO_Country__c(Name='Canada', ISO_Code__c='CA', International_dialing_code_ISD__c='1',ISO_Code_Numeric__c=12));
            listCountry.add(new IATA_ISO_Country__c(Name='Chile', ISO_Code__c='CL', International_dialing_code_ISD__c='56',ISO_Code_Numeric__c=12));
            listCountry.add(new IATA_ISO_Country__c(Name='Mexico', ISO_Code__c='MX',International_dialing_code_ISD__c='52',ISO_Code_Numeric__c=12));
            listCountry.add(new IATA_ISO_Country__c(Name='United States', ISO_Code__c='US', International_dialing_code_ISD__c='1',ISO_Code_Numeric__c=12));
            Database.upsert(listCountry, IATA_ISO_Country__c.ISO_Code__c, false);
        }
        catch (Exception e) {}

        try
        {
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[0].Id, Name='Ontario', ISO_Code__c='CA-ON'));
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[0].Id, Name='ON', ISO_Code__c='ON'));
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[0].Id, Name='Quebec', ISO_Code__c='CA-QC'));
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[0].Id, Name='QC', ISO_Code__c='QC'));
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[3].Id, Name='Alaska', ISO_Code__c='US-AK'));
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[3].Id, Name='AK', ISO_Code__c='AK'));
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[3].Id, Name='California', ISO_Code__c='US-CA'));
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[3].Id, Name='CA', ISO_Code__c='CA'));
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[3].Id, Name='Florida', ISO_Code__c='US-FL'));
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[3].Id, Name='FL', ISO_Code__c='FL'));
            Database.upsert(listState, IATA_ISO_State__c.ISO_Code__c, false);
        }
        catch (Exception e) {}

        return IATAIsoCountryDAO.getIsoCountries();
    }


	public static List<AMS_Address__c> generateAMS_Addresses(Integer nb, Boolean doInsert)
	{
		List<AMS_Address__c> result = new List<AMS_Address__c>();

		List<Account> accounts = generateAccounts(nb,true);
		List<IATA_ISO_Country__c> countries = generateISOCountryState();

		List<String> adr_types = new List<String>{'Primary', 'Mailing', 'Registered'};

		for(Integer x=0; x<nb; x++)
		{
			result.add(new AMS_Address__c(Account__c = accounts[x].Id
				, Legacy_System__c = (Math.mod(x, 2)==0) ? 'Webstar' : 'AIMS'
				, Legacy_External_ID__c = 'AGT-12345'+x
				, Email__c = 'test_'+x+'@test.com'
				, Telephone_Int__c = (Math.mod(x, 2)==0) ? '1' : ''
				, Telephone_STD__c = (Math.mod(x, 2)==0) ? '514' : ''
				, Telephone__c = '90000'+x

				, Fax_Int__c = (Math.mod(x, 2)==0) ? '1' : ''
				, Fax_STD__c = (Math.mod(x, 2)==0) ? '514' : ''
				, Fax__c = '80000'+x

				, Address_1__c = '123 Street '+x
				, Address_2__c = 'Line 2'
				, City__c = 'Montreal'
				, State__c = countries[0].IATA_ISO_States__r[0].Id
				, Country__c = countries[0].Id
				, Address_Type__c = adr_types[Math.mod(x,adr_types.size())]
			));
		}

		if(doInsert)
			insert result;

		return result;
	}

	public static String generateRandomString(Integer len)
    {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';

        while (randStr.length() < len)
        {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }

        return randStr;
    }


	public static List<AMS_Account_Role__c> generateAMS_AccountRoles(Integer nb, Boolean doInsert)
	{

		List<AMS_Account_Role__c> result= new List<AMS_Account_Role__c>();
		List<Account> accounts = generateAccounts(nb,true);

		for(Integer x=0;x<nb;x++)
		{
			result.add(new AMS_Account_Role__c(
				RecordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership'),
				Account__c = accounts[x].Id,
				Owner_Name__c= 'Test Owner',
				Percentage__c= 10.25,
				Legacy_External_ID__c='1234567'+x
				));
		}

		if(doInsert)
			insert result;

		return result;
	}

	public static List<AMS_Agency_Airport__c> generateAMS_AgencyAirports(Integer nb, Boolean doInsert)
	{

		List<AMS_Agency_Airport__c> result= new List<AMS_Agency_Airport__c>();
		List<Account> accounts = generateAccounts(nb,true);
		List<AMS_Airport__c> airportcodes=generateAMS_Airports(nb,true);

		for(Integer x=0;x<nb;x++)
		{
			result.add(new AMS_Agency_Airport__c(
				Account__c = accounts[x].Id,
				Airport__c=airportcodes[x].Id
				));

		}

		if(doInsert)
			insert result;

		return result;
	}

	public static List<GDP_Reference_Table__c> generateReferenceTables(String table, String code, Integer nb, Boolean doInsert)
	{
		List<GDP_Reference_Table__c> result = new List<GDP_Reference_Table__c>();

		for(Integer x=0; x<nb; x++)
		{
			result.add(new GDP_Reference_Table__c(
				Name = 'Ref '+x
				, Code__c = code+x
				, Table__c = table
				, Definition__c = 'Ref '+x
			));
		}

		if(doInsert)
			insert result;

		return result;
	}
	public static List<AMS_Agency_Profile__c> generateAMS_AgencyProfiles(Integer nb, Boolean doInsert)
	{
		List<AMS_Agency_Profile__c> result= new List<AMS_Agency_Profile__c>();
		List<Account> accounts = generateAccounts(nb,true);
		//List<String> GRItems=new List<String>{'APENL2','APEN2C','APSALE','APEN4A','APEN4A','APSPEC','APDEST','APPRAC','APEN4H'};
		List<String> GRItems=new List<String>{'L1','L2','A1','4','AD','A2','C1','S1','RT','H1'};
		List<String> GRCodes=new List<String>{'FL','SL','SA','SV','MK','DS','FC','SS','AT','SH'};

		for(Integer x=0;x<nb;x++)
		{
			result.add(new AMS_Agency_Profile__c(
				Account__c = accounts[x].Id,
				GR_Item__c=GRItems[x],
				GR_Code__c=GRCodes[x]
				));

		}

		if(doInsert)
			insert result;

		return result;
	}

	public static List<Agency_Authorization__c> generateAMS_AgencyAuthorizations(Integer nb, Boolean doInsert)
	{
		List<Agency_Authorization__c> result= new List<Agency_Authorization__c>();
		List<Account> accounts = generateAccounts(nb,true);
		List<String> FormsOfPayment=new List<String>{'CA','CC','EP'};
		List<String> Statuses=new List<String>{'Active', 'Non-Active', 'Not Authorized'};

		for(Integer x=0;x<nb;x++)
		{
			for(Integer i = 0; i < FormsOfPayment.size(); i++) {
				result.add(new Agency_Authorization__c(
				Account__c = accounts[x].Id,
				ANG_FormOfPayment_ID__c=FormsOfPayment[i],
				Status__c=Statuses[i],
				RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'FormOfPayment')
				));
			}

		}

		if(doInsert)
			insert result;

		return result;
	}

	//-----------Generate GDP Object Data---------------------------

		public static List<GDP_Products_Account_View__c> generateGDPProductsView(Integer nb, Boolean doInsert)
	{
		List<Account> accounts = generateAccounts(nb,doInsert);
		List<GDP_Products_Account_View__c> gdpProducts= new List<GDP_Products_Account_View__c>();
        for(Integer i = 0; i < nb; i++)
        {
            gdpProducts.add(new GDP_Products_Account_View__c(
                Name = 'test gdp products ' + i ,
                AIMS_Id__c = (Math.mod(i, 2)==0) ? null : '1234'+i+ 'GDP',
				Webstar_Id__c=(Math.mod(i, 2)==0) ?'1234'+i+'GDP' :null
            ));
        }
        if(doInsert)
            insert gdpProducts;

        return gdpProducts;
	}
}