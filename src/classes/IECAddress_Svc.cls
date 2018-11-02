/* Test Coverage: some of the functions below are covered in the class Location_Dom_Test */

public class IECAddress_Svc 
{
    public static SAP_CustomerMaster.HTTPS_Port setCalloutHeader(SAP_CustomerMaster.HTTPS_Port req)
    {
        String authorizationHeader =  Utility.getSAPauthorization();

        if(req.inputHttpHeaders_x == null)
        {
            req.inputHttpHeaders_x = new Map<String,String>(); 
        }
        req.inputHttpHeaders_x.put('Authorization', authorizationHeader);
        req.timeout_x = Utility.getIntegerSetting('SAP_CALL_TIMEOUT');
        req.endpoint_x = Utility.fixEndpointDomain(req.endpoint_x);

        return req;
    }

    /************************************************************************************************
     *  Created By David D 02/2016                                                                  *
     *      This function return the Request Type to send to SAP                                    *
     *      Xyy     X:    C  = Create      U = Update      D = Delete (or inactivation)             *
     *             yy:    SP = Sold-to    BP = Bill-to    SH = Ship-to                              *
     ************************************************************************************************/
    public static String getRequestType(Location__c location)
    {
        String requestType;
        if(location.Active__c == false) requestType = 'D';
        else if(String.isNotBlank(location.SAP_Id__c))  requestType = 'U' ;
        else requestType = 'C';
 
        if(location.Type__c == 'Sold To') requestType += 'SP';
        else if(location.Type__c == 'Bill To') requestType += 'BP';
        else if(location.Type__c == 'Ship To') requestType += 'SH';
        else requestType = null;

        return requestType;
    }

    public static String getSAPPaymentType(String paymentType)
    {
        if(paymentType == null) return paymentType;
        
        Map<String, String> SAPPaymentMap = new Map<String, String>{
            'creditcard'            =>  '1',
            'banktransfer'          =>  'T',
            'check'                 =>  'C',
            'ich'                   =>  'I'
        };

        String str = paymentType.toLowerCase().replace(' ', '');

        return (SAPPaymentMap.containsKey(str)) ? SAPPaymentMap.get(str) : paymentType;
    }


	/****************************************************************************************************
	    Created by Thai 2016-12-01
	        Return SAP code for region (province)
	****************************************************************************************************/
	String getSAPRegion(IECAddress__c address)
	{
		String isoStateCodeSAP = '';
		String isoCountryCode = address.ISO_Country__r.ISO_Code__c;
		String isoStateCode = address.ISO_State__r.ISO_Code__c;
		
		if (!String.isBlank(isoCountryCode) && !String.isBlank(isoStateCode) && address.ISO_State__r.IEC_Valid_SAP__c == true)
			if (isoStateCode.length() > 3 && isoStateCode.substring(0, 3) == isoCountryCode + '-')
				isoStateCodeSAP = isoStateCode.substring(3);
			else
				isoStateCodeSAP = isoStateCode;
		
		return isoStateCodeSAP;
	} //*** end of "getSAPRegion"


	/****************************************************************************************************
	    Created by Thai 2016-12-01
	        Return VAT number in SAP format
	****************************************************************************************************/
	String getSAPVATNumber(String VATNumber, String isoCountryCode)
	{
		String SAPVATNumber = '';
        system.debug('VATNumber : ' + VATNumber);
		system.debug('isoCountryCode : ' + isoCountryCode);
		
		if (!String.isBlank(VATNumber) && !String.isBlank(isoCountryCode) && isoCountryCode.contains('GR')){
            
            // SPECIAL CASE FOR GREECE - SEND isoCountryCode = EL
            if (!VATNumber.startsWithIgnoreCase(isoCountryCode) && !VATNumber.contains('EL'))
                SAPVATNumber = Utility.truncate('EL' + VATNumber, 20);
			else // VATNumber.contains('EL')
				SAPVATNumber = Utility.truncate(VATNumber, 20);
            // SPECIAL CASE FOR GREECE - SEND isoCountryCode = EL
        }
        
        if (!String.isBlank(VATNumber) && !String.isBlank(isoCountryCode) && !isoCountryCode.contains('GR')){
            if (!VATNumber.startsWithIgnoreCase(isoCountryCode))
                SAPVATNumber = Utility.truncate(isoCountryCode + VATNumber, 20);
			else
				SAPVATNumber = Utility.truncate(VATNumber, 20);
		}
        system.debug('SAPVATNumber : ' + SAPVATNumber);
		return SAPVATNumber;

	} //*** end of "getSAPVATNumber"



