@RestResource(urlMapping='/GSS/v0/Subscriptions/*')
global with sharing class GSS_REST_Subscriptions{

		@HttpGet
		global static void getActiveSubscription() {
				Integer BATCH_SIZE = 200;

				//Get the input parameters in the URL
				String SubscriptionID = RestContext.request.params.get('SubscriptionId');

				//In the case that there is no SubscriptionID, return first records
				if(SubscriptionID == '')             SubscriptionID = '000000000000000000';

				List<Zuora__Subscription__c> SubscriptionList = new List<Zuora__Subscription__c>();
				SubscriptionList = [SELECT Id
																 FROM Zuora__Subscription__c
																 WHERE Zuora__SubscriptionStartDate__c<= TODAY
																 AND ( Zuora__SubscriptionEndDate__c >=TODAY
																		OR ( Zuora__SubscriptionEndDate__c = null
																				AND  Zuora__TermSettingType__c = 'EVERGREEN'
																			)
																		)
																 AND Zuora__Status__c = 'Active'
																 AND Id>:SubscriptionID
																 ORDER BY Id
																 Limit :BATCH_SIZE];

				//Loop and inject data for each subscriptions
				SubscriptionCls ReturnSubscriptionList=new SubscriptionCls();
				for( Zuora__Subscription__c activesub:SubscriptionList)
				 {
					 Subscription sub = new Subscription(activesub.id);
					 ReturnSubscriptionList.Subscriptions.add(sub);
				 }
				//TODO: Get the file specification account criteria the object is to be defined
				//Prepare response
				try {
						RestContext.response.addHeader('Content-Type', 'application/json');
						RestContext.response.statuscode = 200;

						//Return ListOfSubscriptionId object
						RestContext.response.responseBody = Blob.valueOf(json.serialize(ReturnSubscriptionList));

						system.debug('RestContext.response.responseBody ' + json.serialize(ReturnSubscriptionList) );

				}
				Catch(exception e){
						RestContext.response.statuscode = 400;
						RestContext.response.responseBody  = Blob.valueOf( 'getCause()' + e.getCause() + '\n' + 'getMessage()' + e.getMessage() + '\n' +  'getLineNumber()' + e.getLineNumber() + '\n' +  'getStackTraceString()' + e.getStackTraceString() + '\n' + 'getTypeName()' + e.getTypeName() );
				}
		}
		Global Class SubscriptionCls
		{
		 public List<Subscription> Subscriptions {get;set;}
		 public SubscriptionCls()
		 {
				 Subscriptions= new List<Subscription>();
		 }
		}
		//Definition of the Json Body
		global Class Subscription
		{
		 public String SubscriptionId {get;set;}

		 public Subscription(Id vSubscriptionId)
		 {
				 SubscriptionId=vSubscriptionId;

			}
		}

		//Definition of JSON Body
		global class ListOfSubscriptionId {
				public List<Id> SubscriptionIds;

				public ListOfSubscriptionId(List<Id> l) {
						this.SubscriptionIds = l;
				}
		}

}
