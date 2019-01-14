public with sharing class AccountDomainContactHandler{

    /**
     * Before insert part
     */
    public static void beforeInsert(List<Contact> newTrigger) {
        AccountDomainHandler.updateValidDomainNameField(newTrigger);
    }

    /**
     * Before update part
     */
    public static void beforeUpdate(Map<Id, Contact> mapOlds, Map<Id, Contact> mapNews) {

        list<Contact> listContactsToUpdate = new List<Contact>();
        for (Contact newContact: mapNews.values() ) {
            Contact oldContact = mapOlds.get(newContact.Id);

            // changes the email value or the parent account then include it to the list to process
            if ( (oldContact.AccountId != newContact.AccountId) || (oldContact.Email != newContact.Email)) {
                listContactsToUpdate.add(newContact);
            }
        }

        // update Validation email field
        AccountDomainHandler.updateValidDomainNameField(listContactsToUpdate);
    }

}