	/****************************************************************************************************
	    Created by Thai 2016-12-01
	        Create/Update Sold To or Bill To or Ship To partners with SAP
	****************************************************************************************************/
	Enum SAPPartnerType {SOLD, BILL, SHIP}
	public static List<IEC_Error_Log__c> syncCustomerWithSAP(List<Location__c> lstLocation, Map<Id, String> mapContactId_SoldToSAP, Boolean commitDLM)
	{
		return syncCustomerWithSAP(lstLocation, mapContactId_SoldToSAP, commitDLM, null);
	}
	public static List<IEC_Error_Log__c> syncCustomerWithSAP(List<Location__c> lstLocation, Map<Id, String> mapContactId_SoldToSAP, Boolean commitDLM, List<Account> lstAccountToUpdate)
	{
		SAPPartnerType forPartnerType;
		Boolean isCreating;
		List<IEC_Error_Log__c> lstResult = new List<IEC_Error_Log__c>();
		SAP_CustomerMaster.HTTPS_Port http = new SAP_CustomerMaster.HTTPS_Port();
		setCalloutHeader(http);
		SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request request;
		SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Response response;
		IECAddress_Svc cls = new IECAddress_Svc();
		
		for (Location__c loc : lstLocation)
			try
			{
				//*** create request
				request = new SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request();
				request.RequestType = getRequestType(loc);
				if (request.RequestType == null)
				{
					lstResult.add(IECErrorLogger.createErrorLog('IECAddress_Svc.syncCustomerWithSAP', JSON.serialize(loc), 'Not a customer', null));
					continue;
				}
				else if (request.RequestType == 'DSP')   //*** do no deactivate sold to
				{
					lstResult.add(null);
					continue;
				}
				isCreating = (request.RequestType.left(1) == 'C');
				if (request.RequestType.right(2) == 'SP')
					forPartnerType = SAPPartnerType.SOLD;
				else if (request.RequestType.right(2) == 'BP')
					forPartnerType = SAPPartnerType.BILL;
				else
					forPartnerType = SAPPartnerType.SHIP;
				
				//*** information to send
				request.SoldTo = new SAP_CustomerMaster.SoldTo_element();
				if (forPartnerType == SAPPartnerType.SOLD)
				{
					request.SoldTo.Name1         = Utility.truncate(loc.Account__r.Name, 40);
					request.SoldTo.Name2         = Utility.truncate(loc.Account__r.Name, 40, 40);
					request.SoldTo.Name3         = Utility.truncate(loc.Account__r.Name, 80, 40);
					request.SoldTo.SearchTerm1   = Utility.truncate(loc.Account__c, 15);
					List<String> addressLines 	 = Utility.splitAddress(loc.Address__r.Street__c, 35);
					request.SoldTo.Street2       = addressLines[0];
					request.SoldTo.Street3       = addressLines[1];
					request.SoldTo.PostalCode    = Utility.truncate(loc.Address__r.ZipCode__c, 10);
					request.SoldTo.City          = Utility.truncate(loc.Address__r.City__c, 40);
					request.SoldTo.Country       = Utility.truncate(loc.Address__r.ISO_Country__r.ISO_Code__c,3);
					request.SoldTo.Region        = Utility.truncate(cls.getSAPRegion(loc.Address__r), 3);
					request.SoldTo.VAT_Reg_No    = Utility.truncate(cls.getSAPVATNumber(loc.VAT_Number__c, loc.Address__r.ISO_Country__r.ISO_Code__c), 20);
					request.SoldTo.Telephone     = Utility.truncate(loc.Account__r.Phone, 30);
					request.SoldTo.Email         = Utility.truncate(loc.Account__r.Email__c, 241);
					request.SoldTo.PaymentMethod = getSAPPaymentType(loc.Account__r.Default_Payment_Type__c);
					//request.SoldTo.PaymentTerms  = Utility.truncate(loc.Account__r.Account_Payment_Term__c, 4);   //*** this attribute belongs to SAP therefore do not send
					if (isCreating)
						request.SFDCAccountID = Utility.truncate(loc.Account__c, 15);       //*** SFDC Account ID to be used in SAP on creation
					else
						request.SoldTo.SAPSoldToID = Utility.truncate(loc.SAP_Id__c, 10);   //*** SAP Id to update
				}
				else
				{
					request.SoldTo.SAPSoldToID = Utility.truncate((mapContactId_SoldToSAP != null && mapContactId_SoldToSAP.containsKey(loc.Contact__c) ? mapContactId_SoldToSAP.get(loc.Contact__c) : loc.Account__r.SoldTo_Location__r.SAP_Id__c), 10);
					
					SAP_CustomerMaster.Contact_element contactInfo = new SAP_CustomerMaster.Contact_element(); 
					contactInfo.Title     = Utility.truncate(loc.Contact__r.Salutation, 30);
					contactInfo.FirstName = Utility.truncate(loc.Contact__r.FirstName, 40);
					contactInfo.LastName  = Utility.truncate(loc.Contact__r.LastName, 40);
					contactInfo.Telephone = Utility.truncate(loc.Phone__c, 30);
					contactInfo.Email     = Utility.truncate(loc.Email__c, 241);
					
					if (forPartnerType == SAPPartnerType.BILL)
					{
						request.BillTo               = new SAP_CustomerMaster.BillTo_element();
						request.BillTo.Contact       = contactInfo;
						request.BillTo.Name1         = Utility.truncate(loc.Account__r.Name, 40);
						request.BillTo.Name2         = Utility.truncate(loc.Account__r.Name, 40, 40);
						request.BillTo.Name3         = Utility.truncate(loc.Account__r.Name, 80, 40);
						request.BillTo.SearchTerm1   = Utility.truncate(loc.Contact__c, 15);
						List<String> addressLines 	 = Utility.splitAddress(loc.Address__r.Street__c, 35);
						request.BillTo.Street2       = addressLines[0];
						request.BillTo.Street3       = addressLines[1];	
						request.BillTo.PostalCode    = Utility.truncate(loc.Address__r.ZipCode__c, 10);
						request.BillTo.City          = Utility.truncate(loc.Address__r.City__c, 40);
						request.BillTo.Country       = Utility.truncate(loc.Address__r.ISO_Country__r.ISO_Code__c, 3);
						request.BillTo.Region        = Utility.truncate(cls.getSAPRegion(loc.Address__r), 3);
						request.BillTo.VAT_Reg_No    = Utility.truncate(cls.getSAPVATNumber(loc.VAT_Number__c, loc.Address__r.ISO_Country__r.ISO_Code__c), 20);
						request.BillTo.PaymentMethod = getSAPPaymentType(loc.Account__r.Default_Payment_Type__c);
					}
					else
					{
						request.ShipTo               = new SAP_CustomerMaster.ShipTo_element();
						request.ShipTo.Contact       = contactInfo;
						request.ShipTo.Name1         = Utility.truncate(loc.Account__r.Name, 40);
						request.ShipTo.Name2         = Utility.truncate(loc.Account__r.Name, 40, 40);
						request.ShipTo.Name3         = Utility.truncate(loc.Account__r.Name, 80, 40);
						request.ShipTo.SearchTerm1   = Utility.truncate(loc.Contact__c, 15);
						//TC: Enhancement
                		List<String> addressLines 	 = Utility.splitAddress(loc.Address__r.Street__c, 35);
						request.ShipTo.Street2       = addressLines[0];
						request.ShipTo.Street3       = addressLines[1];
						request.ShipTo.PostalCode    = Utility.truncate(loc.Address__r.ZipCode__c, 10);
						request.ShipTo.City          = Utility.truncate(loc.Address__r.City__c, 40);
						request.ShipTo.Country       = Utility.truncate(loc.Address__r.ISO_Country__r.ISO_Code__c, 3);
						request.ShipTo.Region        = Utility.truncate(cls.getSAPRegion(loc.Address__r), 3);
						request.ShipTo.VAT_Reg_No    = Utility.truncate(cls.getSAPVATNumber(loc.VAT_Number__c, loc.Address__r.ISO_Country__r.ISO_Code__c), 20);
					}
					
					if (isCreating)
						request.SFDCContactID = Utility.truncate(loc.Contact__c, 15);       //*** SFDC Contact ID to be used in SAP on creation
					else if (forPartnerType == SAPPartnerType.BILL)
						request.BillTo.SAPBillToID = Utility.truncate(loc.SAP_Id__c, 10);   //*** SAP Id to update
					else
						request.ShipTo.SAPShipToID = Utility.truncate(loc.SAP_Id__c, 10);   //*** SAP Id to update
				}
				
				//*** sync with SAP
				if (String.isBlank(request.SoldTo.SAPSoldToID) && (forPartnerType != SAPPartnerType.SOLD  || (!isCreating && forPartnerType == SAPPartnerType.SOLD)))
					lstResult.add(IECErrorLogger.createErrorLog('IECAddress_Svc.syncCustomerWithSAP', JSON.serialize(request), 'Missing Sold To SAP Id', null));
				else if (!isCreating && forPartnerType == SAPPartnerType.BILL && String.isBlank(request.BillTo.SAPBillToID))
					lstResult.add(IECErrorLogger.createErrorLog('IECAddress_Svc.syncCustomerWithSAP', JSON.serialize(request), 'Missing Bill To SAP Id', null));
				else if (!isCreating && forPartnerType == SAPPartnerType.SHIP && String.isBlank(request.ShipTo.SAPShipToID))
					lstResult.add(IECErrorLogger.createErrorLog('IECAddress_Svc.syncCustomerWithSAP', JSON.serialize(request), 'Missing Ship To SAP Id', null));
				else
				{
					response = http.SI_SFDC_CustomerMasterUpdate_SYNC(request);
					if (response.Error == null)
					{
						//*** save SAP Id if request of creation
						if (isCreating)
							if (forPartnerType == SAPPartnerType.SOLD)
							{

								loc.SAP_Id__c = response.SAP_SoldTo.SAPSoldToID;
								if (lstAccountToUpdate == null){
									lstAccountToUpdate = new List<Account>();
								}

								if(String.isBlank(response.SAP_SoldTo.PaymentTerms)){
									lstAccountToUpdate.add(new Account(Id = loc.Account__c));
								}else{
									lstAccountToUpdate.add(new Account(Id = loc.Account__c, Sales_Office__c = response.SAP_SoldTo.SalesOffice
								                                 , Payment_Term__c = response.SAP_SoldTo.PaymentTerms, Price_Group__c = response.SAP_SoldTo.PriceGroup));
								}


							}
							else if (forPartnerType == SAPPartnerType.BILL)
								loc.SAP_Id__c = response.SAP_BillTo.SAPBillToID;
							else
							{
								loc.SAP_Id__c = response.SAP_ShipTo.SAPShipToID;
								loc.Shipping_Condition__c = response.SAP_ShipTo.ShippingCondition;
							}
						lstResult.add(null);
					}
					else
						lstResult.add(IECErrorLogger.createErrorLog('IECAddress_Svc.syncCustomerWithSAP', JSON.serialize(request), String.valueOf(response.Error.Message), null));
				}
			}
			catch (Exception e)
			{
				lstResult.add(IECErrorLogger.createErrorLog('IECAddress_Svc.syncCustomerWithSAP', JSON.serialize(request), e.getMessage(), e.getStackTraceString()));
			}
		
		//*** save to database if instructed
		if (commitDLM)
		{
			Savepoint sp = Database.setSavepoint();
			try
			{
				//*** save locations
				upsert lstLocation;
				
				//*** save accounts
				if (lstAccountToUpdate != null && lstAccountToUpdate.size() > 0)
					update lstAccountToUpdate;
				
				//*** save errors if any
				try
				{
					List<IEC_Error_Log__c> lstError = new List<IEC_Error_Log__c>();
					for (Integer i = 0; i < lstResult.size(); i++)
						if (lstResult[i] != null)
							lstError.add(lstResult[i]);
					if (lstError.size() > 0)
						insert lstError;
				}
				catch (Exception e) {}
			}
			catch (Exception e)
			{
				IECErrorLogger.logApexException('IECAddress_Svc.syncCustomerWithSAP', String.valueOf(lstLocation), e.getMessage(), e.getStackTraceString());
				
				Database.rollback(sp);   //*** -> need to review SAP partners
				
				//*** add error to return result
				for (Integer i = 0; i < lstResult.size(); i++)
					if (lstResult[i] == null)
						lstResult[i] = IECErrorLogger.createErrorLog('IECAddress_Svc.syncCustomerWithSAP', String.valueOf(lstLocation), e.getMessage(), e.getStackTraceString());
			}
		}
		
		return lstResult;
	} //*** end of "syncCustomerWithSAP"


