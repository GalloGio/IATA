trigger GlobalContactTrigger on Contact (after delete, after insert, after undelete, after update, before delete, before insert, before update) {   

    ID standardContactRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');

    boolean Contacts = true;
    boolean AMP_ContactTrigger = true;
    boolean trgIFAPContact_BeforeInsertUpdate = true;
    boolean trgIDCard_Contact_BeforeUpdate = true;
    boolean trgGDPContact_BeforeDelete = true;
    boolean ISSP_CreateNotificationForContact = true;
    boolean ISSP_UpdateContacKaviIdOnUser = true;
    boolean ISSP_ContactUpdaetPortalUser = true;
    boolean ISSP_ContactStatusTrigger = true;
    boolean ISSP_ContactAfterInsert = true;
    boolean trgIECContact = true;
    boolean sendPushNotificationsToAdmin = true;

    /*Values of flags can be found inside the custom setting Global Case Trigger, created for case project and reused for contacts GM*/
    if(!Test.isRunningTest()){
        Contacts = GlobalCaseTrigger__c.getValues('CON Contacts').ON_OFF__c;
        AMP_ContactTrigger = GlobalCaseTrigger__c.getValues('CON AMP_ContactTrigger').ON_OFF__c;
        trgIFAPContact_BeforeInsertUpdate = GlobalCaseTrigger__c.getValues('CON trgIFAPContact_BeforeInsertUpdate').ON_OFF__c;
        trgIDCard_Contact_BeforeUpdate = GlobalCaseTrigger__c.getValues('CON trgIDCard_Contact_BeforeUpdate').ON_OFF__c;
        trgGDPContact_BeforeDelete = GlobalCaseTrigger__c.getValues('CON trgGDPContact_BeforeDelete').ON_OFF__c;
        ISSP_CreateNotificationForContact = GlobalCaseTrigger__c.getValues('CON ISSP_CreateNotificationForContact').ON_OFF__c;
        ISSP_UpdateContacKaviIdOnUser = GlobalCaseTrigger__c.getValues('CON ISSP_UpdateContacKaviIdOnUser').ON_OFF__c;
        ISSP_ContactUpdaetPortalUser = GlobalCaseTrigger__c.getValues('CON ISSP_ContactUpdaetPortalUser').ON_OFF__c;
        ISSP_ContactStatusTrigger = GlobalCaseTrigger__c.getValues('CON ISSP_ContactStatusTrigger').ON_OFF__c;
        ISSP_ContactAfterInsert = GlobalCaseTrigger__c.getValues('CON ISSP_ContactAfterInsert').ON_OFF__c;
        trgIECContact = GlobalCaseTrigger__c.getValues('CON trgIECContact').ON_OFF__c;
        sendPushNotificationsToAdmin = NewGenApp_Custom_Settings__c.getOrgDefaults().Push_Notifications_State__c;
    }
    
    /*BEFORE*/
    if(Trigger.isBefore){
        /*Share trigger code*/
        if(Trigger.isInsert || Trigger.isUpdate){

            /*AMP_ContactTrigger BeforeTrigger*/
            if(AMP_ContactTrigger){
                system.debug('AMP_ContactTrigger BeforeTrigger');
                for (Contact so : Trigger.new) {
                    //friends remind friends to bulkify
                    if(so.Function__c != null ) {
                        if(so.Membership_Function__c == null) {
                            so.addError('Contact can only be Primary for values included in Job Functions');
                        } else {
                            List<String> functions = so.Function__c.split(';');
                            for(String s: functions) {
                                if(!so.Membership_Function__c.contains(s)) {
                                    so.addError('Contact can only be Primary for values included in Job Functions');
                                }
                            }
                        }
                    }
                }
            }
            /*AMP_ContactTrigger BeforeTrigger*/

            /*trgIFAPContact_BeforeInsertUpdate BeforeTrigger*/
            if(trgIFAPContact_BeforeInsertUpdate){
                system.debug('trgIFAPContact_BeforeInsertUpdate BeforeTrigger');
                String ERRORMSG = 'Only one Contact per Account can be defined as Financial Assessment Contact';
                List<Contact> lCons = new List<Contact>();
                List<Account> Cont2Account = new List<Account>();
                Set<Id> AcctId = new Set<Id>();
                if (test.isrunningTest()) {
                    ISSP_CS__c myCS1 = ISSP_CS__c.getValues('SysAdminProfileId');
                    if(myCS1 == null) 
                        insert new ISSP_CS__c(name = 'SysAdminProfileId' , value__c = '00e20000000h0gFAAQ');
                }
                for (Contact theContact : trigger.new) {
                    if (theContact.Financial_Assessment_Contact__c) 
                        lCons.add(theContact);
                        AcctId.add(theContact.AccountId);
                }
                //************************
                if(!lCons.isEmpty()){
                    Cont2Account = [SELECT Location_type__c, Type FROM Account WHERE Id in :AcctId];
                }
                //************************

                //When contact is created from Portal self-registration this trigger have to be bypassed
                if (userinfo.getLastName() != 'Site Guest User') {
                    system.debug('not guest user');
                    // Get the list of Profiles that we allow to create an FA contact for BR
                    String sysAdminProfileId = String.ValueOF(ISSP_CS__c.getValues('SysAdminProfileId').value__c);
                    //list<Profile> profs = new List<Profile>();
                    //if (sysAdminProfileId != null && sysAdminProfileId != '')
                    //    profs = [SELECT Name, Id FROM Profile where id = :sysAdminProfileId limit 1];
                    //profile prof;
                    //system.debug('profs: ' + profs);
                    if (sysAdminProfileId != null && sysAdminProfileId != '') {
                        //prof = profs[0];
                        // For all contacts (Created or updated)
                        for (Contact theContact : lCons) {
                            system.debug('one contact: ' + theContact);
                            try {
                                system.debug('is IFAP: ' + theContact.Financial_Assessment_Contact__c);
                                if (theContact.Financial_Assessment_Contact__c) {
                                    // check if a financial assessment contact already exists for the same account
                                    if (IFAP_BusinessRules.CheckFinancialAssessmentContactExist(theContact)) {
                                        theContact.addError(ERRORMSG);
                                    }
                                    //QUERY IN LOOP
                                    //Account theAccount = [Select a.Name, a.Location_Type__c, a.Type From Account a where a.Id = :theContact.AccountId];
                                    // check the Agent Type of the Account
                                    for (Account Acct : Cont2Account){
                                        if(theContact.AccountId == Acct.id){
                                            if (Acct.Type != 'IATA Passenger Sales Agent' && Acct.Type != 'IATA Cargo Agent' && Acct.Type != 'CASS Associate' && Acct.Type != 'Import Agent' && !ANG_OscarProcessHelper.isIATACodeGenerationRunning) {
                                                theContact.addError('Cannot associate an IFAP Contact to an Account of type ' + Acct.Type);
                                            }
                                        }
                                    }
                                }
                            }catch (Exception e) {
                                theContact.adderror('An unhandled error has occured. Error Message: ' + e.getMessage());
                            }
                        }
                    }
                }
            }
            /*trgIFAPContact_BeforeInsertUpdate BeforeTrigger*/

        }
        /*Share trigger code*/
            
        /****************************************************************************************************************************************************/
        /*Trigger.BeforeInsert*/
        if (Trigger.isInsert) {
            /*trgIDCard_Contact_BeforeUpdate Trigger.BeforeInsert*/          
            if(trgIDCard_Contact_BeforeUpdate){
                system.debug('trgIDCard_Contact_BeforeUpdate BeforeInsert');
                for (Contact c : trigger.new){
                    if (c.Ver_Number__c != null) {
                        c.Ver_Number_2__c = String.valueOf(c.Ver_Number__c);
                    }else if (c.Ver_Number_2__c != '' && c.Ver_Number_2__c != null && !c.Ver_Number_2__c.startswith('Z')) {
                        c.Ver_Number__c = Decimal.valueOf(c.Ver_Number_2__c);
                    }
                    // update available services field if IdCard Holder is active
                    if (c.ID_Card_Holder__c) {
                        c.Available_Services__c = IdCardUtil.IDCARD_SERVICE_NAME;
                        c.Available_Services_Images__c = IdCardUtil.getCardHolderImageHtml();
                    }
                }
            }
            /*trgIDCard_Contact_BeforeUpdate Trigger.BeforeInsert*/  

            /*Contacts Trigger.BeforeInsert*/
            if (Contacts) {
                system.debug('Contacts BeforeInsert');
                AccountDomainContactHandler.beforeInsert(Trigger.new);
            }
            /*Contacts Trigger.BeforeInsert*/

        }
        /*Trigger.BeforeInsert*/

        /****************************************************************************************************************************************************/    
        /*Trigger.BeforeUpdate*/
        else if (Trigger.isUpdate) {
            /*ISSP_CreateNotificationForContact Trigger.BeforeUpdate*/  
            if(ISSP_CreateNotificationForContact){
                system.debug('ISSP_CreateNotificationForContact BeforeUpdate');
                ISSP_CreateNotification.CreateNotificationForSobjectList(trigger.new);
            }
            /*ISSP_CreateNotificationForContact Trigger.BeforeUpdate*/  

            /*trgIDCard_Contact_BeforeUpdate Trigger.BeforeUpdate*/  
            if (trgIDCard_Contact_BeforeUpdate && IDCardUtil.isFirstTime) {
                system.debug('trgIDCard_Contact_BeforeUpdate BeforeUpdate');
                List<Contact> standardContacts = new List<Contact>();
                for (Contact c : trigger.new) {
                    if ( c.Ver_Number__c !=  trigger.oldMap.get(c.Id).Ver_Number__c ) {
                        c.Ver_Number_2__c = c.Ver_Number__c == null ? null : String.valueOf(c.Ver_Number__c);
                    }if (c.Ver_Number_2__c == '' || c.Ver_Number_2__c == null) {
                        c.Ver_Number__c = null;
                    }else if (c.Ver_Number_2__c != trigger.oldMap.get(c.Id).Ver_Number_2__c && !c.Ver_Number_2__c.startswith('Z')) {
                        c.Ver_Number__c = Decimal.valueOf(c.Ver_Number_2__c);
                    }
                    if(c.RecordTypeId == standardContactRecordTypeID) 
                        standardContacts.add(c);
                    // check id card service image if id card holder is active
                    if (c.Available_Services__c==null) c.Available_Services__c = '';
                    if (c.ID_Card_Holder__c && !c.Available_Services__c.contains(IdCardUtil.IDCARD_SERVICE_NAME)) {
                        list<String> listServices = c.Available_Services__c.split(';');
                        listServices.add(IdCardUtil.IDCARD_SERVICE_NAME);
                        c.Available_Services__c = String.join(listServices,';');
                        if (c.Available_Services_Images__c==null) c.Available_Services_Images__c='';
                        c.Available_Services_Images__c += IdCardUtil.getCardHolderImageHtml();
                    }
                    // if ID card service is in the list but id card holder is false we need to remove it (both service value and image)
                    else if (!c.ID_Card_Holder__c && c.Available_Services__c.contains(IdCardUtil.IDCARD_SERVICE_NAME)) {
                        // remove from multipicklist
                        list<String> listServices = new list<String>();
                        for (String service: c.Available_Services__c.split(';')) {
                            if (service!=IdCardUtil.IDCARD_SERVICE_NAME) {
                                listServices.add(service);
                            }
                        }
                        c.Available_Services__c = String.join(listServices,';');
                        // remove from images
                        list<String> listImages = new list<String>();
                        for (String image: c.Available_Services_Images__c.split('<img')) {
                            if (image!='' && !image.contains(IdCardUtil.IDCARD_SERVICE_NAME)) {
                                listImages.add('<img' + image);
                            }
                        }
                        c.Available_Services_Images__c = String.join(listImages,'');
                    }
                }
                if(!standardContacts.isEmpty()){
                    //RA 7/8/2013
                    //Shows a warning when the contact last name is update if an active IDCard is linked to the contact
                    Profile currentUserProfile = [SELECT ID, Name FROM Profile WHERE id = : UserInfo.getProfileId() limit 1];
                    Set<ID> ids = Trigger.newMap.keySet();
                    ID rectypeid = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'AIMS');

                    List <ID_Card__c> IDCards = [Select i.Valid_To_Date__c , i.Related_Contact__r.Id 
                                                From ID_Card__c i 
                                                where i.Valid_To_Date__c > Today 
                                                    and i.Cancellation_Date__c = null 
                                                    and i.Card_Status__c = 'Valid ID Card' 
                                                    and i.Related_Contact__c in : ids 
                                                    and RecordTypeId = : rectypeid ];

                    for (Contact CurrentContact : standardContacts) {            
                        IDCardUtil.isFirstTime = false;
                        Boolean isAdmin = false;
                        if (currentUserProfile.Name.toLowerCase().contains('system administrator'))
                            isAdmin = true;
                        Contact OldContact = Trigger.oldMap.get(CurrentContact.ID);
                        if (!isAdmin || test.isRunningTest()) {
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
            /*trgIDCard_Contact_BeforeUpdate Trigger.BeforeUpdate*/

            /*Contacts Trigger.BeforeUpdate*/
            if (Contacts) {
                system.debug('Contacts BeforeUpdate');
                AccountDomainContactHandler.beforeUpdate(Trigger.oldMap, Trigger.newMap);

                /* NEWGEN ANG_ContactHandler */
                ANG_ContactHandler angHandler = new ANG_ContactHandler();
                angHandler.handleBeforeUpdate();
                /* NEWGEN ANG_ContactHandler */
                
            }
            /*Contacts Trigger.BeforeUpdate*/

        }
        /*Trigger.BeforeUpdate*/

        /****************************************************************************************************************************************************/    
        /*Trigger.BeforeDelete*/
        else if (Trigger.isDelete) {
            /*trgGDPContact_BeforeDelete Trigger.BeforeDelete*/
            if(trgGDPContact_BeforeDelete){
                system.debug('trgGDPContact_BeforeDelete BeforeDelete');
                // Get the list of Profiles that have deletion rights on contacts when the record type is equal to GDP Contact
                List<Profile> profiles = [SELECT Name, Id 
                                          FROM Profile 
                                          WHERE  Name = 'GDP - Administrator' 
                                            OR Name = 'System Administrator' 
                                          ORDER BY Name DESC];
                
                //Create list of contacts and their ID Cards
                List<Contact> listcontacts = [SELECT Id, VER_Number__c, RecordTypeId, (SELECT Id, Related_Contact__c from ID_Cards__r) 
                                              FROM Contact 
                                              WHERE Id in : Trigger.oldMap.keySet()];

                // add error message for each deletion of ID Card Contact
                for (Contact c : listcontacts){
                    if( UserInfo.getProfileId() != profiles[0].Id && ((c.ID_Cards__r.size()>0) || (c.VER_Number__c != null && c.RecordTypeId == standardContactRecordTypeID))){ 
                        Contact actualRecord = Trigger.oldMap.get(c.Id); 
                        actualRecord.adderror('You cannot delete or merge this contact. This contact has an IATA/IATAN Travel Agent ID Card.');
                    } 
                }    
            }
            /*trgGDPContact_BeforeDelete Trigger.BeforeDelete*/
        }
        /*Trigger.BeforeDelete*/
    }
    /*BEFORE*/

    /********************************************************************************************************************************************************/
    
    /*AFTER*/
    if(Trigger.isAfter){
        /*Share trigger code*/
        
        /*Contacts Trigger*/
        if (Contacts) {
            system.debug('Contacts After');
            EF_ContactHandler.handleAfterUpdate();
        }
        /*Contacts Trigger*/
        
        
        if(Trigger.isInsert || Trigger.isUpdate){
            /*ISSP_ContactAfterInsert Trigger.After*/
            if(ISSP_ContactAfterInsert){
                system.debug('ISSP_ContactAfterInsert After');  
                list<Contact> contactsFromMigrationList = new list<Contact>();
                list<Contact> contactsWithStatusEqualToInactivList = new list<Contact>();
                list<Contact> contactsToDisable_TD = new list<Contact>();
                set<string> contactsForUserUpdateIdSet = new set<string>();
                set<string> contactsForUserdeActivateIdSet = new set<string>();
                Map<Id,Id> oldAccountByContactIdMap = new Map<Id,Id>();
                Map<Id,Id> newAccountByContactIdMap = new Map<Id,Id>();
                Set<Id> contactsToProcess = new Set<Id>();
                Map<Id, Id> contactsToProcessMap = new Map<Id, Id>();
                
                for(Contact con:trigger.new){
                    contactsToProcess.add(con.Id);
                }
                if (!contactsToProcess.isEmpty()){
                    List <User> userList = [SELECT Id, Profile.Name, ContactId,ContactKaviId__c,Is_Kavi_Internal_User__c 
                                            FROM User 
                                            WHERE ContactId = :contactsToProcess OR ContactKaviId__c =:contactsToProcess];
                    if (!userList.isEmpty()){
                        for (User thisUser : userList){
                            if (thisUser.Profile.Name.startsWith('ISS')){
                                if (!contactsToProcessMap.containsKey(thisUser.ContactId)){
                                    contactsToProcessMap.put(thisUser.ContactId, thisUser.ContactId);
                                }
                            }
                            if (thisUser.Is_Kavi_Internal_User__c){
                                if (!contactsToProcessMap.containsKey(thisUser.ContactKaviId__c)){
                                   contactsToProcessMap.put(thisUser.ContactKaviId__c, thisUser.ContactKaviId__c);
                                }
                            }
                        }
                    }
                }
                    
                for(Contact con:trigger.new){   
                    if (contactsToProcessMap.containsKey(con.Id)){
                        system.debug('PROCESSING THIS CONTACT FOR PORTAL');
                        Contact oldCon;  
                        if(trigger.isUpdate){
                            oldCon = trigger.oldMap.get(con.Id);
                            system.debug('con.LastName '+con.LastName);
                            system.debug('oldCon.LastName '+oldCon.LastName);
                            if(con.FirstName != oldCon.FirstName || con.LastName != oldCon.LastName || con.Email != oldCon.Email ||
                                    con.Title != oldCon.Title || con.Preferred_Language__c != oldCon.Preferred_Language__c ){
                                contactsForUserUpdateIdSet.add(con.Id);
                            }
                            if (con.AccountId != oldCon.AccountId){
                                contactsToDisable_TD.add(con);
                            }
                        }
                        if((con.User_Portal_Status__c == 'Deactivate' || con.User_Portal_Status__c == 'Deactivated') 
                            && con.User_Portal_Status__c!= oldCon.User_Portal_Status__c 
                            || ((con.Status__c == 'Inactive' || con.Status__c == 'Retired' || con.Status__c == 'Left Company / Relocated' ) 
                            && (trigger.isinsert || con.Status__c!= oldCon.Status__c))){

                            contactsWithStatusEqualToInactivList.add(con);
                        }
                        
                        if(( (con.Status__c == 'Inactive') || 
                             (con.Kavi_User__c != null & (con.Status__c == 'Retired' || con.Status__c == 'Left Company / Relocated') ) )
                            && (trigger.isinsert || con.Status__c!= oldCon.Status__c )){

                            contactsForUserdeActivateIdSet.add(con.Id);

                            if (con.Kavi_User__c != null){
                                contactsWithStatusEqualToInactivList.add(con);
                            }
                        }
                    }
                }
             
                system.debug('\n\n KIKEcontactsForUserUpdateIdSet '+ contactsForUserUpdateIdSet+'\n\n');
                if(contactsForUserUpdateIdSet.size()>0)
                    ISSP_PortalUserStatusChange.futureUpdateUsers(contactsForUserUpdateIdSet);
                
                // Update Portal Application Rights - to Access Denide If contact Status is inactiv
                system.debug('\n\n contactsWithStatusEqualToInactivList '+contactsWithStatusEqualToInactivList+'\n\n');

                if(contactsWithStatusEqualToInactivList.size()>0){
                    list<Portal_Application_Right__c> parList = [SELECT Id,Right__c 
                                                                FROM Portal_Application_Right__c 
                                                                WHERE Contact__c in:contactsWithStatusEqualToInactivList];
                    for(Portal_Application_Right__c par :parList){
                        par.Right__c = 'Access Denied';
                    }
                    if(!parList.isEmpty())
                        update parList;
                }
                
                // Unactivate Users
                if(contactsForUserdeActivateIdSet.size()>0){
                    ISSP_PortalUserStatusChange.futureDeactivateUsers(contactsForUserdeActivateIdSet);
                }
                
                if (contactsToDisable_TD.size() > 0){

                    list<Portal_Application_Right__c> portalAppList = [SELECT Id, Right__c, Contact__c, Portal_Application__r.Name
                                                                      FROM Portal_Application_Right__c 
                                                                      WHERE Contact__c in:contactsToDisable_TD
                                                                        AND Right__c = 'Access Granted']; 

                    list<Portal_Application_Right__c> tdList = new list<Portal_Application_Right__c>();
                    for(Portal_Application_Right__c par : portalAppList){

                        if(par.Portal_Application__r.Name.startsWith('Treasury Dashboard')){
                             par.Right__c = 'Access Denied';
                             tdList.add(par);
                        }
                        else if(par.Portal_Application__r.Name.startsWith('Standards Setting Workspace')){
                            oldAccountByContactIdMap.put(par.Contact__c,trigger.oldMap.get(par.Contact__c).AccountId);
                            newAccountByContactIdMap.put(par.Contact__c,trigger.newMap.get(par.Contact__c).AccountId);
                        } 
                    }
                    if(!tdList.isEmpty())
                        update tdList;
                    
                }

                if(ISSP_WS_KAVI.preventTrigger!=null) {
                    if(!ISSP_WS_KAVI.preventTrigger && oldAccountByContactIdMap.size()>0){
                        ISSP_WS_KAVI.preventTrigger = true;
                        ISSP_WS_KAVI.replaceKaviRelationShip(newAccountByContactIdMap,oldAccountByContactIdMap);
                    }
                }
            }
            /*ISSP_ContactAfterInsert Trigger.After*/   
        }
        /*Share trigger code*/
     
        /****************************************************************************************************************************************************/
        /*Trigger.AfterInsert*/
        if (Trigger.isInsert) {
            /*ISSP_CreateNotificationForContact Trigger.AfterInsert*/
            if(ISSP_CreateNotificationForContact){
                system.debug('ISSP_CreateNotificationForContact AfterInsert');
                for (Contact con : Trigger.new) {
                   //only send the notification if the Portal Status is Pending / Contact created by Portal
                   if (con.User_Portal_Status__c == ISSP_Constant.NEW_CONTACT_STATUS)
                        ISSP_CreateNotification.SendEmailToPortalAdminNewContact(trigger.new);   
                }
            } 
            /*ISSP_CreateNotificationForContact Trigger.AfterInsert*/

            // NewGen Mobile APP Start
            if(sendPushNotificationsToAdmin){
                for (Contact con : Trigger.new) {
                    if(con.User_Portal_Status__c == ISSP_Constant.NEW_CONTACT_STATUS || (con.Community__c != null && con.Community__c.startswith('ISS'))){
                        NewGen_Account_Statement_Helper.sendPushNotificationToAdmins(trigger.new);
                    }
                }
            }
            // NewGen Mobile APP End

            /*Contacts Trigger.AfterInsert*/
            if(Contacts) {
                system.debug('Contacts AfterInsert');
                ContactHandler.afterInsert(Trigger.new);
            }
            if (Utility.getNumericSetting('Stop Trigger:Contact') != 1)
                Contact_Dom.triggerHandler();
            /*Contacts Trigger.AfterInsert*/
            
            /*ISSP_UpdateContacKaviIdOnUser Trigger.AfterInsert*/
            if(ISSP_UpdateContacKaviIdOnUser){
                system.debug('ISSP_UpdateContacKaviIdOnUser AfterInsert');
                for (Contact oneContact: Trigger.new){
                    //if Kaviuser Field has been modified launch the process of updating ContactKaviId field on User related record.
                    ISSP_ContactTriggerHandler.updateKaviIdOnUser(trigger.new);
                }
            }
            /*ISSP_UpdateContacKaviIdOnUser Trigger.AfterInsert*/
        }
        /*Trigger.AfterInsert*/

        /****************************************************************************************************************************************************/    
        /*Trigger.AfterUpdate*/
        else if (Trigger.isUpdate) {
            /*ISSP_ContactUpdaetPortalUser Trigger.AfterUpdate*/
            if(ISSP_ContactUpdaetPortalUser){ 
                system.debug('ISSP_ContactUpdaetPortalUser AfterUpdate');
                Map<Id, String> conEmailMap = new Map<Id, String>();//TF - SP9-A5
                Set<Id> conEmailIdSet = new Set<Id>();//TF - SP9-A5
                Map<Id, String> conFirstNameMap = new Map<Id, String>();//TF - SP9-A5
                Map<Id, String> conLastNameMap = new Map<Id, String>();//TF - SP9-A5

                //WMO-234 for user with SIS application changing its account
                set<Id> setSISContactChangingAccount = new set<Id>();

                for(Contact con : trigger.new){

                    if ((con.Email != '' && (con.Email != trigger.oldMap.get(con.Id).Email 
                            || con.FirstName != trigger.oldMap.get(con.Id).FirstName 
                            || con.LastName != trigger.oldMap.get(con.Id).LastName))){
                        
                        if (!conEmailMap.containsKey(con.Id)){
                            conEmailMap.put(con.Id, con.Email);
                            conEmailIdSet.add(con.Id);
                            conFirstNameMap.put(con.Id, con.FirstName);
                            conLastNameMap.put(con.Id, con.LastName);
                        }
                    }
                    //WMO-234
                    if (con.S_SIS__c>0 && con.AccountId != trigger.oldMap.get(con.Id).AccountId) {
                        setSISContactChangingAccount.add(con.Id);
                    }

                }
                
                //TF - SP9-A5
                if (!conEmailMap.isEmpty()){
                    system.debug('Going to ISSP_UserTriggerHandler.changeEmailFromContact');
             
                    if(!ISSP_UserTriggerHandler.preventTrigger)
                        ISSP_UserTriggerHandler.changeEmailFromContact (conEmailMap, conFirstNameMap, conLastNameMap, conEmailIdSet);
                }
                
                //WMO-234
                if (!setSISContactChangingAccount.isEmpty()) {
                    ISSP_UserTriggerHandler.alertSISContactsChangingAccount(setSISContactChangingAccount);
                }
            }
            /*ISSP_ContactUpdaetPortalUser Trigger.AfterUpdate*/

            /*ISSP_ContactStatusTrigger Trigger.AfterUpdate*/
            if(ISSP_ContactStatusTrigger && !ISSP_ContactList.avoidContactStatusTrigger){
                system.debug('ISSP_ContactStatusTrigger AfterUpdate');
                Set<Id> contactIds = new Set<Id>();
                Map<String, List<Contact>> inactivationReasonMap = new Map<String, List<Contact>>();

                for(Contact newCon : trigger.new){
                    Contact oldCon = trigger.oldMap.get(newCon.Id);

                    if (newCon.Status__c != oldCon.Status__c){
                        if (newCon.Status__c != 'Active'){

                            contactIds.add(newCon.Id);
                            system.debug('Inactivating contact');
                            if (!inactivationReasonMap.containsKey(newCon.Status__c)){
                                inactivationReasonMap.put(newCon.Status__c, new List<Contact>{newCon});
                            }else{
                                inactivationReasonMap.get(newCon.Status__c).add(newCon);
                            }
                        }
                    }
                }
                
                if (!contactIds.isEmpty()){
                    List <Contact> contactList = [SELECT Id,
                                                    (SELECT Id, Valid_To_Date__c FROM ID_Cards__r WHERE NOT card_status__c like 'Cancelled%'),
                                                    (SELECT Id FROM IEC_Subscriptions_History__r)
                                                 FROM Contact 
                                                 WHERE Id IN :contactIds];

                    for (Contact thisContact : contactList){

                        if (!thisContact.ID_Cards__r.isEmpty()){
                            for(Contact newCon : trigger.new){
                                if (newCon.Id == thisContact.Id){
                                    newCon.addError('This contact is an ID Card holder. Please cancel the ID Card before inactivating the user.');
                                }
                            }
                        }else if (!thisContact.IEC_Subscriptions_History__r.isEmpty()){
                            for(Contact newCon : trigger.new){
                                if (newCon.Id == thisContact.Id){
                                    newCon.addError('This contact has an active product subscription. It\'s not possible to inactivate contacts with active subscriptions.');
                                }
                            }
                        }
                    }
                    for (String thisReason : inactivationReasonMap.keySet()){
                        system.debug('thisReason: ' + thisReason);

                        List<Contact> cls = inactivationReasonMap.get(thisReason);
                        if (thisReason == 'Left Company / Relocated'){
                            thisReason = 'LeftCompany';
                        }else if (thisReason == 'Retired'){
                            thisReason = 'Retired';
                        }else if (thisReason == 'Inactive'){
                            thisReason = 'UnknownContact';
                        }

                        ISSP_ContactList ctrl = new ISSP_ContactList();
                        ctrl.processMultiplePortalUserStatusChange(cls, 'Deactivated', thisReason);
                    }
                }
            }
            /*ISSP_ContactStatusTrigger Trigger.AfterUpdate*/

            /*trgIECContact Trigger.AfterUpdate*/
            if(trgIECContact) {
                system.debug('trgIECContact AfterUpdate');
                trgHndlrIECContact.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
            }
            /*trgIECContact Trigger.AfterUpdate*/

            /*Contacts Trigger.AfterUpdate*/
            if(Contacts) {
                system.debug('Contacts AfterUpdate');
                ContactHandler.afterUpdate(Trigger.new, Trigger.old);
                //manage critical field notifications on after update
                EF_ContactHandler.manageCriticalFieldChanges(trigger.new, trigger.oldMap);
            }
            if (Utility.getNumericSetting('Stop Trigger:Contact') != 1)
                Contact_Dom.triggerHandler();
            /*Contacts Trigger.AfterUpdate*/
            
            /*ISSP_UpdateContacKaviIdOnUser AfterUpdate*/
            if (ISSP_UpdateContacKaviIdOnUser){
                system.debug('ISSP_UpdateContacKaviIdOnUser AfterUpdate');
                for (Contact oneContact: Trigger.new){
                    //if Kaviuser Field has been modified launch the process of updating ContactKaviId field on User related record.
                    if (!((Trigger.oldMap.get(oneContact.id).Kavi_User__c) == (Trigger.newMap.get(oneContact.id).Kavi_User__c))){
                        ISSP_ContactTriggerHandler.updateKaviIdOnUser(trigger.new);
                    }
                }
            }
            /*ISSP_UpdateContacKaviIdOnUser AfterUpdate*/

        }
        /*Trigger.AfterUpdate*/

        /****************************************************************************************************************************************************/    
        /*Trigger.AfterDelete*/
        else if (Trigger.isDelete) {
            /*Contacts Trigger.AfterDelete*/
            if(Contacts) {
                system.debug('Contacts AfterDelete');
                ContactHandler.afterDelete(Trigger.old);
            }
            /*Contacts Trigger.AfterDelete*/
        }
        /*Trigger.AfterDelete*/

        /****************************************************************************************************************************************************/    
        /*Trigger.AfterUndelete*/
        else if (Trigger.isUndelete) {
            /*Contacts Trigger.AfterUndelete*/
            if(Contacts) {
                system.debug('Contacts AfterUndelete');
                ContactHandler.afterUndelete(Trigger.new);
            }
            /*Contacts Trigger.AfterUndelete*/
        }
        /*Trigger.AfterUndelete*/
    
    	//Publish the platform events
    	PlatformEvents_Helper.publishEvents((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'Contact__e', 'Contact', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
    }
    /*AFTER*/
}
