/**
 * Manager class that handles the creation of opportunities and quotes
 */
public with sharing class IECQuoteManager {

    /**
     * Creates an opportunity and a quote for a specific customer and rate plan
     */
    public static zqu__Quote__c submitQuote(IECCustomer oCustomer, Product_Rate_Plan_Information__c oRatePlanInfo, Boolean bAutoRenew, Decimal dQuoteAmount, String sComments, Decimal dTax, Decimal dShipping) {
        
        // Create a savepoint
        Savepoint sp = Database.setSavepoint();
        
        try {

            // create opportunity
            Opportunity oOpp = new Opportunity();
            oOpp.Name = oRatePlanInfo.Related_Product_Information__r.Related_Product_Category__r.Name + '_' + Datetime.now().format().replaceAll(' ', '_');
            oOpp.RecordTypeId = getOpportunityRecordType();
            oOpp.Related_Contact__c = oCustomer.RelatedContact.Id;
            oOpp.Amount = dQuoteAmount;
            oOpp.AccountId = oCustomer.RelatedAccount.Id;
            oOpp.StageName = IECConstants.Opportunity_StageName_NeedsAssessment;
            Date dtFirstDayOfNextMonth = Date.newInstance(Date.today().year(), Date.today().month()+1, 1);
            oOpp.CloseDate = dtFirstDayOfNextMonth.addDays(-1);
            oOpp.Type = IECConstants.Opportunity_Type_NewCustomerSale;
            oOpp.CurrencyIsoCode = 'USD';
            oOpp.OwnerId = IECUserManager.getIECAccountOwnerId();
            // new mandatory field: 2014-11-05
            oOpp.Sales_Team__c = 'eCommerce';
            insert oOpp;
            
            // create Zuora quote
            zqu__Quote__c oQuote = new zqu__Quote__c();
            //oQuote.Name = 'Luc to confirm';
            oQuote.Name = oQuote.zqu__Number__c;
            oQuote.zqu__StartDate__c = Date.today();
            oQuote.zqu__ValidUntil__c = oOpp.CloseDate;
            oQuote.zqu__SubscriptionTermStartDate__c = dtFirstDayOfNextMonth;
            oQuote.zqu__TermStartDate__c = dtFirstDayOfNextMonth;
            oQuote.zqu__Service_Activation_Date__c = dtFirstDayOfNextMonth;
            oQuote.zqu__SubscriptionType__c = IECConstants.Quote_SubscriptionType_NewSubscription;
            if (String.isNotBlank(getQuoteTemplateIdForNewSubscription()))
                oQuote.zqu__QuoteTemplate__c = getQuoteTemplateIdForNewSubscription();
            oQuote.zqu__BillToContact__c = oCustomer.RelatedContact.Id;
            oQuote.zqu__SoldToContact__c = oCustomer.RelatedContact.Id;
            oQuote.IEC_Opportunity_Id__c = oOpp.Id; // save Opportunity Id in temp field. Will be linked by the Web Service.
            oQuote.zqu__Currency__c = oOpp.CurrencyIsoCode;
            oQuote.zqu__Terms__c = sComments;
            oQuote.zqu__Status__c = 'New';
            oQuote.zqu__RecordReadOnly__c = false;
            oQuote.zqu__AutoRenew__c = bAutoRenew;
            oQuote.zqu__PaymentMethod__c = 'Credit Card';
            oQuote.zqu__PaymentTerm__c = 'Net 30';
            oQuote.zqu__InitialTerm__c = 12;
            oQuote.zqu__RenewalTerm__c = 12;
            // Specify the source to SFDC to avoid re-calculating the Tax & Shipping
            oQuote.Source__c = 'Salesforce';

            // Determine whether the quote is confirmed or requires validation
            if (oRatePlanInfo.Related_Product_Information__r.Related_Product_Category__r.Show_price_on_eCommerce__c == null
				|| oRatePlanInfo.Related_Product_Information__r.Related_Product_Category__r.Show_price_on_eCommerce__c == 'Yes')
				oQuote.Quote_Validation_Status__c = IECConstants.Quote_ValidationStatus_Confirmed;
			else
				oQuote.Quote_Validation_Status__c = IECConstants.Quote_ValidationStatus_ValidationRequired;
            
            // if the customer exist in Zuora
            if (oCustomer.AccountExistsInZuora) {
                // query to retrieve the Billing Account
                Zuora__CustomerAccount__c oBillingAccount = IECZuoraHelper.getBillingAccountByContactId(oCustomer.RelatedContact.Id);
                oQuote.Related_Billing_Account__c = (oBillingAccount != null ? oBillingAccount.Id : null);
                oQuote.zqu__ZuoraAccountID__c = (String)oCustomer.RelatedZuoraAccount.getValue('Id');
            }
            
            insert oQuote;
            
            // link the product rate plan to the quote (if not in test)
            if (!Test.isRunningTest()) {
            	List<zqu.zChargeGroup> lstZChrgGrp = new List<zqu.zChargeGroup>();

                // Load the product rate plans into memory and associate them to the quote.
                zqu.zChargeGroup chargeGroup = zqu.zQuoteUtil.getChargeGroup(oQuote.Id, oRatePlanInfo.Product_Rate_Plan__r.Id);
                
                if (chargeGroup != null)
                	lstZChrgGrp.add(chargeGroup);
                
                // Add tax product
	            if (dTax != null)
	            {
	            	List<zqu__ProductRatePlan__c> lstProdRatePlan_Tax = IECProductManager.getZuoraRatePlansFromIDs(new Set<String> {Utility.getTextSetting('Zuora tax Plan id')});
	            	
	            	if (!lstProdRatePlan_Tax.isEmpty())
	                {
	                	// Load the Tax product rate plans into memory and associate them to the quote.
		                zqu.zChargeGroup chargeGroup_Tax = zqu.zQuoteUtil.getChargeGroup(oQuote.Id, lstProdRatePlan_Tax[0].Id);
	                	
	                	List<zqu.zCharge> lstCharge = chargeGroup_Tax.zCharges;
	                	
	                	// Update Effective Price and force recalculation
	                	lstCharge[0].EFFECTIVE_PRICE = String.valueOf(dTax);
	                	chargeGroup_Tax.zCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(lstCharge);
	                	
	                	lstZChrgGrp.add(chargeGroup_Tax);
	                }
	            }
	            
	            // Add shipping product
	            if (dShipping != null && dShipping > 0)
	            {
	                List<zqu__ProductRatePlan__c> lstProdRatePlan_Ship = IECProductManager.getZuoraRatePlansFromIDs(new Set<String> {Utility.getTextSetting('Zuora tax Plan id')});
	            	
	            	if (!lstProdRatePlan_Ship.isEmpty())
	                {
	                	// Load the Shipping product rate plans into memory and associate them to the quote.
		                zqu.zChargeGroup chargeGroup_Ship = zqu.zQuoteUtil.getChargeGroup(oQuote.Id, lstProdRatePlan_Ship[0].Id);
		                
		                List<zqu.zCharge> lstCharge = chargeGroup_Ship.zCharges;
	                	
	                	// Update Effective Price and force recalculation
	                	lstCharge[0].EFFECTIVE_PRICE = String.valueOf(dShipping);
	                	chargeGroup_Ship.zCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(lstCharge);
	                	
	                	lstZChrgGrp.add(chargeGroup_Ship);
	                }
	            }

                // Now add these charge groups into the quote and persist.
                zqu.zQuoteUtil.addChargeGroups(lstZChrgGrp);
            }
            
            assignQuoteToOpportunity(oQuote.Id);
            
            return oQuote;
        }
        catch(Exception ex) {
            Database.rollback(sp);
            if (Test.isRunningTest())
                throw ex;
            else
                throw new IECApplicationException('Could not submit quote: ' + ex.getMessage());
        }
    }
    
    /**
     * Gets the record type for the opportunity
     */
    public static Id getOpportunityRecordType() {
            
        return RecordTypeSingleton.getInstance().getRecordTypeId('Opportunity', 'GDP_Opportunities');
    }
    
    /**
     * Returns the Quote Template Id to use for new subscription
     */
    public static String getQuoteTemplateIdForNewSubscription() {
        return IEC_Settings__c.getOrgDefaults().Quote_Template_ID_New_Subscription__c;
    }
    
    /**
     * This method is used to bypass the following limitation: the current license assigned to our IEC customers (Community Portal User)
     * cannot assign Quotes to Opportunities. So we call an inbound Web Service as the systemintegration user to assign the quote to the opportunity
     */
    @future (callout=true)
    private static void assignQuoteToOpportunity(Id quoteId) {
        try {
            if (!Test.isRunningTest()) {
                
                // login
                partnerSoapSforceCom.Soap spWs = new partnerSoapSforceCom.Soap();
                spWs.endpoint_x = IEC_Settings__c.getOrgDefaults().SF_Partner_Web_Service_endpoint__c;
                partnerSoapSforceCom.LoginResult loginResult = spWs.login(IEC_Settings__c.getOrgDefaults().IEC_Web_Service_Username__c, IEC_Settings__c.getOrgDefaults().IEC_Web_Service_Password__c);
                
                // call the web service to assign the quote to the opportunity
                soapSforceComSchemasClassIecWebser2.IEC_WebService ws = new soapSforceComSchemasClassIecWebser2.IEC_WebService();
                ws.endpoint_x = IEC_Settings__c.getOrgDefaults().IEC_Web_Service_Endpoint__c;
                ws.SessionHeader = new soapSforceComSchemasClassIecWebser2.SessionHeader_element();
                ws.SessionHeader.sessionId = loginResult.SessionID;
                
                Boolean bResult = ws.assignOpportunityToQuote(quoteId);
                if (bResult==false)
                    throw new IECApplicationException('Could not link Quote id ' + quoteId + ' to its Opportunity');
            }
            else {
                zqu__Quote__c oQuote = getQuoteById(quoteId);
                oQuote.zqu__Opportunity__c = oQuote.IEC_Opportunity_Id__c;
                update oQuote;
            }
        }
        catch (Exception ex) {
            system.debug('Error in assignQuoteToOpportunity: ' + ex.getMessage());
        }
    }
    
    /**
     * Returns a Quote by its SalesForce ID
     */
    public static zqu__Quote__c getQuoteById(String sQuoteId) {
        return [SELECT zqu__Number__c, zqu__Opportunity__c, Name, Related_Billing_Account__c, IEC_Opportunity_Id__c, zqu__AutoRenew__c, zqu__Terms__c 
                FROM zqu__Quote__c
                WHERE Id = :sQuoteId
                limit 1];
    }
    
    /**
     * Returns the list of Quotes associated to a contact
     */
    public static List<zqu__Quote__c> getQuotesByContactId(String sContactId) {
        return [SELECT Id, zqu__Number__c, zqu__Opportunity__c, Name, zqu__StartDate__c, Related_Billing_Account__c, IEC_Opportunity_Id__c, zqu__AutoRenew__c, 
                    zqu__Terms__c, zqu__ValidUntil__c, Quote_Validation_Status__c,
                    (SELECT zqu__QuoteRatePlanZuoraId__c,zqu__QuoteProductName__c,zqu__ProductRatePlanZuoraId__c FROM zqu__Quote_Rate_Plans__r),
                    (SELECT zqu__ProductRatePlanName__c FROM zqu__QuoteCharge__r) 
                FROM zqu__Quote__c
                WHERE zqu__BillToContact__c = :sContactId
                ORDER BY zqu__StartDate__c DESC];
    }
}