public class SCIMUsersUtility{

    public static String endPoint = '';

    //override this methods on your process to add parameters and paths to your requests
    public static Map<String, String> createParams = new Map<String, String>();
    public static Map<String, String> updateParams = new Map<String, String>{'_HttpMethod' => 'PATCH'};
    public static Map<String, String> deleteParams = new Map<String, String>();
        
    public static Map<String, Object> getAllUsers(String offset, String reconFilter) {
        String path = '?attributes=active,userName,emails,name,name.familyName,name.givenName&count=200';

        String filter = buildFilter(offset, reconFilter);
        if (!String.isBlank(filter)) path += HttpCall.buildParam(path, filter, 'filter');

        return HttpCall.get(endPoint, path);
    }
    
    public static Map<String, Object> createUser(String userPayload) {
        String finalEndpoint = endPoint;
        for(String param : createParams.keySet()) finalEndpoint += HttpCall.buildParam(finalEndpoint, createParams.get(param), param);

        return HttpCall.post(finalEndpoint, userPayload);
    }
    
    public static Map<String, Object> updateUser(String userId, SCIMUser user) {
        String userPayload = System.JSON.serialize(user, true);
        return updateUser(userId, userPayload);
    }
    
    public static Map<String, Object> updateUser(String userId, String userPayload) {
        String path = '/' + userId;
        for(String param : updateParams.keySet()) path += HttpCall.buildParam(path, updateParams.get(param), param);

        return HttpCall.patch(endPoint, path, userPayload);
    }
    
    public static Boolean isDebug(){
    	return SCIM_Prov_Connector__c.getOrgDefaults().Enable_Debug_Loging__c;
    }
    
    public static Map<String, Object> deleteUser(String userId) {
        String path = '/' + userId;
        for(String param : deleteParams.keySet()) path += HttpCall.buildParam(path, deleteParams.get(param), param);

        return HttpCall.del(endPoint, path);
    }

    private static String buildFilter(String offset, String reconFilter) {
        String filter = '';

        // Are we filtering?
        if (!String.isBlank(offset) || !String.isBlank(reconFilter)) {

            if (!String.isBlank(offset) && !String.isBlank(reconFilter))
                // Filtering on both offset and reconFilter
                filter += EncodingUtil.URLEncode('id gt "' + offset + '" and ' + reconFilter, 'UTF-8');
            else if (!String.isBlank(offset))
                // Only filtering on offset
                filter += EncodingUtil.URLEncode('id gt "' + offset + '"', 'UTF-8');
            else filter += 
                // Only filtering on reconFilter
                EncodingUtil.URLEncode(reconFilter, 'UTF-8');
        }

        return filter;
    }
}