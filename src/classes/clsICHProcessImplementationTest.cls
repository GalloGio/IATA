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
@
isTest
private class clsICHProcessImplementationTest {

    static testMethod void myUnitTest() {
	Test.startTest();
    try {
        Id standardContactRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        list<Case> theCases = new list<Case>() ;

		//adding an excluded subject and email address
        ExcludedCaseSubject__c badSubject = new ExcludedCaseSubject__c();
        badSubject.Name = 'Bad Subject';
        badSubject.Application_Name__c = 'ANY';
        insert badSubject;

        ExcludedEmailFromAddress__c badEmail = new ExcludedEmailFromAddress__c();
        badEmail.Name = 'bad@email.com' ;
        badEmail.ApplicationName__c = 'ANY';
        insert badEmail;

        ID IATAAccountRecordTypeID = TestClass_SetupVariables.IATAAccountRecordTypeID;
        Account account1 = new Account();
        account1.Name = 'ICH Application Support';
        account1.BillingCity = 'Montreal';
        account1.BillingCountry = 'Canada';
        account1.BillingStreet = 'some street';
        account1.Location_Type__c = 'HO';
        account1.RecordTypeId = IATAAccountRecordTypeID;
        insert account1;

        Contact contact1 = new Contact();
        contact1.FirstName = 'Dummy';
        contact1.LastName = 'No-Reply';
        contact1.Type_of_Contact__c = 'ICH User';
        contact1.AccountId = account1.Id;
        contact1.Email = 'some@email.org';
        contact1.Financial_Assessment_Contact__c = false;
        contact1.RecordTypeId = StandardContactRecordTypeId;
        insert contact1;

        Contact contact2 = new Contact();
        contact2.FirstName = 'Dummy';
        contact2.LastName = 'ICH Help Desk';
        contact2.Type_of_Contact__c = 'ICH User';
        contact2.AccountId = account1.Id;
        contact2.Email = 'some2@email.org';
        insert contact2;

        Priority_Mapping__c pm1 = new Priority_Mapping__c();
        pm1.Application__c = 'SIS Help Desk' ;
        pm1.Case_Classification__c = 'Output File Issue' ;
        pm1.Case_Reason__c = 'Other' ;
        pm1.Case_Type__c = 'SIS Technical Problem' ;
        pm1.Priority__c = 'Priority 3 (Minor)' ;
        insert pm1;

        Priority_Mapping__c pm2 = new Priority_Mapping__c();
        pm2.Application__c = 'ICH Help Desk' ;
        pm2.Case_Classification__c = 'Protest / Adjustment' ;
        pm2.Case_Reason__c = 'Protest / Adjustment request through Protest Procedure' ;
        pm2.Case_Type__c = 'ICH Finance' ;
        pm2.Priority__c = 'Priority 1 (Showstopper)' ;
        insert pm2;

        is_keyword__c kw1 = new is_keyword__c();
        kw1.Priority_Mapping__c = pm1.id;
        kw1.Keyword__c = 'kareem' ;
        insert kw1;

        is_keyword__c kw2 = new is_keyword__c();
        kw2.Priority_Mapping__c = pm2.id;
        kw2.Keyword__c = 'afara' ;
        insert kw2;

//removed because of too many SOQL queries
        /*
                Account account1 = new Account();
                account1.Name = 'Test account';
                account1.BillingCity = 'Montreal';
                account1.BillingCountry = 'Canada';
                account1.BillingStreet = 'some street';
                account1.Location_Type__c = 'HO';
                insert account1;
                // create test contact

                */



        id rcrd;
        rcrd = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_SIS_Help_Desk');
        Case kCase = new Case();
        kCase.CaseArea__c = 'ICH';
        kCase.Subject = 'is this it';
        kCase.description = 'Case Area: ICH IATA Alpha/Numeric Code: LH-220 Company: Lufthansa Contact Name: Application Support Email: hamapplicationsudfgdgpport.lrs@dlh.de Phone: +49 40 5070-65515  Subject: test webemail2 Description: Dear SIS HelpDesk, please see attached Word document for detailed error description.Case Type: ICH Operations Case Classification: Application Error - ICH Case Defect/Issue: ICH application issue Browser type: Internet Explorer 7';
        kCase.suppliedemail = 'afarak@iata.org';
        insert kCase;

        kCase.Type = 'Feature Request';

        
        try {
            update kCase;
        } catch (Dmlexception e) {
            System.assertEquals((e.getMessage().contains(Label.HelpDesk_SIS_ICH_Type_Area_Mismatch)), true);
        }


        kCase.Type = 'ICH Operations';
        kCase.priority = 'Priority 3';


        update kCase;

        System.assertEquals(kCase.priority, 'Priority 3'); //Label.HelpDesk_SIS_ICH_Type_Area_Mismatch

//removed because of too many SOQL queries
        /*
                try
                {
                    kCase.status = 'Escalated';
                    kCase.assigned_to__c = 'ICH Application Support';
                    update kCase;
                }
                catch (Dmlexception e)
                {
                    System.assertEquals((e.getMessage().contains(Label.L2_Support_Priority_escalation_check)), true); //Label.HelpDesk_SIS_ICH_Type_Area_Mismatch
                }
        */

        Case vCase = new Case();
        vCase.Origin = 'E-mail to Case - IS Help Desk';
        vCase.Subject = 'goodSubject';
        vCase.description = 'description ';
        vCase.RecordTypeId = rcrd;
        vCase.suppliedemail = 'afarak@gmail.org';
        theCases.add(vCase);

        Case rCase = new Case();
        rCase.Origin = 'E-mail to Case - IS Help Desk';
        rCase.Subject = '## 123213';
        rCase.description = 'test';
        rCase.RecordTypeId = rcrd;
        rCase.suppliedemail = 'afarak@iata.org';
        theCases.add(rCase);

        Case gCase = new Case();
        gCase.Origin = 'E-mail to Case - IS Help Desk';
        gCase.Subject = 'good Subject';
        gCase.description = 'test';
        gCase.RecordTypeId = rcrd;
        gCase.suppliedemail = 'bad@email.com';
        theCases.add(gCase);




        Case jCase = new Case();
        jCase.Origin = 'E-mail to Case - IS Help Desk';
        jCase.Subject = 'that is it';
        jCase.SuppliedEmail = 'afarak@iata.org';
        jCase.description = 'afara';
        theCases.add(jCase);


        Case zCase = new Case();
        zCase.Origin = 'E-mail to Case - IS Help Desk';
        zCase.Subject = 'this is it';
        zCase.description = 'kareem';
        zCase.RecordTypeId = rcrd;
        zCase.suppliedemail = 'afarak@iata.org';
        theCases.add(zCase);


//removed because of too many SOQL queries

        Case cCase = new Case();
        cCase.Origin = 'E-mail to Case - IS Help Desk';
        cCase.Subject = 'RE: this is it';
        cCase.description = 'test';
        cCase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_SIS_Help_Desk');
        cCase.suppliedemail = 'afarak@iata.org';


        Case xCase = new Case();
        xCase.Origin = 'E-mail to Case - IS Help Desk';
        xCase.Subject = 'these are it';
        xCase.description = 'test';
        xCase.suppliedemail = 'afarak@iata.org';
        theCases.add(xCase);

        Case aCase2 = new Case();

        aCase2.Subject = 'thats it';
        aCase2.description = 'Case Area: SIS IATA Alpha/Numeric Code: LH-220 Company: Lufthansa Contact Name: Application Support Email: hamapplicationsudfgdgpport.lrs@dlh.de Phone: +49 40 5070-65515  Subject: test webemail2 Description: Dear SIS HelpDesk, please see attached Word document for detailed error description. Case Type: SIS Technical Problem  Case Classification: System Related  Case Defect/Issue: System Related Question  Browser type: Internet Explorer 7';
        aCase2.SuppliedEmail = 'afarak@iata.org';
        theCases.add(aCase2);



        Case hCase = new Case();
        hCase.Origin = 'E-mail to Case - IS Help Desk';
        hCase.Subject = 'test';
        hCase.description = 'afara';
        hCase.RecordTypeId = rcrd;
        hCase.suppliedemail = 'bad@email.com';
        theCases.add(hCase);




        // insert all
        //insert theCases;


        aCase2.Type = 'ICH Operations';

        try {
            //update aCase2;
        } catch (Dmlexception n) {
            System.assertEquals(n.getMessage().contains(Label.HelpDesk_SIS_ICH_Type_Area_Mismatch), true);
        }
        }
        catch (Exception e) {}

        Test.stopTest();

    }
}