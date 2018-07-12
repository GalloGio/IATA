public class IDCard_AdmPaymentsCtrl extends IDCardAbstractController {
    
    public list<ID_Card_Application__c> IdCardApplications {get; set;}
    public list<ID_Card_Application__c> applicationToCancel {get; set;}
    public Map<String, list<ID_Card_Application__c>> singleAppsPerMassApps  {get;set;}
    
    public Map<String, Contact> contacts  {get;set;}
    
    public Map<String, case> cases  {get;set;}
    public string caseskeyset {get;set;}
    
    public String toCancel {get;set;}
    
    public IDCard_AdmPaymentsCtrl(){
    	
    	initialize(true);
    	loadContent();
    
    
    }
    
    private void loadContent() {
    	try{  
               String massAppRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');
               if(Test.isRunningTest()){
               	iataCodeParameter = '76543210';
               }
               
               String iataCodeSubstring ='';
		       boolean b = false;
		       for(String aCode:keyContactAndDelegateForAccountList.keySet()){
		            iataCodeSubstring = iataCodeSubstring+ (b?' or IATA_code__c = ':' IATA_code__c = ')+ ' \''+aCode+'\' ';
		            b= true;
		       }
               string IdCardApplicationQuery = 'SELECT '+ TransformationHelper.getAllFields(Schema.SObjectType.ID_Card_Application__c.fields.getMap())+
                                               '  FROM ID_Card_Application__c  '+ 
                                               '  WHERE  recordTypeId = \''+ massAppRT + '\' and  ('+iataCodeSubstring+')  ';//+ AND Payment_Date__c <> Null
               
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
               /*List<ID_Card_Application__c>   allSingleList = [SELECT Payment_Amount__c, Applicable_Fee__c, Application_Status__c,
               													 Case_Number__c, IATA_Code__c, First_Name__c, Displayed_Name__c, Title__c, Type_of_application__c, Id, 
               													 Single_Application_Processing_Step__c, Tax_1_Name__c, Tax_1_Value__c, Tax_2_Name__c, Tax_2_Value__c, 
               													 Payment_Type__c, Payment_Date__c, Mass_order_Application__c, Last_Name__c, ID_Card_Fee__c, IDCard_Expedite_Delivery__c,
               													 Name, IATA_Code_for_previous_agency__c, Gender__c FROM ID_Card_Application__c where Mass_order_Application__c in:singleAppsPerMassApps.keySet()];
               	system.debug('[PAYMENTCTRL] single size '+allSingleList.size());
               	for(ID_Card_Application__c singleApp: allSingleList){
               		system.debug('[PAYMENTCTRL] add  '+singleApp.Id+' to '+singleApp.Mass_order_Application__c);
               		singleAppsPerMassApps.get(singleApp.Mass_order_Application__c).add(singleApp) ;  
               	}      
               	//purchaser details
               	contacts = new Map<String, Contact> (); 
               	List<Contact> cts = [select Name, Id, Ver_Number_2__c from contact where Ver_Number_2__c in :cids  ];
                for(ID_Card_Application__c mass:IdCardApplications){
               		for(Contact c:cts)
               			if(c.Ver_Number_2__c == mass.VER_Number__c )
               				contacts.put(mass.Id,c);
                 }*/
                
        }catch(TransformationException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info, e.getmessage()));
        }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info, 'Unexpected error : please contact our support ' + 
                                                            e.getMessage() + '   ' + e.getLineNumber()));
        }
    }
    
    public Pagereference cancelPendingMassOperation(){
    	if(toCancel !=null)
    	{
        applicationToCancel = [SELECT id, Mass_order_Application__c, Application_Status__c from ID_Card_Application__c where Mass_order_Application__c = : toCancel];
    		//List<ID_Card_Application__c> singleAppa = singleAppsPerMassApps.get(toCancel);
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
    	toCancel =null;
    	loadContent();
    		return  null;
	}
    
}