    /************************************************************************************************
     *  Created By David D 02/2016                                                                  *
     *      This function return the Request Object to send to SAP                                  *
     ************************************************************************************************/
/*    public static SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request createCustomerMasterRequestObject(Location__c location, Map<Id, Location__c> soldToLocationByContactId)
    {
        SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request request = new SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request();
            
        SAP_CustomerMaster.SoldTo_element soldTo = new SAP_CustomerMaster.SoldTo_element();
        SAP_CustomerMaster.BillTo_element billTo = new SAP_CustomerMaster.BillTo_element();
        SAP_CustomerMaster.ShipTo_element shipTo = new SAP_CustomerMaster.ShipTo_element();

        SAP_CustomerMaster.Contact_element contactInfo = new SAP_CustomerMaster.Contact_element(); 
            contactInfo.Title       = Utility.truncate(location.Contact_Salutation__c,30);
            contactInfo.FirstName   = Utility.truncate(location.Contact_First_Name__c,40);
            contactInfo.LastName    = Utility.truncate(location.Contact_Last_Name__c,40);
            //contactInfo.Telephone   = Utility.truncate(location.Contact_Phone__c,30);
            contactInfo.Telephone   = Utility.truncate(location.Phone__c,30);
            //contactInfo.Email       = Utility.truncate(location.Contact_Email__c,241);
            contactInfo.Email       = Utility.truncate(location.Email__c,241);
            
        //-- Request Type : mandatory for all requests
        request.RequestType         = getRequestType(location);

        //-- SFDC Account ID: only for Sold To Creation 
        if(request.RequestType == 'CSP') request.SFDCAccountID = Utility.truncate(location.Account__c, 15); 

        //-- SFDC Contact ID: for Sold To Creation & Bill To Creation 
        if(request.RequestType == 'CSP' || request.RequestType == 'CBP' || request.RequestType == 'CSH') request.SFDCContactID = Utility.truncate(location.Contact__c, 15); 

        //-- SAP Sold To ID : for all except Sold To Creation 
        if(request.RequestType != 'CSP')
        {
            if(request.RequestType == 'USP') soldTo.SAPSoldToID  = Utility.truncate(location.SAP_Id__c, 10);
            else
            {
                //-- SoldTo is created first we enter here
                Location__c soldToLocation = soldToLocationByContactId.get(location.Contact__c);
                System.debug('soldToLocation::'+soldToLocation);
                if (soldToLocation != null)
                    soldTo.SAPSoldToID  = Utility.truncate(soldToLocation.SAP_Id__c, 10);
            }
        }

        //-- SAP Bill To ID : for Bill To Update/Inactivation 
        if(request.RequestType == 'UBP' || request.RequestType == 'DBP') billTo.SAPBillToID = Utility.truncate(location.SAP_Id__c, 10);

        //-- SAP Ship To ID : for Ship To Update/Inactivation 
        if(request.RequestType == 'USH' || request.RequestType == 'DSH') shipTo.SAPShipToID = Utility.truncate(location.SAP_Id__c, 10);

        //-- Sold To Details : when Create/Update SoldTo 
        if(request.RequestType == 'CSP' || request.RequestType == 'USP')
        {
            soldTo.Name1            = Utility.truncate(location.Account_Name__c,40);
            soldTo.Name2            = Utility.truncate(location.Account_Name__c,40,40);
            soldTo.Name3            = Utility.truncate(location.Account_Name__c,80,40);
            soldTo.SearchTerm1      = Utility.truncate(location.Account__c,15);
            soldTo.Street2          = Utility.truncate(location.Street__c,40);
            soldTo.Street3          = Utility.truncate(location.Street__c,40,60);
            soldTo.PostalCode       = Utility.truncate(location.ZipCode__c, 10);
            soldTo.City             = Utility.truncate(location.City__c, 40);
            soldTo.Country          = Utility.truncate(location.ISO_Country_Code__c,3);
            soldTo.Region           = (String.isBlank(location.ISO_State_Code_SAP__c)) ? 'NA' : Utility.truncate(location.ISO_State_Code_SAP__c,3);
            soldTo.Region           = (String.isBlank(location.ISO_State_Code_SAP__c) || location.IEC_Valid_SAP_State__c != true) ? '' : Utility.truncate(location.ISO_State_Code_SAP__c,3);
            soldTo.Telephone        = Utility.truncate(location.Account_Phone__c,30);
            soldTo.Email            = Utility.truncate(location.Account_Email__c,241);
            if (!String.isBlank(location.VAT_Number__c) && !String.isBlank(location.ISO_Country_Code__c))
                if (!location.VAT_Number__c.startsWithIgnoreCase(location.ISO_Country_Code__c))
                    soldTo.VAT_Reg_No = Utility.truncate(location.ISO_Country_Code__c + location.VAT_Number__c,20);
                else
                    soldTo.VAT_Reg_No = Utility.truncate(location.VAT_Number__c,20);
            soldTo.PaymentMethod    = getSAPPaymentType(location.Account_Payment_Type__c);
            //soldTo.PaymentTerms     = Utility.truncate(location.Account_Payment_Term__c,4);   //*** this attribute belongs to SAP therefore do not send
        }

        //-- Bill To Details: BillTo Update/Creation + SoldTo Creation
        if(request.RequestType == 'CSP' || request.RequestType == 'CBP' || request.RequestType == 'UBP')
        {
            billTo.Name1            = Utility.truncate(location.Account_Name__c,40);
            billTo.Name2            = Utility.truncate(location.Account_Name__c,40,40);
            billTo.Name3            = Utility.truncate(location.Account_Name__c,80,40);
            billTo.SearchTerm1      = Utility.truncate(location.Contact__c,15);
            billTo.Street2          = Utility.truncate(location.Street__c,40);
            billTo.Street3          = Utility.truncate(location.Street__c,40,60);
            billTo.PostalCode       = Utility.truncate(location.ZipCode__c, 10);
            billTo.City             = Utility.truncate(location.City__c, 40);
            billTo.Country          = Utility.truncate(location.ISO_Country_Code__c,3);
            //billTo.Region           = (String.isBlank(location.ISO_State_Code_SAP__c)) ? 'NA' : Utility.truncate(location.ISO_State_Code_SAP__c,3);
            billTo.Region           = (String.isBlank(location.ISO_State_Code_SAP__c) || location.IEC_Valid_SAP_State__c != true) ? '' : Utility.truncate(location.ISO_State_Code_SAP__c,3);
            billTo.PaymentMethod    = getSAPPaymentType(location.Account_Payment_Type__c);
            if (!String.isBlank(location.VAT_Number__c) && !String.isBlank(location.ISO_Country_Code__c))
                if (!location.VAT_Number__c.startsWithIgnoreCase(location.ISO_Country_Code__c))
                    billTo.VAT_Reg_No = Utility.truncate(location.ISO_Country_Code__c + location.VAT_Number__c,20);
                else
                    billTo.VAT_Reg_No = Utility.truncate(location.VAT_Number__c,20);
            billTo.Contact          = contactInfo;
        }

        //-- Ship To Details: ShipTo Update/Creation + SoldTo Creation
        if(request.RequestType == 'CSP' || request.RequestType == 'CSH' || request.RequestType == 'USH')
        {
            shipTo.Name1        = Utility.truncate(location.Account_Name__c,40);
            shipTo.Name2        = Utility.truncate(location.Account_Name__c,40,40);
            shipTo.Name3        = Utility.truncate(location.Account_Name__c,80,40);
            shipTo.SearchTerm1  = Utility.truncate(location.Contact__c,15);
            shipTo.Street2      = Utility.truncate(location.Street__c,40);
            shipTo.Street3      = Utility.truncate(location.Street__c,40,60);
            shipTo.PostalCode   = Utility.truncate(location.ZipCode__c, 10);
            shipTo.City         = Utility.truncate(location.City__c, 40);
            shipTo.Country      = Utility.truncate(location.ISO_Country_Code__c,3);
            //shipTo.Region       = (String.isBlank(location.ISO_State_Code_SAP__c)) ? 'NA' : Utility.truncate(location.ISO_State_Code_SAP__c,3);
            shipTo.Region       = (String.isBlank(location.ISO_State_Code_SAP__c) || location.IEC_Valid_SAP_State__c != true) ? '' : Utility.truncate(location.ISO_State_Code_SAP__c,3);
            if (!String.isBlank(location.VAT_Number__c) && !String.isBlank(location.ISO_Country_Code__c))
                if (!location.VAT_Number__c.startsWithIgnoreCase(location.ISO_Country_Code__c))
                    shipTo.VAT_Reg_No = Utility.truncate(location.ISO_Country_Code__c + location.VAT_Number__c,20);
                else
                    shipTo.VAT_Reg_No = Utility.truncate(location.VAT_Number__c,20);
            shipTo.Contact      = contactInfo; 
        }

        //-- Sold To Information: sent all the time 
        request.SoldTo = soldTo;

        //-- Bill To Information: for CSP, CBP, UBP and DBP
        if(request.RequestType == 'CSP' || request.RequestType == 'CBP' || request.RequestType == 'UBP' || request.RequestType == 'DBP') request.BillTo = billTo;

        //-- Ship To Information: for CSP, CSH, USH and DSH
        if(request.RequestType == 'CSP' || request.RequestType == 'CSH' || request.RequestType == 'USH' || request.RequestType == 'DSH') request.ShipTo = shipTo;

        return request;
    } 
*/
    
