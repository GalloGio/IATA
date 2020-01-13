/**
 * Class encapsulates query logic for User
 *
 * @author: David Daboue <daboued@iata.org>
 * @date: 2015-08-14
 *
 **/
public class User_Sel extends Selector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			User.Id,
			User.Email,
			User.Username,
			User.Name,
			User.ContactId,
			User.LastLoginDate
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return User.sObjectType;
	}

	public Map<Id, Id> getUserByContact(Set<Id> contactIds)
	{
		Map<Id, Id> result = new Map<Id, Id>();
		for(User u : [SELECT Id, ContactId FROM User WHERE ContactId IN : contactIds])
		{
			result.put(u.ContactId, u.Id);
		}

		return result;
	}

	public User getUserDetails(ID userId)
	{
		User u ;
		List<User> users = (List<User>) selectSObjectById(new Set<Id>{userId});
		if(!users.isEmpty())
			u= users[0];

		return u;
	}

	public static String getCustomerType(Id idUserOrContact)
	{
		String customerType;
		try {
			if (String.valueOf(idUserOrContact).startsWith(User.sObjectType.getDescribe().getKeyPrefix())) {
				//User u = getUserDetails(userId);
				List<User> lstUser = [select Contact.Account.Customer_Type__c, Contact.Account.ParentId, Contact.Account.Parent.Customer_Type__c from User where Id = :idUserOrContact];
				if(lstUser != null && lstUser.size() > 0){
					if (lstUser[0].Contact.Account.ParentId == null)
						customerType = lstUser[0].Contact.Account.Customer_Type__c;
					else
						customerType = lstUser[0].Contact.Account.Parent.Customer_Type__c;
				}
			}
			else
			{
				List<Contact> LstContact = [select Account.Customer_Type__c, Account.ParentId, Account.Parent.Customer_Type__c from Contact where Id = :idUserOrContact];
				if(LstContact != null && LstContact.size() > 0){
					if (LstContact[0].Account.ParentId == null)
						customerType = LstContact[0].Account.Customer_Type__c;
					else
						customerType = LstContact[0].Account.Parent.Customer_Type__c;
				}
			}
		} catch (Exception e) {
			customerType = '';
		}
		if (String.isBlank(customerType))
			customerType = IECConstants.PARAM_CUSTOMERTYPE_DEFAULT;

		return customerType;
	}


	//Return user email by Id
	public Map<Id, User> getUsersById(Set<Id> userIds)
	{
		system.debug('getUsersById ' + userIds);
		return new Map<Id, User>((List<User>) selectSObjectById(userIds));
	}

	public User getUserById(Id userId)
	{
		List<User> users = (List<User>) selectSObjectById(new Set<Id>{userId});

		return (users.size() > 0)  ? users[0] : null;
	}

	public User getUserByContactId(Id contactId)
	{
		List<User> users = (List<User>) selectSObjectByField('ContactId' , new Set<String>{contactId});

		return (users.size() > 0) ? users[0] : null;
	}


	/****************************************************************************************************
		Created by Thai 2015-11-20
			Return contact information for discounts
	****************************************************************************************************/
	public static Contact getContactDiscountInfo(Id idContact)
	{
		try
		{
			return [select AccountId, Account.ShippingCountry, Account.BillingCountry, Account.Region_formula__c, Account.Customer_Type__c from Contact where Id = :idContact limit 1][0];
		}
		catch (Exception e)
		{
			return null;
		}
	} //*** end of "getContactDiscountInfo"


	public User getPortalUser(String usernameOrEmail)
	{
		String query = String.format(
			'SELECT {0} ' +
			'FROM {1} ' +
			'WHERE (Username = :usernameOrEmail OR Email = :usernameOrEmail) ' +
			'   AND IsActive = true AND UserType = \'PowerPartner\'' ,
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		try{
			List<User> users = Database.query(query);
			return (users.size() > 0) ? users[0] : null;
		}catch(Exception ex){}
		return null;
	}
}
