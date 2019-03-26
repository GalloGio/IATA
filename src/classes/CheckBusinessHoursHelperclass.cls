/**
    This class handles trigger actions for trgCheckBusinessHoursBeforeInsert trigger
**/
public with sharing class CheckBusinessHoursHelperclass {
  /*recordtype*/
  public static ID sisHelpDeskCaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_SIS_Help_Desk');
  
  /*variable*/
  public static string caseArea, defect, cPriority, KeyString;
  
    public static void trgCheckBusinessHoursBeforeInsert(list<Case> listNewCases, Map<string,Contact> CBHContactMap, Map<string,Account> CBHAccountMap) {
        Blob descDetails = null;
        BusinessHours bHour = null;
        boolean isExcluded = false;  
        list < Case > parentCaseNumber = new List < Case > ();
        list < Case > CasesToUpdate = new list < Case > ();
        list < Case > CasesToUpdateForStatus = new list < Case > ();
        list < string > ListOfKaleCases = new list < string > ();
        Map < string, Case > parentCases = new Map < string, Case > ();
        Map < string, Case > KaleCases = new Map < string, Case > ();
        List < Priority_Mapping__c > priorityMappingListSIS;
        List < Priority_Mapping__c > priorityMappingListICH;
        List < ExcludedEmailFromAddress__c > ListOfExcludedAddress = new list <ExcludedEmailFromAddress__c>();
        List < ExcludedCaseSubject__c > ListOfExcludedSubjectd = new list <ExcludedCaseSubject__c>();
        Boolean isPM_SIS_Not_Initialized = true;
        Boolean isPM_ICH_Not_Initialized = true;
        Boolean CheckerIN = false;
        
        for (Case newCaseObj: listNewCases){
            if (((newCaseObj.CaseArea__c != null && newCaseObj.CaseArea__c == Label.SIS) 
                    || (newCaseObj.description != null && newCaseObj.description.contains(Label.Case_Area_SIS)) 
                    || (newCaseObj.CaseArea__c != null && newCaseObj.CaseArea__c == Label.ICH) 
                    || (newCaseObj.RecordTypeId != null && newCaseObj.RecordTypeId == sisHelpDeskCaseRecordTypeID))){
                String kaleCaseNumberStr = null;
                String sfCaseNumber = null;
                if (newCaseObj.Subject != null && newCaseObj.Subject.contains(Label.doubleHash)){
                    kaleCaseNumberStr = newCaseObj.Subject.split(Label.doubleHash)[1].trim(); // the case number is in index 1
                    // get SalesForce case number from the case subject
                    sfCaseNumber = EscalatedCaseHelper.extractSFCaseNumberFromSubject(newCaseObj.Subject);
                    if (sfCaseNumber != null){
                        ListOfKaleCases.add(sfCaseNumber);
                    }
                }
            }
        }
        if (!ListOfKaleCases.isEmpty()){
            for (Case cObj: [Select id, CaseNumber, External_Reference_Number__c, Kale_Status__c, Description from Case where CaseNumber in : ListOfKaleCases]){
                KaleCases.put(cObj.CaseNumber, cObj);
            }
        }

        for (Case CHECKCaseObj: listNewCases){
            if(CHECKCaseObj.SuppliedEmail == System.Label.KALE_SUPPORT_EMAIL){
                 CheckerIN = true;
                 break;
            }
        }
        if(CheckerIN){
            ListOfExcludedAddress = [SELECT Name, ApplicationName__c From ExcludedEmailFromAddress__c WHERE ApplicationName__c = : Label.ANY OR ApplicationName__c = : Label.SIS];
            ListOfExcludedSubjectd = [SELECT Name, Application_Name__c From ExcludedCaseSubject__c WHERE Application_Name__c = : Label.ANY OR Application_Name__c = : Label.SIS];
        }
        for (Case newCaseObj: listNewCases){
            if (newCaseObj.CaseArea__c != null && newCaseObj.CaseArea__c == Label.SIS && newCaseObj.Status == Label.Escalated && (newCaseObj.Assigned_To__c != Label.SIS_Help_Desk_Agent 
                  && newCaseObj.Assigned_To__c != Label.SIS_Operations && newCaseObj.Assigned_To__c != Label.SIS_L2_Customer_Support)){
                
                Account theAccount = CBHAccountMap.get(newCaseObj.Assigned_To__c);
                if (theAccount <> null){
                    system.debug('\nnewCaseObj.Assigned_To__c:_' + newCaseObj.Assigned_To__c + '_');
                    newCaseObj.L2_Support_Team_Account__c = string.valueOf(theAccount.Id);
                }
                Contact theContact = CBHContactMap.get(newCaseObj.L2_Support_Team_Account__c);
                if (theContact <> null) 
                    newCaseObj.L2_L3_Support_Owner__c = string.valueOf(theContact.Id);
            }
            if ((newCaseObj.CaseArea__c != null && newCaseObj.CaseArea__c == Label.SIS) || (newCaseObj.description != null && newCaseObj.description.contains(Label.Case_Area_SIS))){
                //Set SIS Help Desk Business Hours
                caseArea = Label.SIS;
                bHour = clsCheckBusinessHours.getBusinessHours(Label.SIS_Help_Desk);
                newCaseObj.BusinessHoursId = bHour.Id;
                if (newCaseObj.RecordTypeId == null){
                    newCaseObj.classification_SIS__C = newCaseObj.Classification__c;
                }
            }
            if ((newCaseObj.CaseArea__c == Label.SIS && newCaseObj.RecordTypeId == null) || (newCaseObj.description != null && newCaseObj.description.contains(Label.Case_Area_SIS))){
                if (isPM_SIS_Not_Initialized){
                    //Initialisation of variables needed for Before Insert           
                    priorityMappingListSIS = [SELECT Case_Classification__c, Case_Type__c, Case_Reason__c, Priority__c FROM Priority_Mapping__c WHERE Application__c = : Label.SIS_Help_Desk];
                    isPM_SIS_Not_Initialized = false;
                }
                clsCheckBusinessHours.priorityMappings = priorityMappingListSIS;
                System.debug('Priority Mapping List Size = ' + priorityMappingListSIS.size());
                // Assign Case Priority - for Web2Case with attachments 
                if (newCaseObj.suppliedemail != null && newCaseObj.suppliedemail != EscalatedCaseHelper.KALE_SUPPORT_EMAIL && newCaseObj.description != null && newCaseObj.description.contains(Label.Case_Area_SIS)){
                    newCaseObj.CaseArea__c = Label.SIS;
                    newCaseObj.origin = Label.Web;
                    descDetails = Blob.valueOf(newCaseObj.description);
                    newCaseObj.Type = clsCheckBusinessHours.getWebFieldValue(Label.Case_Type, Label.Case_Classification, descDetails);
                    newCaseObj.classification_SIS__C = clsCheckBusinessHours.getWebFieldValue(Label.Case_Classification, Label.Case_Defect_Issue, descDetails);
                    defect = clsCheckBusinessHours.getWebFieldValue(Label.Case_Defect_Issue, Label.Browser_type, descDetails);
                    newCaseObj.Defect_Issue__c = defect;
                    cPriority = clsCheckBusinessHours.getCasePriority(newCaseObj);
                    // Get web details and update web company, web IATA code, web name, web phone, browser type 
                    newCaseObj.Browser_Type__c = clsCheckBusinessHours.getBrowserType(descDetails);
                }
                if (newCaseObj.suppliedemail != null && newCaseObj.suppliedemail != EscalatedCaseHelper.KALE_SUPPORT_EMAIL && newCaseObj.CaseArea__c == Label.SIS && newCaseObj.RecordTypeId == null){
                    cPriority = clsCheckBusinessHours.getCasePriority(newCaseObj);
                }
                if (cPriority != null){
                    newCaseObj.assigned_to__c = Label.SIS_Help_Desk_Agent;
                    newCaseObj.Status = Label.Open;
                    newCaseObj.Priority = cPriority;
                    newCaseObj.RecordTypeId = sisHelpDeskCaseRecordTypeID;
                }
            }
            //ICH web-to-case
            if ((newCaseObj.CaseArea__c == Label.ICH && newCaseObj.RecordTypeId == null) 
                    || (newCaseObj.CaseArea__c == Label.ICH && newCaseObj.RecordTypeId == sisHelpDeskCaseRecordTypeID) 
                    || (newCaseObj.description != null && newCaseObj.description.contains(Label.Case_Area_ICH))){
                //kareem ich get priority list
                if (isPM_ICH_Not_Initialized){ //Only do once
                    //Initialisation of variables needed for Before Insert           
                    priorityMappingListICH = [SELECT Case_Classification__c, Case_Type__c, Case_Reason__c, Priority__c FROM Priority_Mapping__c WHERE Application__c = : Label.ICH_Help_Desk];
                    isPM_ICH_Not_Initialized = false;
                }
                clsCheckBusinessHours.priorityMappings = priorityMappingListICH;
                System.debug('Priority Mapping List Size = ' + priorityMappingListICH.size());
                if (newCaseObj.suppliedemail != null && newCaseObj.suppliedemail != EscalatedCaseHelper.KALE_SUPPORT_EMAIL && newCaseObj.description != null 
                    && newCaseObj.description.contains(Label.Case_Area_ICH)){
                    newCaseObj.CaseArea__c = Label.ICH;
                    newCaseObj.origin = Label.Web;
                    descDetails = Blob.valueOf(newCaseObj.description);
                    newCaseObj.Type = clsCheckBusinessHours.getWebFieldValue(Label.Case_Type, Label.Case_Classification, descDetails);
                    newCaseObj.classification_SIS__C = clsCheckBusinessHours.getWebFieldValue(Label.Case_Classification, Label.Case_Defect_Issue, descDetails);
                    defect = clsCheckBusinessHours.getWebFieldValue(Label.Case_Defect_Issue, Label.Browser_type, descDetails);
                    newCaseObj.Defect_Issue__c = defect;
                    cPriority = clsCheckBusinessHours.getCasePriority(newCaseObj);
                    // Get web details and update web company, web IATA code, web name, web phone, browser type 
                    newCaseObj.Browser_Type__c = clsCheckBusinessHours.getBrowserType(descDetails);
                    newCaseObj.SuppliedName = clsCheckBusinessHours.getWebFieldValue(Label.Contact_Name, Label.Email, descDetails);
                    newCaseObj.SuppliedCompany = clsCheckBusinessHours.getWebFieldValue(Label.Company, Label.Contact_Name, descDetails);
                    newCaseObj.SuppliedPhone = clsCheckBusinessHours.getWebFieldValue(Label.Phone, Label.Subject, descDetails);
                    newCaseObj.IATAcode__c = clsCheckBusinessHours.getWebFieldValue(Label.IATA_Alpha, Label.Company, descDetails);
                }
                if ((newCaseObj.CaseArea__c == Label.ICH && newCaseObj.RecordTypeId == null)){
                    //newCaseObj.RecordTypeId = sisHelpDeskCaseRecordTypeID;
                    newCaseObj.classification_SIS__C = newCaseObj.Classification__c;
                }
                // Assign Case Priority - for Web2Case with attachments 
                if (newCaseObj.suppliedemail != null && newCaseObj.description != null && newCaseObj.suppliedemail != EscalatedCaseHelper.KALE_SUPPORT_EMAIL && newCaseObj.CaseArea__c == Label.ICH){
                    cPriority = clsCheckBusinessHours.getCasePriority(newCaseObj);
                }
                if (cPriority != null){
                    if (cPriority == Label.Priority_1_Showstopper){
                        newCaseObj.assigned_to__c = Label.ICH_Application_Support;
                        newCaseObj.L2_Support_Priority__c = Label.X1_High;
                        newCaseObj.Kale_Status__c = Label.New;
                    }else{
                        newCaseObj.assigned_to__c = Label.ICH_Help_Desk_Agent;
                    }
                    newCaseObj.Status = Label.Action_Needed;
                    newCaseObj.Priority = cPriority;
                }
            }
            // K.A 9-11-2014 : IS email to case E-mail to Case - IS Help Desk 
            if ((newCaseObj.Origin == Label.E_mail_to_Case_IS_Help_Desk || newCaseObj.Origin == Label.E_mail_to_Case_SIS_Help_Desk ) && newCaseObj.RecordTypeId != null){
                system.debug('\nOrigin = E-mail to Case - IS Help Desk');
                boolean isIS = false ;
                if (newCaseObj.SuppliedEmail !=System.Label.KALE_SUPPORT_EMAIL && newCaseObj.Origin != Label.E_mail_to_Case_SIS_Help_Desk)  
                    isIS = clsCheckBusinessHours.ISCaseIdentifyAndProcess(newCaseObj);
                if (isIS || newCaseObj.SuppliedEmail ==System.Label.KALE_SUPPORT_EMAIL || newCaseObj.Origin == Label.E_mail_to_Case_SIS_Help_Desk ){
                    if (newCaseObj.SuppliedEmail ==System.Label.KALE_SUPPORT_EMAIL){
                        // extract Kale case number from email subject
                        String kaleCaseNumberStr = null;
                        String sfCaseNumber = null;
                        if (newCaseObj.Subject != null && newCaseObj.Subject.contains(Label.doubleHash)){
                            kaleCaseNumberStr = newCaseObj.Subject.split(Label.doubleHash)[1].trim(); // the case number is in index 1
                            System.debug('Kale Case Number : ' + kaleCaseNumberStr);
                            // get SalesForce case number from the case subject
                            sfCaseNumber = EscalatedCaseHelper.extractSFCaseNumberFromSubject(newCaseObj.Subject);
                            System.debug('SF Case Number : ' + sfCaseNumber);
                        }
                        // update external reference number if case was escalated to Kale
                        if (EscalatedCaseHelper.caseHasBeenEscalatedToKale(newCaseObj)){
                            if (sfCaseNumber == null) 
                                throw new EmailParsingException(Label.EmailParsingExceptionKaleNumber);
                            // get the original case and update the ExternalReferenceNumber
                            Case thisParentCase = KaleCases.get(sfCaseNumber);
                            if (thisParentCase == null){
                                throw new EmailParsingException('ERROR: Case Number ' + sfCaseNumber + ' was not found.');
                            }else{
                                thisParentCase.External_Reference_Number__c = kaleCaseNumberStr;
                                System.debug('Kale Case Number : ' + thisParentCase.Id + '-' + thisParentCase.External_Reference_Number__c);
                                CasesToUpdate.add(thisParentCase);
                            }
                        }
                        // add a case comment with the new SCP case status as closed
                        // add a case comment with the new SCP case status
                        system.debug('\nStart here');
                        if (EscalatedCaseHelper.caseHasBeenClosedByKale(newCaseObj) || EscalatedCaseHelper.caseStatusHasBeenUpdatedByKale(newCaseObj)){
                            system.debug('\nStart here2');
                            Case thisParentCase = KaleCases.get(sfCaseNumber);
                            if (thisParentCase == null){
                                throw new EmailParsingException('ERROR: Case Number ' + sfCaseNumber + ' was not found.');
                            }else{
                                String newStatus = null;
                                String thisfCaseNumber = EscalatedCaseHelper.extractSFCaseNumberFromSubject(newCaseObj.Subject);
                                System.debug('SF Case Number : ' + thisfCaseNumber);
                                if (thisfCaseNumber == null || thisfCaseNumber.trim().length() == 0) 
                                    throw new EmailParsingException(Label.EmailParsingExceptionKaleNumber);
                                // extract new status from case description
                                string[] emailLines = newCaseObj.Description.split('\n');
                                for (integer i = 0; i < emailLines.size(); i++){
                                    // search for the line containing the status
                                    system.debug('\nStatus: ' + emailLines[i]);
                                    if (emailLines[i].trim().startsWith('Status :')){
                                        newStatus = emailLines[i].substring(emailLines[i].lastIndexOf(' : ') + 2);
                                        break;
                                    }
                                }
                                system.debug('NewStatus: ' + newStatus);
                                if (newStatus == null) 
                                    throw new EmailParsingException(Label.EmailParsingExceptionKaleStatus);
                                // add the new status as a case comment
                                EscalatedCaseHelper.addCaseComment(thisParentCase.Id, 'The SCP case status has been updated to ' + newStatus.trim());
                                // Update Kale Status Field
                                Schema.DescribeFieldResult kaleStatusField = Case.Kale_Status__c.getDescribe();
                                List < Schema.PicklistEntry > kaleStatusPicklistEntries = kaleStatusField.getPicklistValues();
                                Boolean statusFound = false;
                                if (newStatus.trim() == 'Onhold') 
                                    newStatus = 'On hold';
                                for (Schema.PicklistEntry p: kaleStatusPicklistEntries){
                                    if (p.getValue().equalsIgnoreCase(newStatus.trim())){
                                        statusFound = true;
                                        thisParentCase.Kale_Status__c = p.getValue();
                                        break;
                                    }
                                }
                                if (statusFound)
                                    CasesToUpdateForStatus.add(thisParentCase);
                                else
                                    throw new EmailParsingException('ERROR: Received Kale Status ' + 'The SCP case status has been updated to ' + newStatus.trim() + ' was not recognized.');
                            }
                        }
                        // add a case comment with Kale's comment
                        if (EscalatedCaseHelper.caseHasNewCommentByKale(newCaseObj))
                            EscalatedCaseHelper.updateCaseWithKaleComment(newCaseObj);
                        // add a case comment with Kale's resolution
                        if (EscalatedCaseHelper.caseHasBeenResolvedByKale(newCaseObj))
                            EscalatedCaseHelper.updateCaseWithResolution(newCaseObj);
                    }else if (newCaseObj.CaseArea__c == Label.ICH){
                        newCaseObj.assigned_to__c = Label.ICH_Help_Desk_Agent;
                    }
                    // assign Case to Recycle Bin if from address is excluded
                    isExcluded = false;
                    for (ExcludedEmailFromAddress__c excludedAddress: ListOfExcludedAddress){
                        system.debug('\nexcludedAddress.Name.toUpperCase(): ' + excludedAddress.Name.toUpperCase());
                        if (newCaseObj.SuppliedEmail != null && newCaseObj.SuppliedEmail.toUpperCase().contains(excludedAddress.Name.toUpperCase())){
                            isExcluded = true;
                        }
                        system.debug('\nisExcluded: ' + isExcluded);
                        system.debug('\nnewCaseObj.SuppliedEmail: ' + newCaseObj.SuppliedEmail);
                    }
                    if (isExcluded){
                        clsCheckBusinessHours.assignToRecycleBin(newCaseObj);
                    }
                    // cancel insert/update if subject is excluded
                    isExcluded = false;
                    for (ExcludedCaseSubject__c excludedSubject: ListOfExcludedSubjectd){
                        if (newCaseObj.Subject.toUpperCase().contains(excludedSubject.Name.toUpperCase())) isExcluded = true;
                    }
                    if (isExcluded){
                        clsCheckBusinessHours.assignToRecycleBin(newCaseObj);
                    }
                    // Search for a parent case (Same case subject + same contact email)
                    if (newCaseObj.SuppliedEmail != null && newCaseObj.SuppliedEmail != EscalatedCaseHelper.KALE_SUPPORT_EMAIL){
                        //AP: Check the case subject content in parts
                        String childCase = newCaseObj.Subject;
                        String newChildCase;
                        if (parentCaseNumber.isEmpty()){
                            parentCaseNumber = [Select c.id, Kale_Status__c, c.CaseNumber, c.Subject, ownerid, SuppliedEmail From Case c where c.RecordTypeId != null
                                    and c.RecordTypeId = : sisHelpDeskCaseRecordTypeID and c.SuppliedEmail != null and c.Origin != null and c.Subject != null  
                                    and c.ownerid != null and c.Origin = :Label.E_mail_to_Case_IS_Help_Desk];
                            if (!parentCaseNumber.isEmpty()){
                                for (Case thisCase: parentCaseNumber){
                                    //build the String Key: SuppliedEmail + Subject
                                    KeyString = thisCase.SuppliedEmail + '**' + thisCase.Subject;
                                    system.debug('\nKeyString1: ' + KeyString);
                                    parentCases.put(KeyString, thisCase);
                                }
                            }
                        }
                        clsCheckBusinessHours.addCaseToParent(newCaseObj, parentCases);
                    }
                    if (newCaseObj.Priority != null && newCaseObj.Priority  == Label.Priority_1_Showstopper && newCaseObj.caseArea__c == Label.ICH ){                    
                        newCaseObj.assigned_to__c = Label.ICH_Application_Support;
                        newCaseObj.L2_Support_Priority__c = Label.X1_High;
                        newCaseObj.Kale_Status__c = Label.New;                            
                    }  
                }else{//no keywords found
                    system.debug('\nno keywords found');
                    newCaseObj.CaseArea__c = '';
                }
            } //end of email to case
        }
        if (CasesToUpdate.size() > 0){
            EscalatedCaseHelper.updateExternalRefNumber(CasesToUpdate);
        }
        if (CasesToUpdateForStatus.size() > 0){
            update CasesToUpdateForStatus;
        }
    }
    
    public static void trgCheckBusinessHoursBeforeUpdate(list<Case> listNewCases, list<Case> listOldCases, Map<string,Contact> CBHContactMap, Map<string,Account> CBHAccountMap) {
        String Kale_BusinessHours_Name = Label.SIS_HelpDesk_Kale;
        String SIS_BusinessHours_Name = Label.SIS_Help_Desk;
        map<Id,Case> mapOlds = new map<Id,Case>(listOldCases);
        Set < String > casePriorityAllowed = new Set < String >{Label.Priority_1_Showstopper, Label.Priority_2_Major, Label.Priority_3_Minor, Label.Priority_4_Trivial_Defects};
        List < BusinessHours > busiHours;
        BusinessHours sisBusinessHours, kaleBusinessHours;
        List < Case > casesToBeUpdate;
        List < Case > casesUpdated;
        Boolean isSISInitialisationBlockRun = false;
        Boolean CheckerUP = false;

        for (Case CHECKCaseObj: listNewCases){
            if(CHECKCaseObj.CaseArea__c == Label.SIS && CHECKCaseObj.RecordTypeId == sisHelpDeskCaseRecordTypeID){
                 CheckerUP = true;
                 break;
            }
        }
        if(CheckerUP)
            busiHours = [SELECT Id, Name FROM BusinessHours WHERE Name IN(: Kale_BusinessHours_Name, : SIS_BusinessHours_Name)];

        for (Case caseObjNew: listNewCases){
            Case caseObjOld = mapOlds.get(caseObjNew.Id);
            // To update L2 Support team details whenever a case is escalated               
            if (caseObjOld.casearea__C != null && caseObjOld.CaseArea__c == Label.SIS && caseObjNew.Status == Label.Escalated && caseObjOld.Assigned_To__c != caseObjNew.Assigned_To__c 
                && (caseObjNew.Assigned_To__c != Label.ICH_Application_Support && caseObjNew.Assigned_To__c != Label.SIS_Help_Desk_Agent 
                && caseObjNew.Assigned_To__c != Label.SIS_Operations && caseObjNew.Assigned_To__c != Label.SIS_L2_Customer_Support)){
                Account theAccount = CBHAccountMap.get(caseObjNew.Assigned_To__c);
                if (theAccount <> null){
                    system.debug('\ncaseObjNew.Assigned_To__c:_' + caseObjNew.Assigned_To__c + '_');
                    system.debug('\ntheAccount.Id: ' + theAccount.Id);
                    caseObjNew.L2_Support_Team_Account__c = string.valueOf(theAccount.Id);
                }
                Contact theContact = CBHContactMap.get(string.valueOf(caseObjNew.L2_Support_Team_Account__c));
                if (theContact <> null) 
                    caseObjNew.L2_L3_Support_Owner__c = string.valueOf(theContact.Id);
                system.debug('\ncaseObjNew.L2_L3_Support_Owner__c: ' + caseObjNew.L2_L3_Support_Owner__c);
            }else{
                if(caseObjOld.CaseArea__c == Label.SIS && caseObjNew.Status == Label.Escalated && caseObjOld.Assigned_To__c != caseObjNew.Assigned_To__c 
                    && (caseObjNew.Assigned_To__c == Label.SIS_Help_Desk_Agent || caseObjNew.Assigned_To__c == Label.SIS_Operations || caseObjNew.Assigned_To__c == Label.SIS_L2_Customer_Support)){
                    caseObjNew.L2_Support_Team_Account__c = null;
                    caseObjNew.L2_L3_Support_Owner__c = null;
                }
            }
            //SIS Helpdesk Enhancement : December 2013.
            if (caseObjNew.CaseArea__c == Label.SIS && caseObjNew.RecordTypeId == sisHelpDeskCaseRecordTypeID){
                // Variables Initialisations. This block of code run once.
                if (isSISInitialisationBlockRun == false){
                    
                    //CasesUpdated : Cases List returned by the "SISHelpDesk_CaseSLATracking.updateSLA", since this function doesn't modify the List Case passed in parameters.
                    casesToBeUpdate = new List < Case > ();
                    casesUpdated = new List < Case > ();
                    // Assign relatives BusinessHours to the variables
                    for (BusinessHours b: busiHours){
                        if (b.Name == Kale_BusinessHours_Name)
                            kaleBusinessHours = b;
                        if (b.Name == SIS_BusinessHours_Name)
                            sisBusinessHours = b;
                    }
                    isSISInitialisationBlockRun = true;
                }
                // If the Case escalated to Kale is going to Stop SLA Calculation Status mode, update the case to Stop Status mode                  
                if (caseObjOld.HasSISCaseBeenClosed__c == false && SISHelpDesk_CaseSLATracking.KaleStopStatus.contains(caseObjOld.Kale_Status__c) == false 
                    && SISHelpDesk_CaseSLATracking.KaleStopStatus.contains(caseObjNew.Kale_Status__c) == true){
                    SISHelpDesk_CaseSLATracking.updateSLA_Kale_BeginStopStatus(caseObjNew, kaleBusinessHours);
                }
                // Check if the Kale Status is going stop SLA Calculation mode, update case info
                if (caseObjOld.HasSISCaseBeenClosed__c == false && SISHelpDesk_CaseSLATracking.SISStopStatus_FromKale.contains(caseObjOld.Kale_Status__c) == false 
                    && SISHelpDesk_CaseSLATracking.SISStopStatus_FromKale.contains(caseObjNew.Kale_Status__c) == true){
                    SISHelpDesk_CaseSLATracking.updateSLA_SIS_BeginStopStatus(caseObjNew, sisBusinessHours);
                }
                //kareem
                // Check if the Case Status is going stop SLA Calculation mode, update case info
                if (caseObjOld.HasSISCaseBeenClosed__c == false && SISHelpDesk_CaseSLATracking.SISStopStatus.contains(caseObjOld.Status) == false 
                    && SISHelpDesk_CaseSLATracking.SISStopStatus.contains(caseObjNew.Status) == true){
                    SISHelpDesk_CaseSLATracking.updateSLA_SIS_BeginStopStatus(caseObjNew, sisBusinessHours);
                }
                // If the Case escalated to Kale is going to Active SLA Calculation Status mode, update the case update case to Active Status mode
                if (caseObjOld.HasSISCaseBeenClosed__c == false && SISHelpDesk_CaseSLATracking.KaleStopStatus.contains(caseObjOld.Kale_Status__c) == true 
                    && SISHelpDesk_CaseSLATracking.KaleStopStatus.contains(caseObjNew.Kale_Status__c) == false){
                    SISHelpDesk_CaseSLATracking.updateSLA_Kale_EndStopStatus(caseObjNew);
                }
                // Check if the Kale Status is going from {'ON HOLD', 'RESOLVED', 'CLOSED'} to Active SLA Calculation mode, update case info
                if (SISHelpDesk_CaseSLATracking.SISStopStatus_FromKale.contains(caseObjOld.Kale_Status__c) == true && SISHelpDesk_CaseSLATracking.SISStopStatus_FromKale.contains(caseObjNew.Kale_Status__c) == false){
                    SISHelpDesk_CaseSLATracking.updateSLA_SIS_EndStopStatus(caseObjNew);
                }
                // Check if the Case Status is going from Stop mode to Active SLA Calculation mode, update case info
                if (SISHelpDesk_CaseSLATracking.SISStopStatus.contains(caseObjOld.Status) == true && SISHelpDesk_CaseSLATracking.SISStopStatus.contains(caseObjNew.Status) == false){
                    SISHelpDesk_CaseSLATracking.updateSLA_SIS_EndStopStatus(caseObjNew);
                }
                // Check if the Case Status is going to Definitive Stop mode, update case info
                if (caseObjOld.HasSISCaseBeenClosed__c == false && SISHelpDesk_CaseSLATracking.SISDefinitiveStopStatus.contains(caseObjNew.status)){
                    //only begin stop status when old sis status is not a stop status
                    if (SISHelpDesk_CaseSLATracking.SISStopStatus.contains(caseObjOld.Status) == false)
                        SISHelpDesk_CaseSLATracking.updateSLA_SIS_BeginStopStatus(caseObjNew, sisBusinessHours);
                    //only begin stop status when old kale status is not a stop status
                    if (SISHelpDesk_CaseSLATracking.KaleStopStatus.contains(caseObjOld.Kale_Status__c) == false)
                        SISHelpDesk_CaseSLATracking.updateSLA_Kale_BeginStopStatus(caseObjNew, kaleBusinessHours);
                    caseObjNew.HasSISCaseBeenClosed__c = true;
                }
                //Update the SLA Calculation
                List < Case > c = SISHelpDesk_CaseSLATracking.updateSLA(new List < Case >{caseObjNew}, sisBusinessHours, kaleBusinessHours);
                if (c.size() > 0){
                    caseObjNew.SIS_SLATracking__c = c[0].SIS_SLATracking__c;
                    caseObjNew.SIS_SLATracking_LastUpdated__c = c[0].SIS_SLATracking_LastUpdated__c;
                    caseObjNew.Kale_SLATracking__c = c[0].Kale_SLATracking__c;
                    caseObjNew.Kale_SLATracking_LastUpdated__c = c[0].Kale_SLATracking_LastUpdated__c;
                }
            }
        }
    }
}