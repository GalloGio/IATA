@IsTest
public class GADM_InternalUsersHandler_TEST {

    @TestSetup
    private static void setup() {

        Id standardUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;

        User testUser1 = createUser('Petr', 'White', standardUserProfileId);
        User testUser2 = createUser('Milan', 'Green', standardUserProfileId);

        Group group1 = new Group();
        group1.name = 'GADM Internal Users Notification Group';
        group1.Type = 'Regular';
        insert group1;

        GroupMember groupMember1 = new GroupMember();
        groupMember1.UserOrGroupId = testUser1.Id;
        groupMember1.GroupId = group1.Id;
        Insert groupMember1;

        GroupMember groupMember2 = new GroupMember();
        groupMember2.UserOrGroupId = testUser2.Id;
        groupMember2.GroupId = group1.Id;
        Insert groupMember2;

    }

    private static User createUser(String firstName, String lastName, Id profileId) {
        User testUser = new User();
        testUser.alias = 'dsfsdfds';
        testUser.email = firstName+'.'+lastName+'@somedomain.org';
        testUser.emailencodingkey = 'UTF-8';
        testUser.firstname = firstName;
        testUser.lastname = lastname;
        testUser.languagelocalekey = 'en_US';
        testUser.localesidkey = 'en_US';
        testUser.timezonesidkey = 'Asia/Dubai';
        testUser.Username = firstName+'.'+lastName+'@somedomain.org';
        testUser.PortalRole = 'Manager';
        testUser.CommunityNickname = (firstName + lastName).substring(0,8);
        testUser.ProfileId = profileId;
        testUser.License_Cost_Center__c = 'ISF005CH01';
        testUser.IsActive = true;
        insert testUser;
        return testUser;
    }

    @IsTest
    private static void getGroupmMembersTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.white@somedomain.org'];
        User testUser2 = [SELECT Id FROM User WHERE Email = 'milan.green@somedomain.org'];

        List<User> users = new List<User>();


        Test.startTest();

        System.runAs(testUser) {

            users = GADM_InternalUsersHandler.getUsersFromGroup('GADM Internal Users Notification Group');

        }

        Test.stopTest();

        Set<Id> userIds = new Set<Id>();
        for(User u : users) {
            userIds.add(u.Id);
        }

        System.assertEquals(true, userIds.contains(testUser.Id), 'Wrong userId form public group retrieved!');
        System.assertEquals(true, userIds.contains(testUser2.Id), 'Wrong userId form public group retrieved!');

    }

}