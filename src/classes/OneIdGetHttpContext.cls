@RestResource(urlMapping='/OneIdGetHttpContext/*')
global class OneIdGetHttpContext {
    
    @HttpGet
    global static void doGet() {
        system.debug('Begin OneIdGetHttpContext.doGet()');
        RestContext.response.addHeader('Content-Type', 'text/plain');
        //String name = RestContext.request.params.get('name');
        
        RestRequest req = RestContext.request;
        
        system.debug('End OneIdGetHttpContext.doGet() IP='+string.valueOf(req.remoteAddress));
        
        //RestContext.response.responseBody = Blob.valueOf('Hello '+name);
        RestContext.response.responseBody = Blob.valueOf(req.remoteAddress);
    }
}