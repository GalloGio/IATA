@isTest
public class IDCard_RenewalWebServiceTest
{
    private static IDCardTestData testData;
    private static Contact contact = null;

    @TestSetup
    public static void makeData()
    {
        CanadianTax__c tax = new CanadianTax__c();
        tax.Name = 'Tx';
        tax.Tax_Name__c = 'Tx';
        tax.Tax_Percentage__c = 10.000;
        tax.Country__c = 'CANADA';
        tax.Province__c = null;
        insert tax;
        tax = new CanadianTax__c();
        tax.Name = 'Tx2';
        tax.Tax_Name__c = 'Tx2';
        tax.Tax_Percentage__c = 5.000;
        tax.Country__c = 'CANADA';
        tax.Province__c = null;
        insert tax;
    }

    @isTest
    public static void testValidRequest_RenewalOnNewCard()
    {
        testValidRequest_RenewalOnNewCard(true);
    }

    private static void testValidRequest_RenewalOnNewCard(Boolean isTest)
    {
        RestResponse response = new RestResponse();
        RestContext.response = response;

        String typeOfCard = IDCard_MobileAppRenewalService.CARD_TYPE_PLASTIC;
        String pCode = null;

        RestRequest request = new RestRequest();
        request.params.put('iataCode', '67504242');
        request.params.put('verNumber', '5990000001');
        request.requestBody = Blob.valueOf(makeJson(pCode, typeOfCard, true, true, true, 2, true));
        RestContext.request = request;

        setNewCard(false, false, null);

        if (isTest)
        {
            Test.startTest();
            IDCard_RenewalWebService.doPost();
            Test.stopTest();
        }
        else
        {
            IDCard_RenewalWebService.doPost();
        }

        Object actualResponse = getResponse(response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>, 'Value: ' + actualResponse);   
        
        Map<String, Object> mapResponse = (Map<String, Object>) actualResponse;
        System.assert(String.isNotBlank((String)mapResponse.get('caseId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('caseNumber')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardApplicationId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('uir')), mapResponse);

        Id caseId = (Id) mapResponse.get('caseId');
        String caseNumber = (String) mapResponse.get('caseNumber');
        Id idCardApplicationId = (Id) mapResponse.get('idCardApplicationId');
        Id idCardId = (Id) mapResponse.get('idCardId');
        String uit = (String) mapResponse.get('uir');

        // validate case
        Case c = getCase(caseId);
        validateCase(c, caseNumber, idCardApplicationId, false, typeOfCard, false, ! isTest);

        // validate application
        ID_Card_Application__c app = getCardApplication(idCardApplicationId);
        validateApplication(app, uit, typeOfCard, pCode, true, 2, false, false, ! isTest, true);
        validatePayment(app, pCode, true, true, true, true, false);
        validateSpecializationFields(app, true);

        // validate id card
        ID_Card__c card = getCard(idCardId);
        validateCard(card, app, contact, true, false, null, false, false);
        validateCardPrinting(card, typeOfCard, true);
        validateSpecializationFields(card, true, true);
    }

    @isTest
    public static void testValidRequest_RenewalOnRenewedCard()
    {
        RestResponse response = new RestResponse();
        RestContext.response = response;

        String typeOfCard = IDCard_MobileAppRenewalService.CARD_TYPE_PLASTIC;
        String pCode = null;

        RestRequest request = new RestRequest();
        request.params.put('iataCode', '67504242');
        request.params.put('verNumber', '5990000001');
        request.requestBody = Blob.valueOf(makeJson(pCode, typeOfCard, true, true, true, 2, true));
        RestContext.request = request;

        setNewCard(false, false, null);
        setRenewalCard(false);

        Test.startTest();
        IDCard_RenewalWebService.doPost();
        Test.stopTest();

        List<Id_Card__c> idCards = [SELECT Id, Valid_To_Date__c, Valid_From_Date__c
                                    FROM Id_Card__c
                                    ORDER BY Valid_To_Date__c ASC, Valid_From_Date__c ASC];
        System.assertEquals(3, idCards.size());

        System.assertEquals(System.now().date().addMonths(0), idCards.get(0).Valid_From_Date__c);
        System.assertEquals(System.now().date().addMonths(12), idCards.get(0).Valid_To_Date__c);
        System.assertEquals(System.now().date().addMonths(12), idCards.get(1).Valid_From_Date__c);
        System.assertEquals(System.now().date().addMonths(24), idCards.get(1).Valid_To_Date__c);
        System.assertEquals(System.now().date().addMonths(12), idCards.get(2).Valid_From_Date__c); // the dates are the same because they are
        System.assertEquals(System.now().date().addMonths(24), idCards.get(2).Valid_To_Date__c); // calculated from the active card "get(0)"

        Object actualResponse = getResponse(response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>, 'Value: ' + actualResponse);   
        
        Map<String, Object> mapResponse = (Map<String, Object>) actualResponse;
        System.assert(String.isNotBlank((String)mapResponse.get('caseId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('caseNumber')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardApplicationId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('uir')), mapResponse);

        Id caseId = (Id) mapResponse.get('caseId');
        String caseNumber = (String) mapResponse.get('caseNumber');
        Id idCardApplicationId = (Id) mapResponse.get('idCardApplicationId');
        Id idCardId = (Id) mapResponse.get('idCardId');
        String uit = (String) mapResponse.get('uir');

        // validate case
        Case c = getCase(caseId);
        validateCase(c, caseNumber, idCardApplicationId, false, typeOfCard, false, false);

        // validate application
        ID_Card_Application__c app = getCardApplication(idCardApplicationId);
        validateApplication(app, uit, typeOfCard, pCode, true, 2, false, false, false, true);
        validatePayment(app, pCode, true, true, true, true, false);
        validateSpecializationFields(app, true);

        // validate id card
        ID_Card__c card = getCard(idCardId);
        validateCard(card, app, contact, true, false, null, false, false);
        validateCardPrinting(card, typeOfCard, true);
        validateSpecializationFields(card, true, true);
    }

    @isTest
    public static void testValidRequest_RenewalOnRenewedCardFromApp()
    {
        String typeOfCard = IDCard_MobileAppRenewalService.CARD_TYPE_PLASTIC;
        String pCode = null;

        // first renewal
        Test.startTest();
        testValidRequest_RenewalOnNewCard(false);
        Test.stopTest();

        // plastic card - close case to allow the second renewal
        List<Case> cases = [SELECT Id FROM Case];
        cases.get(0).Status = 'Closed';
        update cases.get(0);

        // change the renewal IDCA created on the previous step to be able to check that it was used
        List<ID_Card_Application__c> apps = [SELECT Id FROM ID_Card_Application__c ORDER BY Name DESC];
        apps.get(0).Telephone__c = '5145550002';
        update apps.get(0);

        // second renewal
        IDCard_RenewalWebService.doPost();

        Object actualResponse = getResponse(RestContext.response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>, 'Value: ' + actualResponse);   
        
        Map<String, Object> mapResponse = (Map<String, Object>) actualResponse;
        System.assert(String.isNotBlank((String)mapResponse.get('caseId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('caseNumber')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardApplicationId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('uir')), mapResponse);

        Id caseId = (Id) mapResponse.get('caseId');
        String caseNumber = (String) mapResponse.get('caseNumber');
        Id idCardApplicationId = (Id) mapResponse.get('idCardApplicationId');
        Id idCardId = (Id) mapResponse.get('idCardId');
        String uit = (String) mapResponse.get('uir');

        // validate case
        Case c = getCase(caseId);
        validateCase(c, caseNumber, idCardApplicationId, false, typeOfCard, false, true);

        // validate application
        ID_Card_Application__c app = getCardApplication(idCardApplicationId);
        validateApplication(app, uit, typeOfCard, pCode, true, 2, false, false, true, true);
        validatePayment(app, pCode, true, true, true, true, false);
        validateSpecializationFields(app, true);

        // validate id card
        ID_Card__c card = getCard(idCardId);
        validateCard(card, app, contact, true, false, null, true, false);
        validateCardPrinting(card, typeOfCard, true);
        validateSpecializationFields(card, true, true);
    }

    @isTest
    public static void testValidRequest_ExistingCase()
    {
        String typeOfCard = IDCard_MobileAppRenewalService.CARD_TYPE_PLASTIC;
        String pCode = null;

        // first renewal
        Test.startTest();
        testValidRequest_RenewalOnNewCard(false);
        Test.stopTest();

        // plastic card - close case to allow the second renewal
        List<Case> cases = [SELECT Id, CaseNumber FROM Case];
		String caseId = cases.get(0).CaseNumber;

        // second renewal
        IDCard_RenewalWebService.doPost();

        Object actualResponse = getResponse(RestContext.response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>);
        String message = (String) ((Map<String, Object>) actualResponse).get('message');
        System.assertEquals('Sorry, there was a problem with the ID Card renewal process due to an existing pending application case [' + caseId + ']. Please contact us for details', message, actualResponse); 
    }

    @isTest
    public static void testValidRequest_TwoRenewalsFromDifferentClients()
    {
        // first client
        Test.startTest();
        testValidRequest_RenewalOnNewCard(false);
        Test.stopTest();

        // second client
        String typeOfCard = IDCard_MobileAppRenewalService.CARD_TYPE_PLASTIC;
        String pCode = null;

        RestContext.request.params.put('iataCode', '85500100');
        RestContext.request.params.put('verNumber', '5990000002');

        setAlternateNewCard();

        IDCard_RenewalWebService.doPost();

        Object actualResponse = getResponse(RestContext.response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>, 'Value: ' + actualResponse);   
        
        Map<String, Object> mapResponse = (Map<String, Object>) actualResponse;
        System.assert(String.isNotBlank((String)mapResponse.get('caseId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('caseNumber')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardApplicationId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('uir')), mapResponse);

        Id caseId = (Id) mapResponse.get('caseId');
        String caseNumber = (String) mapResponse.get('caseNumber');
        Id idCardApplicationId = (Id) mapResponse.get('idCardApplicationId');
        Id idCardId = (Id) mapResponse.get('idCardId');
        String uit = (String) mapResponse.get('uir');

        // validate case
        Case c = getCase(caseId);
        validateCase(c, caseNumber, idCardApplicationId, false, typeOfCard, true, true);

        // validate application
        ID_Card_Application__c app = getCardApplication(idCardApplicationId);
        validateApplication(app, uit, typeOfCard, pCode, true, 2, false, true, true, true);
        validatePayment(app, pCode, true, true, true, true, false);
        validateSpecializationFields(app, true);

        // validate id card
        ID_Card__c card = getCard(idCardId);
        validateCard(card, app, contact, true, false, null, false, true);
        validateCardPrinting(card, typeOfCard, true);
        validateSpecializationFields(card, true, true);
    }

    @isTest
    public static void testValidRequest_DigitalCard()
    {
        RestResponse response = new RestResponse();
        RestContext.response = response;

        String typeOfCard = IDCard_MobileAppRenewalService.CARD_TYPE_DIGITAL;
        String pCode = null;

        RestRequest request = new RestRequest();
        request.params.put('iataCode', '67504242');
        request.params.put('verNumber', '5990000001');
        request.requestBody = Blob.valueOf(makeJson(pCode, typeOfCard, true, true, false, 2, true));
        RestContext.request = request;

        setNewCard(false, false, null);

        Test.startTest();
        IDCard_RenewalWebService.doPost();
        Test.stopTest();

        Object actualResponse = getResponse(response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>, 'Value: ' + actualResponse);   
        
        Map<String, Object> mapResponse = (Map<String, Object>) actualResponse;
        System.assert(String.isNotBlank((String)mapResponse.get('caseId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('caseNumber')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardApplicationId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('uir')), mapResponse);

        Id caseId = (Id) mapResponse.get('caseId');
        String caseNumber = (String) mapResponse.get('caseNumber');
        Id idCardApplicationId = (Id) mapResponse.get('idCardApplicationId');
        Id idCardId = (Id) mapResponse.get('idCardId');
        String uit = (String) mapResponse.get('uir');

        // validate case
        Case c = getCase(caseId);
        validateCase(c, caseNumber, idCardApplicationId, false, typeOfCard, false, false);

        // validate application
        ID_Card_Application__c app = getCardApplication(idCardApplicationId);
        validateApplication(app, uit, typeOfCard, pCode, true, 2, false, false, false, false);
        validatePayment(app, pCode, true, false, true, true, false);
        validateSpecializationFields(app, true);

        // validate id card
        ID_Card__c card = getCard(idCardId);
        validateCard(card, app, contact, true, false, null, false, false);
        validateCardPrinting(card, typeOfCard, false);
        validateSpecializationFields(card, true, true);
    }

    @isTest
    public static void testValidRequest_WithPromotion()
    {
        RestResponse response = new RestResponse();
        RestContext.response = response;

        String typeOfCard = IDCard_MobileAppRenewalService.CARD_TYPE_DIGITAL;
        String pCode = 'PCODE';

        RestRequest request = new RestRequest();
        request.params.put('iataCode', '67504242');
        request.params.put('verNumber', '5990000001');
        request.requestBody = Blob.valueOf(makeJson(pCode, typeOfCard, true, true, false, 2, true));
        RestContext.request = request;

        setNewCard(false, false, null);
        setPromotion(pCode, 30);

        Test.startTest();
        IDCard_RenewalWebService.doPost();
        Test.stopTest();

        Object actualResponse = getResponse(response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>, 'Value: ' + actualResponse);   
        
        Map<String, Object> mapResponse = (Map<String, Object>) actualResponse;
        System.assert(String.isNotBlank((String)mapResponse.get('caseId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('caseNumber')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardApplicationId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('uir')), mapResponse);

        Id caseId = (Id) mapResponse.get('caseId');
        String caseNumber = (String) mapResponse.get('caseNumber');
        Id idCardApplicationId = (Id) mapResponse.get('idCardApplicationId');
        Id idCardId = (Id) mapResponse.get('idCardId');
        String uit = (String) mapResponse.get('uir');

        // validate case
        Case c = getCase(caseId);
        validateCase(c, caseNumber, idCardApplicationId, false, typeOfCard, false, false);

        // validate application
        ID_Card_Application__c app = getCardApplication(idCardApplicationId);
        validateApplication(app, uit, typeOfCard, pCode, true, 2, false, false, false, false);
        validatePayment(app, pCode, true, false, true, true, false);
        validateSpecializationFields(app, true);

        // validate id card
        ID_Card__c card = getCard(idCardId);
        validateCard(card, app, contact, true, false, null, false, false);
        validateCardPrinting(card, typeOfCard, false);
        validateSpecializationFields(card, true, true);
    }

    @isTest
    public static void testValidRequest_Promotion100Percent()
    {
        RestResponse response = new RestResponse();
        RestContext.response = response;

        String typeOfCard = IDCard_MobileAppRenewalService.CARD_TYPE_DIGITAL;
        String pCode = 'PCODE';

        RestRequest request = new RestRequest();
        request.params.put('iataCode', '67504242');
        request.params.put('verNumber', '5990000001');
        request.requestBody = Blob.valueOf(makeJson(pCode, typeOfCard, true, true, false, 2, false));
        RestContext.request = request;

        setNewCard(false, false, null);
        setPromotion(pCode, 30);

        Test.startTest();
        IDCard_RenewalWebService.doPost();
        Test.stopTest();

        Object actualResponse = getResponse(response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>, 'Value: ' + actualResponse);   
        
        Map<String, Object> mapResponse = (Map<String, Object>) actualResponse;
        System.assert(String.isNotBlank((String)mapResponse.get('caseId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('caseNumber')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardApplicationId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('uir')), mapResponse);

        Id caseId = (Id) mapResponse.get('caseId');
        String caseNumber = (String) mapResponse.get('caseNumber');
        Id idCardApplicationId = (Id) mapResponse.get('idCardApplicationId');
        Id idCardId = (Id) mapResponse.get('idCardId');
        String uit = (String) mapResponse.get('uir');

        // validate case
        Case c = getCase(caseId);
        validateCase(c, caseNumber, idCardApplicationId, false, typeOfCard, false, false);

        // validate application
        ID_Card_Application__c app = getCardApplication(idCardApplicationId);
        validateApplication(app, uit, typeOfCard, pCode, false, 2, false, false, false, false);
        validatePayment(app, pCode, true, false, true, false, false);
        validateSpecializationFields(app, true);

        // validate id card
        ID_Card__c card = getCard(idCardId);
        validateCard(card, app, contact, false, false, null, false, false);
        validateCardPrinting(card, typeOfCard, false);
        validateSpecializationFields(card, true, true);
    }

    @isTest
    public static void testValidRequest_JustRenewalOfCard()
    {
        RestResponse response = new RestResponse();
        RestContext.response = response;

        String typeOfCard = IDCard_MobileAppRenewalService.CARD_TYPE_DIGITAL;
        String pCode = 'PCODE';

        RestRequest request = new RestRequest();
        request.params.put('iataCode', '67504242');
        request.params.put('verNumber', '5990000001');
        request.requestBody = Blob.valueOf(makeJson(pCode, typeOfCard, true, false, false, 0, false));
        RestContext.request = request;

        setNewCard(false, false, null);
        setPromotion(pCode, 30);

        Test.startTest();
        IDCard_RenewalWebService.doPost();
        Test.stopTest();

        Object actualResponse = getResponse(response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>, 'Value: ' + actualResponse);   
        
        Map<String, Object> mapResponse = (Map<String, Object>) actualResponse;
        System.assert(String.isNotBlank((String)mapResponse.get('caseId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('caseNumber')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardApplicationId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('uir')), mapResponse);

        Id caseId = (Id) mapResponse.get('caseId');
        String caseNumber = (String) mapResponse.get('caseNumber');
        Id idCardApplicationId = (Id) mapResponse.get('idCardApplicationId');
        Id idCardId = (Id) mapResponse.get('idCardId');
        String uit = (String) mapResponse.get('uir');

        // validate case
        Case c = getCase(caseId);
        validateCase(c, caseNumber, idCardApplicationId, false, typeOfCard, false, false);

        // validate application
        ID_Card_Application__c app = getCardApplication(idCardApplicationId);
        validateApplication(app, uit, typeOfCard, pCode, false, 0, false, false, false, false);
        validatePayment(app, pCode, false, false, false, false, false);
        validateSpecializationFields(app, true);

        // validate id card
        ID_Card__c card = getCard(idCardId);
        validateCard(card, app, contact, false, false, null, false, false);
        validateCardPrinting(card, typeOfCard, false);
        validateSpecializationFields(card, true, true);
    }

    @isTest
    public static void testValidRequest_WithoutCourses()
    {
        RestResponse response = new RestResponse();
        RestContext.response = response;

        String typeOfCard = IDCard_MobileAppRenewalService.CARD_TYPE_PLASTIC;
        String pCode = 'PCODE';

        RestRequest request = new RestRequest();
        request.params.put('iataCode', '67504242');
        request.params.put('verNumber', '5990000001');
        request.requestBody = Blob.valueOf(makeJson(pCode, typeOfCard, true, true, true, 0, true));
        RestContext.request = request;

        setNewCard(false, false, null);
        setPromotion(pCode, 30);

        Test.startTest();
        IDCard_RenewalWebService.doPost();
        Test.stopTest();

        Object actualResponse = getResponse(response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>, 'Value: ' + actualResponse);   
        
        Map<String, Object> mapResponse = (Map<String, Object>) actualResponse;
        System.assert(String.isNotBlank((String)mapResponse.get('caseId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('caseNumber')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardApplicationId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('uir')), mapResponse);

        Id caseId = (Id) mapResponse.get('caseId');
        String caseNumber = (String) mapResponse.get('caseNumber');
        Id idCardApplicationId = (Id) mapResponse.get('idCardApplicationId');
        Id idCardId = (Id) mapResponse.get('idCardId');
        String uit = (String) mapResponse.get('uir');

        // validate case
        Case c = getCase(caseId);
        validateCase(c, caseNumber, idCardApplicationId, false, typeOfCard, false, false);

        // validate application
        ID_Card_Application__c app = getCardApplication(idCardApplicationId);
        validateApplication(app, uit, typeOfCard, pCode, false, 0, false, false, false, true);
        validatePayment(app, pCode, true, true, false, true, false);
        validateSpecializationFields(app, true);

        // validate id card
        ID_Card__c card = getCard(idCardId);
        validateCard(card, app, contact, true, false, null, false, false);
        validateCardPrinting(card, typeOfCard, true);
        validateSpecializationFields(card, true, true);
    }

    @isTest
    public static void testValidRequest_WithOnlyOneCourse()
    {
        RestResponse response = new RestResponse();
        RestContext.response = response;

        String typeOfCard = IDCard_MobileAppRenewalService.CARD_TYPE_PLASTIC;
        String pCode = null;

        RestRequest request = new RestRequest();
        request.params.put('iataCode', '67504242');
        request.params.put('verNumber', '5990000001');
        request.requestBody = Blob.valueOf(makeJson(pCode, typeOfCard, true, true, true, 1, true));
        RestContext.request = request;

        setNewCard(false, false, null);

        Test.startTest();
        IDCard_RenewalWebService.doPost();
        Test.stopTest();

        Object actualResponse = getResponse(response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>, 'Value: ' + actualResponse);   
        
        Map<String, Object> mapResponse = (Map<String, Object>) actualResponse;
        System.assert(String.isNotBlank((String)mapResponse.get('caseId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('caseNumber')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardApplicationId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('uir')), mapResponse);

        Id caseId = (Id) mapResponse.get('caseId');
        String caseNumber = (String) mapResponse.get('caseNumber');
        Id idCardApplicationId = (Id) mapResponse.get('idCardApplicationId');
        Id idCardId = (Id) mapResponse.get('idCardId');
        String uit = (String) mapResponse.get('uir');

        // validate case
        Case c = getCase(caseId);
        validateCase(c, caseNumber, idCardApplicationId, false, typeOfCard, false, false);

        // validate application
        ID_Card_Application__c app = getCardApplication(idCardApplicationId);
        validateApplication(app, uit, typeOfCard, pCode, true, 1, false, false, false, true);
        validatePayment(app, pCode, true, true, true, true, false);
        validateSpecializationFields(app, true);

        // validate id card
        ID_Card__c card = getCard(idCardId);
        validateCard(card, app, contact, true, false, null, false, false);
        validateCardPrinting(card, typeOfCard, true);
        validateSpecializationFields(card, true, true);
    }

    @isTest
    public static void testValidRequest_WithoutSpecializationOnRequestButOnLastCard()
    {
        RestResponse response = new RestResponse();
        RestContext.response = response;

        String typeOfCard = IDCard_MobileAppRenewalService.CARD_TYPE_PLASTIC;
        String pCode = null;

        RestRequest request = new RestRequest();
        request.params.put('iataCode', '67504242');
        request.params.put('verNumber', '5990000001');
        request.requestBody = Blob.valueOf(makeJson(pCode, typeOfCard, false, true, true, 2, true));
        RestContext.request = request;

        setNewCard(true, false, null);

        Test.startTest();
        IDCard_RenewalWebService.doPost();
        Test.stopTest();

        Object actualResponse = getResponse(response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>, 'Value: ' + actualResponse);   
        
        Map<String, Object> mapResponse = (Map<String, Object>) actualResponse;
        System.assert(String.isNotBlank((String)mapResponse.get('caseId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('caseNumber')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardApplicationId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('uir')), mapResponse);

        Id caseId = (Id) mapResponse.get('caseId');
        String caseNumber = (String) mapResponse.get('caseNumber');
        Id idCardApplicationId = (Id) mapResponse.get('idCardApplicationId');
        Id idCardId = (Id) mapResponse.get('idCardId');
        String uit = (String) mapResponse.get('uir');

        // validate case
        Case c = getCase(caseId);
        validateCase(c, caseNumber, idCardApplicationId, false, typeOfCard, false, false);

        // validate application
        ID_Card_Application__c app = getCardApplication(idCardApplicationId);
        validateApplication(app, uit, typeOfCard, pCode, true, 2, false, false, false, true);
        validatePayment(app, pCode, true, true, true, true, false);
        validateSpecializationFields(app, false);

        // validate id card
        ID_Card__c card = getCard(idCardId);
        validateCard(card, app, contact, true, false, null, false, false);
        validateCardPrinting(card, typeOfCard, true);
        validateSpecializationFields(card, true, false);
    }

    @isTest
    public static void testValidRequest_WithoutSpecializationOnRequestAndLastCard()
    {
        RestResponse response = new RestResponse();
        RestContext.response = response;

        String typeOfCard = IDCard_MobileAppRenewalService.CARD_TYPE_PLASTIC;
        String pCode = null;

        RestRequest request = new RestRequest();
        request.params.put('iataCode', '67504242');
        request.params.put('verNumber', '5990000001');
        request.requestBody = Blob.valueOf(makeJson(pCode, typeOfCard, false, true, true, 2, true));
        RestContext.request = request;

        setNewCard(false, false, null);

        Test.startTest();
        IDCard_RenewalWebService.doPost();
        Test.stopTest();

        Object actualResponse = getResponse(response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>, 'Value: ' + actualResponse);   
        
        Map<String, Object> mapResponse = (Map<String, Object>) actualResponse;
        System.assert(String.isNotBlank((String)mapResponse.get('caseId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('caseNumber')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardApplicationId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('uir')), mapResponse);

        Id caseId = (Id) mapResponse.get('caseId');
        String caseNumber = (String) mapResponse.get('caseNumber');
        Id idCardApplicationId = (Id) mapResponse.get('idCardApplicationId');
        Id idCardId = (Id) mapResponse.get('idCardId');
        String uit = (String) mapResponse.get('uir');

        // validate case
        Case c = getCase(caseId);
        validateCase(c, caseNumber, idCardApplicationId, false, typeOfCard, false, false);

        // validate application
        ID_Card_Application__c app = getCardApplication(idCardApplicationId);
        validateApplication(app, uit, typeOfCard, pCode, true, 2, false, false, false, true);
        validatePayment(app, pCode, true, true, true, true, false);
        validateSpecializationFields(app, false);

        // validate id card
        ID_Card__c card = getCard(idCardId);
        validateCard(card, app, contact, true, false, null, false, false);
        validateCardPrinting(card, typeOfCard, true);
        validateSpecializationFields(card, false, true);
    }
    
    @isTest
    public static void testValidRequest_USAgent()
    {
        RestResponse response = new RestResponse();
        RestContext.response = response;

        String typeOfCard = IDCard_MobileAppRenewalService.CARD_TYPE_PLASTIC;
        String pCode = null;

        RestRequest request = new RestRequest();
        request.params.put('iataCode', '67504242');
        request.params.put('verNumber', '5991000001');
        request.requestBody = Blob.valueOf(makeJson(pCode, typeOfCard, true, true, true, 2, true));
        RestContext.request = request;

        setNewCard(false, true, null);

        Test.startTest();
        IDCard_RenewalWebService.doPost();
        Test.stopTest();

        Object actualResponse = getResponse(response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>, 'Value: ' + actualResponse);   
        
        Map<String, Object> mapResponse = (Map<String, Object>) actualResponse;
        System.assert(String.isNotBlank((String)mapResponse.get('caseId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('caseNumber')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardApplicationId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('uir')), mapResponse);

        Id caseId = (Id) mapResponse.get('caseId');
        String caseNumber = (String) mapResponse.get('caseNumber');
        Id idCardApplicationId = (Id) mapResponse.get('idCardApplicationId');
        Id idCardId = (Id) mapResponse.get('idCardId');
        String uit = (String) mapResponse.get('uir');

        // validate case
        Case c = getCase(caseId);
        validateCase(c, caseNumber, idCardApplicationId, true, IDCard_MobileAppRenewalService.CARD_TYPE_DIGITAL, false, false); // forced digital

        // validate application
        ID_Card_Application__c app = getCardApplication(idCardApplicationId);
        validateApplication(app, uit, typeOfCard, pCode, true, 2, true, false, false, true); // forced digital
        validatePayment(app, pCode, true, true, true, true, true);
        validateSpecializationFields(app, true);

        // validate id card
        ID_Card__c card = getCard(idCardId);
        validateCard(card, app, contact, true, true, null, false, false);
        validateCardPrinting(card, IDCard_MobileAppRenewalService.CARD_TYPE_DIGITAL, false); // forced digital
        validateSpecializationFields(card, true, true);

        // only one contact
        System.assertEquals(1, [SELECT Id FROM Contact].size());
    }
    
    @isTest
    public static void testValidRequest_USAgentFromIdCardWithoutContact()
    {
        RestResponse response = new RestResponse();
        RestContext.response = response;

        String typeOfCard = IDCard_MobileAppRenewalService.CARD_TYPE_PLASTIC;
        String pCode = null;

        RestRequest request = new RestRequest();
        request.params.put('iataCode', '67504242');
        request.params.put('verNumber', '5991000001');
        request.requestBody = Blob.valueOf(makeJson(pCode, typeOfCard, true, true, true, 2, true));
        RestContext.request = request;

        setNewUSAgentCard(false, 'WSKey');

        Test.startTest();
        IDCard_RenewalWebService.doPost();
        Test.stopTest();

        Object actualResponse = getResponse(response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>, 'Value: ' + actualResponse);   
        
        Map<String, Object> mapResponse = (Map<String, Object>) actualResponse;
        System.assert(String.isNotBlank((String)mapResponse.get('caseId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('caseNumber')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardApplicationId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('uir')), mapResponse);

        Id caseId = (Id) mapResponse.get('caseId');
        String caseNumber = (String) mapResponse.get('caseNumber');
        Id idCardApplicationId = (Id) mapResponse.get('idCardApplicationId');
        Id idCardId = (Id) mapResponse.get('idCardId');
        String uit = (String) mapResponse.get('uir');

        // validate case
        Case c = getCase(caseId);
        validateCase(c, caseNumber, idCardApplicationId, true, IDCard_MobileAppRenewalService.CARD_TYPE_DIGITAL, false, false); // forced digital

        // validate application
        ID_Card_Application__c app = getCardApplication(idCardApplicationId);
        validateApplication(app, uit, typeOfCard, pCode, true, 2, true, false, false, true); // forced digital
        validatePayment(app, pCode, true, true, true, true, true);
        validateSpecializationFields(app, true);

        // validate id card
        ID_Card__c card = getCard(idCardId);
        validateCard(card, app, contact, true, true, 'WSKey', false, false);
        validateCardPrinting(card, IDCard_MobileAppRenewalService.CARD_TYPE_DIGITAL, false); // forced digital
        validateSpecializationFields(card, true, true);

        // only one contact
        System.assertEquals(1, [SELECT Id FROM Contact].size());
    }
    
    @isTest
    public static void testValidRequest_USAgentFromIdCardWithContact()
    {
        RestResponse response = new RestResponse();
        RestContext.response = response;

        String typeOfCard = IDCard_MobileAppRenewalService.CARD_TYPE_PLASTIC;
        String pCode = null;

        RestRequest request = new RestRequest();
        request.params.put('iataCode', '67504242');
        request.params.put('verNumber', '5991000001');
        request.requestBody = Blob.valueOf(makeJson(pCode, typeOfCard, true, true, true, 2, true));
        RestContext.request = request;

        setNewUSAgentCard(true, 'WSKey');

        Test.startTest();
        IDCard_RenewalWebService.doPost();
        Test.stopTest();

        Object actualResponse = getResponse(response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>, 'Value: ' + actualResponse);   
        
        Map<String, Object> mapResponse = (Map<String, Object>) actualResponse;
        System.assert(String.isNotBlank((String)mapResponse.get('caseId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('caseNumber')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardApplicationId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('uir')), mapResponse);

        Id caseId = (Id) mapResponse.get('caseId');
        String caseNumber = (String) mapResponse.get('caseNumber');
        Id idCardApplicationId = (Id) mapResponse.get('idCardApplicationId');
        Id idCardId = (Id) mapResponse.get('idCardId');
        String uit = (String) mapResponse.get('uir');

        // validate case
        Case c = getCase(caseId);
        validateCase(c, caseNumber, idCardApplicationId, true, IDCard_MobileAppRenewalService.CARD_TYPE_DIGITAL, false, false); // forced digital

        // validate application
        ID_Card_Application__c app = getCardApplication(idCardApplicationId);
        validateApplication(app, uit, typeOfCard, pCode, true, 2, true, false, false, true); // forced digital
        validatePayment(app, pCode, true, true, true, true, true);
        validateSpecializationFields(app, true);

        // validate id card
        ID_Card__c card = getCard(idCardId);
        validateCard(card, app, contact, true, true, 'WSKey', false, false);
        validateCardPrinting(card, IDCard_MobileAppRenewalService.CARD_TYPE_DIGITAL, false); // forced digital
        validateSpecializationFields(card, true, true);

        // only one contact
        System.assertEquals(1, [SELECT Id FROM Contact].size());
    }
    
    @isTest
    public static void testValidRequest_USAgentFromIdCardWithoutContact_hasContactInSystem()
    {
        setData(true);

        // there is a "lost" contact in the system for the same email;
        Contact lostContact = createUSContact();
        insert lostContact;

        testValidRequest_USAgentFromIdCardWithoutContact();
    }

    @isTest
    public static void testValidRequest_USAgentFromIdCardWithoutContact_RenewalOnRenewedCardFromApp()
    {
        String typeOfCard = IDCard_MobileAppRenewalService.CARD_TYPE_PLASTIC;
        String pCode = null;

        // first renewal
        testValidRequest_USAgentFromIdCardWithoutContact();

        // plastic card - close case to allow the second renewal
        List<Case> cases = [SELECT Id FROM Case];
        cases.get(0).Status = 'Closed';
        update cases.get(0);

        // change the renewal IDCA created on the previous step to be able to check that it was used
        List<ID_Card_Application__c> apps = [SELECT Id FROM ID_Card_Application__c ORDER BY Name DESC];
        apps.get(0).Telephone__c = '5145550002';
        update apps.get(0);

        // second renewal
        IDCard_RenewalWebService.doPost();

        Object actualResponse = getResponse(RestContext.response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>, 'Value: ' + actualResponse);   
        
        Map<String, Object> mapResponse = (Map<String, Object>) actualResponse;
        System.assert(String.isNotBlank((String)mapResponse.get('caseId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('caseNumber')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardApplicationId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('uir')), mapResponse);

        Id caseId = (Id) mapResponse.get('caseId');
        String caseNumber = (String) mapResponse.get('caseNumber');
        Id idCardApplicationId = (Id) mapResponse.get('idCardApplicationId');
        Id idCardId = (Id) mapResponse.get('idCardId');
        String uit = (String) mapResponse.get('uir');

        // validate case
        Case c = getCase(caseId);
        validateCase(c, caseNumber, idCardApplicationId, true, IDCard_MobileAppRenewalService.CARD_TYPE_DIGITAL, false, true); // forced digital

        // validate application
        ID_Card_Application__c app = getCardApplication(idCardApplicationId);
        validateApplication(app, uit, typeOfCard, pCode, true, 2, true, false, true, true); // forced digital
        validatePayment(app, pCode, true, true, true, true, true);
        validateSpecializationFields(app, true);

        // validate id card
        ID_Card__c card = getCard(idCardId);
        validateCard(card, app, contact, true, true, 'WSKey', true, false);
        validateCardPrinting(card, IDCard_MobileAppRenewalService.CARD_TYPE_DIGITAL, false); // forced digital
        validateSpecializationFields(card, true, true);

        // only one contact
        System.assertEquals(1, [SELECT Id FROM Contact].size());
    }
    
    @isTest
    public static void testValidRequest_WithWebstarKey()
    {
        RestResponse response = new RestResponse();
        RestContext.response = response;

        String typeOfCard = IDCard_MobileAppRenewalService.CARD_TYPE_PLASTIC;
        String pCode = null;

        RestRequest request = new RestRequest();
        request.params.put('iataCode', '67504242');
        request.params.put('verNumber', '5990000001');
        request.requestBody = Blob.valueOf(makeJson(pCode, typeOfCard, false, true, true, 2, true));
        RestContext.request = request;

        setNewCard(false, false, 'WSKey');

        Test.startTest();
        IDCard_RenewalWebService.doPost();
        Test.stopTest();

        Object actualResponse = getResponse(response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>, 'Value: ' + actualResponse);   
        
        Map<String, Object> mapResponse = (Map<String, Object>) actualResponse;
        System.assert(String.isNotBlank((String)mapResponse.get('caseId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('caseNumber')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardApplicationId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('idCardId')), mapResponse);
        System.assert(String.isNotBlank((String)mapResponse.get('uir')), mapResponse);

        Id caseId = (Id) mapResponse.get('caseId');
        String caseNumber = (String) mapResponse.get('caseNumber');
        Id idCardApplicationId = (Id) mapResponse.get('idCardApplicationId');
        Id idCardId = (Id) mapResponse.get('idCardId');
        String uit = (String) mapResponse.get('uir');

        // validate case
        Case c = getCase(caseId);
        validateCase(c, caseNumber, idCardApplicationId, false, typeOfCard, false, false);

        // validate application
        ID_Card_Application__c app = getCardApplication(idCardApplicationId);
        validateApplication(app, uit, typeOfCard, pCode, true, 2, false, false, false, true);
        validatePayment(app, pCode, true, true, true, true, false);
        validateSpecializationFields(app, false);

        // validate id card
        ID_Card__c card = getCard(idCardId);
        validateCard(card, app, contact, true, false, 'WSKey', false, false);
        validateCardPrinting(card, typeOfCard, true);
        validateSpecializationFields(card, false, true);
    }

    @isTest
    public static void testInvalidRequest_InvalidPromotionCode()
    {
        RestResponse response = new RestResponse();
        RestContext.response = response;

        RestRequest request = new RestRequest();
        request.params.put('iataCode', '67504242');
        request.params.put('verNumber', '5990000001');
        request.requestBody = Blob.valueOf(makeJson('InvalidPromotionCode', IDCard_MobileAppRenewalService.CARD_TYPE_PLASTIC, true, true, true, 2, true));
        RestContext.request = request;

        setNewCard(false, false, null);

        Test.startTest();
        IDCard_RenewalWebService.doPost();
        Test.stopTest();

        Object actualResponse = getResponse(response);
        System.assertNotEquals(null, actualResponse);
        System.assert(actualResponse instanceof Map<String, Object>);
        String message = (String) ((Map<String, Object>) actualResponse).get('message');
        // System.DmlException: Insert failed. First exception on row 0; first error: STRING_TOO_LONG, 
        //     Promotion Code: data value too large: InvalidPromotionCode (max length=6): [Promotion_Code__c]
        System.assert(message.contains('InvalidPromotionCode'), actualResponse);
    }

    private static String makeJson(String promotionCode, String typeOfCard,
        Boolean hasSpecialization, Boolean hasPayment, Boolean hasExpedite, Integer hasCourses, Boolean hasRenewalFee)
    {
        return '{'+
		'  \"orderId\": \"some id\",'+
		'  \"created\": \"2019-07-01T12:43:55Z\",'+
		'  \"typeOfCard\": \"' + typeOfCard + '\",'+
		'  \"items\": ['+
		'	{'+
		'	  \"id\": \"RENEWAL\",'+
		'	  \"description\": \"Agent ID card renewal\",'+
		'	  \"quantity\": 1,'+
        (hasRenewalFee ? 
            '	  \"price\": 85.00'
            : '	  \"price\": 0.00') +
		'	}'+
        (hasCourses == 2 ? 
            ' , {'+
            '	  \"id\": \"TRAINING_1\",'+
            '	  \"training\": \"Intro to the BSP System & Language - EN\",'+
            '	  \"quantity\": 1,'+
            '	  \"price\": 170.00' +
            '	}'+
            ' , {'+
            '	  \"id\": \"TRAINING_2\",'+
            '	  \"training\": \"a training course\",'+
            '	  \"quantity\": 1,'+
            '	  \"price\": 0.00'+
            '	}'
            : (hasCourses == 1 ? 
                ' , {'+
                '	  \"id\": \"TRAINING_1\",'+
                '	  \"training\": \"Intro to the BSP System & Language - EN\",'+
                '	  \"quantity\": 1,'+
                '	  \"price\": 170.00' +
                '	}'
                : '')) +
        (hasExpedite ? 
            ' , {'+
            '	  \"id\": \"EXPEDITE\",'+
            '	  \"description\": \"expedited delivery charge\",'+
            '	  \"quantity\": 1,'+
            '	  \"price\": 25.00' +
		    '	}'
            : '') + // no expedite
		'  ],'+
		'  \"payment\": {'+
		'	\"promotionCode\": \"' + (promotionCode == null ? '' : promotionCode) + '\"'+
        (hasPayment ? 
		    ' , \"amount\": 280.00'+
            ' , \"date\": \"2019-08-21T102456Z\"'+
            ' , \"currency\": \"USD\"'+
            ' , \"cardNumber\": \"411111xxxxxx1111\"'+
            ' , \"transactionNumber\": \"5663830960336778804005\"'
            : '') + // no payment
        '  }' +
        (hasSpecialization ?
            ' , \"specializationFields\": {'+
            '	\"ASF_Current_Function__c\": \"AF1;AF2;AF3\",'+
            '	\"ASF_Percentage_of_Annual_Booking__c\": \"N/A\",'+
            '	\"ASF_Market_Specialization__c\": \"N/A\",'+
            '	\"ASF_Market_Specialization_Comment__c\": \"some comment\",'+
            '	\"ASF_Market_Focus__c\": \"N/A\",'+
            '	\"ASF_Specializing_on_Destination__c\": \"N/A\",'+
            '	\"ASF_Completed_Travel_Courses__c\": \"N/A\",'+
            '	\"ASF_Last_Completed_Travel_Course__c\": \"N/A\",'+
            '	\"ASF_FAM_Trips__c\": \"N/A\"'+
            '  }'
            : '' ) + // no specialization
		'}';
    }

    private static void setData(Boolean isUSAgent)
    {
        if (testData != null)
            return;
        testData = new IDCardTestData();

        // misc settings
        testData.IDCards_Price_Tables[0].Profit_Center__c = 'p1';
        testData.IDCards_Price_Tables[1].Profit_Center__c = 'p2';
        update testData.IDCards_Price_Tables;

        // change agent to US
        if (isUSAgent)
        {
            // clone account with different country
            Account a = testData.IDCard_Accounts[0].clone();
            a.BillingCountry = 'USA';
            a.Type = 'IATAN Passenger Sales Agent (USA Only)';
            // invalidate the existing account
            testData.IDCard_Accounts[0].IATACode__c = 'invalid';
            update testData.IDCard_Accounts[0];
            // switch accounts
            testData.IDCard_Accounts[0] = a;
            insert a;
        }
    }

    private static void setNewCard(Boolean setSpecializationFieldsOnIDC, Boolean isUSAgent, String webstarKey)
    {
        setData(isUSAgent);

        // id card application
        if (isUSAgent)
        {
            testData.IDCards_IDCardApplications[2].UIR__c = 'US000001';
            testData.IDCards_IDCardApplications[2].Photo__c = 'US000001.jpg';
        }
        else
        {
            testData.IDCards_IDCardApplications[2].UIR__c = 'CA000001';
            testData.IDCards_IDCardApplications[2].Photo__c = 'CA000001.jpg';
        }
        insert testData.IDCards_IDCardApplications[2];
        System.debug('Id Application: ' + testData.IDCards_IDCardApplications[2]);

        // contact
        contact = IDCardUtil.CreateContactWhenNewCardIsApproved(testData.IDCards_IDCardApplications[2]);
        System.debug('Contact: ' + contact);
        
        if (isUSAgent)
        {
            // Hammer time: update the account to be of a "valid" type
            Account a = new Account(Id = testData.IDCard_Accounts[0].Id);
            a.Type = IDCardUtil.ACCOUNT_TYPE_PASSENGER;
            update a;
        }

        // id card
        Id_Card__c idCard = IDCardUtil.CreateIDCardObjectFromApplication(testData.IDCards_IDCardApplications[2], contact);
        if (setSpecializationFieldsOnIDC)
        {
            idCard.ASF_Current_Function__c = 'AF1;AF2;AF3';
            idCard.ASF_Percentage_of_Annual_Booking__c = 'N/A';
            idCard.ASF_Market_Specialization__c = 'N/A';
            idCard.ASF_Market_Specialization_Comment__c = 'some comment from previous IDC';
            idCard.ASF_Market_Focus__c = 'N/A';
            idCard.ASF_Specializing_on_Destination__c = 'N/A';
            idCard.ASF_Completed_Travel_Courses__c = 'N/A';
            idCard.ASF_Last_Completed_Travel_Course__c = 'N/A';
            idCard.ASF_FAM_Trips__c = 'N/A';
        }

        idCard.WebStar_P00_Key__c = webstarKey;

        System.debug('Id Card: ' + idCard);
        if (isUSAgent)
            idCard.ID_Card_Application__c = null; // any previous US card don't have an IDCA
        insert idCard;

        if (isUSAgent)
        {
            // un-hammer
            Account a = new Account(Id = testData.IDCard_Accounts[0].Id);
            a.Type = 'IATAN Passenger Sales Agent (USA Only)';
            update a;
        }
    }

    private static void setAlternateNewCard()
    {
        // id card application
        testData.IDCards_IDCardApplications[5].UIR__c = 'CA000002';
        testData.IDCards_IDCardApplications[5].Photo__c = 'CA000002.jpg';
        testData.IDCards_IDCardApplications[5].IATA_Code__c = '85500100';
        testData.IDCards_IDCardApplications[5].Type_of_application__c = IDCardUtil.APPLICATIONTYPE_NEW;
        insert testData.IDCards_IDCardApplications[5];
        System.debug('Id Application: ' + testData.IDCards_IDCardApplications[5]);

        // contact
        contact = IDCardUtil.CreateContactWhenNewCardIsApproved(testData.IDCards_IDCardApplications[5]);
        System.debug('Contact: ' + contact);

        // id card
        Id_Card__c idCard = IDCardUtil.CreateIDCardObjectFromApplication(testData.IDCards_IDCardApplications[5], contact);
        System.debug('Id Card: ' + idCard);
        insert idCard;
    }

    private static void setRenewalCard(Boolean setSpecializationFieldsOnIDC)
    {
        // id card application
        testData.IDCards_IDCardApplications[5].UIR__c = 'CA000001';
        testData.IDCards_IDCardApplications[5].Photo__c = 'CA000001.jpg';
        insert testData.IDCards_IDCardApplications[5];
        System.debug('Id Application renewal: ' + testData.IDCards_IDCardApplications[5]);

        // id card
        Id_Card__c idCard = IDCardUtil.CreateIDCardObjectFromApplication(testData.IDCards_IDCardApplications[5], contact);
        if (setSpecializationFieldsOnIDC)
        {
            idCard.ASF_Current_Function__c = 'AF1;AF2;AF3';
            idCard.ASF_Percentage_of_Annual_Booking__c = 'N/A';
            idCard.ASF_Market_Specialization__c = 'N/A';
            idCard.ASF_Market_Specialization_Comment__c = 'some comment from previous IDC';
            idCard.ASF_Market_Focus__c = 'N/A';
            idCard.ASF_Specializing_on_Destination__c = 'N/A';
            idCard.ASF_Completed_Travel_Courses__c = 'N/A';
            idCard.ASF_Last_Completed_Travel_Course__c = 'N/A';
            idCard.ASF_FAM_Trips__c = 'N/A';
        }

        System.debug('Id Card renewal: ' + idCard);
        insert idCard;
    }

    private static void setNewUSAgentCard(Boolean createContact, String webstarKey)
    {
        setData(true);

        // contact
        if (createContact)
        {
            contact = createUSContact();
            insert contact;
            System.debug('Contact: ' + contact);
        }

        // id card
        Id_Card__c idCard = createUSAgentIdCard(webstarKey);
        if (createContact)
            idCard.Related_Contact__c = contact.Id;
        insert idCard;

        System.debug('US Id Card: ' + idCard);
    }

    private static void setPromotion(String promotionCode, Integer percentage)
    {
        Promotion__c promotion1 = new Promotion__c();
        promotion1.Promotion_Value__c = percentage;
        promotion1.Promotion_Duration_Valid_From__c = Date.today().addDays(-365);
        promotion1.Promotion_Duration_Valid_Up_to__c = Date.today().addDays(365);
        promotion1.Promotion_Code__c = promotionCode;
        promotion1.Type_of_Application__c = 'New;Renewal';
        insert promotion1;
    }

    private static Case getCase(Id caseId)
    {
        return [SELECT RecordTypeId, CaseNumber, Subject, Status, AccountId, Origin, Related_ID_Card_Application__c,
                    ID_Card_Status__c, CaseArea__c, Reason1__c, BSPCountry__c, Region__c
                FROM Case WHERE Id = :caseId];
    }

    private static ID_Card_Application__c getCardApplication(Id idCardApplicationId)
    {
        return [SELECT RecordTypeId, Application_Status__c, Type_of_application__c, Renewal_From_Replace__c,
                    Single_Application_Processing_Step__c, Card_Type__c, Mobile_App_Transaction_Id__c, Mobile_App_Request__c,
                    Payment_Transaction_Number__c, Payment_Amount__c, Payment_Date__c, Payment_Currency__c,
                    Payment_Type__c, Payment_Credit_Card_Number__c, IDCard_Expedite_Delivery__c, Applicable_Fee__c,
                    ID_Card_Fee__c, IDCard_Expedite_Delivery_Fee__c, ITDI_Courses_Fee__c, CurrencyIsoCode,
                    Tax_1_Name__c, Tax_1_Value__c, Tax_2_Name__c, Tax_2_Value__c, Profit_Center__c, Promotion_Code__c,
                    Package_of_Travel_Professionals_Course_1__c, Package_of_Travel_Professionals_Course_2__c,
                    ASF_Current_Function__c, ASF_Percentage_of_Annual_Booking__c, ASF_Market_Specialization__c,
                    ASF_Market_Specialization_Comment__c, ASF_Market_Focus__c, ASF_Specializing_on_Destination__c,
                    ASF_Completed_Travel_Courses__c, ASF_Last_Completed_Travel_Course__c, ASF_FAM_Trips__c,
                    UIR__c, VER_Number__c, IATA_Code__c
                FROM ID_Card_Application__c WHERE Id = :idCardApplicationId];
    }

    private static ID_Card__c getCard(Id idCardId)
    {
        return [SELECT RecordTypeId, MustSyncWithAIMS__c, Card_Status__c, Sent_to_AIMS_on__c, Received_From_AIMS__c,
                    Card_Type__c, ASF_Current_Function__c, ASF_Percentage_of_Annual_Booking__c, ASF_Market_Specialization__c,
                    ASF_Market_Specialization_Comment__c, ASF_Market_Focus__c, ASF_Specializing_on_Destination__c,
                    ASF_Completed_Travel_Courses__c, ASF_Last_Completed_Travel_Course__c, ASF_FAM_Trips__c,
                    Agency_IATA_Code__c, Agency_Name__c, Approving_Manager_s_Name__c, Approving_Manager_s_Email__c, 
                    Blacklisted__c, CurrencyIsoCode, Date_of_Birth__c, Duties__c, Email__c, Fee_Applicable__c, FirstName__c,
                    Gender__c, Hours_per_week__c, ID_Card_Application__c, Is_Expedite__c, LastName__c,
                    Middle_Initial__c, Name_on_ID_Card__c, Nature_of_ID_Card__c, Position__c, Photo__c,
                    Photo_Flag__c, Phone__c, Profit_Center__c, Paid__c, Payment_Type__c, Renewal_From_Replace__c,
                    Start_Date_Industry__c, Start_Date_Agency_Month__c, Start_Date_Agency_Year__c, Type_of_ID_Card__c,
                    Title__c, VER_Number__c, Valid_To_Date__c, Valid_From_Date__c, Card_Code__c, Related_Contact__c,
                    WebStar_P00_Key__c
                FROM ID_Card__c WHERE Id = :idCardId];
    }

    private static void validateCase(Case c, String caseNumber, Id idCardApplicationId, Boolean isUSAgent,
                                     String typeOfCard, Boolean useAlternateAccount, Boolean skipCaseStatus)
    {
        System.debug('Validating card: ' + c);

        System.assertEquals(RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Application'), c.RecordTypeId);
        System.assert(c.Subject.contains('Case for Mobile ID Card Application'));
        System.assertEquals(caseNumber, c.caseNumber);
        if (! skipCaseStatus)
        {
            if (IDCard_MobileAppRenewalService.CARD_TYPE_DIGITAL.equals(typeOfCard))
                System.assertEquals('Closed', c.Status);
            else
                System.assertEquals('Ready for production', c.Status);
        }
        if (useAlternateAccount)
            System.assertEquals(testData.IDCard_Accounts[2].Id, c.AccountId);
        else
            System.assertEquals(testData.IDCard_Accounts[0].Id, c.AccountId);
        System.assertEquals('ID Card Mobile', c.Origin);
        System.assertEquals(idCardApplicationId, c.Related_ID_Card_Application__c);
        if (! skipCaseStatus)
            System.assertEquals('Approved', c.ID_Card_Status__c);
        System.assertEquals('Accreditation', c.CaseArea__c);
        System.assertEquals('ID Card', c.Reason1__c);
        if (isUSAgent)
            System.assertEquals('USA', c.BSPCountry__c);
        else
            System.assertEquals('Canada', c.BSPCountry__c);
        System.assertEquals('Americas', c.Region__c);
    }

    private static void validateApplication(ID_Card_Application__c app, String uit, String typeOfCard, String pCode,
                                 Boolean hasPayment, Integer hasCourses, Boolean isUSAgent, Boolean useAlternateAccount,
                                 Boolean skipCaseStatus, Boolean isToPrint)
    {
        System.debug('Validating id card application: ' + app);

        System.assertEquals(RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Standard'), app.RecordTypeId);
        if (IDCard_MobileAppRenewalService.CARD_TYPE_PLASTIC.equals(typeOfCard) && ! isUSAgent)
            System.assertEquals('Processing Successfull payment', app.Application_Status__c);
        else // the IDCA status is updated on the IDC trigger when the IDC is update to the "valid" status
            System.assertEquals('Completed', app.Application_Status__c);
        System.assertEquals(IDCardUtil.APPLICATIONTYPE_RENEWAL, app.Type_of_application__c);
        System.assertEquals(false, app.Renewal_From_Replace__c);
        if (! skipCaseStatus)
            System.assertEquals('Processed', app.Single_Application_Processing_Step__c);
        System.assertEquals(typeOfCard, app.Card_Type__c);
        System.assertEquals('some id', app.Mobile_App_Transaction_Id__c);
        System.assertNotEquals(null, app.Mobile_App_Request__c);
        if (hasCourses == 2)
        {
            System.assertEquals('Intro to the BSP System & Language - EN', app.Package_of_Travel_Professionals_Course_1__c);
            System.assertEquals('a training course', app.Package_of_Travel_Professionals_Course_2__c);
        }
        else if (hasCourses == 1)
        {
            System.assertEquals('Intro to the BSP System & Language - EN', app.Package_of_Travel_Professionals_Course_1__c);
            System.assertEquals(null, app.Package_of_Travel_Professionals_Course_2__c);
        }
        else
        {
            System.assertEquals(null, app.Package_of_Travel_Professionals_Course_1__c);
            System.assertEquals(null, app.Package_of_Travel_Professionals_Course_2__c);
        }
        System.assertEquals(uit, app.UIR__c.subString(2));
        if (isUSAgent)
            System.assertEquals('5991000001', app.VER_Number__c);
        else 
            validateIf(useAlternateAccount, '5990000002', '5990000001', app.VER_Number__c);
        validateIf(useAlternateAccount, '85500100', '67504242', app.IATA_Code__c);
        System.assertEquals(isToPrint, app.IDCard_Expedite_Delivery__c);
    }

    private static void validatePayment(ID_Card_Application__c app, String pCode,
        Boolean hasPayment, Boolean hasExpedite, Boolean hasCourses, Boolean hasRenewalFee, Boolean isUSAgent)
    {
        if (hasPayment)
        {
            System.assertEquals('5663830960336778804005', app.Payment_Transaction_Number__c);
            System.assertEquals(280.00, app.Payment_Amount__c);
            System.assertEquals('21-August-2019 12:24:56 GMT', app.Payment_Date__c);
            System.assertEquals('USD', app.Payment_Currency__c);
            System.assertEquals('411111xxxxxx1111', app.Payment_Credit_Card_Number__c);
        }
        else
        {
            System.assertEquals(null, app.Payment_Transaction_Number__c);
            System.assertEquals(0.00, app.Payment_Amount__c);
            System.assertEquals(null, app.Payment_Date__c);
            System.assertEquals(null, app.Payment_Currency__c);
            System.assertEquals(null, app.Payment_Credit_Card_Number__c);
        }

        Decimal fee = ! hasPayment ? 0.00
                : (hasExpedite ? 25.00 : 0.00) + (hasCourses ? 170.00 : 0.00) + (hasRenewalFee ? 85.00 : 0.00);
        
        System.assertEquals(fee, app.Applicable_Fee__c);
        System.assertEquals((hasRenewalFee ? 85.00 : 0.00), app.ID_Card_Fee__c);
        System.assertEquals((hasExpedite ? 25.00 : 0.00), app.IDCard_Expedite_Delivery_Fee__c);
        System.assertEquals((hasCourses ? 170.00 : 0.00), app.ITDI_Courses_Fee__c);
        
        if (isUSAgent)
        {
            System.assertEquals(null, app.Tax_1_Name__c);
            System.assertEquals(null, app.Tax_2_Name__c);
            System.assertEquals(null, app.Tax_1_Value__c);
            System.assertEquals(null, app.Tax_2_Value__c);
            System.assertEquals(null, app.Profit_Center__c);
        }
        else
        {
            System.assertEquals('Tx(10.000%)', app.Tax_1_Name__c);
            System.assertEquals('Tx2(5.000%)', app.Tax_2_Name__c);
            System.assertEquals(String.valueOf((fee / 115 * 10).setScale(2)) + ' CAD', app.Tax_1_Value__c);
            System.assertEquals(String.valueOf((fee / 115 * 5 ).setScale(2)) + ' CAD', app.Tax_2_Value__c);
            System.assertEquals('p2', app.Profit_Center__c);
        }

        System.assertEquals(IDCardUtil.PAYMENT_TYPE_CC, app.Payment_Type__c);
        System.assertEquals('CAD', app.CurrencyIsoCode);
        System.assertEquals(pCode, app.Promotion_Code__c);
    }

    private static void validateCard(ID_Card__c card, ID_Card_Application__c app, Contact contact,
                                 Boolean hasPayment, Boolean isUSAgent, String webstarKey, Boolean useAlternatePhone,
                                 Boolean useAlternateAccount)
    {
        System.debug('Validating id card: ' + card);

        System.assertEquals(RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'AIMS'), card.RecordTypeId);
        validateIf(useAlternateAccount, '85500100', '67504242', card.Agency_IATA_Code__c);
        validateIf(useAlternateAccount, 'ADAMB TRAVEL SERVICES INC.', 'ADAM TRAVEL SERVICES INC.', card.Agency_Name__c);
        System.assertEquals('Manager Name', card.Approving_Manager_s_Name__c);
        System.assertEquals('manager@email.com', card.Approving_Manager_s_Email__c);
        System.assertEquals(false, card.Blacklisted__c);
        System.assertEquals('CAD', card.CurrencyIsoCode);
        validateIf(useAlternateAccount, date.newInstance(1971, 10, 16), date.newInstance(1980, 1, 1), card.Date_of_Birth__c);
        System.assertEquals('Administration', card.Duties__c);
        System.assertEquals('johnsonk@iata.org', card.Email__c);
        validateIf(hasPayment, 85.00, 0.00, card.Fee_Applicable__c);
        validateIf(useAlternateAccount, 'MARWA', 'ContactOne', card.FirstName__c);
        validateIf(useAlternateAccount, 'F', 'M', card.Gender__c);
        System.assertEquals('35h or more', card.Hours_per_week__c);
        System.assertEquals(app.Id, card.ID_Card_Application__c);
        validateIf(useAlternateAccount, 'ALLAM', 'UserOne', card.LastName__c);
        validateIf(useAlternateAccount, null, 'K', card.Middle_Initial__c);
        validateIf(useAlternateAccount, 'ALLAM MARWA', 'ContactOne UserOne', card.Name_on_ID_Card__c);
        System.assertEquals('Renew', card.Nature_of_ID_Card__c);
        validateIf(useAlternateAccount, 'Independent Consultant/Broker', 'Director', card.Position__c);
        if (isUSAgent)
            System.assertEquals('US000001.jpg', card.Photo__c);
        else
            validateIf(useAlternateAccount, 'CA000002.jpg', 'CA000001.jpg', card.Photo__c);
        System.assertEquals('Digital', card.Photo_Flag__c);
        if (useAlternatePhone)
            System.assertEquals('5145550002', card.Phone__c);
        else
            validateIf(useAlternateAccount, '514-555-0001', '5145550001', card.Phone__c);
        validateIf(isUSAgent, (String) null, 'p2', card.Profit_Center__c);
        System.assertEquals('Y', card.Paid__c);
        System.assertEquals(IDCardUtil.PAYMENT_TYPE_CC, card.Payment_Type__c);
        System.assertEquals(false, card.Renewal_From_Replace__c);
        validateIf(useAlternateAccount, '1995', '2000', card.Start_Date_Industry__c);
        validateIf(useAlternateAccount, 'July', 'January', card.Start_Date_Agency_Month__c);
        validateIf(useAlternateAccount, '2002', '2003', card.Start_Date_Agency_Year__c);
        System.assertEquals('Passenger', card.Type_of_ID_Card__c);
        System.assertEquals('MRS.', (card.Title__c == null ? null : card.Title__c.toUpperCase()));
        if (isUSAgent)
            System.assertEquals('5991000001', card.VER_Number__c);
        else
            validateIf(useAlternateAccount, '5990000002', '5990000001', card.VER_Number__c);
        System.assertEquals(System.now().date().addMonths(24), card.Valid_To_Date__c);
        System.assertEquals(System.now().date().addMonths(12), card.Valid_From_Date__c);
        System.assertEquals('TACB', card.Card_Code__c);
        System.assertNotEquals(null, card.Related_Contact__c);
        if (contact != null)
            System.assertEquals(contact.Id, card.Related_Contact__c);
        System.assertEquals(webstarKey, card.WebStar_P00_Key__c);
    }

    private static void validateIf(Boolean useFirst, String first, String second, String value)
    {
        if (useFirst)
            System.assertEquals(first, value);
        else
            System.assertEquals(second, value);
    }

    private static void validateIf(Boolean useFirst, Decimal first, Decimal second, Decimal value)
    {
        if (useFirst)
            System.assertEquals(first, value);
        else
            System.assertEquals(second, value);
    }

    private static void validateIf(Boolean useFirst, Date first, Date second, Date value)
    {
        if (useFirst)
            System.assertEquals(first, value);
        else
            System.assertEquals(second, value);
    }

    private static void validateCardPrinting(ID_Card__c card, String typeOfCard, Boolean isToPrint)
    {
        if (IDCard_MobileAppRenewalService.CARD_TYPE_PLASTIC.equals(typeOfCard))
        {
            System.assertEquals(IDCard_MobileAppRenewalService.CARD_TYPE_PLASTIC, card.Card_Type__c);
            System.assertEquals(IDCardUtil.CARDSTATUS_APPROVED, card.Card_Status__c);
            System.assertEquals(true, card.MustSyncWithAIMS__c);
            System.assertEquals(null, card.Sent_to_AIMS_on__c);
            System.assertEquals(null, card.Received_From_AIMS__c);
        }
        else
        {
            System.assertEquals(IDCard_MobileAppRenewalService.CARD_TYPE_DIGITAL, card.Card_Type__c);
            System.assertEquals(IDCardUtil.CARDSTATUS_VALID, card.Card_Status__c);
            System.assertEquals(false, card.MustSyncWithAIMS__c);
            System.assertEquals(System.now().date(), (card.Sent_to_AIMS_on__c == null ? null : card.Sent_to_AIMS_on__c.date()));
            System.assertEquals(System.now().date(), (card.Received_From_AIMS__c == null ? null : card.Received_From_AIMS__c.date()));
        }
        System.assertEquals(isToPrint, card.Is_Expedite__c);
    }

    private static void validateSpecializationFields(ID_Card_Application__c app, Boolean specializationsSet)
    {
        validateSpecializationFields(specializationsSet, true, app.ASF_Current_Function__c, app.ASF_Percentage_of_Annual_Booking__c,
            app.ASF_Market_Specialization__c, app.ASF_Market_Specialization_Comment__c, app.ASF_Market_Focus__c,
            app.ASF_Specializing_on_Destination__c, app.ASF_Completed_Travel_Courses__c,
            app.ASF_Last_Completed_Travel_Course__c, app.ASF_FAM_Trips__c);
    }

    private static void validateSpecializationFields(ID_Card__c card, Boolean specializationsSet, Boolean fieldsFromRequest)
    {
        validateSpecializationFields(specializationsSet, fieldsFromRequest, card.ASF_Current_Function__c,
            card.ASF_Percentage_of_Annual_Booking__c,
            card.ASF_Market_Specialization__c, card.ASF_Market_Specialization_Comment__c, card.ASF_Market_Focus__c,
            card.ASF_Specializing_on_Destination__c, card.ASF_Completed_Travel_Courses__c,
            card.ASF_Last_Completed_Travel_Course__c, card.ASF_FAM_Trips__c);
    }

    private static void validateSpecializationFields(Boolean specializationsSet, Boolean fieldsFromRequest,
                                                     String f1, String f2, String f3, String f3c, String f4,
                                                     String f5, String f6, String f7, String f8)
    {
        if (specializationsSet)
        {
            System.assertEquals('AF1;AF2;AF3', f1);
            System.assertEquals('N/A', f2);
            System.assertEquals('N/A', f3);
            if (fieldsFromRequest)
                System.assertEquals('some comment', f3c);
            else
                System.assertEquals('some comment from previous IDC', f3c);
            System.assertEquals('N/A', f4);
            System.assertEquals('N/A', f5);
            System.assertEquals('N/A', f6);
            System.assertEquals('N/A', f7);
            System.assertEquals('N/A', f8);
        }
        else
        {
            System.assertEquals(null, f1);
            System.assertEquals(null, f2);
            System.assertEquals(null, f3);
            System.assertEquals(null, f3c);
            System.assertEquals(null, f4);
            System.assertEquals(null, f5);
            System.assertEquals(null, f6);
            System.assertEquals(null, f7);
            System.assertEquals(null, f8);
        }
    }

    private static Id_Card__c createUSAgentIdCard(String webstarKey)
    {
        Id_Card__c idCard = new Id_Card__c();
        idCard.Approving_Manager_s_Name__c = 'Manager Name';
        idCard.Approving_Manager_s_Email__c = 'manager@email.com';
        idCard.CurrencyIsoCode = 'CAD';
        idCard.Date_of_Birth__c = date.newInstance(1980, 1, 1);
        idCard.Duties__c = 'Administration';
        idCard.Email__c = 'johnsonk@iata.org';
        idCard.Fee_Applicable__c = 0.00; // unimportant
        idCard.FirstName__c = 'ContactOne';
        idCard.Gender__c = 'M';
        idCard.Hours_per_week__c = '35h or more';
        idCard.Is_Expedite__c = false;
        idCard.LastName__c = 'UserOne';
        idCard.Middle_Initial__c = 'K';
        idCard.Name_on_ID_Card__c = 'ContactOne UserOne';
        idCard.Nature_of_ID_Card__c = IDCardUtil.IDCARDNATURE_NEW;
        idCard.Position__c = 'Director';
        idCard.Photo__c = 'US000001.jpg';
        idCard.Phone__c = '5145550001';
        idCard.Profit_Center__c = '-'; // unimportant
        idCard.Payment_Type__c = '-'; // unimportant
        idCard.Renewal_From_Replace__c = true;
        idCard.Start_Date_Industry__c = '2000';
        idCard.Start_Date_Agency_Month__c = 'January';
        idCard.Start_Date_Agency_Year__c = '2003';
        idCard.Title__c = 'Mrs.';
        idCard.VER_Number__c = '5991000001';
        idCard.WebStar_P00_Key__c = webstarKey;
        idCard.Valid_To_Date__c = System.now().date().addMonths(12);
        idCard.Valid_From_Date__c = System.now().date().addMonths(0);
        return idCard;
    }

    private static Contact createUSContact()
    {
        Contact theContact = new Contact();
        theContact.RecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        theContact.AccountId = testData.IDCard_Accounts[0].Id;
        theContact.LastName = 'UserOne';
        theContact.IDCard_Email__c = 'johnsonk@iata.org';
        theContact.FirstName = 'ContactOne';
        theContact.VER_Number_2__c = '5991000001';
        return theContact;
    }

    private static Object getResponse(RestResponse response)
    {
        String txt = response.responseBody.toString();
        return (Object) JSON.deserializeUntyped(txt);
    }
}
