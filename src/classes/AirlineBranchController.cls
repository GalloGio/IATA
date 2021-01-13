public class AirlineBranchController {


public String parentAccountId {
get;
set{parentAccountId =value;AirlineBranchController();}
}
 
 

  public List<Services_Rendered__c> servicesList {get; set;}

     // the current sort direction. defaults to asc
    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
        set;
    }
 
    // the current field to sort by. defaults to account Name
    public String sortField {
        get  { if (sortField == null) {sortField = 'service.Services_Rendered_Type__c'; } return sortField;  }
        set;
    }
    
    public void AirlineBranchController() {
   


       servicesList = [Select
             // iso_country__c,
             ISO_Country_formula__c,bsp_country__c, cass_country__c,
             Services_Rendered_to_Airline__r.Name,
             GSA_Type__c,
             Services_Rendered_Status__C,
             Services_Rendered_to_Airline__r.Parent.id,
             Services_Rendered_to_Airline__r.Parent.Name,
             Services_Rendered_to_Airline__r.BillingCountry,
             Services_rendered_By__r.Name,Services_rendered_By__r.Parent.id, 
             Services_Rendered_Type__c, Services_Rendered_By__r.billingcountry,
              Name, Services_Rendered_By__r.Services_Rendered_Country__c,
              Services_Rendered_By__r.Services_Rendered_Country_GSA__c,
              ANG_IATA_EasyPay_Opt_out__c
               from Services_Rendered__c 
               where 
               (Services_Rendered_To_Airline__c =: +parentAccountId 
               or Services_Rendered_To_Airline__r.Parentid =: +parentAccountId 
               or Services_rendered_By__r.Parent.id =: +parentAccountId 
               or Services_rendered_By__c =: +parentAccountId) 
               order by Services_Rendered_Type__c asc/* and gsa_type__c = ''*/];          
         
             

             

    }


 

}