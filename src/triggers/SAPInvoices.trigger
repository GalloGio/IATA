/**
 *
 * @author: Kevin Ky <kevin.ky@cgi.com>
 * @date: 2015-12-03
 *
 *
 **/
trigger SAPInvoices on SAP_Invoice__c (after delete, after insert, after update, before delete, before insert, before update) {

	SAPInvoice_Dom.triggerHandler();

}