    /************************************************************************************************
     *  Created By David D 02/2016                                                                  *
     *      Logic to make SAP callouts                                                              *
     ************************************************************************************************/
    public static void syncCustomerMasterWithSAP(List<Location__c> locations)
    {

		if (locations == null || locations.size() == 0)
			return;
		
		Map<Id, Location__c> mapAccountId_SoldToLoc = new Map<Id, Location__c>();
		List<Location__c> lstBillToShipToLoc = new List<Location__c>();
		Map<Id, String> mapContactId_SoldToSAP = new Map<Id, String>();
		List<IEC_Error_Log__c> lstResult = new List<IEC_Error_Log__c>();
		List<Account> lstAccountToUpdate = new List<Account>();
		Integer i1;
		
		//*** split requests to sold to and bill/ship to
		for (i1 = 0; i1 <locations.size(); i1++)
			if (locations[i1].Type__c == IECConstants.SOLDTO)
				mapAccountId_SoldToLoc.put(locations[i1].Account__c, locations[i1]);
			else
			{
				lstBillToShipToLoc.add(locations[i1]);
				mapContactId_SoldToSAP.put(locations[i1].Contact__c, locations[i1].Account__r.SoldTo_Location__r.SAP_Id__c);
			}
		
		//*** send sold to requests
		if (mapAccountId_SoldToLoc.size() > 0)
			lstResult.addAll(syncCustomerWithSAP(mapAccountId_SoldToLoc.values(), null, false, lstAccountToUpdate));
		
		//*** finalize list of sold to SAP Id for bill/ship to requests if applicable
		for (i1 = 0; i1 <lstBillToShipToLoc.size(); i1++)
			if (mapAccountId_SoldToLoc.containsKey(lstBillToShipToLoc[i1].Account__c))
				mapContactId_SoldToSAP.put(lstBillToShipToLoc[i1].Contact__c, mapAccountId_SoldToLoc.get(lstBillToShipToLoc[i1].Account__c).SAP_Id__c);
		
		//*** send bill/ship to requests
		lstResult.addAll(syncCustomerWithSAP(lstBillToShipToLoc, mapContactId_SoldToSAP, false, null));
		
		//*** save results
		Savepoint sp = Database.setSavepoint();
		try
		{
			update locations;
			if (lstAccountToUpdate.size() > 0)
				update lstAccountToUpdate;
		}
		catch (Exception e)
		{
			lstResult.add(IECErrorLogger.createErrorLog('IECAddress_Svc.syncCustomerMasterWithSAP'
			                                          , '***** Need to validate partners in SAP *****\n\n' + String.valueOf(locations)
			                                          , e.getMessage(), e.getStackTraceString()));
			Database.rollback(sp);   //*** -> need to review SAP partners
		}
		
		//*** log error if any
		for (i1 = lstResult.size()-1; i1 >= 0; i1--)
			if (lstResult[i1] == null)
				lstResult.remove(i1);
		if (lstResult.size() > 0)
			try { insert lstResult; } catch (Exception e) { /* ignore error */ }
/*
        //-- Build Request objects for SAP call 
        Map<Id, SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request> requestByLocation = new Map<Id, SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request>(); 
        Map<Id, SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Response> responseByLocation = new Map<Id, SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Response>();

        //-- Sold To Location By Contact 
        Set<Id> contactIds = new Set<Id>();
        for(Location__c location : locations)
        {
            contactIds.add(location.Contact__c);
        }

        Location_Sel lSelector = new Location_Sel(); 
        Map<Id, Location__c> soldToLocationByContactId = lSelector.getSoldToLocationByContactId(contactIds);

        //-- Locations MAP 
        Map<Id, Location__c> locationById = new Map<Id, Location__c>(locations);
        
        map<String,String> ContactIdByAccountId = new map<String,String>();

        for(Location__c location : locations)
        {
        	requestByLocation.put(location.Id, createCustomerMasterRequestObject(location, soldToLocationByContactId));
            if(location.Contact__c != null)
            	ContactIdByAccountId.put(Utility.truncate(location.Contact__c,15),Utility.truncate(location.Account__c,15));
        }

        //-- Set Authentication header 
        SAP_CustomerMaster.HTTPS_Port req = new SAP_CustomerMaster.HTTPS_Port(); 
        req = setCalloutHeader(req);

        //-- Errors logging
        List<IEC_Error_Log__c> errorLogs = new List<IEC_Error_Log__c>();
        
        Map<Id, SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request> request2Reprocess = new Map<Id, SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request>();
		
		Map<Id,String> SAPAccountByAccountId = new Map<Id,String>();
		
		
		
        //-- Do Callouts for each location 
        for(Id locationId : requestByLocation.keySet())
        {
        	
            SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request request = requestByLocation.get(locationId);
            
            try
            {
            	SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Response response = req.SI_SFDC_CustomerMasterUpdate_SYNC(request);
                if(response.Error != null)  //*&& response.Error.Message.contains('locked')
                {
                   request2Reprocess.put(locationId, request); 
                }
                else
                {
                    responseByLocation.put(locationId, response);
                    if(request.RequestType == 'CSP')
                    	SAPAccountByAccountId.put(response.SAP_SoldTo.SFDCAccountID, response.SAP_SoldTo.SAPSoldToID);
                }
            }
            catch(Exception ex)
            {
                if(!System.isFuture() && !System.isBatch() && !System.isScheduled())
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,ex.getMessage()));
                else
                    errorLogs.add(IECErrorLogger.createErrorLog('IECAddress_Svc.syncCustomerMasterWithSAP', JSON.serialize(request), ex.getMessage(), ex.getStackTraceString()));                
            }
        }
        
        //-- Updated 2016-07-01 David D & Kevin K to reprocess failled SAP Customer master when sold to is locked
        if(!request2Reprocess.isEmpty())
        {
            for(Id locationId : request2Reprocess.keySet())
            {
                SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request request = request2Reprocess.get(locationId);
                try
                {
                	//if the SAPSoldToId is missing in the BillTo or ShipTo request 
                	if((request.RequestType == 'CBP' || request.RequestType == 'CSH') && (request.SoldTo == null || String.isBlank(request.SoldTo.SAPSoldToID))){
                		if(request.RequestType == 'CBP'){
                			String accountId = ContactIdByAccountId.get(request.BillTo.SearchTerm1);
                			if(accountId != null)
                				request.SoldTo.SAPSoldToID = SAPAccountByAccountId.get(accountId);
                		}
                		if(request.RequestType == 'CSH'){
                			String accountId = ContactIdByAccountId.get(request.ShipTo.SearchTerm1);
                			if(accountId != null)
                				request.SoldTo.SAPSoldToID = SAPAccountByAccountId.get(accountId);
                		}
                			
                	}
                		
                	
                    SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Response response = req.SI_SFDC_CustomerMasterUpdate_SYNC(request);
                    
                    responseByLocation.put(locationId, response);
                }
                catch(Exception ex)
                {
                    if(!System.isFuture() && !System.isBatch() && !System.isScheduled())
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,ex.getMessage()));
                    else
                        errorLogs.add(IECErrorLogger.createErrorLog('IECAddress_Svc.syncCustomerMasterWithSAP', JSON.serialize(request), ex.getMessage(), ex.getStackTraceString()));                
                }
            }
        }

        if(errorLogs.size() > 0) IECErrorLogger.logErrors(errorLogs, true);
        
        //-- Update with SAP response 
        processResponse(responseByLocation, requestByLocation);
*/
    }

