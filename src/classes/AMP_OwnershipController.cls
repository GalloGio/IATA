public with sharing class AMP_OwnershipController {

    private final Account acc;
    public AMSAccountRoleList owners {get; set;}
    public AMSAccountRoleList subsidiaries {get; set;}
    public Boolean isAddNew {get; set;}
    public Boolean isEditMode {get; set;}
    public Boolean isNewLine {get; set;}
    public Id IdConcerned {get; set;}
    private Id OwnershipRtId {get; set;}

    public Boolean canEdit {get; set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public AMP_OwnershipController(ApexPages.StandardController stdController) {
        this.acc = (Account)stdController.getRecord();

        OwnershipRtId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');

        owners = getOwners();
        subsidiaries = getSubsidiaries();
        canEdit = getCanEdit();
    }

    @AuraEnabled
    public static Boolean getCanEdit() {
        Boolean canEdit = true;
        if(!Schema.SObjectType.AMS_Account_Role__c.fields.Account__c.isUpdateable()) canEdit = false;
        if(!Schema.SObjectType.AMS_Account_Role__c.fields.Owner_Account__c.isUpdateable()) canEdit = false;
        if(!Schema.SObjectType.AMS_Account_Role__c.fields.Percentage__c.isUpdateable()) canEdit = false;
        // MME : Should we check the updatability of the fields Other_Stakeholder_Types__c and No_Airline_Subsidiaries__c
        // and in that case, maybe the getCanEdit value should be calculated per line...
        return canEdit;
    }

    @AuraEnabled
    public static AMSAccountRoleList getOwners(Id AccountId) {
    	// MME : Shouldn't we filter on the record type (Ownership)?
        list<AMS_Account_Role__c> tmplstOwners = [SELECT Id, Percentage__c, Owner_Account__c, Owner_Account__r.Name, Owner_Account__r.Membership_status__c, Owner_Account__r.Sector__c, Account__c, Other_Stakeholder_Types__c, CreatedById
                        FROM AMS_Account_Role__c
                        WHERE Account__c = :AccountId];

        List<AMS_Account_Role__c> sortedList = new List<AMS_Account_Role__c>();
        List<AMS_Account_Role__c> otherStakeholderTypesRecords = new List<AMS_Account_Role__c>();

		// This will be used later in the method to define user rights on the special line
		Id specialLineCreatedById = null;
        
        for (AMS_Account_Role__c ar : tmplstOwners) {
            if (ar.Owner_Account__r != null && (ar.Owner_Account__r.Membership_status__c == null || ar.Owner_Account__r.Membership_status__c == '')) {
                ar.Owner_Account__r.Membership_status__c = ar.Owner_Account__r.Sector__c;
            }
            
			// Sort the list to have OtherStakeholderTypes records at the end of the list (there should be max 1 record)
            if(ar.Other_Stakeholder_Types__c){
            	otherStakeholderTypesRecords.add(ar);
            	specialLineCreatedById = ar.CreatedById;
            }
            else{
            	sortedList.add(ar);
            }
        }
        
        sortedList.addAll(otherStakeholderTypesRecords);
        
		Boolean hasSpecialLine = !otherStakeholderTypesRecords.isEmpty();
		Boolean canSpecialLineBeAdded = otherStakeholderTypesRecords.isEmpty();
        
        // Define user rights related to the Other Stakeholder Types line
	    Id userId = UserInfo.getUserId();
	    Id profileId = UserInfo.getProfileId();
	    
        List<PermissionSetAssignment> permissionSet = [select Id from PermissionSetAssignment where AssigneeId =: userId and PermissionSet.Name = 'AMP_Manage_Account_Ownership'];
        List<Profile> accountManagementTeamProfile = [SELECT Id FROM Profile WHERE Id =: profileId and Name='Account management team'];
        
		Boolean canUserHandleSpecialLine = !(accountManagementTeamProfile.isEmpty() && permissionSet.isEmpty());

        return new AMSAccountRoleList(sortedList, hasSpecialLine, canSpecialLineBeAdded, canUserHandleSpecialLine);
    }

    public AMSAccountRoleList getOwners() {
        return getOwners(acc.Id);
    }

    @AuraEnabled
    public static AMS_Account_Role__c upsertAccount(AMS_Account_Role__c accountRole ) {
        System.debug(accountRole);

            if (accountRole.RecordTypeId == null) {
                accountRole.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
            }

        upsert accountRole;
        return accountRole;
    }

    @AuraEnabled
    public static AMS_Account_Role__c deleteAccount(AMS_Account_Role__c accountRole ) {
        delete accountRole;
        return accountRole;
    }

    @AuraEnabled
    public static AMSAccountRoleList getSubsidiaries(Id AccountId) {
        list<AMS_Account_Role__c> tmplstOwners = [SELECT Id, Percentage__c, Account__c, Account__r.Name, Account__r.Membership_status__c, Account__r.Sector__c, Owner_Account__c, No_Airline_Subsidiaries__c, CreatedById
                        FROM AMS_Account_Role__c
                        WHERE Owner_Account__c = :AccountId
                        //AND Percentage__c >= 50
                        ];

        List<AMS_Account_Role__c> sortedList = new List<AMS_Account_Role__c>();
        List<AMS_Account_Role__c> noAirlineSubsidiariesRecords = new List<AMS_Account_Role__c>();

		// This will be used later in the method to define user rights on the special line
		Id specialLineCreatedById = null;
        
        for (AMS_Account_Role__c ar : tmplstOwners) {
            if (ar.Account__c != null && (ar.Account__r.Membership_status__c == null || ar.Account__r.Membership_status__c == '')) {
                ar.Account__r.Membership_status__c = ar.Account__r.Sector__c;
            }
            
			// Sort the list to have noAirlineSubsidiaries records at the end of the list (there should be max 1 record and if present, there shouldn't be any other line)
            if(ar.No_Airline_Subsidiaries__c){
            	noAirlineSubsidiariesRecords.add(ar);
            	specialLineCreatedById = ar.CreatedById;
            }
            else{
            	sortedList.add(ar);
            }
        }

        sortedList.addAll(noAirlineSubsidiariesRecords);

		Boolean hasSpecialLine = !noAirlineSubsidiariesRecords.isEmpty();
		Boolean canSpecialLineBeAdded = sortedList.isEmpty();
        
        // Define user rights related to the noAirlineSubsidiaries line
	    Id userId = UserInfo.getUserId();
	    Id profileId = UserInfo.getProfileId();
	    
        List<PermissionSetAssignment> permissionSet = [select Id from PermissionSetAssignment where AssigneeId =: userId and PermissionSet.Name = 'AMP_Manage_Account_Ownership'];
        List<Profile> accountManagementTeamProfile = [SELECT Id FROM Profile WHERE Id =: profileId and Name='Account management team'];
        
		Boolean canUserHandleSpecialLine = !(accountManagementTeamProfile.isEmpty() && permissionSet.isEmpty());

        system.debug('AccountId: ' + AccountId);
        system.debug('getSubs: ' + sortedList);

        return new AMSAccountRoleList(sortedList, hasSpecialLine, canSpecialLineBeAdded, canUserHandleSpecialLine);
    }

    public AMSAccountRoleList getSubsidiaries() {
        return getSubsidiaries(acc.Id);
    }


    public void AddNewOwner() {
        try {
            AMS_Account_Role__c newLine = new AMS_Account_Role__c();
            // newLine.Percentage__c = 0;
            newLine.Account__c = acc.Id;
            newLine.RecordTypeId = OwnershipRtId;
            //insert newLine;

            //lstOwners = getOwners();
            owners.amsAccountRoleList.add(newLine);

            IdConcerned = null;
            isEditMode = true;
            isNewLine = true;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
    }

    public void AddOtherStakeholderTypes(){
        try {
            AMS_Account_Role__c newLine = new AMS_Account_Role__c();
            newLine.Account__c = acc.Id;
            newLine.RecordTypeId = OwnershipRtId;
            newLine.Other_Stakeholder_Types__c = true;

            owners.amsAccountRoleList.add(newLine);

            IdConcerned = null;
            isEditMode = true;
            isNewLine = true;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
    }

    public void AddNewSubsidiary() {
        try {
            AMS_Account_Role__c newLine = new AMS_Account_Role__c();
            // newLine.Percentage__c = 0;
            newLine.Owner_Account__c = acc.Id;
            newLine.RecordTypeId = OwnershipRtId;
            //insert newLine;

            //lstSubsidiaries = getSubsidiaries();
            subsidiaries.amsAccountRoleList.add(newLine);

            IdConcerned = null;
            isEditMode = true;
            isNewLine = true;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
    }

    public void AddNoAirlineSubsidiaries(){
        try {
            AMS_Account_Role__c newLine = new AMS_Account_Role__c();
            newLine.Owner_Account__c = acc.Id;
            newLine.RecordTypeId = OwnershipRtId;
            newLine.No_Airline_Subsidiaries__c = true;

            subsidiaries.amsAccountRoleList.add(newLine);

			saveLine();
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
    }

    public void EditLine() {
        isEditMode = true;

        owners = getOwners();
        subsidiaries = getSubsidiaries();
    }


    public void SaveLine() {

        try {

            upsert owners.amsAccountRoleList;
            upsert subsidiaries.amsAccountRoleList;

            owners = getOwners();
            subsidiaries = getSubsidiaries();

            isEditMode = false;
            isNewLine = false;
                    // }
        } catch (DMLException e) {
        	System.debug('ERROR : ' + e.getMessage());
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
        }
    }


    public void DeleteLine() {
        try {
            AMS_Account_Role__c newLine = new AMS_Account_Role__c(Id = IdConcerned);
            delete newLine;

            owners = getOwners();
            subsidiaries = getSubsidiaries();
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
    }


    public void CancelEdit() {
        try {
            /*if (isNewLine) {
                AMS_Account_Role__c newLine = new AMS_Account_Role__c(Id = IdConcerned);
                delete newLine;
            }*/

            owners = getOwners();
            subsidiaries = getSubsidiaries();

            isEditMode = false;
            IdConcerned = null;
            isNewLine = false;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
    }    
    
    public class AMSAccountRoleList {
    	@AuraEnabled
    	public List<AMS_Account_Role__c> amsAccountRoleList {get;set;}
    
	    @AuraEnabled
	    public Boolean hasSpecialLine {get;set;}
	    
	    @AuraEnabled
	    public Boolean canSpecialLineBeAdded {get;set;}
	    
	    @AuraEnabled
	    public Boolean canUserHandleSpecialLine {get;set;}

	    public AMSAccountRoleList(List<AMS_Account_Role__c> amsAccountRoleList, Boolean hasSpecialLine, Boolean canSpecialLineBeAdded, Boolean canUserHandleSpecialLine){
	    	this.amsAccountRoleList = amsAccountRoleList;
	    	this.hasSpecialLine = hasSpecialLine;
	    	this.canSpecialLineBeAdded = canSpecialLineBeAdded;
	    	this.canUserHandleSpecialLine = canUserHandleSpecialLine;
	    }
    }
}
