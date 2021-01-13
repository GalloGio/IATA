/**
 * Class encapsulates query logic for Product__c
 *
 * @author: Kevin Ky <kyk@iata.org>
 * @date: 2015-12-22
 *
 **/
public without sharing class ProductEmailNotification_Sel{

	//Return List of Product Email Notification base on the product Id
	public static map<Id,List<Product_Email_Notification__c>> getProdIdByLstEmailNotif(set<Id> productIds){
		map<Id,List<Product_Email_Notification__c>> prodIdByLstEmailNotif = new map<Id,List<Product_Email_Notification__c>>();

		List<Product_Email_Notification__c> lstProdEmailNotif = [Select Id, External_email_address__c,Internal_user__c,Product__c
																	From  Product_Email_Notification__c
																	Where Product__c in :productIds ];

		if(lstProdEmailNotif != null && lstProdEmailNotif.size() > 0){
			for(Product_Email_Notification__c pen : lstProdEmailNotif){
				if(!prodIdByLstEmailNotif.containsKey(pen.Product__c)){
					prodIdByLstEmailNotif.put(pen.Product__c,new List<Product_Email_Notification__c>());
				}
				prodIdByLstEmailNotif.get(pen.Product__c).add(pen);
			}
		}
		return prodIdByLstEmailNotif;
	}

}
