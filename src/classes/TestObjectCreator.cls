@isTest
public without sharing class TestObjectCreator {

    public static List<FAQ__kav> createFAQArticles(Integer size)
    {
        List<FAQ__kav> lstFaqs = new List<FAQ__kav>();
        for (Integer i = 0; i < size; ++i)
        {
            FAQ__kav faq = new FAQ__kav(Language='fr', UrlName='test' + i, IsVisibleInPkb=true, Title='test' + i);
            lstFaqs.add(faq);
        }

        insert lstFaqs;
        return [SELECT Id, KnowledgeArticleId, Language, UrlName, Title FROM FAQ__kav WHERE Language = 'fr' AND PublishStatus = 'Draft'];
    }

    public static List<FAQ__DataCategorySelection> createFAQArticlesCategories(List<FAQ__kav> lstFaqs, String groupName, String topic)
    {
        List<FAQ__DataCategorySelection> lstFaqsCategories = new List<FAQ__DataCategorySelection>();
        for (Integer i = 0; i < lstFaqs.size(); ++i)
        {
            FAQ__DataCategorySelection faqCategorie = new FAQ__DataCategorySelection(DataCategoryGroupName = groupName, DataCategoryName=topic, ParentId = lstFaqs[i].Id);
            lstFaqsCategories.add(faqCategorie);
        }

        insert lstFaqsCategories;
        return lstFaqsCategories;
    }


	public static Portal_Application_Right__c buildPortalApplicationRight(ID contId, ID applicationId) {
		return buildPortalApplicationRight(contId, applicationId, 'Access Requested');
	}
	
	
	public static Portal_Application_Right__c buildPortalApplicationRight(ID contId, ID applicationId, String right) {
		return 
			new Portal_Application_Right__c(Contact__c = contId,
		                                Portal_Application__c = applicationId,
		                                Right__c = right);
	}
	
	public static Portal_Applications__c buildPortalApplications(String appName) {
		return 
			new Portal_Applications__c(Name = appName);
	}

    public static Portal_Applications__c buildPortalApplications2(String appName) {
        return 
            new Portal_Applications__c(
                    Name = appName,
                    ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.CARGO_AGENT,
                    ANG_Accredited_Agents_Only__c = false,
                    Agency__c = true,
                    Cannot_be_managed_by_portal_admin__c = false                
                );
    }

	/**
     * Create User Object.
     * @param  licenseType User License Type
     * @return             Instance of User object.
     */
    public static User CreateUser(String licenseType){
        
        String profileId = '';
        Profile p = null;
        p = [SELECT Id FROM Profile WHERE profile.UserLicense.Name = : licenseType  LIMIT 1 ];
        User u = new User();
        if(p!=null){
            profileId = p.Id;
            u.FirstName='Barak';
            u.LastName='Test';
            u.Alias='BTest';
            u.Username='barak.inbal.2.kerensen.com@partner.iata.org';
            u.Email='barak.inbal.2.@kerensen.com';
            u.TimeZoneSidKey='Europe/Paris';
            u.LocaleSidKey='fr_FR_EURO';
            u.EmailEncodingKey='ISO-8859-1';
            u.ProfileId = profileId;
            u.LanguageLocaleKey='en_US';
            u.UserPermissionsMobileUser=false;

            insert u;
            return u;
         }

         return u;
     }

     /**
      * Create Account Object.
      * @param  u User Object.
      * @return   Instance of Account Object.
      */
	public static Account CreateAccount(User u){

		Account a = new Account();
        
        System.runAs(u){
        	a.Owner = u;
            a.Name='Acc_1';
            insert a;
        }

        return a;
	}

	  /**
     * Create Contact Object for testing.
     * @param  u        User object.
     * @param  a        Account object.
     * @param  commitInsert Boolean flag to insert to database or not.
     * @return          Instance of Account object.
     */
    public static Contact CreateContact(User u,Account a){

        Contact c       = new Contact();

        System.runAs(u) {
        	c.Account 		=  a;
        	c.Owner 		=  u;
            c.AccountId     =  a.Id;
            c.FirstName     = 'CFName_1';
            c.LastName      = 'CLName_1';
            c.Email         = 'barak.inbal@kerensen.com';
            c.Phone         = '0552229333';
            insert c;
        }  

        return c;  
    }

}