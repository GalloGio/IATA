@isTest
public class ISSP_CaseTest {

	public static testMethod void testISSP_Case_1() {
		Account account = ISSP_ObjectFactory.createNewAccount();
        account.Name = 'Account1';
        insert account;
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        insert contact;
        User thisUser = ISSP_ObjectFactory.createPortalUser(contact);
        contact.OwnerId = thisUser.Id;
        update contact;
        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Email_to_Case');
        Case c = new Case();
        c.Subject = 'test 1';
        c.Status = 'Open';
        c.AccountId = account.id;
        c.ContactId = contact.id;
        c.Region__c = 'Europe';
        c.RecordTypeId = recordTypeId;
        c.CaseArea__c = 'test';
        c.Reason1__c = 'test';
        insert c;

        ApexPages.currentPage().getParameters().put('caseId', String.valueOf(c.Id));
        ApexPages.currentPage().getParameters().put('recordTypeId', recordTypeId);
        ApexPages.currentPage().getParameters().put('topic', 'test');
        ApexPages.currentPage().getParameters().put('subtopic', 'test1');
        ApexPages.currentPage().getParameters().put('origin', 'Portal');
        
        Test.startTest();
        ISSP_Case.articleWrapper wrapper = new ISSP_Case.articleWrapper();
        system.runAs(thisUser){
        	ISSP_Case cttr = new ISSP_Case();
        	cttr.pageLoad();

        	cttr.AddComment();
        	cttr.edit();
        	ISSP_Case.getFieldMappedValue('test','test');
            cttr.updateCase();
            String fullname = cttr.fullnameNOCFile;
        }
        Test.stopTest();
	}

	public static testMethod void testISSP_Case_2() {
		Account account = ISSP_ObjectFactory.createNewAccount();
        account.Name = 'Account1';
        insert account;
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        insert contact;
        User thisUser = ISSP_ObjectFactory.createPortalUser(contact);
        contact.OwnerId = thisUser.Id;
        update contact;
        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_SIS_Help_Desk');
        Case c = new Case();
        c.Subject = 'test 1';
        c.Status = 'Open';
        c.AccountId = account.id;
        c.ContactId = contact.id;
        c.Region__c = 'Europe';
        c.RecordTypeId = recordTypeId;
        c.CaseArea__c = 'test';
        c.Reason1__c = 'test';
        insert c;

       	ContentVersion doc = new ContentVersion();
        doc.Title = 'test;';
        doc.PathOnClient = 'test';
        doc.VersionData = Blob.valueOf('test');
        insert doc;
        ContentDistribution cDist = new ContentDistribution();
        cDist.RelatedRecordId = c.Id;
        cDist.Name = 'test';
        cDist.ContentVersionId = doc.Id;
        insert cDist;

        ApexPages.currentPage().getParameters().put('caseId', String.valueOf(c.Id));
        ApexPages.currentPage().getParameters().put('recordTypeId', recordTypeId);
        ApexPages.currentPage().getParameters().put('topic', 'SIS');
        ApexPages.currentPage().getParameters().put('subtopic', 'test1');
        ApexPages.currentPage().getParameters().put('origin', 'Portal');
        Test.startTest();
        system.runAs(thisUser){
        	ISSP_Case cttr = new ISSP_Case();
        	cttr.pageLoad();
        	cttr.sisCaseArea = 'test';
        	cttr.AddComment();
        	cttr.edit();
        }
        Test.stopTest();
	}

