public class vfIECEBC_Resubscribe {
   
   public string test {get;set;}

public String email {
        get {
            if (email == null) {
                
                if(ApexPages.currentPage().getParameters().get('e') != null){
                    email = IECUtil.DecryptParameter(ApexPages.currentPage().getParameters().get('e'));
                }else{
                    email = ApexPages.currentPage().getParameters().get('email');
                }                
                
            }
            return email;
        }
        set;
    }

    public String agencyCode {get;set;}

    public String personName {get;set;}       
    
    public String fullName {get;set;}

    public String newEmail {
        get {
            if (newEmail == null) newEmail = email;
            return newEmail;
        }
        set;
    }

    public PageReference cancel() { return null; }

    public PageReference subscribe() {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id,DisplayName from OrgWideEmailAddress where DisplayName = 'IATA Global Data'];
        //mail.setToAddresses(new List<String>{'debonol@iata.org','beausoleim@iata.org'});
        mail.setOrgWideEmailAddressId(owea.get(0).Id);
        mail.setToAddresses(new List<String>{'globaldata@iata.org'}); 
        mail.setccAddresses(new List<String>{'debonol@iata.org'});        
        mail.setSubject('eBroadcast Resubscribe');

        
        String text = '';        
        text += '<b>eBroadcast Resubscribe Request</b><br><br>';        
        text += 'Your First and Last Name: ' + personName + '<br>';
        text += 'Agency IATA Code: ' + agencyCode + '<br>';
        text += 'Agency Name: ' + fullName + '<br>';
        text += 'New Email: ' + newEmail;
        mail.setHtmlBody(text);        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        PageReference pr = Page.IECEBC_PublicConfirmation;
        pr.setRedirect(true);
        pr.getParameters().put('isFromResubscribe','true');
        pr.getParameters().put('e', ApexPages.currentPage().getParameters().get('e'));        
        return pr;
    }
}