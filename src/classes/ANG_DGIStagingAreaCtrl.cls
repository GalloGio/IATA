public without sharing class ANG_DGIStagingAreaCtrl {

	@TestVisible private static final String FINANCIAL_SECURITY_ERROR_MESSAGE = 'Please select a GDI Financial Security of this Account in status "Active", "Close to Expiry Date" or "Not Active yet".';
	
	private static final List<String> FINANCIAL_SECURITY_ACTIVE_STATUS = new List<String>{
		AMS_Utils.FINANCIAL_SECURITY_STATUS_ACTIVE, 
		AMS_Utils.FINANCIAL_SECURITY_STATUS_CLOSE_EXPIRY, 
		AMS_Utils.FINANCIAL_SECURITY_STATUS_NOT_ACTIVE	
	};

	public String amazonFileEId { 
		get{

			if(this.stagingFs != null){

				List<AmazonFile__c> files = [Select Id, Full_Name_Unique__c from AmazonFile__c where sObject_Id__c = :this.stagingFs.Id LIMIT 1];

				if(files.isEmpty())
					return null;

				String toReturn = AMS_OSCAR_Attachments.getExpiringLinkWS(files.get(0).Full_Name_Unique__c);

				return toReturn;
			}

			return null;
		}
		set;
	}

	public Boolean hasErrorMessages { get { return ApexPages.hasMessages(); } }

	private Opportunity opp{get;set;}

	public Id newFSId{get;set;}

	public Financial_Security__c currentFS {
		get{
			List<Financial_Security__c> toReturn = new List<Financial_Security__c>();

			if(currentFs != null && stagingFs != null && stagingFs.Financial_Security__c != null && currentFS.Id <> stagingFs.Financial_Security__c){
				toReturn = fetchFinancialSecurityGDI(stagingFs.Financial_Security__c, null);
			}
			else if(currentFs == null){
				toReturn = fetchFinancialSecurityGDI(null, stagingFs.OSCAR_GDI__r.Account__c);
			}

			if(!toReturn.isEmpty()){
				currentFS = toReturn.get(0);
				if(stagingFs != null && currentFS != null){
					this.stagingFs.Financial_Security__c = currentFS.Id;
				}
			}

			return currentFS;
		}
		set;
	}

	private List<Financial_Security__c> fetchFinancialSecurityGDI(Id fsId, Id accountId) {
		String fsQuery = 'SELECT Id, Amount__c, Account__c, Reception_Case__c, Security_Type__c, Security_Status__c'
			+ ' FROM Financial_Security__c WHERE ';
		String securityTypeGdi = AMS_Utils.FINANCIAL_SECURITY_TYPE_GDI;
		
		if (fsId != null) {
			fsQuery += ' Id = :fsId ';
		} else {
			fsQuery += ' Account__c = :accountId ';
			fsQuery += ' AND Security_Type__c = :securityTypeGdi';
			fsQuery += ' AND Security_Status__c IN :FINANCIAL_SECURITY_ACTIVE_STATUS ';
			fsQuery += ' ORDER BY CreatedDate DESC LIMIT 1';
		}
		
		return Database.query(fsQuery);
	}

	private boolean isValidFS(){
		return (currentFS.Account__c == stagingFs.OSCAR_GDI__r.Account__c && currentFS.Security_Type__c == AMS_Utils.FINANCIAL_SECURITY_TYPE_GDI
			&& FINANCIAL_SECURITY_ACTIVE_STATUS.contains(currentFS.Security_Status__c));
	}

	public boolean hasAdendum {get;set;}

	public AMS_OSCAR__c oscarObj {get;set;}

	public final Case oscarCase {get{

		if(this.oscarCase == null && oscarObj != null)
			return [Select Id, Origin, ParentId from Case where Id = :oscarObj.Oscar_Communication_Case_Id__c].get(0);

		return oscarCase;
	}set;}

	public boolean oscarProcessed {
		get{
			boolean toReturn = oscarObj.step50__c == AMS_Utils.PASSED || oscarObj.step50__c == AMS_Utils.FAILED;

			if(toReturn)
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'This process is completed - No action needed.'));

			return toReturn;
		}
		set;
	}

	public Opportunitylineitem stagingFs{get;set;}

	public List<String> stagingAreaFields {
		get{
			return new List<String>{'Amount__c','Expiry_Date__c','Financial_Institution__c','Reception_Case__c','Reception_Date__c','Region__c','Security_Type__c','Security_Status__c','Validity_Start_Date__c'};
		}
		set;
	}

	public boolean waitingForEndorsement {get{

		Boolean toReturn = (stagingFs == null || stagingFs.Id == null) &&  oscarCase.Origin == AMS_Utils.CASE_ORIGIN_GDI_PORTAL;

		if(toReturn){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'The certificate of endorsement has not been received from GDI yet'));
		}

		return toReturn;

	}set;}

	public boolean addCertificate{get;set;}

	private Financial_Institution__c dfltFI {get{
		if(dfltFI == null)
			dfltFI = [Select id from Financial_Institution__c where name = 'GDI - Euler Hermes'];

		return dfltFI;
	}set;}


	// The extension constructor initializes the private member
	// variable mysObject by using the getRecord method from the standard
	// controller.
	public ANG_DGIStagingAreaCtrl() {

		hasAdendum = false;

		Id oscarId = ApexPages.currentPage().getParameters().get('id');

		if(oscarId == null) return;

		this.oscarObj = [Select Id, step50__c, Account__c, Oscar_Communication_Case_Id__c from AMS_OSCAR__c where Id=:oscarId];

		fetchStagingFs(null, oscarId);

		if(stagingFs != null && currentFS != null){
			this.stagingFs.Financial_Security__c = currentFS.Id;
		}

	}

	@TestVisible private void fetchStagingFs(Id stagingFsId, Id oscarId){

		if(stagingFsId == null && oscarId == null) return;

		List<String> fieldListoli = new List<String>();

		Map<String, Schema.SObjectField> schemaFieldMapContacts = Opportunitylineitem.sObjectType.getDescribe().fields.getMap();

		for (String field : schemaFieldMapContacts.keySet()){
			fieldListoli.add(field);
		}

		String query = 'SELECT '+ String.join(fieldListoli, ', ') + ' , OSCAR_GDI__r.Name, OSCAR_GDI__r.Account__c FROM Opportunitylineitem WHERE ';

		if(stagingFsId != null){
			query += ' Id = :stagingFsId ';
		}
		else if(oscarId != null){
			query += ' OSCAR_GDI__c = :oscarId ';
		}
		
		List<OpportunityLineItem> oppLineItemLst = (List<OpportunityLineItem>) Database.query(query);

		if(!oppLineItemLst.isEmpty()){
			stagingFs = oppLineItemLst.get(0);
		}

	}

	public void accept(){

		addCertificate = true;
		try{
			Case oscarCase = [Select id, ParentId from Case where OSCAR__c = :stagingFs.OSCAR_GDI__c];

			//set the status of the "Confirm Financial Security Information" in the GDI OSCAR as "Passed"
			AMS_OSCAR__c oscar = new AMS_OSCAR__c (Id =stagingFs.OSCAR_GDI__c);
			oscar.step50__c = AMS_Utils.PASSED;
			oscar.status__c = AMS_Utils.OSCAR_CLOSED;
			update oscar;

			if(hasAdendum)
				performAcceptancewithAdendum(oscarCase);
			else
				createNewFinancialSecurity(oscarCase);

			if(newFsId != null){
				stagingFs.Financial_Security__c = newFSId;
			}

			stagingFs.Reception_Date__c = System.today();
			update stagingFs;
			
			opp = new Opportunity(Id=stagingFs.OpportunityId);
			opp.StageName = AMS_Utils.OPPORTUNITY_CLOSED_WON;
			update opp;

			movePdfEndorsementAttachment(stagingFs.Id, newFsId);

		}
		catch(Exception e){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, parseException(e)));
			System.debug(LoggingLevel.ERROR, '____ [cls ANG_DGIStagingAreaCtrl - accept] ' + e.getStackTraceString());
		}
	}

	@future(callout=true)
	private static void movePdfEndorsementAttachment(Id opportunityLineItemId, Id financialSecurityId){

		if(opportunityLineItemId == null || financialSecurityId == null){
			return;
		}
		
		List<WrapperAttach> wrapAttachmentsLst = WrapperAttach.getListAttachments(opportunityLineItemId);

		Map<String, Id> scopeMapping = new Map<String, Id>();
		List<MoveAmazonFilesActionBatch.MoveAmazonFilesActionWrapper> afWrapLst = new List<MoveAmazonFilesActionBatch.MoveAmazonFilesActionWrapper>();

		for(WrapperAttach wa : wrapAttachmentsLst){
			System.debug(LoggingLevel.FINE, '____ [cls ANG_DGIStagingAreaCtrl - movePdfEndorsementAttachment] Processing file ' + wa.fileAmazon.amazonFile.Full_Name_Unique__c + ' to financial security' + financialSecurityId);
			afWrapLst.add(MoveAmazonFilesActionBatch.moveAmazonFile(wa, financialSecurityId));
			scopeMapping.put(wa.fileAmazon.amazonFile.Full_Name_Unique__c, financialSecurityId);
		}

		Savepoint sp = Database.setSavepoint();

		try {
			MoveAmazonFilesActionBatch.commitActions(afWrapLst);
		}
		catch(Exception e){
			System.debug(LoggingLevel.ERROR, '____ [cls ANG_DGIStagingAreaCtrl - movePdfEndorsementAttachment] Exception: ' + e.getMessage());
			System.debug(LoggingLevel.ERROR, '____ [cls ANG_DGIStagingAreaCtrl - movePdfEndorsementAttachment] Exception Stacktrace: ' + e.getStackTraceString());
			Database.rollback(sp);
			MoveAmazonFilesActionBatch.commitTechnicalLogs(
				new Technical_Logs__c(
					Operation__c = 'ANG_DGIStagingAreaCtrl - Moving PDF Endorsement',
					Status__c = (e.getMessage() + '\n' + e.getStackTraceString()).left(254),
					Log__c = JSON.serialize(scopeMapping)
				)
			);
		}
	}

	public void reject(){
		addCertificate = true;
		AMS_OSCAR__c oscar = new AMS_OSCAR__c (Id =stagingFs.OSCAR_GDI__c);
		try{
			oscar.step50__c = AMS_Utils.FAILED;
			oscar.status__c = AMS_Utils.OSCAR_CLOSED;
			oscarObj.step50__c = AMS_Utils.FAILED;

			update oscar;

			opp = new Opportunity(Id=stagingFs.OpportunityId);
			opp.StageName = AMS_Utils.OPPORTUNITY_CLOSED_LOST;
			update opp;
		}
		catch(Exception e){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, parseException(e)));
			System.debug(LoggingLevel.ERROR, '____ [cls ANG_DGIStagingAreaCtrl - reject] ' + e.getStackTraceString());
			oscar.step50__c = 'Not Started';
			oscarObj.step50__c = 'Not Started';
		}

	}

	public void createStagingArea(){
		opp.CurrencyIsoCode = stagingFs.FS_Currency__c;
		update opp;

		pricebook2 pb = [select id from pricebook2 where name = 'NewGen Generic'];

		PricebookEntry pbe = [select id,unitprice,product2id,product2.name from pricebookentry where pricebook2id = :pb.id and currencyIsoCode = :opp.CurrencyIsoCode limit 1];

		stagingFs.pricebookentryid = pbe.id;
		upsert stagingFs;

		fetchStagingFs(stagingFs.Id, null);
	}

	public void createStagingAreaDefault(){

		if(!addCertificate)
			return;

		opp = [Select Id, currencyIsoCode, Account.Region_formula__c from Opportunity where Related_Oscar__c = :oscarObj.Id];

		Case oscarCase = [Select id, ParentId from Case where id = :oscarObj.Oscar_Communication_Case_Id__c];

		pricebook2 pb = [select id from pricebook2 where name = 'NewGen Generic'];
		PricebookEntry pbe = [select id,unitprice,product2id,product2.name from pricebookentry where pricebook2id = :pb.id limit 1];

		if(stagingFs == null)
			stagingFs = new Opportunitylineitem();

		stagingFs.OpportunityId = opp.Id;
		stagingFs.OSCAR_GDI__c = oscarObj.Id;
		stagingFs.Security_Type__c = AMS_Utils.FINANCIAL_SECURITY_TYPE_GDI;
		stagingFs.Security_Status__c = 'Draft';
		stagingFs.Reception_Case__c = oscarCase.ParentId;
		if(currentFS != null)
			stagingFs.Financial_Security__c = currentFS.Id;
		stagingFs.Quantity = 1;
		stagingFs.Region__c = opp.Account.Region_formula__c;
		if(dfltFI <> null)
			stagingFs.Financial_Institution__c = dfltFI.Id;
		stagingFs.TotalPrice = 1;
		stagingFs.pricebookentryid = pbe.id;
		stagingFs.FS_Currency__c = opp.currencyIsoCode;

	}

	public void performAcceptancewithAdendum(Case oscarCase){

		if(currentFS == null || !isValidFS()){
			throw new AMS_ApplicationException(FINANCIAL_SECURITY_ERROR_MESSAGE);
		}

		ANG_AmendFS plugin = new ANG_AmendFS();

		Map<String, Object> inputParams = new Map<String, Object>();

		inputParams.put('NewFSAmount',stagingFs.Amount__c);
		inputParams.put('SelectedCaseId',oscarCase.ParentId);
		inputParams.put('SelectedCurrency',stagingFs.FS_Currency__c );
		inputParams.put('FSToCloneId',currentFS.Id);
		inputParams.put('ExpiryDate',system.today());
		inputParams.put('UnlimitedValidity',false);

		Process.PluginRequest request = new Process.PluginRequest(inputParams);
		Process.PluginResult result = plugin.invoke(request);
		Process.PluginDescribeResult describeresult= plugin.describe();

		newFSId = String.valueOF(result.outputParameters.get('CreatedFSId'));
	}

	public void createNewFinancialSecurity(Case oscarCase){

		Financial_Security__c fs = new Financial_Security__c();

		fs.Amount__c = stagingFs.Amount__c;
		fs.Expiry_Date__c = stagingFs.Expiry_Date__c;
		fs.Financial_Institution__c = stagingFs.Financial_Institution__c;
		fs.Reasonforrequest__c = stagingFs.Reason__c;
		fs.Reception_Case__c = oscarCase.ParentId;
		fs.Region__c = stagingFs.Region__c;
		fs.Security_Status__c = AMS_Utils.FINANCIAL_SECURITY_STATUS_NOT_ACTIVE;
		fs.Security_Type__c = stagingFs.Security_Type__c;
		fs.Validity_Start_Date__c = stagingFs.Validity_Start_Date__c;
		fs.Account__c = oscarObj.Account__c;
		fs.CurrencyIsoCode = stagingFs.FS_Currency__c;
		fs.Reception_Date__c = stagingFs.Reception_Date__c;

		insert fs;

		newFSId = fs.Id;

	}

	private String parseException(Exception e){
		String errorMessage = e.getMessage();
		String errorMessageSplit = errorMessage.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
		return (String.isBlank(errorMessageSplit)) ? errorMessage : errorMessageSplit;
	}

}