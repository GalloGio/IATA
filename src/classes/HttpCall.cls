public class HttpCall {
    public static String HTTP_METHOD_GET = 'GET';
    public static String HTTP_METHOD_POST = 'POST';
    public static String HTTP_METHOD_PUT = 'PUT';
    public static String HTTP_METHOD_DELETE = 'DELETE';
    public static String HTTP_METHOD_PATCH = 'PATCH';

    private String endPoint;
    private String path;
    private String body;
    private String method;

    public String debugPrefix = 'HttpCall';
    public String authHeader;
    public String contentType = 'application/json';
    public String accept = 'application/json';
    public String soapAction = null;

    public HttpCall(String endPoint, String path, String body, String method) {
        this.endPoint = endPoint;
        this.path = path;
        this.body = body;
        this.method = method;
    }

    public Map<String, Object> invoke() {
        Map<String, Object> result = new Map<String, Object>();
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();      
        req.setEndpoint(endPoint + path);

        if (method == HTTP_METHOD_PATCH) { 
            req.setHeader('X-HTTP-Method-Override', HTTP_METHOD_PATCH); 
            method = HTTP_METHOD_PUT; 
		}
        req.setMethod(method);
        req.setTimeout(120000);
        req.setHeader('Accept', accept); // required by Azure AD

        if (!String.isBlank(this.authHeader)) { // required by Concur
            req.setHeader('Authorization', this.authHeader);
        }

        if (body != null) {
            req.setHeader('Content-Type', contentType);
            req.setBody(body);
        }

        // SOAP compat
        if (!String.isBlank(this.soapAction)) { // required by ExactTarget
            req.setHeader('SOAPAction', this.soapAction);
        }

        System.debug(loggingLevel.FINEST, '____ [cls HttpCall - invoke] req - ' + req);

        HttpResponse res = http.send(req);

        System.debug(loggingLevel.FINEST, '____ [cls HttpCall - invoke] res - ' + res);
        
        Integer httpStatusCode = res.getStatusCode();
        String respStr = res.getBody();
        Boolean isSuccess = httpStatusCode >= 200 && httpStatusCode < 300;
        
        result.put('httpStatusCode', httpStatusCode);
        result.put('isSuccess', isSuccess);
        result.put('httpResponseStr', respStr);
        
        System.debug(loggingLevel.FINEST, '____ [cls HttpCall - invoke] result - ' + result);
        
        return result;
    }

    // Static helper methods    
    public static String buildParam(String path, String paramValue, String paramName) {
        if (paramValue != null) {
            String encodedParam = EncodingUtil.urlEncode(paramValue, 'UTF-8');
            if (path.contains('?')) return '&' + paramName + '=' + encodedParam;
            else return '?' + paramName + '=' + encodedParam;
        }
        return '';
    }

    public static String buildParam(String path, Boolean paramValue, String paramName) {
        return buildParam(path, String.valueOf(paramValue), paramName);
    }

    public static String buildParam(String path, Integer paramValue, String paramName) {
        return buildParam(path, String.valueOf(paramValue), paramName);
    }
    
    public static Map<String, Object> get(String endPoint) {
        return HttpCall.get(endPoint, '');
    }

    public static Map<String, Object> get(String endPoint, String path) {
        return new HttpCall(endPoint, path, null, HTTP_METHOD_GET).invoke();
    }

    public static Map<String, Object> post(String endPoint, String body) {
        return HttpCall.post(endPoint, '', body); 
    }

    public static Map<String, Object> post(String endPoint, String path, String body) {
        return new HttpCall(endPoint, path, body, HTTP_METHOD_POST).invoke(); 
    }

    public static Map<String, Object> del(String endPoint, String path) {
        return new HttpCall(endPoint, path, null, HTTP_METHOD_DELETE).invoke();
    }

    public static Map<String, Object> patch(String endPoint, String path, String body) {
        return new HttpCall(endPoint, path, body, HTTP_METHOD_PATCH).invoke(); 
    }

    public static Map<String, Object> put(String endPoint, String path, String body) {
        return new HttpCall(endPoint, path, body, HTTP_METHOD_PUT).invoke(); 
    }
}