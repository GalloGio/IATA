@IsTest
Public Class TestData {
    public class ForReplicateAccreditation {
        public User user {get; set;}
        public List<Account> accountsList {get; set;}
        public List<Accreditation__c> accreditationsList {get; set;}
        public ForReplicateAccreditation() {
            this.user = TestUtilities.createAdminUser();
            this.accountsList = TestUtilities.createAccounts(250);
            this.accreditationsList = TestUtilities.createAccreditations(250, accountsList);
        }
    }

    public class ForReplicateAccount {
        public User user {get; set;}
        public List<Account> accountsList {get; set;}
        public List<Accreditation__c> accreditationsList {get; set;}
        public ForReplicateAccount() {
            this.user = TestUtilities.createAdminUser();
            this.accountsList = TestUtilities.createAccounts(250);
            this.accreditationsList = TestUtilities.createAccreditations(250, accountsList);
        }
    }

    public class ForReplicateAccountCategory {
        public User user {get; set;}
        public List<Account> accountsList {get; set;}
        public List<Accreditation__c> accreditationsList {get; set;}
        public List<Account_Category__c> accountCategoriesList {get; set;}
        public ForReplicateAccountCategory() {
            this.user = TestUtilities.createAdminUser();
            this.accountsList = TestUtilities.createAccounts(250);
            this.accreditationsList = TestUtilities.createAccreditations(250, accountsList);
            this.accountCategoriesList = TestUtilities.createAccountCategoriess(250);
        }
    }

    public class ForReplicateAddress {
        public User user {get; set;}
        public List<Account> accountsList {get; set;}
        public List<Accreditation__c> accreditationsList {get; set;}
        public List<Account_Category__c> accountCategoriesList {get; set;}
        public List<GDP_Address__c> addressesList {get; set;}
        public ForReplicateAddress() {
            this.user = TestUtilities.createAdminUser();
            this.accountsList = TestUtilities.createAccounts(250);
            this.accreditationsList = TestUtilities.createAccreditations(250, accountsList);
            this.accountCategoriesList = TestUtilities.createAccountCategoriess(250);
            this.addressesList = TestUtilities.createAddresses(250);
        }
    }

    public class ForReplicateAffiliations {
        public User user {get; set;}
        public List<Account> accountsList {get; set;}
        public List<Accreditation__c> accreditationsList {get; set;}
        public List<Account_Category__c> accountCategoriesList {get; set;}
        public List<GDP_Address__c> addressesList {get; set;}
        public List<Assoc_Affiliation_Membership__c> affiliationMembershipsList {get; set;}
        public ForReplicateAffiliations() {
            this.user = TestUtilities.createAdminUser();
            this.accountsList = TestUtilities.createAccounts(250);
            this.accreditationsList = TestUtilities.createAccreditations(250, accountsList);
            this.accountCategoriesList = TestUtilities.createAccountCategoriess(250);
            this.addressesList = TestUtilities.createAddresses(250);
            this.affiliationMembershipsList = TestUtilities.createAffiliationMemberships(250);
        }
    }

    public class ForReplicateAdjacentAirports {
        public User user {get; set;}
        public List<Account> accountsList {get; set;}
        public List<Accreditation__c> accreditationsList {get; set;}
        public List<Account_Category__c> accountCategoriesList {get; set;}
        public List<GDP_Address__c> addressesList {get; set;}
        public List<Assoc_Affiliation_Membership__c> affiliationMembershipsList {get; set;}
        public List<Adjacent_Airport__c> adjacentAirportsList {get; set;}
        public ForReplicateAdjacentAirports() {
            this.user = TestUtilities.createAdminUser();
            this.accountsList = TestUtilities.createAccounts(250);
            this.accreditationsList = TestUtilities.createAccreditations(250, accountsList);
            this.accountCategoriesList = TestUtilities.createAccountCategoriess(250);
            this.addressesList = TestUtilities.createAddresses(250);
            this.affiliationMembershipsList = TestUtilities.createAffiliationMemberships(250);
            this.adjacentAirportsList = TestUtilities.createAdjacentAirports(250);
        }
    }

    public class ForReplicateAgencyOwner {
        public User user {get; set;}
        public List<Account> accountsList {get; set;}
        public List<Accreditation__c> accreditationsList {get; set;}
        public List<Account_Category__c> accountCategoriesList {get; set;}
        public List<GDP_Address__c> addressesList {get; set;}
        public List<Assoc_Affiliation_Membership__c> affiliationMembershipsList {get; set;}
        public List<Adjacent_Airport__c> adjacentAirportsList {get; set;}
        public List<Agency_Owner__c> agencyOwnersList {get; set;}
        public ForReplicateAgencyOwner() {
            this.user = TestUtilities.createAdminUser();
            this.accountsList = TestUtilities.createAccounts(250);
            this.accreditationsList = TestUtilities.createAccreditations(250, accountsList);
            this.accountCategoriesList = TestUtilities.createAccountCategoriess(250);
            this.addressesList = TestUtilities.createAddresses(250);
            this.affiliationMembershipsList = TestUtilities.createAffiliationMemberships(250);
            this.adjacentAirportsList = TestUtilities.createAdjacentAirports(250);
            this.agencyOwnersList = TestUtilities.createAgencyOwners(250);
        }
    }

    public class ForReplicatePhone {
        public User user {get; set;}
        public List<Account> accountsList {get; set;}
        public List<Accreditation__c> accreditationsList {get; set;}
        public List<Account_Category__c> accountCategoriesList {get; set;}
        public List<GDP_Address__c> addressesList {get; set;}
        public List<Assoc_Affiliation_Membership__c> affiliationMembershipsList {get; set;}
        public List<Adjacent_Airport__c> adjacentAirportsList {get; set;}
        public List<Agency_Owner__c> agencyOwnersList {get; set;}
        public List<GDP_Phone__c> gDPPhonesList {get; set;}
        public ForReplicatePhone() {
            this.user = TestUtilities.createAdminUser();
            this.accountsList = TestUtilities.createAccounts(250);
            this.accreditationsList = TestUtilities.createAccreditations(250, accountsList);
            this.accountCategoriesList = TestUtilities.createAccountCategoriess(250);
            this.addressesList = TestUtilities.createAddresses(250);
            this.affiliationMembershipsList = TestUtilities.createAffiliationMemberships(250);
            this.adjacentAirportsList = TestUtilities.createAdjacentAirports(250);
            this.agencyOwnersList = TestUtilities.createAgencyOwners(250);
            this.gDPPhonesList = TestUtilities.createGDPPhones(250);
        }
    }

    public class ForReplicateAgencyProfiles {
        public User user {get; set;}
        public List<Account> accountsList {get; set;}
        public List<Accreditation__c> accreditationsList {get; set;}
        public List<Account_Category__c> accountCategoriesList {get; set;}
        public List<GDP_Address__c> addressesList {get; set;}
        public List<Assoc_Affiliation_Membership__c> affiliationMembershipsList {get; set;}
        public List<Adjacent_Airport__c> adjacentAirportsList {get; set;}
        public List<Agency_Owner__c> agencyOwnersList {get; set;}
        public List<GDP_Phone__c> gDPPhonesList {get; set;}
        public List<GDP_Agency_Profile_Specialization__c> gDPAgencyProfileSpecializationsList {get; set;}
        public ForReplicateAgencyProfiles() {
            this.user = TestUtilities.createAdminUser();
            this.accountsList = TestUtilities.createAccounts(250);
            this.accreditationsList = TestUtilities.createAccreditations(250, accountsList);
            this.accountCategoriesList = TestUtilities.createAccountCategoriess(250);
            this.addressesList = TestUtilities.createAddresses(250);
            this.affiliationMembershipsList = TestUtilities.createAffiliationMemberships(250);
            this.adjacentAirportsList = TestUtilities.createAdjacentAirports(250);
            this.agencyOwnersList = TestUtilities.createAgencyOwners(250);
            this.gDPPhonesList = TestUtilities.createGDPPhones(250);
            this.gDPAgencyProfileSpecializationsList = TestUtilities.createGDPAgencyProfileSpecializations(250);
        }
    }

    public class ForIECGDPReplication {
        public User user {get; set;}
        public List<Account> accountsList {get; set;}
        public List<Accreditation__c> accreditationsList {get; set;}
        public List<Account_Category__c> accountCategoriesList {get; set;}
        public List<GDP_Address__c> addressesList {get; set;}
        public List<Assoc_Affiliation_Membership__c> affiliationMembershipsList {get; set;}
        public List<Adjacent_Airport__c> adjacentAirportsList {get; set;}
        public List<Agency_Owner__c> agencyOwnersList {get; set;}
        public List<GDP_Phone__c> gDPPhonesList {get; set;}
        public List<GDP_Agency_Profile_Specialization__c> gDPAgencyProfileSpecializationsList {get; set;}
        public ForIECGDPReplication() {
            this.user = TestUtilities.createAdminUser();
            this.accountsList = TestUtilities.createAccounts(250);
            this.accreditationsList = TestUtilities.createAccreditations(250, accountsList);
            this.accountCategoriesList = TestUtilities.createAccountCategoriess(250);
            this.addressesList = TestUtilities.createAddresses(250);
            this.affiliationMembershipsList = TestUtilities.createAffiliationMemberships(250);
            this.adjacentAirportsList = TestUtilities.createAdjacentAirports(250);
            this.agencyOwnersList = TestUtilities.createAgencyOwners(250);
            this.gDPPhonesList = TestUtilities.createGDPPhones(250);
            this.gDPAgencyProfileSpecializationsList = TestUtilities.createGDPAgencyProfileSpecializations(250);
        }
    }

    public class ForUpdateExpiryDate {
        public User user {get; set;}
        public List<Account> accountsList {get; set;}
        public List<Accreditation__c> accreditationsList {get; set;}
        public List<Account_Category__c> accountCategoriesList {get; set;}
        public List<GDP_Address__c> addressesList {get; set;}
        public List<Assoc_Affiliation_Membership__c> affiliationMembershipsList {get; set;}
        public List<Adjacent_Airport__c> adjacentAirportsList {get; set;}
        public List<Agency_Owner__c> agencyOwnersList {get; set;}
        public List<GDP_Phone__c> gDPPhonesList {get; set;}
        public List<GDP_Agency_Profile_Specialization__c> gDPAgencyProfileSpecializationsList {get; set;}
        public List<AMS_Agency__c> aMSAgenciesList {get; set;}
        public List<AMS_Inspection__c> aMSInspectionsList {get; set;}
        public List<AMS_Accreditation_Organization__c> aMSAccreditationOrganizationsList {get; set;}
        public IATA_ISO_Country__c country {get; set;}
        public ForUpdateExpiryDate() {
            this.user = TestUtilities.createAdminUser();
            this.country = TestUtilities.createCountry();
            this.accountsList = TestUtilities.createAccounts(250);
            this.accreditationsList = TestUtilities.createAccreditations(250, accountsList);
            this.accountCategoriesList = TestUtilities.createAccountCategoriess(250);
            this.addressesList = TestUtilities.createAddresses(250);
            this.affiliationMembershipsList = TestUtilities.createAffiliationMemberships(250);
            this.adjacentAirportsList = TestUtilities.createAdjacentAirports(250);
            this.agencyOwnersList = TestUtilities.createAgencyOwners(250);
            this.gDPPhonesList = TestUtilities.createGDPPhones(250);
            this.gDPAgencyProfileSpecializationsList = TestUtilities.createGDPAgencyProfileSpecializations(250);
            this.aMSAgenciesList = TestUtilities.createAMSAgencies(250, country);
            this.aMSInspectionsList = TestUtilities.createAMSInspections(250, aMSAgenciesList, accountsList);
            this.aMSAccreditationOrganizationsList = TestUtilities.createAMSAccreditationOrganizations(250, aMSAgenciesList, accountsList);
        }
    }
    
    public class ForBusinessLogic {
        public User user {get; set;}
        public List<Account> accountsList {get; set;}
        public List<Accreditation__c> accreditationsList {get; set;}
        public List<Account_Category__c> accountCategoriesList {get; set;}
        public List<GDP_Address__c> addressesList {get; set;}
        public List<Assoc_Affiliation_Membership__c> affiliationMembershipsList {get; set;}
        public List<Adjacent_Airport__c> adjacentAirportsList {get; set;}
        public List<Agency_Owner__c> agencyOwnersList {get; set;}
        public List<GDP_Phone__c> gDPPhonesList {get; set;}
        public List<GDP_Agency_Profile_Specialization__c> gDPAgencyProfileSpecializationsList {get; set;}
        public ForBusinessLogic() {
            this.user = TestUtilities.createAdminUser();
            this.accountsList = TestUtilities.createAccounts(250);
            this.accreditationsList = TestUtilities.createAccreditations(250, accountsList);
            this.accountCategoriesList = TestUtilities.createAccountCategoriess(250);
            this.addressesList = TestUtilities.createAddresses(250);
            this.affiliationMembershipsList = TestUtilities.createAffiliationMemberships(250);
            this.adjacentAirportsList = TestUtilities.createAdjacentAirports(250);
            this.agencyOwnersList = TestUtilities.createAgencyOwners(250);
            this.gDPPhonesList = TestUtilities.createGDPPhones(250);
            this.gDPAgencyProfileSpecializationsList = TestUtilities.createGDPAgencyProfileSpecializations(250);
        }
    }
}