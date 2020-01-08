public without sharing class ISSP_NewCase_RedirectController
{
		public ISSP_NewCase_RedirectController(ApexPages.StandardController controller) {
		}
		public ApexPages.StandardSetController standardController;
		public ISSP_NewCase_RedirectController (ApexPages.StandardSetController standardController)
		{
				this.standardController = standardController;
		}

		public String PartnerUserAccountId()
		{
			 User objUser=[Select Id,contactID from User where Id=:userinfo.getuserid()];
			 String url2return = '/500/e';
			 if(objUser.contactID!=null)  url2return = '/500/e?cas4_lkid=' + [Select AccountId from Contact where Id=:objUser.contactID].AccountId +'&retURL=ISSP_homePage';
			 return url2return ;
	 }
}
