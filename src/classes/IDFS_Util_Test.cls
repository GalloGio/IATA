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
@isTest(SeeAllData=true)
public class IDFS_Util_Test{
    TestMethod static void WebserviceMethodsTest(){
        IDFS_Util.getIATACountryEmail('Canada');
        IDFS_Util.getIATACountryEmail('');
        IDFS_Util.getRecordTypeEmail('ProcessEuropeSCE','','');
        IDFS_Util.getRecordTypeEmail('','','');
    }

    TestMethod static void createInternalCaseTest(){
        Case cse = new Case(
            Subject = 'test',
            Region__c = 'Europe',
            BSPCountry__c = 'Switzerland',
            Reason1__c = '',
            CaseArea__c = '',
            Complaint_Analysis__c = ''
        );
        insert cse;

        Test.startTest();
        IDFS_Util.createInternalCase(cse.Id);
        Test.stopTest();

        list<Case> results = [Select Id from Case where ParentId = :cse.Id];
        System.assert(results.size() == 1);
    }


}