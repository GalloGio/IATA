@isTest
public class SIDRAliteMassActionControllerTest {


    private static Case createParentCase(Id recordtypeID) {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(
            Name = 'Canada',
            ISO_Code__c = 'CA',
            AIMS_Area_Name__c = 'Canada',
            AIMS_Area_ID__c = '1'
        );
        insert country;

        Account account = new Account(
            Name = 'Test account',
            BillingCity = 'Montreal',
            BillingCountry = 'Canada',
            BillingStreet = 'some street',
            IATA_ISO_Country__c = country.Id,
            Location_Type__c = 'HO',
            IATACode__c = '1234567',
            Type = 'IATA Cargo Agent',
            Status__c = 'Approved'
        );
        //Type = 'IATA Passenger Sales Agent'
        //Type = 'IATA Cargo Agent'
        insert account;

        IATA_ISO_Country__c[] associatedCountry = [Select i.Name, i.Id From IATA_ISO_Country__c i where Name = :account.BillingCountry];
        System.assert(associatedCountry != null && associatedCountry.size() > 0);

        Contact contact = new Contact(
            RecordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact'),
            FirstName = 'Dummy',
            LastName = 'Contact',
            Type_of_Contact__c = 'IFAP Contact',
            AccountId = account.Id,
            Email = 'some@email.org',
            Financial_Assessment_Contact__c = true
        );
        insert contact;

        Case cse = new Case(
            RecordtypeId = recordtypeId,
            Region__c='Americas',
            BSPCountry__c = 'Canada',
            Subject = 'Test Case 1',
            Status = 'Agent to be Notified',
            Origin = 'Agent Financial Review Notification',
            Priority = 'Normal',
            Financial_Review_Type__c = 'New applications',
            IFAP_Financial_Year__c = String.valueOf(Date.today().year()),
            Deadline_Date__c = Date.today().addMonths(1),
            Agent_Code__c = '1234567',
            ContactId = contact.Id,
            AccountId = account.Id,
            Description = 'Test Case 1',
            Start_Date_of_Sales_Period__c = Date.today(),
            End_Date_of_Sales_Period__c = Date.today(),
            Next_Remittance_Date__c = Date.today()
        );
        return cse;
    }

    private static void selectAll(SIDRAliteMassActionController controller) {
        list<String> listIds = new list<String>();
        for (SIDRAliteMassActionController.WrapperCase wrapper: controller.listWrapperCase) {
            listIds.add(wrapper.cse.Id);
        }
        controller.selectedIds = String.join(listIds,',');
    }

    @isTest
    public static void testController() {

        Test.startTest();
        SIDRAliteMassActionController controller = new SIDRAliteMassActionController();
        controller.filter.getListIFAPCountries();
        controller.triggerSidraLiteAction();
        controller.exportCSV();
        Test.stopTest();
    }

    @isTest
    public static void testSearchIFAPFS() {
        Case ifapCase = createParentCase(SIDRAliteMassActionController.RECORDTYPE_IFAP.Id);
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.firstFSnonComplianceDate__c = null;
        ifapCase.FS_Second_Deadline_Date__c = null;
        ifapCase.FS_Third_Deadline_Date__c = null;
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;

        Test.startTest();
        SIDRAliteMassActionController controller = new SIDRAliteMassActionController();
        controller.filter.cse.RecordTypeId = SIDRAliteMassActionController.RECORDTYPE_IFAP.Id;
        controller.filter.cse.Region__c = 'Americas';
        controller.filter.cse.BSPCountry__c = 'Canada';
        controller.filter.ifapType = 'FS';

        ifapCase.Region__c = 'Americas';
        update ifapCase;

        controller.search();
        System.assert(controller.listWrapperCase.size()==1);
        selectAll(controller);
        controller.triggerSidraLiteAction();

        for (SIDRAliteMassActionController.WrapperCase result: controller.listWrapperCase) {
            System.assert(result.getIsSuccess());
            result.getChildId();
            result.getIfapType();
        }

        controller.filter.getShortName();
        controller.filter.getListReasons();
        controller.filter.getListFinancialReviews();
        controller.getcsvContent();
        Test.stopTest();
    }

    @isTest
    public static void testSearchIFAPFA() {
        Case ifapCase = createParentCase(SIDRAliteMassActionController.RECORDTYPE_IFAP.Id);
        ifapCase.Status = 'Financial Statements Uploaded';
        ifapCase.FA_Letter_Sent__c = true;
        ifapCase.firstFAnonComplianceDate__c = null;
        ifapCase.FA_Second_Deadline_Date__c = null;
        ifapCase.FA_Third_Deadline_Date__c = null;
        ifapCase.Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;

        Test.startTest();
        SIDRAliteMassActionController controller = new SIDRAliteMassActionController();
        controller.filter.cse.RecordTypeId = SIDRAliteMassActionController.RECORDTYPE_IFAP.Id;
        controller.filter.cse.Region__c = 'Americas';
        controller.filter.cse.BSPCountry__c = 'Canada';
        controller.filter.ifapType = 'FA';

        ifapCase.Region__c = 'Americas';
        update ifapCase;

        controller.search();
        System.assert(controller.listWrapperCase.size()==1);
        selectAll(controller);
        controller.triggerSidraLiteAction();

        for (SIDRAliteMassActionController.WrapperCase result: controller.listWrapperCase) {
            System.assert(result.getIsSuccess());
            result.getChildId();
            result.getIfapType();
        }

        controller.filter.getShortName();
        controller.filter.getListReasons();
        controller.getcsvContent();
        Test.stopTest();
    }