	public static testMethod void testISSP_Case_3() {
		Account account = ISSP_ObjectFactory.createNewAccount();
        account.Name = 'Account1';
        insert account;
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        insert contact;
        User thisUser = ISSP_ObjectFactory.createPortalUser(contact);
        contact.OwnerId = thisUser.Id;
        update contact;
        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IDFS_Airline_Participation_Process');
        Case c = new Case();
        c.Subject = 'test 1';
        c.Status = 'Draft';
        c.AccountId = account.id;
        c.ContactId = contact.id;
        c.Region__c = 'Europe';
        c.RecordTypeId = recordTypeId;
        c.CaseArea__c = 'test';
        c.Reason1__c = 'test';
        insert c;
        Portal_Applications__c newApp = new Portal_Applications__c();
        newApp.Name = 'TEST';
        insert newApp;
        Portal_Application_Right__c newAppRight = new Portal_Application_Right__c();
        newAppRight.Portal_Application__c = newApp.Id;
        newAppRight.Contact__c = contact.Id;
        newAppRight.Right__c = 'Access Granted';
        insert newAppRight;
        ISSP_Portal_Service_Ids__c newCS = new ISSP_Portal_Service_Ids__c();
        newCS.AgencyAccreditation__c = String.valueOf(newApp.Id).left(15);
        insert newCS;
        AP_Process_Form__c form = new AP_Process_Form__c();
        form.Case__c = c.Id;
        insert form;
        AMS_Pax_Accreditation_Form__c form2 = new AMS_Pax_Accreditation_Form__c();
        form2.Operation_Type__c = 'Travel_Agent';
        form2.SAAM_Case__c = c.Id;
        insert form2;

        FAQ__kav FAQkav;
        FAQkav =  (FAQ__kav)ISSP_ObjectFactory.createSObject('FAQ__kav',false,5);
        FAQkav.Language='en_US';
        FAQkav.UrlName = 'test00qwe';
        FAQkav.Title ='Test';
        FAQkav.To_display_on_Homepage__c=true;
        insert FAQkav;

        String kId = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :FAQkav.Id LIMIT 1].KnowledgeArticleId;

        CaseArticle art = new CaseArticle();
        art.CaseId = c.Id;
        art.KnowledgeArticleId = kId;
        insert art;

        How_To__kav howTokav ;
        howTokav =  (How_To__kav)ISSP_ObjectFactory.createSObject('How_To__kav',false,12);
        howTokav.Language='en_US';
        howTokav.UrlName = 'test2qwesdf';
        howTokav.Title='test2';
        howTokav.To_display_on_Homepage__c=true;
        insert howTokav;

        String kId2 = [SELECT KnowledgeArticleId FROM How_To__kav WHERE Id = :howTokav.Id LIMIT 1].KnowledgeArticleId;

        CaseArticle art2 = new CaseArticle();
        art2.CaseId = c.Id;
        art2.KnowledgeArticleId = kId2;
        insert art2;

        Id recordTypeId2 = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account account2 = ISSP_ObjectFactory.createNewAccount();
        account2.Name = 'Account2';
        account2.RecordTypeId = recordTypeId2;
        account2.Site = '123';
        account2.IATACode__c = '123';
        insert account2;
        Services_Rendered__c service = new Services_Rendered__c();
        service.Services_Rendered_By__c = account.Id;
        service.Services_Rendered_to_Airline__c = account2.Id;
        insert service;

