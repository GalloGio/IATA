public with sharing class CaseFinancialSecuritiesCTRL {

		private final Case c;
		public list<Financial_Security__c> fs {get;private set;}

		public CaseFinancialSecuritiesCTRL(ApexPages.StandardController controller) {
									 if (!Test.isRunningTest())
									 	controller.addFields( new list<string>{'accountid'});
									 this.c=(case)controller.getRecord();

									 fs = new list<Financial_Security__c>();
									 for(Financial_Security__c f: [SELECT Id,Name,Status_image__c,Amount__c,
																												security_status__c,expiry_date__c,
																												Financial_institution__c,remarks__c ,Security_Type__c
																												from Financial_Security__c where Account__c =: c.accountid
																								 ])
																		fs.add(f);

		}

}
