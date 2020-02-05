/****************************************************************************************************
	Created by CGI, Thai 2016-01-26
		SOAP web service to be called by SAP interface for customer
****************************************************************************************************/

global without sharing class SAP2SF_Customer
{


//*** detail for Sold To entity
global class SoldToDetail
{
	webService String SAP_SoldToID;
	webService String SFDC_AccountID;
	webService String PaymentTerm;
	webService String PriceGroup;
	webService String SalesOffice;
}


//*** detail for Bill To entity
global class BillToDetail
{
	webService String SAP_BillToID;
	webService String SFDC_ContactID;
	webService String ShippingCondition;
}


//*** detail for Ship To entity
global class ShipToDetail
{
	webService String SAP_ShipToID;
	webService String SFDC_ContactID;
	webService String ShippingCondition;
}


/****************************************************************************************************
	Created by Thai 2016-01-26
		Method to call by SAP to update customer information
		Naming convention for RequestType
		   Xyy     X:    C = Create      U = Update      D = Delete (or inactivation)
				  yy:    SP = Sold-to    BP = Bill-to    SH = Ship-to
****************************************************************************************************/
webService static void updateCustomer(String RequestType, SoldToDetail SoldTo, BillToDetail BillTo, ShipToDetail ShipTo)
{
	Location__c locationSoldTo, locationBillOrShipTo;

	try
	{
		//*** validate input
		if ('DSP,USP,UBP,USH'.indexOf(RequestType.toUpperCase()) < 0 ||
			SoldTo == null ||
			(RequestType.equalsIgnoreCase('UBP') && BillTo == null) ||
			(RequestType.equalsIgnoreCase('USH') && ShipTo == null))
		{
			logError(RequestType, SoldTo, BillTo, ShipTo, 'Missing/Incorrect information', null);
			return;
		}

		//*** get Sold To relation
		locationSoldTo = getSoldToLocation(SoldTo);
		if (locationSoldTo == null)
		{
			logError(RequestType, SoldTo, BillTo, ShipTo, 'Sold To entity not found', null);
			return;
		}

		//*** deactivate Sold To
		if (RequestType.equalsIgnoreCase('DSP'))
		{
			deactivateSoldTo(locationSoldTo);
		}
		//*** update Sold To
		else if (RequestType.equalsIgnoreCase('USP'))
		{
			updateSoldTo(locationSoldTo, SoldTo);
		}
		//*** update Bill To
		else if (RequestType.equalsIgnoreCase('UBP'))
		{
			locationBillOrShipTo = getBillToOrShipToLocation(locationSoldTo, 'Bill To', BillTo.SFDC_ContactID, BillTo.SAP_BillToID);
			if (locationBillOrShipTo != null)
				updateBillTo(locationBillOrShipTo, BillTo);
			else
				logError(RequestType, SoldTo, BillTo, ShipTo, 'Bill To entity not found', null);
		}
		//*** update Ship To
		else if (RequestType.equalsIgnoreCase('USH'))
		{
			locationBillOrShipTo = getBillToOrShipToLocation(locationSoldTo, 'Ship To', ShipTo.SFDC_ContactID, ShipTo.SAP_ShipToID);
			if (locationBillOrShipTo != null)
				updateShipTo(locationBillOrShipTo, ShipTo);
			else
				logError(RequestType, SoldTo, BillTo, ShipTo, 'Ship To entity not found', null);
		}
	}
	catch (Exception e)
	{
		logError(RequestType, SoldTo, BillTo, ShipTo, String.valueOf(e), e.getStackTraceString());
	}
} //*** end of "updateCustomer"


/****************************************************************************************************
	Created by Thai 2016-02-04
		Get Sold To relationship
****************************************************************************************************/
static Location__c getSoldToLocation(SoldToDetail SoldTo)
{
	Id idTemp;
	Location__c location = null;

	//*** get location
	idTemp = ((SoldTo.SFDC_AccountID == null || SoldTo.SFDC_AccountID == '') ? null : Id.valueOf(SoldTo.SFDC_AccountID));
	for (Location__c loc : [select Id, Account__c, SAP_Id__c
							from Location__c
							where Type__c = 'Sold To'
							  and Account__c != null and (Account__c = :idTemp or SAP_Id__c = :SoldTo.SAP_SoldToID)
							order by Id])
		if (loc.Account__c == idTemp && loc.SAP_Id__c == SoldTo.SAP_SoldToID)
		{
			//*** perfect match -> get location and stop search
			location = loc;
			break;
		}
		else
			//*** partial match -> get location and continue search
			location = loc;

	//*** update SAP Id in location record if necessary
	if (location != null && location.SAP_Id__c == null && SoldTo.SAP_SoldToID != null)
	{
		location.SAP_Id__c = SoldTo.SAP_SoldToID;
		update location;
	}

	return location;
} //*** end of "getSoldToLocation"


/****************************************************************************************************
	Created by Thai 2016-02-04
		Get Bill To or Ship To relationship
****************************************************************************************************/
static Location__c getBillToOrShipToLocation(Location__c locationSoldTo, String queryType, String idContact, String idSAP)
{
	Id idTemp;
	Location__c location = null;

	//*** get location
	idTemp = ((idContact == null || idContact == '') ? null : Id.valueOf(idContact));
	for (Location__c loc : [select Id, Account__c, Contact__c, SAP_Id__c, Shipping_Condition__c
							from Location__c
							where Type__c = :queryType
							  and (Account__c = :locationSoldTo.Account__c or Account__r.ParentId = :locationSoldTo.Account__c)
							  and Contact__c != null and (Contact__c = :idTemp or SAP_Id__c = :idSAP)
							order by Id])
		if (loc.Contact__c == idTemp && loc.SAP_Id__c == idSAP)
		{
			//*** perfect match -> get location and stop search
			location = loc;
			break;
		}
		else
			//*** partial match -> get location and continue search
			location = loc;

	//*** update SAP Id in location record if necessary
	if (location != null && location.SAP_Id__c == null && idSAP != null)
	{
		location.SAP_Id__c = idSAP;
		update location;
	}

	return location;
} //*** end of "getBillToOrShipToLocation"


/****************************************************************************************************
	Created by Thai 2016-02-04
		Deactivate Sold To relationship
		 -> deactivate also associated Bill To and Ship To relationships
****************************************************************************************************/
static void deactivateSoldTo(Location__c locationSoldTo)
{
	List<Location__c> lstLocation = new List<Location__c>();
	List<Id> lstContactId = new List<Id>();
	List<User> lstUser;

	//*** deactivate SAP relations
	for (Location__c loc : [select Id, Type__c, Contact__c
							from Location__c
							where Type__c in ('Sold To', 'Bill To', 'Ship To') and Active__c = true
							  and (Account__c = :locationSoldTo.Account__c or Account__r.ParentId = :locationSoldTo.Account__c)])
	{
		loc.Active__c = false;
		lstLocation.add(loc);
		if (loc.Contact__c != null)
			lstContactId.add(loc.Contact__c);
	}
	if (lstLocation.size() > 0)
		update lstLocation;

	//*** deactivate related portal users
	if (lstContactId.size() > 0)
	{
		lstUser = [select Id from User where IsActive = true and ContactId in :lstContactId];
		if (lstUser.size() > 0)
			User_Svc.deactivateUser(JSON.serialize(lstUser));
	}
} //*** end of "deactivateSoldTo"


/****************************************************************************************************
	Created by Thai 2016-02-04
		Update Sold To relationship
****************************************************************************************************/
static void updateSoldTo(Location__c locationSoldTo, SoldToDetail SoldTo)
{
	for (Account acc : [select Id, Payment_Term__c, Price_Group__c, Sales_Office__c
						from Account
						where Id = :locationSoldTo.Account__c
						limit 1])
		if (acc.Payment_Term__c != SoldTo.PaymentTerm || acc.Price_Group__c != SoldTo.PriceGroup || acc.Sales_Office__c != SoldTo.SalesOffice)
		{
			acc.Payment_Term__c = SoldTo.PaymentTerm;
			acc.Price_Group__c = SoldTo.PriceGroup;
			acc.Sales_Office__c = SoldTo.SalesOffice;
			update acc;
			break;
		}
} //*** end of "updateSoldTo"


/****************************************************************************************************
	Created by Thai 2016-02-04
		Update Bill To relationship
****************************************************************************************************/
static void updateBillTo(Location__c location, BillToDetail BillTo)
{
	if (location != null)
		if (location.Shipping_Condition__c != BillTo.ShippingCondition)
		{
			location.Shipping_Condition__c = BillTo.ShippingCondition;
			update location;
		}
} //*** end of "updateBillTo"


/****************************************************************************************************
	Created by Thai 2016-02-04
		Update Ship To relationship
****************************************************************************************************/
static void updateShipTo(Location__c location, ShipToDetail ShipTo)
{
	if (location != null)
		if (location.Shipping_Condition__c != ShipTo.ShippingCondition)
		{
			location.Shipping_Condition__c = ShipTo.ShippingCondition;
			update location;
		}
} //*** end of "updateShipTo"


/****************************************************************************************************
	Created by Thai 2016-02-23
		Log an error for follow up
****************************************************************************************************/
static void logError(String RequestType, SoldToDetail SoldTo, BillToDetail BillTo, ShipToDetail ShipTo, String strError, String strStack)
{
	if (strStack == null)
		IECErrorLogger.logApexError('SAP2SF_Customer.updateCustomer'
								  , 'RequestType: ' + RequestType + '\nSoldTo: ' + String.valueOf(SoldTo) + '\nBillTo: ' + String.valueOf(BillTo) + '\nShipTo: ' + String.valueOf(ShipTo)
								  , strError, true);
	else
		IECErrorLogger.logApexException('SAP2SF_Customer.updateCustomer'
									  , 'RequestType: ' + RequestType + '\nSoldTo: ' + String.valueOf(SoldTo) + '\nBillTo: ' + String.valueOf(BillTo) + '\nShipTo: ' + String.valueOf(ShipTo)
									  , strError, strStack, true);
} //*** end of "logError"


} //*** end of class
