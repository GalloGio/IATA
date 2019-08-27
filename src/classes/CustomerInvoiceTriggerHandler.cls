public class CustomerInvoiceTriggerHandler {

    public static void handleBeforeInsert(List<Customer_Invoice__c> newInvoiceList) {
        Map<String, String> invoiceSISIdMap = new Map<String, String>(); //<Invoice Id, Billing Member Id (SIS Id)>
        Map<String, Customer_Invoice__c> newInvoicesMap = new Map<String, Customer_Invoice__c>(); //<Invoice Id, <Invoice>>

        for(Customer_Invoice__c inv : newInvoiceList) {
            invoiceSISIdMap.put(inv.Invoice_ID__c, inv.Billed_Member_Id__c);
            newInvoicesMap.put(inv.Invoice_ID__c, inv);
        }

        List<Account> accountList = new List<Account>([SELECT SIS_ID__c FROM Account WHERE SIS_ID__c IN : invoiceSISIdMap.values()]);

        Map<String, Id> accountSISIdMap = new Map<String, Id>(); //<SIS Id, Account Id>

        for(Account acc : accountList) {
            accountSISIdMap.put(acc.SIS_ID__c, acc.Id);
        }

        for(String invoiceId : invoiceSISIdMap.keySet()) {
            Customer_Invoice__c currentInvoice = newInvoicesMap.get(invoiceId);
            currentInvoice.AccountId__c = accountSISIdMap.get(currentInvoice.Billed_Member_Id__c);
        }
    }
}