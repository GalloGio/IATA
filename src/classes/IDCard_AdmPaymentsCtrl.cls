public class IDCard_AdmPaymentsCtrl extends IDCardAbstractController {

	public list<ID_Card_Application__c> IdCardApplications {get; set;}
	public list<ID_Card_Application__c> applicationToCancel {get; set;}
	public Map<String, list<ID_Card_Application__c>> singleAppsPerMassApps  {get;set;}
	public Map<String, Contact> contacts  {get;set;}
	public Map<String, case> cases  {get;set;}
	public string caseskeyset {get;set;}
	public String toCancel {get;set;}

	public IDCard_AdmPaymentsCtrl() {
		initialize(true);
		loadContent();
	}

	private void loadContent() {
		try {
			String massAppRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');
			if(Test.isRunningTest()){
			 	iataCodeParameter = '76543210';
			}
			// Get all Id Card application created on the first day of the current month two years ago
			Date twoYearsAgo = Date.today().toStartOfMonth().addYears(-2); 

			String iataCodeSubstring ='';
			boolean b = false;
			for(String aCode:keyContactAndDelegateForAccountList.keySet()){
				iataCodeSubstring = iataCodeSubstring + (b?' or IATA_code__c = ':' IATA_code__c = ')+ ' \''+aCode+'\' ';
				b = true;
		 	}
			string IdCardApplicationQuery = 'SELECT '+ TransformationHelper.getAllFields(Schema.SObjectType.ID_Card_Application__c.fields.getMap())+' FROM ID_Card_Application__c '+' WHERE recordTypeId = \''+ massAppRT + '\' and ('+iataCodeSubstring+') and CreatedDate >= ' + twoYearsAgo;
			system.debug('[PAYMENTCTRL] PAYMENT Query '+IdCardApplicationQuery);

			IdCardApplications = (list<ID_Card_Application__c>)(database.query(IdCardApplicationQuery));
			List<String> cids = new List<String>();
			
			if(IdCardApplications == null || IdCardApplications.size() == 0)
				throw new TransformationException('No Payments found ');
			//single cards details
			singleAppsPerMassApps = new Map<String, list<ID_Card_Application__c>>();
			
			for(ID_Card_Application__c mass:IdCardApplications){
		 		system.debug('[PAYMENTCTRL] add new item to Map '+mass.Id);
		 		singleAppsPerMassApps.put(mass.Id, new List<ID_Card_Application__c>());
		 		cids.add(mass.VER_Number__c);
			}

			List<Case> relatedCases = [SELECT Related_ID_Card_Application__c , CaseNumber, Id, Status FROM Case where Related_ID_Card_Application__c in: singleAppsPerMassApps.keySet()];
			cases = new Map<String,Case>();
			caseskeyset = '';

			for(case c:relatedCases){
			 	cases.put(c.Related_ID_Card_Application__c,c);
				caseskeyset += c.Related_ID_Card_Application__c;
			}

		}catch(TransformationException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info, e.getmessage()));
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info, 'Unexpected error: please contact our support: ' +e.getMessage() + ' :: ' + e.getLineNumber()));
		}
	}

	public Pagereference cancelPendingMassOperation() {
		if(toCancel !=null) {
			applicationToCancel = [SELECT id, Mass_order_Application__c, Application_Status__c from ID_Card_Application__c where Mass_order_Application__c = : toCancel];

			for(ID_Card_Application__c app:applicationToCancel)    {
				app.Mass_order_Application__c = null;
				app.Application_Status__c = 'Pending';
			}

			update 	applicationToCancel;
			for(ID_Card_Application__c app:IdCardApplications)    {
				if(app.Id == toCancel){
					app.Application_Status__c = 'Cancelled';
					update app;
				}
			}
		}

		toCancel = null;
		loadContent();
		return null;
	}
}
