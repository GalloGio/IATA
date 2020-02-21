public without sharing class  IECFirstLoginCtrl{

					 private string userName {get;set;}
					 private string passWord {get;set;}
					 private boolean logMeIn {get;set;}
					 private User u {get;set;}
					 public string ids = '';

		public IECFirstLoginCtrl(){

					 // u = new User();
						logMeIn = false;

		try{        list<User> us;

								String parameters = ApexPages.currentPage().getParameters().get('c');
								 parameters =  Encodingutil.urlDecode( Comm_User_Helper.DecryptString(parameters),'UTF-8') ;
								list<string> paramList =  parameters.split(Comm_User_Helper.SEPARATOR,-1);
								userName =paramList[0];
								passWord =paramList[1];
								string UID =paramList[2];
								userName = userName.replace( Comm_User_Helper.plusReplacer,'+');
								if (!String.isEmpty(userName)) {

										us = [Select Id, Username, LastLoginDate,UID__c from user where username =:userName OR email =:userName  ];

										if(us<> null && us.size()>0)
										if(us[0].UID__c == UID){
												logMeIn = true;
												 ids = us[0].id;

										}

								}


				 }catch(Exception ex){
				 //   throw new transformationException('' + ex.getMessage());
							logMeIn = false;

				 }

		}



		public PageReference DoNext(){

				if(logMeIn) return this.changePassword();

				return this.home();




		}


		 private PageReference home(){

								Pagereference pr = Page.IECLogin;

								pr.setRedirect(true);
								return pr;




		}



		private PageReference changePassword(){

					//  updateUsers(ids);
						Pagereference pr =  !test.isRunningTest() ? site.login(userName,passWord,'/IECChangePassword'): Page.IECChangePassword;
						pr.setRedirect(true);
						return pr;



			 }



}
