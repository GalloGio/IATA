public with sharing class ISSP_TIP_Product_Enrolment_Controller {

 //##======================VARIABLES=================================##
	public String applyLanguage {get; set;}
	public String displayLanguage {get; set;}
	public User user {get; set;}
	public Contact con {get; set;}
	public Account account {get; set;}
	public Partner_products__c newpp {get; set;}
	private Id accountID {get; set;}
	private Case newCase {get; set;}
	public boolean isNew {get; set;}
	public list<BinRangeRec> binRangeList{get; set;}
	public BinRangeRec selectedBinRange{get;set;}

	
	public List<selectOption> paymentGuaranteeOptList{
		get{		
			List<SelectOption> paymentGuaranteeOptList = new List<SelectOption>();		
			for( Schema.PicklistEntry f : Partner_products__c.PP_Payment_guarantee__c.getDescribe().getPicklistValues()) paymentGuaranteeOptList.add(new SelectOption(f.getValue(), f.getLabel()));
			return paymentGuaranteeOptList;
		}
		set;}

	public List<selectOption> acceptedTransactionsOptList{
		get{		
			List<SelectOption> acceptedTransactionsOptList = new List<SelectOption>();		
			for( Schema.PicklistEntry f : Partner_products__c.PP_Accepted_transactions__c.getDescribe().getPicklistValues()) acceptedTransactionsOptList.add(new SelectOption(f.getLabel(), f.getValue()));
			return acceptedTransactionsOptList;
		}
		set;}

//##======================Sidekick classes=================================##

	public class BinRangeRec{
		public TIP_BIN_Range__c binRange{get;set;}
		public integer pos{get;set;}

		public BinRangeRec(TIP_BIN_Range__c tbr,integer p){
			pos=p;
			binRange=tbr;
		}

	}



//##======================Constructors=================================##
	public ISSP_TIP_Product_Enrolment_Controller(){
		isNew=true;
		applyLanguage = UserInfo.getLanguage();
		displayLanguage = UserInfo.getLanguage();
		string prodParam= ApexPages.currentPage().getParameters().get('id');
		newpp= new Partner_products__c(PP_Payment_Product_Network_type__c ='Open Loop');
		binRangeList= new list<BinRangeRec>();
		if(!String.isBlank(prodParam)){
			list<Partner_products__c> prodlist=[Select id,name,PP_Settlement_terms__c,PP_Issuer_name__c,is_PCI_DSS_required__c,PP_Chargeback_airlines__c,PP_Pay_in_model__c,PP_Category__c,PP_Banking_license__c,PP_Payment_network__c,PP_GDS_Integration__c,PP_VAN_type__c,PP_Interchange_fee__c,PP_Payment_guarantee__c,PP_Network_Fee__c,PP_Accepted_transactions__c,PP_Chargeback_airlines_duration__c,Provider__c,PP_Payment_Product_Network_type__c,
													(select id,TIP_Range_Start__c,TIP_Range_End__c,TIP_Status__c from BIN_Ranges__r) 
												from Partner_products__c where id=:prodParam
												];
			if(prodList.size()>0){
				isNew=false;
				newpp= prodlist.get(0);
				integer pos=0;
				for(TIP_BIN_Range__c tbr:newpp.BIN_Ranges__R){
					binRangeList.add(new BinRangeRec(tbr,pos++));
				}
			}
		}
	}


	public Pagereference saveDraft(){
		try{
			if(isNew){
				user usr=[select id,Contact.accountId,Contact.account.name,Contact.account.IATA_ISO_Country__r.region__c,Contact.account.IATA_ISO_Country__r.Name from user where id =:UserInfo.getUserId()];

				newpp.Provider__c=usr.Contact.accountID;
				newpp.PP_Accepted_transactions__c=String.isBlank(newpp.PP_Accepted_transactions__c)?'':newpp.PP_Accepted_transactions__c.substring(1,newpp.PP_Accepted_transactions__c.length() -1);
				newpp.PP_Payment_guarantee__c=String.isBlank(newpp.PP_Payment_guarantee__c)?'':newpp.PP_Payment_guarantee__c.substring(1,newpp.PP_Payment_guarantee__c.length() -1);
				newpp.PP_status__c='Draft';
				try{
					insert newpp;
				}catch(exception e){
					//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));
					return null;
				}
				//create Case
				newCase = new Case();
				newcase.RecordTypeid = TIP_Utils.CASE_PROCESS_IDFS_RECORD_TYPE_ID;
				newcase.AccountId = usr.contact.accountId; 
				newcase.Visible_on_ISS_Portal__c = true;
				newcase.Reason = TIP_Utils.CASE_REASON_PAYMENT_PROVIDER_MANAGMENT ;
				newcase.CaseArea__c = TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS; 
				newcase.Status = 'Draft';
				newcase.Subject = TIP_Utils.CASE_DESC_REQUEST_FOR_ENLISTMENT_PAYMENT_PROVIDER+' - '+ usr.Contact.account.name;
				newCase.Description = TIP_Utils.CASE_DESC_REQUEST_FOR_ENLISTMENT_PAYMENT_PROVIDER;
				newcase.Region__c = usr.Contact.account.IATA_ISO_Country__r.region__c;
				newcase.Origin = 'Portal';
				newcase.BSPCountry__c = usr.Contact.account.IATA_ISO_Country__r.Name;
				newcase.Country_concerned_by_the_query__c = usr.Contact.account.IATA_ISO_Country__r.Name;

				try{
					insert newCase;
				}catch(exception e){
					//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));
					return null;
				}
			} else {			

				newpp.PP_Accepted_transactions__c=String.isBlank(newpp.PP_Accepted_transactions__c)?'':newpp.PP_Accepted_transactions__c.substring(1,newpp.PP_Accepted_transactions__c.length() -1);
				newpp.PP_Payment_guarantee__c=String.isBlank(newpp.PP_Payment_guarantee__c)?'':newpp.PP_Payment_guarantee__c.substring(1,newpp.PP_Payment_guarantee__c.length() -1);
				
				

			}

			update newpp;
		}catch(exception e){
			//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));
			return null;
		}
		return new Pagereference('/apex/ISSP_TIP_Home');

	}
}