    /************************************************************************************************
     *  Created By David D 02/2016                                                                  *
     *      This function is called by trigger when location is created/updated                     *
     *      Or when certain Contact information such as email changed                               *
     *      Then the changes are sent to SAP                                                        *
     ************************************************************************************************/
    public static void syncCustomerMasterWithSAP(Set<Id> locationIds)
    {   
        //set<Id> locationIdsToSend = new set<Id>();

        //for(Id locationId : locationIds){
        //    String methodName = Utility.idsInTriggers.get(locationId);
        //    if(methodName != null && methodName == 'syncCustomerMasterWithSAP'){
        //        //if(location.SAP_Id__c == oldLocation.SAP_Id__c)
        //        {
        //            locationIdsToSend.add(locationId);
        //        }
        //    }else{
        //        Utility.idsInTriggers.put(locationId,'syncCustomerMasterWithSAP');
        //    }
        //}
        
        //if(!locationIdsToSend.isEmpty())
        //if(locationIds.size() == 1)
        //{
            //List<Location__c> locations = (List<Location__c>) new Location_Sel().selectSObjectById(locationIds);
            List<Location__c> locations = Location_Sel.getLocationToSyncSAP(new List<Id>(locationIds), null, null, null, null).values();
            System.enqueueJob(new Location_Queue(locations));
        //}
        //else if (!locationIds.isEmpty()) Database.executeBatch(new Location_Batch(locationIds), 10);
            
    }

