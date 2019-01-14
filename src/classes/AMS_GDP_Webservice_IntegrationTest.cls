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
private class AMS_GDP_Webservice_IntegrationTest {

	/** 
     *
     */
    static testMethod void gdpProductsAccountViewTest() {
		
		AMS_GDP_Webservice_Integration.gdpProductsAccountView('EXTERNALID', 'IATACODE', 'IATACASS', 'LOCATIONTYPE', 'LEGALNAME', 'DBA', 'EMAIL', 'WEBADDRESS', 'PC', 'LEGALTYPE', 'SOLICITATION', 'QTANAME', 'QMPNAME', 'TAXID');
    }
    
    /** 
     *
     */
    static testMethod void gdpAddressTest() {
    	
        AMS_GDP_Webservice_Integration.gdpAddress('EXTERNALID', 'ADDRESS', 'ADDRESS2', 'SUITE3', 'CITY', 'STATECODE', 'COUNTRY', 'ZIP');
    }
    
    /** 
     *
     */
    static testMethod void gdpPhoneTest() {
    	
        AMS_GDP_Webservice_Integration.gdpPhone('EXTERNALID', 'COUNTRYCODE', 'AREACODE', 'PHONENUMBER');
    }
    
    /** 
     *
     */
    static testMethod void gdsTest() {
    	
        AMS_GDP_Webservice_Integration.gds('EXTERNALID', 'RESERVATIONSYSTEM', null, null, null);
        AMS_GDP_Webservice_Integration.gds('EXTERNALID', null, 'RESERVATIONSYSTEM2', null, null);
        AMS_GDP_Webservice_Integration.gds('EXTERNALID', null, null, 'RESERVATIONSYSTEM3', null);
        AMS_GDP_Webservice_Integration.gds('EXTERNALID', null, null, null, 'RESERVATIONSYSTEM4');
    }
    
    /** 
     *
     */
    static testMethod void gdpAgencyProfileSpecializationTest() {
    
        AMS_GDP_Webservice_Integration.gdpAgencyProfileSpecialization('EXTERNALID', 'MARKETFOCUSLEISURE', 'MARKETFOCUSCOPORATE', 'TOTALANNUALSALES', 'PERCENTAIR', 'PERCENTCRUISE', 'PERCENTLAND', 'SPECIALITY1', 'SPECIALITY2', 'SPECIALITY3', 'PROFILE', 'PRINCIPALACTIVITY');
    }
    
    /** 
     *
     */    
    static testMethod void agencyOwnerTest() {
    	
        AMS_GDP_Webservice_Integration.agencyOwner('EXTERNALID', 'OWNER');
    }
    
    /** 
     *
     */
    static testMethod void accreditationTest() {

        String todayDate = system.now().format(AMS_GDP_Integration_Handler.DATE_FORMAT);
    	
        AMS_GDP_Webservice_Integration.accreditation('EXTERNALID', todayDate, todayDate, 'ORGABBR', 'STATUS', todayDate, 'ORGCLASS', todayDate);

        todayDate = 'not a date';
        AMS_GDP_Webservice_Integration.accreditation('EXTERNALID', todayDate, todayDate, 'ORGABBR', 'STATUS', todayDate, 'ORGCLASS', todayDate);
    }
    
    /** 
     *
     */
    static testMethod void accountCategoryTest() {

        AMS_GDP_Webservice_Integration.accountCategory('EXTERNALID', 'LOCATIONCAT', 'LOCATIONCAT2');

        insert new GDP_Reference_Table__c(Code__c = 'LOCATIONCA');
    	
        AMS_GDP_Webservice_Integration.accountCategory('EXTERNALID', 'LOCATIONCAT', 'LOCATIONCA');
    }
}