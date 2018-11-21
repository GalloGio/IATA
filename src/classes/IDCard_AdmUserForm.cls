public class IDCard_AdmUserForm extends IDCardAbstractController{
    public Contact loggedContact {get;set;}
    public Account mainAccount {get;set;}
    
    public boolean showNewContact{get;set;}
    public boolean showNewContactQuestion{get;set;}
    public boolean NewContactQuestionResult{get;set;}

    public List<SelectOption> packages {get;set;}
    public List<SelectOption> accountCodes {get;set;}
    public List<SelectOption> appTypes {get;set;}
    
    private static boolean requestTakenInCharge = false;
    
    private string adminName;
    private string adminEmail;
    
    public boolean moreThan1000Iatacodes {get;set;}
    public string ver;


    /* NEW VARIABLES */
    public boolean isNew{get;set;} // Creation of a new app
    public boolean isEditNew{get;set;} // Edit of an app with type = new
    public boolean isEdit{get;set;} // Edit of an app with another type
    public boolean isReplacement{get;set;}  // App with type replacement
    public ID_Card_Application__c app {get;set;}
    public ID_Card_Application__c oldapp {get;set;}


    public IDCard_AdmUserForm (){
            initialize(true);
            // Get the key contact
            try{
                loggedContact = [SELECT Name, Email, IDCard_Email__c, IATA_code__c, IDCard_Batch_Status__c, VER_Number_2__c
                                  FROM Contact 
                                  WHERE Id in (SELECT contact__c from Managed_agency__c where Account__r.IATACode__c = :iataCodeParameter)
                                  AND VER_Number_2__c = :vernumParameter
                              LIMIT 1];
                
                for(Managed_agency__c ma : keyContactAndDelegateForAccountList.values()){
                    if(ma.Account__r.IATAcode__c == iataCodeParameter){
                        mainAccount = ma.Account__r;
                        adminName = ma.Contact__r.Name;
                        adminEmail = ma.Contact__r.Email;
                    }
                }
            }catch(Exception e){                
                printErr('Login has expired. Please go back and login again.'+e.getMessage());
                return;
            }
            
            
            ver = ApexPages.currentPage().getParameters().get('ver');
            isReplacement = false;
            isEdit = ApexPages.currentPage().getParameters().get('edit')=='true';
            isEditNew = false;
            //////////////////////////////////////////////
            // CASE 1: NEW Contact -> show the question //
            if(string.isblank(ver)){
                showNewContactQuestion=true;
                showNewContact=false;
            ////////////////////////////////////////////////////////////////////////////
            // CASE 2: EDIT Contact -> retrieve and print all the contact information //
            }else{
                isNew = false;
                List<ID_Card_Application__c> pendingapps = [SELECT Name, Displayed_Name__c, Type_of_application__c, IATA_Code__c, Title__c, Date_of_birth__c, First_Name__c, Last_Name__c, Gender__c, 
                                                                    Email_admin__c, Telephone__c, Hours_worked__c, Position_in_Current_Agency__c, Duties_in_current_Agency__c, 
                                                                    Start_date_agency_month__c, Start_date_agency_year__c, Start_date_industry__c, VER_Number__c, UIR__c, Photo__c,
                                                                    Package_of_Travel_Professionals_Course_1__c, Package_of_Travel_Professionals_Course_2__c, IATA_Code_for_previous_agency__c
                                                            FROM ID_Card_Application__c 
                                                            WHERE VER_Number__c = :ver 
                                                            AND (Application_Status__c = : IDcardUtil.APPlICATIONSTATUS_PENDING
                                                                OR Application_Status__c = :IDcardUtil.APPlICATIONSTATUS_UNPAID)
                                                            ORDER BY CreatedDate DESC];
                if(pendingapps.size()>=1){
                    app = pendingapps[0];
                    oldapp = app.clone(true,true);
                    if(app.Type_of_application__c==IDCardUtil.APPLICATIONTYPE_NEW)
                        isEditNew = true;
                }else
                    printerr('Application not found');
                showNewContact=true;
                showNewContactQuestion=false;
            }
            

            packages = new List<SelectOption>(); 
            packages.add(new SelectOption('','--None--'));          
            for(Schema.PicklistEntry ple : ID_Card_Application__c.Package_of_Travel_Professionals_Course_1__c.getDescribe().getPicklistValues())
                packages.add(new SelectOption(ple.getValue(),ple.getLabel()));
            
            
            
            accountCodes = new List<SelectOption>();
             
            if(keyContactAndDelegateForAccountList.values().size()<=50){
                moreThan1000Iatacodes = false;
                accountCodes.add(new SelectOption('','--None--'));
                for(Managed_agency__c ma : keyContactAndDelegateForAccountList.values()){
                    accountCodes.add(new SelectOption(ma.Account__r.IATAcode__c, 'IATA Code:'+ma.Account__r.IATACode__c+' - '+ma.Account__r.Short_Name__c));
                }
                accountcodes.sort();
            }else{
                moreThan1000Iatacodes = true;
            }
            
            
            
            appTypes = new List<SelectOption>(); 
            appTypes.add(new SelectOption('','--None--'));
            for(Schema.PicklistEntry ple : ID_Card_Application__c.Type_of_application__c.getDescribe().getPicklistValues())
                appTypes.add(new SelectOption(ple.getValue(),ple.getLabel()));
            
            system.debug(LoggingLevel.ERROR,'============================= FINISH CONSTRUCTOR');     
    }
    
    
    public PageReference createOrChangeContact(){
        if(NewContactQuestionResult)
            return  Page.IDCard_AdmUserManagmentAgencyChange;
        else
            newContact();
        return null;
    }
    
    public void newContact(){
        Id rtsingleapp =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c','Single_ID_Card_Operation');
        showNewContact=true;
        showNewContactQuestion=false;
        app = new ID_Card_Application__c(RecordTypeId = rtsingleapp);
        isNew = true;
    }
    
    
    public void changeAgency(){
        boolean wasReplacement = isReplacement;
        isReplacement = (!isNew && oldapp.IATA_code__c != app.IATA_code__c);
        if(!wasReplacement && isReplacement){
            app.Start_Date_agency_month__c = '';
            app.Start_Date_agency_year__c = '';
        }else if(wasReplacement && !isReplacement){
            app.Start_Date_agency_month__c = oldapp.Start_Date_agency_month__c;
            app.Start_Date_agency_year__c = oldapp.Start_Date_agency_year__c;
        }
    }
    
    
    
    //////////////////////////
    ///// SAVE A CONTACT /////
    //////////////////////////
    public PageReference SaveContact(){
        boolean isCreation = (ver==null);
        boolean success = true;
        List<Account> accStatus;
        
        // ############ STEP 1: ###############
        // I check that all the required fields were filled with a proper value
        set<string> newFields = new set<string>{'Title__c','Email_admin__c','First_Name__c','Date_of_birth__c','Last_Name__c','IATA_Code__c',
                                               'Gender__c','Hours_worked__c','Position_in_Current_Agency__c','Duties_in_current_Agency__c',
                                               'Start_date_agency_month__c','Start_date_agency_year__c','Start_date_industry__c','Displayed_Name__c'};
        set<string> editFields = new set<string>{'Title__c','Email_admin__c','Last_Name__c','IATA_Code__c','Gender__c',
                                               'Hours_worked__c','Position_in_Current_Agency__c','Duties_in_current_Agency__c','Displayed_Name__c'};
        set<string> replacementFields = new set<string>{'Title__c','Email_admin__c','Last_Name__c','IATA_Code__c',
                                                       'Gender__c','Hours_worked__c','Position_in_Current_Agency__c','Duties_in_current_Agency__c',
                                                       'Start_date_agency_month__c','Start_date_agency_year__c','Displayed_Name__c'};
        
        set<String> requiredFields = isNew ? newFields : (isReplacement ? replacementFields : editFields);
        Map<String, Schema.SobjectField> allFields =ID_Card_Application__c.getSObjectType().getDescribe().fields.getMap();
        string missingFields = '';

        for(string field : requiredFields){
            if(app.get(field)==null){               
                missingfields += (missingfields=='' ? '' : ', ') + allFields.get(field).getDescribe().getLabel(); 
                success = false;
            }
        }        
        if(!success){
            printerr('A value is missing for the following fields: '+missingfields);
            //return null;
            success = false;
        }
        
        // Integrity checks on fields
        if(app.Date_of_birth__c > date.today().addYears(-18)){
            printErr('An empolyee must be at least 18 years old');
            success = false;
        }
        
        if(!keyContactAndDelegateForAccountList.keyset().contains(app.IATA_Code__c)){
            printErr('The IATA code inserted was not recognized.');
            system.debug(LoggingLevel.ERROR, '*********** SAVECONTACT() - IATA code not recognized = '+app.IATA_Code__c+' - the valid ones are '+keyContactAndDelegateForAccountList.keyset());
            success = false;
        }

        try{
            Integer year = Integer.valueOf(app.Start_date_agency_year__c);
            if(year>date.today().year()){
                printerr(Schema.SobjectType.ID_Card_Application__c.fields.Start_Date_Agency_year__c.label+': the year cannot be greater than '+date.today().year());
                success = false;
            }else if(year<app.Date_of_birth__c.year()){
                printerr(Schema.SobjectType.ID_Card_Application__c.fields.Start_Date_Agency_year__c.label+': the year cannot be lower than '+app.Date_of_birth__c.year());
                success = false;
            }
            
        }catch(Exception e){
            printerr(Schema.SobjectType.ID_Card_Application__c.fields.Start_Date_Agency_year__c.label+' : please insert a valid year.');
            success = false;
        }
        try{
            Integer year = Integer.valueOf(app.Start_date_industry__c);
            if(year>date.today().year()){
                printerr(Schema.SobjectType.ID_Card_Application__c.fields.Start_date_industry__c.label+': the year cannot be greater than '+date.today().year());
                success = false;
            }else if(year<app.Date_of_birth__c.year()){
                printerr(Schema.SobjectType.ID_Card_Application__c.fields.Start_date_industry__c.label+': the year cannot be lower than '+app.Date_of_birth__c.year());
                success = false;
            }
            
        }catch(Exception e){
            printerr(Schema.SobjectType.ID_Card_Application__c.fields.Start_date_industry__c.label+' : please insert a valid year.');
            success = false;
        }
        if((isNew || isEditNew) && 
           ((String.isEmpty(app.Package_of_Travel_Professionals_Course_1__c) && !String.isEmpty(app.Package_of_Travel_Professionals_Course_2__c)) || 
           (String.isEmpty(app.Package_of_Travel_Professionals_Course_2__c) && !String.isEmpty(app.Package_of_Travel_Professionals_Course_1__c)))){
            
            printerr('It is not possible to select only one package.');
            success = false;
        }if(app.Hours_worked__c == 'Less than 20 h'){
            printerr(Schema.SobjectType.ID_Card_Application__c.fields.Hours_worked__c.label+': employee must work more than 20 hours per week to obtain an ID Card');
            success = false;
        }
         accStatus = [SELECT Status__c from Account where IATACode__c = :app.IATA_Code__c LIMIT 1];
         if(!accStatus.isEmpty() && accStatus[0].Status__c == IDCardUtil.ACCOUNT_STATUS_TERMINATED){
            String addIATACodeToLabel = Label.IDCard_Error_Message_Terminated_Account;
            addIATACodeToLabel = addIATACodeToLabel.replace('{iata_code}',app.IATA_Code__c);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,addIATACodeToLabel));
            success = false;
         }

         // The name displayed on ID Card must not contain any special characters
         if (!Test.isRunningTest()){
            if (app.Displayed_Name__c != null && app.Displayed_Name__c != '') {
              //pattern fullNamePattern = pattern.compile('[[\\x30-\\x39][\\x41-\\x5a][\\x61-\\x7a]- ]+');

              //remove accents
              app.Displayed_Name__c = IDCardUtil.deAccent(app.Displayed_Name__c);
              
              pattern fullNamePattern = pattern.compile('[^a-zA-Z - ,.]');
              Matcher fullNameMatcher = fullNamePattern.matcher(app.Displayed_Name__c);
              if (fullNameMatcher.find()) {
                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ID_Card_DisplayName_Business_Rule));
                 success = false;
              }
            }
        }
         
         if(success == false)
            return null; 
        
        
        // Set status and type on the application 
        
        // If I am creating or editing a new application type == NEW
        if(isNew || oldapp.Type_of_application__c==IDCardUtil.APPLICATIONTYPE_NEW)
            app.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_NEW;
        
        // If I am creating or editing a renew / reissue / replacement      
        else{
            String originalIATAcode = oldapp.Type_of_application__c==IDCardUtil.APPLICATIONTYPE_REPLACEMENT ? 
                                      oldapp.IATA_Code_for_previous_agency__c : 
                                      oldapp.IATA_Code__c;
            // If the iata code is different from the original -> REPLACEMENT
            if(app.IATA_Code__c != originalIATAcode){
                app.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_REPLACEMENT;
                app.IATA_Code_for_previous_agency__c = originalIATAcode;
            // If it's the same I should put type = RENEW or REISSUE
            }else{
                app.IATA_Code_for_previous_agency__c = null;
                // If I am creating or editing a renew / reissue app, I put the oldapp's type
                if(oldapp.Type_of_application__c != IDCardUtil.APPLICATIONTYPE_REPLACEMENT){
                    app.Type_of_application__c = oldapp.Type_of_application__c;
                // If I am editing an app replacement I need to look at the validity date of the last active idcard to choose between RENEW / REISSUE
                }else{
                    ID_Card__c card = getLastIDCard([SELECT Valid_To_Date__c, Card_Status__c FROM ID_Card__c WHERE VER_Number__c = :app.VER_Number__c]);
                    app.Type_of_application__c = card.Valid_To_Date__c>date.today().addMonths(-3) ? 
                                                 IDCardUtil.APPLICATIONTYPE_REISSUE : 
                                                 IDCardUtil.APPLICATIONTYPE_RENEWAL;
                }
            }       
        }
        app.Application_Status__c = IDCardUtil.APPLICATIONSTATUS_PENDING;
        app.Displayed_Name__c = IDCardUtil.calculateDisplayedName(app.First_Name__c, '', app.Last_Name__c);
        // Calculate fees
        Account myAcc = keyContactAndDelegateForAccountList.get(app.IATA_code__c).Account__r;
        try{
            app = IDCardApplicationFactory.applyApplicationFees(app,myacc,null);
        }catch(Exception e){
            printerr('An error occurred while processing your application ('+e.getMessage()+'). Please kindly contact ID Card Team (iataglobalidcardprogram@iata.org) for more information.');
            return null;
        }
        
