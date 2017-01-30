@isTest
private class AMS_EBulletinReport_Test {
	
	/** 
	Setup data for EBulletin. It needs to Include:
	1. IATA ISO Countries
	2. Accounts to be added change codes
	3. Change Codes to be extracted
	4. AMS EBulletin Profiles to be used (at least 2, 1 Daily and 1 Weekly)
	*/

	@testSetup static void dataSetupForEBulletin() {
		
		/**
		 1. Iso Countries
		*/
		List<IATA_ISO_Country__c> isoCountriesSet = new List<IATA_ISO_Country__c>();


        IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy');
        isoCountriesSet.add(italy);
        

        IATA_ISO_Country__c portugal = new IATA_ISO_Country__c(Name='Portugal', ISO_Code__c='PT', Region__c='Europe', ISS_Office_Location__c='Portugal');
        isoCountriesSet.add(portugal);
        
        IATA_ISO_Country__c us = new IATA_ISO_Country__c(Name='United States', ISO_Code__c='US', Region__c='Americas', ISS_Office_Location__c='United States');
        isoCountriesSet.add(us);

        insert isoCountriesSet;
		
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

		changeCode1.name = 'CTA';
		changeCode1.reasonCode = 'Change data';
		changeCode1.memoText = 'Minor Changes';//createMemoText(accountChanges);
		changeCode1.reasonDesc  = 'Accredited-Meets Criteria.';
		changeCode1.status  = null;

		changeCode2.name = 'CAD';
		changeCode2.reasonCode = 'Change data';
		changeCode2.memoText = 'Minor Changes';//createMemoText(accountChanges);
		changeCode2.reasonDesc  = 'Accredited-Meets Criteria.';
		changeCode2.status  = null;

		AMS_ChangeCodesHelper.ObjectChange objChange1 = new AMS_ChangeCodesHelper.ObjectChange('Account','Name','new Value Name' ,'old Value Name' );
		AMS_ChangeCodesHelper.ObjectChange objChange2 = new AMS_ChangeCodesHelper.ObjectChange('Case','Name','new Value Name Case','old Value Name Case' );

		AMS_ChangeCodesHelper.ObjectChange objChange3 = new AMS_ChangeCodesHelper.ObjectChange('Account','Name2','new Value Name 2' ,'old Value Name 2' );
		AMS_ChangeCodesHelper.ObjectChange objChange4 = new AMS_ChangeCodesHelper.ObjectChange('Case','Name2','new Value Name Case 2','old Value Name Case 2' );

		List <AMS_ChangeCodesHelper.ObjectChange> objChangeList = new List <AMS_ChangeCodesHelper.ObjectChange>{objChange1,objChange2};

		AMS_ChangeCodesHelper.ObjectChangesStruct objChangeListStruct1 = new AMS_ChangeCodesHelper.ObjectChangesStruct(new List <AMS_ChangeCodesHelper.ObjectChange>{objChange1,objChange2});
		AMS_ChangeCodesHelper.ObjectChangesStruct objChangeListStruct2 = new AMS_ChangeCodesHelper.ObjectChangesStruct(new List <AMS_ChangeCodesHelper.ObjectChange>{objChange3,objChange4});


		AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_ChangeCodesHelper.ObjectChangesStruct> {objChangeListStruct1,objChangeListStruct2},
		                                          new List <AMS_OSCAR_JSON.ChangeCode> {changeCode1,changeCode2},new List<AMS_OSCAR__c>{null,null}, 
		                                          new List<Account> {acc1,acc2}, 
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
		 4. AMS EBulletin Profiles
		 */
		
		setEBulletinProfiles();

		/**
		 5. Custom Settings
		 */

		createEBulletinCustomSettings();

	}

