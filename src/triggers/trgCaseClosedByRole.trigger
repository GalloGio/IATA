/**
    This trigger only updates Closed_by_Role__c for all cases (no matter the recordtype)
    Every time a case is closed
**/
trigger trgCaseClosedByRole on Case (before insert, before update) {

    // get user profile and role
    /*
    Profile profile = [Select Name from Profile where id =:UserInfo.getProfileId()];
    String profileName = profile==null? '': profile.Name;
    UserRole role = [Select Name from UserRole where id = :UserInfo.getUserRoleId()];
    String roleName = role==null? '': role.Name;
    */

    User user = [Select Profile.Name, UserRole.Name from User where Id = :UserInfo.getUserId()];
    String profileName = user.Profile.Name;
    String roleName = user.UserRole.Name;


    // Get value to put in Closed_by_Role__c field
    String ClosedByRoleValue = '';
    if ( profileName.contains('ISS Portal')) ClosedByRoleValue = 'IATA Partner';
    else if ( profileName.contains('IATA Portal1389712205152 Profile')) ClosedByRoleValue = 'IATA Partner';
    else if ( profileName.contains('Hub MGR AM/ARM')) ClosedByRoleValue = 'Agency Management';
    else if ( profileName.contains('Hub Staff AM')) ClosedByRoleValue = 'Agency Management';
    else if ( profileName.contains('Hub Staff ARM')) ClosedByRoleValue = 'Risk Management';
    else if ( profileName.contains('Hub Staff R&S')) ClosedByRoleValue = 'Remittance & Settlement';
    else if ( profileName.contains('Hub CS Management')) ClosedByRoleValue = 'Customer Service';
    else if ( profileName.startsWithIgnoreCase('IDFS Americas - Hub Staff')) ClosedByRoleValue = 'Customer Service';
    else if ( roleName.contains('Banking')) ClosedByRoleValue = 'Banking';
    else if ( roleName.contains('Business Delivery')) ClosedByRoleValue = 'Business Delivery';
    else if ( roleName.contains('I&C')) ClosedByRoleValue = 'Invoicing & Collection';
    else if ( roleName.contains('Operations Manager')) ClosedByRoleValue = 'Operations';
    else if ( roleName.contains('Operations Staff')) ClosedByRoleValue = 'Operations';
    else if ( roleName.contains('Operational Management')) ClosedByRoleValue = 'Operations';
    else if ( profileName.contains('Coding and MITA')) ClosedByRoleValue = 'Coding & MITA';
    else if ( roleName.contains('Distribution - Airline Management')) ClosedByRoleValue = 'Airline Management';
    else ClosedByRoleValue = 'IATA Other';

    // get all case statuses that means a case is closed
    set<String> setClosedStatus = new set<String>();
    for (CaseStatus cstatus: [Select Id, MasterLabel From CaseStatus Where IsClosed = true] ) {
        setClosedStatus.add(cstatus.MasterLabel);
    }

    // Update Closed_by_Role__c when case is closed
    for (Case caseNew: Trigger.new) {
        Case caseOld = Trigger.old== null? null: Trigger.oldmap.get(caseNew.Id);
        if ( setClosedStatus.contains(caseNew.Status)
            && (caseOld == null || caseOld.isClosed==false) ) {
            caseNew.Closed_by_Role__c = ClosedByRoleValue;
        }
    }



}
