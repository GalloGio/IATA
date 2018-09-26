trigger trgIDCard_Contact_BeforeUpdate on Contact (before update, before insert) {

    boolean CardToSync = false;

    // Get RecordTypeID
    ID contactTypeID = clsContactTypeIDSingleton.getInstance().RecordTypes.get('Standard');

    if (trigger.isInsert) {
        // force to sync ver num and ver num 2
        for (Contact c : trigger.new)
            if (c.Ver_Number__c != null) {
                c.Ver_Number_2__c = String.valueOf(c.Ver_Number__c);
            } else if (c.Ver_Number_2__c != '' && c.Ver_Number_2__c != null && !c.Ver_Number_2__c.startswith('Z')) {
                c.Ver_Number__c = Decimal.valueOf(c.Ver_Number_2__c);
            }
    }

    if (trigger.isUpdate && IDCardUtil.isFirstTime) {

        List<Contact> standardContacts = new List<Contact>();

        // force to sync ver num and ver num 2
        for (Contact c : trigger.new) {
            if ( c.Ver_Number__c !=  trigger.oldMap.get(c.Id).Ver_Number__c ) {
                c.Ver_Number_2__c = c.Ver_Number__c == null ? null : String.valueOf(c.Ver_Number__c);
            }
            if (c.Ver_Number_2__c == '' || c.Ver_Number_2__c == null) {
                c.Ver_Number__c = null;
            } else if (c.Ver_Number_2__c != trigger.oldMap.get(c.Id).Ver_Number_2__c && !c.Ver_Number_2__c.startswith('Z')) {
                c.Ver_Number__c = Decimal.valueOf(c.Ver_Number_2__c);
            }

            if(c.RecordTypeId == contactTypeID) standardContacts.add(c);
        }

        if(standardContacts.isEmpty()) return;

        //RA 7/8/2013
        //Shows a warning when the contact last name is update if an active IDCard is linked to the contact
        Profile currentUserProfile = [SELECT ID, Name FROM Profile WHERE id = : UserInfo.getProfileId() limit 1];

        Set<ID> ids = Trigger.newMap.keySet();

        ID rectypeid = Schema.SObjectType.ID_Card__c.getRecordTypeInfosByName().get('AIMS').getRecordTypeId();
        List <ID_Card__c> IDCards = [Select i.Valid_To_Date__c , i.Related_Contact__r.Id From ID_Card__c i where i.Valid_To_Date__c > Today and i.Cancellation_Date__c = null  and i.Card_Status__c = 'Valid ID Card' and i.Related_Contact__c in : ids and  RecordTypeId = : rectypeid ];


        for (Contact CurrentContact : standardContacts) {
        	
        	IDCardUtil.isFirstTime = false;
        	
            //CurrentContact.addError(IDCards.size()+'   Related_Contact__r.Id  ' +IDCards[0].Related_Contact__r.Id+ '  CurrentContact.Id ' +CurrentContact.Id );
            Boolean isAdmin = false;
            if (currentUserProfile.Name.toLowerCase().contains('system administrator'))
                isAdmin = true;

            Contact OldContact = Trigger.oldMap.get(CurrentContact.ID);
            if (!isAdmin || test.isRunningTest()) {

                //checks if theres any active IDCard for this contact.

                //ID_Card__c[] IDCard = [Select i.Valid_To_Date__c , i.Related_Contact__r.Id From ID_Card__c i where i.Valid_To_Date__c > Today and i.Cancellation_Date__c= null  and i.Card_Status__c = 'Printed/Delivered' and i.Related_Contact__c =: CurrentContact.ID ];
                //top statement replaced by following to bulkify 
                Boolean isThereAnyActiveCard = false;
                for (ID_Card__c  card : IDCards) {
                    if (card.Related_Contact__r.Id == CurrentContact.id)
                        isThereAnyActiveCard = true;
                }

                //if last name has been changed
                if ( (OldContact.LastName != CurrentContact.LastName || OldContact.FirstName != CurrentContact.FirstName ) && isThereAnyActiveCard) { //IDCard.size()>0) //
                    if (CurrentContact.Allow_Contact_LastName_Change__c == false )
                        CurrentContact.addError('Theres an active IDCard for the following Contact. Changing the Name will not be reflected on the current IDCard, To continue with this modification please check "Allow Contact LastName change box" in order to be able to do the changes');

                    if (CurrentContact.Allow_Contact_LastName_Change__c)
                        CurrentContact.Allow_Contact_LastName_Change__c = false;
                }
            }
        }
    }
}