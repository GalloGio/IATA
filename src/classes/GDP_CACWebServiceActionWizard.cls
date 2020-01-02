public with sharing class GDP_CACWebServiceActionWizard {

		public CAC_Subscription_Detail__c theObj {get;set;}
		public List<CAC_Subscription_Detail__c> CACSubscriptionItemList {get;set;}
		private Integer Counter=0;
		public String toSelect {get; set;}
		public String toUnselect {get; set;}
		public Boolean FlagMessage {get; set;}
		public String ErrorMessage {get;set;}
		public String faction {get;set;}
		public String Response {get;set;} // simulate response
		public boolean isTest {get;set;}  // simulate
		public String idc {get;set;}
		public String AllCACWebService {get;set;}
		public boolean ErrorFlag {get;set;}

		public GDP_CACWebServiceActionWizard(ApexPages.StandardController controller) {
				faction='';
				Response='';
				isTest=false;
				FlagMessage=false;
				idc=String.escapeSingleQuotes(controller.getRecord().Id);
				theObj = [select id
												, Name
												, Max_API_Call_Per_Month__c
												, Service_Specification__c
												, Service_Specification__r.Reference__r.Payload_Procedure__c
												, Service_Specification__r.Reference__r.Product_Type__c
												, Service_Token__c
												, Actions__c
												, Subscription__c
												, Credit__c
												, Status__c
									 From CAC_Subscription_Detail__c
									 Where Id =:idc limit 1];
				LoadDLI();

		}

		public String getCACActions()
		{
		 String options = '';
		 Schema.DescribeFieldResult fieldResult = CAC_Subscription_Detail__c.Actions__c.getDescribe();
		 List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			 for( Schema.PicklistEntry f : ple)
			 {
					options += '"'+f.getLabel()+'","'+f.getLabel()+'",';
			 }
			 return options;
		}


		public void LoadDLI()
		{
				CACSubscriptionItemList=new List<CAC_Subscription_Detail__c>();

				List<CAC_Subscription_Detail__c> clist=new List<CAC_Subscription_Detail__c>();
				clist = [select  id
												, Name
												, Max_API_Call_Per_Month__c
												, Service_Specification__c
												, Service_Token__c
												, Actions__c
												, Subscription__c
												, Status__c
									 From CAC_Subscription_Detail__c
									 Where Subscription__c=:theObj.Subscription__c

									 Limit 1000];

				AllCACWebService='';
				for(CAC_Subscription_Detail__c cli:clist)
				{
					if (cli.Status__c=='Suspended') continue;
					AllCACWebService += String.ValueOf(cli.Id)+ ',';
					if (cli.id==theobj.Id) continue;
					CACSubscriptionItemList.add(cli);
				}


		}

		public PageReference GoBack()
		{
		 return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
		}
		public PageReference RDSAction()
		{
		 if (!SaveCASubscriptionItemList()) { return null;}
		 return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));

		}
		private boolean SaveCASubscriptionItemList()
		 {
			ErrorMessage='';
			list<CACUsageItemCls> usageList  = new list<CACUsageItemCls>();
			flagmessage=false;
			if (faction=='') return false;
			if (AllCACWebService=='') AllCACWebService=String.ValueOf(theObj.Id);
			Map<String,String> headers= new Map<String,String>();
			String typerequest='subscription';
			if (faction=='Recover Usage') typerequest='usage';
			if (faction=='Apply Credit') typerequest='credit';
			String url = IEC_Settings__c.getOrgDefaults().CAC_Web_Service_Usage_Url__c+'?code='+typerequest;
			headers.put('x-api-key',IEC_Settings__c.getOrgDefaults().CAC_Web_Service_API_Gateway__c);
			headers.put('x-service-token',theObj.Service_Token__c);
			if (faction!='Apply Credit') headers.put('x-service-max',String.ValueOf(theObj.Max_API_Call_Per_Month__c));
			if (faction=='Apply Credit') headers.put('x-service-max',String.ValueOf(theObj.Credit__c));
			System.Debug('Id >>>'+theObj.Id);

			if (faction!='Suspend All the Web Services') headers.put('x-service-api',theObj.Id);

			if (faction=='Suspend All the Web Services') headers.put('x-service-api',AllCACWebService);
			if (faction=='Apply Credit') headers.put('x-service-type',String.ValueOf(theObj.Service_Specification__c));

			if (faction=='Update Subscription, Limit and Token') headers.put('x-service-type',String.ValueOf(theObj.Service_Specification__c));
			if (faction=='Suspend this Web Service') headers.put('x-service-type','suspend');
			if (faction=='Suspend All the Web Services') headers.put('x-service-type','suspend');
			Integer dYear=System.Now().Year();
			Integer dMonth=System.Now().Month();
			Integer dDay=System.Now().Day();

			String QueryDate=String.ValueOf(dYear).Trim();
			if (dMonth<10) QueryDate +='0';
			QueryDate +=String.ValueOf(dMonth).Trim();
			if (dDay<10) QueryDate +='0';
			QueryDate +=String.ValueOf(dDay).Trim();
			System.Debug('QueryDate >>>'+QueryDate);
			if (faction=='Recover Usage')  headers.put('x-service-type',QueryDate);
			try {
					String result=getCalloutResponseContents(url,  headers);

					if (faction=='Recover Usage')
						 usageList = (list<CACUsageItemCls>)JSON.deserialize(result, List<CACUsageItemCls>.class);
					else
					if (result!='{"Result":"done"}') FlagMessage=true;

					}
			catch (CalloutException ex)
			{
				FlagMessage=true;
			}
			if (faction=='Recover Usage')
			{
				//process the usage and return true because there is no update;
				List<IEC_Usage_Tracker_Live__c> ulist=new List<IEC_Usage_Tracker_Live__c>();
				System.Debug('Usage >>>'+usageList);
				for (CACUsageItemCls u:usageList)
				{
					Integer Year = Integer.ValueOf(u.request_period.substring(0,4));
					Integer Month = Integer.ValueOf(u.request_period.substring(4,6));
					Integer Day = Integer.ValueOf(u.request_period.substring(6,8));
					DateTime usageDate = DateTime.newInstance(Year, Month, Day, 0, 0, 0);
					System.Debug('Usage >>>'+u);
					if (Integer.ValueOf(u.goodapi_counter)<>0) {
							IEC_Usage_Tracker_Live__c usage=new IEC_Usage_Tracker_Live__c();
							usage.CAC_Web_Service_Id__c = u.uniqueid+'-Valid';
							usage.Related_Application_Type__c =theObj.Service_Specification__r.Reference__r.Product_Type__c;
							if (usage.Related_Application_Type__c==null) usage.Related_Application_Type__c ='CACSWS';
							usage.Counter__c=Integer.ValueOf(u.goodapi_counter);
							usage.CAC_Subscription_Detail__c=u.service_product;
							usage.Search_Status__c='Valid';
							usage.Search_Target__c='Agency';
							usage.Date__c=usageDate;
							usage.Authorized_Consumption__c=theObj.Max_API_Call_Per_Month__c;
							if (Integer.ValueOf(u.api_max)>0) usage.Authorized_Consumption__c=Integer.ValueOf(u.api_max);
							if (theObj.Service_Specification__r.Reference__r.Payload_Procedure__c!='Agency') usage.Search_Target__c='Agent';

							ulist.add(usage);
							}
					 if (Integer.ValueOf(u.badapi_counter)<>0) {
							IEC_Usage_Tracker_Live__c usage=new IEC_Usage_Tracker_Live__c();
							usage.CAC_Web_Service_Id__c = u.uniqueid+'-Invalid';
							usage.Related_Application_Type__c =theObj.Service_Specification__r.Reference__r.Product_Type__c;
							if (usage.Related_Application_Type__c==null) usage.Related_Application_Type__c ='CACSWS';

							usage.Counter__c=Integer.ValueOf(u.badapi_counter);
							usage.CAC_Subscription_Detail__c=u.service_product;
							usage.Search_Status__c='Invalid';
							usage.Search_Target__c='Agency';
							usage.Date__c=usageDate;

							usage.Authorized_Consumption__c=theObj.Max_API_Call_Per_Month__c;
							if (Integer.ValueOf(u.api_max)>0) usage.Authorized_Consumption__c=Integer.ValueOf(u.api_max);
							if (theObj.Service_Specification__r.Reference__r.Payload_Procedure__c!='Agency') usage.Search_Target__c='Agent';


							ulist.add(usage);
							}

				}
				Schema.SObjectField f = IEC_Usage_Tracker_Live__c.Fields.CAC_Web_Service_Id__c;
				if (ulist.size()>0) Database.UpsertResult [] cr = Database.upsert(ulist, f, false);
				//if (ulist.size()>0) insert ulist;
				return true;
			}
			ErrorMessage='Synchronization did not happened.';
			if (FlagMessage) return false;
			if (faction=='Apply Credit')
				 {
					CAC_Process.CACCreditProcess=true;
					CAC_Subscription_Credit__c credit = new CAC_Subscription_Credit__c();
					credit.Credit__c=theObj.Credit__c;
					credit.Date__c  =System.Today();
					credit.CAC_Subscription_Detail__c=theObj.id;
					insert credit;
					CAC_Process.CACCreditProcess=false;
					theObj.Credit__c=0;
					}
			if (faction=='Update Subscription, Limit and Token') theObj.Status__c='Active';
			if (faction=='Suspend this Web Service') theObj.Status__c='Suspended';
			if (faction=='Suspend All the Web Services') theObj.Status__c='Suspended';

			update theObj;
			if (faction!='Suspend All the Web Services') return true;
			for(CAC_Subscription_Detail__c cli:CACSubscriptionItemList)
				{

					cli.Status__c='Suspended';

				}
			update CACSubscriptionItemList;
			if (FlagMessage) return false;
			return true;
		}

		// Pass in the endpoint to be used using the string url
		public String getCalloutResponseContents(String url, Map<String,String> headers) {
				// Instantiate a new http object
				Http h = new Http();
				// Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
				HttpRequest req = new HttpRequest();
				req.setEndpoint(url);
				req.setMethod('GET');
				for(String hkey:headers.KeySet())
				{
					if (!isTest) req.SetHeader(hkey, headers.get(hkey));
				}
				req.setTimeout(6000);
				// Send the request, and return a response
				if (isTest) return Response;
				HttpResponse res = h.send(req);
				System.Debug('Result : >>>'+res.getBody());
				return res.getBody();

	 }
		/*
			 Sample Json Usage Structure
		[
				 {
						"uniqueid": "16",
						"service_specification": "a6G8E00000001TSUAY",
						"service_product": "a5Hg0000000NgwwEAC",
						"response_type": "",
						"request_period": "20160215",
						"api_counter": "21",
						"api_max":"250",
						"goodapi_counter": "0",
						"badapi_counter": "0"
					},....
		]
		*/

		public Class CACUsageItemCls
		{
		 public String service_specification {get;set;}
		 public String service_product {get;set;}
		 public String response_type {get;set;}
		 public String request_period {get;set;}
		 public String api_counter {get;set;}
		 public String api_max {get;set;}
		 public String goodapi_counter {get;set;}
		 public String badapi_counter {get;set;}
		 public String uniqueid {get;set;}

			public CACUsageItemCls()
			{

			}

		}

}
