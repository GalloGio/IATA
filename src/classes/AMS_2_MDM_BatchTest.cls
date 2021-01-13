@isTest
private class AMS_2_MDM_BatchTest {

	static String localRegion = '';
	static SET<String> setAIMSRegion = new SET<String>();
	static List<IATA_ISO_Country__c> lIsoCountry;
	static List<AMS_ChangeCodes__c> lBillableChangeCodes;
	static String sQuery;

	@TestSetup
	private static void testSetup(){

			List<IATA_ISO_Country__c> countrylist = new List<IATA_ISO_Country__c>();
			IATA_ISO_Country__c isoc1 = new IATA_ISO_Country__c(Name = 'Test1', ISO_Code__c = 'TS', Region__c = 'Americas');
			IATA_ISO_Country__c isoc2 = new IATA_ISO_Country__c(Name = 'Test2', ISO_Code__c = 'LS', Region__c = 'Europe');
			IATA_ISO_Country__c isoc3 = new IATA_ISO_Country__c(Name = 'Test3', ISO_Code__c = 'PS', Region__c = 'China & North Asia');
			IATA_ISO_Country__c isoc4 = new IATA_ISO_Country__c(Name = 'Test4', ISO_Code__c = 'EE', Region__c = 'Europe');
			countrylist.add(isoc1);
			countrylist.add(isoc2);
			countrylist.add(isoc3);
			countrylist.add(isoc4);
			insert countrylist;



			List<Account> agencylist = new List<Account>();
			Account a1 = new Account(Name='Test1 Agency',IATA_ISO_Country__c = isoc1.id, Sent_to_external_system__c = true, IATACode__c = '12345677', Location_Class__c = 'P',RecordTypeId=AMS_Utils.RECTYPE_IATAAGENCY);
			Account a2 = new Account(Name='Test2 Agency',IATA_ISO_Country__c = isoc2.id, Sent_to_external_system__c = true, IATACode__c = '12345678', Location_Class__c = 'P',RecordTypeId=AMS_Utils.RECTYPE_IATAAGENCY);
			Account a3 = new Account(Name='Test3 Agency',IATA_ISO_Country__c = isoc3.id, Sent_to_external_system__c = true, IATACode__c = '12345679', Location_Class__c = 'P',RecordTypeId=AMS_Utils.RECTYPE_IATAAGENCY);
			Account a4 = new Account(Name='Test4 Agency',IATA_ISO_Country__c = isoc4.id, Sent_to_external_system__c = true, IATACode__c = '12345680', Location_Class__c = 'T',RecordTypeId=AMS_Utils.RECTYPE_IATAAGENCY);
			agencylist.add(a1);
			agencylist.add(a2);
			agencylist.add(a3);
			agencylist.add(a4);
			insert agencylist;

			AMS_ChangeCodes__c cc = new AMS_ChangeCodes__c(Name = 'test', Change_Code__c = 'TST', Billable__c = true, Integration_RecId__c='C', Billable_Location_Class__c = 'P');
			AMS_ChangeCodes__c cc4 = new AMS_ChangeCodes__c(Name = 'test2', Change_Code__c = 'TS2', Billable__c = true, Integration_RecId__c='C', Billable_Location_Class__c = 'T');
			insert new list<AMS_ChangeCodes__c>{cc,cc4};

			AMS_Change_Codes_Billable_Setup__c ccbs =  new AMS_Change_Codes_Billable_Setup__c(Name = 'TST', Change_Code__c = 'TST',
					Country_To_Exclude__c = 'TS', Location_Class_To_Exclude__c = 'P');
			insert ccbs;

			// create an oscar with a promotion
			AMS_OSCAR__c oscar4 = new AMS_OSCAR__c( Account__c = a4.Id, Promotions__c = 'TIDS_to_GoLite');
			insert oscar4;

			List<Agency_Applied_Change_code__c> aacclist = new List<Agency_Applied_Change_code__c>();
			Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Account__c = a1.Id, Change_Code__c = 'TST',  Sent_to_external_system__c = false);
			Agency_Applied_Change_code__c aacc2 = new Agency_Applied_Change_code__c(Account__c = a2.Id, Change_Code__c = 'TST',  Sent_to_external_system__c = false);
			Agency_Applied_Change_code__c aacc3 = new Agency_Applied_Change_code__c(Account__c = a3.Id, Change_Code__c = 'TST',  Sent_to_external_system__c = false);
			Agency_Applied_Change_code__c aacc4 = new Agency_Applied_Change_code__c(Account__c = a4.Id, Change_Code__c = 'TS2',  Sent_to_external_system__c = false, OSCAR__c = oscar4.Id);
			aacclist.add(aacc1);
			aacclist.add(aacc2);
			aacclist.add(aacc3);
			aacclist.add(aacc4);
			insert aacclist;
	}

	private static void test_config(String Region){
			setAIMSRegion = new SET<String>();

			if(Region.equalsIgnoreCase('AIMS1')){
				setAIMSRegion.add('Americas');
			}else if(Region.equalsIgnoreCase('AIMS2')){
				setAIMSRegion.add('Europe');
				setAIMSRegion.add('Africa & Middle East');
			}else if(Region.equalsIgnoreCase('AIMS3')){
				setAIMSRegion.add('China & North Asia');
				setAIMSRegion.add('Asia & Pacific');
			}

			lIsoCountry = [SELECT ID FROM IATA_ISO_Country__c WHERE Region__c in :setAIMSRegion];
			lBillableChangeCodes = [SELECT Change_Code__c FROM AMS_ChangeCodes__c where Billable__c = true];

			String[] tmp1 = New String[]{};
			String[] tmp1Country = New String[]{};
			String changeCodeString;
			String countryString;

			for(AMS_ChangeCodes__c c : lBillableChangeCodes){
				tmp1.add(c.Change_Code__c);
			}

			changeCodeString = string.join(tmp1,'\',\'');
			changeCodeString = '\'' + changeCodeString + '\'';


			//for(AggregateResult isoCountry : lIsoCountry){
			for(IATA_ISO_Country__c isoCountry : lIsoCountry){
				tmp1Country.add(isoCountry.id);
			}

			countryString = string.join(tmp1Country,'\',\'');
			countryString = '\'' + countryString + '\'';


			sQuery = 'SELECT Change_Code__c, Account__c, Account__r.IATACode__c, Account__r.Location_Class__c, ' +
												'Account__r.IATA_ISO_Country__r.IATA_Regional_Office__c, ' +
												'Account__r.IATA_ISO_Country__r.Iso_code__c, OSCAR__c, ' +
												'OSCAR__r.Promotions__c, ' +
												'Account__r.ANG_IsNewGenAgency__c ' +
										'FROM Agency_Applied_Change_code__c ' +
												'where Change_Code__c <> null ' +
												'and Account__r.IATACode__c <> null ' +
												'and Sent_to_external_system__c = false ' +
												'and Account__r.Sent_to_External_System__c = true ' +
												'and Change_Code__c in (' + changeCodeString + ') ' +
												'and Account__r.IATA_ISO_Country__c in (' + countryString + ') ' +
												'limit 8000' ;



	}


	static testmethod void test_area1() {

				test_config('AIMS1');

				Integer i1 = [SELECT COUNT() FROM Agency_Applied_Change_code__c
												where Change_Code__c <> null
												and Account__r.IATACode__c <> null
												and Sent_to_external_system__c = false
												and Account__r.Sent_to_External_System__c = true
												and Change_Code__c = 'TST'
												and Account__r.IATA_ISO_Country__r.name = 'Test1' ];
				System.assertEquals(i1, 1);

				Test.startTest();
				AMS_2_MDM_Batch c = new AMS_2_MDM_Batch(sQuery);
				Database.executeBatch(c);
				Test.stopTest();


				Integer i2 = [SELECT COUNT() FROM Agency_Applied_Change_code__c
												where Change_Code__c <> null
												and Account__r.IATACode__c <> null
												and Sent_to_external_system__c = false
												and Account__r.Sent_to_External_System__c = true
												and Change_Code__c = 'TST'
												and Account__r.IATA_ISO_Country__r.name = 'Test1' ];
				System.assertEquals(i2, 1);
	}

	static testmethod void test_area2() {

				test_config('AIMS2');

				Integer i1 = [SELECT COUNT() FROM Agency_Applied_Change_code__c
												where Change_Code__c <> null
												and Account__r.IATACode__c <> null
												and Sent_to_external_system__c = false
												and Account__r.Sent_to_External_System__c = true
												and Change_Code__c = 'TST'
												and Account__r.IATA_ISO_Country__r.name = 'Test2' ];
				System.assertEquals(i1, 1);

				Test.startTest();
				AMS_2_MDM_Batch c = new AMS_2_MDM_Batch(sQuery);
				Database.executeBatch(c);
				Test.stopTest();


				Integer i2 = [SELECT COUNT() FROM Agency_Applied_Change_code__c
												where Change_Code__c <> null
												and Account__r.IATACode__c <> null
												and Sent_to_external_system__c = false
												and Account__r.Sent_to_External_System__c = true
												and Change_Code__c = 'TST'
												and Account__r.IATA_ISO_Country__r.name = 'Test2' ];
				System.assertEquals(i2, 0);
	}

	static testmethod void test_area3() {

				test_config('AIMS3');

				Integer i1 = [SELECT COUNT() FROM Agency_Applied_Change_code__c
												where Change_Code__c <> null
												and Account__r.IATACode__c <> null
												and Sent_to_external_system__c = false
												and Account__r.Sent_to_External_System__c = true
												and Change_Code__c = 'TST'
												and Account__r.IATA_ISO_Country__r.name = 'Test3' ];
				System.assertEquals(i1, 1);

				Test.startTest();
				AMS_2_MDM_Batch c = new AMS_2_MDM_Batch(sQuery);
				Database.executeBatch(c);
				Test.stopTest();


				Integer i2 = [SELECT COUNT() FROM Agency_Applied_Change_code__c
												where Change_Code__c <> null
												and Account__r.IATACode__c <> null
												and Sent_to_external_system__c = false
												and Account__r.Sent_to_External_System__c = true
												and Change_Code__c = 'TST'
												and Account__r.IATA_ISO_Country__r.name = 'Test3' ];
				System.assertEquals(i2, 0);
	}


	static testmethod void test_area4() {

			test_config('AIMS2');

			Integer i1 = [SELECT COUNT() FROM Agency_Applied_Change_code__c
											where Change_Code__c <> null
											and Account__r.IATACode__c <> null
											and Sent_to_external_system__c = false
											and Account__r.Sent_to_External_System__c = true
											and Change_Code__c = 'TS2'
											and Account__r.IATA_ISO_Country__r.name = 'Test4' ];
			System.assertEquals(1, i1);

			Test.startTest();
			AMS_2_MDM_Batch c = new AMS_2_MDM_Batch(sQuery);
			Database.executeBatch(c);
			Test.stopTest();


			Integer i2 = [SELECT COUNT() FROM Agency_Applied_Change_code__c
											where Change_Code__c <> null
											and Account__r.IATACode__c <> null
											and Sent_to_external_system__c = false
											and Account__r.Sent_to_External_System__c = true
											and Change_Code__c = 'TS2'
											and Account__r.IATA_ISO_Country__r.name = 'Test4' ];
			System.assertEquals(1, i2);
	}
}
