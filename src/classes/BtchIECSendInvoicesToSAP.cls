/**  
  * Description: This class contains batchable class for processing SAP Invoices and sending them to SAP
  * Note: Using batch to avoid two issues:
  *		1- Supporting Callout on Schedulable Jobs
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
  */
global class BtchIECSendInvoicesToSAP implements Database.Batchable<sObject>, Database.AllowsCallouts {

	public String query;

    global Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
		//*** (Thai 2016-11-02) rewrite for new behaviour
		//*** get invoice numbers to query invoice items
		Map<String, IEC_SAP_Invoice__c> mapZInvNum_SAPInv = new Map<String, IEC_SAP_Invoice__c>();
		for (sObject o : scope)
			mapZInvNum_SAPInv.put((String) o.get('Zuora_Invoice_Number__c'), (IEC_SAP_Invoice__c) o);
		
		//*** get invoice items to create orders
		Set<Id> setInvoiceItemId = new Set<Id>();
		for (Invoice_Item__c ii : [select Id, Charge_Name__c from Invoice_Item__c where Invoice__r.Name in :mapZInvNum_SAPInv.keySet()])
			if (ii.Charge_Name__c == null || !'Tax,Shipping'.containsIgnoreCase(ii.Charge_Name__c))
				setInvoiceItemId.add(ii.Id);
		
		//*** create orders
		Map<String, String> mapZInvNum_Status = new Map<String, String>();
		if (setInvoiceItemId.size() > 0)
			mapZInvNum_Status = IEC_Invoice_Item_Svc.CreateSalesOrder(setInvoiceItemId);
		
		//*** update status of SAP invoices
		List<IEC_SAP_Invoice__c> lstSAPInv = new List<IEC_SAP_Invoice__c>();
		String strStatus;
		IEC_SAP_Invoice__c SAPInv;
		List<String> ordersIDs = new List<String>();

		for (String ZInvNum : mapZInvNum_SAPInv.keySet())
		{
			strStatus = mapZInvNum_Status.get(ZInvNum);

			if(strStatus != null){
				List<String> strStatusSplit = strStatus.split(',');
				SAPInv = mapZInvNum_SAPInv.get(ZInvNum);
				if (getNextStatus(SAPInv, strStatus)){
					SAPInv.Error_Message__c = strStatus;
					SAPInv.Status_Date__c = system.now();				
					String orderIdstr;
					String orderNumberstr;
					List<String> orderNumberstrLst = new List<String>();
					system.debug('strStatus ' + strStatus);
					if(!strStatus.contains('Error') && strStatus != '' && !strStatusSplit.isEmpty() && strStatusSplit != null){					
						for(String str :strStatusSplit){
							system.debug('strStatusSplit ' + strStatusSplit);
							orderIdstr = str.substring(str.indexOf('(') + 1, str.indexOf(')'));
							orderNumberstr = str.substring(str.indexOf(' ') + 1, str.indexOf('('));
							orderNumberstrLst.add('Order- ' + orderNumberstr);
							ordersIDs.add(orderIdstr);
						}
					}
					String allstring = string.join(orderNumberstrLst,',');
					SAPInv.Related_Orders__c = allstring;
					lstSAPInv.add(SAPInv);
				}
			}
		}
		
		//Connecting Order with respective IEC SAP INVOICE -- start
		Set<Id> oIDtoUodate = new Set<Id>();
		for(String o :ordersIDs){
		    Id oID = Id.valueOf(o);
		    oIDtoUodate.add(oID);
		}

		List<Order> ordersList = new List<Order>([SELECT Id, SAP_Invoice__c FROM Order where Id IN :oIDtoUodate]);
		List<Order> orderToUpdate = new List<Order>();

		for(Order order :ordersList){
			order.SAP_Invoice__c = SAPInv.Id;
			orderToUpdate.add(order);
		}
		

		if (lstSAPInv.size() > 0)
			update lstSAPInv;
		
		if(orderToUpdate.size() > 0)
			update orderToUpdate;

		//Connecting Order with respective IEC SAP INVOICE -- end
    }

    global void finish(Database.BatchableContext BC) {
	}


	//*** (created by Thai 2016-11-02) get next status for SAP Invoice
	Boolean getNextStatus(IEC_SAP_Invoice__c SAPInv, String strCheckData)
	{
		String strStatus = SAPInv.Status__c;
		
		//*** indicate to skip update SAP invoice
		if (String.isBlank(strStatus) || (!strStatus.equalsIgnoreCase('New') && !strStatus.startsWithIgnoreCase('Retry')))
			return false;
		
		//*** set next status to SAP invoice
		if (String.isBlank(strCheckData))
			strStatus = 'Skipped';
		else if (strCheckData.containsIgnoreCase('subscription'))
		{
			//*** grant some more tries or stop processing when no invoice items or missing subscriptions
			if (strStatus.equalsIgnoreCase('New'))
				strStatus = 'Retry 1';
			else if (strStatus.startsWithIgnoreCase('Retry') && Integer.valueOf(strStatus.right(2).trim()) < 9)
				strStatus = 'Retry ' + (Integer.valueOf(strStatus.right(2).trim()) + 1);
			else
				strStatus = 'Failed';
		}
		else if (strCheckData.containsIgnoreCase('error'))
			strStatus = 'Processed with Error';
		else   //*** strCheckData contains success order Ids
			strStatus = 'Processed';
		SAPInv.Status__c = strStatus;
		return true;
	} //*** end of "getNextStatus"
}