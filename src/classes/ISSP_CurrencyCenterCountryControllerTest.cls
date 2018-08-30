@isTest
private class ISSP_CurrencyCenterCountryControllerTest {
	
	@isTest static void testSectionChanged(){
		Test.startTest();

		//insert country profile
		Country_Profile__c cp = new Country_Profile__c(Name='Test Country');
		insert cp;

		//set page to ISSP_CurrencyCenterCountry and set the country profile id
		PageReference pageRef = Page.ISSP_CurrencyCenterCountry;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('id', String.valueOf(cp.Id));

		//initialize controller+extension
		ApexPages.StandardController sc = new ApexPages.StandardController(cp);
		ISSP_CurrencyCenterCountryController ctrl = new ISSP_CurrencyCenterCountryController(sc);

		//use below to increase coverage - these are methods/vars which are invoked directly from VF page
		String s = ctrl.isChangedString;
		Boolean f = ctrl.isCountryFollowed;
		ctrl.ToggleFollow();
		PageReference checkAccess = ctrl.checkAccess();

		// check "isSectionChanged" methods - all should be false as it's a new country profile;
        System.assertEquals(false,ctrl.isGeneralInformationChanged);
        System.assertEquals(false,ctrl.isBspCassChanged);
        System.assertEquals(false,ctrl.isEconomicProfileChanged);
        System.assertEquals(false,ctrl.isCurrencyChanged);
        System.assertEquals(false,ctrl.isRepatriationChanged);
        System.assertEquals(false,ctrl.isImportantContactsChanged);
        System.assertEquals(false,ctrl.isIccsChanged);
        System.assertEquals(false,ctrl.isAirlinesChargesChanged);

        //insert some fake history value for general information and test again
        Country_Profile_History__c cph = new Country_Profile_History__c(Country_Profile__c=cp.Id,Field__c='Presence_of_BSP__c');
        insert cph;
		sc = new ApexPages.StandardController(cp);
		ctrl = new ISSP_CurrencyCenterCountryController(sc);
		//as we inserted history entry for Presence_of_BSP__c, general information section should be changed
		System.assertEquals(true,ctrl.isGeneralInformationChanged);
    	
    	Test.stopTest();
	}

	@isTest static void testActions(){
		Test.startTest();

		//insert country profile
		Country_Profile__c cp = new Country_Profile__c(Name='Test Country');
		insert cp;

		// create actions (tasks, events)
		List<Task> tList = new List<Task>();
		List<Event> eList = new List<Event>();

		// add past tasks
		tList.add(new Task(WhatId=cp.Id,RecordTypeId=RecordTypeSingleton.getInstance().getRecordTypeId('Task', 'Airlines_Industry_Communication'),ActivityDate=Date.today().addDays(-1)));
		tList.add(new Task(WhatId=cp.Id,RecordTypeId=RecordTypeSingleton.getInstance().getRecordTypeId('Task', 'IATA_Airlines_Survey'),ActivityDate=Date.today().addDays(-2)));

		// add future tasks
		tList.add(new Task(WhatId=cp.Id,RecordTypeId=RecordTypeSingleton.getInstance().getRecordTypeId('Task', 'Official_Letter'),ActivityDate=Date.today().addDays(2)));
		tList.add(new Task(WhatId=cp.Id,RecordTypeId=RecordTypeSingleton.getInstance().getRecordTypeId('Task', 'Press_Release'),ActivityDate=Date.today().addDays(1)));

		// add past events
		eList.add(new Event(WhatId=cp.Id,RecordTypeId=RecordTypeSingleton.getInstance().getRecordTypeId('Event', 'Conference_Call'),StartDateTime=Datetime.now().addDays(-1),EndDateTime=Datetime.now().addDays(-1).addHours(1)));
		eList.add(new Event(WhatId=cp.Id,RecordTypeId=RecordTypeSingleton.getInstance().getRecordTypeId('Event', 'Meeting'),StartDateTime=Datetime.now().addDays(-1),EndDateTime=Datetime.now().addDays(-1).addHours(1)));

		// add future events
		eList.add(new Event(WhatId=cp.Id,RecordTypeId=RecordTypeSingleton.getInstance().getRecordTypeId('Event', 'Task_Force'),StartDateTime=Datetime.now().addDays(1),EndDateTime=Datetime.now().addDays(1).addHours(1)));

		insert tList;
		insert eList;

		//set page to ISSP_CurrencyCenterCountry and set the country profile id
		PageReference pageRef = Page.ISSP_CurrencyCenterCountry;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('id', String.valueOf(cp.Id));

		//initialize controller+extension
		ApexPages.StandardController sc = new ApexPages.StandardController(cp);
		ISSP_CurrencyCenterCountryController ctrl = new ISSP_CurrencyCenterCountryController(sc);

		// we should have 4 past actions (2 tasks + 2 events)
		System.assertEquals(4,ctrl.pastActionList.size());
		// we should have 3 future actions (2 tasks + 1 event)
		System.assertEquals(3,ctrl.futureActionList.size());
    	
    	Test.stopTest();
	}

