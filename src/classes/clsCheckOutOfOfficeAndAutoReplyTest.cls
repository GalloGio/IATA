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
private class clsCheckOutOfOfficeAndAutoReplyTest {

    static testMethod void isCaseFromAddressExcludedTest() {
        
        Case aCase = new Case();
                
        for(String excludedAddress : new String[]{'servicedesk@kaleconsultants.com','sis_servicedesk@kaleconsultants.com','sishelp@iata.org','sisoperations@iata.org','noreply@iata.org','ach@airlines.org','aia@atpco.net','ichsystems@iata.org','iinetcare@iata.org','rousselb@iata.org','Postmaster','Mailer-Deamon','No-reply'}){
        	
        	aCase.SuppliedEmail = 'sishelp@iata.org';
        	clsCheckOutOfOfficeAndAutoReply.IsFromAddressExcluded(aCase, 'SIS');
        	
        	
        }
       
        
        
        aCase.SuppliedEmail = 'toto@tito.com';
        clsCheckOutOfOfficeAndAutoReply.IsFromAddressExcluded(aCase, 'SIS');
        
    }
    
    static testMethod void isCaseSubjectExcludedTest() {
                Case aCase = new Case();
                
       
        	
        	aCase.Subject = 'FAILURE NOTICE';
        	clsCheckOutOfOfficeAndAutoReply.IsSubjectExcluded(aCase, 'SIS');
        	
        	
        
        aCase.Subject = 'WATHEVER';
        clsCheckOutOfOfficeAndAutoReply.IsSubjectExcluded(aCase, 'SIS');
      
    }
    
}