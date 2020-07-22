public class CW_ICG_Facility_Queuable implements Queueable, Database.AllowsCallouts {
    private Set<Id> objects;

    public CW_ICG_Facility_Queuable(Set<Id> objects) {
        if(objects != null && !objects.isEmpty()) {
            this.objects = objects;
        }  
    }
    //Execute list content one by one.
    public void execute(QueueableContext context) {
        if(this.objects != null && !this.objects.isEmpty()) {
            CW_ICG_Facility_Queuable.updateSearchByFormulaValues(this.objects);
        }
    }
    /**
     * @description		@future method to update search facilities´s fields based on formula fields
     * 
     * @param			List<Id> lstFacilities
     */
    private static void updateSearchByFormulaValues(Set<Id> lstFacilities) {
        List<ICG_Account_Role_Detail__c> ardFinal = new List<ICG_Account_Role_Detail__c>();
        List<ICG_Account_Role_Detail__c> ardToUpdate = [SELECT Id, Company_FOR__c, City_FOR__c, Country_FOR__c,
                                                        Search_By_City__c, Search_By_Company__c, Search_By_Country__c
                                                        FROM ICG_Account_Role_Detail__c
                                                        WHERE Id IN :lstFacilities];
        System.debug(LoggingLevel.FINE, 'updateSearchByFormulaValues.lstARDtoUpdate: ' + ardToUpdate);
        for(ICG_Account_Role_Detail__c facility : ardToUpdate) {
            Boolean toUpdate = false;
            if(facility.City_FOR__c != null 
                && (facility.Search_By_City__c != null
                    || facility.City_FOR__c.toLowerCase() != facility.Search_By_City__c.toLowerCase() )) {
                facility.Search_By_City__c = CW_ICGAccountRoleDetail_Handler.translationText(facility.City_FOR__c);
                toUpdate = true;
            }
            if(facility.Company_FOR__c != null 
                && (facility.Search_By_Company__c != null
                    || facility.Company_FOR__c.toLowerCase() != facility.Search_By_Company__c.toLowerCase() )) {
                facility.Search_By_Company__c = CW_ICGAccountRoleDetail_Handler.translationText(facility.Company_FOR__c);
                toUpdate = true;
            }
            if(facility.Country_FOR__c != null 
                && (facility.Search_By_Country__c != null
                    || facility.Country_FOR__c.toLowerCase() != facility.Search_By_Country__c.toLowerCase() )) {
                facility.Search_By_Country__c = CW_ICGAccountRoleDetail_Handler.translationText(facility.Country_FOR__c);
                toUpdate = true;
            }
            if(toUpdate) {
                ardFinal.add(facility);
            }
        }
        if (!ardFinal.isEmpty()) {
            Database.SaveResult [] updateResult = Database.update(ardFinal, false);
            System.debug(LoggingLevel.FINE, 'updateResult : ' + JSON.serialize(updateResult));
		}
    }
}