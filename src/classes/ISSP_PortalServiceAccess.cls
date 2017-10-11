/**
 * Created by Jiryes 11/05/2015
 */

public class ISSP_PortalServiceAccess{

    public Portal_Application_Right__c PortalServiceAccess {get;set;}
    public List<Portal_Application_Right__c> PortalServiceAccess_List {get;set;}

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
     
    public ISSP_PortalServiceAccess(){
    
        string psaId = Apexpages.currentPage().getParameters().get('id');

        PortalServiceAccess_List = new List<Portal_Application_Right__c>([Select p.Name,p.Application_Name__c,p.Portal_Application__r.Description__c,p.Portal_Application__r.Requestable__c,p.Application_icon_del__c, p.Portal_Application__r.New_Window__c,p.Right__c, p.Portal_Application__r.Application_icon_URL__c, p.Portal_Application__r.Name, p.Portal_Application__c, p.My_Apps__c, p.Contact__c,p.Contact__r.Name, p.Application_Start_URL__c ,p.Case_creation_record_Type__c, p.Access_Status_Reason__c
                                                                                               From Portal_Application_Right__c p 
                                                                                               where p.Id = : psaId]); 
        if( PortalServiceAccess_List != null && PortalServiceAccess_List .size() > 0){
            PortalServiceAccess =PortalServiceAccess_List[0];
        }
    }
}