@isTest
private class AMS_TreeViewTest {

    @testSetup static void setup(){
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

		Id standardAccountRt = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        
        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = standardAccountRt, Name='Test1 Agency', IATAcode__c = '1234567', Short_Name__c = 'Test1 Agency', /*Legacy_External_ID__c = '12345677',*/ Source_System__c = 'AIMS');
        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = standardAccountRt, Name='Test2 Agency', IATAcode__c = '1234565', Short_Name__c = 'Test2 Agency', /*Legacy_External_ID__c = '12345678',*/ Source_System__c = 'AIMS');
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = standardAccountRt, Name='Test3 Agency', IATAcode__c = '1234564', Short_Name__c = 'Test3 Agency', /*Legacy_External_ID__c = '12345679',*/ Source_System__c = 'AIMS');
        List<Account> listOfAgencies = new List<Account>();
        listOfAgencies.add(a1);
        listOfAgencies.add(a2);
        listOfAgencies.add(a3);
        insert listOfAgencies;

        AMS_Agencies_Hierarchy__c ah = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='MAIN');
        insert ah;

        AMS_Agencies_relationhip__c ar1 = new AMS_Agencies_relationhip__c(Hierarchy__c = ah.id, Parent_Account__c = a1.id, Child_Account__c = a2.id);
        AMS_Agencies_relationhip__c ar2 = new AMS_Agencies_relationhip__c(Hierarchy__c = ah.id, Parent_Account__c = a2.id, Child_Account__c = a3.id);
        List<AMS_Agencies_relationhip__c> listOfRelationships = new List<AMS_Agencies_relationhip__c>();
        listOfRelationships.add(ar1);
        listOfRelationships.add(ar2);
        insert listOfRelationships;
    }
    
    @isTest static void test_TreeViewChild() {
        PageReference pageRef = Page.AMS_DemoTreeViewPage;
        Test.setCurrentPageReference(pageRef);

        Account ag = [select id from Account where Name = 'Test2 Agency'];

        ApexPages.CurrentPage().getparameters().put('id', ag.id);
        ApexPages.StandardController sc = new ApexPages.standardController(ag);

        Test.startTest();
        AMS_DemoTreeview sic = new AMS_DemoTreeview(sc);
        sic.fetchHierchyParent();
        sic.getHierchyChilds();
        Test.stopTest();
    }

    @isTest static void test_TreeViewParent() {
        PageReference pageRef = Page.AMS_DemoTreeViewPage;
        Test.setCurrentPageReference(pageRef);

        Account ag = [select id from Account where Name = 'Test1 Agency'];

        ApexPages.CurrentPage().getparameters().put('id', ag.id);
        ApexPages.StandardController sc = new ApexPages.standardController(ag);

        Test.startTest();
        AMS_DemoTreeview sic = new AMS_DemoTreeview(sc);
        sic.fetchHierchyParent();
        sic.getHierchyChilds();
        Test.stopTest();
    }

    @isTest static void test_TreeViewParent2() {
        PageReference pageRef = Page.AMS_DemoTreeViewPage;
        Test.setCurrentPageReference(pageRef);

        Account a1 = [select id, IATA_ISO_Country__c,RecordTypeId, IATAcode__c  from Account where Name = 'Test1 Agency'];

        Contact co1 = new Contact(AccountId = a1.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = false);
		insert co1;
                
		Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		ID oscarNewHeRt = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_New_HE');
        
        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'US20', ISO_Code__c = 'US', IATA_ISO_Country__c = a1.IATA_ISO_Country__c);
        insert stt;    
		
        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Process__c = AMS_Utils.NEWHESTANDARD, Account__c = a1.id, Is_using_credit_card__c = true, RecordTypeId = oscarNewHeRt, IATA_Codes_OK__c = '1234565' , IATA_Codes_NOK__c = '1234564');

		insert oscar;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = caseRT);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;
	
		ID rtNew = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_Head_Entity_Standard_no_Cash'); 

		AMS_Pax_Accreditation_Form__c theAccreditation = new AMS_Pax_Accreditation_Form__c(RecordTypeId = rtNew);

		theAccreditation.Account_Name__c='NEWGEN-559 HE5';
		theAccreditation.ISSP_AMS_Legal_Status__c='Association';
		theAccreditation.Branch_Office_Country__c= a1.IATA_ISO_Country__c;
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

		ID personRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person'); 

		AMS_Accreditation_Contact__c acontact = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = theAccreditation.Id, 
			First_name__c='Bugs', Last_name__c='Bunny', Agency_owner__c = true, Email__c='bugsandbunny@imagsd.com' , PhoneNational__c = '123123123',
			Phone__c='123123123', Contact__c = co1.Id, Financial_interest__c = 100, RecordTypeId=personRT);

		insert acontact;

		oscar.AMS_Online_Accreditation__c = theAccreditation.Id;
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
        oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;
		update oscar;

        ApexPages.CurrentPage().getparameters().put('id', oscarCase.id);

        Test.startTest();
        AMS_DemoTreeview sic = new AMS_DemoTreeview();

        Test.stopTest();
    }

}