	@isTest static void testAttachments(){
		Test.startTest();

		//insert country profile
		Country_Profile__c cp = new Country_Profile__c(Name='Test Country');
		insert cp;

		// create attachments
		List<Attachment> aList = new List<Attachment>();
		aList.add(new Attachment(ParentId=cp.Id,Name='test',
        						Body=Blob.valueof('some text'),
        						Description='1__###__General Information__###__Sample Description'
        						));
		aList.add(new Attachment(ParentId=cp.Id,Name='test',
        						Body=Blob.valueof('some text'),
        						Description='1__###__BSP Profile__###__Sample Description'
        						));
		aList.add(new Attachment(ParentId=cp.Id,Name='test',
        						Body=Blob.valueof('some text'),
        						Description='1__###__CASS Profile__###__Sample Description'
        						));
		aList.add(new Attachment(ParentId=cp.Id,Name='test',
        						Body=Blob.valueof('some text'),
        						Description='1__###__Economic Profile__###__Sample Description'
        						));
		aList.add(new Attachment(ParentId=cp.Id,Name='test',
        						Body=Blob.valueof('some text'),
        						Description='1__###__Currency__###__Sample Description'
        						));
		aList.add(new Attachment(ParentId=cp.Id,Name='test',
        						Body=Blob.valueof('some text'),
        						Description='1__###__Repatriation Process__###__Sample Description'
        						));
		aList.add(new Attachment(ParentId=cp.Id,Name='test',
        						Body=Blob.valueof('some text'),
        						Description='1__###__Important Contacts__###__Sample Description'
        						));
		aList.add(new Attachment(ParentId=cp.Id,Name='test',
        						Body=Blob.valueof('some text'),
        						Description='1__###__ICCS Content__###__Sample Description'
        						));
		aList.add(new Attachment(ParentId=cp.Id,Name='test',
        						Body=Blob.valueof('some text'),
        						Description='1__###__Airlines Charges__###__Sample Description'
        						));
        insert aList;

		//set page to ISSP_CurrencyCenterCountry and set the country profile id
		PageReference pageRef = Page.ISSP_CurrencyCenterCountry;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('id', String.valueOf(cp.Id));

		//initialize controller+extension
		ApexPages.StandardController sc = new ApexPages.StandardController(cp);
		ISSP_CurrencyCenterCountryController ctrl = new ISSP_CurrencyCenterCountryController(sc);

		//all sections should have 1 attachment
		System.assertEquals(1,ctrl.attGI.size());
    	System.assertEquals(1,ctrl.attBSP.size());
    	System.assertEquals(1,ctrl.attCASS.size());
    	System.assertEquals(1,ctrl.attEconomic.size());
    	System.assertEquals(1,ctrl.attCurr.size());
    	System.assertEquals(1,ctrl.attRP.size());
    	System.assertEquals(1,ctrl.attIC.size());
    	System.assertEquals(1,ctrl.attICCS.size());
    	System.assertEquals(1,ctrl.attAC.size());

    	Test.stopTest();
	}

}