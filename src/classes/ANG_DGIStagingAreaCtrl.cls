public without sharing class ANG_DGIStagingAreaCtrl {

    public Boolean hasErrorMessages { get { return ApexPages.hasMessages(); } }

    private Opportunity opp{get;set;}

    public Id newFSId{get;set;}

    public Financial_Security__c currentFS {get{ 

        List<Financial_Security__c> toReturn = new List<Financial_Security__c>();

        if(currentFS == null)
            toReturn = [Select Id, Amount__c, Security_Type__c,Reception_Case__c from Financial_Security__c where Account__c = :stagingFs.OSCAR_GDI__r.Account__c and Security_Type__c = 'GDI' and Security_Status__c in ('Active','Close to Expiry Date') ORDER BY CREATEDDATE DESC LIMIT 1];
        else {
           if(currentFS.Id <> stagingFs.Financial_Security__c)
                if(stagingFs != null && stagingFs.Financial_Security__c != null)
                    toReturn = [Select Id, Amount__c, Security_Type__c,Reception_Case__c from Financial_Security__c where Id = :stagingFs.Financial_Security__c];
                else
                    toReturn = [Select Id, Amount__c, Security_Type__c,Reception_Case__c from Financial_Security__c where Account__c = :stagingFs.OSCAR_GDI__r.Account__c and Security_Type__c = 'GDI' and Security_Status__c in ('Active','Close to Expiry Date') ORDER BY CREATEDDATE DESC LIMIT 1];
        }

        if(!toReturn.isEmpty())
            currentFS = toReturn.get(0);

        if(stagingFs != null && currentFS != null)
            this.stagingFs.Financial_Security__c = currentFS.Id;

        return currentFS;
    }set;}

    public boolean hasAdendum {get;set;}  

	public AMS_OSCAR__c oscarObj {get;set;}

    public final Case oscarCase {get{
        
        if(this.oscarCase == null && oscarObj != null)
           return [Select Id, Origin, ParentId from Case where Id = :oscarObj.Oscar_Communication_Case_Id__c].get(0);

        return oscarCase;
    }set;}

    public boolean oscarProcessed {get{
        
        boolean toReturn = oscarObj.step50__c == 'Passed' || oscarObj.step50__c == 'Failed'; 

        if(toReturn)
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'This process is completed - No action needed.'));

        return toReturn;
        
    }set;}

    public Opportunitylineitem stagingFs{get;set;}

    public List<String> stagingAreaFields {
            get{ 
                return new List<String>{'Amount__c','Expiry_Date__c','Financial_Institution__c','Reception_Case__c','Reception_Date__c','Region__c','Security_Type__c','Security_Status__c','Validity_Start_Date__c'};
            }set;
    }

    public boolean waitingForEndorsement {get{
        
        Boolean toReturn = (stagingFs == null || stagingFs.Id == null) &&  oscarCase.Origin == 'GDI Portal';

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

        this.oscarObj = [Select Id, step50__c, Account__c, Oscar_Communication_Case_Id__c  from AMS_OSCAR__c where Id=:oscarId];

        List<Opportunitylineitem> lineItemsLst = [Select id from Opportunitylineitem where OSCAR_GDI__c = :oscarId];

        if(!lineItemsLst.isEmpty()){ stagingFs = lineItemsLst.get(0); fetchStagingFs();}

        List<Financial_Security__c> currentFSLst = [Select Id, Amount__c, Security_Type__c,Reception_Case__c from Financial_Security__c where Account__c = :oscarObj.Account__c and Security_Type__c = 'GDI' and Security_Status__c in ('Active','Close to Expiry Date') ORDER BY CREATEDDATE DESC LIMIT 1];

        if(!currentFSLst.isEmpty()){ 
            currentFS=currentFSLst.get(0);
            if(stagingFs != null) this.stagingFs.Financial_Security__c = currentFS.Id;
        }

    }

    @TestVisible private void fetchStagingFs(){
        
        List<String> fieldListoli = new List<String>();

		Map<String, Schema.SObjectField> schemaFieldMapContacts = Opportunitylineitem.sObjectType.getDescribe().fields.getMap();

		for (String field : schemaFieldMapContacts.keySet()){
			fieldListoli.add(field);
		}

		String query = 'SELECT '+ String.join(fieldListoli, ', ') + ' , OSCAR_GDI__r.Name, OSCAR_GDI__r.Account__c FROM Opportunitylineitem WHERE Id = \'' +  stagingFs.Id + '\'';

        stagingFs = Database.query(query); 


    }

    public void accept(){ 

        try{
            Case oscarCase = [Select id, ParentId from Case where OSCAR__c = :stagingFs.OSCAR_GDI__c];

            stagingFs.Reception_Date__c = System.today();
            update stagingFs;

            if(hasAdendum)
                performAcceptancewithAdendum(oscarCase);
            else
                createNewFinancialSecurity(oscarCase);

            //set the status of the "Confirm Financial Security Information" in the GDI OSCAR as "Passed"

            AMS_OSCAR__c oscar = new AMS_OSCAR__c (Id =stagingFs.OSCAR_GDI__c);
            oscar.step50__c = 'Passed';
            oscar.status__c = 'Closed';
            update oscar;

            opp = new Opportunity(Id=stagingFs.OpportunityId);
            opp.StageName='Closed Won';
            update opp;
  
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            System.debug(e.getStackTraceString());
        }
    }

    public void reject(){
        
        AMS_OSCAR__c oscar = new AMS_OSCAR__c (Id =stagingFs.OSCAR_GDI__c);
        oscar.step50__c = 'Failed';
        oscar.status__c = 'Closed';
        oscarObj.step50__c = 'Failed';

        update oscar;

        opp = new Opportunity(Id=stagingFs.OpportunityId);
        opp.StageName='Closed Lost';
        update opp;

    }

    public void createStagingArea(){
            opp.CurrencyIsoCode = stagingFs.FS_Currency__c;
            update opp;

            pricebook2 pb = [select id from pricebook2 where name = 'NewGen Generic'];

            PricebookEntry pbe = [select id,unitprice,product2id,product2.name from pricebookentry where pricebook2id = :pb.id and currencyIsoCode = :opp.CurrencyIsoCode limit 1];

            stagingFs.pricebookentryid = pbe.id;
            upsert stagingFs;
        
        	fetchStagingFs();

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
            stagingFs.Security_Type__c = 'GDI';
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

        if(currentFS == null){
            throw new AMS_ApplicationException('There is no Financial Security or no correct Financial Security type/Status on the Account.');
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
        fs.Security_Status__c = 'Not Active yet';
        fs.Security_Type__c = stagingFs.Security_Type__c;
        fs.Validity_Start_Date__c = stagingFs.Validity_Start_Date__c;
        fs.Account__c = oscarObj.Account__c;
        fs.CurrencyIsoCode = stagingFs.FS_Currency__c;
        fs.Reception_Date__c = stagingFs.Reception_Date__c;

        insert fs;
/*
        //Inactivate old FS
        if(currentFS <> null && !hasAdendum){
            currentFS.Security_Status__c = 'Inactive_Addendum';
            currentFS.Release_Date__c = system.today();
            currentFS.Release_Reason__c = 'Security Update';
            update currentFS;
        }
*/
        newFSId = fs.Id;


    }
}