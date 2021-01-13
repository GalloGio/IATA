public class ISSP_EditContact{

    public List<Contact> contactList {get;set;}
    public Contact Contact{get;set;}

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}

    
    public ISSP_EditContact(ApexPages.StandardController controller) {
        this.contact = (Contact)controller.getRecord(); 
    }


   
    
    public Pagereference SaveContact(){
        Pagereference p  = new Pagereference ('/apex/ISSP_Contact?Id='+contact.Id + commParam);
        p.setredirect(true);
        
        try{
            update Contact ;
        }catch (Exception e){
            System.debug('Error while updating Contact ==>'+e);
        }
        return p;
    }
    
    public Pagereference CancelContact(){
        Pagereference p  = new Pagereference ('/apex/ISSP_Contact?Id='+contact.Id + commParam);
        p.setredirect(true);
        return p;
    }
    
}