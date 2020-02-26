public class ISSP_ChangeDDS_Ctrl {
	public Account accnt			{get; set;}
	public boolean bHasAccnt		{get; set;}
	public boolean bIsAdmin			{get; set;}
	public boolean bHasOptOut		{get; set;}
	public boolean bHasOptIn		{get; set;}
	public boolean bSaved			{get; set;}
	public boolean bAccntValid		{get; set;}
	public boolean bCountryEnabled	{get; set;}

	public ISSP_ChangeDDS_Ctrl(){
   		bHasOptOut = false;
   		bHasOptIn = false;
   		bSaved = false;

		bHasAccnt = false;
		bIsAdmin = false;
		bAccntValid = false;
		bCountryEnabled = false;

		list<User> Users = [select Id, ContactId, LastName, FirstName, Contact.AccountId, Contact.User_Portal_Status__c from user where id=:Userinfo.getUserId()];

		if(!Users.isEmpty()){
			User U = Users[0];

			if(u.ContactId!=null){
				Contact con = [Select Id, AccountId, User_Portal_Status__c from Contact where id=:u.ContactId];

				if(con.User_Portal_Status__c == 'Administrator' || con.User_Portal_Status__c == 'Approved Admin' || con.User_Portal_Status__c == 'Regional Administrator' || con.User_Portal_Status__c == 'R. Administrator' )
					bIsAdmin = true;

				if(con.AccountId!=null){
					list<Account> lsAccnt = [Select Id, DDS_status__c, Location_Type__c, Category__c, DDS_Last_Update_Date__c, recordType.DeveloperName, IATA_ISO_Country__r.DDS_Enabled__c from Account where id = :con.AccountId];

					if(!lsAccnt.isEmpty()){
						bHasAccnt = true;

						accnt = lsAccnt[0];

						if(accnt.DDS_status__c == 'Opt-Out')
							bHasOptOut = true;

						if(accnt.DDS_status__c == 'Opt-In')
							bHasOptIn = true;

						if(accnt.recordType.DeveloperName == 'IATA_Agency')
							if(accnt.Location_Type__c == 'AO' || accnt.Location_Type__c=='HO')
								if(accnt.Category__c == 'IATA Passenger Sales Agent' || accnt.Category__c == 'Domestic Agent')
									bAccntValid = true;

						bCountryEnabled = accnt.IATA_ISO_Country__r.DDS_Enabled__c;
					}
				}
			}
		}
	}

	public Pagereference SaveAccnt(){
		if(bHasOptOut)
			accnt.DDS_status__c = 'Opt-In';
		else //handle opt-out from "opt-int" or "no-Reply", or null or other values
			accnt.DDS_status__c = 'Opt-Out';
		try{
			update accnt;
			bSaved = true;
		}
		catch(exception e){
			system.debug('DTULLO. Exception --> ' + e.getMessage());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An error occoured. Please try again later'));
		}

		return null;
	}

	public pagereference goToHP(){
		return new PageReference('/');
	}
}
