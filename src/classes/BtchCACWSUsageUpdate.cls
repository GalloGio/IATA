/**
	* Description: This class to run daily for CAC Webservice usage
	* Author: Abdellah Bellahssan
	* Version: 1.0
	* History:
	*/

global class BtchCACWSUsageUpdate implements Database.Batchable<sObject>, Database.AllowsCallouts
{
		global String Response {get;set;}
		global Boolean IsTest {get;set;}
		global Class CACUsageItemCls
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
		public BtchCACWSUsageUpdate()
		{
				IsTest = false;
				Response = '';
		}
		global Database.QueryLocator start(Database.BatchableContext BC)
		{
				//if (IsTest==null)  IsTest=false;
			 // if (Response==null) Response='';
				String query = 'Select Id From CAC_Subscription_Detail__c Limit 1';
				return Database.getQueryLocator(query);
		}

		global void execute(Database.BatchableContext BC, List<CAC_Subscription_Detail__c> scope)
		{
				system.debug('IsTest-'+IsTest+' Response-'+Response+' scope-'+scope);
				list<CACUsageItemCls> usageList  = new list<CACUsageItemCls>();
				String url = IEC_Settings__c.getOrgDefaults().CAC_Web_Service_Usage_Url__c+'?code=usage';
				Map<String,String> headers = new Map<String,String>();
				headers.put('x-api-key',IEC_Settings__c.getOrgDefaults().CAC_Web_Service_API_Gateway__c);
				Integer dYear=System.Now().AddDays(-1).Year();
				Integer dMonth=System.Now().AddDays(-1).Month();
				Integer dDay=System.Now().AddDays(-1).Day();

				String QueryDate=String.ValueOf(dYear).Trim();
				if (dMonth<10) QueryDate +='0';
				QueryDate +=String.ValueOf(dMonth).Trim();
				if (dDay<10) QueryDate +='0';
				QueryDate +=String.ValueOf(dDay).Trim();

				headers.put('x-service-type',QueryDate);
				// Instantiate a new http object
				Http h = new Http();
				// Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
				HttpRequest req = new HttpRequest();
				req.setEndpoint(url);
				req.setMethod('GET');
				for(String hkey:headers.KeySet())
				{
					if (!IsTest) req.SetHeader(hkey, headers.get(hkey));
				}
				req.setTimeout(6000);
				// Send the request, and return a response
				HttpResponse res;
				if (!IsTest) res = h.send(req);
				String result='';
				if (!IsTest)  result=res.getBody();
				if (IsTest)  result=Response;
				System.Debug('Result : >>>'+result);
				usageList = (list<CACUsageItemCls>)JSON.deserialize(result, List<CACUsageItemCls>.class);

				List<IEC_Usage_Tracker_Live__c> ulist=new List<IEC_Usage_Tracker_Live__c>();
				//Build List of unique CAC Subscription Detail
				Set<String> cacset = new Set<String>();
				for (CACUsageItemCls u:usageList)
				{
						 cacset.add(u.service_product);
				}
				//Query the CAC Subscription Record

				Map<ID, CAC_Subscription_Detail__c> CACDetailMap = new Map<ID, CAC_Subscription_Detail__c>(
				[select  id
												, Name
												, Max_API_Call_Per_Month__c
												, Service_Specification__r.Reference__r.Payload_Procedure__c
												, Service_Specification__r.Reference__r.Product_Type__c
									 From CAC_Subscription_Detail__c
									 Where id=:cacset
									 Limit 10000]);


				//Process the usage to record them under the right CAC Subscription Record
				for (CACUsageItemCls u:usageList)
				{
					CAC_Subscription_Detail__c theObj = new CAC_Subscription_Detail__c();
					theObj = CACDetailMap.get(u.service_product);

					Integer Year = Integer.ValueOf(u.request_period.substring(0,4));
					Integer Month = Integer.ValueOf(u.request_period.substring(4,6));
					Integer Day = Integer.ValueOf(u.request_period.substring(6,8));
					DateTime usageDate = DateTime.newInstance(Year, Month, Day, 0, 0, 0);
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
		}


		global void finish(Database.BatchableContext BC)
		{
				 //call the usage computing batch at the end
		}
}
