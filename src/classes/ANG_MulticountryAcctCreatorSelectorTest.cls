@isTest
private class ANG_MulticountryAcctCreatorSelectorTest {
	
	@testSetup static void setup(){

		Id settlementRTId = Schema.AMS_Settlement_System__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('BSP').getRecordTypeId();

		AMS_Settlement_System__c settlement = new AMS_Settlement_System__c(
				Name = 'France',
				RecordTypeId = settlementRTId
		);

		insert settlement;

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', ANG_Enable_NewGen__c = true, Region__c = 'Europe',AMS_Settlement_System__c=settlement.Id);
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'FR20', ISO_Code__c = 'FR', IATA_ISO_Country__c = ctry.Id);
        insert stt;
        
        IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='Test Country',ISO_Code__c='ZZ', ANG_Enable_NewGen__c = true, Region__c = 'Europe',AMS_Settlement_System__c=settlement.Id);
        insert ctry2;

        IATA_ISO_State__c stt2 = new IATA_ISO_State__c(Name= 'ZZ', ISO_Code__c = 'ZZ', IATA_ISO_Country__c = ctry2.Id);
        insert stt2;
		
		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
		
		List<Account> accountList = new List<Account>();
		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT ,Name='NewgenAgency GE',Short_Name__c='NewgenAgency GE', Location_Class__c = 'P', Location_Type__c = 'GE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');
		insert a1;
        
        Account newBSPCountryAcc = new Account(IATA_ISO_Country__c = ctry2.Id, ParentId = a1.Id, Top_Parent__c = a1.Id, RecordTypeId = accountRT ,Name='NewgenAgency HE 1',Short_Name__c='NewgenAgency HE', Location_Class__c = 'P', Location_Type__c = 'HE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');
        insert newBSPCountryAcc;
        
        Contact co1 = new Contact(AccountId = a1.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Process__c = AMS_Utils.NGGE, Account__c = a1.id, Is_using_credit_card__c = true, RecordTypeId = AMS_Utils.RECTYPE_NEWGE);

		insert oscar;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = caseRT);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;
		
		ID rtNew = Schema.SObjectType.AMS_Pax_Accreditation_Form__c.getRecordTypeInfosByName().get('Travel Agent - Head Entity Standard no Cash').getRecordTypeId();

		AMS_Pax_Accreditation_Form__c theAccreditation = new AMS_Pax_Accreditation_Form__c(RecordTypeId = rtNew);

		theAccreditation.Account_Name__c='NEWGEN-559 HE5';
		theAccreditation.ISSP_AMS_Legal_Status__c='Association';
		theAccreditation.Branch_Office_Country__c= ctry.Id;
		theAccreditation.Branch_Office_Street_name_number__c='sdfsdf';
		theAccreditation.Branch_Office_City__c='sdfsdfdf';
		theAccreditation.IATA_ISO_State__c= stt.Id;
		theAccreditation.Branch_Office_Email__c='sdfsdfgdg@f3434.com';
		theAccreditation.Branch_Office_Phone__c='123123123';
		theAccreditation.ISSP_AMS_Premises_located_at_airport__c='No';
		theAccreditation.Abbreviated_name__c='NEWGEN-559 HE5';
		theAccreditation.Abbreviated_Address__c='sdfsdf';
		theAccreditation.Remittance_frequency__c='M';
		theAccreditation.Solicitation_Flag__c=false;
		theAccreditation.Location_Class__c='P';
		theAccreditation.Location_Type__c='HE';
		theAccreditation.SAAM_Case__c=oscarCase.Id;
		theAccreditation.Account_Name__c = a1.Id;

		insert theAccreditation;
	}

	@isTest static void ANG_MulticountryAccountCreatorTest() {

        PageReference pageRef = Page.ANG_MulticountryAccountCreator;
        Test.setCurrentPageReference(pageRef);

		AMS_OSCAR__c oscar = [Select Id, ANG_Type_Of_Change__c from AMS_OSCAR__c];

		ApexPages.CurrentPage().getparameters().put('pid', oscar.id);
        ApexPages.StandardController sc = new ApexPages.standardController(oscar);

        Test.startTest();
        
		ANG_MulticountryAccountCreatorController multicreator = new ANG_MulticountryAccountCreatorController(sc);

		oscar = multicreator.oscar;
        multicreator.accIndex = 0;
		Integer accIndex = multicreator.accIndex;
		multicreator.addAccount();
		multicreator.addAccount();
		multicreator.removeAccount();
        multicreator.addAccount();
        
		Integer i = 0;
		
		IATA_ISO_Country__c ctry = [ Select Id from IATA_ISO_Country__c Limit 1];

		for(Account acct: multicreator.listAccount){
			if(acct.Id <> multicreator.mainAccount.Id){
				acct.Name = 'AE' + String.valueOf(i++);
				acct.Location_Class__c = 'P';
				acct.IATA_ISO_Country__c = ctry.Id;
			}
		}
		multicreator.removeAccount();
		multicreator.saveAccount();
 		
		
        Boolean canBeEdited = multicreator.canbeedited;

		List<SelectOption> options = multicreator.getItems();

		Boolean closeTab = multicreator.closeTab;

		Set<String> oscarFields = multicreator.oscarFields;
		List<String> oscarFieldList = multicreator.oscarFieldList;

		multicreator.submitHierarchy();

		Test.StopTest();

		System.debug([Select Id, ParentId, Top_Parent__c, Location_Class__c, Location_Type__c, Name from Account]);

	}
	
	@isTest static void ANG_MulticountryHierarchySelectionCrtlTestSAMEBSP() {
        
		IATA_ISO_Country__c ctry = [Select Id from IATA_ISO_Country__c limit 1];
		
		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		
		AMS_OSCAR__c oscar = [Select Id, ANG_Type_Of_Change__c, Account__c from AMS_OSCAR__c];

		List<Account> accountList = new List<Account>();

		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = oscar.Account__c, Top_Parent__c = oscar.Account__c, RecordTypeId = accountRT ,Name='NewgenAgency GE 1',Short_Name__c='NewgenAgency GE', Location_Class__c = 'P', Location_Type__c = 'AE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');
		Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = oscar.Account__c, Top_Parent__c = oscar.Account__c, RecordTypeId = accountRT ,Name='NewgenAgency GE 2',Short_Name__c='NewgenAgency GE', Location_Class__c = 'P', Location_Type__c = 'AE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');
		Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = oscar.Account__c, Top_Parent__c = oscar.Account__c, RecordTypeId = accountRT ,Name='NewgenAgency GE 3',Short_Name__c='NewgenAgency GE', Location_Class__c = 'P', Location_Type__c = 'AE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');
		Account a4 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = oscar.Account__c, Top_Parent__c = oscar.Account__c, RecordTypeId = accountRT ,Name='NewgenAgency GE 4',Short_Name__c='NewgenAgency GE', Location_Class__c = 'P', Location_Type__c = 'AE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');

		insert new List<Account>{a1,a2,a3,a4};

		PageReference pageRef = Page.ANG_MulticountryHierarchySelection;
        Test.setCurrentPageReference(pageRef);


		ApexPages.CurrentPage().getparameters().put('pid', oscar.id);
        ApexPages.StandardController sc = new ApexPages.standardController(oscar); 

        Test.startTest();
        
		ANG_MulticountryHierarchySelectionCrtl selectionCrtl = new ANG_MulticountryHierarchySelectionCrtl(sc);


		List<String> oscarFields = selectionCrtl.oscarFieldList;
		Set<String> accountFields = selectionCrtl.accountFields;
		List<String> noteList = selectionCrtl.noteList;
        Boolean showTargetAgency = selectionCrtl.showTargetAgency;
        Boolean getDisablePrevious = selectionCrtl.getDisablePrevious();
        Boolean getDisableNext = selectionCrtl.getDisableNext();
        Integer totalPages = selectionCrtl.totalPages;
        Boolean showTopPanel = selectionCrtl.showTopPanel;
        Boolean selectAll = selectionCrtl.selectAll;
        Boolean editable = selectionCrtl.editable;
        
		Map<String, List<ANG_MulticountryHierarchySelectionCrtl.HierarchyItem>> hierarchy = selectionCrtl.hierarchy;
		List<ANG_MulticountryHierarchySelectionCrtl.HierarchyItem> hierarchyValues = selectionCrtl.hierarchyValues;
		selectionCrtl.save();

		Test.stopTest();

	}
	@isTest static void ANG_MulticountryHierarchySelectionCrtlTest2ONLYAE(){

        IATA_ISO_Country__c ctry = [Select Id from IATA_ISO_Country__c limit 1];
		
		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		
		AMS_OSCAR__c oscar = [Select Id, Account__c, Account__r.IATA_ISO_Country__c from AMS_OSCAR__c];

		List<Account> accountList = new List<Account>();

		Id settlementRTId = Schema.AMS_Settlement_System__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('BSP').getRecordTypeId();

		AMS_Settlement_System__c settlement = new AMS_Settlement_System__c(
				Name = 'Portugal',
				RecordTypeId = settlementRTId
		);

		insert settlement;
        
		Account a1 = new Account(IATA_ISO_Country__c = oscar.Account__r.IATA_ISO_Country__c, ParentId = oscar.Account__c, Top_Parent__c = oscar.Account__c, RecordTypeId = accountRT ,Name='NewgenAgency AE 1',Short_Name__c='NewgenAgency AE', Location_Class__c = 'P', Location_Type__c = 'AE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');
		Account a2 = new Account(IATA_ISO_Country__c = oscar.Account__r.IATA_ISO_Country__c, ParentId = oscar.Account__c, Top_Parent__c = oscar.Account__c, RecordTypeId = accountRT ,Name='NewgenAgency AE 2',Short_Name__c='NewgenAgency AE', Location_Class__c = 'P', Location_Type__c = 'AE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');
		Account a3 = new Account(IATA_ISO_Country__c = oscar.Account__r.IATA_ISO_Country__c, ParentId = oscar.Account__c, Top_Parent__c = oscar.Account__c, RecordTypeId = accountRT ,Name='NewgenAgency AE 3',Short_Name__c='NewgenAgency AE', Location_Class__c = 'P', Location_Type__c = 'AE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');
		Account a4 = new Account(IATA_ISO_Country__c = oscar.Account__r.IATA_ISO_Country__c, ParentId = oscar.Account__c, Top_Parent__c = oscar.Account__c, RecordTypeId = accountRT ,Name='NewgenAgency AE 3',Short_Name__c='NewgenAgency AE', Location_Class__c = 'P', Location_Type__c = 'AE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');

		insert new List<Account>{a1,a2,a3,a4};

		PageReference pageRef = Page.ANG_MulticountryHierarchySelection;
        Test.setCurrentPageReference(pageRef);

		ApexPages.CurrentPage().getparameters().put('pid', oscar.id);
        ApexPages.StandardController sc = new ApexPages.standardController(oscar); 

        Test.startTest();
        
		ANG_MulticountryHierarchySelectionCrtl selectionCrtl = new ANG_MulticountryHierarchySelectionCrtl(sc);


		List<String> oscarFields = selectionCrtl.oscarFieldList;
		Set<String> accountFields = selectionCrtl.accountFields;
		List<String> noteList = selectionCrtl.noteList;

		Map<String, List<ANG_MulticountryHierarchySelectionCrtl.HierarchyItem>> hierarchy = selectionCrtl.hierarchy;
		List<ANG_MulticountryHierarchySelectionCrtl.HierarchyItem> hierarchyValues = selectionCrtl.hierarchyValues;
		selectionCrtl.save();

		Test.stopTest();
	}	

	@isTest static void ANG_MulticountryHierarchySelectionCrtlTest3OK(){
        
		IATA_ISO_Country__c ctry = [Select Id from IATA_ISO_Country__c limit 1];
		
		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Id settlementRTId = Schema.AMS_Settlement_System__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('BSP').getRecordTypeId();

		AMS_Settlement_System__c settlement = new AMS_Settlement_System__c(
				Name = 'Portugal',
				RecordTypeId = settlementRTId
		);

		insert settlement;

		IATA_ISO_Country__c ctryPt = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true, Region__c = 'Europe',AMS_Settlement_System__c=settlement.Id);
        insert ctryPt ;

		AMS_OSCAR__c oscar = [Select Id, Account__c from AMS_OSCAR__c];

		List<Account> accountList = new List<Account>();

		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = oscar.Account__c, Top_Parent__c = oscar.Account__c, RecordTypeId = accountRT ,Name='NewgenAgency GE 1',Short_Name__c='NewgenAgency GE', Location_Class__c = 'P', Location_Type__c = 'AE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');
		Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = oscar.Account__c, Top_Parent__c = oscar.Account__c, RecordTypeId = accountRT ,Name='NewgenAgency GE 2',Short_Name__c='NewgenAgency GE', Location_Class__c = 'P', Location_Type__c = 'AE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');
		Account a3 = new Account(IATA_ISO_Country__c = ctryPt.id, ParentId = oscar.Account__c, Top_Parent__c = oscar.Account__c, RecordTypeId = accountRT ,Name='NewgenAgency GE 3',Short_Name__c='NewgenAgency GE', Location_Class__c = 'P', Location_Type__c = 'HE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');

		insert new List<Account>{a1,a2,a3};

		PageReference pageRef = Page.ANG_MulticountryHierarchySelection;
        Test.setCurrentPageReference(pageRef);


		ApexPages.CurrentPage().getparameters().put('pid', oscar.id);
        ApexPages.StandardController sc = new ApexPages.standardController(oscar); 

        Test.startTest();
        
		ANG_MulticountryHierarchySelectionCrtl selectionCrtl = new ANG_MulticountryHierarchySelectionCrtl(sc);


		List<String> oscarFields = selectionCrtl.oscarFieldList;
		Set<String> accountFields = selectionCrtl.accountFields;
		List<String> noteList = selectionCrtl.noteList;

		Map<String, List<ANG_MulticountryHierarchySelectionCrtl.HierarchyItem>> hierarchy = selectionCrtl.hierarchy;
		List<ANG_MulticountryHierarchySelectionCrtl.HierarchyItem> hierarchyValues = selectionCrtl.hierarchyValues;
		
		selectionCrtl.save();

		Test.stopTest();

		selectionCrtl.save();

		selectionCrtl.Beginning();

		selectionCrtl.Previous();

		selectionCrtl.Next();

		selectionCrtl.End();

    }
}