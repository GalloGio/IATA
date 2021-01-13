@isTest
private class UserProvisioningUtilsTest {

    // Tests
    @isTest static void testDeletedLinkedUserProvAccount() {
        // arrange
        // Create a UPR for testing & initialize UserProvisioningUtils
        UserProvisioningRequest upr = UserProvisioningTestUtils.createUserProvisioningRequest('SCIM', 'Create');

        UserProvisioningUtils userProvUtils = new UserProvisioningUtils(false);
        userProvUtils.init(upr.Id);

        // Delete the initially created UPA
        UserProvAccount firstUpa = userProvUtils.getLinkedUserProvAccount();
        firstUpa.Status = 'Deleted';
        update firstUpa;

        // Create an active user provisioning account
        UserProvAccount activeUpa = new UserProvAccount(
            salesforceUserId = upr.salesforceUserId,
            connectedAppId = upr.connectedAppId,
            externalUserId = '4321',
            externalUserName = firstUpa.externalUserName,
            externalFirstName = firstUpa.externalFirstName,
            externalLastName = firstUpa.externalLastName,
            linkState = 'Linked',
            status = 'Active'
        );
        insert activeUpa;

        // can uncomment below once SFDC populates this field
        // as of 1/29/2016 this code path is not followed
        //
        // see UserProvisioningUtils.getLinkedUserProvAccount()
        //
        // MUST CHANGE UserProvisioningTestUtils.createUserProvisioningRequest()
        // in conjunction

        //upr.UserProvAccountId = activeUpa.id;
        //update upr;
        //// UserProvisioningUtils caches upr
        //UserProvisioningUtils.init(upr.Id);

        // act
        UserProvAccount actualUpa = userProvUtils.getLinkedUserProvAccount();

        // assert
        System.assertNotEquals('Deleted', actualUpa.Status);
    }
}