        ApexPages.currentPage().getParameters().put('caseId', String.valueOf(c.Id));
        ApexPages.currentPage().getParameters().put('recordTypeId', recordTypeId);
        ApexPages.currentPage().getParameters().put('topic', 'test');
        ApexPages.currentPage().getParameters().put('subtopic', 'test1');
        ApexPages.currentPage().getParameters().put('origin', 'Portal');
        ApexPages.currentPage().getParameters().put('artid', art.Id);
        Test.startTest();
        system.runAs(thisUser){
        	ISSP_Case cttr = new ISSP_Case();

			ApexPages.currentPage().getParameters().put('topic', 'SA');
			cttr = new ISSP_Case();
			ApexPages.currentPage().getParameters().put('topic', 'TIDS');
			cttr = new ISSP_Case();
			ApexPages.currentPage().getParameters().put('topic', 'VR');
			cttr = new ISSP_Case();

        	cttr.pageLoad();
        	cttr.getAirlines();
        	cttr.AddComment();
        	cttr.edit();
        	cttr.save();
        	cttr.saveAttach();
        	//cttr.getSelectArtical();
        }
        Test.stopTest();
	}

	public static testMethod void testISSP_Case_4() {
		dgAI2__DG_Disable_Features__c dg = dgAI2__DG_Disable_Features__c.getOrgDefaults();
		dg.dgAI2__Disable_Case_Predictions__c = true;
		dg.dgAI2__Disable_Case_Feedback__c = true;
		dg.dgAI2__Disable_Prediction_On_Update__c = true;
		upsert dg;
		
		Account account = ISSP_ObjectFactory.createNewAccount();
        account.Name = 'Account1';
        insert account;
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        insert contact;
        User thisUser = ISSP_ObjectFactory.createPortalUser(contact);
        contact.OwnerId = thisUser.Id;
        update contact;
        String recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'DPC_Service_Request');
        Case c = new Case();
        c.Subject = 'test 1';
        c.Status = 'Draft';
        c.AccountId = account.id;
        c.ContactId = contact.id;
        c.Region__c = 'Europe';
        c.RecordTypeId = recordTypeId;
        c.CaseArea__c = 'test';
        c.Reason1__c = 'test';
        insert c;

        ApexPages.currentPage().getParameters().put('caseId', String.valueOf(c.Id));
        ApexPages.currentPage().getParameters().put('recordTypeId', recordTypeId);
        ApexPages.currentPage().getParameters().put('topic', 'test');
        ApexPages.currentPage().getParameters().put('subtopic', 'test1');
        ApexPages.currentPage().getParameters().put('origin', 'Portal');
        Test.startTest();
        system.runAs(thisUser){
        	ISSP_Case cttr = new ISSP_Case();
        	cttr.pageLoad();
        	cttr.DPCAccept();
        	cttr.DPCCompleteDSR();
        	cttr.newCase.Planned_Start_CR__c = system.today();
        	cttr.newCase.Planned_End_CR__c = system.today();
        	cttr.DPCCompleteScheduleDSR();
        	cttr.DPCSave();
        	cttr.changeDpcOwner();
        	cttr.newCase.Escalated_Status_ACCA__c = '8.0 Doc review - completed';
        	cttr.validateACR();
        	cttr.newCase.Evaluation_Effort__c = 'test';
        	cttr.newCase.Specification_Effort__c = 'test';
            cttr.newCase.Coding_Effort__c = 'test';
            cttr.newCase.Unit_Test_Effort__c = 'test';
    		cttr.newCase.System_Test_Effort__c = 'test';
    		cttr.newCase.QA_Effort__c = 'test';
            cttr.newCase.Documentation_Effort__c = 'test';
            cttr.newCase.Implementation_Effort__c = 'test';
            cttr.newCase.Estimated_Total_Person_days__c = 1;
            cttr.newCase.Estimated_Total_Development_Cost__c = 1;
        	cttr.validateACR();
        	cttr.newCase.Planned_Documentation_Date__c = system.today();
        	cttr.newCase.Planned_Implementation_Date__c = system.today();
        	cttr.validateACR();
        	cttr.newCase.Documentation_Complete__c = system.today();
        	cttr.newCase.Deployment_date_to_acca__c = system.today();
        	cttr.close();
        }
        Test.stopTest();
	}

	public static testMethod void testISSP_Case_5() {
		Account account = ISSP_ObjectFactory.createNewAccount();
        account.Name = 'Account1';
        insert account;
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        insert contact;
        User thisUser = ISSP_ObjectFactory.createPortalUser(contact);
        contact.OwnerId = thisUser.Id;
        update contact;
        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'DPC_Service_Request');
        Case c = new Case();
        c.Subject = 'test 1';
        c.Status = 'Draft';
        c.AccountId = account.id;
        c.ContactId = contact.id;
        c.Region__c = 'Europe';
        c.RecordTypeId = recordTypeId;
        c.CaseArea__c = 'test';
        c.Reason1__c = 'test';
        insert c;

        ApexPages.currentPage().getParameters().put('caseId', String.valueOf(c.Id));
        ApexPages.currentPage().getParameters().put('recordTypeId', recordTypeId);
        ApexPages.currentPage().getParameters().put('topic', 'test');
        ApexPages.currentPage().getParameters().put('subtopic', 'test1');
        ApexPages.currentPage().getParameters().put('origin', 'Portal');
        Test.startTest();
        system.runAs(thisUser){
        	ISSP_Case cttr = new ISSP_Case();
        	cttr.pageLoad();
        	cttr.DPCCaseScheduleWarning = true;
        	cttr.newCase.Region__c = 'Africa & Middle East';
        	cttr.assignToIATA();
        	cttr.newCase.Region__c = 'Americas';
        	cttr.assignToIATA();
        	cttr.newCase.Region__c = 'Asia & Pacific';
        	cttr.assignToIATA();
        	cttr.newCase.Region__c = 'China & North Asia';
        	cttr.assignToIATA();
        	cttr.newCase.Region__c = 'Europe';
        	cttr.assignToIATA();
        	cttr.cancel();
        	ApexPages.currentPage().getParameters().put('retURL', '/ISSP_Homepage');
        	cttr.cancel();
        	ApexPages.currentPage().getParameters().put('caseId', '1234');
        	cttr.cancel();
        	cttr.isEditMode = true;
        	cttr.cancel();
        	cttr.isGSAOnly = false;
        	cttr.isGSAUser = true;
        	cttr.save();
        	cttr.saveAttach();
        	cttr.isGSAOnly = false;
        	cttr.isGSAUser = true;
        	cttr.save();
        	cttr.saveAttach();
        }
        Test.stopTest();
	}
    
	public static testMethod void testISSP_Case_6() {
		Account account = ISSP_ObjectFactory.createNewAccount();
        account.Name = 'Account1';
        insert account;
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        insert contact;
        User thisUser = ISSP_ObjectFactory.createPortalUser(contact);
        contact.OwnerId = thisUser.Id;
        update contact;
        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case','CasesMENA');
        
        // insert a case using json to set the field ClosedDate
        String caseJSON = '{"attributes":{'
            + '"type":"CasSe",'
            + '"url":"/services/data/v25.0/sobjects/Case/500E0000002nH2fIAE"},'
            + '"CreatedDate":' + JSON.serialize(DateTime.now().addMonths(-3)) + ','
            + '"Subject":"test 1",'
            + '"Status":"Closed",'
            + '"ClosedDate":' + JSON.serialize(DateTime.now().addMonths(-3)) + ','
            + '"AccountId":"' + account.id + '",'
            + '"ContactId":"' + contact.id + '",'
            + '"Region__c":"Europe",'
            + '"RecordTypeId":"' + recordTypeId + '",'
            + '"CaseArea__c":"test",'
            + '"Reason1__c":"test",'
            + '"Visible_on_ISS_Portal__c":"true"'
            + '}';
        Case c = (Case) JSON.deserialize(caseJSON, Case.class );
        insert c;
        
        ApexPages.currentPage().getParameters().put('caseId', String.valueOf(c.Id));
        ApexPages.currentPage().getParameters().put('recordTypeId', recordTypeId);
        ApexPages.currentPage().getParameters().put('topic', 'test');
        ApexPages.currentPage().getParameters().put('subtopic', 'test1');
        ApexPages.currentPage().getParameters().put('origin', 'Portal');
        Test.startTest();
        system.runAs(thisUser){
        	ISSP_Case cttr = new ISSP_Case();
            cttr.newCase = c;
        	cttr.showAlertMessage();
        }
        Test.stopTest();
	}

	public static testMethod void testISSP_Case_99() {
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
        							IATA_COUNTRY_EN__c = 'test', IATA_Country_FR__c = 'test', IATA_Country_ZH__c = 'test',
        							IATA_Country_IT__c = 'test', IATA_Country_JP__c = 'test', ISO_Code__c = 'tt',
        							IATA_Country_PT__c = 'test', IATA_Country_SP__c = 'test', Case_BSP_Country__c = 'test');
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2',  ISO_Code__c = 'tp', Case_BSP_Country__c = 'test2');
        insert country2;
		User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId()];
    	currentUserInfo.LanguageLocaleKey = 'pt_BR';
        update currentUserInfo;

        Test.StartTest();
        ISSP_Case cttr = new ISSP_Case();
        cttr.getItems();
        currentUserInfo.LanguageLocaleKey = 'zh_CN';
        update currentUserInfo;
        cttr.getItems();
        currentUserInfo.LanguageLocaleKey = 'fr';
        update currentUserInfo;
        cttr.getItems();
        currentUserInfo.LanguageLocaleKey = 'ja';
        update currentUserInfo;
        cttr.getItems();
        currentUserInfo.LanguageLocaleKey = 'it';
        update currentUserInfo;
        cttr.getItems();
        currentUserInfo.LanguageLocaleKey = 'es';
        update currentUserInfo;
        cttr.getItems();
        currentUserInfo.LanguageLocaleKey = 'ko';
        update currentUserInfo;
        cttr.getItems();
        currentUserInfo.LanguageLocaleKey = 'de';
        update currentUserInfo;
        cttr.getItems();

		Boolean isOSCARCase = cttr.isOSCARCase;
		Boolean isAgencyUser = cttr.isAgencyUser;
		Boolean isToShowSurveyBtn = cttr.isToShowSurveyBtn;
		Boolean isDPCAccepted = cttr.isDPCAccepted;
		Boolean isACRAccepted = cttr.isACRAccepted;
		Boolean disableCaseComments = cttr.getDisableCaseComments();
		Id i = cttr.getAMSRegionalQueue();

        cttr.edit();

		Apexpages.currentPage().getParameters().put('caseTypeSelection', 'Feature Request');

        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Application Error');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Application Error - ICH');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Bankruptcy');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Billing Data Issue');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Business Related');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Certification Issue');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Claim Entry');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Clearance Notifications');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Digital Signature Issue');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Enhancement to Existing Feature');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'ICH Contacts');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'ICH General');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'ICH Membership');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'ICH Reports');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'ICH Reports Issue');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Input File load Issue');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Invoice Issue');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Invoicing / Billing');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Master Table Issue');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Member Profile Issue');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Migration Issue');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Miscellaneous');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'New Feature');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Output File Issue');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Processing Time Issue');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Protest / Adjustment');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Remittance and Settlement');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Reporting Issue');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Sandbox Issue');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Server / iiNET Issue');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Settlement File Issue');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'Supporting Document');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'System Related');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'User Access Issue');
        cttr.getCaseDefectItems();
        Apexpages.currentPage().getParameters().put('caseClassificationSelection', 'test');
        cttr.getCaseDefectItems();

        cttr.newCase.CaseArea__c = 'ICH';
        cttr.getCaseTypeItems();
        cttr.newCase.CaseArea__c = 'SIS';
        cttr.getCaseTypeItems();
        cttr.newCase.CaseArea__c = 'test';
        cttr.getCaseTypeItems();
        List<SelectOption> selectOptions = cttr.getCaseClassificationItems();
        Test.StopTest();
	}
    
    public static testMethod void testCCOthers() {
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.Name = 'Account1';
        insert account;
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.User_Portal_Status__c = 'Approved Admin';
        contact.Email = 'teamcontact@email.com';
        insert contact;
        Contact teamContact = ISSP_ObjectFactory.createNewContact();
        teamContact.Email = 'teamcontact2@email.com';
        insert teamContact;
        User thisUser = ISSP_ObjectFactory.createPortalUser(contact);
        contact.OwnerId = thisUser.Id;
        update contact;
        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case','FDS_ICCS_Email_to_Case');
        Case c = new Case();
        c.Subject = 'test 1';
        c.Status = 'Open';
        c.AccountId = account.id;
        c.ContactId = contact.id;
        c.Region__c = 'Europe';
        c.RecordTypeId = recordTypeId;
        c.CaseArea__c = 'test';
        c.Reason1__c = 'test';
        c.Visible_on_ISS_Portal__c = true;
        c.Account_Concerned__c = contact.AccountId;
        insert c;

        ApexPages.currentPage().getParameters().put('caseId', String.valueOf(c.Id));
        ApexPages.currentPage().getParameters().put('recordTypeId', recordTypeId);
        ApexPages.currentPage().getParameters().put('topic', 'test');
        ApexPages.currentPage().getParameters().put('subtopic', 'test1');
        ApexPages.currentPage().getParameters().put('origin', 'Portal');
        Test.startTest();
        system.runAs(thisUser){
            ISSP_Case cttr = new ISSP_Case();
            cttr.pageLoad();
            // test there are no cc others
            list<String> result1 = cttr.getListCCOther();
            System.assert(result1.isEmpty(),'wrong result ' + result1);
            
            //insert one cc other
            cttr.inputccotheremail = contact.Email;
            cttr.addCCOther();
            // insert one fake cc other
            cttr.inputccotheremail = 'noemail';
            cttr.addCCOther();
            
            // check a cc other was inserted
            set<String> result2 = new set<String>(cttr.getListCCOther());
            System.assert(result2.contains(contact.Email),'wrong result ' + result2);
            
            //remove ccother
            cttr.inputDelCCOther = contact.Email;
            cttr.delCCOther();
            // del one fake cc other
            cttr.inputDelCCOther = 'noemail';
            cttr.delCCOther();
            
            list<String> result3 = cttr.getListCCOther();
            System.assert(result3.isEmpty(),'wrong result ' + result3);
        }
        Test.stopTest();
    }

    public static testMethod void testDCPnewCase() {
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.Name = 'Account1';
        insert account;
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.User_Portal_Status__c = 'Approved Admin';
        contact.status__c = 'Active';
        contact.Email = 'teamcontact@email.com';
        insert contact;

       Id p = [select id from profile where name='ISS Portal DPC Admin'].id;

        User user = new User(alias = 'test123', email=contact.Email,
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = contact.Id, FederationIdentifier = contact.Id,
                timezonesidkey='America/Los_Angeles', username=contact.Email);

        insert user;

       List<ISSP_DPC__c> mcs = new List<ISSP_DPC__c>();
       ISSP_DPC__c accaRoleIds = new ISSP_DPC__c(name='ACCA Roles', Value__c=null);
       ISSP_DPC__c accaAccounts = new ISSP_DPC__c(name='ACCA Accounts', Value__c=null);
       ISSP_DPC__c nonAccaAccounts = new ISSP_DPC__c(name='Non-ACCA Accounts', Value__c=null);
       ISSP_DPC__c dpcRecordType = new ISSP_DPC__c(name='DPC Recordtype', Value__c='test');
       ISSP_DPC__c dpcSector = new ISSP_DPC__c(name='DPC Sector', Value__c='test');
       ISSP_DPC__c dpcCategory = new ISSP_DPC__c(name='DPC Category', Value__c='test');
       mcs.add(accaRoleIds);
       mcs.add(accaAccounts);
       mcs.add(nonAccaAccounts);
       mcs.add(dpcRecordType);
       mcs.add(dpcSector);
       mcs.add(dpcCategory);
       insert mcs;
       
        ApexPages.currentPage().getParameters().put('caseArea', 'Area1');
        Test.startTest();
        // system.runAs(thisUser){
           system.runAs(user) {
            ISSP_Case cttr = new ISSP_Case();
            cttr.pageLoad();
            cttr.whoToContact = account.Id;
            cttr.save();
            cttr.saveAttach();
            // test insert cc other
            cttr.inputccotheremail = user.Email;
            cttr.addCCOther();
            set<String> result1 = new set<String>(cttr.getListCCOther());
            System.assert(result1.contains(user.Email),'wrong result ' + result1);

            cttr.inputDelCCOther = user.Email;
            cttr.delCCOther();
            cttr.InterDPCAccept();
            cttr.getCustomLabel('ISSP_NewCase');
            // test delete cc other
            list<String> result2 = cttr.getListCCOther();
            System.assert(result2.isEmpty(),'wrong result ' + result2);
        }
        Test.stopTest();
    }

    public static testMethod void testDPC() {
        List<ISSP_DPC__c> mcs = new List<ISSP_DPC__c>();
        ISSP_DPC__c accaRoleIds = new ISSP_DPC__c(name='ACCA Roles', Value__c=null);
        ISSP_DPC__c accaAccounts = new ISSP_DPC__c(name='ACCA Accounts', Value__c=null);
        ISSP_DPC__c nonAccaAccounts = new ISSP_DPC__c(name='Non-ACCA Accounts', Value__c=null);
        ISSP_DPC__c dpcRecordType = new ISSP_DPC__c(name='DPC Recordtype', Value__c='test');
        ISSP_DPC__c dpcSector = new ISSP_DPC__c(name='DPC Sector', Value__c='test');
        ISSP_DPC__c dpcCategory = new ISSP_DPC__c(name='DPC Category', Value__c='test');
        mcs.add(accaRoleIds);
        mcs.add(accaAccounts);
        mcs.add(nonAccaAccounts);
        mcs.add(dpcRecordType);
        mcs.add(dpcSector);
        mcs.add(dpcCategory);
        insert mcs;
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.Name = 'Account1';
        insert account;
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        insert contact;
        Contact teamContact = ISSP_ObjectFactory.createNewContact();
        teamContact.Email = 'teamcontact@email.com';
        insert teamContact;

       Id p = [select id from profile where name='ISS Portal DPC Admin'].id;
       ISSP_UserTriggerHandler.preventTrigger = true;
        User user = new User(alias = 'test123', email=teamContact.Email,
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = contact.Id, FederationIdentifier = contact.Id,
                timezonesidkey='America/Los_Angeles', username=teamContact.Email);

        insert user;
        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case','Inter_DPCs');
        Case c = new Case();
        c.Subject = 'test 1';
        c.Status = 'Open';
        c.AccountId = account.id;
        c.ContactId = contact.id;
        c.Region__c = 'Europe';
        c.RecordTypeId = recordTypeId;
        c.CaseArea__c = 'test';
        c.Reason1__c = 'test';
        c.Visible_on_ISS_Portal__c = true;
        insert c;

        ApexPages.currentPage().getParameters().put('caseId', String.valueOf(c.Id));
        ApexPages.currentPage().getParameters().put('recordTypeId', recordTypeId);

        Test.startTest();
        system.runAs(user) {
            ISSP_Case cttr = new ISSP_Case();
            cttr.pageLoad();
            cttr.whoToContact = account.Id;
            cttr.additionalRecipients=user.Email;
            cttr.save();
            cttr.getListCaseHistory();
            System.assertEquals(true,cttr.getIsInterDPCCase());
            cttr.getAccountConcernedName();
            cttr.getCaseContactName();
            cttr.newCase.Account_Concerned__c = null;
            cttr.newCase.ContactId = null;
            update cttr.newCase;
            cttr.getAccountConcernedName();
            cttr.getCaseContactName();
        }
        Test.stopTest();
    }


    public static testMethod void tesTIP() {
      
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.Name = 'Account1';
        insert account;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = account.Id;
        insert con;

        Case c = new Case();
        c.Subject = 'test 1';
        c.AccountId = account.id;
        c.ContactId = con.id;
        c.Region__c = 'Europe';
        c.RecordTypeId = TIP_Utils.CASE_PROCESS_IDFS_RECORD_TYPE_ID;
        c.Reason1__c = TIP_Utils.CASE_REASON_PRODUCT_MANAGEMENT;
        c.status = TIP_Utils.CASE_STATUS_DRAFT;
        c.CaseArea__c = TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS;
        c.Visible_on_ISS_Portal__c = true;
       
       User user = ISSP_ObjectFactory.createPortalUser(con);

       Portal_Applications__c pa = new Portal_Applications__c(name = TIP_Utils.PORTAL_SERVICE_NAME_TIP);
       insert pa;
         
          ISSP_Portal_Service_Ids__c psi = new ISSP_Portal_Service_Ids__c(

        TIP_Portal_Service_Id__c=pa.id
        );
       insert psi;

       Portal_Application_Right__c appRight = new Portal_Application_Right__c (
           Right__c = 'Access Granted', 
           Contact__c = user.ContactId, 
           Portal_Application__c = pa.id);
       insert appRight;

       con.OwnerId = user.Id;
       update con;

       
       Test.startTest();
        system.runAs(user) {
             insert c;
            ISSP_Case cttr = new ISSP_Case();
            ApexPages.currentPage().getParameters().put('caseId', String.valueOf(c.Id));
            cttr.pageLoad();
        }
       Test.stopTest();
     }

 }