    @isTest
    public static void testSearchSMAP() {
        Case smapCase = createParentCase(SIDRAliteMassActionController.RECORDTYPE_SMAP.Id);
        smapCase.Decision__c = 'Prejudiced Collection of Funds';
        smapCase.Suspension_Date__c = Date.today().addDays(-1);
        insert smapCase;

        Test.startTest();
        SIDRAliteMassActionController controller = new SIDRAliteMassActionController();
        controller.filter.cse.RecordTypeId = SIDRAliteMassActionController.RECORDTYPE_SMAP.Id;
        controller.filter.cse.Region__c = 'Americas';
        controller.filter.cse.BSPCountry__c = 'Canada';

        smapCase.Region__c = 'Americas';
        update smapCase;

        controller.search();
        System.assert(controller.listWrapperCase.size()==1);
        selectAll(controller);
        controller.triggerSidraLiteAction();

        for (SIDRAliteMassActionController.WrapperCase result: controller.listWrapperCase) {
            System.assert(result.getIsSuccess());
            result.getChildId();
        }

        controller.filter.getShortName();
        controller.filter.getListReasons();
        controller.getcsvContent();
        Test.stopTest();
    }

    @isTest
    public static void testSearchSAAM_ReasonType1() {
        Case saamCase = createParentCase(SIDRAliteMassActionController.RECORDTYPE_SAAM.Id);
        saamCase.Reason1__c = 'Financial Security Renewal';
        saamCase.Bank_Guarantee_deadline__c = Date.today().addDays(-1);
        insert saamCase;

        Test.startTest();
        SIDRAliteMassActionController controller = new SIDRAliteMassActionController();
        controller.filter.cse.RecordTypeId = SIDRAliteMassActionController.RECORDTYPE_SAAM.Id;
        controller.filter.cse.Region__c = 'Americas';
        controller.filter.cse.BSPCountry__c = 'Canada';
        controller.filter.cse.Reason1__c = saamCase.Reason1__c;

        saamCase.Region__c = 'Americas';
        update saamCase;

        controller.search();
        System.assert(controller.listWrapperCase.size()==1);
        selectAll(controller);
        controller.triggerSidraLiteAction();

        for (SIDRAliteMassActionController.WrapperCase result: controller.listWrapperCase) {
            System.assert(result.getIsSuccess());
            result.getChildId();
        }

        controller.filter.getShortName();
        controller.filter.getListReasons();
        controller.getcsvContent();
        Test.stopTest();
    }

    @isTest
    public static void testSearchSAAM_ReasonType2() {
        Case saamCase = createParentCase(SIDRAliteMassActionController.RECORDTYPE_SAAM.Id);
        saamCase.Reason1__c = 'Certificate DGR';
        saamCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
        insert saamCase;

        Test.startTest();
        SIDRAliteMassActionController controller = new SIDRAliteMassActionController();
        controller.filter.cse.RecordTypeId = SIDRAliteMassActionController.RECORDTYPE_SAAM.Id;
        controller.filter.cse.Region__c = 'Americas';
        controller.filter.cse.BSPCountry__c = 'Canada';
        controller.filter.cse.Reason1__c = saamCase.Reason1__c;

        saamCase.Region__c = 'Americas';
        update saamCase;

        controller.search();
        System.assert(controller.listWrapperCase.size()==1);
        selectAll(controller);
        controller.triggerSidraLiteAction();

        for (SIDRAliteMassActionController.WrapperCase result: controller.listWrapperCase) {
            System.assert(result.getIsSuccess());
            result.getChildId();
        }

        controller.filter.getShortName();
        controller.filter.getListReasons();
        controller.getcsvContent();
        Test.stopTest();
    }

