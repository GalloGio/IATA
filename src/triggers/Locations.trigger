trigger Locations on Location__c (after delete, after insert, after update, before delete, before insert, before update) {
    Location_dom.triggerHandler();
}