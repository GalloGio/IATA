public class localgroupTriggerHandler
{
    public List<LocalGovernance__c> getAllChildren(Id parentId, List<LocalGovernance__c> allGroups) {
        List<LocalGovernance__c> lsChildren = new List<LocalGovernance__c>();
        for(LocalGovernance__c l : allGroups) {
            if(l.Reporting_to__c == parentId) {
                lsChildren.add(l);
                lsChildren.addAll(getChildren(l.Id, allGroups));
            }
        }
        return lsChildren;
    }

    public List<LocalGovernance__c> getChildren(Id parentId, List<LocalGovernance__c> allGroups) {
        List<LocalGovernance__c> lsChildren = new List<LocalGovernance__c>();
        for(LocalGovernance__c l : allGroups) {
            if(l.Reporting_to__c == parentId) {
                lsChildren.add(l);
            }
        }
        return lsChildren;
    }

    public Boolean hasActiveGroups(List<LocalGovernance__c> lsGroups) {
        Boolean hasActive = false;
        for(LocalGovernance__c l : lsGroups) {
            if(l.Active__c) {
                hasActive = true;
                break;
            }
        }
        return hasActive;
    }
}
