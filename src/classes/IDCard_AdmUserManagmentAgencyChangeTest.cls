/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class IDCard_AdmUserManagmentAgencyChangeTest {

    public static Account a;
    public static Account a2;
    public static List<Contact> cs;
    public static List<ID_Card__c> idcs;

    public static void initData() {

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c( Name = 'Australia',
                ISO_Code__c = '12',
                AIMS_Area_Name__c = 'Australia'
                                                          );
        insert isoc;
        Price_Table__c  p1 = new Price_Table__c(CurrencyIsoCode = 'CAD', ISO_Country__c = isoc.Id, Type_Class_of_Agent__c  = 'Domestic', IATA_Package__c = 10, ID_Card_Fee__c = 8);
        Price_Table__c  p2 = new Price_Table__c(CurrencyIsoCode = 'CAD', ISO_Country__c = isoc.Id , Type_Class_of_Agent__c  = 'TIDS', IATA_Package__c = 14, ID_Card_Fee__c = 9);

        Insert p1;
        Insert p2;

        Id rtacc = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Id rtcon = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');

        a = new Account(Name = 'Test Account',
                        IATACode__c = '12312312',
                        Type = 'Domestic Agent',
                        Industry = 'Cargo Agent',
                        IDCard_Key_Account__c = true,
                        RecordTypeId = rtacc,
                        BillingCountry = 'Australia',
                        Status__c = 'Approved'

                       );

        a2 = new Account(Name = 'Test Account external',
                         IATACode__c = '23423423',
                         Type = 'Domestic Agent',
                         Industry = 'Cargo Agent',
                         IDCard_Key_Account__c = true,
                         RecordTypeId = rtacc,
                         BillingCountry = 'Australia',
                         Status__c = 'Approved'

                        );
        insert a;
        insert a2;


        cs = new List<Contact>();
        for (integer i = 1; i <= 10; i++) {
            string si = (i < 10 ? '0' : '') + i;
            cs.add(new Contact(FirstName = 'Test ' + si,
                               LastName = 'Contact ' + si,
                               BirthDate = date.today().addYears(-30),
                               AccountId = a.id,
                               Phone = '+41 7777777777',
                               Email = 'test' + i + '@contact.com',
                               Date_of_birth__c = date.today().addYears(-30),
                               ID_Card_Holder__c = true,

                               VER_number_2__c = (i <= 100 ? '' + i : null),
                               UIR__c = (i <= 100 ? 'UIR' + i : null),
                               RecordTypeId = rtcon
                              ));
        }
        insert cs;


        list<Managed_agency__c> mas = new list<Managed_Agency__c>();
        mas.add(new Managed_agency__c(Contact__c = cs[0].id, Account__c = a.id));
        insert mas;

    }

    @isTest
	static void testListPage() {
        initData();
        Id rtcon = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact externalc = new Contact(FirstName = 'External',
                                        LastName = 'Cont\'act\\',
                                        BirthDate = date.today().addYears(-30),
                                        AccountId = a2.id,
                                        Phone = '+41 7777777777',
                                        Email = 'external@contact.com',
                                        Date_of_birth__c = date.today().addYears(-30),
                                        ID_Card_Holder__c = true,
                                        VER_number_2__c = '999',
                                        UIR__c = 'UIR999\\',
                                        RecordTypeId = rtcon,
                                        Start_Date_Agency_Month__c = 'January',
                                        Start_Date_Agency_Year__c = 2010,
                                        Start_Date_Industry__c = 2011,
                                        Title = 'Mr'
                                       );
        insert externalc;
        test.startTest();


        // Let's start the page
        Test.setCurrentPage(new PageReference('IDCard_AdmUserManagmentAgencyChange'));
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE, '12312312', null, -1, false));
        cookies.add(new Cookie(IDCardUtil.PARAM_VER, '1', null, -1, false));
        ApexPages.currentPage().setCookies(cookies);


        IDCard_AdmUserManagmentAgencyChangeCtrl ctrl = new IDCard_AdmUserManagmentAgencyChangeCtrl();

        // Search for an external contact with no data
        ctrl.search4Contact();
        system.assertEquals(0, ctrl.currentRecords.size());


        // Search with complete information
        ctrl.searched.VER_Number_2__c = externalc.VER_Number_2__c;
        ctrl.searched.LastName = externalc.LastName;
        ctrl.searched.Date_of_Birth__c = externalc.Date_of_Birth__c;

        ctrl.search4Contact();

        system.assertEquals(1, ctrl.currentRecords.size());

        // try to procede without selecting any contact
        ctrl.addid = externalc.VER_Number_2__c;
        ctrl.confirmContact();

        system.assertNotEquals(null, ctrl.theChosenOne);

        // try to procede without selecting any iatacode
        //ctrl.addid = externalc.VER_Number_2__c;
        ctrl.confirmContact();
        system.assertNotEquals(null, ctrl.theChosenOne);

        // try to procede with a fake iata code
        ctrl.currentRecords.get(externalc.VER_Number_2__c).newIataCode = 'fakeiatacode';
        ctrl.confirmContact();
        system.assertNotEquals(null, ctrl.theChosenOne);

        // try to procede with the same iata code
        ctrl.currentRecords.get(externalc.VER_Number_2__c).newIataCode = a2.IATAcode__c;
        ctrl.confirmContact();
        system.assertNotEquals(null, ctrl.theChosenOne);

        // try to procede without start agency month and year
        ctrl.currentRecords.get(externalc.VER_Number_2__c).newIataCode = a.IATAcode__c;
        ctrl.confirmContact();
        system.assertNotEquals(null, ctrl.theChosenOne);

        List<ID_Card_Application__c> apps = [SELECT Id FROM ID_Card_Application__c];
        system.assertEquals(0, apps.size());



        // select the external contact and proceed
        ctrl.currentRecords.get(externalc.VER_Number_2__c).startyear = '' + date.today().year();
        ctrl.currentRecords.get(externalc.VER_Number_2__c).startmonth = 'February';
        ctrl.currentRecords.get(externalc.VER_Number_2__c).title = 'Mr';
        ctrl.currentRecords.get(externalc.VER_Number_2__c).email = 'mr@idCardTest.com';
        ctrl.currentRecords.get(externalc.VER_Number_2__c).oldIATACode = '1111';

        ctrl.confirmContact();
        system.debug(LoggingLevel.error, '######### I manage ' + ctrl.keyContactAndDelegateForAccountList.keyset());
        if (ctrl.currentRecords.get(externalc.VER_Number_2__c) != null)
            system.debug(LoggingLevel.error, '######### I want to change the external from ' + ctrl.currentRecords.get(externalc.VER_Number_2__c).oldiatacode + ' to' + ctrl.currentRecords.get(externalc.VER_Number_2__c).newiatacode);


        system.assertEquals(1, ctrl.keyContactAndDelegateForAccountList.size());
        system.assert(ctrl.keyContactAndDelegateForAccountList.keyset().contains(a.IATAcode__c));
        system.assertEquals(null, ctrl.addid);
        //system.assertEquals(1,ctrl.currentRecords.size());

        apps = [SELECT Displayed_Name__c, Type_of_application__c, IATA_Code__c, Title__c, Date_of_birth__c, First_Name__c, Last_Name__c, Gender__c,
                Email_admin__c, Telephone__c, Hours_worked__c, Position_in_Current_Agency__c, Duties_in_current_Agency__c,
                Start_date_agency_month__c, Start_date_agency_year__c, Start_date_industry__c, VER_Number__c, UIR__c, Photo__c
                FROM ID_Card_Application__c];

        string cleanlastname = externalc.LastName.replaceAll('\'', ' ');
        system.assertEquals(1, apps.size());
        system.assertEquals(externalc.FirstName, apps[0].First_Name__c);
        system.assertEquals(cleanlastname, apps[0].Last_Name__c);
        system.assertEquals(externalc.FirstName + ' ' + cleanlastname, apps[0].Displayed_Name__c);
        system.assertEquals(externalc.UIR__c, apps[0].UIR__c);
        system.assertEquals('' + date.today().year(), apps[0].Start_date_agency_year__c);
        system.assertEquals('' + externalc.Start_date_industry__c, apps[0].Start_date_industry__c);
        system.assertEquals('February', apps[0].Start_date_agency_month__c);
        system.assertEquals('Replacement', apps[0].Type_of_application__c);
        system.assertEquals(a.IATACode__c, apps[0].IATA_Code__c);
        system.assertEquals(externalc.Salutation, apps[0].Title__c);
        system.assertEquals(externalc.Date_of_birth__c, apps[0].Date_of_birth__c);
        system.assertEquals('mr@idcardtest.com', apps[0].Email_admin__c);

        ctrl.complete();
        //ctrl.getImageLink();
        ctrl.cancel();

        ctrl.getChangesSize();
        ctrl.printerr('test');




    }
}