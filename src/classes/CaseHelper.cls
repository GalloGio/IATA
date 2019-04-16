public with sharing class CaseHelper {

	public static Profile currentUserProfile{
        get{
            if(currentUserProfile == null){
                currentUserProfile = [SELECT ID, Name FROM Profile WHERE id = :UserInfo.getProfileId() limit 1];
            }
            return currentUserProfile;
        }
        set{}
    }

    public static List<EmailTemplate__c> IFAPemailtemplate{
        get{
            if(IFAPemailtemplate == null){
                IFAPemailtemplate = [SELECT et.IATA_ISO_Country__r.Id FROM EmailTemplate__c et WHERE et.recordType.Name = 'IFAP'];
            }
            return IFAPemailtemplate;
        }
        set{}
    }

    public static Boolean isIfapAuthorizedUser{
        get{
            if(isIfapAuthorizedUser == null){
                List<PermissionSetAssignment> psa = [SELECT AssigneeId FROM PermissionSetAssignment WHERE Assignee.IsActive = true 
                                                      AND AssigneeId = :UserInfo.getUserId() AND PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name = 'IFAP_Authorized_Users')];
                isIfapAuthorizedUser = !psa.isEmpty();
            }
            return isIfapAuthorizedUser;
        }
        set{}
    }

    public static BusinessHours bHourObj{
        get{
            if(bHourObj == null){
                bHourObj = [SELECT id, name FROM BusinessHours WHERE name = : 'EUR - France'];
            }
            return bHourObj;
        }
        set{}
    }
}