system.debug(LoggingLevel.ERROR,'------- FINE STEP 1');      
        
        // ############ STEP 2: ###############
        // If it's a creation or name/surname/birthdate changed, I want to be sure that I'm not creating a duplicate
        if(isNew || oldapp.Last_Name__c!=app.Last_Name__c){
            
            // CASE 1:
            // There is already a contact with one or more id cards. The most recent card is active or blacklisted --> ERROR!!
            Map<String,ID_Card__c> VERtoLastIDC = new Map<String,ID_Card__c>();
            for(ID_Card__c card : [SELECT VER_Number__c, Valid_To_Date__c, Card_Status__c, Blacklisted__c, Name_on_ID_card__c
                                    FROM ID_Card__c 
                                    WHERE Related_Contact__r.FirstName = :app.First_Name__c AND Related_Contact__r.LastName = :app.Last_Name__c  
                                          AND Related_Contact__r.Date_of_Birth__c = :app.Date_of_Birth__c
                                    ORDER BY VER_Number__c, Valid_To_Date__c]){
                if(VERtoLastIDC.get(card.VER_Number__c)==null || VERtoLastIDC.get(card.VER_Number__c).Valid_To_Date__c < card.Valid_To_Date__c)
                    VERtoLastIDC.put(card.VER_Number__c, card);                     
            }
                                      
            for(ID_Card__c card : VERtoLastIDC.values()){
                /*if(card.Blacklisted__c==true){
                    printerr('The applicant '+card.Name_on_ID_card__c+' existed and has been deleted so it\'s not possible to create it again. Please contact your key contact for more details ('+adminName+': '+adminEmail+').');
                    success = false;
                }else if(card.Blacklisted__c==true || (card.Card_Status__c==IDCardUtil.CARDSTATUS_APPROVED && card.Valid_To_Date__c<=date.today())){
                    printerr('The applicant '+card.Name_on_ID_card__c+' already exists and has an active ID card');
                    success = false;
                }*/
                printerr('There is an existing record with the same name and date of birth. Please kindly contact ID Card Team (iataglobalidcardprogram@iata.org) for more information.');
                return null;
            }
            
            
system.debug(LoggingLevel.ERROR,'------- FINE STEP 2 - Caso 1');
system.debug(LoggingLevel.ERROR,'------- INIZIO STEP 2 - Caso 2 - '+app.First_Name__c+', '+app.Last_Name__c+', '+app.Date_of_Birth__c );            
            // CASE 2:
            // There is already an application pending for the same contact --> ERROR!!
            for(ID_Card_Application__c idca : [SELECT VER_Number__c, Application_Status__c, Displayed_Name__c, Type_of_application__c
                                                FROM ID_Card_Application__c 
                                                WHERE First_Name__c = :app.First_Name__c AND Last_Name__c = :app.Last_Name__c 
                                                      AND Date_of_Birth__c = :app.Date_of_Birth__c 
                                                      AND (Application_Status__c = :IDcardUtil.APPLICATIONSTATUS_PENDING 
                                                            OR Application_Status__c = :IDCardUtil.APPLICATIONSTATUS_UNPAID
                                                            OR Mass_order_Application__r.Application_Status__c = :IDcardUtil.APPLICATIONSTATUS_PENDING)]){
                printerr('There is an existing record with the same name and date of birth. Please kindly contact ID Card Team (iataglobalidcardprogram@iata.org) for more information.');
                return null;                                                
            }

system.debug(LoggingLevel.ERROR,'------- FINE STEP 2 - Caso 2');        
            
        }
        
        
        // If the new app has not a VER (type=new without duplicates) I'll generate it
        if(isNew){ 
            app.VER_Number__c = IDCardUtil.generateTMPVER(myAcc);
         // SALVO   throw new transformationException(' app.VER_Number__c   '   +   app.VER_Number__c );
            //nc.c.UIR__c = IDCardUtil.generateTMPUIR(myAcc);
        }
        
        