    /************************************************************************************************
     *  Created By David D 02/2016                                                                  *
     *      Same as previous function called when we are about to sync ShipTo or BillTo             *
     *      without SoldTo                                                                          *
     ************************************************************************************************/
    public static void syncCustomerMasterWithSAP(Set<Id> locationIds, Set<Id> soldToLocationIds2CreateFirst)
    {
        Set<Id> setAllLocationId = new Set<Id>();
        if (locationIds != null)
            setAllLocationId.addAll(locationIds);
        if (soldToLocationIds2CreateFirst != null)
            setAllLocationId.addAll(soldToLocationIds2CreateFirst);
        syncCustomerMasterWithSAP(setAllLocationId);
        //if (!locationIds.isEmpty() || !soldToLocationIds2CreateFirst.isEmpty())
            //Database.executeBatch(new Location_Batch(locationIds, soldToLocationIds2CreateFirst), 10);
        
        //System.debug('syncCustomerMasterWithSAP CREATE SOLDTO FIRST');

        //set<Id> locationIdsToSend = new set<Id>();
        //set<Id> soldToLocationIdsToSend = new set<Id>();

        //for(Id locationId : locationIds){
        //    String methodName = Utility.idsInTriggers.get(locationId);
        //    if(methodName != null && methodName == 'syncCustomerMasterWithSAP'){
        //        //if(location.SAP_Id__c == oldLocation.SAP_Id__c)
        //        {
        //            locationIdsToSend.add(locationId);
        //        }
        //    }else{
        //        Utility.idsInTriggers.put(locationId,'syncCustomerMasterWithSAP');
        //    }
        //}

        //for(Id soldToLocationId : soldToLocationIds2CreateFirst){
        //    String methodName = Utility.idsInTriggers.get(soldToLocationId);
        //    if(methodName != null && methodName == 'syncCustomerMasterWithSAP'){
        //        //if(location.SAP_Id__c == oldLocation.SAP_Id__c)
        //        {
        //            soldToLocationIdsToSend.add(soldToLocationId);
        //        }
        //    }else{
        //        Utility.idsInTriggers.put(soldToLocationId,'syncCustomerMasterWithSAP');
        //    }
        //}

        //if(!locationIdsToSend.isEmpty() && !soldToLocationIdsToSend.isEmpty())
        //    Database.executeBatch(new Location_Batch(locationIdsToSend, soldToLocationIdsToSend), 10);
    }
    
