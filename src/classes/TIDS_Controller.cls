public without sharing class TIDS_Controller {
	private static List<Case> cases {get;set;}
	private static vTIDS tids {get;set;}
	private static List<IATA_ISO_State__c> states {get;set;}
	
	//Auto approved business profiles
	@InvocableMethod
	public static void autoApproved(List<String> caseId) {
		TIDSUtil.iataCodeError = new TIDSUtil.ErrorWrapper();
		Savepoint sp = Database.setSavepoint();
		try {
			final String result = TIDSUtil.getAttachment(caseId[0], TIDS_Constant.DATAJSONFILENAME);
			if (!String.isEmpty(result)){
				loadTIDSFromJson(result);
				if (!TIDSUtil.iataCodeError.hasAnError){
					//Delta changes  
					tids.setAccount();
					tids.runInheritancebatch(caseId[0],false);  
				}
			}
		} catch (Exception e){
			Database.rollback(sp);
			TIDSUtil.setError(e.getMessage(),true);
			System.debug(loggingLevel.FINE, '____ [TIDS_Controller -  autoApproved] e.getMessage() - ' + e.getMessage());
		}
	}

	//Submit the application
	@AuraEnabled(cacheable=false)
	public static TIDSUtil.ErrorWrapper applicationSubmitted(String caseId, String applicationData, String applicationType){
		TIDSUtil.iataCodeError = new TIDSUtil.ErrorWrapper();
		TIDSUtil.getTidsCases(caseId,false);
		Case tidsCase = new Case();
		Savepoint sp = Database.setSavepoint();
		try {
			if (TIDSUtil.cases.size() > 0){
				tidsCase = TIDSUtil.cases[0];
				tidsCase.Origin = TIDS_Constant.CASE_ORIGIN;
				tidsCase.CaseArea__c = TIDS_Constant.CASE_AREA;
				tidsCase.Priority = TIDS_Constant.CASE_PRIORITY;		
				if (applicationType == 'chg-business-profile-specialization'){
					TIDSUtil.addAttachment(caseId, applicationData,TIDS_Constant.DATAJSONFILENAME);
					tidsCase.Decision__c=TIDS_Constant.DECISION_AUTOAPPROVED;
					tidsCase.Decision_Date__c=System.now();
					tidsCase.Status=TIDS_Constant.IS_CLOSED;
				}else{
					tidsCase.Status = TIDS_Constant.IS_REVIEWED;
				}   
			}
			TIDSUtil.iataCodeError.reason ='Application Submitted';
			update tidsCase;
		} catch (Exception e){
			Database.rollback(sp);
			TIDSUtil.setError(e.getMessage(),true);
			System.debug(loggingLevel.FINE, '____ [TIDS_Controller -  applicationSubmitted] e.getMessage() - ' + e.getMessage());
		}    
		return TIDSUtil.iataCodeError;
	}
	
	@AuraEnabled(cacheable=false)
	public static TIDSUtil.ErrorWrapper updateCaseStatus(
		String applicationDecision,
		String userType,
		String applicationType,
		String caseId,
		String applicationsettings,
		String reason){
		TIDSUtil.iataCodeError = new TIDSUtil.ErrorWrapper();
		TIDSUtil.getTidsCases(caseId,false);
		Case tidsCase = new Case();
		if (TIDSUtil.cases.size() > 0){
			tidsCase = TIDSUtil.cases[0];
			if ((applicationDecision==TIDS_Constant.IS_REJECTED || applicationDecision==TIDS_Constant.IS_APPREJECTED) && tidsCase.Status!=TIDS_Constant.IS_INPROGRESS){
				TIDSUtil.setError(TIDS_Constant.MSG11,false);
				return TIDSUtil.iataCodeError;
			}else if (applicationDecision==TIDS_Constant.IS_APPROVED){
				if (tidsCase.Status!=TIDS_Constant.IS_INPROGRESS){
					TIDSUtil.setError(TIDS_Constant.MSG11,false);
					return TIDSUtil.iataCodeError;
				}else if ((!String.isEmpty(tidsCase.Account.IATACode__c) 
					&& tidsCase.Account.RecordType.DeveloperName==TIDS_Constant.RT_AGENCY 
					&& applicationType==TIDS_Constant.NEW_HO)){
					TIDSUtil.setError(TIDS_Constant.MSG11,false);
					return TIDSUtil.iataCodeError;
				}
			}
			tidsCase.Origin = TIDS_Constant.CASE_ORIGIN;
			tidsCase.CaseArea__c = TIDS_Constant.CASE_AREA;
			tidsCase.Priority = TIDS_Constant.CASE_PRIORITY;
			tidsCase.Status = TIDS_Constant.IS_REVIEWED;
			TIDSUtil.addAttachment(caseId, applicationsettings,TIDS_Constant.DATAJSONFILENAME);
		}
		
		if (applicationDecision==TIDS_Constant.IS_APPROVED){
			tidsCase.Decision__c = TIDS_Constant.IS_APPROVED.toUpperCase();
			tidsCase.Status = TIDS_Constant.IS_CLOSED;
			loadTIDSFromJson(applicationsettings);
			if (TIDSUtil.iataCodeError.hasAnError){
				return TIDSUtil.iataCodeError;
			}
			Set<String> type1 = new Set<String>{TIDS_Constant.CHG_NAME,TIDS_Constant.CHG_ADDRESS,TIDS_Constant.CHG_PROFILE};
			Set<String> type2 = new Set<String>{TIDS_Constant.NEW_HO,TIDS_Constant.NEW_BR,TIDS_Constant.NEW_VB};
			if (type1.Contains(tids.applicationType)){
				//Delta changes  
				tids.setAccount();
				tids.runInheritancebatch(caseId,true);
			}else if(type2.Contains(tids.applicationType)){
				//Account Creation  
				tidsGenerateIATACode(tidsCase.contactId, caseId, null, false);
				if (TIDSUtil.iataCodeError.hasAnError){
					return TIDSUtil.iataCodeError;
				}else{
					manageHierarchy(tids.userInfo.tidsAccount.Id, tids.applicationType);
				}
			}
			createChangeCode(tids.userInfo.tidsAccount.Id, tids.applicationType);
		}else if(applicationDecision==TIDS_Constant.IS_REJECTED || applicationDecision==TIDS_Constant.IS_APPREJECTED  || applicationDecision==TIDS_Constant.IS_CLOSED ){
			
			tidsCase.Decision__c = TIDS_Constant.IS_REJECTED.toUpperCase();
			tidsCase.Status = TIDS_Constant.IS_CLOSED;

		}
		if (TIDSUtil.iataCodeError.hasAnError){
			return TIDSUtil.iataCodeError;
		}
		if (!String.isBlank(reason)){
			TIDSUtil.createCaseComment(true, caseId,reason);
		}
		tidsCase.Decision_Date__c = System.Now();
		try {    
			update tidsCase;
		}catch(Exception e){
			TIDSUtil.setError(e.getMessage(),true);
			System.debug(loggingLevel.FINE, '____ [TIDS_Controller -  updateCaseStatus] e.getMessage() - ' + e.getMessage());
		}
		return TIDSUtil.iataCodeError;
	}


	//Lock the Canada Prince Edward Iso State in order to avoid duplicate
	//IATA Code assignement
	private static void testUpdateLocking(){
		states  = new List<IATA_ISO_State__c>();
		try {
			states = [SELECT Id, IATA_ISO_Country__c, IATA_ISO_Country__r.CurrencyIsoCode
				FROM IATA_ISO_State__c
				WHERE ISO_Code__c = :TIDS_Constant.STATEISOCODE LIMIT 1];
		} catch (exception e){
			TIDSUtil.setError(TIDS_Constant.MSG16,false);
		}
	}

	//Will emulate the Staging values based on a minimum of information
	//provided to run the generatedAgencyIATACode(String accountId, String onlineAccreditationId)
	public static void tidsGenerateIATACode(
		Id contactId,
		Id tidsCaseId,
		Id accountId,
		Boolean isRollback){
		
		Boolean isNewBranch = false;
		if (tids.applicationType == TIDS_Constant.NEW_BR){
			isNewBranch = true;
		}
		
		//Try to lock the state to gain exclusive access to the IATA Code generator
		testUpdateLocking();
		if (TIDSUtil.iataCodeError.hasAnError){
			return;
		}
		//Account loaded
		String iataCode;
		String iataCheckDigit;
		String iataSite;
		Account theAccount= tids.setAccount();
		Savepoint sp = Database.setSavepoint();
		try {
			upsert theAccount;
			tids.userInfo.tidsAccount.Id = theAccount.Id;
			Account theFormAccount = [SELECT Name, IATACode__c, Site, Company_Type__c, Short_Name__c, TradeName__c, License_Number__c, VAT_Number__c, GDS__c, Operation__c,
				BillingCountry, BillingStreet, BillingPostalCode, BillingState, BillingCity, IATA_ISO_Country__c, Iso_State__c, ShippingCountry,
				ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity, Email__c, Website, Phone, Fax, In_a_Airport__c, Abbreviated_name__c, Abbreviated_address__c,
				Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c
				,IATA_ISO_Billing_State__c, IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_Country__r.Name, IATA_ISO_Shipping_State__c, IATA_ISO_Shipping_State__r.Name, ISO_State__r.Name,
				Link_agent_name__c, ANG_Accreditation_Model__c, IATA_ISO_Country__r.CurrencyIsoCode,
				(SELECT Id FROM RHC_Informations__r), Is_PCI_compliant__c,Link_agent_code__c, Sector__c, Category__c, Check_Digit__c, RecordTypeId,Due_Diligence_Status__c,CNS_Agency__c
				FROM Account
				WHERE Id =:tids.userInfo.tidsAccount.Id FOR UPDATE];
			
			AMS_Pax_Accreditation_Form__c theForm = new AMS_Pax_Accreditation_Form__c(
				IsGSA__c = 'No',
				CurrencyIsoCode = states[0].IATA_ISO_Country__r.CurrencyIsoCode,
				Branch_Office_Country__c = states[0].IATA_ISO_Country__c,
				IATA_ISO_State__c = states[0].Id,
				SAAM_Case__c = tidsCaseId,
				Location_Class__c = TIDS_Constant.TIDS_T,
				Account_Name__c = theFormAccount.Name
			);
			if (!Test.isRunningTest()){
				ANG_OscarProcessHelper.EntityUpdater upd = AmsIataCodeGenerator.generatedAgencyIATACode(theFormAccount,theForm, null);
				if (upd.isFaulty){
					TIDSUtil.setError(upd.errorMessage,true);
					Database.rollback(sp);
					return;
				}
				theFormAccount = (account) upd.acctMap.get(tids.userInfo.tidsAccount.Id);
				iataCode = theFormAccount.IATAcode__c;
				iataCheckDigit =theFormAccount.Check_Digit__c;
				iataSite = theFormAccount.Site;
			}else{
				//Fake values for the Test coverage to avoid too many queries
				//created by the Iata Code generator
				iataCode = '960001522';
				iataCheckDigit = '2';
				iataSite = 'x';
			}
			Id agencyId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', TIDS_Constant.RT_AGENCY);
			theAccount.IATAcode__c = IATACode;
			if (agencyId != theAccount.RecordTypeId){
				theAccount.RecordTypeId = agencyId;
			}
			if (theAccount.Location_Class__c==null){
				theAccount.Location_Class__c=TIDS_Constant.TIDS_T;
			}
			theAccount.Site = iataSite;
			theAccount.Check_Digit__c = iataCheckDigit;
			update theAccount;
			tids.saveBuinessProfiles(tids.userInfo.tidsAccount.Id);
			tids.saveAMSRole(tids.userInfo.tidsAccount.Id);
			if (!isNewBranch){
				TIDSUtil.grantTIDSPortalAccess(contactId);
			}
		} catch (exception e){
			Database.rollback(sp);
			TIDSUtil.setError(e.getMessage(),true);
			System.debug(loggingLevel.FINE, '____ [TIDS_Controller -  tidsGenerateIATACode] e.getMessage() - ' + e.getMessage());
		}		
		return;
	}
	//Deserialize the data.json file in the tids class
	public static void loadTIDSFromJson(string tidsjson){
		try{
			tids = (vTIDS) JSON.deserialize(tidsjson, vTIDS.class);
		}catch(Exception e){
			TIDSUtil.setError(e.getMessage(),true);
		}
	}
	public class vuserInfo {
		public String Id {get;set;}
		public String Name {get;set;}
		public String ContactId {get;set;}
		public String AccountId {get;set;}
		public vAccount tidsAccount {get;set;}
		public vuserInfo(){
			this.tidsAccount = new vAccount();
		}
	}
	public class vAccount {
		public String RecordTypeId {get;set;}
		public String Country_ISO_Code {get;set;}
		public String Id {get;set;}
		public vRecordType RecordType {get;set;}
		public vAccount(){
			this.RecordType = new vRecordType();
		}
	}
	public class vRecordType {
		public String Name {get;set;}
		public String Id {get;set;}
	}

	public class vbusinessRules {
		public Integer TIDS_Reinstatement_Window {get;set;}
		public String Name {get;set;}
		public Integer TIDS_Total_Ownership_Minimum {get;set;}
		public Integer TIDS_Total_Ownership_Maximum {get;set;}
		public String Id {get;set;}
	}
	public class vcase {
		public String id {get;set;}
	}

	public class sWelcome {
		public String sectionName {get;set;}
		public String cmpName {get;set;}
		public vWelcome values {get;set;}
		public String sectionDecision {get;set;}
		public List<verror> errors {get;set;}
		public sWelcome(){
			this.cmpName='';
			this.sectionName='';
			this.sectionDecision='';
			this.values = new vWelcome();
			this.errors = new List<verror>();
		}
	}

	public class vWelcome {
		public String companyLegalName {get;set;}
		public String countryIsoCode {get;set;}
		public String countryName {get;set;}
		public String countryId {get;set;} 
	}

	public class sAgencyLegalStatus {
		public String sectionName {get;set;}
		public String cmpName {get;set;}
		public vAgencyLegalStatus values {get;set;}
		public String sectionDecision {get;set;}
		public List<verror> errors {get;set;}
		public sAgencyLegalStatus(){
			this.cmpName='';
			this.sectionName='';
			this.sectionDecision='';
			this.values = new vAgencyLegalStatus();
			this.errors = new List<verror>();
		}
	}

	public class vAgencyLegalStatus {
		public String tradingName {get;set;}
		public String companyType {get;set;}
		public String taxIdVATNumber1 {get;set;}
		public String taxIdVATNumber2 {get;set;}
		public String businessRegistration {get;set;}
		public String inOperationsSince {get;set;}
	}

	public class sShareholderDetails {
		public String sectionName {get;set;}
		public String cmpName {get;set;}
		public List<vShareholderDetails> values {get;set;}
		public String sectionDecision {get;set;}
		public List<verror> errors {get;set;}
		public sShareholderDetails(){
			this.cmpName='';
			this.sectionName='';
			this.sectionDecision='';
			this.values = new List<vShareholderDetails>();
			this.errors = new List<verror>();
		}
	}
	public class vShareholderDetails {
		public String type {get;set;}
		public String name {get;set;}
		public String percentage {get;set;}
		public String email {get;set;}
		public String id {get;set;}
		public String action {get;set;}
	}

	public class sAddress {
		public String sectionName {get;set;}
		public String cmpName {get;set;}
		public vAddress values {get;set;}
		public String sectionDecision {get;set;}
		public List<verror> errors {get;set;}
		public sAddress(){
			this.cmpName='';
			this.sectionName='';
			this.sectionDecision='';
			this.values = new vAddress();
			this.errors = new List<verror>();
		}
	}
	public class vAddress {
		public String address {get;set;}
		public String city {get;set;}
		public vstate state {get;set;}
		public String postalCode {get;set;}
		public String country {get;set;}
		public String countryName {get;set;}
		public String countryIsoCode {get;set;}
		public String countryId {get;set;}
		public String citygeonameId {get;set;}
		public vvirtualCountryOfOperations virtualCountryOfOperations {get;set;}
		public vAddress(){
			this.state = new vstate();
		}
	}
	public class vvirtualCountryOfOperations {
		public String countryid {get;set;}
		public String label {get;set;}
		public String value {get;set;}
	}
	public class vstate {
		public String label {get;set;}
		public String value {get;set;}
		public String Id {get;set;}
	}
	public class sMailing {
		public String sectionName {get;set;}
		public String cmpName {get;set;}
		public vMailing values {get;set;}
		public String sectionDecision {get;set;}
		public List<verror> errors {get;set;}
		public sMailing(){
			this.cmpName='';
			this.sectionName='';
			this.sectionDecision='';
			this.values = new vMailing();
			this.errors = new List<verror>();
		}
	}
	public class vMailing {
		public String isMailingSameAsPhysicalAddress {get;set;}
		public String mailingAddress {get;set;}
		public String mailingOption {get;set;}
		public String otherAddress {get;set;}
		public String city {get;set;}
		public vstate state {get;set;}
		public String postalCode {get;set;}
		public String country {get;set;}
		public String countryName {get;set;}
		public String countryIsoCode {get;set;}
		public String countryId {get;set;}
		public String citygeonameId {get;set;}
		public vMailing(){
			this.state = new vstate();
		}
	}
	public class sContact {
		public String sectionName {get;set;}
		public String cmpName {get;set;}
		public vContact values {get;set;}
		public String sectionDecision {get;set;}
		public List<verror> errors {get;set;}
		public sContact(){
			this.cmpName='';
			this.sectionName='';
			this.sectionDecision='';
			this.values = new vContact();
			this.errors = new List<verror>();
		}
	}
	public class vContact {
		public String preferedLanguage {get;set;}
		public String phone {get;set;}
		public String fax {get;set;}
		public String businessEmail {get;set;}
		public String webSite {get;set;}
		public String omFirstName {get;set;}
		public String omLastName {get;set;}
	}

	public class sBusinessProfile {
		public String sectionName {get;set;}
		public String cmpName {get;set;}
		public vBusinessProfile values {get;set;}
		public String sectionDecision {get;set;}
		public List<verror> errors {get;set;}
		public sBusinessProfile(){
			this.cmpName='';
			this.sectionName='';
			this.sectionDecision='';
			this.values = new vBusinessProfile();
			this.errors = new List<verror>();
		}
	}
	public class vBusinessProfile {
		public vsfields principalActivities {get;set;}
		public vsfields marketFocus {get;set;}
		public vsfields salesMix {get;set;}
		public vnfields travelSales {get;set;}
		public vsfields gds {get;set;}
		public vnfields numberEmployees {get;set;}
		public vnfields numberOffices {get;set;}
	}
	public class sBusinessSpecialization {
		public String sectionName {get;set;}
		public vBusinessSpecialization values {get;set;}
		public List<verror> errors {get;set;}
		public sBusinessSpecialization(){
			this.sectionName='';
			this.errors = new List<verror>();
			this.values= new vBusinessSpecialization();
		}
	}
	public class vBusinessSpecialization {
		public spercentageBreakdown percentageBreakdown {get;set;}
		public smarketSpecialties marketSpecialties {get;set;}
		public sdestinationSpecialties destinationSpecialties {get;set;}
		public vBusinessSpecialization(){
			this.percentageBreakdown = new spercentageBreakdown();
			this.marketSpecialties = new smarketSpecialties();
			this.destinationSpecialties = new sdestinationSpecialties();
		}
	}
	public class spercentageBreakdown {
		public String fieldName {get;set;}
		public List<vslabel> values {get;set;}
		public spercentageBreakdown(){
			this.fieldName='percentageBreakdown';
			this.values = new List<vslabel>();
		}
	}
	public class smarketSpecialties {
		public String fieldName {get;set;}
		public List<vslabel> values {get;set;}
		public smarketSpecialties(){
			this.fieldName='';
			this.values = new List<vslabel>();
		}
	}
	public class sdestinationSpecialties {
		public String fieldName {get;set;}
		public List<vslabel> values {get;set;}
		public sdestinationSpecialties(){
			this.fieldName='';
			this.values = new List<vslabel>();
		}
	}
	public class vnfields {
		public String fieldName {get;set;}
		public String values {get;set;}
		public vnfields(){
			this.fieldName='';
			this.values = '';
		}
	}

	public class vsfields {
		public String fieldName {get;set;}
		public List<vslabel> values {get;set;}
		public vsfields(){
			this.fieldName='';
			this.values = new List<vslabel>();
		}
	}
	public class vslabel {
		public String label {get;set;}
		public String value {get;set;}
		public vslabel(String xlabel, String xvalue){
			this.label=xlabel;
			this.value=xvalue;
		}
	}
	public class sSupportingDocuments {
		public String sectionName {get;set;}
		public String cmpName {get;set;}
		public List<vslabel> values {get;set;}
		public String sectionDecision {get;set;}
		public List<verror> errors {get;set;}
		public sSupportingDocuments(){
			this.cmpName='';
			this.sectionName='';
			this.values = new List<vslabel>();
			this.errors = new List<verror>();
			this.sectionDecision='';

		}
	}

	public class vsections {
		public sWelcome Welcome {get;set;}
		public sAgencyLegalStatus AgencyLegalStatus {get;set;}
		public sShareholderDetails ShareholderDetails {get;set;}
		public sAddress Address {get;set;}
		public sMailing Mailing {get;set;}
		public sContact Contact {get;set;}
		public sBusinessProfile BusinessProfile {get;set;}
		public sBusinessSpecialization BusinessSpecialization {get;set;}
		public sSupportingDocuments SupportingDocuments {get;set;}
		public vsections(){
			this.Welcome = new sWelcome();
			this.AgencyLegalStatus = new sAgencyLegalStatus();
			this.ShareholderDetails = new sShareholderDetails();
			this.Address = new sAddress();
			this.Mailing = new sMailing();
			this.Contact = new sContact();
			this.BusinessProfile = new sBusinessProfile();
			this.BusinessSpecialization = new sBusinessSpecialization();
			this.SupportingDocuments = new sSupportingDocuments();
		}
	}

	public class vsectionsDone {
		public String id {get;set;}
		public String sectionName {get;set;}
		public String next {get;set;}
		public vsectionsDone(){
			this.id='';
			this.sectionName='';
			this.next='';				
		}
	}

	public class verror {
		public String fieldLabel {get;set;}
		public String fieldName {get;set;}
		public String description {get;set;}
		public verror(){
			this.fieldLabel='';
			this.fieldName='';
			this.description='';
		}
	}

	public class vTIDS {
		public String applicationType {get;set;}
		public String userType {get;set;}
		public vuserInfo userInfo {get;set;}
		public vbusinessRules businessRules {get;set;}
		public vcase tidscase {get;set;}
		public vsections sections {get;set;}
		public List<vsectionsDone> sectionsDone {get;set;}
		public vTIDS(){
			this.userInfo = new vuserInfo();
			this.sections = new vsections();
			this.sectionsDone = new List<vsectionsDone>();
			this.businessRules = new vbusinessRules();
			this.tidscase = new vcase();
			this.applicationType='';
			this.userType='';
		}
		
		public void getRoles(Id accountId){
			List<AMS_Account_Role__c> amsroles = TIDSUtil.tidsShareholders(accountId,true,true);
			List<vShareholderDetails> values = new List<vShareholderDetails>();
			for (AMS_Account_Role__c item : amsroles){
				vShareholderDetails vitem = new vShareholderDetails();
				vitem.percentage = String.ValueOf(item.Percentage__c);
				vitem.type = item.Owner_Category__c;
				vitem.Name = item.Owner_Name__c;
				vitem.email = item.Owner_Email__c;
				values.add(vitem);
			}
			this.sections.ShareholderDetails.values = values;
		}
		
		//load the information based on the account
		private List<Account> getAccountObject(Id objectId
										,boolean isFromContact
										,boolean isFromRelatedAccount){
			List<Account> mapaccounts = new List<Account>();
			if (isFromRelatedAccount){
				List<Account> relatedobjects = new List<Account>();
				relatedobjects = [SELECT ParentId, Location_Type__c FROM Account WHERE Id=:objectId Limit 1];
				if (relatedobjects.size()==0){
					return mapaccounts;
				}
				transactiontype=relatedobjects[0].Location_Type__c;
				if (transactiontype!=TIDS_Constant.TIDS_HO){
					objectId=relatedobjects[0].ParentId;
				}
			}
			if (isFromContact){
				List<Contact> relatedobjects = new List<Contact>();
				relatedobjects = [SELECT AccountId FROM Contact WHERE Id=:objectId Limit 1];
				if (relatedobjects.size()==0){
					return mapaccounts;
				}
				objectId=relatedobjects[0].AccountId;
			}
			mapaccounts = [
				SELECT
					Id,
					Location_Type__c,
					Name,
					TradeName__c,
					Category__c,
					Sector__c,
					Status__c,
					ParentId,
					Parent.Status__c,
					VAT_Number__c,
					VAT_Number_2__c,
					License_Number__c,
					BillingStreet,
					BillingCity,
					BillingState,
					BillingPostalCode,
					BillingCountry,
					IATA_ISO_Country__c,
					IATA_ISO_Billing_State__c,
					IATA_ISO_Shipping_Country__c,
					IATA_ISO_Shipping_State__c,
					Iso_State__c,
					preferred_Language__c,
					phone,
					fax,
					email__c,
					website,
					Manager_First_Name__c,
					Manager_Last_Name__c,
					GDP_Opt_In__c,
					GDS__c,
					Company_Type__c,
					ShippingStreet,
					ShippingCity,
					ShippingState,
					ShippingPostalCode,
					ShippingCountry,
					Geoname_Shipping_City__c,
					Geoname_Billing_City__c,
					Organization_Last_Change_Date__c,
					Site,
					Check_Digit__c,
					RecordTypeId			
				FROM Account
				WHERE  Id=:objectId LIMIT 1];
			return mapaccounts;
		}
		private Map<String, Id> geonameIds {get;set;}
		public void setGeonames(){
		 	geonameIds = new Map<String, Id>();
		 	if (!String.isEmpty(this.sections.Address.values.citygeonameId)){
				geonameIds.put(this.sections.Address.values.citygeonameId, null);
			}
			if (!String.isEmpty(this.sections.Mailing.values.citygeonameId)){
				geonameIds.put(this.sections.Mailing.values.citygeonameId, null);
			}
			readGeonames();
		}
		
		public void readGeonames(){
			// Make sure we can update the database before even trying
			List<IATA_ISO_City__c> geonames = new List<IATA_ISO_City__c>();
			geonames = [SELECT Id,GeonameId__c
										FROM IATA_ISO_City__c
										WHERE GeonameId__c=:geonameIds.KeySet() or Id=:geonameIds.KeySet()
										ORDER BY GeonameId__c NULLS LAST LIMIT 2];
			for (IATA_ISO_City__c key : geonames){
				geonameIds.put(key.Id, key.Id);
				geonameIds.put(key.GeonameId__c, key.Id);
			}
		}
		public void setCompanyName(){
			mapaccount.Name = this.sections.Welcome.values.companyLegalName;
			mapaccount.TradeName__c = this.sections.AgencyLegalStatus.values.tradingName;
		}
		public void setDefault(){
			mapaccount.Category__c = 'TIDS Agent';
			mapaccount.Sector__c = 'Travel Agent';
			mapaccount.Status__c = TIDS_Constant.IS_APPROVED; // Date Organization Status attained must be provided

			mapaccount.Location_Type__c = TIDS_Constant.TIDS_HO; //HO ==>HO BR ==>BR VB ==>VB
			if (this.applicationType == TIDS_Constant.NEW_BR){
				mapaccount.Location_Type__c = TIDS_Constant.TIDS_BR;
			}
			if (this.applicationType == TIDS_Constant.NEW_VB){
				mapaccount.Location_Type__c = TIDS_Constant.TIDS_VB;
			}
			mapaccount.Accreditation_Date__c = System.Today();
			mapaccount.Date_Organisation_Status_attained__c = System.Today();
			mapaccount.GDP_Opt_In__c = true;
			setGDS();
			mapaccount.Source_System__c = 'TIDS Online Portal';
		}
		public void setGDS(){
			mapaccount.GDS__c = getGDS();
		}
		public void setCompanyType(){   
			mapaccount.Company_Type__c = this.sections.AgencyLegalStatus.values.companyType;
		}
		public void setTax(){
			mapaccount.VAT_Number__c = this.sections.AgencyLegalStatus.values.taxIdVATNumber1;
			mapaccount.VAT_Number_2__c = this.sections.AgencyLegalStatus.values.taxIdVATNumber2;
			mapaccount.License_Number__c = this.sections.AgencyLegalStatus.values.businessRegistration;
		}

		public void setAddress(){
			//Address
			mapaccount.BillingStreet = this.sections.Address.values.address;
			mapaccount.BillingCity = this.sections.Address.values.city;
			mapaccount.BillingState =null;
			mapaccount.IATA_ISO_Billing_State__c=null;
			mapaccount.Iso_State__c=null;
			mapaccount.BillingPostalCode = this.sections.Address.values.postalCode;
			mapaccount.BillingCountry = this.sections.Address.values.countryName; // JH Change mapping
			mapaccount.IATA_ISO_Country__c = this.sections.Address.values.countryId;
			if (this.sections.Address.values.state!=null){
				mapaccount.BillingState = this.sections.Address.values.state.label;
				mapaccount.IATA_ISO_Billing_State__c = this.sections.Address.values.state.Id;
				mapaccount.Iso_State__c = this.sections.Address.values.state.Id;
			}
			mapaccount.Geoname_Billing_City__c = null;
			string key = this.sections.Address.values.citygeonameId;
			if (geonameIds.containsKey(key)){mapaccount.Geoname_Billing_City__c = (Id) geonameIds.get(key);}
		}
		public void setMailing(){
			//Mailing
			if (this.sections.Mailing.values.isMailingSameAsPhysicalAddress == 'true'){
				mapaccount.ShippingStreet = null;
				mapaccount.ShippingCity = null;
				mapaccount.ShippingState = null;
				mapaccount.ShippingPostalCode = null;
				mapaccount.ShippingCountry = null;
				mapaccount.Geoname_Shipping_City__c = null;
				mapaccount.IATA_ISO_Shipping_Country__c=null;
				mapaccount.IATA_ISO_Shipping_State__c=null;
		 	}else{
			mapaccount.ShippingStreet = this.sections.Mailing.values.mailingAddress;
			mapaccount.ShippingCity = this.sections.Mailing.values.city;
			mapaccount.ShippingState =null;
			mapaccount.IATA_ISO_Shipping_State__c =null;
			if (this.sections.Mailing.values.state!=null){
				mapaccount.ShippingState = this.sections.Mailing.values.state.label;
				mapaccount.IATA_ISO_Shipping_State__c = this.sections.Mailing.values.state.Id;
			}
			mapaccount.IATA_ISO_Shipping_Country__c = this.sections.Mailing.values.countryId;
			mapaccount.ShippingPostalCode = this.sections.Mailing.values.postalCode;
			mapaccount.ShippingCountry = this.sections.Mailing.values.countryName;
			mapaccount.Geoname_Shipping_City__c = null;
			string key = this.sections.Mailing.values.citygeonameId;
			if (geonameIds.containsKey(key)){
				mapaccount.Geoname_Shipping_City__c = (Id) geonameIds.get(key);
			}
		 }
		}
		public void setLastDateOrgChange(){
			mapaccount.Organization_Last_Change_Date__c = System.today();
		}
		public void setContact(){
			mapaccount.preferred_Language__c = this.sections.Contact.values.preferedLanguage;
			mapaccount.phone = this.sections.Contact.values.phone;
			mapaccount.fax = this.sections.Contact.values.fax;
			mapaccount.email__c = this.sections.Contact.values.businessEmail;
			mapaccount.website = this.sections.Contact.values.webSite;
			mapaccount.Manager_First_Name__c = this.sections.Contact.values.omFirstName;
			mapaccount.Manager_Last_Name__c = this.sections.Contact.values.omLastName;
		}
		//ses the virtual Address of Operation
		public void setVirtualAddressOfOperation(){
			List<vslabel> values = new List<vslabel>();
				vslabel avalue = new vslabel(
				this.sections.Address.values.virtualCountryOfOperations.label,
				this.sections.Address.values.virtualCountryOfOperations.value
			);
			values.add(avalue);
			setBusinessCodes(values, false, false, 'TIDS_VB_ISO');
		}
		private Account mapaccount = new Account();
		private Account parentaccount = new Account();
		//Will copy from Account information to the updated account
		private void setInheritance(List<string> types, Account copyfrom){
			for(string type:types){
				switch on (type){
					when 'companytype'{
						mapaccount.Company_Type__c = copyfrom.Company_Type__c;
					}
					when 'companyname'{
						mapaccount.Name = copyfrom.Name;
					}
					when 'address'{
						mapaccount.BillingStreet = copyfrom.BillingStreet;
						mapaccount.BillingCity = copyfrom.BillingCity;
						mapaccount.BillingState = copyfrom.BillingState;
						mapaccount.BillingPostalCode = copyfrom.BillingPostalCode;
						mapaccount.BillingCountry = copyfrom.BillingCountry;
						mapaccount.IATA_ISO_Country__c = copyfrom.IATA_ISO_Country__c;
						mapaccount.IATA_ISO_Billing_State__c = copyfrom.IATA_ISO_Billing_State__c;
						mapaccount.Iso_State__c = copyfrom.Iso_State__c;
						mapaccount.Geoname_Billing_City__c = copyfrom.Geoname_Billing_City__c;
					}					
				}
			}
		}
		private boolean inheritanceBatched;
		//The batch will copy data from HO to BR or VB
		//with sub data such as ownership
		private void runInheritanceBatch(Id caseId, boolean isCreateAccount){
			upsert mapaccount;
			saveBuinessProfiles(mapaccount.Id);
			saveAMSRole(mapaccount.Id);
			if (inheritanceBatched){
				TidsBatchCascading nb = new TidsBatchCascading();
				nb.caseId=caseId;
				Database.executeBatch(nb,100);
			}
		}
		private string transactiontype=TIDS_Constant.TIDS_HO;
		private boolean isVirtualBranchDateOfOp=false;
		private boolean isSaveVBISOCountry=false;
		private boolean isSaveAllBP=false;
		private boolean isSaveInOperationSince=false;
		private boolean isSaveAMSRole=false;
		private void retrieveAccount(boolean isFromContact, boolean isFromRelatedAccount ){
			Id objectid =this.userInfo.tidsAccount.Id;
			//Get the parent account From the related account Id
			list<Account> parentaccounts = getAccountObject(objectid, isFromContact, isFromRelatedAccount);
			if (parentaccounts.size()>0){parentaccount=parentaccounts[0];}
		}
		
		public Account setAccount(){
			isVirtualBranchDateOfOp=false;
			isSaveVBISOCountry=false;
			isSaveAMSRole=false;
			isSaveAllBP=false;
			isSaveInOperationSince=false;
			inheritanceBatched=false;
			mapaccount = new Account();
			switch on (this.applicationType){
				when 'chg-name-company' {
					//Agency and Legal Status
					isSaveInOperationSince=true;
					retrieveAccount(false, true);
					if (transactiontype==TIDS_Constant.TIDS_HO){
						inheritanceBatched=true;
						isSaveAMSRole=true;
						mapaccount.id=parentaccount.Id;
					}else{
						mapaccount.id=this.userInfo.tidsAccount.Id;
					}
					setLastDateOrgChange();
					setCompanyType();
					setTax();
					setCompanyName();
				}
				when 'chg-address-contact'{
					retrieveAccount(false, true);
					if (transactiontype==TIDS_Constant.TIDS_HO){
						inheritanceBatched=true;
						mapaccount.id=parentaccount.Id;
						setGeonames();
					}else{
						mapaccount.id=this.userInfo.tidsAccount.Id;
						setGeonames();
					}
					if (transactiontype==TIDS_Constant.TIDS_VB){
						inheritanceBatched=false;
					}else{
						setAddress();
					}
					setLastDateOrgChange();
					setMailing();
					setContact();
				}  
				when 'chg-business-profile-specialization' {
					inheritanceBatched=false;
					retrieveAccount(false, true);
					if (transactiontype==TIDS_Constant.TIDS_HO){
						mapaccount.id=parentaccount.Id;
					}else{
						mapaccount.id=this.userInfo.tidsAccount.Id;
					}
					setGDS();
					setLastDateOrgChange();
					isSaveAllBP=true;
				}
				when 'NEW_HO' {
					isSaveAllBP=true;
					isSaveAMSRole=true;
					isSaveInOperationSince=true;
					inheritanceBatched=false;
					//will get a iatacode
					retrieveAccount(false, false);
					mapaccount.Id=parentaccount.Id;
					setCompanyName();
					setDefault();
					setCompanyType();
					setTax();
					setGeonames();
					setAddress();
					setMailing();
					setContact();
				}
				when 'NEW_BR' {
					//Copy certain details inherited by Branches from the Head 
					//Office (for example: owners, legal name, company type…)
					isSaveAllBP=true;
					isSaveAMSRole=true;
					isSaveInOperationSince=true;
					inheritanceBatched=false;
					retrieveAccount(false, false);
					mapaccount.parentId=parentaccount.Id;
					mapaccount.Reason_for_creation__c=TIDS_Constant.NEW_AGENT;
					getRoles(parentaccount.Id);
					setCompanyName();
					setDefault();
					setCompanyType();
					setTax();
					setGeonames();
					setAddress();
					setMailing();
					setContact();
					setInheritance(new List<String> {'companytype', 'companyname'},parentaccount);
				}
				when 'NEW_VB' {
					isSaveVBISOCountry=true;
					isSaveAllBP=true;
					isSaveAMSRole=true;
					isSaveInOperationSince=true;
					inheritanceBatched=false;
					retrieveAccount(false, false);
					mapaccount.parentId=parentaccount.Id;
					mapaccount.Reason_for_creation__c=TIDS_Constant.NEW_AGENT;
					getRoles(parentaccount.Id);
					setCompanyName();
					setDefault();
					setCompanyType();
					setTax();
					this.businessProfiles = new Map<String, AMS_Agency_Profile__c>();
					isVirtualBranchDateOfOp=true;
					//Physical address must same as the HO account
					setGeonames();
					setMailing();
					setContact();
					setInheritance(new List<String> {'address','companytype', 'companyname'},parentaccount);
				}
			}
			//new field
			return mapaccount;
		}
		//main function to save All the Business Profiles
		public void saveBuinessProfiles(Id accountId){
			currentAccountId=accountId;
			this.businessProfiles = new Map<String, AMS_Agency_Profile__c>();
			if (isSaveInOperationSince){
				getinOperationsSince();
			}
			if (isSaveAllBP){
				getdestinationSpecialties();
				getmarketSpecialties();
				getPrincipalActivities();
				getMarketFocus();
				getSalesMix();
				getBusinessProfile();
				getTravelSales();
				getNumberOfEmployees();
				getNumberOffices();
			}
			if (isVirtualBranchDateOfOp) {
				setVirtualAddressOfOperation();
			}
			if (businessProfiles.size() > 0){
				loadbusinessProfiles(businessProfiles.Values());
			}
		}

		private void getTravelSales(){
			List<vslabel> values = new List<vslabel>();
			vslabel avalue = new vslabel(
				this.sections.BusinessProfile.values.travelSales.fieldName,
				this.sections.BusinessProfile.values.travelSales.values
			);
			values.add(avalue);
			setBusinessCodes(values, false, true, 'SV');
		}
		private void getNumberOfEmployees(){
			List<vslabel> values = new List<vslabel>();
			vslabel avalue = new vslabel(
				this.sections.BusinessProfile.values.numberEmployees.fieldName,
				this.sections.BusinessProfile.values.numberEmployees.values
			);
			values.add(avalue);
			setBusinessCodes(values, false, true, 'NU_EMPL');
		}
		private void getNumberOffices(){
			List<vslabel> values = new List<vslabel>();
			vslabel avalue = new vslabel(
				this.sections.BusinessProfile.values.numberOffices.fieldName,
				this.sections.BusinessProfile.values.numberOffices.values);
			values.add(avalue);
			setBusinessCodes(values, false, true, 'NU_OFFI');
		}
		//create and replace
		public void saveAMSRole(Id accountId){
			if (!isSaveAMSRole){
				return;
			}
			//expiration date on the owner
			//check expiration date and disable existing one and create new owners
			//Action and Id to add in the json
			
			Id ownershipId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
			
			set<String> itemtypes = new Set<String>();
			List<vShareholderDetails> values = this.sections.ShareholderDetails.values;
			List<AMS_Account_Role__c> amsroles = TIDSUtil.tidsShareholders(accountId,false,false);
			List<AMS_Account_Role__c> newroles = new List<AMS_Account_Role__c>();
			List<AMS_Account_Role__c> delroles = new List<AMS_Account_Role__c>();
			Set<Id> delset = new Set<Id>();
			
			for (vShareholderDetails item : values){
				AMS_Account_Role__c n = new AMS_Account_Role__c();
				n.RecordTypeId = ownershipId;
				n.Percentage__c = Decimal.ValueOf(item.percentage);
				n.Owner_Account__c = accountId;
				n.Owner_Category__c = item.type;
				n.Owner_Name__c = item.Name;
				n.Owner_Email__c = item.email;
				n.Account__c = accountId;
				for (AMS_Account_Role__c o: amsroles){
					if (delset.Contains(o.Id)){
						continue;
					}
					if (o.Owner_Category__c==n.Owner_Category__c && 
						o.Owner_Email__c==n.Owner_Email__c &&
						o.Owner_Name__c==n.Owner_Name__c){
						if (o.Active__c){
							n=o;
							n.Percentage__c = Decimal.ValueOf(item.percentage);
						}
						delset.add(o.Id);
					}
				}
				newroles.add(n);
			}
			for (AMS_Account_Role__c o: amsroles){
				if (!delset.Contains(o.Id)){
					delroles.add(o);
				}
			}
			if (delroles.size() > 0){
				delete delroles;
			}
			if (newroles.size() > 0){
				upsert newroles;
			}
		}
		private Id currentAccountId;
		private Map<String, AMS_Agency_Profile__c> businessProfiles {get;set;}
		private Set<String> grcodes  = new Set<String>{'FL','FC','DS','MK','AT','SMOL','SMOF','ME','SA','SS','SH','TR','SL','DIBS','TIDS_SH', 'TIDS_SA', 'TIDS_SS', 'TIDS_SL','TIDS_ME','TIDS_TR','NU_EMPL','NU_OFFI'};
			
		//Delete and create the code in the profile
		private void loadbusinessProfiles(List<AMS_Agency_Profile__c> insertbr){
			grcodes= new Set<String>();
			for(AMS_Agency_Profile__c br:insertbr){grcodes.add(br.GR_Code__c);}
				List<AMS_Agency_Profile__c> businessprofilelist = [SELECT Id
																	FROM AMS_Agency_Profile__c
																	WHERE Account__c = :currentAccountId 
																	and GR_Code__c=:grcodes];
				if (businessprofilelist.size() > 0){
					delete businessprofilelist;
				}
				if (insertbr.size()>0){
					insert insertbr;
				}
		}
		private void setBusinessCodes(
				List<vslabel> svalues,
				boolean isMultipleSelection,
				boolean isLabelBased,
			String itemcode){
			if (svalues == null || svalues.isEmpty() == true || svalues.size() == 0){
				return;
			}
			string grcode = '';
			Map<String, String> mapgrcodes = new Map<String, String>();
			mapgrcodes.put('Meetings/Groups','TIDS_ME');
			mapgrcodes.put('Air Travel','TIDS_SA');
			mapgrcodes.put('Cruises','TIDS_SS');
			mapgrcodes.put('Tours & Packages','TIDS_TR');
			mapgrcodes.put('Meetings & Events','TIDS_ME');
			mapgrcodes.put('Accommodation','TIDS_SH');
			mapgrcodes.put('Land Transportation','TIDS_SL');
			mapgrcodes.put('Online','SMOL');
			mapgrcodes.put('Offline','SMOF');
			mapgrcodes.put('Leisure','FL');
			mapgrcodes.put('Corporate','FC');
			for (vslabel item : svalues){
				grcode = itemcode;
				if (isLabelBased){
					if (mapgrcodes.ContainsKey(item.label)){
						grcode = (String) mapgrcodes.get(item.label);
						if (item.value==null || String.IsEmpty(item.value)){item.value='0';}
					}
				}
				if (String.IsEmpty(grcode)){
					continue;
				}
				AMS_Agency_Profile__c businessprofile = (AMS_Agency_Profile__c) businessProfiles.get(grcode);
				if (businessprofile == null){
					businessprofile = new AMS_Agency_Profile__c(GR_Code__c = grcode,GR_Item__c = null);
					businessProfiles.put(grcode, businessprofile);
				}
				if (isMultipleSelection){
					if (businessprofile.GR_Item__c == null){
						businessprofile.GR_Item__c = item.value;
					}else{
						businessprofile.GR_Item__c = businessprofile.GR_Item__c + ';' + item.value;
					}
				}else{
					businessprofile.GR_Item__c = item.value;
				}
				businessprofile.Account__c = currentAccountId;
				this.businessProfiles.put(grcode, businessprofile);
			}
		}
		private void getinOperationsSince(){
			vslabel slabel = new vslabel( 'DIBS',this.sections.AgencyLegalStatus.values.inOperationsSince);
			List<vslabel> values = new List<vslabel>();
			values.add(slabel);
			setBusinessCodes(values, false, true, 'DIBS');
		}

		private void getdestinationSpecialties(){
			List<vslabel> values = this.sections.BusinessSpecialization.values.destinationSpecialties.values;
			setBusinessCodes(values, true, true, 'DS');
		}
		private void getmarketSpecialties(){
			List<vslabel> values = this.sections.BusinessSpecialization.values.marketSpecialties.values;
			setBusinessCodes(values, true, false, 'MK');
		}
		private String getGDS(){
			List<vslabel> values = this.sections.BusinessProfile.values.GDS.values;
			string selection = null;
			if (values == null || values.isEmpty() == true || values.size() == 0){
				return selection;
			}
			for (vslabel item : values){
				if (selection == null){
					selection = item.value;
				}else{
					selection = selection + ';' + item.value;
				}
			}
			return selection;
		}
		private void getPrincipalActivities(){
			List<vslabel> values = this.sections.BusinessProfile.values.principalActivities.values;
			setBusinessCodes(values, true, true, 'AT');
		}
		private void getMarketFocus(){
			List<vslabel> values = this.sections.BusinessProfile.values.marketFocus.values;
			setBusinessCodes(values, false, true, '');
		}
		private void getSalesMix(){
			List<vslabel> values = this.sections.BusinessProfile.values.salesMix.values;
			setBusinessCodes(values, false, true, '');
		}
		private void getBusinessProfile(){
			List<vslabel> values = this.sections.BusinessSpecialization.values.percentageBreakdown.values;
			setBusinessCodes(values, false, true, '');
		}
	}

	@future
	private static void manageHierarchy(string accountId, string applicationType){
		if(applicationType == TIDS_Constant.NEW_HO){
			insert( new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy', Main_account__c = accountId));

		}else{
			boolean bIsHiearchyCreated = AMS_RecordCreatorWebservice.publicCreateHierarchy(accountId, applicationType);
		}
	}

	@future
	public static void createChangeCode(string accountId, string applicationType){
		string sSettingName = '';
		if(applicationType == TIDS_Constant.NEW_HO || applicationType == TIDS_Constant.NEW_BR || applicationType == TIDS_Constant.NEW_VB){
			sSettingName = 'TIDS-FIN';
		}
		if(applicationType==TIDS_Constant.CHG_NAME || applicationType==TIDS_Constant.CHG_ADDRESS){
			sSettingName = 'TIDS-CHF';
		}
		if(applicationType==TIDS_Constant.RELINQ_HO || applicationType==TIDS_Constant.RELINQ_BR || applicationType==TIDS_Constant.RELINQ_VB){
			sSettingName = 'TIDS-CLO';
		}
		if(applicationType==TIDS_Constant.REINSTATE_HO || applicationType==TIDS_Constant.REINSTATE_BR || applicationType==TIDS_Constant.REINSTATE_VB){
			sSettingName = 'TIDS-REI';
		}

		if(sSettingName!=''){
			AMS_OSCAR_JSON.ChangeCode cc = AMS_ChangeCodesConfigHelper.createChangeCodeFromConfigSetting(sSettingName, '', '', null, '');
			//DO NOT SET REASON CODE/DESCRIPTION OR ACCUONT STATUS. Otherwhise, Last Org Date Change gets updated, and we don't want it.
			Agency_Applied_Change_code__c changeCode = new Agency_Applied_Change_code__c(
						Account__c = accountId
						,Active__c = true
						,Bulletin_Information__c = cc.memoText
						,Change_Code__c = cc.name
						,To_Publish_in_e_Bulletin__c = cc.publishedOnEBulletin
						);
			insert changeCode;
		}
	}
}