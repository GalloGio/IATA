/**
* @author Abdellah Bellahssan
* @date 2016
* @group CACW
* @description This trigger updates a service token of a CACWeb Subscription Detail
*/
trigger trgIECCAC_Subscription_Detail_BI_BU on CAC_Subscription_Detail__c (before insert, before update) {

  integer counter=-1;


  for(CAC_Subscription_Detail__c obj:Trigger.New){
	counter++;
	if(Trigger.isUpdate)
		if (obj.Service_Activation_Date__c==Trigger.Old[counter].Service_Activation_Date__c) continue;
	//perform service token only if the date is changed
	string stringencrypted=String.ValueOf(obj.Service_Activation_Date__c)+'|' +obj.Service_Specification__c +'|'+obj.Name;
	string link;
	String key = 'lPaCAj3GglZuKtQQcBakX9UMw27emQXppDRqzmiMmTU=';
	// Decode the key from base64 to binary
	Blob cryptoKey = Crypto.generateAesKey(256);
	cryptoKey =EncodingUtil.base64Decode(key);
	// Generate the data to be encrypted.
	Blob data = Blob.valueOf(stringencrypted);
	// Encrypt the data and have Salesforce.com generate the initialization vector
	Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, data);
	// Decode the decrypted data for subsequent use
	String sessionencrypted = EncodingUtil.base64Encode(encryptedData);
	obj.service_Token__c=sessionencrypted;
	}


}
