public with sharing class SidraLiteUtil{

	public class SidraLiteException extends Exception{}

	/**
		Return default region based on current user role
	**/
	public static String getDefaultRegion() {
		try {
			UserRole role = [Select Name from UserRole where id = :UserInfo.getUserRoleId()];

			if (role.Name.contains('Africa & ME')) {
				return 'Africa & Middle East';
			}
			if (role.Name.contains('Americas')) {
				return 'Americas';
			}
			if (role.Name.contains('A&P')) {
				return 'Asia & Pacific';
			}
			if (role.Name.contains('China')) {
				return 'China & North Asia';
			}
			if (role.Name.contains('MAD')) {
				return 'Europe';
			}
		} catch (Exception e) {
			System.debug('Could not find a valid role ' + UserInfo.getUserRoleId());
		}
		return '';
	}

	/**
		Return true if input is Passenger account
	**/
	public static final set<String> LOCATION_CLASS_BSP = new set<String>{AMS_Utils.LC_DOMESTIC_AGENT,AMS_Utils.LC_PASSENGER};
	public static Boolean isPassenger(Account account) {
		if (account==null) {
			throw new SidraLiteException('There is no related Account');
		}
		return LOCATION_CLASS_BSP.contains(account.Location_Class__c);
	}

	/**
		Return true if account is Cargo or CASS
	**/
	public static final set<String> LOCATION_CLASS_CASS = new set<String>{AMS_Utils.LC_CASS_ASSOCIATE,AMS_Utils.LC_CARGO,AMS_Utils.LC_IMPORT_AGENT};
	public static Boolean isCargoCASS(Account account) {
		if (account==null) {
			throw new SidraLiteException('There is no related Account');
		}
		return LOCATION_CLASS_CASS.contains(account.Location_Class__c);
	}

	/**
		Return true if account is only CASS
	**/
	public static final set<String> LOCATION_CLASS_CASS_ASSOCIATE = new set<String>{AMS_Utils.LC_CASS_ASSOCIATE};
	public static Boolean isCASSAssociate(Account account) {
		if (account==null) {
			throw new SidraLiteException('There is no related Account');
		}
		return LOCATION_CLASS_CASS_ASSOCIATE.contains(account.Location_Class__c);
	}

	/**
		Return true if account is TIDS Agent
	**/
	public static final set<String> LOCATION_CLASS_TIDS_AGENT = new set<String>{AMS_Utils.LC_TIDS};
	public static Boolean isTIDSAgent(Account account) {
		if (account==null) {
			throw new SidraLiteException('There is no related Account');
		}
		return LOCATION_CLASS_TIDS_AGENT.contains(account.Location_Class__c);
	}

	public static String getBSPCASS(Account account) {
		if (account==null) {
			throw new SidraLiteException('There is no related Account');
		}
		if (isPassenger(account) || isTIDSAgent(account)) {
			return 'BSP';
		}
		if (isCargoCASS(account) ) {
			return 'CASS';
		}
		return '';
	}

	/**
		Return true if input account is active
	**/
	public static final set<String> ACCOUNT_INACTIVE_STATUS = new set<String>{'Cash basis/no commission', 'Cash basis/with commission'};
	public static Boolean isAccountActive(Account account) {
		if (account==null) {
			throw new SidraLiteException('There is no related Account');
		}
		return account != null && !ACCOUNT_INACTIVE_STATUS.contains(account.Status__c);
	}

	/**
		Get last month day of current date
	**/
	public static Date lastMonthDay(Date dt) {
		Integer daysInMonth = Date.daysInMonth(dt.year(), dt.month());
		return Date.newInstance(dt.year(), dt.month(), daysInMonth);
	}

	/**
		find email template for given case based on custom setting SidraLiteEmailTemplates__c
	**/
	public static String getEmailTemplate(Case cse, String actionType) {
		String searchCountry = '%' + cse.BSPCountry__c + '%';
		list<SidraLiteEmailTemplates__c> listTemplates = [
			SELECT Id, Name, SidraLiteAction__c, SidraLiteReason__c, Country__c,Region__c, TypeOfCustomer__c, EmailTemplate__c
			FROM SidraLiteEmailTemplates__c
			WHERE SidraLiteAction__c = :actionType
			AND SidraLiteReason__c = :cse.SIDRA_Lite_Reason__c
			AND ( Country__c = 'All Region' OR Country__c like :searchCountry )
			AND Region__c = :cse.Region__c
			AND TypeOfCustomer__c = :cse.account.Type];

		// if no template is found then throw an error
		if (listTemplates.isEmpty()) {
			throw new SidraLiteException('No custom email template was found for case ' + cse.CaseNumber + ' and type ' + actionType);
		}
		// if one template is found then return it
		if (listTemplates.size() == 1) {
			return listTemplates[0].EmailTemplate__c;
		}
		for (SidraLiteEmailTemplates__c customTemplate: listTemplates) {
			for (String country: customTemplate.Country__c.split(';')) {
				if (country == cse.BSPCountry__c) {
					return customTemplate.EmailTemplate__c;
				}
			}
		}
		return listTemplates[0].EmailTemplate__c;
	}

	/**
		find merge template for given case based on custom setting SidraLiteCongaTemplates__c
	**/
	public static String getMergeTemplate(Case cse, String actionType) {
		String searchCountry = '%' + cse.BSPCountry__c + '%';
		list<SidraLiteCongaTemplates__c> listTemplates = [
			SELECT Id, Name, SidraLiteAction__c, SidraLiteReason__c, Country__c,Region__c, TypeOfCustomer__c, EmailTemplate__c
			FROM SidraLiteCongaTemplates__c
			WHERE SidraLiteAction__c = :actionType
			AND SidraLiteReason__c = :cse.SIDRA_Lite_Reason__c
			AND ( Country__c = 'All Region' OR Country__c like :searchCountry )
			AND Region__c = :cse.Region__c
			AND TypeOfCustomer__c = :cse.account.Type];

		// if no template is found then throw an error
		if (listTemplates.isEmpty()) {
			throw new SidraLiteException('No custom merge template was found for case ' + cse.CaseNumber);
		}
		// if one template is found then return it
		if (listTemplates.size() == 1) {
			return listTemplates[0].EmailTemplate__c;
		}
		for (SidraLiteCongaTemplates__c customTemplate: listTemplates) {
			for (String country: customTemplate.Country__c.split(';')) {
				if (country == cse.BSPCountry__c) {
					return customTemplate.EmailTemplate__c;
				}
			}
		}
		return listTemplates[0].EmailTemplate__c;
	}

	/**
		All SIDRA and SIDRA Lite cases related to the account's input case are searched
		if most recent case is the same as the input Sidra Lite case the return true
		WARNING: this method contains a query and should never been called in a trigger or a loop
	**/
	public static Boolean isLastSidraCase(Case sidraLiteCase) {
		list<Case> listCases = [
			SELECT id
			FROM Case
			WHERE AccountId = :sidraLiteCase.AccountId
			AND RecordtypeId IN (:SidraLiteManager.RECORDTYPE_SIDRA_LITE,:SidraLiteManager.RECORDTYPE_SIDRA)
			AND DEF_Approval_Rejection__c = 'Approved'
			AND DEF_Withdrawal_Approval_Rejection__c != 'Approved'
			AND Update_AIMS_DEF__c != NULL
			ORDER BY Update_AIMS_DEF__c desc
			LIMIT 1];

		return !listCases.isEmpty() && listCases.get(0).id == sidraLiteCase.Id;
	}

	/**
		In Sidra Lite process has been added an exception, if certain conditions are met in Sidra Lite case
		the process will not proceed as usual, only the parent case will be updated.
		This method tests the Sidra Lite case and returns true if this special condition is met
	**/
	public static final set<String> REASONS_TO_AVOID_CHILD_UPDATE = new set<String>{'Non-payment','Technical Default'};
	public static Boolean SidraLiteCaseMustNotBeUpdated(Case sidraLiteCase) {
		return (sidraLiteCase.Reason_for_Default__c != null && REASONS_TO_AVOID_CHILD_UPDATE.contains(sidraLiteCase.Reason_for_Default__c));
	}

	/**
	 * As a general rule the Termination Date should be the last day of the next month
	 * But an exception was added for United Arab Emirates and CASS Import (location class I)
	 */
	public static Date getDefaultTerminationDate(Account account) {
		if (account.IATA_ISO_Country__r.ISO_Code__c == 'AE' && account.Location_Class__c == AMS_Utils.LC_IMPORT_AGENT) {
			return lastMonthDay(Date.today().addMonths(3));
		}
		return lastMonthDay(Date.today().addMonths(1));
	}
}