	@isTest static void test_DailyExtraction_All() {
		// Implement test code

		DateTime dT = System.now();
		DateTime fromDate = DateTime.newInstance(dT.year(), dT.month(), dT.day(), 0,0,0);

		AMS_eBulletin_Profile__c dailyProfile = 
						[ SELECT Agency_Info_Agency_Changes__c,Agency_Info_Defaults__c,Agency_Info_Irregularities__c,Agency_Info_New_Aplication_Processes__c,
                        Agency_Info_Reviews__c,Agency_Info_Termination_Closures__c,Area_1__c,Area_2__c,Area_3__c,CountriesList__c,CreatedDate,Daily_Frequency__c,
                        Id,LastModifiedDate,Name,Opt_out_Bulletin__c,Program_Cargo__c,Program_CASS_Associates__c,Program_Passage__c,Program_Domestic__c,Suspend_Subscription__c,
                        RecordTypeId,User__c, TimeZone__c,Opt_in__c,StatusDisplay__c,Last_Run__c
                    	 FROM AMS_eBulletin_Profile__c
                     	 WHERE User__c = :Userinfo.getuserid() and RecordType.Name = 'Daily'
                    	LIMIT 1
                		];

		system.debug('dailyProfile: ' + dailyProfile);

        Test.startTest();

        AMS_EBulletinReportWebservice.generateEBulletinReport(dailyProfile,fromDate, dT , '');

        Test.stopTest();

	}

	@isTest static void test_DailyExtraction_Last() {
		// Implement test code

		DateTime dT = System.now();
		DateTime fromDate = DateTime.newInstance(dT.year(), dT.month(), dT.day(), 0,0,0);
		
		AMS_eBulletin_Profile__c dailyProfile = 
						[ SELECT Agency_Info_Agency_Changes__c,Agency_Info_Defaults__c,Agency_Info_Irregularities__c,Agency_Info_New_Aplication_Processes__c,
                        Agency_Info_Reviews__c,Agency_Info_Termination_Closures__c,Area_1__c,Area_2__c,Area_3__c,CountriesList__c,CreatedDate,Daily_Frequency__c,
                        Id,LastModifiedDate,Name,Opt_out_Bulletin__c,Program_Cargo__c,Program_CASS_Associates__c,Program_Passage__c,Program_Domestic__c,Suspend_Subscription__c,
                        RecordTypeId,User__c, TimeZone__c,Opt_in__c,StatusDisplay__c,Last_Run__c
                    	 FROM AMS_eBulletin_Profile__c
                     	 WHERE User__c = :Userinfo.getuserid() and  RecordType.Name = 'Daily'
                    	LIMIT 1
                		];

		system.debug('dailyProfile: ' + dailyProfile);

		
        Test.startTest();

        AMS_EBulletinReportWebservice.generateEBulletinReport(dailyProfile,fromDate, dT , 'Last');

        Test.stopTest();

	}