    @isTest
    public static void testSearchSAAM_ReasonType3() {
        Case saamCase = createParentCase(SIDRAliteMassActionController.RECORDTYPE_SAAM.Id);
        saamCase.Reason1__c = 'Annual Fees';
        saamCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
        insert saamCase;

        Test.startTest();
        SIDRAliteMassActionController controller = new SIDRAliteMassActionController();
        controller.filter.cse.RecordTypeId = SIDRAliteMassActionController.RECORDTYPE_SAAM.Id;
        controller.filter.cse.Region__c = 'Americas';
        controller.filter.cse.BSPCountry__c = 'Canada';
        controller.filter.cse.Reason1__c = saamCase.Reason1__c;

        saamCase.Region__c = 'Americas';
        update saamCase;

        controller.search();
        System.assert(controller.listWrapperCase.size()==1);
        selectAll(controller);
        controller.triggerSidraLiteAction();

        for (SIDRAliteMassActionController.WrapperCase result: controller.listWrapperCase) {
            System.assert(result.getIsSuccess());
            result.getChildId();
        }

        controller.filter.getShortName();
        controller.filter.getListReasons();
        controller.getcsvContent();
        Test.stopTest();
    }

    @isTest
    public static void testSearchOSCAR_Reasons1() {
        Case oscarCase = createParentCase(SIDRAliteMassActionController.RECORDTYPE_OSCAR.Id);
        oscarCase.Reason1__c = new list<String>(SidraLiteHelperForOSCAR.VALID_REASONS1).get(0);
        insert oscarCase;
        
        Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account account = new Account(RecordTypeId = agencyRT, Name='Test Account');
        insert account;

        AMS_OSCAR__c oscar = new AMS_OSCAR__c(
            Account__c = account.Id,
            RPM_Approval__c = 'Authorize Disapproval'
        );
        insert oscar;

        Test.startTest();
        SIDRAliteMassActionController controller = new SIDRAliteMassActionController();
        controller.filter.cse.RecordTypeId = SIDRAliteMassActionController.RECORDTYPE_OSCAR.Id;
        controller.filter.cse.Region__c = 'Americas';
        controller.filter.cse.BSPCountry__c = 'Canada';

        oscarCase.OSCAR__c = oscar.Id;
        oscarCase.Region__c = 'Americas';
        update oscarCase;

        controller.search();
        System.assert(controller.listWrapperCase.size()==1);
        selectAll(controller);
        controller.triggerSidraLiteAction();

        for (SIDRAliteMassActionController.WrapperCase result: controller.listWrapperCase) {
            System.assert(result.getIsSuccess());
            result.getChildId();
        }

        controller.filter.getShortName();
        controller.filter.getListReasons();
        controller.getcsvContent();
        Test.stopTest();
    }

    @isTest
    public static void testSearchOSCAR_Reasons2() {
        Case oscarCase = createParentCase(SIDRAliteMassActionController.RECORDTYPE_OSCAR.Id);
        oscarCase.Reason1__c = new list<String>(SidraLiteHelperForOSCAR.VALID_REASONS2).get(0);
        oscarCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
        oscarCase.Termination_date_manual_entry__c = null;
        oscarCase.Documentation_Complete__c = null;
        insert oscarCase;

        Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account account = new Account(RecordTypeId = agencyRT, Name='Test Account');
        insert account;

        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = account.Id);
        insert oscar;

        Test.startTest();
        SIDRAliteMassActionController controller = new SIDRAliteMassActionController();
        controller.filter.cse.RecordTypeId = SIDRAliteMassActionController.RECORDTYPE_OSCAR.Id;
        controller.filter.cse.Region__c = 'Americas';
        controller.filter.cse.BSPCountry__c = 'Canada';

        oscarCase.OSCAR__c = oscar.Id;
        oscarCase.Region__c = 'Americas';
        update oscarCase;

        controller.search();
        System.assert(controller.listWrapperCase.size()==1);
        selectAll(controller);
        controller.triggerSidraLiteAction();

        for (SIDRAliteMassActionController.WrapperCase result: controller.listWrapperCase) {
            System.assert(result.getIsSuccess());
            result.getChildId();
        }

        controller.filter.getShortName();
        controller.filter.getListReasons();
        controller.getcsvContent();
        Test.stopTest();
    }

    @isTest
    public static void testSearchInvoicing() {
        Case invoicingCase = createParentCase(SIDRAliteMassActionController.RECORDTYPE_INVOICING.Id);
        invoicingCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
        invoicingCase.Has_the_agent_paid_invoice__c = 'Not paid';
        invoicingCase.Reason1__c = 'Annual Fees';
        insert invoicingCase;

        Test.startTest();
        SIDRAliteMassActionController controller = new SIDRAliteMassActionController();
        controller.filter.cse.RecordTypeId = SIDRAliteMassActionController.RECORDTYPE_INVOICING.Id;
        controller.filter.cse.Region__c = 'Americas';
        controller.filter.cse.BSPCountry__c = 'Canada';

        invoicingCase.Region__c = 'Americas';
        update invoicingCase;

        controller.search();
        System.assert(controller.listWrapperCase.size()==1);
        selectAll(controller);
        controller.triggerSidraLiteAction();

        for (SIDRAliteMassActionController.WrapperCase result: controller.listWrapperCase) {
            System.assert(result.getIsSuccess());
            result.getChildId();
        }

        controller.filter.getShortName();
        controller.filter.getListReasons();
        controller.getcsvContent();
        Test.stopTest();
    }

}