    /************************************************************************************************
     *  Created By David D 02/2016                                                                  *
     *      This function update SAP_Id fields on Location                                          *
     ************************************************************************************************/
/*
    public static void processResponse(Map<Id, SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Response> responseByLocation, Map<Id, SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request> requestByLocation)
    {
        Location_Sel lSelector = new Location_Sel(); 
        List<Location__c> locations = (List<Location__c>) lSelector.selectSObjectById(responseByLocation.keySet());

        Map<Id, Account> accounts2Update = new Map<Id, Account>();

        //-- Errors logging
        List<IEC_Error_Log__c> errorLogs = new List<IEC_Error_Log__c>();

        for(Location__c location : locations)
        {
            SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Response response = responseByLocation.get(location.Id);
            SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request request = requestByLocation.get(location.Id);

            if(location.Type__c == 'Sold To' && response.SAP_SoldTo != null)
            {
                location.SAP_Id__c = response.SAP_SoldTo.SAPSoldToID;
                accounts2Update.put(response.SAP_SoldTo.SFDCAccountID,new Account(Id=response.SAP_SoldTo.SFDCAccountID, Sales_Office__c=response.SAP_SoldTo.SalesOffice, Payment_Term__c=response.SAP_SoldTo.PaymentTerms, Price_Group__c=response.SAP_SoldTo.PriceGroup));
            } 
            else if(location.Type__c == 'Bill To' && response.SAP_BillTo != null) location.SAP_Id__c = response.SAP_BillTo.SAPBillToID; 
            else if(location.Type__c == 'Ship To' && response.SAP_ShipTo != null)  location.SAP_Id__c = response.SAP_ShipTo.SAPShipToID;
            
            if(response.Error != null) errorLogs.add(IECErrorLogger.createErrorLog('IECAddress_Svc.processResponse', JSON.serialize(request),JSON.serialize(response.Error), null));             
        }

        if(!accounts2Update.isEmpty())
        {
            try{update accounts2Update.values();}
            catch(Exception ex){errorLogs.add(IECErrorLogger.createErrorLog('IECAddress_Svc.processResponse', JSON.serialize(locations), ex.getMessage(), ex.getStackTraceString()));}     
        }


        //-- Update Locations : be sure that triggers are not recall SAP after this update  
        try{update locations;}
        catch(Exception ex){errorLogs.add(IECErrorLogger.createErrorLog('IECAddress_Svc.processResponse', JSON.serialize(locations), ex.getMessage(), ex.getStackTraceString()));}

        if(errorLogs.size() > 0) IECErrorLogger.logErrors(errorLogs, true);
    }
*/

    /**
     * Function will prepare a batch job to make api object update to Zuora with updated contacts' address
     *
     * @param setAddressId The set of IECAddress__c Ids that has been modified
     */
    public static void syncIECAddressWithZuora(Set<Id> setAddressId) {
        try {
            String query  = ' SELECT Id, Contact__c, Account__c, Address__c, Type__c, Account_Contact_ID__c' +
            '   , Contact_First_Name__c, Contact_Last_Name__c, Email__c, Phone__c ' +
            '   , Country__c, State__c, City__c, ZipCode__c, Street__c, VAT_Number__c, SAP_Id__c' +  
            '   FROM Location__c WHERE Account__c <> NULL' +
            '   AND Contact__c <> NULL ' +
            '   AND Address__c IN :setAddressId' +
            '   AND Active__c = true' +
            '   AND Type__c = \'Bill To\''; 

            List<Location__c> lstLocation = Database.query(query);

            //Call by queueable if less than 50000 locations
            if(lstLocation != null && lstLocation.size() > 0)
                Id jobID = System.enqueueJob(new ContactAddressZSync_Queueable(lstLocation, setAddressId, 'IECAddress'));
            
        }
        catch(LimitException e){
            //Call Batch if we have more than 50000 locations
            ContactAddressZSync_Batch btch = new ContactAddressZSync_Batch(setAddressId, 'IECAddress');
            Database.ExecuteBatch(btch);
        }
        catch (Exception ex) {
            IECErrorLogger.logApexException('IECAddress_Svc.syncIECAddressWithZuora', 'setAddressId: ' + setAddressId, ex.getMessage(), ex.getStackTraceString());
        }
    }
    
    /**
     * Function will query all location records that reference the specified IECAddress
     * record and make an update to SAP
     *
     * @param setAddressId The set of IECAddress__c Ids that has been modified
     */
    public static void syncIECAddressWithSAP(Set<Id> setAddressId) {
        // The map of Location that will be synced with SAP
        Map<Id, Location__c> mapLocation = new Map<Id, Location__c>(
            [SELECT Id
            FROM Location__c
            WHERE Address__c IN :setAddressId
                AND Active__c = true
                AND Type__c IN ('Sold To', 'Bill To', 'Ship To')]);
        
        // Make the SAP call to update the account/contact
        if (!mapLocation.isEmpty())
        {
            IECAddress_Svc.syncCustomerMasterWithSAP(mapLocation.keySet());
        }
    }
    
    // Determine whether there is a difference between two address records
    public static Boolean isAddressChanged(IECAddress__c oAddress1, IECAddress__c oAddress2)
    {
        if (oAddress1 == null && oAddress2 == null)
            return false;
        else if (oAddress1 == null && oAddress2 != null || oAddress1 != null && oAddress2 == null)
            return true;
        else
            return (oAddress1.Street__c != oAddress2.Street__c || oAddress1.City__c != oAddress2.City__c || oAddress1.ZipCode__c != oAddress2.ZipCode__c || oAddress1.ISO_Country__c != oAddress2.ISO_Country__c || oAddress1.ISO_State__c != oAddress2.ISO_State__c);
    }

