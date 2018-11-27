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
		ID rtAgency = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
       
      
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

        Id ownerRtId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
		
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
        
        Agency_Applied_Change_code__c irr = new Agency_Applied_Change_code__c(Account__c = acc1.Id, 
        	RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Applied_Change_code__c', 'Irregularities'), Change_Code__c = 'IRR', Operation__c = 'A', Irregularities_Points__c = 1, Irregularities_Expired__c = false);
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
			new AMS_eBulletin_Profile__c( RecordTypeId  	  		 		  		= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_eBulletin_Profile__c', 'Daily'),
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
			new AMS_eBulletin_Profile__c( RecordTypeId  							= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_eBulletin_Profile__c', 'Weekly'),
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

        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='0-Section',Label__c='Section',API_Name__c='Section',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=0,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='1-Change Code',Label__c='Change Code',API_Name__c='Change_Code__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=1,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='2-Agency Code',Label__c='Agency Code',API_Name__c='Account__r.IATACode__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=2,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='3-Agency Name',Label__c='Agency Name',API_Name__c='Account__r.Name',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=3,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='4-Location Type',Label__c='Location Type',API_Name__c='Account__r.Location_Type__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=4,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='5-Legal Status',Label__c='Legal Status',API_Name__c='Account__r.Company_Type__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=5,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));    
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='6-Accreditation Type',Label__c='Accreditation Type',API_Name__c='Account__r.ANG_Accreditation_Model__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=6,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));      
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='7-Forms of Payment',Label__c='Forms of Payment',API_Name__c='Forms_of_Payment__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=7,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='8-Risk Status',Label__c='  Risk Status',API_Name__c='Account__r.ANG_RiskStatus__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=8,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='9-Cash Condition equal to FS',Label__c='Cash Condition equal to FS',API_Name__c='Account__r.ANG_CashCondition__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=9,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));       
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='10-Program',Label__c='Program',API_Name__c='Account__r.Location_Class__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=10,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='11-Hierarchy',Label__c='Hierarchy HO',API_Name__c='Account__r.Parent.IATACode__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=11,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='12-Trade Name',Label__c='Trade Name',API_Name__c='Account__r.TradeName__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=12,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='13-City',Label__c='City',API_Name__c='Account__r.BillingCity',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=13,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='14-Country or State',Label__c='Country or State',API_Name__c='Account__r.Iso_State__r.name,Account__r.Iso_State__r.ISO_Code__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=14,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='15-Country or State',Label__c='Country or State',API_Name__c='Account__r.IATA_ISO_Country__r.name,Account__r.IATA_ISO_Country__r.ISO_Code__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=14,do_not_show__c=TRUE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='16-Street',Label__c='Street',API_Name__c='Account__r.BillingStreet',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=15,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='17-Zip Code',Label__c='Zip Code',API_Name__c='Account__r.BillingPostalCode',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=16,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='18-Phone Number',Label__c='Phone Number',API_Name__c='Account__r.Phone',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=17,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='19-Fax Number',Label__c='Fax Number',API_Name__c='Account__r.Fax',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=18,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='20-Email',Label__c='Email',API_Name__c='Account__r.Email__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=19,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='21-VAT Number 1',Label__c='VAT Number 1',API_Name__c='Account__r.VAT_Number__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=20,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='22-VAT Number 2',Label__c='VAT Number 2',API_Name__c='Account__r.VAT_Number_2__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=21,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='23-Status',Label__c='Status',API_Name__c='AccountNewStatus__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=22,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='24-Effective Date',Label__c='User Date',API_Name__c='Created_Date_To_Show__c ',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=23,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));        
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='25-User Date',Label__c='Effective Date',API_Name__c='CreatedDate_User__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=24,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='26-Application Date',Label__c='Application Date',API_Name__c='Created_Date_To_Show__c ',Daily__c=FALSE,Weekly__c=FALSE,Number_Order__c=25,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='27-Reason',Label__c='Reason',API_Name__c='Reason_Description__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=26,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));       
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='28-Remarks',Label__c='Remarks',API_Name__c='Bulletin_Information__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=27,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='29-Financial Security',Label__c='Financial Security',API_Name__c='Financial_Security__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=28,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='30-Outstanding Amount',Label__c='Outstanding Amount',API_Name__c='Outstanding_Amount__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=29,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='31-Termination Date',Label__c='Termination Date',API_Name__c='Termination_Date__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=30,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='32-Irregularity Sequence',Label__c='Irregularity Sequence',API_Name__c='Irregularity_Sequence__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=31,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='33-Owners',Label__c='Owners',API_Name__c='Owners',Daily__c=FALSE,Weekly__c=FALSE,Number_Order__c=32,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='34-Owner1',Label__c='Owner1',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=33,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='35-Owner1 %',Label__c='Owner1 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=34,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='36-Owner2',Label__c='Owner2',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=35,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='37-Owner2 %',Label__c='Owner2 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=36,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='38-Owner3',Label__c='Owner3',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=37,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='39-Owner3 %',Label__c='Owner3 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=38,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='40-Owner4',Label__c='Owner4',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=39,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='41-Owner4 %',Label__c='Owner4 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=40,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='42-Owner5',Label__c='Owner5',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=41,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='43-Owner5 %',Label__c='Owner5 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=42,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='44-Owner6',Label__c='Owner6',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=43,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='45-Owner6 %',Label__c='Owner6 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=44,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='46-Owner7',Label__c='Owner7',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=45,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='47-Owner7 %',Label__c='Owner7 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=46,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='48-Owner8',Label__c='Owner8',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=47,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='49-Owner8 %',Label__c='Owner8 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=48,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='50-Owners Total %',Label__c='Owners Total %',API_Name__c='OwnersTotal',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=49,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='51-New Agency Name',Label__c='New Agency Name',API_Name__c='Account__r.Name',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=50,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='52-New Location Type',Label__c='New Location Type',API_Name__c='Account__r.Location_Type__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=51,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='53-New Legal Status',Label__c='New Legal Status',API_Name__c='Account__r.Company_Type__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=52,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='54-New Hierarchy',Label__c='New Hierarchy',API_Name__c='Account__r.Parent.IATACode__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=53,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='55-New Trade Name',Label__c='New Trade Name',API_Name__c='Account__r.TradeName__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=54,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='56-New Accreditation Type',Label__c='New Accreditation Type',API_Name__c='Account__r.ANG_Accreditation_Model__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=55,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='57-New City',Label__c='New City',API_Name__c='Account__r.BillingCity',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=56,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='58-New Country or State',Label__c='New Country or State',API_Name__c='Account__r.IATA_ISO_Billing_State__r.name,Account__r.IATA_ISO_Billing_State__r.ISO_Code__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=57,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='59-New Country or State',Label__c='New Country or State',API_Name__c='Account__r.IATA_ISO_Country__r.name,Account__r.IATA_ISO_Country__r.ISO_Code__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=57,do_not_show__c=TRUE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='60-New Street',Label__c='New Street',API_Name__c='Account__r.BillingStreet',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=58,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='61-New Zip Code',Label__c='New Zip Code',API_Name__c='Account__r.BillingPostalCode',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=59,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='62-New Phone Number',Label__c='New Phone Number',API_Name__c='Account__r.Phone',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=60,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='63-New Fax Number',Label__c='New Fax Number',API_Name__c='Account__r.Fax',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=61,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='64-New Email',Label__c='New Email',API_Name__c='Account__r.Email__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=62,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='65-New VAT Number 1',Label__c='New VAT Number 1',API_Name__c='Account__r.VAT_Number__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=63,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='66-New VAT Number 2',Label__c='New VAT Number 2',API_Name__c='Account__r.VAT_Number_2__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=64,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='67-New Owners',Label__c='New Owners',API_Name__c='Owners',Daily__c=FALSE,Weekly__c=FALSE,Number_Order__c=65,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='68-New Owner1',Label__c='New Owner1',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=66,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='69-New Owner1 %',Label__c='New Owner1 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=67,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='70-New Owner2',Label__c='New Owner2',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=68,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='71-New Owner2 %',Label__c='New Owner2 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=69,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='72-New Owner3',Label__c='New Owner3',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=70,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='73-New Owner3 %',Label__c='New Owner3 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=71,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='74-New Owner4',Label__c='New Owner4',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=72,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='75-New Owner4 %',Label__c='New Owner4 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=73,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='76-New Owner5',Label__c='New Owner5',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=74,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='77-New Owner5 %',Label__c='New Owner5 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=75,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='78-New Owner6',Label__c='New Owner6',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=76,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='79-New Owner6 %',Label__c='New Owner6 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=77,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='80-New Owner7',Label__c='New Owner7',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=78,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='81-New Owner7 %',Label__c='New Owner7 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=79,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='82-New Owner8',Label__c='New Owner8',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=80,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='83-New Owner8 %',Label__c='New Owner8 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=81,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='84-New Owners Total %',Label__c='New Owners Total %',API_Name__c='OwnersTotal',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=82,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='85-IRR: Reason',Label__c='IRR: Reason',API_Name__c='Reason_Description__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=83,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=TRUE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='86-IRR: Period',Label__c='IRR: Period',API_Name__c='Start_Date__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=84,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=TRUE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='87-IRR: Period',Label__c='IRR: Period',API_Name__c='End_Date__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=84,do_not_show__c=TRUE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=TRUE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='88-IRR: Point',Label__c='IRR: Point',API_Name__c='Irregularities_Points__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=85,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=TRUE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='89-IRR: Accumulated Irregularities',Label__c='IRR: Accumulated Irregularities',API_Name__c='Account__r.Accumulated_Irregularities__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=86,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=TRUE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='90-IRR: End of Grace Period Date',Label__c='IRR: End of Grace Period Date',API_Name__c=' End_Of_Grace_Period_date__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=87,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=TRUE));

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