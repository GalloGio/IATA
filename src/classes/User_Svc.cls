/****************************************************************************************************
	Created by CGI, Thai 2016-02-12
		Various functionalities around object "User"
****************************************************************************************************/

public without sharing class User_Svc
{


/****************************************************************************************************
	Created by CGI, Thai 2016-02-12
		Deactivate users in future mode to prevent error "MIXED_DML_OPERATION"
****************************************************************************************************/
@future
public static void deactivateUser(String jsonListUser)
{
	List<User> lstUser = (List<User>) JSON.deserialize(jsonListUser, List<User>.class);
	if (lstUser.size() > 0)
	{
		for (User usr : lstUser)
			usr.IsActive = false;
		update lstUser;
	}
} //*** end of "deactivateUser"


} //*** end of class