    public static Boolean isAddressChanged(Address_DTO adr1, Address_DTO adr2)
    {
        if (adr1 == null && adr2 == null)
            return false;
        else if (adr1 == null && adr2 != null || adr1 != null && adr2 == null)
            return true;
    	
        String full1 = adr1.street1 +'|'+ adr1.street2 +'|'+ adr1.city +'|'+ adr1.stateCode +'|'+ adr1.postalCode +'|'+ adr1.countryCode;
    	full1 = full1.replace(' ','').trim().toLowerCase();
		
		String full2 = adr2.street1 +'|'+ adr2.street2 +'|'+ adr2.city +'|'+ adr2.stateCode +'|'+ adr2.postalCode +'|'+ adr2.countryCode;
    	full2 = full2.replace(' ','').trim().toLowerCase();		

        System.debug('full1::'+full1);
        System.debug('full2::'+full2);

    	return (full1 != full2);
    }

    //verified if the address change
/*	public static Location__c updateAddress(
							String street,String city, Id isoCountryId,Id isStateId,String zipCode, String VATNumber,
							Contact loginContact,String locationType
							){
		

		List<IECAddress__c> existingAddresses = new IECAddress_Sel().getAddressByIsoIds(street,city, isoCountryId, isStateId,zipCode);

        Id iecAddressId;
        //if address already exist, just change the location reference to that Address
        if(existingAddresses != null && existingAddresses.size() > 0){
            iecAddressId = existingAddresses[0].Id;
        }else{
            //If address don't existe create a new one and update the Location
            IECAddress__c newIECAddress = createNewIECAddress(street,city, isoCountryId, isStateId,zipCode);
            if(newIECAddress != null){
            	iecAddressId = newIECAddress.Id;
            }
        }

        //Get the login Contact Billing Location
        List<Location__c> lstBillToLocation;
		if(locationType == IECConstants.SHIPTO)
			lstBillToLocation = new Location_Sel().getLocations(new set<Id>{loginContact.BillTo_Location__c});

		//Create a new BillTolocation
        if(lstBillToLocation == null && iecAddressId != null){
            lstBillToLocation.add(Location_Svc.createLocation(iecAddressId,loginContact,VATNumber, locationType));
            //Update the Contact with the new BillTo Location as defautl Billto Location
            loginContact.BillTo_Location__c = lstBillToLocation[0].Id;
            update loginContact;
        }

        //Update the Location with the new Address
        if(iecAddressId != null && lstBillToLocation != null && lstBillToLocation.size() > 0){
        	lstBillToLocation[0].Address__c = iecAddressId;
        	update lstBillToLocation[0];
        }

        return lstBillToLocation[0];
	}
*/
	public static IECAddress__c createNewIECAddress(String street,String city, Id isoCountryId,Id isStateId,String zipCode){
		//Create a new IECAddress
        IECAddress__c iecAddress 	= 	new IECAddress__c();
        iecAddress.Street__c 		= 	street;
        iecAddress.City__c 			= 	city;
        iecAddress.ISO_Country__c 	= 	isoCountryId;
        iecAddress.ISO_State__c 	= 	isStateId;
        iecAddress.ZipCode__c 		= 	zipCode;

        try{
            insert iecAddress;
        }catch(Exception ex){
            //IECErrorLogger.logApexException('IECAddress_Svc.createNewIECAddress', JSON.serialize(iecAddress), ex.getMessage(), ex.getStackTraceString());
            return null;
        }
        return iecAddress;
	}

	public static IECAddress__c newAddress(String street,String city, String countryCode, String stateCode, String zipCode)
	{
		List<IATA_ISO_Country__c> isoCountries = ISO_Country_State_Helper.getIsoCountryByIsoCode(countryCode);
		Id countryId; 
		Id stateId; 

	    if(isoCountries != null && isoCountries.size() > 0){
	        countryId = isoCountries[0].Id;
	        if(String.isNotBlank(stateCode))
	        {
	        	List<IATA_ISO_State__c> isoStates = ISO_Country_State_Helper.getIsoStateByIsoCode(countryCode, stateCode);
	        	if(isoStates != null && isoStates.size() > 0)
	        	{
	        		stateId = isoStates[0].Id;
	        	}	
	        }
	    }
	    
		IECAddress__c address = new IECAddress__c(
			Street__c = street,
			City__c = city,
			ISO_Country__c = countryId,
			ISO_State__c = stateId,
			ZipCode__c = zipCode
		);

		try{
			insert address; 
			return address;
		}catch(Exception e){
			return null;			
		}
	}


	/****************************************************************************************************
	    Created by Thai 2016-12-13
	        Return a new address (not committed) compatible to call out to SAP in case of new address
	****************************************************************************************************/
	public static IECAddress__c newAddressForSAPSync(String street, String city, String countryCode, String stateCode, String zipCode)
	{
		//*** get ISO country and state information
		IATA_ISO_Country__c isoCountry = null;
		IATA_ISO_State__c isoState = null;
		if (!String.isBlank(stateCode) && !String.isBlank(countryCode))
			for (IATA_ISO_State__c state : [select Id, Name, ISO_Code__c, IEC_Valid_SAP__c, IATA_ISO_Country__r.Id, IATA_ISO_Country__r.Name, IATA_ISO_Country__r.ISO_Code__c
			                                from IATA_ISO_State__c
			                                where ISO_Code__c = :stateCode AND IATA_ISO_Country__r.ISO_Code__c = :countryCode
			                                limit 1])
				isoState = state;
		if (isoState != null && isoState.Id != null)
			isoCountry = isoState.IATA_ISO_Country__r;
		else if (!String.isBlank(countryCode))
			for (IATA_ISO_Country__c country : [select Id, Name, ISO_Code__c from IATA_ISO_Country__c where ISO_Code__c = :countryCode limit 1])
				isoCountry = country;

		//*** return address compatible for call out to SAP in case of new address
		return new IECAddress__c(Street__c = street, City__c = city, ZipCode__c = zipCode
		                       , ISO_State__c = (isoState == null ? null : isoState.Id), ISO_State__r = isoState
		                       , ISO_Country__c = (isoCountry == null ? null : isoCountry.Id), ISO_Country__r = isoCountry
		                       , Address_Type__c = (Test.isRunningTest() ? Utility.generateRandomString(8) : null));
	} //*** end of "newAddressForSAPSync"

}