system.debug(LoggingLevel.ERROR,'------- FINE STEP 2');        
        // ############ STEP 3: ###############
        // If it's a creation or email has changed, I want to be sure that I'm not creating a duplicate
 system.debug(LoggingLevel.ERROR,'------- INIZIO STEP 3 (email = '+app.Email_admin__c+')');            
        if(isNew || oldapp.Email_admin__c != app.Email_admin__c){
            for(Contact sameemail : [SELECT Email,Name,VER_Number_2__c 
                                     FROM Contact 
                                     WHERE Email = :app.Email_admin__c 
                                     AND VER_Number_2__c <> :app.VER_Number__c]){
                printErr('The email address '+app.Email_admin__c+' is already used by the employee '+sameemail.Name);
                success = false;
                system.debug(LoggingLevel.ERROR, '*********** SAVE() block a duplicate mail  '+app.Email_admin__c);
            }
        }
        if(!success)
            return null;        
 system.debug(LoggingLevel.ERROR,'------- FINE STEP 3');       

        
        // ############ STEP 4: ###############
        // Now I can finally save the application!
        database.UpsertResult result = database.upsert(app);
        if(!result.isSuccess()){
            printErr('An error occurred. Please contact your key contact ('+adminName+': '+adminEmail+').'+result.getErrors()[0].getMessage() );
            return null;
        }

        return Page.IDcard_AdmUserList;     
        
        //If i arrive from the picture page then I lost every variable concerning the old status!
        //if(oldemail==null)
        //    EditContact();
        
        // If I am changing the email of the contact I must check that it wasn't the primary contact using that address.
        // In this case I look for one of the secondary contacts and I make it primary
        //
        // Contact      Email   IDcard_Email__c                                 Contact         Email   IDcard_Email__c 
        // C1           email   email                                                C1      email2     email2
        // C2                           email                           --->         C2                     email
        // C3                           email                                        C3                                      email
        /*
        if(success && !isCreation && oldcp.c.email!=nc.c.email && !String.isBlank(oldcp.c.IDCard_Email__c)){
                try{
                        Contact cwithidcardemail = [SELECT Email, IDCard_email__c FROM Contact WHERE IDcard_Email__c = :oldcp.c.email AND Email = null ];
                        cwithidcardemail.Email = cwithidcardemail.IDCard_email__c;
                        update cwithidcardemail;
                }catch(Exception e){
                        system.debug('ERROR when trying to save a contact using the sam');
                }
        }
        if(!success){
            return null;
        }
        */
    }
    
    
    public string getImageLink(){
        if(app == null) return '';
        string ver = app.VER_Number__c;
        return IDCardUtil.EncryptEncodeParameter(ver).replaceAll('%', '%25');
    }
    
    public boolean getHasPhoto(){
        return app==null ? false : !String.isEmpty(app.Photo__c);
    }

    
    public Pagereference Cancel(){
        if(!isNew && !isEdit)
            delete app;
        return isEdit ? Page.IDCard_AdmPendingOps : Page.IDCard_AdmUserList;
    }


    
    
    public void printErr(String message){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,message));
    }

    public ID_Card_Application__c createApplication(Contact c, Account a, string appType,string packageTravel1, string packageTravel2){
        ID_Card_Application__c idcapp = IDCardApplicationFactory.createIDCardApplication(c,appType);
        idcapp.Package_of_Travel_Professionals_Course_1__c = packageTravel1;
        idcapp.Package_of_Travel_Professionals_Course_2__c = packageTravel2;
        idcapp = IDCardApplicationFactory.applyApplicationFees(idcapp,a,null);
        return idcapp;
    }
    
    
    public ID_Card__c getLastIDCard(List<ID_Card__c> cards){
        ID_Card__c card;
        for(ID_Card__c c : cards){
            if(card == null ||
               (c.Valid_To_Date__c > card.Valid_To_Date__c))
                card = c;
        }
        return card;
    }
  
}