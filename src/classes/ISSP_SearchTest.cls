@isTest
private class ISSP_SearchTest {


	private static testMethod void test001() {

		ISSPPortalSearchListView__c accSetting  = new ISSPPortalSearchListView__c(Name = 'AccountTest');
		accSetting.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
		accSetting.Object_API_Name__c = 'Account';
		accSetting.Field_Set_Table_Columns__c = 'Test';

		ISSPPortalSearchListView__c contSetting  = new ISSPPortalSearchListView__c(Name = 'ContactTest');
		contSetting.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
		contSetting.Object_API_Name__c = 'Contact';
		contSetting.Field_Set_Table_Columns__c = 'Test';

		ISSPPortalSearchListView__c caseSetting  = new ISSPPortalSearchListView__c(Name = 'CaseTest');
		caseSetting.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
		caseSetting.Object_API_Name__c = 'Case';
		contSetting.Field_Set_Table_Columns__c = 'Test';

		insert new ISSPPortalSearchListView__c[] {accSetting, contSetting, caseSetting};

	 	ISSP_SearchResultCO theSearchResult = new ISSP_SearchResultCO();
	 	theSearchResult.searchGet();
	 	theSearchResult.searchPost();

	 	theSearchResult.searchText = 'test';
	 	theSearchResult.qlSearch();
	}

	private static testMethod void test002() {

		ISSPPortalSearchListView__c contSetting  = new ISSPPortalSearchListView__c(Name = 'ContactTest');
		contSetting.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
		contSetting.Object_API_Name__c = 'Contact';
		contSetting.Field_Set_Table_Columns__c = 'ISSP_Contacts_MyCompanyContacts';
		contSetting.Field_Set_Filter__c = 'ISSP_Contacts_MyCompanyContacts';

		ISSPPortalSearchListView__c caseSetting  = new ISSPPortalSearchListView__c(Name = 'CaseTest');
		caseSetting.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
		caseSetting.Object_API_Name__c = 'Case';
		caseSetting.Field_Set_Table_Columns__c = 'ISSP_MyOpenCases';
		caseSetting.Field_Set_Filter__c = 'ISSP_MyOpenCases';

		insert new ISSPPortalSearchListView__c[] {contSetting, caseSetting};

	 	ISSP_SearchResultCO theSearchResult = new ISSP_SearchResultCO();
	 	//theSearchResult.searchGet();
	 	//theSearchResult.searchPost();

	 	//theSearchResult.searchText = '1000';
	 	theSearchResult.search('100');
	}


	private static testMethod void test003() {

		PermissionSet ps = new PermissionSet();
		ps.Name = 'test';
		ps.Label = 'test';
		insert ps;

		PermissionSetAssignment saas = new PermissionSetAssignment();
		saas.PermissionSetId = ps.Id;
		saas.AssigneeId = UserInfo.getUserId();

		ISSPPortalSearchListView__c contSetting  = new ISSPPortalSearchListView__c(Name = 'ContactTest');
		contSetting.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
		contSetting.Object_API_Name__c = 'Contact';
		contSetting.Field_Set_Table_Columns__c = 'ISSP_Contacts_MyCompanyContacts';
		contSetting.Field_Set_Filter__c = 'ISSP_Contacts_MyCompanyContacts';
		contsetting.Permission_set__c = ((String)ps.Id).substring(0,15);

		ISSPPortalSearchListView__c caseSetting  = new ISSPPortalSearchListView__c(Name = 'CaseTest');
		caseSetting.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
		caseSetting.Object_API_Name__c = 'Case';
		caseSetting.Field_Set_Table_Columns__c = 'ISSP_MyOpenCases';
		caseSetting.Field_Set_Filter__c = 'ISSP_MyOpenCases';
		caseSetting.Permission_set__c = ((String)ps.Id).substring(0,15);
		ISSPPortalSearchListView__c[] csList = new ISSPPortalSearchListView__c[] {contSetting, caseSetting};

		ISSP_PermissionFilterFactory.ProfilePermissionFilter ppf = ISSP_PermissionFilterFactory.createProfilePermissionFilter();
		ppf.isDataEmpty(contSetting, 'Profiles_Id__c');
		ppf.isUserPermittedFor(contSetting, 'Profiles_Id__c');
		ppf.isDataEmpty(caseSetting, 'Profiles_Id__c');
		ppf.isUserPermittedFor(caseSetting, 'Profiles_Id__c');

		ISSP_PermissionFilterFactory.PermissionSetFilter psf = ISSP_PermissionFilterFactory.createPermissionSetFilter(csList, 'Permission_set__c');
		psf.isDataEmpty(contSetting, 'Permission_set__c');
		psf.isUserPermittedFor(contSetting, 'Permission_set__c');
		psf.isDataEmpty(caseSetting, 'Permission_set__c');
		psf.isUserPermittedFor(caseSetting, 'Permission_set__c');

	}


}
