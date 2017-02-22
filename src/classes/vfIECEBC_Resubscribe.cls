public class vfIECEBC_Resubscribe {
    public String email {
        get {
            if (email == null) {
                email = IECUtil.DecryptParameter(ApexPages.currentPage().getParameters().get('e'));
            }
            return email;
        }
        set;
    }
    
    public String agencyCode { get; set; }
    public String fullName { get; set; }
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
        mail.setToAddresses(new List<String>{'debonol@iata.org','beausoleim@iata.org'});
        mail.setSubject('eBroadcast Resubscribe');
        String text = '';
        text += 'Agency Code: ' + agencyCode + '\n';
        text += 'Full Name: ' + fullName + '\n';
        text += 'New Email: ' + newEmail;
        mail.setPlainTextBody(text);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        PageReference pr = Page.IECEBC_PublicConfirmation;
        pr.setRedirect(true);
        pr.getParameters().put('e', ApexPages.currentPage().getParameters().get('e'));
        return pr;
    }
}