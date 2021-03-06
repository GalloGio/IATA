@isTest
public class ANG_ActivateDeactivateREBatch_Test{

	@testSetup static void testSetup(){

		User u=[select id from User where id =:UserInfo.getUserId()];
		System.runAs(u){
			insert new EmailTemplate(
				isActive = true,
				Name = 'Risk_Status_Upgrade',
				DeveloperName = 'Risk_Status_Upgrade',
				TemplateType = 'text',
				FolderId = UserInfo.getUserId()
			);
		}

		insert new Notification_template__c (
			Subject__c = 'Some subject',
			Message__c = 'Some message',
			Type__c = 'Information',
			Notification_color__c = '#FF5E4D',
			Admins_Users__c = 'User',
			Expire_in_days__c = 0,
			Identifier__c = 'Risk_Status_Upgrade'
		);

		Notification_Template__c nt = new Notification_Template__c();

				nt.Identifier__c ='Risk_Information_Update';
				nt.Language__c ='English';
				nt.Subject__c ='Risk Information Update';
				nt.Type__c ='Information';
				nt.Notification_color__c ='#007FFF';
				nt.Expire_in_days__c =180;
				nt.Admins_Users__c ='Administrators';
				nt.Message__c =
		'We would like to inform you that your Risk Status has been updated. '+
		'Your risk information now stands as follow:'+
		'<br><br>Risk Status: #RISK_STATUS#'+
		'<br>Cash conditions limited to Financial Security: #CASH_CONDITION#'+
		'<br>RHC Amount: #RHC_AMOUNT#'+
		'<br>RHC Effective Date: #RHC_EFFECTIVE_DATE#'+
		'<p>Please check more details on the RHC Information page.'+
		'<br>Thank you</p>'+
		'<p>IATA – Global Delivery Center</p>';

		insert nt;

		insert new AMS_ChangeCodes__c(Name = 'UpgradedRisk', Change_Code__c = 'UGR', Integration_RecId__c = 'C', Bulletin_Memo_Text__c = 'Agent has complied to Agency Rules. Card payment methods are reinstated.');

		ANG_Agency_Risk_Calculation__c calcA = new ANG_Agency_Risk_Calculation__c(RecordTypeId = ANG_Risk_Helper.RECTYPE_RISKSTATUSASSESSMENT, ANG_Financial_Review_Result__c = null, ANG_Risk_History_Assessment__c = AMS_Utils.PASSED, ANG_Risk_History__c = ANG_Risk_Helper.RISK_STATUS_A, ANG_Limit_Cash_Condition__c = false);
		ANG_Agency_Risk_Calculation__c calcB = new ANG_Agency_Risk_Calculation__c(RecordTypeId = ANG_Risk_Helper.RECTYPE_RISKSTATUSASSESSMENT, ANG_Financial_Review_Result__c = null, ANG_Risk_History_Assessment__c = AMS_Utils.FAILED, ANG_Risk_History__c = ANG_Risk_Helper.RISK_STATUS_c, ANG_Limit_Cash_Condition__c = true);
		ANG_Agency_Risk_Calculation__c rule = new ANG_Agency_Risk_Calculation__c(ANG_Order__c = 1, ANG_Occurrence_Num__c = 1, ANG_Adjusted__c = ANG_Risk_Helper.ADJ_NO, ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH, RecordTypeId = ANG_Risk_Helper.RECTYPE_RULES);
		insert new List<ANG_Agency_Risk_Calculation__c>{calcA, calcB, rule};

		ANG_Risk_Event_Type__c ret = new ANG_Risk_Event_Type__c(
			Name = 'Risk Event Test',
			ANG_Description__c = 'Risk Event Test',
			ANG_Expiration__c = 24,
			ANG_Risk_ID__c = 'testRiskId',
			ANG_Agency_Risk_Calculation__c = rule.Id

		);
		insert ret;

		List<AMS_Settlement_System__c> settlementSystemList = new List<AMS_Settlement_System__c>();
		settlementSystemList.add(new AMS_Settlement_System__c(name = 'BSP-01'));
		settlementSystemList.add(new AMS_Settlement_System__c(name = 'BSP-02'));
		settlementSystemList.add(new AMS_Settlement_System__c(name = 'BSP-03'));
		insert settlementSystemList;

		List<ANG_BSP_Attributes__c> bspAttrLst = new List<ANG_BSP_Attributes__c>();
		for(AMS_Settlement_System__c iss:settlementSystemList){
			bspAttrLst.addAll(AMS_OSCAR_TestDataFactory.createOperationAttributes(iss));
		}
		insert bspAttrLst;

		//isoCountry
		IATA_ISO_Country__c isoCntr1 = new IATA_ISO_Country__c(Name = 'Portugal', Region__c = 'Europe', ISO_Code__c='PT', ANG_Enable_NewGen__c = true, AMS_Settlement_System__c = settlementSystemList[0].id);
		IATA_ISO_Country__c isoCntr2 = new IATA_ISO_Country__c(Name = 'China', Region__c = 'Asia', ISO_Code__c='CN', ANG_Enable_NewGen__c = true, AMS_Settlement_System__c = settlementSystemList[1].id);
		IATA_ISO_Country__c isoCntr3 = new IATA_ISO_Country__c(Name = 'United States', Region__c = 'Americas', ISO_Code__c='US', ANG_Enable_NewGen__c = true, AMS_Settlement_System__c = settlementSystemList[2].id);

		insert new List<IATA_ISO_Country__c>{isoCntr1, isoCntr2, isoCntr3};

		//Account
		Account acc1= new Account(Name='Acc1', Location_Class__c = 'P', IATA_ISO_Country__c=isoCntr1.id, Location_Type__c= AMS_Utils.HE, recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY, ANG_HE_RiskStatus__c = ANG_Risk_Helper.RISK_STATUS_C, Reason__c = '21-NEW APPLICATION');
		Account acc2= new Account(Name='Acc2', Location_Class__c = 'P', IATA_ISO_Country__c=isoCntr2.id, Location_Type__c= AMS_Utils.HE, recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY, ANG_HE_RiskStatus__c = ANG_Risk_Helper.RISK_STATUS_C, Reason__c = '21-NEW APPLICATION');
		Account acc3= new Account(Name='Acc3', Location_Class__c = 'P', IATA_ISO_Country__c=isoCntr3.id, Location_Type__c= AMS_Utils.HE, recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY, ANG_HE_RiskStatus__c = ANG_Risk_Helper.RISK_STATUS_C, Reason__c = '21-NEW APPLICATION');
		insert new List<Account>{acc1, acc2, acc3};


		ANG_Agency_Risk_Event__c re1 = new ANG_Agency_Risk_Event__c(
			ANG_AccountId__c = acc1.id,
			ANG_Risk_Type__c = ret.id,
			ANG_Issued_Date__c = System.today(),
			ANG_Event_Status__c = ANG_Risk_Helper.STATUS_INACTIVE
		);

		ANG_Agency_Risk_Event__c re2= new ANG_Agency_Risk_Event__c(
			ANG_AccountId__c = acc2.id,
			ANG_Risk_Type__c = ret.id,
			ANG_Issued_Date__c = System.today().addMonths(-1*Integer.ValueOf(ret.ANG_Expiration__c)),
			ANG_Expiration_Date__c = System.today(),
			ANG_Event_Status__c = ANG_Risk_Helper.STATUS_ACTIVE
		);

		ANG_Agency_Risk_Event__c re3= new ANG_Agency_Risk_Event__c(
			ANG_AccountId__c = acc3.id,
			ANG_Risk_Type__c = ret.id,
			ANG_Issued_Date__c = System.today().addDays(5),
			ANG_Event_Status__c = ANG_Risk_Helper.STATUS_INACTIVE
		);

		ANG_RiskEventGenerator.skipStatusAssignment = true;
		insert new list<ANG_Agency_Risk_Event__c>{re1, re2, re3};
		ANG_RiskEventGenerator.skipStatusAssignment = false;
	}

