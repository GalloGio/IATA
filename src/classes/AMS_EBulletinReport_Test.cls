@isTest
private class AMS_EBulletinReport_Test {
	
	/** 
	Setup data for EBulletin. It needs to Include:
	1. IATA ISO Countries
	2. Accounts to be added change codes
	3. Change Codes to be extracted
	4. Contact
	5. Portal User
	6. AMS EBulletin Profiles to be used (at least 2, 1 Daily and 1 Weekly)
	7. Custom Settings
	*/

	@testSetup static void dataSetupForEBulletin() {
		
		//EM: To be deleted
		AMS_EBulletinReportWebservice amsweb = new AMS_EBulletinReportWebservice();
		
		/**
		 1. Iso Countries
		*/
		List<IATA_ISO_Country__c> isoCountriesList = new List<IATA_ISO_Country__c>();


        IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy');
        isoCountriesList.add(italy);
        

        IATA_ISO_Country__c portugal = new IATA_ISO_Country__c(Name='Portugal', ISO_Code__c='PT', Region__c='Europe', ISS_Office_Location__c='Portugal');
        isoCountriesList.add(portugal);
        
        IATA_ISO_Country__c us = new IATA_ISO_Country__c(Name='United States', ISO_Code__c='US', Region__c='Americas', ISS_Office_Location__c='United States');
        isoCountriesList.add(us);        

        insert isoCountriesList;

		/**
		 1. Iso State
		*/
		List<IATA_ISO_State__c> isoStatesList = new List<IATA_ISO_State__c>();


        IATA_ISO_State__c alabama = new IATA_ISO_State__c(	IATA_ISO_Country__c = isoCountriesList.get(2).Id ,Name='Alabama', ISO_Code__c='	US-AL');
        isoStatesList.add(alabama);
        

        IATA_ISO_State__c alasca = new IATA_ISO_State__c(	IATA_ISO_Country__c = isoCountriesList.get(2).Id ,Name='Alaska', ISO_Code__c='US-AK');
        isoStatesList.add(alasca);
        

        insert isoStatesList;

		
		/**
		 2. Create Accounts
		*/
  		List<Account> acctList = new List<Account>();

        Boolean isPax = true;

		String SECTORPAX = 'Travel Agent';
        String CATEGORYPAX = 'IATA Passenger Sales Agent';
        String LOCCLASSPAX = 'P';

        String SECTORCASS = 'Cargo Agent';
        String CATEGORYCASS = 'IATA Cargo Sales Agent';
        String LOCCLASSCASS = 'C';

        String CHANGELOCATIONTYPE = 'Location type';
        String CHANGEOWNERSHIPIATA= 'Ownership to IATA Agent';
        String CHANGEOWNERSHIPNONIATA= 'Ownership to non-IATA Agent';
		ID rtAgency = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
       
      
        Account acc1 = new Account(RecordTypeId = rtAgency, Name = 'My Travels', IATAcode__c = '1111110', IATA_ISO_Country__c = us.id, 
                         Sector__c = (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), 
                         Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'HO', Status__c = 'Approved',
                         Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com'
                         );

        acctList.add(acc1);

        Account acc2 = new Account(RecordTypeId = rtAgency, Name = 'My Travels 2', IATAcode__c = '1111112', IATA_ISO_Country__c = italy.id, 
                         Sector__c = (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), 
                         Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'HO', Status__c = 'Approved',
                         Short_Name__c = 'Short name 2 ', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe4.com'
                         );
      
 		acctList.add(acc2);
        
		insert acctList;
		//Account Owners

        Id ownerRtId = AMS_Utils.getId('AMS_Account_Role__c', 'Ownership');
		
		List<AMS_Account_Role__c> ownersList = new List<AMS_Account_Role__c>();
        
		ownersList.add(new AMS_Account_Role__c(recordTypeId = ownerRtId, Account__c = acc1.Id, Person__c = null, Contact__c = null, Owner_Name__c='Diogo', Percentage__c=100.0,Legacy_External_ID__c = 'AIMS'));
 		ownersList.add(new AMS_Account_Role__c(recordTypeId = ownerRtId, Account__c = acc2.Id, Person__c = null, Contact__c = null, Owner_Name__c='Luis' , Percentage__c=60.0 , Legacy_External_ID__c = 'AIMS'));
		ownersList.add(new AMS_Account_Role__c(recordTypeId = ownerRtId, Account__c = acc2.Id, Person__c = null, Contact__c = null, Owner_Name__c='Duarte' , Percentage__c=40.0 , Legacy_External_ID__c = 'AIMS'));
		
		insert ownersList;


		/**
		 3. Change Codes Per Section
		 */

		List<Agency_Applied_Change_code__c> aaccSet = new List<Agency_Applied_Change_code__c>();

		//CHANGES IN PROGRESS
		 
		AMS_OSCAR_JSON.ChangeCode changeCode1 = new AMS_OSCAR_JSON.ChangeCode();
		AMS_OSCAR_JSON.ChangeCode changeCode2 = new AMS_OSCAR_JSON.ChangeCode();
		AMS_OSCAR_JSON.ChangeCode changeCode3 = new AMS_OSCAR_JSON.ChangeCode();
		AMS_OSCAR_JSON.ChangeCode changeCode4 = new AMS_OSCAR_JSON.ChangeCode();

		changeCode1.name = 'CTA';
		changeCode1.reasonCode = 'Change data';
		changeCode1.memoText = 'Minor Changes';//createMemoText(accountChanges);
		changeCode1.reasonDesc  = 'Accredited-Meets Criteria.';
		changeCode1.status  = null;

		AMS_ChangeCodesHelper.ObjectChange objChange1 = new AMS_ChangeCodesHelper.ObjectChange('Account','Name','new Value Name' ,'old Value Name' );
		AMS_ChangeCodesHelper.ObjectChange objChange2 = new AMS_ChangeCodesHelper.ObjectChange('Account','TradeName__c','new Trade Name' ,'Old Trade Name' );

		AMS_ChangeCodesHelper.ObjectChangesStruct objChangeListStruct1 = new AMS_ChangeCodesHelper.ObjectChangesStruct(new List <AMS_ChangeCodesHelper.ObjectChange>{objChange1,objChange2});

		changeCode2.name = 'CAD';
		changeCode2.reasonCode = 'Change data';
		changeCode2.memoText = 'Minor Changes';//createMemoText(accountChanges);
		changeCode2.reasonDesc  = 'Accredited-Meets Criteria.';
		changeCode2.status  = null;


		AMS_ChangeCodesHelper.ObjectChange objChange3 = new AMS_ChangeCodesHelper.ObjectChange('Account','Name','new Value Name' ,'old Value Name' );
		AMS_ChangeCodesHelper.ObjectChange objChange4 = new AMS_ChangeCodesHelper.ObjectChange('Account','Email__c','aa@aa.aa' ,'bb@bb.bb' );

		AMS_ChangeCodesHelper.ObjectChangesStruct objChangeListStruct2 = new AMS_ChangeCodesHelper.ObjectChangesStruct(new List <AMS_ChangeCodesHelper.ObjectChange>{objChange3,objChange4});


		changeCode3.name = 'CNL';
		changeCode3.reasonCode = 'Change in Progress';
		changeCode3.memoText = 'Change of Shareholding, Name and Location in process';//createMemoText(accountChanges);
		changeCode3.reasonDesc  = 'Change of Shareholding, Name and Location in process';
		changeCode3.status  = null;



		AMS_ChangeCodesHelper.ObjectChange objChange5 = new AMS_ChangeCodesHelper.ObjectChange('Account','Iso_State__c','Alabama','Alaska',isoStatesList.get(0).Id,isoStatesList.get(1).Id );
		AMS_ChangeCodesHelper.ObjectChange objChange6 = new AMS_ChangeCodesHelper.ObjectChange('Account','Owners','Name,Percentage\nAdrien Silva,60\nWilliam Carvalho,40','Name,Percentage\nRui Patricio,100' );

		AMS_ChangeCodesHelper.ObjectChangesStruct objChangeListStruct3 = new AMS_ChangeCodesHelper.ObjectChangesStruct(new List <AMS_ChangeCodesHelper.ObjectChange>{objChange5,objChange6});



		changeCode4.name = 'CHL';
		changeCode4.reasonCode = 'Change in Progress';
		changeCode4.memoText = 'Change of Location I process';//createMemoText(accountChanges);
		changeCode4.reasonDesc  = 'Change of Location I process';
		changeCode4.status  = null;

		AMS_ChangeCodesHelper.ObjectChange objChange7 = new AMS_ChangeCodesHelper.ObjectChange('Account','IATA_ISO_Country__c','Portugal','Italy',isoCountriesList.get(1).Id,isoCountriesList.get(0).Id);


		AMS_ChangeCodesHelper.ObjectChangesStruct objChangeListStruct4 = new AMS_ChangeCodesHelper.ObjectChangesStruct(new List <AMS_ChangeCodesHelper.ObjectChange>{objChange7});


		AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_ChangeCodesHelper.ObjectChangesStruct> {objChangeListStruct1,objChangeListStruct2,objChangeListStruct3,objChangeListStruct4},
		                                          new List <AMS_OSCAR_JSON.ChangeCode> {changeCode1,changeCode2,changeCode3,changeCode4},new List<AMS_OSCAR__c>{null,null,null,null}, 
		                                          new List<Account> {acc1,acc2,acc1,acc2}, 
		                                          false);
		//NEW APPROVALS

        Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Account__c = acc2.Id, Change_Code__c = 'NEW',  Sent_to_external_system__c = false);
        aaccSet.add(aacc1);

		//IRREGULARITIES
        
        Agency_Applied_Change_code__c irr = new Agency_Applied_Change_code__c(Account__c = acc1.Id, RecordTypeId = AMS_Utils.getId('Agency_Applied_Change_code__c', 'Irregularities'), Change_Code__c = 'IRR', Operation__c = 'A', Irregularities_Points__c = 1, Irregularities_Expired__c = false);
        aaccSet.add(irr);
		
		//REVIEWS/NOTICES OF TERM.
		
		//TERMINATIONS AND CLOSURES

        Agency_Applied_Change_code__c aacc2 = new Agency_Applied_Change_code__c(Account__c = acc2.Id, Change_Code__c = 'TER',  Sent_to_external_system__c = false);
        aaccSet.add(aacc2);

        Agency_Applied_Change_code__c aacc3 = new Agency_Applied_Change_code__c(Account__c = acc2.Id, Change_Code__c = 'CLO',  Sent_to_external_system__c = false);
        aaccSet.add(aacc3);
		
		insert aaccSet;



		List<Agency_Applied_Change_code__c> aaCCToEBulletin = new List<Agency_Applied_Change_code__c>();

		for(Agency_Applied_Change_code__c aacc : [select To_Publish_in_e_Bulletin__c from Agency_Applied_Change_code__c])
		{
			aacc.To_Publish_in_e_Bulletin__c = true;
			aaCCToEBulletin.add(aacc);
			
		}

		update aaCCToEBulletin;

		/**
		 4. Contact
		 */

		Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acctList.get(0).Id;
		con.Email = 'Test@test11.com';
		con.User_Portal_Status__c='Administrator';
        
        insert con;

        /**
		 5. Portal User
		 */

		 User newUser = ISSP_ObjectFactory.createPortalUser(con);
		 con.OwnerId = newUser.Id;
        update con;

		/**
		 6. AMS EBulletin Profiles
		 */
		
		setEBulletinProfiles();

		/**
		 7. Custom Settings
		 */

		createEBulletinCustomSettings();

	}

	@isTest static void test_DailyExtraction_All() {
		// Implement test code

		DateTime dT = System.now();
		DateTime fromDate = DateTime.newInstance(dT.year(), dT.month(), dT.day(), 0,0,0);

		User newUser = [SELECT Id FROM User WHERE Alias = 'dsfsdfds' LIMIT 1];

		AMS_eBulletin_Profile__c dailyProfile = 
						[ SELECT Agency_Info_Agency_Changes__c,Agency_Info_Defaults__c,Agency_Info_Irregularities__c,Agency_Info_New_Aplication_Processes__c,
                        Agency_Info_Reviews__c,Agency_Info_Termination_Closures__c,Area_1__c,Area_2__c,Area_3__c,CountriesList__c,CreatedDate,Daily_Frequency__c,
                        Id,LastModifiedDate,Name,Opt_out_Bulletin__c,Program_Cargo__c,Program_CASS_Associates__c,Program_Passage__c,Program_Domestic__c,Suspend_Subscription__c,
                        RecordTypeId,User__c, TimeZone__c,Opt_in__c,StatusDisplay__c,Last_Run__c,Agency_Info_Reinstatements__c
                    	 FROM AMS_eBulletin_Profile__c
                     	 WHERE User__c = :newUser.Id and RecordType.Name = 'Daily'
                    	LIMIT 1
                		];

		system.debug('dailyProfile: ' + dailyProfile);

        Test.startTest();

        //AMS_EBulletinReportWebservice.generateEBulletinReport(dailyProfile,fromDate, dT , '');

        Test.stopTest();

	}

	@isTest static void test_DailyExtraction_Last() {
		// Implement test code

		DateTime dT = System.now();
		DateTime fromDate = DateTime.newInstance(dT.year(), dT.month(), dT.day(), 0,0,0);

		User newUser = [SELECT Id FROM User WHERE Alias = 'dsfsdfds' LIMIT 1];
		
		AMS_eBulletin_Profile__c dailyProfile = 
						[ SELECT Agency_Info_Agency_Changes__c,Agency_Info_Defaults__c,Agency_Info_Irregularities__c,Agency_Info_New_Aplication_Processes__c,
                        Agency_Info_Reviews__c,Agency_Info_Termination_Closures__c,Area_1__c,Area_2__c,Area_3__c,CountriesList__c,CreatedDate,Daily_Frequency__c,
                        Id,LastModifiedDate,Name,Opt_out_Bulletin__c,Program_Cargo__c,Program_CASS_Associates__c,Program_Passage__c,Program_Domestic__c,Suspend_Subscription__c,
                        RecordTypeId,User__c, TimeZone__c,Opt_in__c,StatusDisplay__c,Last_Run__c,Agency_Info_Reinstatements__c
                    	 FROM AMS_eBulletin_Profile__c
                     	 WHERE User__c = :newUser.Id and  RecordType.Name = 'Daily'
                    	LIMIT 1
                		];

		system.debug('dailyProfile: ' + dailyProfile);

		
        Test.startTest();

        //AMS_EBulletinReportWebservice.generateEBulletinReport(dailyProfile,fromDate, dT , 'Last');

        Test.stopTest();

	}


	@isTest static void test_WeeklyExtraction() {
		// Implement test code
		DateTime dT = System.now();

		User newUser = [SELECT Id FROM User WHERE Alias = 'dsfsdfds' LIMIT 1];

        AMS_eBulletin_Profile__c weeklyProfile = 
						[ SELECT Agency_Info_Agency_Changes__c,Agency_Info_Defaults__c,Agency_Info_Irregularities__c,Agency_Info_New_Aplication_Processes__c,
                        Agency_Info_Reviews__c,Agency_Info_Termination_Closures__c,Area_1__c,Area_2__c,Area_3__c,CountriesList__c,CreatedDate,Daily_Frequency__c,
                        Id,LastModifiedDate,Name,Opt_out_Bulletin__c,Program_Cargo__c,Program_CASS_Associates__c,Program_Passage__c,Program_Domestic__c,Suspend_Subscription__c,
                        RecordTypeId,User__c, TimeZone__c,Opt_in__c,StatusDisplay__c,Last_Run__c,Agency_Info_Reinstatements__c
                    	 FROM AMS_eBulletin_Profile__c
                     	 WHERE User__c = :newUser.Id and RecordType.Name = 'Weekly'
                    	LIMIT 1
                		];

		system.debug('weeklyProfile: ' + weeklyProfile);

		System.runAs(newUser)
        {
			ISSP_AMS_EBulletin controller = new ISSP_AMS_EBulletin();
			controller.newFormWeekly = weeklyProfile;
			controller.pWeekStart = String.valueOf(dt.addDays(-5).format('dd/MM/yyyy'));
			controller.pWeekEnd = String.valueOf(dt.format('dd/MM/yyyy'));
			

	        AMS_EBulletinReportHelper.AMSEBulletinFilters filters = new AMS_EBulletinReportHelper.AMSEBulletinFilters(weeklyProfile, dt.addDays(-5), system.now());
	        //AMS_EBulletinReportHelper.getEBulletinFields(filters,'Agency_Applied_Change_code__c','","');
	        ISSP_AMS_EBulletin.filters = filters;
	        String header = ISSP_AMS_EBulletin.getHeader();
	        String query = ISSP_AMS_EBulletin.getQuery();
	        AMS_EBulletinReportHelper.eBulletinSettingsList = new List<AMS_CustomSettingsUtils.AMS_EBulletinSetting>();
			AMS_EBulletinReportHelper.headersList = new List<String>();

	    	Test.startTest();
	        AMS_EBulletinRecordsBatch batchRecords = new AMS_EBulletinRecordsBatch(header, query, weeklyProfile, dt, dt.addDays(-5), ISSP_AMS_EBulletin.ccNamesToRecoverAux, ISSP_AMS_EBulletin.countriesFilterAux, ISSP_AMS_EBulletin.locClsListAux, false);
	        Database.executeBatch(batchRecords, 50);
	        Test.stopTest();

	    }

	}

	@isTest static void test_NotificationsBatch_Daily() {
		
		Test.startTest();
		
		String sch1 = '0 0 6 ? * *';
		String sch2 = '0 30 20 ? * *';

		String jobID = system.schedule('AMS EBulletin Daily hours Test', sch1, new AMS_EBulletinDailySchedule());

		String job2ID = system.schedule('AMS EBulletin Daily half hours Test', sch2, new AMS_EBulletinDailySchedule());

		Test.stopTest();

	}

	@isTest static void test_NotificationsBatch_Weekly() {

		Test.startTest();

		String sch3 = '0 0 8 ? * MON';

		String jobID3 = system.schedule('AMS EBulletin Weekly Test', sch3, new AMS_EBulletinWeeklySchedule());

		Test.stopTest();

	}

	public static void setEBulletinProfiles(){

		List<AMS_eBulletin_Profile__c> eBulletinProfiles = new List <AMS_eBulletin_Profile__c>();
		User newUser = [SELECT Id FROM User WHERE Alias = 'dsfsdfds' LIMIT 1];

		eBulletinProfiles.add( 
			new AMS_eBulletin_Profile__c( RecordTypeId  	  		 		  		= Schema.SObjectType.AMS_eBulletin_Profile__c.RecordTypeInfosByName.get('Daily').RecordTypeId,
										  User__c       			 		  		= newUser.Id,
										  TimeZone__c		  		 		  		= UserInfo.getTimeZone().toString(),
										  Opt_in__c    		  		 		  		= true,
										  Opt_out_Bulletin__c		 		  		= false,
										  Program_CASS_Associates__c     	  		= true,
										  Program_Cargo__c 			 		  		= true,
										  Program_Domestic__c 		 		  		= true,
										  Program_Passage__c		 		  		= true,
										  Suspend_Subscription__c 	 		  		= false,
										  Area_1__c					 		  		= true,
										  Area_2__c						  	  		= true,
										  Area_3__c				 			  		= true,
										  Agency_Info_Termination_Closures__c 		= true,
										  Agency_Info_Reviews__c					= true,
										  Agency_Info_New_Aplication_Processes__c	= true,		
										  Agency_Info_Irregularities__c				= true,
										  Agency_Info_Defaults__c					= true,
										  Agency_Info_Agency_Changes__c				= true,
										  CountriesList__c							= 'IT;PT;US',
										  Last_Run__c = System.now().addHours(-5)
										)
			);

		eBulletinProfiles.add(  
			new AMS_eBulletin_Profile__c( RecordTypeId  							= Schema.SObjectType.AMS_eBulletin_Profile__c.RecordTypeInfosByName.get('Weekly').RecordTypeId,
										  User__c       			 		  		= newUser.Id,
										  TimeZone__c		  		 		  		= UserInfo.getTimeZone().toString(),
										  Opt_in__c    		  		 		  		= true,
										  Opt_out_Bulletin__c		 		  		= false,
										  Program_CASS_Associates__c     	  		= true,
										  Program_Cargo__c 			 		  		= true,
										  Program_Domestic__c 		 		  		= true,
										  Program_Passage__c		 		  		= true,
										  Suspend_Subscription__c 	 		  		= false,
										  Area_1__c					 		  		= true,
										  Area_2__c						  	  		= true,
										  Area_3__c				 			  		= true,
										  Agency_Info_Termination_Closures__c 		= true,
										  Agency_Info_Reviews__c					= true,
										  Agency_Info_New_Aplication_Processes__c	= true,		
										  Agency_Info_Irregularities__c				= true,
										  Agency_Info_Defaults__c					= true,
										  Agency_Info_Agency_Changes__c				= true,
										  CountriesList__c							= 'IT;PT;US'
										)
			);

		insert eBulletinProfiles;
	}


		/**
		 Create EBulletin Custom Settings
		 1.AMSEBulletinCCSections
		 2.AMSEBulletinCCExtration
		 3.	AMSEBulletinSettings
		*/
	

	public static void createEBulletinCustomSettings(){

		/**
		 1.AMSEBulletinCCSections
		*/
	
		List<AMSEBulletinCCSections__c> eBulletinCCSections = new List <AMSEBulletinCCSections__c>();

		eBulletinCCSections.add( new AMSEBulletinCCSections__c(NAME='NEW APPLICATIONS', AGENCY_INFORMATION__C='Agency_Info_New_Aplication_Processes__c', ORDER__C=1, TRACK_CC_HISTORY__C=FALSE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(NAME='NEW APPROVALS', AGENCY_INFORMATION__C='Agency_Info_New_Aplication_Processes__c', ORDER__C=2, TRACK_CC_HISTORY__C=FALSE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(NAME='NEW APPLICATIONS DISAPPROVED', AGENCY_INFORMATION__C='Agency_Info_New_Aplication_Processes__c', ORDER__C=3, TRACK_CC_HISTORY__C=FALSE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(NAME='CHANGES IN PROCESS', AGENCY_INFORMATION__C='Agency_Info_Agency_Changes__c', ORDER__C=4, TRACK_CC_HISTORY__C=TRUE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(NAME='CHANGES FINALISED', AGENCY_INFORMATION__C='Agency_Info_Agency_Changes__c', ORDER__C=5, TRACK_CC_HISTORY__C=FALSE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(NAME='CHANGE WITHDRAWN', AGENCY_INFORMATION__C='Agency_Info_Agency_Changes__c', ORDER__C=6, TRACK_CC_HISTORY__C=FALSE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(NAME='TERMINATIONS AND CLOSURES', AGENCY_INFORMATION__C='Agency_Info_Termination_Closures__c', ORDER__C=7, TRACK_CC_HISTORY__C=FALSE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(NAME='DEFAULT INFORMATION', AGENCY_INFORMATION__C='Agency_Info_Defaults__c', ORDER__C=8, TRACK_CC_HISTORY__C=FALSE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(NAME='REVIEWS/NOTICES OF TERM.', AGENCY_INFORMATION__C='Agency_Info_Reviews__c', ORDER__C=9, TRACK_CC_HISTORY__C=FALSE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(NAME='IRREGULARITIES', AGENCY_INFORMATION__C='Agency_Info_Irregularities__c', ORDER__C=10, TRACK_CC_HISTORY__C=FALSE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(NAME='REINSTATEMENTS', AGENCY_INFORMATION__C='Agency_Info_Reinstatements__c', ORDER__C=11, TRACK_CC_HISTORY__C=FALSE));


		insert eBulletinCCSections;

		/**
		 2.AMSEBulletinCCExtration
		*/

		List<AMSEBulletinCCExtration__c> eBulletinExtraction = new List <AMSEBulletinCCExtration__c>();


		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CAD', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Administrative Change'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CCL', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Shareholding and Location in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CCN', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Shareholding and Name in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CHC', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Shareholding in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CHH', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Hierarchy in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CHL', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Location in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CHN', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Name in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CHO', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CHS', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Legal Status in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CNM', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Name and Minor Shareholding in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CSC', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Legal Status and Shareholding in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CSM', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Legal Status and Minor Shareholding in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CSN', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Legal Status and Name in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='OSN', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership, Legal Status and Name in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='SCN', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Legal Status, Shareholding and Name in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='SNI', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Legal status, Name and Minor Shareholding in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CHV', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Province'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CDL', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Location Type to different Legal Entity in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CHA', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Accreditation Type in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='COH', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership and Hierarchy in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='PCN', DAILY__C=TRUE, SECTION__C='IRREGULARITIES AND ADMIN NONCOMPLIANCE', WEEKLY__C=TRUE, DESCRIPTION__C='PCI DSS Administrative Non-Compliance'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='PCA', DAILY__C=TRUE, SECTION__C='REVIEWS/NOTICES OF TERMINATION', WEEKLY__C=TRUE, DESCRIPTION__C='Removal of Cash Form of Payment'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CCA', DAILY__C=TRUE, SECTION__C='REVIEWS/NOTICES OF TERMINATION', WEEKLY__C=TRUE, DESCRIPTION__C='Removal of Credit Card Form of Payment'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='HLN', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Hierarchy, Legal Status and Name in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='HCF', DAILY__C=FALSE, SECTION__C='CHANGES FINALISED', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Hierarchy finalized'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='PCR', DAILY__C=TRUE, SECTION__C='REINSTATEMENTS', WEEKLY__C=TRUE, DESCRIPTION__C='Reinstatement of Cash Form of Payment'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CCR', DAILY__C=TRUE, SECTION__C='REINSTATEMENTS', WEEKLY__C=TRUE, DESCRIPTION__C='Reinstatement of Credit Card Form of Payment'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='BSP', DAILY__C=TRUE, SECTION__C='BSP/CASS REVIEW', WEEKLY__C=TRUE, DESCRIPTION__C='Agent cut-over into BSP in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CAS', DAILY__C=TRUE, SECTION__C='BSP/CASS REVIEW', WEEKLY__C=TRUE, DESCRIPTION__C='Agent cut-over into CASS in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='BSF', DAILY__C=TRUE, SECTION__C='BSP/CASS REVIEW', WEEKLY__C=TRUE, DESCRIPTION__C='Agent cut-over into BSP FINALIZED'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='HNP', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Hierarchy and Name'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='HLP', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Hierarchy and Legal Status'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CLM', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of  Location and Minor Shareholding in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CLR', DAILY__C=TRUE, SECTION__C='BSP/CASS REVIEW', WEEKLY__C=TRUE, DESCRIPTION__C='Change from BSP MAS to Regular BSP'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='DWD', DAILY__C=TRUE, SECTION__C='REINSTATEMENTS', WEEKLY__C=TRUE, DESCRIPTION__C='Default due to Accumulated Irregularities Withdrawn'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CHI', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership to IATA Agent'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CHM', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Name and Location in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='FPY', DAILY__C=TRUE, SECTION__C='IRREGULARITIES AND ADMIN NONCOMPLIANCE', WEEKLY__C=TRUE, DESCRIPTION__C='Full Payment Received'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='RRC', DAILY__C=FALSE, SECTION__C='', WEEKLY__C=FALSE, DESCRIPTION__C=''));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='RTE', DAILY__C=TRUE, SECTION__C='REINSTATEMENTS', WEEKLY__C=TRUE, DESCRIPTION__C='Reinstatement after Termination'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CNL', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Shareholding, Name and Location in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='COL', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership and Location in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='SCM', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Legal Status, Shareholding, Name and Location in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='HNL', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership to IATA Agent, Name and Location'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='HSL', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership to IATA Agent, Legal status and Location'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='HSM', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership to IATA Agent, Name and Location'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='IRR', DAILY__C=TRUE, SECTION__C='IRREGULARITIES AND ADMIN NONCOMPLIANCE', WEEKLY__C=TRUE, DESCRIPTION__C='Irregularities'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='LSP', DAILY__C=TRUE, SECTION__C='IRREGULARITIES AND ADMIN NONCOMPLIANCE', WEEKLY__C=TRUE, DESCRIPTION__C='Late/Short Payment'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='NFS', DAILY__C=TRUE, SECTION__C='IRREGULARITIES AND ADMIN NONCOMPLIANCE', WEEKLY__C=TRUE, DESCRIPTION__C='Failure to provide Financial Statements'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='LSW', DAILY__C=TRUE, SECTION__C='IRREGULARITIES AND ADMIN NONCOMPLIANCE', WEEKLY__C=TRUE, DESCRIPTION__C='Late/Short Payment Withdrawn'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='NCW', DAILY__C=TRUE, SECTION__C='IRREGULARITIES AND ADMIN NONCOMPLIANCE', WEEKLY__C=TRUE, DESCRIPTION__C='Administrative Non-Compliance Withdrawal'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='REW', DAILY__C=TRUE, SECTION__C='IRREGULARITIES AND ADMIN NONCOMPLIANCE', WEEKLY__C=TRUE, DESCRIPTION__C='Risk Event Withdrawal'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='WCP', DAILY__C=TRUE, SECTION__C='IRREGULARITIES AND ADMIN NONCOMPLIANCE', WEEKLY__C=TRUE, DESCRIPTION__C='Payment in Wrong Currency'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='RNC', DAILY__C=TRUE, SECTION__C='IRREGULARITIES AND ADMIN NONCOMPLIANCE', WEEKLY__C=TRUE, DESCRIPTION__C='Annual revalidation Administrative Non-Compliance'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='IAF', DAILY__C=TRUE, SECTION__C='IRREGULARITIES AND ADMIN NONCOMPLIANCE', WEEKLY__C=TRUE, DESCRIPTION__C='Annual Fee Administrative Non-compliance'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='AFN', DAILY__C=TRUE, SECTION__C='IRREGULARITIES AND ADMIN NONCOMPLIANCE', WEEKLY__C=TRUE, DESCRIPTION__C='Administrative fee Non-Compliance'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='DFE', DAILY__C=TRUE, SECTION__C='DEFAULT INFORMATION', WEEKLY__C=TRUE, DESCRIPTION__C='Default due to non-Payment'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='DFW', DAILY__C=TRUE, SECTION__C='REINSTATEMENTS', WEEKLY__C=TRUE, DESCRIPTION__C='Default due to non-Payment Withdrawn'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='RPY', DAILY__C=TRUE, SECTION__C='DEFAULT INFORMATION', WEEKLY__C=TRUE, DESCRIPTION__C='Agreement on Repayment'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='RCR', DAILY__C=TRUE, SECTION__C='REINSTATEMENTS', WEEKLY__C=TRUE, DESCRIPTION__C='Reinstatement after Default'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CLO', DAILY__C=TRUE, SECTION__C='TERMINATIONS AND CLOSURES', WEEKLY__C=TRUE, DESCRIPTION__C='Voluntary Relinquishment Finalized'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='REI', DAILY__C=TRUE, SECTION__C='REINSTATEMENTS', WEEKLY__C=TRUE, DESCRIPTION__C='Reinstatement after Termination'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='TER', DAILY__C=TRUE, SECTION__C='TERMINATIONS AND CLOSURES', WEEKLY__C=TRUE, DESCRIPTION__C='Termination'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='TRW', DAILY__C=TRUE, SECTION__C='TERMINATIONS AND CLOSURES', WEEKLY__C=TRUE, DESCRIPTION__C='Cancellation of Termination'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='VRR', DAILY__C=TRUE, SECTION__C='TERMINATIONS AND CLOSURES', WEEKLY__C=TRUE, DESCRIPTION__C='Voluntary Relinquishment Request'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='VRW', DAILY__C=TRUE, SECTION__C='TERMINATIONS AND CLOSURES', WEEKLY__C=TRUE, DESCRIPTION__C='Voluntary Relinquishment Request Withdrawn'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='NOT', DAILY__C=TRUE, SECTION__C='REVIEWS/NOTICES OF TERMINATION', WEEKLY__C=TRUE, DESCRIPTION__C='Notice of Termination/Disapproval of Change'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='FOP', DAILY__C=TRUE, SECTION__C='REVIEWS/NOTICES OF TERMINATION', WEEKLY__C=TRUE, DESCRIPTION__C='Removal of Cash and Credit Card Form of Payment'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='NTW', DAILY__C=TRUE, SECTION__C='REVIEWS/NOTICES OF TERMINATION', WEEKLY__C=TRUE, DESCRIPTION__C='Notice of Termination Withdrawal'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='RTR', DAILY__C=TRUE, SECTION__C='REINSTATEMENTS', WEEKLY__C=TRUE, DESCRIPTION__C='Reinstatement after NOT'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='RVW', DAILY__C=TRUE, SECTION__C='REVIEWS/NOTICES OF TERMINATION', WEEKLY__C=TRUE, DESCRIPTION__C='Review'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='RWD', DAILY__C=TRUE, SECTION__C='REVIEWS/NOTICES OF TERMINATION', WEEKLY__C=TRUE, DESCRIPTION__C='Review Withdrawn'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='SDR', DAILY__C=TRUE, SECTION__C='REINSTATEMENTS', WEEKLY__C=TRUE, DESCRIPTION__C='Reinstatement from Removal of STDs/RVW'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='SRM', DAILY__C=TRUE, SECTION__C='REVIEWS/NOTICES OF TERMINATION', WEEKLY__C=TRUE, DESCRIPTION__C='Withdrawal of STDs/e-Ticketing Authority'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='FPR', DAILY__C=TRUE, SECTION__C='REINSTATEMENTS', WEEKLY__C=TRUE, DESCRIPTION__C='Reinstatement of Cash and Credit Card Form of Payment'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='STR', DAILY__C=TRUE, SECTION__C='REVIEWS/NOTICES OF TERMINATION', WEEKLY__C=TRUE, DESCRIPTION__C='STDs/e-Ticketing Authority Restored'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='NEW', DAILY__C=FALSE, SECTION__C='NEW APPLICATIONS', WEEKLY__C=TRUE, DESCRIPTION__C='New Application in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='NWD', DAILY__C=FALSE, SECTION__C='NEW APPLICATIONS', WEEKLY__C=TRUE, DESCRIPTION__C='New Application Withdrawn'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='NAC', DAILY__C=FALSE, SECTION__C='NEW APPLICATIONS', WEEKLY__C=TRUE, DESCRIPTION__C='New Application Change'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='FIN', DAILY__C=FALSE, SECTION__C='NEW APPROVALS', WEEKLY__C=TRUE, DESCRIPTION__C='New Application Finalized'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='REC', DAILY__C=FALSE, SECTION__C='NEW APPROVALS', WEEKLY__C=TRUE, DESCRIPTION__C='New Application under Reconsideration'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='DIS', DAILY__C=FALSE, SECTION__C='NEW APPLICATIONS DISAPPROVED', WEEKLY__C=TRUE, DESCRIPTION__C='New Application Disapproved'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='TCN', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Hierarchy, Legal Status and Major Shareholding in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='TMA', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Hierarchy, Legal Status, Name and Minor Shareholding in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='TNI', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Hierarchy, Legal Status and Minor Shareholding in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='TNL', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Hierarchy and Minor Shareholding in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='TSM', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Hierarchy and Major Shareholding in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='UON', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership, Hierarchy and Name in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='UOS', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership, Hierarchy and Legal Status in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='USN', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership, Legal Status and Name in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CCF', DAILY__C=FALSE, SECTION__C='CHANGES FINALISED', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Shareholding finalized'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='COF', DAILY__C=FALSE, SECTION__C='CHANGES FINALISED', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership finalized'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CLF', DAILY__C=FALSE, SECTION__C='CHANGES FINALISED', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Location finalized'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CNF', DAILY__C=FALSE, SECTION__C='CHANGES FINALISED', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Name finalized'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CSF', DAILY__C=FALSE, SECTION__C='CHANGES FINALISED', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Legal Status finalized'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CTA', DAILY__C=FALSE, SECTION__C='CHANGES FINALISED', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Trade Name'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='MCF', DAILY__C=FALSE, SECTION__C='CHANGES FINALISED', WEEKLY__C=TRUE, DESCRIPTION__C='Multiple Changes finalized'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CDF', DAILY__C=FALSE, SECTION__C='CHANGES FINALISED', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Location Type to different Legal Entity finalized'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CAF', DAILY__C=FALSE, SECTION__C='CHANGES FINALISED', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Accreditation Type finalized'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CHF', DAILY__C=FALSE, SECTION__C='CHANGES FINALISED', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership finalized'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='MHF', DAILY__C=FALSE, SECTION__C='CHANGES FINALISED', WEEKLY__C=TRUE, DESCRIPTION__C='Multiple changes finalized'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='MCH', DAILY__C=FALSE, SECTION__C='CHANGES FINALISED', WEEKLY__C=TRUE, DESCRIPTION__C='Minor change of Shareholding finalized'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CWD', DAILY__C=FALSE, SECTION__C='CHANGE WITHDRAWN', WEEKLY__C=TRUE, DESCRIPTION__C='Change Withdrawn'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='SLI', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Legal status,  Location and Minor Shareholding'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='SML', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Legal Status, Minor Shareholding and Location in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='SMN', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Legal Status, Name, Location and Minor Shareholding in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='IRS', DAILY__C=TRUE, SECTION__C='IRREGULARITIES AND ADMIN NONCOMPLIANCE', WEEKLY__C=TRUE, DESCRIPTION__C='Irregularity and STDs/e-Ticketing Authority withdrawn'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='IRW', DAILY__C=TRUE, SECTION__C='IRREGULARITIES AND ADMIN NONCOMPLIANCE', WEEKLY__C=TRUE, DESCRIPTION__C='Irregularity Withdrawn'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='LRA', DAILY__C=TRUE, SECTION__C='BSP/CASS REVIEW', WEEKLY__C=TRUE, DESCRIPTION__C='Change from BSP MAS to Regular BSP - FINALIZED'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='LRD', DAILY__C=TRUE, SECTION__C='BSP/CASS REVIEW', WEEKLY__C=TRUE, DESCRIPTION__C='Change from BSP MAS to Regular BSP - DISAPPROVED'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='SNL', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Legal Status, Name and Location in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CIJ', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership to IATA Agent and Change of Location in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CJJ', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership or Branches by Another Party and Change of Location in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='OSM', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership, Legal Status, Name and Location in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='RCM', DAILY__C=TRUE, SECTION__C='REINSTATEMENTS', WEEKLY__C=TRUE, DESCRIPTION__C='Reinstatement of Commission'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='LRR', DAILY__C=TRUE, SECTION__C='BSP/CASS REVIEW', WEEKLY__C=TRUE, DESCRIPTION__C='Change from Regular BSP to BSP MAS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CLI', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Location with inspection in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='MEP', DAILY__C=TRUE, SECTION__C='', WEEKLY__C=TRUE, DESCRIPTION__C=''));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CSL', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Legal Status and Location in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='NLI', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of  Name, Location and Minor Shareholding'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='SCL', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Legal Status, Shareholding and Location in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='DEF', DAILY__C=TRUE, SECTION__C='DEFAULT INFORMATION', WEEKLY__C=TRUE, DESCRIPTION__C='Default due to Accumulated Irregularities'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='ONL', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership, Name and Location in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='OSL', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership, Legal Status and Location in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='CON', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership and Name in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='COS', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership and Legal Status in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='HIN', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership to IATA Agent and Name'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='HIS', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership to IATA Agent and Legal status'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='HNM', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Hierarchy, Name and Major Shareholding in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='HNR', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Hierarchy, Name and Minor Shareholding in progress'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='HSN', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Ownership to IATA Agent, Legal status and Name'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(NAME='TCL', DAILY__C=FALSE, SECTION__C='CHANGES IN PROCESS', WEEKLY__C=TRUE, DESCRIPTION__C='Change of Hierarchy, Legal Status, Name and Major Shareholding in progress'));


		insert eBulletinExtraction;


		/**
		 3.	AMSEBulletinSettings
		*/

		List<AMSEBulletinSettings__c> eBulletinSettings = new List <AMSEBulletinSettings__c>();

		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='39-Owner4', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Owner4', NUMBER_ORDER__C=38, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='40-Owner4 %', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Owner4 %', NUMBER_ORDER__C=39, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='41-Owner5', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Owner5', NUMBER_ORDER__C=40, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='42-Owner5 %', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Owner5 %', NUMBER_ORDER__C=41, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='43-Owner6', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Owner6', NUMBER_ORDER__C=42, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='44-Owner6 %', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Owner6 %', NUMBER_ORDER__C=43, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='45-Owner7', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Owner7', NUMBER_ORDER__C=44, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='46-Owner7 %', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Owner7 %', NUMBER_ORDER__C=45, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='47-Owner8', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Owner8', NUMBER_ORDER__C=46, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='48-Owner8 %', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Owner8 %', NUMBER_ORDER__C=47, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='49-Owners Total %', API_NAME__C='OwnersTotal', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Owners Total %', NUMBER_ORDER__C=48, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='50-New Agency Name', API_NAME__C='Account__r.Name', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Agency Name', NUMBER_ORDER__C=49, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='51-New Location Type', API_NAME__C='Account__r.Location_Type__c', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Location Type', NUMBER_ORDER__C=50, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='52-New Legal Status', API_NAME__C='Account__r.Company_Type__c', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Legal Status', NUMBER_ORDER__C=51, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='53-New Hierarchy', API_NAME__C='Account__r.Parent.IATACode__c', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Hierarchy', NUMBER_ORDER__C=52, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='54-New Trade Name', API_NAME__C='Account__r.TradeName__c', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Trade Name', NUMBER_ORDER__C=53, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='55-New Accreditation Type', API_NAME__C='Account__r.ANG_Accreditation_Model__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='New Accreditation Type', NUMBER_ORDER__C=54, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='56-New City', API_NAME__C='Account__r.BillingCity', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New City', NUMBER_ORDER__C=55, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='57-New Country or State', API_NAME__C='Account__r.IATA_ISO_Billing_State__r.name,Account__r.IATA_ISO_Billing_State__r.ISO_Code__c', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Country or State', NUMBER_ORDER__C=56, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='58-New Country or State', API_NAME__C='Account__r.IATA_ISO_Country__r.name,Account__r.IATA_ISO_Country__r.ISO_Code__c', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Country or State', NUMBER_ORDER__C=56, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=TRUE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='59-New Street', API_NAME__C='Account__r.BillingStreet', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Street', NUMBER_ORDER__C=57, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='60-New Zip Code', API_NAME__C='Account__r.BillingPostalCode', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Zip Code', NUMBER_ORDER__C=58, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='61-New Phone Number', API_NAME__C='Account__r.Phone', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Phone Number', NUMBER_ORDER__C=59, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='62-New Fax Number', API_NAME__C='Account__r.Fax', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Fax Number', NUMBER_ORDER__C=60, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='63-New Email', API_NAME__C='Account__r.Email__c', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Email', NUMBER_ORDER__C=61, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='64-New VAT Number 1', API_NAME__C='Account__r.VAT_Number__c', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New VAT Number 1', NUMBER_ORDER__C=62, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='65-New VAT Number 2', API_NAME__C='Account__r.VAT_Number_2__c', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New VAT Number 2', NUMBER_ORDER__C=63, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='66-New Owners', API_NAME__C='Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Owners', NUMBER_ORDER__C=64, WEEKLY__C=FALSE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='74-New Owner4 %', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Owner4 %', NUMBER_ORDER__C=72, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='75-New Owner5', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Owner5', NUMBER_ORDER__C=73, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='76-New Owner5 %', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Owner5 %', NUMBER_ORDER__C=74, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='77-New Owner6', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Owner6', NUMBER_ORDER__C=75, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='67-New Owner1', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Owner1', NUMBER_ORDER__C=65, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='68-New Owner1 %', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Owner1 %', NUMBER_ORDER__C=66, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='69-New Owner2', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Owner2', NUMBER_ORDER__C=67, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='70-New Owner2 %', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Owner2 %', NUMBER_ORDER__C=68, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='71-New Owner3', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Owner3', NUMBER_ORDER__C=69, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='72-New Owner3 %', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Owner3 %', NUMBER_ORDER__C=70, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='73-New Owner4', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Owner4', NUMBER_ORDER__C=71, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='78-New Owner6 %', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Owner6 %', NUMBER_ORDER__C=76, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='79-New Owner7', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Owner7', NUMBER_ORDER__C=77, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='80-New Owner7 %', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Owner7 %', NUMBER_ORDER__C=78, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='81-New Owner8', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Owner8', NUMBER_ORDER__C=79, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='82-New Owner8 %', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Owner8 %', NUMBER_ORDER__C=80, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='83-New Owners Total %', API_NAME__C='OwnersTotal', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='New Owners Total %', NUMBER_ORDER__C=81, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='84-IRR: Reason', API_NAME__C='Reason_Description__c', DAILY__C=TRUE, IRR_FIELD__C=TRUE, LABEL__C='IRR: Reason', NUMBER_ORDER__C=82, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='85-IRR: Period', API_NAME__C='Start_Date__c', DAILY__C=TRUE, IRR_FIELD__C=TRUE, LABEL__C='IRR: Period', NUMBER_ORDER__C=83, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='86-IRR: Period', API_NAME__C='End_Date__c', DAILY__C=TRUE, IRR_FIELD__C=TRUE, LABEL__C='IRR: Period', NUMBER_ORDER__C=83, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=TRUE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='87-IRR: Point', API_NAME__C='Irregularities_Points__c', DAILY__C=TRUE, IRR_FIELD__C=TRUE, LABEL__C='IRR: Point', NUMBER_ORDER__C=84, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='88-IRR: Accumulated Irregularities', API_NAME__C='Account__r.Accumulated_Irregularities__c', DAILY__C=TRUE, IRR_FIELD__C=TRUE, LABEL__C='IRR: Accumulated Irregularities', NUMBER_ORDER__C=85, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='30-Termination Date', API_NAME__C='Termination_Date__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Termination Date', NUMBER_ORDER__C=29, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='31-Irregularity Sequence', API_NAME__C='Irregularity_Sequence__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Irregularity Sequence', NUMBER_ORDER__C=30, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='32-Owners', API_NAME__C='Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Owners', NUMBER_ORDER__C=31, WEEKLY__C=FALSE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='33-Owner1', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Owner1', NUMBER_ORDER__C=32, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='34-Owner1 %', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Owner1 %', NUMBER_ORDER__C=33, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='35-Owner2', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Owner2', NUMBER_ORDER__C=34, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='36-Owner2 %', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Owner2 %', NUMBER_ORDER__C=35, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='37-Owner3', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Owner3', NUMBER_ORDER__C=36, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='38-Owner3 %', API_NAME__C='Account__r.Owners', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Owner3 %', NUMBER_ORDER__C=37, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='89-IRR: End of Grace Period Date', API_NAME__C='End_Of_Grace_Period_date__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='IRR: End of Grace Period Date', NUMBER_ORDER__C=86, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='0-Section', API_NAME__C='Section', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Section', NUMBER_ORDER__C=0, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='1-Change Code', API_NAME__C='Change_Code__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Change Code', NUMBER_ORDER__C=1, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='2-Agency Code', API_NAME__C='Account__r.IATACode__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Agency Code', NUMBER_ORDER__C=2, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='3-Agency Name', API_NAME__C='Account__r.Name', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Agency Name', NUMBER_ORDER__C=3, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='4-Location Type', API_NAME__C='Account__r.Location_Type__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Location Type', NUMBER_ORDER__C=4, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='5-Legal Status', API_NAME__C='Account__r.Company_Type__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Legal Status', NUMBER_ORDER__C=5, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='6-Accreditation Type', API_NAME__C='Account__r.ANG_Accreditation_Model__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Accreditation Type', NUMBER_ORDER__C=6, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='7-Forms of Payment', API_NAME__C='Forms_of_Payment__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Forms of Payment', NUMBER_ORDER__C=7, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='8-Risk Status', API_NAME__C='Account__r.ANG_RiskStatus__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Risk Status', NUMBER_ORDER__C=8, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='9-Program', API_NAME__C='Account__r.Location_Class__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Program', NUMBER_ORDER__C=9, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='10-Hierarchy', API_NAME__C='Account__r.Parent.IATACode__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Hierarchy HO', NUMBER_ORDER__C=10, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='11-Trade Name', API_NAME__C='Account__r.TradeName__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Trade Name', NUMBER_ORDER__C=11, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='12-City', API_NAME__C='Account__r.BillingCity', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='City', NUMBER_ORDER__C=12, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='13-Country or State', API_NAME__C='Account__r.Iso_State__r.name,Account__r.Iso_State__r.ISO_Code__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Country or State', NUMBER_ORDER__C=13, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='14-Country or State', API_NAME__C='Account__r.IATA_ISO_Country__r.name,Account__r.IATA_ISO_Country__r.ISO_Code__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Country or State', NUMBER_ORDER__C=13, WEEKLY__C=TRUE, DO_NOT_QUERY__C=TRUE, DO_NOT_SHOW__C=TRUE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='15-Street', API_NAME__C='Account__r.BillingStreet', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Street', NUMBER_ORDER__C=14, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='16-Zip Code', API_NAME__C='Account__r.BillingPostalCode', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Zip Code', NUMBER_ORDER__C=15, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='17-Phone Number', API_NAME__C='Account__r.Phone', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Phone Number', NUMBER_ORDER__C=16, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='18-Fax Number', API_NAME__C='Account__r.Fax', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Fax Number', NUMBER_ORDER__C=17, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='19-Email', API_NAME__C='Account__r.Email__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Email', NUMBER_ORDER__C=18, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='20-VAT Number 1', API_NAME__C='Account__r.VAT_Number__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='VAT Number 1', NUMBER_ORDER__C=19, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='21-VAT Number 2', API_NAME__C='Account__r.VAT_Number_2__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='VAT Number 2', NUMBER_ORDER__C=20, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='22-Status', API_NAME__C='AccountNewStatus__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Status', NUMBER_ORDER__C=21, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='23-Effective Date', API_NAME__C='Created_Date_eBulletin__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Effective Date', NUMBER_ORDER__C=22, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='24-User Date', API_NAME__C='CreatedDate_User__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='User Date', NUMBER_ORDER__C=23, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='25-Application Date', API_NAME__C='Created_Date_To_Show__c', DAILY__C=FALSE, IRR_FIELD__C=FALSE, LABEL__C='Application Date', NUMBER_ORDER__C=24, WEEKLY__C=FALSE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='26-Reason', API_NAME__C='Reason_Description__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Reason', NUMBER_ORDER__C=25, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='27-Remarks', API_NAME__C='Bulletin_Information__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Remarks', NUMBER_ORDER__C=26, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='28-Financial Security', API_NAME__C='Financial_Security__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Financial Security', NUMBER_ORDER__C=27, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(NAME='29-Outstanding Amount', API_NAME__C='Outstanding_Amount__c', DAILY__C=TRUE, IRR_FIELD__C=FALSE, LABEL__C='Outstanding Amount', NUMBER_ORDER__C=28, WEEKLY__C=TRUE, DO_NOT_QUERY__C=FALSE, DO_NOT_SHOW__C=FALSE, IS_FIELD_NEW__C=FALSE));


		insert eBulletinSettings;

		/**
		 4.	ISSP_CS__c
		*/

		List<ISSP_CS__c> isspCs = new List<ISSP_CS__c>();
		isspCs.add( new ISSP_CS__c(Name = 'eBulletin_UserGuide',Value__c = 'EBULLETIN-USERGUIDE-'));
        isspCs.add( new ISSP_CS__c(Name = 'eBulletin_StartDate',Value__c = '01/08/2015'));

        insert isspCs;

	}

    
}