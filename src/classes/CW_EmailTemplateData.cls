public without sharing class CW_EmailTemplateData {
    public String stationId {get; set;}
    public String contactRoleDetailId {get; set;}
    public String orderItemId {get; set;}
    public Boolean isRemove {get;set;}
    List<ICG_Account_Role_Detail__c> station;
    List<ICG_Contact_Role_Detail__c> contactRoleDetail;
    List<OrderItem> orderItem;
    List<User> userRequestor;
    List<Account> accountDetail;
    public Boolean isPurchaseRemoteValidation {get;set;}


    public ICG_Account_Role_Detail__c getStationDetails(){
        if(station == null && stationId != null) station = [SELECT Name, Reject_Reason__c, LastModifiedById, Company_Admin_Approver_Rejector__c, RecordType.Name, Company_FOR__c, Country_FOR__c, City_FOR__c, CreatedById, Account_Role__c,Account_Role__r.Account__c FROM ICG_Account_Role_Detail__c WHERE Id = :stationId LIMIT 1];
        return station != null && !station.isEmpty() ? station[0] : null;
    }
 
    public ICG_Contact_Role_Detail__c getContactRoleDetails(){
        if(contactRoleDetail == null && contactRoleDetailId != null) contactRoleDetail = [SELECT Id, Reject_Reason__c, CreatedById, LastModifiedById, Company_Admin_Approver_Rejector__c, CreatedBy.Name, ICG_Role__c, ICG_Account_Role_Detail__c,ICG_Account_Role_Detail__r.Account_Role__r.Account__c, Account_Role__c, Account_Role__r.Account__c, ContactId__c FROM ICG_Contact_Role_Detail__c WHERE Id = :contactRoleDetailId LIMIT 1];
        return contactRoleDetail != null && !contactRoleDetail.isEmpty() ? contactRoleDetail[0] : null;
    }

    public OrderItem getOrderItemDetails(){
        if(orderItem == null && orderItemId != null) orderItem = [SELECT Id, Station__c, OrderId, (Select Id from ICG_Capability_Assignment_Groups__r),CreatedById FROM OrderItem where Id =:orderItemId];
        return orderItem != null && !orderItem.isEmpty() ? orderItem[0] : null;
    }

    public List<ICG_Contact_Role_Detail__c> getStationManagersContactRoleDetails(){
        if(stationId != null) return CW_Utilities.getStationManagersContactRoleDetails(stationId);
        else return new List<ICG_Contact_Role_Detail__c>();
	}

    public User getRequestedBy()
    {
        if(userRequestor == null){
            Id requestorId;
            if(getContactRoleDetails() != null){
            requestorId = contactRoleDetail[0].LastModifiedById;
            }
            else if(getOrderItemDetails() != null){
                requestorId = orderItem[0].CreatedById;
            }
            else if (getStationDetails() != null){
                requestorId = station[0].LastModifiedById;
            }

            userRequestor = [SELECT Firstname, Lastname, Name, Email, AccountId, Account.Name, Account.Business_Street__c, Account.Business_City_Name__c, Account.Business_City__c, Account.Business_City__r.Name,
            Account.Business_Postal_Code__c, Account.IATA_ISO_Country__r.Name, Account.Business_State_Name__c,  Account.Iso_State__r.Name FROM User WHERE Id = :requestorId LIMIT 1];
        }
        
        return userRequestor != null && !userRequestor.isEmpty() ? userRequestor[0] : null;
    }

    

    public String getRequestedByCompanyAddress()
    {
        String address='';
        User u = getRequestedBy();
        if (u != null){
            address = buildAddress(u);
        }

        return address;
    }

    public Account getAccountDetail()
    {

        if (getStationDetails() != null){
            accountDetail = [SELECT Id, TradeName__c,Legal_name__c,Phone,Email__c,Website, Name, Category__c, Sector__c FROM Account WHERE Id = :station[0].Account_Role__r.Account__c LIMIT 1];
        }
        return accountDetail != null && !accountDetail.isEmpty() ? accountDetail[0] : null;
    }

    public String getCommunityUrl(){
        return CW_Utilities.getCommunityUrlBase();
    }
    public String getCommunityUrlForResources(){
        return CW_Utilities.getCommunityUrlBase().removeEnd('s/');
    }
    public String getPrivateAreaUrl(){
        return CW_Utilities.getURLPage('URL_ICG_PrivateArea');
    }
    public String getFacilityPageUrl(){
        return CW_Utilities.getURLPage('URL_ICG_FacilityPage');
    }
    public String getOperationalHierarchyFromStation(){
        String opsHierarchy = getStationDetails() != null ? CW_Utilities.getOpsHierarchyNameFromStationId(getStationDetails().Id) : 'N/A';
        return opsHierarchy;
    }
    public String getOperationalHierarchyFromCrd(){
        String opsHierarchy = 'N/A';
        if(getContactRoleDetails() != null){
            if(contactRoleDetail[0].ICG_Account_Role_Detail__c != null) return CW_Utilities.getOpsHierarchyNameFromStationId(contactRoleDetail[0].ICG_Account_Role_Detail__c);
            else if (contactRoleDetail[0].Account_Role__c != null) return CW_Utilities.getOpsHierarchyNameFromAccountId(contactRoleDetail[0].Account_Role__r.Account__c);
        }
        return opsHierarchy;
    }
    public String getOperationalHierarchyFromCrdOrStation(){
        if(getOperationalHierarchyFromCrd() != 'N/A') return getOperationalHierarchyFromCrd();
        else return getOperationalHierarchyFromStation();
    }
    public String getOperationalHierarchyFromRequestor(){
        String opsHierarchy = getRequestedBy() != null ? CW_Utilities.getOpsHierarchyNameFromUserId(getRequestedBy().Id) : 'N/A';
        return opsHierarchy;
    }
    public List<ICG_Account_Role_Detail__c> getDuplicatedStations (){
        List<ICG_Account_Role_Detail__c> duplicatedStations;
        if (getStationDetails() != null){
            duplicatedStations = [SELECT Name, RecordType.Name, Company_FOR__c, Country_FOR__c, City_FOR__c, CreatedById, Account_Role__r.Account__c FROM ICG_Account_Role_Detail__c WHERE RecordType.Name =:station[0].RecordType.Name and Account_Role__c =:station[0].Account_Role__c];
        }
        return duplicatedStations != null && !duplicatedStations.isEmpty() ? duplicatedStations : null;
    }

    public String getApproveUrl(){
        String approveUrl = getPrivateAreaUrl();        
        if (isRemove == true){
            if(getContactRoleDetails() != null){
                approveUrl += '?approveRemoveContactRole='+contactRoleDetail[0].Id;
            }
        }else{
            if(getContactRoleDetails() != null){
                approveUrl += '?approveContactRole='+contactRoleDetail[0].Id;
            }
            else if (getStationDetails() != null){
                approveUrl += '?approveStation='+station[0].Id;
            }
        }
        return approveUrl;
    }

    public User getContactRoleDetailUser(){

        User crdUser;
        if(getContactRoleDetails() != null){
            crdUser = [SELECT Firstname, Lastname, Name, Email, AccountId, Account.Name, Account.Business_Street__c, Account.Business_City_Name__c, Account.Business_City__c, Account.Business_City__r.Name,
            Account.Business_Postal_Code__c, Account.IATA_ISO_Country__r.Name, Account.Business_State_Name__c,  Account.Iso_State__r.Name FROM User WHERE contactId = :contactRoleDetail[0].ContactId__c];
        }

        return crdUser;
    }

    public String getContactRoleDetailContactAccountAddress(){
        String address='';
        User u = getContactRoleDetailUser();
        if ( u != null){
           address = buildAddress(u);
        }

        return address;
    }

    public String getRejectUrl(){
        String rejectUrl = getPrivateAreaUrl();

        if (isRemove == true){
            if(getContactRoleDetails() != null){
                rejectUrl += '?rejectRemoveContactRole='+contactRoleDetail[0].Id;
            }
        }else{
            if(getContactRoleDetails() != null){
                rejectUrl += '?rejectContactRole='+contactRoleDetail[0].Id;
            }
            else if (getStationDetails() != null){
                rejectUrl += '?rejectStation='+station[0].Id;
            }
        }

        return rejectUrl;
    }

    public String getStationUrl(){
        String url = getPrivateAreaUrl();
        if (getStationDetails() != null){
            url += '/#ID:'+station[0].Id;
        }
        return url;
    }
    public String getPublicStationUrl(){
        String url = getFacilityPageUrl();
        if (getStationDetails() != null){
            url += '?eid='+station[0].Id;
        }
        return url;
    }

    public String getManageCompanyAdminsUrl(){
        String url = getPrivateAreaUrl();
        url += '#Company%20Admins';
        return url;
    }

    public String getIataManageRequest(){
        ICG_Environment_Variables__c environmentVariables = CW_Utilities.getEnvironmentVariables();
        String manageRequestUrl = environmentVariables.InternalRequestURL__c;
        if(getContactRoleDetails() != null){
            manageRequestUrl += String.valueOf(contactRoleDetail[0].Id);
        }
        else if (getStationDetails() != null){
            manageRequestUrl += String.valueOf(station[0].Id);
        }

        return manageRequestUrl;
    }

    public List<Contact> getCompanyAdminContacts(){
        if(contactRoleDetailId != null && getContactRoleDetails() != null) return contactRoleDetail[0].ICG_Account_Role_Detail__c != null ? CW_Utilities.getCompanyadminContactsFromAccountId(contactRoleDetail[0].ICG_Account_Role_Detail__r.Account_Role__r.Account__c) : CW_Utilities.getCompanyadminContactsFromAccountId(contactRoleDetail[0].Account_Role__r.Account__c);
        else if(stationId != null && getStationDetails() != null) return CW_Utilities.getCompanyadminContactsFromAccountId(station[0].Account_Role__r.Account__c);
        else return new List<Contact>();
    }
    
    public User getApprover (){
        User approver;
        String approverId;
        if(getContactRoleDetails() != null){
            approverId = contactRoleDetail[0].Company_Admin_Approver_Rejector__c != null ? contactRoleDetail[0].Company_Admin_Approver_Rejector__c : contactRoleDetail[0].LastModifiedById;
        }
        else if (getStationDetails() != null){
            approverId = station[0].Company_Admin_Approver_Rejector__c != null ? station[0].Company_Admin_Approver_Rejector__c : station[0].LastModifiedById;
        }

        if(approverId != null){
            approver = [SELECT Firstname, Lastname, Name, Email, AccountId, Account.Name, Account.Business_Street__c, Account.Business_City_Name__c, Account.Business_City__c, Account.Business_City__r.Name,
            Account.Business_Postal_Code__c, Account.IATA_ISO_Country__r.Name, Account.Business_State_Name__c,  Account.Iso_State__r.Name FROM User WHERE Id = :approverId LIMIT 1];
        }
        
        return approver;
    }

    public String getRejectReason (){
        String rejectReason;

        if(getContactRoleDetails() != null){
            rejectReason = contactRoleDetail[0].Reject_Reason__c != null ? contactRoleDetail[0].Reject_Reason__c : 'No Reason Provided';
        }
        else if (getStationDetails() != null){
            rejectReason = station[0].Reject_Reason__c != null ? station[0].Reject_Reason__c : 'No Reason Provided';
        }
        
        return rejectReason;
    }

    public String getApproverAddress()
    {
        String address='';
        User u = getApprover();
        if ( u != null){
           address = buildAddress(u);
        }

        return address;
    }

    public String getContactRoleDetailUserAddress(){
        String address='';
        User u = getContactRoleDetailUser();
        if ( u != null){
           address = buildAddress(u);
        }

        return address;
    }

    public String getApproverOpsHierarchy()
    {
        String opsHierarchy='';
        User u = getApprover();
        if ( u != null && u.accountId != null){
            opsHierarchy = CW_Utilities.getOpsHierarchyNameFromAccountId(u.accountId);
        }

        return opsHierarchy;
    }

    public String buildAddress(User u){
        String address='';
        if( u!= null && u.AccountId != null){
            address += u.Account.Business_Street__c;
            if(address != '') address+=', ';
            address +=  u.Account.Business_Postal_Code__c;
            if(address != '' && !address.endsWith(', ')) address+=', ';
            address +=  u.Account.Business_City__c != null ? u.Account.Business_City__r.Name : u.Account.Business_City_Name__c;
            if(address != '' && !address.endsWith(', ')) address+=', ';
            address +=  u.Account.IATA_ISO_Country__r.Name;
            address = address.replaceAll('null, ','');
        }
        return address;
    }

    public String getRemoteValidationLink(){
        if(isPurchaseRemoteValidation == true) return getPurchaseRemoteValidationLink();
        else return getOpenRemoteValidationAreaUrl();
    }
    public String getOpenRemoteValidationAreaUrl(){
        return getPrivateAreaUrl() + '#Open%20Remote%20Validations';
    }
    public String getPurchaseRemoteValidationLink(){
        return getPrivateAreaUrl() + '#Purchase%20Remote%20Validation';
    }
    public String getScheduleAuditsUrl(){
        return getPrivateAreaUrl() + '#Schedule%20Audits';
    }
}