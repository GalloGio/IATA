@IsTest(SeeAllData = false)
public with sharing class OneIdGetHttpContextTest {
    public static final string IP_FOR_TEST ='128.65.43.123';
    
	@IsTest
	static void testOneIdGetHttpContext() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = OneIdUtils.getCommunityUrlName()+'/services/apexrest/OneIdGetHttpContext';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
		req.remoteAddress=IP_FOR_TEST;
        
        RestContext.request = req;
        RestContext.response= res;

        //Call REST Service
        OneIdGetHttpContext.doGet();
        
        System.debug('OneIdGetHttpContextTest After Call OneIdGetHttpContext.doGet responseBody='+res.responseBody.toString());
        
        system.assertEquals(IP_FOR_TEST,res.responseBody.toString());
	}
}