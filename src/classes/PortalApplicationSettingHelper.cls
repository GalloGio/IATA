/**
	Helper methods to get the configuration in Custom Metadata "Portal_Application_Setting__mdt"
**/
public with sharing class PortalApplicationSettingHelper {
	private static final map<Id,Schema.RecordTypeInfo> MAP_RECORDTYPES_ID = Schema.SObjectType.Account_Contact_Role__c.getRecordTypeInfosById();
	public static final string WILDCARD = 'ALL';

	public class PortalApplicationSettingException extends Exception {}

	/**
		Returns a list of all visible application names for the input account
		according to the Custom Metadata Portal_Application_Setting__mdt
	**/
	public static list<String> getVisibleApplicationNames(Account account) {
		// Get the list of services visible for thi input account based on the Custom metadata Portal_Application_Setting__mdt
		list<String> listVisibleApplicationNames = new list<String>();
		if (account==null) return listVisibleApplicationNames;
		for (Portal_Application_Setting__mdt setting: [
				SELECT id, MasterLabel,
					(SELECT Sector__c, Category__c
					FROM Portal_Application_Visibilities__r
					WHERE is_Visible__c = true
					AND Sector__c = :account.Sector__c
					AND Category__c IN (:account.Category__c,:WILDCARD))
				FROM Portal_Application_Setting__mdt]) {
			if (setting.Portal_Application_Visibilities__r.size()>0) {
				listVisibleApplicationNames.add(setting.MasterLabel);
			}
		}
		return listVisibleApplicationNames;
	}

	/**
		Returns a list of all autoGrant application names for the input account
		according to the Custom Metadata Portal_Application_Setting__mdt
	**/
	public static list<String> getAutoGrantApplicationNames(Account account) {
		// Get the list of services with auto grant enabled for this input account based on the Custom metadata Portal_Application_Setting__mdt
		list<String> listAutoGrantApplicationNames = new list<String>();
		if (account==null) return listAutoGrantApplicationNames;
		for (Portal_Application_Setting__mdt setting: [
				SELECT id, MasterLabel,
					(SELECT Sector__c, Category__c
					FROM Portal_Application_Visibilities__r
					WHERE Auto_grant_service__c = true
					AND Sector__c = :account.Sector__c
					AND Category__c IN (:account.Category__c,:WILDCARD))
				FROM Portal_Application_Setting__mdt]) {
			if (setting.Portal_Application_Visibilities__r.size()>0) {
				listAutoGrantApplicationNames.add(setting.MasterLabel);
			}
		}
		return listAutoGrantApplicationNames;
	}

	/**
		Get the list of app names valid to be GRANTED for the incoming Contact,
		based in a contact checkbox field, defined in custom metadata.
		If that checkbox field is marked and the metadata has "Add_Service_On_Checked__c"
	**/
	public static list<String> getGrantAppNamesByContact(Contact contactNew, Contact contactOld) {
		set<String> setAppNames = new set<String>();
		for (Portal_Application_Setting__mdt setting: [
				SELECT id, MasterLabel,
					(SELECT Id, Checkbox_Fieldname__c, Location_Class__c, Location_Type__c, Country__c
					FROM Portal_Application_Contacts_Visibility__r
					WHERE Add_Service_On_Checked__c = true)
				FROM Portal_Application_Setting__mdt]) {
			for (Portal_Application_Contact_Visibility__mdt visibility: setting.Portal_Application_Contacts_Visibility__r) {
				Boolean newValue = Boolean.ValueOf(contactNew.get(visibility.Checkbox_Fieldname__c));
				Boolean oldValue = contactOld==null? !newValue: Boolean.ValueOf(contactOld.get(visibility.Checkbox_Fieldname__c));
				if (newValue==true && oldValue==false && contactNew.Account!=null
					&&( visibility.Location_Class__c == WILDCARD || visibility.Location_Class__c == contactNew.Account.Location_Class__c)
					&&( visibility.Location_Type__c == WILDCARD || visibility.Location_Type__c == contactNew.Account.Location_Type__c)
					&&( checkCountry(visibility.Country__c, contactNew.Account.Country_ISO_Code__c))
				) {
					setAppNames.add(setting.MasterLabel);
				}
			}
		}
		return new list<String>(setAppNames);
	}

	/**
		Get the list of app names valid to be REVOKED for the incoming Contact,
		based in a contact checkbox field, defined in custom metadata.
		If that checkbox field is marked and the metadata has "Remove_Service_On_Unchecked__c"
	**/
	public static list<String> getRevokeAppNamesByContact(Contact contactNew, Contact contactOld) {
		if (contactNew==null || contactOld==null) return new list<String>();

		set<String> setAppNames = new set<String>();
		for (Portal_Application_Setting__mdt setting: [
				SELECT id, MasterLabel,
					(SELECT Id, Checkbox_Fieldname__c, Location_Class__c, Location_Type__c, Country__c
					FROM Portal_Application_Contacts_Visibility__r
					WHERE Remove_Service_On_Unchecked__c = true)
				FROM Portal_Application_Setting__mdt]) {
			for (Portal_Application_Contact_Visibility__mdt visibility: setting.Portal_Application_Contacts_Visibility__r) {
				Boolean newValue = Boolean.ValueOf(contactNew.get(visibility.Checkbox_Fieldname__c));
				Boolean oldValue = Boolean.ValueOf(contactOld.get(visibility.Checkbox_Fieldname__c));
				if (newValue==false && oldValue==true && contactNew.Account!=null
					&&( visibility.Location_Class__c == WILDCARD || visibility.Location_Class__c == contactNew.Account.Location_Class__c)
					&&( visibility.Location_Type__c == WILDCARD || visibility.Location_Type__c == contactNew.Account.Location_Type__c)
					&&( checkCountry(visibility.Country__c, contactNew.Account.Country_ISO_Code__c))
				) {
					setAppNames.add(setting.MasterLabel);
				}
			}
		}
		return new list<String>(setAppNames);
	}

	/**
	 * Test the input country passes the input rule
	 * the rule is stored in the field Country__c on the custom metadata Portal_Application_Setting__mdt
	 * and must be a list of iso country codes, comma separated
	 * if the character '-' is at the beginning then it returns the opposite value
	 * Finally, if the rule contains the keyword 'ALL' then it retures true always
	**/
	@TestVisible
	private static Boolean checkCountry(String rule, String isocode) {
		if (rule==WILDCARD) return true;
		Boolean invert = rule.startsWith('-');
		if (invert) {
			rule = rule.replace('-','');
		}
		Boolean result = rule.split(',').contains(isocode);
		return invert? !result: result;
	}
}
