public with sharing class IDCard_DetailsAdmPaymentsCtrl extends IDCardAbstractController{
	
	public list<ID_Card_Application__c> IdCardApplications {get; set;}
	public Map<String, list<ID_Card_Application__c>> singleAppsPerMassApps  {get;set;}
	public List<ID_Card_Application__c>   allSingleList {get;set;}
	public Map<String, Contact> contacts  {get;set;}

	String massAppRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');
	Public String message = System.currentPagereference().getParameters().get('id');

	public IDCard_DetailsAdmPaymentsCtrl(){
		initialize(true);
		loading();
	}

	public void loading(){
		system.debug('IDCard_DetailsAdmPaymentsCtrl - Loading starting...');
		List<String> cids = new List<String>();
		IdCardApplications = [SELECT id, VER_Number__c from ID_Card_Application__c where id = : message];

		String iataCodeSubstring ='';
        boolean b = false;
        for(String aCode:keyContactAndDelegateForAccountList.keySet()){
            iataCodeSubstring = iataCodeSubstring+ (b?' or IATA_code__c = ':' IATA_code__c = ')+ ' \''+aCode+'\' ';
            b= true;
        }

		singleAppsPerMassApps = new Map<String, list<ID_Card_Application__c>>();
        for(ID_Card_Application__c mass:IdCardApplications){
                    system.debug('IDCard_DetailsAdmPaymentsCtrl - [PAYMENTCTRL] add new item to Map '+mass.Id);
                    singleAppsPerMassApps.put(mass.Id, new List<ID_Card_Application__c>());
                    if(mass.Ver_Number__c != null){
                        cids.add(mass.VER_Number__c);
                    }
          }

		System.debug('IDCard_DetailsAdmPaymentsCtrl - IdCardApplications ' + IdCardApplications + ' singleAppsPerMassApps ' + singleAppsPerMassApps);
		allSingleList = [SELECT Payment_Amount__c, Applicable_Fee__c, Application_Status__c,
                                                                 Case_Number__c, IATA_Code__c, First_Name__c, Displayed_Name__c, Title__c, Type_of_application__c, Id, 
                                                                 Single_Application_Processing_Step__c, Tax_1_Name__c, Tax_1_Value__c, Tax_2_Name__c, Tax_2_Value__c, 
                                                                 Payment_Type__c, Payment_Date__c, Mass_order_Application__c, Last_Name__c, ID_Card_Fee__c, IDCard_Expedite_Delivery__c,
                                                                 Name, IATA_Code_for_previous_agency__c, Gender__c FROM ID_Card_Application__c where Mass_order_Application__c in:singleAppsPerMassApps.keySet()];
                                                                 
        system.debug('IDCard_DetailsAdmPaymentsCtrl - [PAYMENTCTRL] single size '+allSingleList.size());
        for(ID_Card_Application__c singleApp: allSingleList){
            system.debug('IDCard_DetailsAdmPaymentsCtrl - [PAYMENTCTRL] add  '+singleApp.Id+' to '+singleApp.Mass_order_Application__c);
            singleAppsPerMassApps.get(singleApp.Mass_order_Application__c).add(singleApp) ;  
        }

        contacts = new Map<String, Contact> (); 
        system.debug('IDCard_DetailsAdmPaymentsCtrl - cids size ' + cids.size());
        List<Contact> cts = [select Name, Id, Ver_Number_2__c from contact where Ver_Number_2__c in :cids  ];
        for(ID_Card_Application__c mass:IdCardApplications){
            for(Contact c:cts)
                if(c.Ver_Number_2__c == mass.VER_Number__c )
                    contacts.put(mass.Id,c);
         }
	}
}