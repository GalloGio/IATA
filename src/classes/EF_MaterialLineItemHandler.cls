public class EF_MaterialLineItemHandler {
    //
    // Check is the material Item that is in the BillingAgreement exists in the contract.
    //
    public static void checkBillingAgreementContractItems (List<EF_Material_Line_Item__c> materialLineItemList, Map<Id,EF_Material_Line_Item__c> materialLineItemOldMap) {
        
        List<EF_Material_Line_Item__c> workdata = new List<EF_Material_Line_Item__c>();
        Set<Id> baIdSet = new Set<Id>();
                    
        //
        // Get all the new material lines and Billing agreements
        //
        for (EF_Material_Line_Item__c mli : materialLineItemList) {
            
            // TODO add a clause to check is the material has changed 
            
            if ((mli.EF_Relationship__c != null && materialLineItemOldMap == null) || 
                (materialLineItemOldMap != null && materialLineItemOldMap.containsKey(mli.Id) && mli.EF_Relationship__c != materialLineItemOldMap.get(mli.Id).EF_Relationship__c) ||
                (materialLineItemOldMap != null && materialLineItemOldMap.containsKey(mli.Id) && mli.EF_Material__c != materialLineItemOldMap.get(mli.Id).EF_Material__c) 
               ) {
                   
                workdata.add(mli);
                baIdSet.add(mli.EF_Relationship__c);
            }
        }
                        
        if (workdata.size() > 0) {
            
            Map<Id, Id> mliToContractMap = new Map<Id, Id>();
            
            //
            // Get all the contracts associated with the material lines
            //
            for (EF_Material_Line_Item__c mli : [select Id, EF_Relationship__r.Contract__c from EF_Material_Line_Item__c where Id IN: workdata]) {
                
                mliToContractMap.put(mli.Id, mli.EF_Relationship__r.Contract__c);
            }           

            //
            // Get all the material lines associated with the contracts in the billings agreements
            // 
            Map<Id,Contract> contracts = new Map<Id,Contract>([select Id, (select Id, EF_Material__c from EF_Material_Line_Items__r) from Contract where Id IN: mliToContractMap.values()]);
            Contract cont;
            Boolean found;
            
            //
            // The materials on the new lines must exist on the Material lines associated with the contracts.
            //
            for (EF_Material_Line_Item__c mli : workdata) {
                
                cont = contracts.get(mliToContractMap.get(mli.Id));
                found = false;
                
                if (cont.EF_Material_Line_Items__r != null) {
                    
                    for (EF_Material_Line_Item__c contractMLI : cont.EF_Material_Line_Items__r) {
                        
                        if (contractMLI.EF_Material__c == mli.EF_Material__c) {
                            
                            found = true;
                            break;
                        }
                    }
                }
                
                if (found == false) {
                    
                    mli.addError(Label.EF_Line_Item_Not_In_Contract_Error);
                }
            }
        }
    }
}