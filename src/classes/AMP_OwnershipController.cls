public with sharing class AMP_OwnershipController {

	private final Account acc;
    public list<AMS_Account_Role__c> lstOwners {get; set;}
    public list<AMS_Account_Role__c> lstSubsidiaries {get; set;}
    public Boolean isAddNew {get; set;}
    public Boolean isEditMode {get; set;}
    public Boolean isNewLine {get; set;}
    public Id IdConcerned {get; set;}
    private Id OwnershipRtId {get; set;}


    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public AMP_OwnershipController(ApexPages.StandardController stdController) {
        this.acc = (Account)stdController.getRecord();

        OwnershipRtId = [SELECT Id FROM RecordType WHERE SObjectType = 'AMS_Account_Role__c' AND DeveloperName = 'Ownership'].Id;

        lstOwners = getOwners();
        lstSubsidiaries = getSubsidiaries();
    }


    @AuraEnabled
    public static list<AMS_Account_Role__c> getOwners(Id AccountId) {
        list<AMS_Account_Role__c> tmplstOwners = [SELECT Id, Percentage__c, Owner_Account__c, Owner_Account__r.Name, Owner_Account__r.Membership_status__c, Owner_Account__r.Sector__c, Account__c
                        FROM AMS_Account_Role__c
                        WHERE Account__c = :AccountId];

        for (AMS_Account_Role__c ar : tmplstOwners) {
            if (ar.Owner_Account__r != null && (ar.Owner_Account__r.Membership_status__c == null || ar.Owner_Account__r.Membership_status__c == '')) {
                ar.Owner_Account__r.Membership_status__c = ar.Owner_Account__r.Sector__c;
            }
        }

        return tmplstOwners;
    }

    public list<AMS_Account_Role__c> getOwners() {
        return getOwners(acc.Id);
    }

		@AuraEnabled
		public static AMS_Account_Role__c upsertAccount(AMS_Account_Role__c accountRole ) {
			System.debug(accountRole);
			upsert accountRole;
			return accountRole;
		}

		@AuraEnabled
		public static AMS_Account_Role__c deleteAccount(AMS_Account_Role__c accountRole ) {
			delete accountRole;
			return accountRole;
		}

    @AuraEnabled
    public static list<AMS_Account_Role__c> getSubsidiaries(Id AccountId) {
        list<AMS_Account_Role__c> tmplstOwners = [SELECT Id, Percentage__c, Account__c, Account__r.Name, Account__r.Membership_status__c, Account__r.Sector__c, Owner_Account__c
                        FROM AMS_Account_Role__c
                        WHERE Owner_Account__c = :AccountId
                        AND Percentage__c >= 50];

        for (AMS_Account_Role__c ar : tmplstOwners) {
            if (ar.Account__c != null && (ar.Account__r.Membership_status__c == null || ar.Account__r.Membership_status__c == '')) {
                ar.Account__r.Membership_status__c = ar.Account__r.Sector__c;
            }
        }

        system.debug('AccountId: ' + AccountId);
        system.debug('getSubs: ' + tmplstOwners);

        return tmplstOwners;
    }

    public list<AMS_Account_Role__c> getSubsidiaries() {
        return getSubsidiaries(acc.Id);
    }


    public void AddNewOwner() {
        try {
            AMS_Account_Role__c newLine = new AMS_Account_Role__c();
            newLine.Percentage__c = 0;
            newLine.Account__c = acc.Id;
            newLine.RecordTypeId = OwnershipRtId;
            //insert newLine;

            //lstOwners = getOwners();
            lstOwners.add(newLine);

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
            newLine.Percentage__c = 0;
            newLine.Owner_Account__c = acc.Id;
            newLine.RecordTypeId = OwnershipRtId;
            //insert newLine;

            //lstSubsidiaries = getSubsidiaries();
            lstSubsidiaries.add(newLine);

            IdConcerned = null;
            isEditMode = true;
            isNewLine = true;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
    }


    public void EditLine() {
        isEditMode = true;

        lstOwners = getOwners();
        lstSubsidiaries = getSubsidiaries();
    }


    public void SaveLine() {
			Decimal sum = 0;
			Boolean zeroPercent = false; // percentage held is <= 0
			Boolean ownerTwice = false; // the same account as owner twice
			Boolean subsidiaryTwice = false; // the same account as subsidiary twice
			Boolean selfOwnership = false; // account owning itself
			Boolean ownershipMix = false; // the same account as owner and subsidiary
			Boolean lowPercent = false; // percentage held <50
			for(AMS_Account_Role__c a : lstOwners) {
				if(a.Percentage__c <= 0) {
					zeroPercent = true;
					break;
				}
				if(a.Account__c == a.Owner_Account__c) {
					selfOwnership = true;
					break;
				}
				for(AMS_Account_Role__c b : lstOwners) {
					if(a.Id != b.Id && a.Owner_Account__c == b.Owner_Account__c) {
						ownerTwice = true;
						// break;
					}
				}

						sum += a.Percentage__c;
						for(AMS_Account_Role__c b : lstSubsidiaries) {
							if(a.Owner_Account__c == b.Account__c) {
								ownershipMix = true;
								// break;
							}
						}
			}
			for(AMS_Account_Role__c a : lstSubsidiaries) {
				if(a.Percentage__c < 50) {
					lowPercent = true;
					break;
				}
				for(AMS_Account_Role__c b : lstSubsidiaries) {
					if(a.Id != b.Id && a.Account__c == b.Account__c) {
						subsidiaryTwice = true;
						// break;
					}

				}
			}

        try {
					if(sum > 100) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The total ownership cannot be more than 100%' ));
					} else if(zeroPercent) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The ownership must be more than 0%' ));
					} else if(ownerTwice) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The same owner cannot be listed twice' ));
					} else if(subsidiaryTwice) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The same subsidiary cannot be listed twice' ));
					} else if(lowPercent) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The percenteage held must be at least 50%' ));
					} else if(ownershipMix) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The same account cannot be an owner and a subsidiary' ));
					} else {

						System.debug(lstOwners);
						System.debug(lstSubsidiaries);

            upsert lstOwners;
            upsert lstSubsidiaries;

            lstOwners = getOwners();
            lstSubsidiaries = getSubsidiaries();

            isEditMode = false;
            isNewLine = false;
					}
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
    }


    public void DeleteLine() {
        try {
            AMS_Account_Role__c newLine = new AMS_Account_Role__c(Id = IdConcerned);
            delete newLine;

            lstOwners = getOwners();
            lstSubsidiaries = getSubsidiaries();
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

            lstOwners = getOwners();
            lstSubsidiaries = getSubsidiaries();

            isEditMode = false;
            IdConcerned = null;
            isNewLine = false;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
    }
}