	static testMethod void testBatch(){ // testing batch 3 records(one to be set active, one to be set inactive, one to ignore)

		Test.startTest();

		Account acc2 =[select id from account where name='Acc2'];

		ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
			ANG_AccountId__c = acc2.Id,
			CurrencyIsoCode = 'EUR',
			RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO
		);

		insert rhcInfo;

		Contact c = new Contact(FirstName = 'test', LastName = 'test', AccountId = acc2.Id, User_Portal_Status__c = 'Approved Admin', Email = 'testiata@yopmail.com');
		insert c;

		Portal_Applications__c par = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		par.Name =ANG_RHCHelper.RISK_PROFILE_AND_RHC_PORTAL_SERVICE;
		insert par;

		insert new Portal_Application_Right__c(Portal_Application__c = par.Id, Right__c = 'Access Granted', Contact__c = c.Id);

		ANG_ActivateDeactivateRiskEventsBatch bat= new ANG_ActivateDeactivateRiskEventsBatch(new list<string>{'Europe','Americas','Asia'});
		bat.execute(null);

		test.StopTest();

		Map<String, ANG_Agency_Risk_Event__c> riskEvents = new Map<String, ANG_Agency_Risk_Event__c>();
		for(ANG_Agency_Risk_Event__c re : [SELECT Id, ANG_Event_Status__c, ANG_AccountId__r.IATA_ISO_Country__r.Region__c FROM ANG_Agency_Risk_Event__c]){
			riskEvents.put(re.ANG_AccountId__r.IATA_ISO_Country__r.Region__c, re);
		}
		System.assertEquals(ANG_Risk_Helper.STATUS_ACTIVE, riskEvents.get('Europe').ANG_Event_Status__c, 'RE1 should be activate');
		System.assertEquals(ANG_Risk_Helper.STATUS_INACTIVE, riskEvents.get('Asia').ANG_Event_Status__c, 'RE2 should be inactive');
		System.assertEquals(ANG_Risk_Helper.STATUS_INACTIVE, riskEvents.get('Americas').ANG_Event_Status__c, 'RE3 should be inactive');

		System.assertEquals(1, [SELECT Id, Subject__c FROM Notification__c].size(), 'Notification was not created');

	}

	static testMethod void testscheduleEasternRegion(){
		//test method to schedule batch for the eastern region to run next week
		Test.startTest();
		ANG_ActivateDeactivateRiskEventsBatch.scheduleEasternRegion(time.newInstance(18, 0, 0, 0));
		test.StopTest();

		List<AsyncApexJob> joblist =Database.query('select Id from AsyncApexJob where JobType in (\'BatchApexWorker\',\'ScheduledApex\') and status =\'Queued\' and  ApexClass.Name =\'ANG_ActivateDeactivateRiskEventsBatch\'');
		System.assertEquals(1,joblist.size(),'There should be just one batch scheduled');
	}

	static testMethod void testscheduleWesternRegion(){
		//test method to schedule batch for the western region to run on the next day
		Test.startTest();
		ANG_ActivateDeactivateRiskEventsBatch.scheduleWesternRegion(null);
		test.StopTest();

		List<AsyncApexJob> joblist =Database.query('select Id from AsyncApexJob where JobType in (\'BatchApexWorker\',\'ScheduledApex\') and status =\'Queued\' and  ApexClass.Name =\'ANG_ActivateDeactivateRiskEventsBatch\'');
		System.assertEquals(1,joblist.size(),'There should be just one batch scheduled');
	}
}
