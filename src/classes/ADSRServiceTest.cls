@isTest
public class ADSRServiceTest {
    
    @TestSetup
    static void setupTest(){
        
    }

    @isTest
    static void testGetSummaryReportByMarket(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ADSR_API_Mock');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

        ADSRService service = new ADSRService('airlineCode', 'region', 'markets', 'operation', null);

        ADSRService.SummaryReport report = service.getSummaryReport();

        System.debug(JSON.serialize(report));

        Test.stopTest();

    }

}