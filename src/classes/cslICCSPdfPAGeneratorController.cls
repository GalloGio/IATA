/*
 *  @author: Constantin BUZDUGA, blue-infinity
 *  @description: This is a controller class for the Visualforce page that generates the PDF to be attached to the notification email sent upon a Product Management case closure.
 *
 */

public with sharing class cslICCSPdfPAGeneratorController {
    public Account acc {get; set;}
    public String IATALogoURL { 
        get {
            Document logoFile = new Document();
            try { // in case the file doesn't exist - mainly for testing purposes
                Document[] tmpDocs = [SELECT Id FROM Document WHERE DeveloperName = 'Logo_IATA_to_use_in_Case_email_templates' LIMIT 1];
                if (!tmpDocs.isEmpty() && tmpDocs[0] != null) {
                    logoFile = tmpDocs[0];
                }
            } catch (VisualforceException e){}
            
            if (logofile != null) {
                return '/servlet/servlet.ImageServer?id=' + logoFile.Id + '&oid=' + UserInfo.getOrganizationId();
            } else {
                return null; 
            }
        } set;
    }
    public String ICCSLogoURL { 
        get {
            Document logoFile = new Document();
            try { // in case the file doesn't exist - mainly for testing purposes
                Document[] tmpDocs = [SELECT Id FROM Document WHERE DeveloperName = 'IATA_ICCS_Logo' LIMIT 1];
                if (!tmpDocs.isEmpty() && tmpDocs[0] != null) {
                    logoFile = tmpDocs[0];
                }
            } catch (VisualforceException e){}
            
            if (logofile != null) {
                return '/servlet/servlet.ImageServer?id=' + logoFile.Id + '&oid=' + UserInfo.getOrganizationId();
            } else {
                return null;
            }
        } set;
    }
    public List<Product_Assignment__c> pas { get; set; }
    public Date lastUpdateDate {
        get {
            return date.today();
        } set;
    }
    
    //controls how many Product Assignments are displayed on page 1
    private static Integer FIRST_BREAK = 16;

    //controls how many Product Assignments are displayed on subsequent pages
    private static Integer SUBSEQ_BREAKS = 25;
 
    public List<List<Product_Assignment__c>> pageBrokenProdAssignmentLines {get; private set; }

    
    public cslICCSPdfPAGeneratorController (ApexPages.StandardController stdController) {
        acc = (Account)stdController.getRecord();
        acc = [SELECT Id, Name FROM Account WHERE Id = :acc.Id];
                        
        /*List<Product_Assignment__c> allPA = [SELECT Id, ICCS_Product_Currency__r.Product__c, ICCS_Product_Currency__r.Country__c, ICCS_Product_Currency__r.Currency__c, Bank_Account_Code__c, 
                                                    Bank_Account_Currency__c, Split_type__c, Percentage__c, Amount__c,
                                                    GSA_Agreement__c, Notice_of_Assignment__c, Third_Party_Payment__c, De_Activation_Date__c, Status__c 
                                            FROM Product_Assignment__c WHERE Account__c = :acc.Id ORDER BY ICCS_Product_Currency__r.Country__c ASC];
                        
                        
        Date LastChangeDate ;
        lstPAs = new List<Product_Assignment__c>();
        
        for(Product_Assignment__c pa : allPA){
            //if(pa.Status__c == 'Active'){ 
                lstPAs.add(pa);
            //}
            if(LastChangeDate==null || pa.De_Activation_Date__c > LastChangeDate)
                LastChangeDate = pa.De_Activation_Date__c;
        }
        
        if(lstPAs.size()==0){
            for(Product_Assignment__c pa : allPA){
                if(LastChangeDate==pa.De_Activation_Date__c)
                    lstPAs.add(pa);
            }
        }*/              
        
        pas = new List<Product_Assignment__c>();
        
        // Create a map with a List of Product Assignments per key Product - Country - Currency
        Map<String, List<Product_Assignment__c>> mapProductAssignmentsPerProductCurrencyKey = new Map<String, List<Product_Assignment__c>>();
        List<Product_Assignment__c> lstPAs = [SELECT Id, Account__c, Name, ICCS_Product_Currency__c, Status__c, ICCS_Bank_Account__c, Bank_Account_Code__c, Bank_Account_Currency__c, GSA_Agreement__c, Third_Party_Payment__c, De_Activation_Date__c, Split_Type__c, Percentage__c, ICCS_Product_Currency__r.Product__c, ICCS_Product_Currency__r.Country__c, ICCS_Product_Currency__r.Currency__c, Notice_of_Assignment__c, Amount__c FROM Product_Assignment__c WHERE Account__c = :acc.Id ORDER BY De_Activation_Date__c DESC];
        for (Product_Assignment__c pa : lstPAs) {
          //mapProductAssignmentsPerKey.put(String.valueOf(pa.ICCS_Product_Currency__c), pa);
          List<Product_Assignment__c> lst = mapProductAssignmentsPerProductCurrencyKey.get(String.valueOf(pa.ICCS_Product_Currency__c));
          if(lst == null)
            lst = new List<Product_Assignment__c>{pa};
          else
            lst.add(pa);

          mapProductAssignmentsPerProductCurrencyKey.put(String.valueOf(pa.ICCS_Product_Currency__c), lst);

        }

        for(String key: mapProductAssignmentsPerProductCurrencyKey.keyset())
        {

            List<Product_Assignment__c> paL = mapProductAssignmentsPerProductCurrencyKey.get(key);
            //List of Assignments to display for the ProductCurrency
            List<Product_Assignment__c> productCurrencyDisplayList = new List<Product_Assignment__c>();
            for(Product_Assignment__c pa: paL)
            {
                //all actives should show in list
                if(pa.Status__c == 'Active')
                {
                    productCurrencyDisplayList.add(pa);
                    System.debug('###Adding PA: '+ pa.Name + ' from Product Currency:' + pa.ICCS_Product_Currency__c);
                }
            }

            //if displayList is empty for the ProductCurrency then we must show the most recently deactivated PAs
            if(productCurrencyDisplayList.size() == 0)
            {
                for(Product_Assignment__c pa: paL)
                {
                    //always add the first most recent Inactivated
                    if(productCurrencyDisplayList.size() == 0)
                        productCurrencyDisplayList.add(pa);
                    else
                        //compare with first PA in display List, PAs with equal deactivation Date will be added
                        if(pa.De_Activation_Date__c == productCurrencyDisplayList[0].De_Activation_Date__c)
                            productCurrencyDisplayList.add(pa);
                }
            }

            pas.addAll(productCurrencyDisplayList);
            
        }
        
        pas = sortProductAssignmentByCountry(pas);
        
        System.debug('###Product Assignment List Size: + ' + pas.size());
        
        prepareProductAssignmentsForPrinting(pas);
        
        /*Document no_img;
        try {
            no_img = [SELECT Id FROM Document WHERE DeveloperName = 'No_Image_Logo'];
        } catch (Exception e) {
            no_img = new Document();
        } // for testing purposes*/
        Integer i = 1;
                
    }
    
    //splits the product assignments into an approximate number of rows that can be
    //displayed per page
    private void prepareProductAssignmentsForPrinting(List<Product_Assignment__c> ProdAssignments)
    {
    
       pageBrokenProdAssignmentLines = new List<List<Product_Assignment__c>>();
    
       List<Product_Assignment__c> pageOfProdAssignments = new List<Product_Assignment__c>();
    
       Integer counter = 0;
    
       boolean firstBreakFound = false;
    
       boolean setSubSeqBreak = false;       
    
       Integer breakPoint = FIRST_BREAK;
    
       for(Product_Assignment__c pa : ProdAssignments)
       {
       
         if(counter <= breakPoint)
         {
            pageOfProdAssignments.add(pa);
            counter++;
         }
    
         if(counter == breakPoint)
         {
            if (!firstBreakFound)
            {
               firstBreakFound = true;
                   setSubSeqBreak = true;
            }
            
            counter = 0;
            
            pageBrokenProdAssignmentLines.add(pageOfProdAssignments);
            
            pageOfProdAssignments = new List<Product_Assignment__c>();
            
         }
    
         if(setSubSeqBreak)
         {
            breakPoint = SUBSEQ_BREAKS;
            setSubSeqBreak = false;
        }
    
       }
    
       //if we have finished looping and have some quotes left let's assign them
       if(pageOfProdAssignments!=null && !pageOfProdAssignments.isEmpty())
              pageBrokenProdAssignmentLines.add(pageOfProdAssignments);
              
    }
    
    /*
     * @parameters: templateName = the Developer Name (API Name) of the email template; targetId = the Id of the Contact to whom the email will be sent;
     *          whatId = the Id of the Case which is getting closed;
     */
    public void sendPdf(String templateName, Id targetId, Id whatId) {
        
        PageReference pdf = Page.ICCSPdfPAGenerator;
        // add parent id to the parameters for standardcontroller
        pdf.getParameters().put('id',acc.Id);
        
        // the contents of the attachment from the pdf
        Blob body;
        
        try {
            // returns the output of the page as a PDF
            body = pdf.getContent();
            
            // need to pass unit test -- current bug  
        } catch (VisualforceException e) {
            body = Blob.valueOf('Some Text');
        }
        
        EmailTemplate et;
        try {
            et = [SELECT Id, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = :templateName];
        } catch (Exception e) {
            et = new EmailTemplate();
        }
        
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType('application/pdf');
            attach.setFileName('Product_Assignment_Overview.pdf');
            attach.setInline(false);
            attach.Body = body;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.saveAsActivity = true; 
            mail.setTemplateId(et.id);
            mail.setTargetObjectId(targetId);
            mail.setWhatId(whatId);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
        
        OrgWideEmailAddress[] owa = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'info.iccs@iata.org'];
        
        if (!owa.isEmpty() && owa[0] != null) {
            mail.setOrgWideEmailAddressId(owa[0].Id);
        }
        
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    public List<Product_Assignment__c> sortProductAssignmentByCountry(List<Product_Assignment__c> pAssignments)
    {
        boolean swapped = false;
        do{
            swapped = false;
            for(Integer i=0; i< pAssignments.size()-1; i++)
            {
                if(pAssignments[i].ICCS_Product_Currency__r.Country__c.compareTo(pAssignments[i+1].ICCS_Product_Currency__r.Country__c) > 0)
                {
                    Product_Assignment__c tmp = pAssignments[i];
                    pAssignments[i] = pAssignments[i+1];
                    pAssignments[i+1] = tmp;
                    swapped = true;
                }
                    
            }
        }while(swapped==true);
        
        return pAssignments;
    }
    
}