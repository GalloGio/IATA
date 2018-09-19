public class CampaignMember_Svc
{

    //Generate renewal Order
    public static void generateRenewalOrder(String campaignId,List<CampaignMember> campaignMembers){
        //system.debug('generateRenewalOrder CALLED');
        set<Id> contactIds = new set<Id>();
        for(CampaignMember cm : campaignMembers){
            contactIds.add(cm.ContactId);
        }
        //*** remove deleted contact
        for (Contact c : [select Id from Contact where Id in :contactIds and IsDeleted = true])
            contactIds.remove(c.Id);
        //system.debug('set contactIds ' + contactIds);
        generateRenewalOrder(campaignId, contactIds);

    }

    //Generate Order Campaign Member and Product
    public static void generateRenewalOrder(Id campaignId, set<Id> contactIds){

        //get the list of campaign member product base on the contact Id
        map<Id,List<Campaign_Member_Product__c>> contactId_campaignMemberPrd = new campaignMemberProduct_sel().getCampaignMemberPrdByContactId(campaignId,contactIds);
        map<Id,List<Campaign_Member_Product__c>> contactId_newCampaignMemberPrd = new map<Id,List<Campaign_Member_Product__c>>();
        map<Id,Campaign_Member_Product__c> productId_newCampaignMemberPrd = new map<Id, Campaign_Member_Product__c>();

        //Get the last version of product form campaign product object
        map<Id,Id> old_NewProds = new CampaignProduct_Sel().getLastVersionProductIdById(campaignId);
        set<Id> prodIds = new set<Id>();
        Map<String, String> mapProduct_Version = new Map<String, String>();
        
        //Make sure that the contact do not have duplicated product
        for(Id contactId : contactId_campaignMemberPrd.keySet()){
            if (contactId_campaignMemberPrd.containsKey(contactId)){
                productId_newCampaignMemberPrd.clear();
                mapProduct_Version.clear();
                for (Campaign_Member_Product__c cmp : contactId_campaignMemberPrd.get(contactId)){
                    Id newVersion = old_NewProds.get(cmp.Product__c);
                    String strActivity = String.valueOf(cmp.Product__r.SAP_Material_Number__c).left(4);
                    String strVersion = String.valueOf(cmp.Product__r.SAP_Material_Number__c).right(2);
                    prodIds.add(newVersion);
                    if (!productId_newCampaignMemberPrd.containsKey(newVersion) ||
                        (mapProduct_Version.containsKey(strActivity) && mapProduct_Version.get(strActivity) < strVersion))
                    {
                        cmp.Product__c = newVersion;
                        productId_newCampaignMemberPrd.put(newVersion, cmp);
                        mapProduct_Version.put(strActivity, strVersion);
                    }
                    //else
                        //productId_newCampaignMemberPrd.get(newVersion).Quantity__c += cmp.Quantity__c;
                }
                if (productId_newCampaignMemberPrd.size() > 0)
                    contactId_newCampaignMemberPrd.put(contactId, productId_newCampaignMemberPrd.values());
            }
            /*
            List<Campaign_Member_Product__c> lstMemberProds = contactId_campaignMemberPrd.get(contactId);

            //get the list of campaign member product base on the product new version
            map<Id,List<Campaign_Member_Product__c>> newProdVersion_listCmp = new map<Id,List<Campaign_Member_Product__c>>();

            set<Campaign_Member_Product__c> contrtsactIds = new set<Campaign_Member_Product__c>();

            //create the new list of campaign member product base on the last version of the product
            for(Campaign_Member_Product__c cmp : lstMemberProds){
                Id newVersion = old_NewProds.get(cmp.Product__c);
                cmp.Product__c = newVersion;
            }

            //create the new list of campaign member product base on the last version of the product
            for(Campaign_Member_Product__c cmp : lstMemberProds){
                if(!newProdVersion_listCmp.containsKey(cmp.Product__c)){
                    newProdVersion_listCmp.put(cmp.Product__c, new List<Campaign_Member_Product__c>());
                }
                newProdVersion_listCmp.get(cmp.Product__c).add(cmp);
            }

            contactId_newCampaignMemberPrd.put(contactId, new List<Campaign_Member_Product__c>());

            //set the last list of campaign member product for the contact
            for(Campaign_Member_Product__c cmp : lstMemberProds){
                List<Campaign_Member_Product__c> cmpsByVersion = newProdVersion_listCmp.get(cmp.Product__c);
                
                Boolean takeFirst = false;
                if(cmpsByVersion != null && cmpsByVersion.size() > 1){
                    Date inoviceDate;
                    Decimal qty = 1;
                    for(Campaign_Member_Product__c newCmp : cmpsByVersion){
                        if(inoviceDate == null && newCmp.Invoice_Date__c != null){
                            inoviceDate = newCmp.Invoice_Date__c;
                            qty = newCmp.Quantity__c;
                        }else if(newCmp.Invoice_Date__c != null && inoviceDate < newCmp.Invoice_Date__c){
                            inoviceDate = newCmp.Invoice_Date__c;
                            qty = newCmp.Quantity__c;
                        }else{
                            takeFirst = true;
                        }
                    }
                    if(takeFirst){
                        Campaign_Member_Product__c cpmToAdd = cmpsByVersion[0];
                        cpmToAdd.Quantity__c = qty;
                        contactId_newCampaignMemberPrd.get(contactId).add(cpmToAdd);
                    }else{
                        contactId_newCampaignMemberPrd.get(contactId).add(cmpsByVersion[0]);
                    }
                    
                }else if(cmpsByVersion != null){
                    contactId_newCampaignMemberPrd.get(contactId).add(cmpsByVersion[0]);
                }
                    
            }*/

        }

        system.debug('contactId_newCampaignMemberPrd ' + contactId_newCampaignMemberPrd);

        //for each contact generate a order to create
        map<Id,Order> contactId_Order = createOrderbyContactId(campaignId,contactId_newCampaignMemberPrd.keySet());

        //get the list of all products
        /*set<Id> prodIds = new set<Id>();
        for(id contactId : contactId_newCampaignMemberPrd.keySet()){
            List<Campaign_Member_Product__c> lstCmp = contactId_newCampaignMemberPrd.get(contactId);
            for(Campaign_Member_Product__c cmp : lstCmp){
                prodIds.add(cmp.Product__c);
            }
        }*/

        //Create Items for each order
        //get the map of order Id base on the Order
        map<Id,Order> orderId_Order = new map<Id,Order>(contactId_Order.values());

        //insert the Order Items
        set<Id> orderItemIds = createOrderItemsForOrder(orderId_Order,contactId_newCampaignMemberPrd,prodIds);
    }

    //Create an order for each Contact
    public static map<Id,Order> createOrderbyContactId(Id campaignId, set<Id> contactIds){
        
        system.debug('contactIds ' + contactIds);

        List<Order> toInsert = new List<Order>();
        map<Id,Order> contactId_Order = new map<Id,Order>();
        Map<Id, Id> contactId_UserId = new User_Sel().getUserByContact(contactIds);

        system.debug('contactId_UserId ' + contactId_UserId);

        //List<Contact> lstContact = [SELECT id, AccountId from Contact where Id in :contactIds ];
        map<Id,Contact> contactId_Contact = Contact_Sel.getContactById(contactIds);
        system.debug('contactId_UserId ' + contactId_UserId);

        for(Id contactId : contactId_Contact.keySet()){
            //get the related Account
            Contact contact = contactId_Contact.get(contactId);
            //get the order owner id
            Id orderOwnerId;
            if(contactId_UserId.containsKey(contactId))
                orderOwnerId =  contactId_UserId.get(contactId);

            //Create the Order
            Order order = Order_Svc.createNewOrder(IECConstants.ORDER_TYPE_RENEWAL_NOTIFICATION, campaignId, null, null, contact, orderOwnerId);
            if(order != null){
                toInsert.add(order);
            }
        }

        if(toInsert.size() > 0){
            contactId_Order = saveOrders(toInsert);
        }

        return contactId_Order;
        
    }

    //Save the orders and return a map of billing contactId and order
    public static map<Id,Order> saveOrders(List<Order> orders){
        
        map<Id,Order> contactId_Order = new map<Id,Order>();

        set<Id> orderIds = new set<Id>();
        
        List<Database.SaveResult> srList = Database.insert(orders, false);
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                orderIds.add(sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {                   
                    System.debug('Error saveOrders +++ ' + err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
        if(orderIds.size() > 0){

            Id campaignId;

            List<Order> lstOrder = Order_Sel.getOrdersById(orderIds);
            if(lstOrder != null && lstOrder.size() > 0){
                for(Order order : lstOrder){
                    contactId_Order.put(order.BillToContactId,order);
                    if(campaignId == null) campaignId = order.Campaign__c;
                }
            }

            //Update the campaign members with the order
            List<CampaignMember> cmToUpdate = new List<CampaignMember>();
            
            map<Id,CampaignMember> contactId_campaignMember = new CampaignMember_sel().getCampaignMembers(campaignId, contactId_Order.keySet());
            
            for(Id contactId : contactId_Order.keySet()){
                Order order = contactId_Order.get(contactId);
                CampaignMember cm = contactId_campaignMember.get(contactId);
                
                if(order != null && cm !=null) 
                {
                    cm.Order__c = order.Id;
                    cmToUpdate.add(cm);
                }
            }

            if(cmToUpdate.size() > 0){
                Update cmToUpdate;
            }
        }
        return contactId_Order;
    }

    //Create the orderItems
    public static set<Id> createOrderItemsForOrder( map<Id,Order> orderId_Order,map<Id,List<Campaign_Member_Product__c>> contactId_campaignMemberPrd,set<Id> prodIds){ 
        
        set<Id> orderItemIds = new set<Id>();

        //Set the pricebookEntry
        Pricebook2 stdPriceBook = new Pricebook_Sel().getStandardPriceBook();
        Map<Id, PricebookEntry> pricebookEntryByProductId = new PricebookEntry_Sel().getPricebookEntryByProductId(stdPriceBook.Id, prodIds);
        
        List<PricebookEntry> pbe2Create = new List<PricebookEntry> ();

        pricebookEntryByProductId = new PricebookEntry_Sel().getPricebookEntryByProductId(stdPriceBook.Id, prodIds);

        //get Items by order
        List<OrderItem> itemsToInsert = new List<OrderItem>();
        for(Order order : orderId_Order.values()){
            List<Campaign_Member_Product__c> lstCmp = contactId_campaignMemberPrd.get(order.BillToContactId);
            
            if(lstCmp == null) continue;

            for(Campaign_Member_Product__c cmp : lstCmp){
                PricebookEntry pbe = pricebookEntryByProductId.get((Id) cmp.Product__c);
                itemsToInsert.add(
                    new OrderItem(
                        OrderId = order.Id, PriceBookEntryId = pbe.Id, Quantity = cmp.Quantity__c, UnitPrice = pbe.UnitPrice
                    )
                );
            }
        }

        //Insert orderItems
        if(itemsToInsert.size() > 0){
            orderItemIds = OrderItem_Svc.insertOrderItems(itemsToInsert);
            if (orderItemIds.size() > 0) {
                //Get Product price info
                Set<String> setProductNumber = new Set<String>(); 
                for(Product2 p: [select SAP_Material_Number__c from Product2 where Id in : prodIds])
                    setProductNumber.add(p.SAP_Material_Number__c);
                Map<String, PriceInfo_DTO> mapProductNumber_Price = new Product_Sel().getProductPriceInfo(setProductNumber, null, null, null, true);

                system.debug('itemsToInsert ' + itemsToInsert);
                system.debug('mapProductNumber_Price ' + mapProductNumber_Price);

                //Set the orderItems price
                for(Order order : orderId_Order.values())
                    Order_Svc.setPriceToOrder(order, mapProductNumber_Price);
            }
            

        }

        return orderItemIds;
    }
    

    //Prevent user to add campaign member
    public static void validateAddingCampaignMembers(List<CampaignMember> campaignMembers){

        set<Id> campaignIds = new set<Id>();

        for(CampaignMember cm : campaignMembers){
            campaignIds.add(cm.CampaignId);
        }

        //get Campaign by Id
        map<Id,Campaign> campaignById = new Campaign_Sel().getCampaignById(campaignIds);

        for(CampaignMember cm : campaignMembers){
            Campaign campaign = campaignById.get(cm.CampaignId);
            //verified if batchs done generatind campaign members
            if(campaign != null && campaign.Generate_Members_Completed_On__c != null){
                cm.addError(label.Add_campaign_member_error);
                break;
            }
        }

    }

    public static List<CampaignMember> generateCampaignMembers(Id campaignId, List<OrderItem> items){
        //-- List to return 
        List<CampaignMember> campaignMembers2Save = new List<CampaignMember>();

        Map<Id, List<OrderItem>> itemsByContactId = new Map<Id, List<OrderItem>>(); 
        Set<String> cmSearchKeys = new Set<String>();
        
        //Make sure that the BillToContact is not Deleted
        set<Id> contactIds = new set<Id>();
        map<Id,Contact> contactsById = new map<Id,Contact>();
        List<IEC_Renewal_notice_log__c> lstErrorLog = new List<IEC_Renewal_notice_log__c>();
        
        //Set order items product ids
        Set<Id> setOrderItemProductIds = new Set<Id>();

        for(OrderItem item : items){
            contactIds.add(item.Order.BillToContactId);
            setOrderItemProductIds.add(item.Product__c);
        }

        System.debug('JJ setOrderItemProductIds : ' + setOrderItemProductIds);

        //get the subscriptions for this products and contacts
        List<IEC_Event_Subscription__c> lstEventSubscriptions = new IEC_EventSubscription_Sel().getEventSubscriptionByProductsIdListAndContactsList(setOrderItemProductIds,contactIds);
        System.debug('JJ lstEventSubscriptions: ' + lstEventSubscriptions);
        
        Map<Id,List<IEC_Event_Subscription__c>> mapSubscriptionByProductNbrWoVersion = IEC_EventSubscription_Svc.buildMapWithSubscByProductNbrWoVersion(lstEventSubscriptions);


        System.debug('JJ mapSubscriptionByProductNbrWoVersion : ' + mapSubscriptionByProductNbrWoVersion);
        
        contactsById = Contact_Sel.getContactById(contactIds);
        
        for(OrderItem item : items){
            if(item.Order.BillToContactId == null) continue;
            
            IEC_Event_Subscription__c iecEventSubsAux = null;
            if(mapSubscriptionByProductNbrWoVersion.containsKey(item.Product__c)){
                List<IEC_Event_Subscription__c>  lstIecEventSubsAux = mapSubscriptionByProductNbrWoVersion.get(item.Product__c);
                for(IEC_Event_Subscription__c iecAux : lstIecEventSubsAux){
                    if(iecAux.Subscriber__c == item.Order.BillToContactId){
                        iecEventSubsAux = iecAux;
                    }
                }
            }
            System.debug('JJ iecEventSubsAux : ' + iecEventSubsAux);

            //If have an subscription that is active, then remove them from renewal notice
            if( iecEventSubsAux == null || !(iecEventSubsAux != null && iecEventSubsAux.Active__c)){
                System.debug('JJ does not have active subscription');
                Contact contact = contactsById.get(item.Order.BillToContactId);
                //If contact is not deleted create CampaignMember
                if(contact != null && !contact.IsDeleted){
                    List<OrderItem> tmp = (itemsByContactId.containsKey(contact.Id))
                        ?   itemsByContactId.get(contact.Id)
                        :   new List<OrderItem>(); 
        
                    tmp.add(item);
                    itemsByContactId.put(contact.Id, tmp);
                    
                    cmSearchKeys.add(campaignId + '_' + contact.Id);
                }else{
                    //If Contact is deleted log it
                    lstErrorLog.add(
                        IEC_RenewalNotice_Svc.logError('Trying to create campaignMember for deleted contact', JSON.serialize(contact), null, campaignId, null, false)
                    );
                }
            }
            
        }

        Map<String,CampaignMember> existingCampaignMemberByKey = new CampaignMember_sel().getExistingCampaignMemberByKey(cmSearchKeys);
        Set<String> cmKeysToInsert = new Set<String>();

        for(Id contactId : itemsByContactId.keySet()){
            String key = campaignId + '_' + contactId; 

            //Ensure that there is no duplicate Campaign Member
            if(!cmKeysToInsert.contains(key)){
                cmKeysToInsert.add(key);
                if(!existingCampaignMemberByKey.containsKey(key)){
                    campaignMembers2Save.add(new CampaignMember(
                        CampaignId = campaignId, 
                        ContactId = contactId,
                        Status = 'Not Reached',
                        Key__c = key
                    ));
                }                       
            }
        }
        
        //insert new CampaignMembers and update existing ones base on the campaign and contact
        try{
            if(campaignMembers2Save.size() > 0) upsert campaignMembers2Save Key__c;
        }catch(Exception ex){
            lstErrorLog.add(
                IEC_RenewalNotice_Svc.logError('Error when trying to upsert campaignMembers', JSON.serialize(campaignMembers2Save), null, campaignId, null, false)
            );
        }
        
        //Log renewal notice errors
        if(lstErrorLog.size() > 0) insert lstErrorLog;


        return campaignMembers2Save;
    }

    public static void sendBatchFinishNotification(List<String> emails, String campaignNumber, String name, EmailTemplate template){

        String templateSubject = (template != null && template.Subject != null) ? template.Subject : '';
        String templateHtmlValue = (template != null && template.HtmlValue != null) ? template.HtmlValue : '';
        String body = '';
        String subject = (templateSubject.contains('{!Campaign.Campaign_Number__c}')) ? templateSubject.replace('{!Campaign.Campaign_Number__c}',campaignNumber) : templateSubject ;
        body = (templateHtmlValue.contains('{!User.Name}')) ? template.HtmlValue.replace('{!User.Name}', name) : templateHtmlValue;
        body = (body.contains('{!Campaign.Campaign_Number__c}')) ? body.replace('{!Campaign.Campaign_Number__c}',campaignNumber) : body;

        Utility.sendEmail(emails,subject,body,true,null);
    }

}