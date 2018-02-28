/**
 * REST API for NewGen Mobile APP
 * @author Miguel Duarte
 * @since 04/01/2018
 */
@RestResource(urlMapping='/newgenapp/v1/iceGetBalances_asda/*')
global class NewGen_Rest_ICE_Balances {

	@HttpGet
	global static List <WrapperStatement> doGet(){
        List <WrapperStatement> listWrapper = new List <WrapperStatement>();
        WrapperStatement wrapperStatement;
        String disclaimer = Label.ISSP_Account_Statements_Disclaimer;

        ISSP_Ctrl_AccountStatements accountStatementCtrl = new ISSP_Ctrl_AccountStatements();

        // does it need to add China's disclaimer ?
        if(accountStatementCtrl.account.Country_ISO_Code__c == 'CN' && accountStatementCtrl.account.Sector__c == 'Travel Agent'){
        	disclaimer += Label.ISSP_Account_Statements_Disclaimer_China_TravelAgent;
        }
        if(accountStatementCtrl.listMessages != null && !accountStatementCtrl.listMessages.isEmpty()){
	    	wrapperStatement = new WrapperStatement();
	        wrapperStatement.errorMessages = accountStatementCtrl.listMessages;
	        listWrapper.add(wrapperStatement);
	    }
	    else if(accountStatementCtrl.listWrapper != null && !accountStatementCtrl.listWrapper.isEmpty()){
	        for(ISSP_Ctrl_AccountStatements.WrapperStatement statement : accountStatementCtrl.listWrapper){
	        	wrapperStatement = new WrapperStatement();
	        	wrapperStatement.listCurrency = accountStatementCtrl.listCurrency;
	        	wrapperStatement.lastUpdatedOn = accountStatementCtrl.lastUpdatedOn.format();
	        	wrapperStatement.disclaimer = disclaimer;
	        	wrapperStatement.listStatements = new List <Account_Statement__c>();
	        	wrapperStatement.listStatements.addAll(statement.listStatements);
	        	wrapperStatement.accountSite = statement.accountSite;
	        	wrapperStatement.location = Label.ISSP_Account_Statement_Location;
	        	wrapperStatement.addParentAccountStatement(statement.parent);
	        	listWrapper.add(wrapperStatement);
	        }
	    }

        return listWrapper;
	}

	global class WrapperStatement {
		global List <Account_Statement__c> listStatements {get; set;}
		global String accountSite {get;set;}
		global List <String> errorMessages {get;set;}
		global List <String> listCurrency {get; set;}
		global String location { get; set;}
		global String lastUpdatedOn { get; set; }
		global String disclaimer { get; set; }
		global ParentWrapperStatement parentWrapper { get; set; }

		global void addParentAccountStatement(Account_Statement__c parentAccountStatement){
			parentWrapper = new ParentWrapperStatement();
			parentWrapper.period = parentAccountStatement.Period__c;
			parentWrapper.remittanceDate = parentAccountStatement.Remittance_Date__c;
			parentWrapper.remittanceDateFormated = parentAccountStatement.Remittance_Date__c.format();
			parentWrapper.currencyIsoCode = parentAccountStatement.CurrencyIsoCode;
			parentWrapper.billingAmount = parentAccountStatement.Billing_Amount__c;
			parentWrapper.billingAdjustment = parentAccountStatement.Billing_Adjustment__c;
			parentWrapper.amountToBePaid = parentAccountStatement.Amount_to_be_Paid__c;
			parentWrapper.paid = parentAccountStatement.Paid__c;
			parentWrapper.balance = parentAccountStatement.Balance__c;
			parentWrapper.status = parentAccountStatement.Status__c;
		}
    }

    global class ParentWrapperStatement {
    	global String period { get; set; }
    	global Date remittanceDate { get; set; }
    	global String remittanceDateFormated { get; set; }
    	global String currencyIsoCode { get; set; }
    	global Decimal billingAmount { get; set; }
    	global Decimal billingAdjustment { get; set; }
    	global Decimal amountToBePaid { get; set; }
    	global Decimal paid { get; set; }
    	global Decimal balance { get; set; }
    	global String status { get; set; }
    }
}