	@isTest static void test_WeeklyExtraction() {
		// Implement test code
		DateTime dT = System.now();
        Test.startTest();

        AMS_eBulletin_Profile__c weeklyProfile = 
						[ SELECT Agency_Info_Agency_Changes__c,Agency_Info_Defaults__c,Agency_Info_Irregularities__c,Agency_Info_New_Aplication_Processes__c,
                        Agency_Info_Reviews__c,Agency_Info_Termination_Closures__c,Area_1__c,Area_2__c,Area_3__c,CountriesList__c,CreatedDate,Daily_Frequency__c,
                        Id,LastModifiedDate,Name,Opt_out_Bulletin__c,Program_Cargo__c,Program_CASS_Associates__c,Program_Passage__c,Program_Domestic__c,Suspend_Subscription__c,
                        RecordTypeId,User__c, TimeZone__c,Opt_in__c,StatusDisplay__c,Last_Run__c
                    	 FROM AMS_eBulletin_Profile__c
                     	 WHERE User__c = :Userinfo.getuserid() and RecordType.Name = 'Weekly'
                    	LIMIT 1
                		];

		system.debug('weeklyProfile: ' + weeklyProfile);

        AMS_EBulletinReportWebservice.generateEBulletinReport( weeklyProfile,dt.addDays(-5), system.now() , '');

        Test.stopTest();

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

		eBulletinProfiles.add( 
			new AMS_eBulletin_Profile__c( RecordTypeId  	  		 		  		= Schema.SObjectType.AMS_eBulletin_Profile__c.RecordTypeInfosByName.get('Daily').RecordTypeId,
										  User__c       			 		  		= Userinfo.getuserid(),
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
										  User__c       			 		  		= Userinfo.getuserid(),
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

		eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=1,Name='NEW APPLICATIONS',Agency_Information__c='Agency_Info_New_Aplication_Processes__c',Track_CC_History__c=FALSE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=2,Name='NEW APPROVALS',Agency_Information__c='Agency_Info_New_Aplication_Processes__c',Track_CC_History__c=FALSE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=3,Name='NEW APPLICATIONS DISAPPROVED',Agency_Information__c='Agency_Info_New_Aplication_Processes__c',Track_CC_History__c=FALSE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=4,Name='CHANGES IN PROCESS',Agency_Information__c='Agency_Info_Agency_Changes__c',Track_CC_History__c=TRUE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=5,Name='CHANGES FINALISED',Agency_Information__c='Agency_Info_Agency_Changes__c',Track_CC_History__c=FALSE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=6,Name='CHANGE WITHDRAWN',Agency_Information__c='Agency_Info_Agency_Changes__c',Track_CC_History__c=FALSE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=7,Name='TERMINATIONS AND CLOSURES',Agency_Information__c='Agency_Info_Termination_Closures__c',Track_CC_History__c=FALSE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=8,Name='DEFAULT INFORMATION',Agency_Information__c='Agency_Info_Defaults__c',Track_CC_History__c=FALSE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=9,Name='REVIEWS/NOTICES OF TERM.',Agency_Information__c='Agency_Info_Reviews__c',Track_CC_History__c=FALSE));
		eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=10,Name='IRREGULARITIES',Agency_Information__c='Agency_Info_Irregularities__c',Track_CC_History__c=FALSE));

		insert eBulletinCCSections;

		/**
		 2.AMSEBulletinCCExtration
		*/

		List<AMSEBulletinCCExtration__c> eBulletinExtraction = new List <AMSEBulletinCCExtration__c>();

		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CAD',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CCF',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES FINALISED'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CCL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CCN',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CHC',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CHF',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES FINALISED'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CHI',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CHL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CHM',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CHN',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CHO',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CHS',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CHV',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CIJ',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CJJ',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CLF',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES FINALISED'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CLI',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CLM',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CLO',Daily__c=FALSE,Weekly__c=TRUE,Section__c='TERMINATIONS AND CLOSURES'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CLR',Daily__c=FALSE,Weekly__c=FALSE,Section__c=''));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CNF',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES FINALISED'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CNL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CNM',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='COL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CON',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='COS',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CSC',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CSF',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES FINALISED'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CSL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CSM',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CSN',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CTA',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES FINALISED'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CWD',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGE WITHDRAWN'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='DEF',Daily__c=TRUE,Weekly__c=TRUE,Section__c='DEFAULT INFORMATION'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='DIS',Daily__c=FALSE,Weekly__c=TRUE,Section__c='NEW APPLICATIONS DISAPPROVED'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='DWD',Daily__c=TRUE,Weekly__c=TRUE,Section__c='DEFAULT INFORMATION'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='FIN',Daily__c=FALSE,Weekly__c=TRUE,Section__c='NEW APPROVALS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='FPY',Daily__c=TRUE,Weekly__c=TRUE,Section__c='DEFAULT INFORMATION'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='HIN',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='HIS',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='HNL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='HSL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='HSM',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='HSN',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='IRR',Daily__c=TRUE,Weekly__c=TRUE,Section__c='IRREGULARITIES'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='IRS',Daily__c=TRUE,Weekly__c=TRUE,Section__c='IRREGULARITIES'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='IRW',Daily__c=TRUE,Weekly__c=TRUE,Section__c='IRREGULARITIES'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='LRA',Daily__c=FALSE,Weekly__c=FALSE,Section__c=''));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='LRD',Daily__c=FALSE,Weekly__c=FALSE,Section__c=''));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='LRR',Daily__c=FALSE,Weekly__c=FALSE,Section__c=''));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='MCF',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES FINALISED'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='MCH',Daily__c=FALSE,Weekly__c=FALSE,Section__c='CHANGES FINALISED'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='MEP',Daily__c=TRUE,Weekly__c=TRUE,Section__c=''));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='NAC',Daily__c=FALSE,Weekly__c=TRUE,Section__c='NEW APPLICATIONS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='NEW',Daily__c=FALSE,Weekly__c=TRUE,Section__c='NEW APPLICATIONS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='NLI',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='NOT',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REVIEWS/NOTICES OF TERM.'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='NTW',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REVIEWS/NOTICES OF TERM.'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='NWD',Daily__c=FALSE,Weekly__c=TRUE,Section__c='NEW APPLICATIONS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='ONL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='OSL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='OSM',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='OSN',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='RCM',Daily__c=TRUE,Weekly__c=TRUE,Section__c='IRREGULARITIES'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='RCR',Daily__c=TRUE,Weekly__c=TRUE,Section__c='DEFAULT INFORMATION'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='REC',Daily__c=FALSE,Weekly__c=TRUE,Section__c='NEW APPROVALS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='REI',Daily__c=TRUE,Weekly__c=TRUE,Section__c='TERMINATIONS AND CLOSURES'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='RPY',Daily__c=TRUE,Weekly__c=TRUE,Section__c=''));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='RRC',Daily__c=FALSE,Weekly__c=FALSE,Section__c=''));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='RTE',Daily__c=TRUE,Weekly__c=TRUE,Section__c='TERMINATIONS AND CLOSURES'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='RTR',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REVIEWS/NOTICES OF TERM.'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='RVW',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REVIEWS/NOTICES OF TERM.'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='RWD',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REVIEWS/NOTICES OF TERM.'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SCL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SCM',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SCN',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SDR',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REVIEWS/NOTICES OF TERM.'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SLI',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SML',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SMN',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SNI',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SNL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SRM',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REVIEWS/NOTICES OF TERM.'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='STR',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REVIEWS/NOTICES OF TERM.'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='TER',Daily__c=TRUE,Weekly__c=TRUE,Section__c='TERMINATIONS AND CLOSURES'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='TRW',Daily__c=TRUE,Weekly__c=TRUE,Section__c='TERMINATIONS AND CLOSURES'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='VRR',Daily__c=FALSE,Weekly__c=TRUE,Section__c='TERMINATIONS AND CLOSURES'));
		eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='VRW',Daily__c=FALSE,Weekly__c=TRUE,Section__c='TERMINATIONS AND CLOSURES'));


		insert eBulletinExtraction;


		/**
		 3.	AMSEBulletinSettings
		*/

		List<AMSEBulletinSettings__c> eBulletinSettings = new List <AMSEBulletinSettings__c>();

		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='0-Section',Label__c='Section',API_Name__c='Section',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=0,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='1-Change Code',Label__c='Change Code',API_Name__c='Change_Code__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=1,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='2-Change Code',Label__c='Change Code',API_Name__c='Reason_Description__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=1,do_not_show__c=TRUE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='3-Agency Code',Label__c='Agency Code',API_Name__c='Account__r.IATACode__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=2,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='4-Agency Name',Label__c='Agency Name',API_Name__c='Account__r.Name',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=3,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='5-Location Type',Label__c='Location Type',API_Name__c='Account__r.Location_Type__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=4,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='6-Hierarchy',Label__c='Hierarchy',API_Name__c='Account__r.Parent.IATACode__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=5,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='7-Trade Name',Label__c='Trade Name',API_Name__c='Account__r.TradeName__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=6,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='8-City',Label__c='City',API_Name__c='Account__r.BillingCity',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=7,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='9-Country or State',Label__c='Country or State',API_Name__c='Account__r.IATA_ISO_Billing_State__r.name,Account__r.IATA_ISO_Billing_State__r.ISO_Code__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=8,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='10-Country or State',Label__c='Country or State',API_Name__c='Account__r.IATA_ISO_Country__r.name,Account__r.IATA_ISO_Country__r.ISO_Code__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=8,do_not_show__c=TRUE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='11-Street',Label__c='Street',API_Name__c='Account__r.BillingStreet',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=9,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='12-Phone Number',Label__c='Phone Number',API_Name__c='Account__r.Phone',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=10,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='13-Email',Label__c='Email',API_Name__c='Account__r.Email__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=11,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='14-VAT Number 1',Label__c='VAT Number 1',API_Name__c='Account__r.VAT_Number__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=12,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='15-VAT Number 2',Label__c='VAT Number 2',API_Name__c='Account__r.VAT_Number_2__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=13,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='16-Status',Label__c='Status',API_Name__c='Account__r.Status__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=14,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='17-Effective Date',Label__c='Effective Date',API_Name__c='OSCAR__r.Change_effective_as_of__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=15,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='18-User Date',Label__c='User Date',API_Name__c='CreatedDate_User__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=16,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='19-Application Date',Label__c='Application Date',API_Name__c='CreatedDate',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=17,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='20-Reason',Label__c='Reason',API_Name__c='Reason_Description__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=18,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='21-Remarks',Label__c='Remarks',API_Name__c='Bulletin_Information__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=19,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='22-Owners',Label__c='Owners',API_Name__c='Owners',Daily__c=FALSE,Weekly__c=FALSE,Number_Order__c=20,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='23-Owner1',Label__c='Owner1',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=21,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='24-Owner1 %',Label__c='Owner1 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=22,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='25-Owner2',Label__c='Owner2',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=23,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='26-Owner2 %',Label__c='Owner2 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=24,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='27-Owner3',Label__c='Owner3',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=25,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='28-Owner3 %',Label__c='Owner3 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=26,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='29-Owner4',Label__c='Owner4',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=27,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='30-Owner4 %',Label__c='Owner4 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=28,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='31-Owner5',Label__c='Owner5',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=29,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='32-Owner5 %',Label__c='Owner5 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=30,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='33-Owner6',Label__c='Owner6',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=31,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='34-Owner6 %',Label__c='Owner6 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=32,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='35-Owner7',Label__c='Owner7',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=33,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='36-Owner7 %',Label__c='Owner7 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=34,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='37-Owner8',Label__c='Owner8',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=35,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='38-Owner8 %',Label__c='Owner8 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=36,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='39-New Agency Name',Label__c='New Agency Name',API_Name__c='Account__r.Name',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=37,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='40-New Location Type',Label__c='New Location Type',API_Name__c='Account__r.Location_Type__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=38,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='41-New Hierarchy',Label__c='New Hierarchy',API_Name__c='Account__r.Parent.IATACode__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=39,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='42-New Trade Name',Label__c='New Trade Name',API_Name__c='Account__r.TradeName__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=40,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='43-New City',Label__c='New City',API_Name__c='Account__r.BillingCity',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=41,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='44-New Country or State',Label__c='New Country or State',API_Name__c='Account__r.IATA_ISO_Billing_State__r.name,Account__r.IATA_ISO_Billing_State__r.ISO_Code__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=42,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='45-New Country or State',Label__c='New Country or State',API_Name__c='Account__r.IATA_ISO_Country__r.name,Account__r.IATA_ISO_Country__r.ISO_Code__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=42,do_not_show__c=TRUE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='46-New Street',Label__c='New Street',API_Name__c='Account__r.BillingStreet',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=43,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='47-New Phone Number',Label__c='New Phone Number',API_Name__c='Account__r.Phone',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=44,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='48-New Email',Label__c='New Email',API_Name__c='Account__r.Email__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=45,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='49-New VAT Number 1',Label__c='New VAT Number 1',API_Name__c='Account__r.VAT_Number__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=46,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='50-New VAT Number 2',Label__c='New VAT Number 2',API_Name__c='Account__r.VAT_Number_2__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=47,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='51-New Owners',Label__c='New Owners',API_Name__c='Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=48,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='52-New Owner1',Label__c='New Owner1',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=49,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='53-New Owner1 %',Label__c='New Owner1 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=50,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='54-New Owner2',Label__c='New Owner2',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=51,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='55-New Owner2 %',Label__c='New Owner2 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=52,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='56-New Owner3',Label__c='New Owner3',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=53,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='57-New Owner3 %',Label__c='New Owner3 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=54,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='58-New Owner4',Label__c='New Owner4',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=55,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='59-New Owner4 %',Label__c='New Owner4 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=56,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='60-New Owner5',Label__c='New Owner5',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=57,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='61-New Owner5 %',Label__c='New Owner5 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=58,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='62-New Owner6',Label__c='New Owner6',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=59,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='63-New Owner6 %',Label__c='New Owner6 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=60,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='64-New Owner7',Label__c='New Owner7',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=61,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='65-New Owner7 %',Label__c='New Owner7 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=62,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='66-New Owner8',Label__c='New Owner8',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=63,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='67-New Owner8 %',Label__c='New Owner8 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=64,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='68-IRR: Reason',Label__c='IRR: Reason',API_Name__c='Reason_Description__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=65,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='69-IRR: Period',Label__c='IRR: Period',API_Name__c='Start_Date__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=66,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='70-IRR: Period',Label__c='IRR: Period',API_Name__c='End_Date__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=66,do_not_show__c=TRUE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='71-IRR: Point',Label__c='IRR: Point',API_Name__c='Irregularities_Points__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=67,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=TRUE));
		eBulletinSettings.add( new AMSEBulletinSettings__c(Name='72-IRR: Accumulated Irregularities',Label__c='IRR: Accumulated Irregularities',API_Name__c='Account__r.Accumulated_Irregularities__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=68,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=TRUE));

		insert eBulletinSettings;

	}

    
}