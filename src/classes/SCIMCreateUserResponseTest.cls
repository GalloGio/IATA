@isTest
public class SCIMCreateUserResponseTest {

    @isTest static void testParse() {
        // arrange
        String json = '{"id":"some-id","userName":"some-username"}';

        // act
        SCIMCreateUserResponse obj = SCIMCreateUserResponse.parse(json);

        // assert
        System.assert(obj != null);
        System.assertEquals('some-id', obj.id);
        System.assertEquals('some-username', obj.userName);
    }

    @isTest static void testParse1() {
        UserProvisioningUtils userProvUtils= new UserProvisioningUtils(false);

        UserProvisioningRequest up = UserProvisioningTestUtils.userProvisioningRequestVM('ISAGO Provisioning', 'Create', 'New');

        userProvUtils.init(up.id);
        
        //String json = '{"id":"some-id","userName":"some-username", "active":"false"}';
        
        //SCIMCreateUserResponse obj = SCIMCreateUserResponse.parse(json); 
        //userProvUtils.addExternalResponse(obj);
    }    
}