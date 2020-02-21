public class IECUSerSingleTon{


	private IECUSerSingleTon(){}

	public static User instance = null;

	public static User getIECUser(Id UserId){

			if(instance == null && UserId <>null){

				instance = [SELECT UserType, Username, IsActive, AccountId, CompanyName,
									ContactId, Email, FirstName, Name, LastName, Id, Portal_User_Frozen__c
									FROM User
									WHERE Id = :userId][0];

			}

			return instance;

	}

}
