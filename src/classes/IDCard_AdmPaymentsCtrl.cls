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
			Date dt = Date.today().toStartOfMonth().addYears(-2);
			Time tm = Time.newInstance(0,0,0,0);
            DateTime dttm = DateTime.newInstanceGMT(dt, tm);
            String twoYearsAgo = dttm.formatGMT('yyyy-MM-dd') + 'T' + dttm.formatGMT('HH:mm:ss.SSS') + 'Z';
			String iataCodeSubstring ='';
			boolean b = false;
			for(String aCode:keyContactAndDelegateForAccountList.keySet()){
				iataCodeSubstring = iataCodeSubstring + (b?' or IATA_code__c = ':' IATA_code__c = ')+ ' \''+aCode+'\' ';
				b = true;
		 	}
			string IdCardApplicationQuery = 'SELECT '+ TransformationHelper.getAllFields(Schema.SObjectType.ID_Card_Application__c.fields.getMap())+' FROM ID_Card_Application__c WHERE recordTypeId = \''+ massAppRT + '\' and ('+iataCodeSubstring+') and CreatedDate >= ' + twoYearsAgo;
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
			applicationToCancel = [SELECT id, Mass_order_Application__c, Application_Status__c,ID_Card_Fee_Discount__c,ITDI_Courses_Fee__c, IDCard_Expedite_Delivery_Fee__c, ID_Card_Fee__c, Applicable_Fee__c,Physical_Card_Fee__c, Promotion_Code__c from ID_Card_Application__c where Mass_order_Application__c = : toCancel];

			String promotionCode;

			for(ID_Card_Application__c app:applicationToCancel){
				if(String.isNotBlank(app.Promotion_Code__c)){
					promotionCode = app.Promotion_Code__c;
					break;
				}
			}
			List<Promotion__c> listPromotion = new List<Promotion__c>();
			if(String.isNotBlank(promotionCode)){
				listPromotion = [SELECT Id, Promotion_Code__c, Promotion_Value__c FROM Promotion__c WHERE Promotion_Code__c = : promotionCode LIMIT 1];
			}
			List<ID_Card_Application__c> listToUpdate = new List<ID_Card_Application__c>();
			for(ID_Card_Application__c app:applicationToCancel) {
				app.Mass_order_Application__c = null;
				app.Application_Status__c = 'Pending';
				if(String.isNotBlank(app.Promotion_Code__c)){
					if(app.ID_Card_Fee_Discount__c != null) app.ID_Card_Fee_Discount__c = app.ID_Card_Fee_Discount__c * 100 / (100+listPromotion[0].Promotion_Value__c);
					if(app.ID_Card_Fee__c != null) app.ID_Card_Fee__c = app.ID_Card_Fee__c * 100 / (100-listPromotion[0].Promotion_Value__c);
					if(app.Physical_Card_Fee__c != null) app.Physical_Card_Fee__c = app.Physical_Card_Fee__c * 100 / (100-listPromotion[0].Promotion_Value__c);
					app.Applicable_Fee__c = app.ID_Card_Fee__c + app.Physical_Card_Fee__c + app.IDCard_Expedite_Delivery_Fee__c + app.ITDI_Courses_Fee__c;
					app.Promotion_Code__c = '';
				}
				listToUpdate.add(app);
			}

			for(ID_Card_Application__c app:IdCardApplications) {
				if(app.Id == toCancel){
					app.Application_Status__c = 'Cancelled';
					listToUpdate.add(app);
				}
			}
			update listToUpdate;
		}

		toCancel = null;
		loadContent();
		return null;
	}
}
