//This class is refrenced in the apex trigger Add to Group in order to add users automatically to public groups.
public class trg_ctrl_PortalUser{

		@future
		public static void AddUsersToGroups(Set<Id> userIds , String inGroupName)
		{
				System.debug('START METHOD ADDUSERTOGROUPS  '+userIds );
				 //Get the groups that the user should be added to
				 Group g=[select Id from Group Where DeveloperName=: inGroupName];

				 List<User> users=[Select Id,Name from user Where Id IN :userIds];

				 List<GroupMember>listGroupMember =new List<GroupMember>();
				 List<User> UsersToUpdate_Lst =new List<User>();
				 // loop the users that have been created
				 for (User user : users){
							//UsersToUpdate_Lst.add(new User(Id=user.Id , UserPermissionsSFContentUser=true));
							GroupMember gm= new GroupMember();
							gm.GroupId=g.id;
							gm.UserOrGroupId = user.id;
							listGroupMember.add(gm);
				 }
				 //insert listGroupMember;
				 //System.debug('RRR1 UsersToUpdate_Lst '+UsersToUpdate_Lst );
				 //if(UsersToUpdate_Lst != null && UsersToUpdate_Lst.size() > 0){
				 //   update UsersToUpdate_Lst;
				 //}
		}
}
