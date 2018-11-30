public with sharing class ANG_DGIStagingAreaCtrl {

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

	private final AMS_OSCAR__c oscarObj;

    public boolean oscarProcessed {get{
        
        boolean toReturn = oscarObj.step50__c == 'Passed' || oscarObj.step50__c == 'Failed'; 

        if(toReturn)
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'This process is completed - No action needed.'));

        return toReturn;
        
    }set;}

    public Opportunitylineitem stagingFs{get;set;}

    public List<String> stagingAreaFields {
            get{ 
                return new List<String>{'Amount__c','Expiry_Date__c','Financial_Institution__c','Reason__c','Reception_Case__c','Reception_Date__c','Region__c','Security_Type__c','Security_Status__c','Validity_Start_Date__c'};
            }set;
    }

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ANG_DGIStagingAreaCtrl(ApexPages.StandardController stdController) {
        
        this.stagingFs = (Opportunitylineitem)stdController.getRecord();
        fetchStagingFs();

        List<Financial_Security__c> currentFSLst = [Select Id, Amount__c, Security_Type__c,Reception_Case__c from Financial_Security__c where Account__c = :stagingFs.OSCAR_GDI__r.Account__c and Security_Type__c = 'GDI' and Security_Status__c in ('Active','Close to Expiry Date') ORDER BY CREATEDDATE DESC LIMIT 1];
		
        if(!currentFSLst.isEmpty()){ 
        	currentFS=currentFSLst.get(0);
			this.stagingFs.Financial_Security__c = currentFS.Id;
        }
                
        this.oscarObj = [Select Id, step50__c  from AMS_OSCAR__c where Id=:stagingFs.OSCAR_GDI__c];
    }


    private void fetchStagingFs(){
        
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

            if(hasAdendum)
                performAcceptancewithAdendum(oscarCase);
            else
                createNewFinancialSecurity(oscarCase);

            //set the status of the "Confirm Financial Security Information" in the GDI OSCAR as "Passed"

            AMS_OSCAR__c oscar = new AMS_OSCAR__c (Id =stagingFs.OSCAR_GDI__c);
            oscar.step50__c = 'Passed';
            update oscar;

            Opportunity opp = new Opportunity(Id=stagingFs.OpportunityId);
            opp.StageName='Closed Won';
            update opp;


        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getStackTraceString()));
            System.debug(e.getStackTraceString());
        }
    }

    public void reject(){
        
        AMS_OSCAR__c oscar = new AMS_OSCAR__c (Id =stagingFs.OSCAR_GDI__c);
        oscar.step50__c = 'Failed';
        update oscar;

        Opportunity opp = new Opportunity(Id=stagingFs.OpportunityId);
        opp.StageName='Closed Lost';
        update opp;

    }

    public void performAcceptancewithAdendum(Case oscarCase){

        ANG_AmendFS plugin = new ANG_AmendFS();

        Map<String, Object> inputParams = new Map<String, Object>();
    
        inputParams.put('NewFSAmount',stagingFs.Amount__c);
        inputParams.put('SelectedCaseId',oscarCase.ParentId);
        inputParams.put('SelectedCurrency',stagingFs.CurrencyIsoCode );
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
        fs.Security_Status__c = stagingFs.Security_Status__c;
        fs.Security_Type__c = stagingFs.Security_Type__c;
        fs.Validity_Start_Date__c = stagingFs.Validity_Start_Date__c;
        fs.Account__c = stagingFs.OSCAR_GDI__r.Account__c;
        fs.CurrencyIsoCode = stagingFs.CurrencyIsoCode;
        fs.Reception_Date__c = stagingFs.Reception_Date__c;

        insert fs;

        //Inactivate old FS
        if(currentFS <> null && !hasAdendum){
            currentFS.Security_Status__c = 'Inactive_Addendum';
            currentFS.Release_Date__c = system.today();
            currentFS.Release_Reason__c = 'Security Update';
            update currentFS;
        }

        newFSId = fs.Id;


    }
}