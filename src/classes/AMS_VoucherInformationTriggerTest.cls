@isTest
private class AMS_VoucherInformationTriggerTest {
	
	@testSetup static void setup(){
    
        ID rtAgency = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        
        IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy');
        insert italy;

        Account HO1 = new Account(RecordTypeId = rtAgency, Name = 'My Travels', IATA_ISO_Country__c = italy.id, Location_type__c = 'HO', Location_Class__c = 'C');
       
        insert HO1;

		Account HO2 = new Account(RecordTypeId = rtAgency, Name = 'My Travels2', IATA_ISO_Country__c = italy.id, Location_type__c = 'HO' , Location_Class__c = 'C');
       
        insert HO2;

    }

	@isTest static void testInsertUpdateVoucherInfo() {

		Test.startTest();

		List<Account> accounts = [SELECT id, Location_type__c, Location_Class__c from Account];

		Account acct1 = accounts.get(0);
		Account acct2 = accounts.get(1);

		AMS_Voucher_Information__c voucher1 = new AMS_Voucher_Information__c(Account__c = acct1.Id , Amount_Currency__c = 'USD' ,AmountLastYearSales__c = 100000 , Exchange_Rate__c = 1, Year__c = '2016' );
		AMS_Voucher_Information__c voucher2 = new AMS_Voucher_Information__c(Account__c = acct2.Id , Amount_Currency__c = 'USD' ,AmountLastYearSales__c = 100000 , Exchange_Rate__c = 1, Year__c = '2016' );

		insert new List<AMS_Voucher_Information__c>{voucher1,voucher2};

		voucher2.Year__c = '2015';

		update voucher2;

		Test.stopTest();
	}
	

	@isTest static void testInsertTwoVoucherInfo() {

		Test.startTest();

		List<Account> accounts = [SELECT id, Location_type__c,Location_Class__c from Account];

		Account acct1 = accounts.get(0);

		AMS_Voucher_Information__c voucher1 = new AMS_Voucher_Information__c(Account__c = acct1.Id , Amount_Currency__c = 'USD' ,AmountLastYearSales__c = 100000 , Exchange_Rate__c = 1 , Year__c = '2016' );
		
		insert voucher1;

		AMS_Voucher_Information__c voucher2 = new AMS_Voucher_Information__c(Account__c = acct1.Id , Amount_Currency__c = 'USD' ,AmountLastYearSales__c = 100000 , Exchange_Rate__c = 1 , Year__c = '2016' );

		try{
			insert voucher2;

			System.assertEquals(true,false);
		
		}catch(Exception e){
			System.assertEquals(true ,e.getMessage().contains('There is already 1 Voucher Information Attached to the Account ' + acct1.Id));
		}

		Test.stopTest();
	}

	@isTest static void testInsertTwoVoucherInfoDiffYyears() {

		Test.startTest();

		List<Account> accounts = [SELECT id, Location_type__c,Location_Class__c from Account];

		Account acct1 = accounts.get(0);

		AMS_Voucher_Information__c voucher1 = new AMS_Voucher_Information__c(Account__c = acct1.Id , Amount_Currency__c = 'USD' ,AmountLastYearSales__c = 100000 , Exchange_Rate__c = 1, Year__c = '2016' );
		
		insert voucher1;

		AMS_Voucher_Information__c voucher2 = new AMS_Voucher_Information__c(Account__c = acct1.Id , Amount_Currency__c = 'USD' ,AmountLastYearSales__c = 100000 , Exchange_Rate__c = 1, Year__c = '2017' );

		insert voucher2;

		Test.stopTest();
		
	}

	@isTest static void testUndeleteVoucherInfoNOK() {

		Test.startTest();

		List<Account> accounts = [SELECT id, Location_type__c,Location_Class__c from Account];

		Account acct1 = accounts.get(0);

		AMS_Voucher_Information__c voucher1 = new AMS_Voucher_Information__c(Account__c = acct1.Id , Amount_Currency__c = 'USD' ,AmountLastYearSales__c = 100000 ,Exchange_Rate__c = 1, Year__c = '2016' );
		
		insert voucher1;


		delete voucher1;

		AMS_Voucher_Information__c voucher2 = new AMS_Voucher_Information__c(Account__c = acct1.Id , Amount_Currency__c = 'USD' ,AmountLastYearSales__c = 100000 ,Exchange_Rate__c = 1, Year__c = '2016' );

		insert voucher2;


		try{
			undelete voucher1;
		
			System.assertEquals(true,false);
		
		}catch(Exception e){
			System.assertEquals(true ,e.getMessage().contains('There is already 1 Voucher Information Attached to the Account ' + acct1.Id));
		}

		Test.stopTest();
	}

