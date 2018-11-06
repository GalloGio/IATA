public with sharing class ANG_AgencyAuthorizationTriggerHandler {

    public static final ID formOfPaymentRT = AMS_Utils.getId('Agency_Authorization__c','FormOfPayment');
    public static Map<Id,String> accountsName = new Map<Id,String>();
    public static void handleBeforeInsert(List<Agency_Authorization__c> newMap){
		verifyAAUniqueness(newMap);
	}

    public static void handleBeforeUpdate(List<Agency_Authorization__c> newMap, Map<Id,Agency_Authorization__c> oldMap){
		
		verifyAAUniqueness(newMap);
		removeUniqueId(newMap);
	}

	 public static void handleAfterInsert(List<Agency_Authorization__c> triggerNew){

	 	List<Agency_Authorization__c> listAuthP = new List<Agency_Authorization__c>();
	 	map<Id,Agency_Authorization__c> mapOldAuthP = new map<Id,Agency_Authorization__c>();
         
         for(Agency_Authorization__c a : triggerNew){
             if(a.recordtypeid == Schema.Agency_Authorization__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Form Of Payment').getRecordTypeId()){
                 listAuthp.add(a);
                 mapOldAuthP.put(a.id, new Agency_Authorization__c(id = a.id));
             }
         }

 		new ANG_AgencyEventsGenerator(listAuthP,mapOldAuthP,'AgencyAuthorization','Account__c').run(); 
	}

	public static void handleAfterUpdate(List<Agency_Authorization__c> triggerNew, Map<Id,Agency_Authorization__c> oldMap){

 		List<Agency_Authorization__c> listAuthP = new List<Agency_Authorization__c>();
 		
 		for(Agency_Authorization__c a : triggerNew){
 			if(a.recordtypeid == Schema.Agency_Authorization__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Form Of Payment').getRecordTypeId())
 				listAuthp.add(a);
 		}

 		new ANG_AgencyEventsGenerator(listAuthP,oldMap,'AgencyAuthorization','Account__c').run(); 
	}


	public static void removeUniqueId(List<Agency_Authorization__c> newMap){

		for(Agency_Authorization__c aa: newMap){
			if(aa.RecordTypeId == formOfPaymentRT && aa.Unique_Identifier__c <> null)
				aa.Unique_Identifier__c = null;
		}

	}

	public static void verifyAAUniqueness(List<Agency_Authorization__c> newMap){

		Set<Id> accountsInvolved = new Set<Id>();
		Map<Id,List<Agency_Authorization__c>> toVerifyAA = new Map<Id,List<Agency_Authorization__c>>();

		for(Agency_Authorization__c aa : newMap){

			if(aa.RecordTypeId == formOfPaymentRT && aa.Status__c == 'Active'){
				accountsInvolved.add(aa.Account__c);

				if(toVerifyAA.containsKey(aa.Account__c))
					toVerifyAA.get(aa.Account__c).add(aa);
				else
					toVerifyAA.put(aa.Account__c,new List<Agency_Authorization__c>{aa});
			}
		}

		List<Agency_Authorization__c> aaFromAccounts = [Select ID,Account__c, Account__r.IATACode__c,ANG_FormOfPayment_ID__c, RecordTypeId from Agency_Authorization__c where Account__c in:accountsInvolved and RecordTypeId = :formOfPaymentRT and Status__c = 'Active' and Id not in :newMap];

		Map<Id,List<Agency_Authorization__c>> accountsAAMap = new Map<Id,List<Agency_Authorization__c>>();

		For(Agency_Authorization__c aa: aaFromAccounts){

			if(accountsAAMap.containsKey(aa.Account__c)){
				accountsAAMap.get(aa.Account__c).add(aa);
			}
			else
				accountsAAMap.put(aa.Account__c, new List<Agency_Authorization__c>{aa});

			//Populate MapAccountName for show in error
			accountsName.put(aa.Account__c, aa.Account__r.IATACode__c);
		}

		For(Id accountId: accountsAAMap.keySet()){

			verifyAAPerAccountUniqueness(accountsAAMap.get(accountId),toVerifyAA.get(accountId));

		}

	}

	public static void verifyAAPerAccountUniqueness(List<Agency_Authorization__c> currentAccountList, List<Agency_Authorization__c> newAAValues){

		for(Agency_Authorization__c aa: newAAValues){

			if(hasMatchingConditions(aa,currentAccountList))
				aa.addError('There is already an Agency Authorization with the same Type/FormOfPayment for the Account ' + accountsName.get(aa.Account__c));
		}
	}

	public static boolean hasMatchingConditions(Agency_Authorization__c aa, List<Agency_Authorization__c> currentAccountList){

		for(Agency_Authorization__c aaElem: currentAccountList){

			if(aa.RecordTypeId == aaElem.RecordTypeId && aa.ANG_FormOfPayment_ID__c == aaElem.ANG_FormOfPayment_ID__c && aa.Id <> aaElem.Id){
				return true;
			}
		}

		return false;

	}

    // this function is used to
    // delete Authorized_Form_Of_Payment__c records
    // when the Agency Authorizations are deleted
    public static void removeAuthorizedFormsOfPayment(List<Agency_Authorization__c> aaValues){
        List<Id> lsAccountIds = new List<Id>();
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Agency_Authorization__c' AND RecordType.DeveloperName = 'FormOfPayment'];
        List<Agency_Authorization__c> lsFormsOfPayment = new List<Agency_Authorization__c>();
        for(Agency_Authorization__c aa: aaValues){
            if(aa.RecordTypeId == rt.Id) lsFormsOfPayment.add(aa);
        }
        for(Agency_Authorization__c aa: lsFormsOfPayment){
            lsAccountIds.add(aa.Account__c);
        }

        List<GDP_Products_Account_View__c> lsProducts =
            [SELECT Id, AMS_GDP_Key__c
            FROM GDP_Products_Account_View__c
            WHERE AMS_GDP_Key__c IN :lsAccountIds];
        List<Authorized_Forms_Of_Payment__c> lsAFP =
            [SELECT Id, Form_of_Payment_Code__c, Related_GDP_Products_Account_View__r.Related_Accreditation_Class__r.Related_Account__c
            FROM Authorized_Forms_Of_Payment__c
            WHERE Related_GDP_Products_Account_View__c IN :lsProducts];

        List<Authorized_Forms_Of_Payment__c> lsAFP2Delete = new List<Authorized_Forms_Of_Payment__c>();

        for(Agency_Authorization__c aa : lsFormsOfPayment ) {
            for(Authorized_Forms_Of_Payment__c r : lsAFP) {
                if(r.Related_GDP_Products_Account_View__r.Related_Accreditation_Class__r.Related_Account__c == aa.Account__c
                    && r.Form_of_Payment_Code__c == aa.ANG_FormOfPayment_ID__c ) {
                        lsAFP2Delete.add(r);
                        break;
                }

            }
        }
        try {
            delete lsAFP2Delete;
        } catch(Exception e) {
            System.debug(e);
        }
    }
}
