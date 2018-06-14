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
private class SCIMMessageEnhancerTest {

    static testMethod void test_generic_SCIMMessage() {

        Map<String,Object> inputParams = new Map<String,Object>();
        inputParams.put(SCIMUserAttributeGenerator.PARAM_FIRSTNAME, 'givenName');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_LASTNAME, 'familyName');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_EMAIL, 'email');        
        inputParams.put(SCIMUserAttributeGenerator.PARAM_USERNAME, 'userName');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_EXTERNALID, 'externalid');

        Process.PluginRequest request = new Process.PluginRequest(inputParams);

        SCIMMessageEnhancer message = new SCIMMessageEnhancer('SCIMMessageEnhancer');
        SCIMMessageEnhancer message_noConstructor = new SCIMMessageEnhancer();

        Test.startTest();
        message.enhanceMessage(request);
        Test.stopTest();
    }

    static testMethod void test_CopaMessage() {

        Map<String,Object> inputParams = new Map<String,Object>();
        inputParams.put(SCIMUserAttributeGenerator.PARAM_FIRSTNAME, 'givenName');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_LASTNAME, 'familyName');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_EMAIL, 'email');        
        inputParams.put(SCIMUserAttributeGenerator.PARAM_USERNAME, 'userName');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_EXTERNALID, 'externalid');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_ENTITLEMENT, 'COPAMessage');

        Process.PluginRequest request = new Process.PluginRequest(inputParams);

        COPASCIMMessageEnhancer cE = new COPASCIMMessageEnhancer('test');
        COPASCIMMessageEnhancer cE1 = new COPASCIMMessageEnhancer();

        Test.startTest();
        cE.enhanceMessage(request);
        Test.stopTest();
    }

    static testMethod void test_ANG_IEPSCIMMessage() {

        Map<String,Object> inputParams = new Map<String,Object>();
        inputParams.put(SCIMUserAttributeGenerator.PARAM_FIRSTNAME, 'givenName');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_LASTNAME, 'familyName');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_EMAIL, 'email');        
        inputParams.put(SCIMUserAttributeGenerator.PARAM_USERNAME, 'userName');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_EXTERNALID, 'externalid');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_ENTITLEMENT, 'COPAMessage');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_PROPERTIES, '{"language" : "EN" , "IATA Code" : "90786"}');

        Process.PluginRequest request = new Process.PluginRequest(inputParams);

        ANG_IEPSCIMMessage message = new ANG_IEPSCIMMessage('ANG_IEPSCIMMessage');
        ANG_IEPSCIMMessage message_noConstructor = new ANG_IEPSCIMMessage();

        Test.startTest();
        message.enhanceMessage(request);
        Test.stopTest();
    }
}