	@isTest static void testUndeleteVoucherInfoOK() {

		Test.startTest();

		List<Account> accounts = [SELECT id, Location_type__c,Location_Class__c from Account];

		Account acct1 = accounts.get(0);

		AMS_Voucher_Information__c voucher1 = new AMS_Voucher_Information__c(Account__c = acct1.Id , Amount_Currency__c = 'USD' ,AmountLastYearSales__c = 100000 , Exchange_Rate__c = 1 , Year__c = '2016' );
		
		insert voucher1;


		delete voucher1;

		AMS_Voucher_Information__c voucher2 = new AMS_Voucher_Information__c(Account__c = acct1.Id , Amount_Currency__c = 'USD' ,AmountLastYearSales__c = 100000 , Exchange_Rate__c = 1 , Year__c = '2016' );

		insert voucher2;

		delete voucher2;

		undelete voucher1;

		Test.stopTest();
		
	}

/*
	@isTest static void testCalculateLastYearVouchersSingle() {

		Test.startTest();

		List<Account> accounts1 = [SELECT id, Location_type__c from Account where Name = 'My Travels'];
		List<Account> accounts2 = [SELECT id, Location_type__c from Account where Name = 'My Travels2'];

		Account acct1 = accounts1.get(0);
		Account acct2 = accounts2.get(0);

		AMS_Voucher_Information__c voucherInfo1 = new AMS_Voucher_Information__c(Account__c = acct1.Id , Amount_Currency__c = 'USD' ,AmountLastYearSales__c = 100000 , Year__c = '2015' );
		AMS_Voucher_Information__c voucherInfo2 = new AMS_Voucher_Information__c(Account__c = acct2.Id , Amount_Currency__c = 'USD' ,AmountLastYearSales__c = 100000 , Year__c = '2015' );
		
		insert new List<AMS_Voucher_Information__c>{voucherInfo1,voucherInfo2};

		List<AMS_Voucher_Information__c> vouchersInfoLst = [SELECT Id, Vouchers_Issued_Last_Year__c, Number_Of_Vouchers__c from AMS_Voucher_Information__c where Account__c = :acct1.Id];
		List<AMS_Voucher_Information__c> vouchersInfoLst2 = [SELECT Id, Vouchers_Issued_Last_Year__c, Number_Of_Vouchers__c from AMS_Voucher_Information__c where Account__c = :acct2.Id];

		System.assertEquals(0,vouchersInfoLst.get(0).Vouchers_Issued_Last_Year__c);
		System.assertEquals(0,vouchersInfoLst2.get(0).Vouchers_Issued_Last_Year__c);

		AMS_Voucher__c voucher1 = new AMS_Voucher__c(Voucher_Information__c = vouchersInfoLst.get(0).Id);
		AMS_Voucher__c voucher2 = new AMS_Voucher__c(Voucher_Information__c = vouchersInfoLst.get(0).Id);
		AMS_Voucher__c voucher3 = new AMS_Voucher__c(Voucher_Information__c = vouchersInfoLst.get(0).Id);

		AMS_Voucher__c voucher4 = new AMS_Voucher__c(Voucher_Information__c = vouchersInfoLst2.get(0).Id);
		AMS_Voucher__c voucher5 = new AMS_Voucher__c(Voucher_Information__c = vouchersInfoLst2.get(0).Id);
		AMS_Voucher__c voucher6 = new AMS_Voucher__c(Voucher_Information__c = vouchersInfoLst2.get(0).Id);
		AMS_Voucher__c voucher7 = new AMS_Voucher__c(Voucher_Information__c = vouchersInfoLst2.get(0).Id);

		insert new List<AMS_Voucher__c>{voucher1,voucher2,voucher3,voucher4,voucher5,voucher6,voucher7};

		vouchersInfoLst  = [SELECT Id, Vouchers_Issued_Last_Year__c, Number_Of_Vouchers__c from AMS_Voucher_Information__c where Account__c = :acct1.Id];

		System.assertEquals(3,vouchersInfoLst.get(0).Number_Of_Vouchers__c);

		vouchersInfoLst2  = [SELECT Id, Vouchers_Issued_Last_Year__c, Number_Of_Vouchers__c from AMS_Voucher_Information__c where Account__c = :acct2.Id];

		System.assertEquals(4,vouchersInfoLst2.get(0).Number_Of_Vouchers__c);

		AMS_Voucher_Information__c voucherInfo3 = new AMS_Voucher_Information__c(Account__c = acct1.Id , Amount_Currency__c = 'USD' ,AmountLastYearSales__c = 100000 , Year__c = '2016' );
		AMS_Voucher_Information__c voucherInfo4 = new AMS_Voucher_Information__c(Account__c = acct2.Id , Amount_Currency__c = 'USD' ,AmountLastYearSales__c = 100000 , Year__c = '2016' );

		insert new List<AMS_Voucher_Information__c>{voucherInfo3,voucherInfo4};

		vouchersInfoLst = [SELECT Id, Vouchers_Issued_Last_Year__c from AMS_Voucher_Information__c where Year__c = '2016' and Account__c = :acct1.Id];

		System.assertEquals(3,vouchersInfoLst.get(0).Vouchers_Issued_Last_Year__c);
		
		vouchersInfoLst = [SELECT Id, Vouchers_Issued_Last_Year__c from AMS_Voucher_Information__c where Year__c = '2016' and Account__c = :acct2.Id];

		System.assertEquals(4,vouchersInfoLst.get(0).Vouchers_Issued_Last_Year__c);

		Test.stopTest();
	}
	*/
}