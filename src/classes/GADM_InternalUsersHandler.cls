public without sharing class GADM_InternalUsersHandler {

	public static List<User> getUsersFromGroup(String groupName) {
		List<User> usersFromPublicGroup = new List<User>();

		if(String.isNotBlank(groupName)) {
			List<Group> groups = [SELECT Id, Name FROM Group WHERE Name = :groupName];

			if(! groups.isEmpty()) {

				List<GroupMember> groupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :groups];
				String userType = Schema.SObjectType.User.getKeyPrefix();

				Set<Id> groupMembersIds = new Set<Id>();
				for(GroupMember member : groupMembers) {
					String memberId = member.UserOrGroupId;
					if(memberId.startsWithIgnoreCase(userType)) {
						groupMembersIds.add(member.UserOrGroupId);
					}

				}
				List<User> users = [SELECT Id, Email FROM User WHERE Id = :groupMembersIds];
				usersFromPublicGroup.addAll(users);

			}

		}

		return usersFromPublicGroup;
	}

}
