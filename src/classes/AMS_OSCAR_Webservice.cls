global class AMS_OSCAR_Webservice {

    public class OSCARException extends Exception{}

    WebService static String updateFormFields(String[] fieldsToUpdateKey, String[] fieldsToUpdateValue, String recordId) {

        Map<String, Schema.DisplayType> fTypes;
        Boolean needsUpdate = false;
        String theQuery = 'SELECT ';

        for (Integer i = 0; i < fieldsToUpdateKey.size(); i++) {
            theQuery += fieldsToUpdateKey[i];
            if (i < fieldsToUpdateKey.size() - 1)
                theQuery += ', ';
        }

        theQuery += ' FROM AMS_OSCAR__c WHERE Id=' + '\'' + recordId + '\'';

        system.debug('AMS OSCAR Webservice query: ' + theQuery);

        List<AMS_OSCAR__c> oscar = database.query(theQuery);
        if (oscar != null && oscar.size() > 0) {
            for (Integer i = 0; i < fieldsToUpdateKey.size(); i++) {

                Object fieldValue = oscar[0].get(fieldsToUpdateKey[i]);

                String updatedValue = fieldsToUpdateValue[i].trim();

                if (String.valueOf(fieldValue) != updatedValue) {

                    needsUpdate = true;

                    if (ftypes == null)
                        fTypes = getFieldTypes(fieldsToUpdateKey);

                    try {
                        if (updatedValue == '' || updatedValue == null)
                            oscar[0].put(fieldsToUpdateKey[i], null);
                        else {
                            //check fieldType
                            Schema.DisplayType fldDisplayType = ftypes.get(fieldsToUpdateKey[i]);
                            if (fldDisplayType == Schema.DisplayType.DOUBLE ||
                                    fldDisplayType == Schema.DisplayType.CURRENCY ||
                                    fldDisplayType == Schema.DisplayType.PERCENT) {
                                //remove commas from doubles
                                updatedValue = updatedValue.replace(',', '');
                                oscar[0].put(fieldsToUpdateKey[i], Double.valueOf(updatedValue));
                            } else if (fldDisplayType == Schema.DisplayType.DATE)      oscar[0].put(fieldsToUpdateKey[i], Date.parse(updatedValue));
                            else if (fldDisplayType == Schema.DisplayType.INTEGER)   oscar[0].put(fieldsToUpdateKey[i], Integer.valueOf(updatedValue));
                            else if (fldDisplayType == Schema.DisplayType.BOOLEAN)   oscar[0].put(fieldsToUpdateKey[i], Boolean.valueOf(updatedValue));
                            else //default will try to update field with String value
                                oscar[0].put(fieldsToUpdateKey[i], String.valueOf(updatedValue));
                        }

                    } catch (TypeException te) {
                        return te.getMessage();
                    }

                }
            }

            if (needsUpdate)
                try {
                    update oscar[0];
                } catch (DMLException dmle) {
                    String errorMessage = AMS_Utils.errorMessageBeautifyer(dmle);
                    return errorMessage;
                    //return dmle.getMessage();
                }
        }

        return '';
    }

    private static Map<String, Schema.DisplayType> getFieldTypes(List<String> fieldsApiName) {

        Map<String, Schema.DisplayType> fieldTypes = new Map<String, Schema.DisplayType>();
        Map<String, Schema.SObjectField> allFields = Schema.getGlobalDescribe().get('AMS_OSCAR__c').getDescribe().fields.getMap();

        for (String f : fieldsApiName) {
            Schema.DescribeFieldResult fr = allFields.get(f).getDescribe();
            fieldTypes.put(f, fr.getType());
            system.debug('Field types map: ' + fieldTypes);
        }

        return fieldTypes;

    }

    WebService static String createIFAPFromOSCAR(String oscarId) {

        String result = '';

        try {

            ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

            List<AMS_OSCAR__c> oscar = [select Name, Account__c, Account__r.BillingCountry, Account__r.Type, Account__r.Name from AMS_OSCAR__c where Id = : oscarId];
            if (oscar != null && oscar.size() > 0) {
                String accountId = oscar[0].Account__c;

                if (accountId == null) {
                    result = 'Could not find an account related to this OSCAR.';
                    return 'ERROR: ' + result;
                }
                //account must have billing country
                String billingCountry = oscar[0].Account__r.BillingCountry;
                if (billingCountry == null) {
                    result = 'Could not find a billing country on the account related to this OSCAR.';
                    return 'ERROR: ' + result;
                }

                String accountType = oscar[0].Account__r.Type;
                if (accountType == null || !Pattern.matches('IATA Cargo Agent|IATA Passenger Sales Agent|CASS Associate', accountType)) {
                    result = 'The type of account related to this oscar must be one of the following: IATA Cargo Agent|IATA Passenger Sales Agent|CASS Associate';
                    return 'ERROR: ' + result;
                }

                //find IFAP Contact in Account
                List<Contact> ifapContact = [select Financial_Assessment_Contact__c from Contact where AccountId = : accountId AND Financial_Assessment_Contact__c = true limit 1];
                if (ifapContact == null || ifapContact.size() == 0) {
                    result = 'Could not find a Financial Assessment contact for the account related to this OSCAR.';
                    return 'ERROR: ' + result;
                }

                List<Case> cases = [select Id, Reason1__c from Case where OSCAR__c = : oscar[0].Id AND ( ParentId = null or Parent.RecordType.Name != 'OSCAR Communication' ) limit 1];

                if (cases == null || cases.isEmpty()) {
                    result = 'Could not find a the Oscar Communication case related to this OSCAR.';
                    return 'ERROR: ' + result;
                }

                Case oscarCommCase = cases[0];

                Date currentDate = Date.today();
                Case ifapCase = new Case(RecordTypeId = IFAPcaseRecordTypeID, ParentId = oscarCommCase.Id, AccountId = oscar[0].Account__c,
                                         Subject = oscarCommCase.Reason1__c + ' - ' + oscar[0].Account__r.Name, Status = 'Agent to be Notified',
                                         Deadline_Date__c = currentDate + 5, ContactId = ifapContact[0].Id, OSCAR__c = oscar[0].Id, Financial_Assessment_requested__c = currentDate);

                insert ifapCase;

                oscar[0].STEP11__c = 'In Progress';
                update oscar;

                //OSCAR Name will be equal to the CaseNumber, so instead of querying the ifap Case for its CaseNumber
                //we simply return the OSCAR Name
                return ifapCase.Id + ':' + oscar[0].Name;

            }

            return 'ERROR: OSCAR not found.';

        } catch (Exception ex) {
            return AMS_Utils.errorMessageBeautifyer(ex);
        }

    }

    WebService static String createAMLCaseWithNoOscarUpdate(AMS_OSCAR__c oscar) {
        return execCreateAMLCase(oscar, false);
    }

    WebService static String createAMLCase(String oscarId) {
        List<AMS_OSCAR__c> oscar = [select Name, STEP17__c, Account__c, Region__c, Process__c from AMS_OSCAR__c where Id = : oscarId];
        if (oscar != null && oscar.size() > 0) {
            return execCreateAMLCase(oscar[0], true);
        }
        return 'ERROR: OSCAR not found.';
    }

    private static String execCreateAMLCase(AMS_OSCAR__c oscar, Boolean updateOscar) {
        String result = '';

        if (oscar.STEP17__c == AMS_Utils.IN_PROGRESS) return 'ERROR: Due Diligence already in progress';

        try {

            ID InternalCaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'InternalCasesEuropeSCE');

            List<Case> cases = [select Id, OSCAR__r.Account__r.IATA_ISO_Country__r.Name, OSCAR__r.AMS_Online_Accreditation__r.Account_Name__c, OSCAR__r.Account__r.Name from Case where OSCAR__c = : oscar.Id AND ( ParentId = null or Parent.RecordType.Name != 'OSCAR Communication' ) limit 1];

            if (cases == null || cases.isEmpty()) {
                result = 'Could not find a the Oscar Communication case related to this OSCAR.';
                return 'ERROR: ' + result;
            }

            Case oscarCommCase = cases[0];

            Case issCase = new Case(RecordTypeId = InternalCaseRecordTypeID, CaseArea__c = 'Corporate Compliance',
                                    Reason1__c = fetchAMLCaseReason(oscar.Process__c),
                                    ParentId = oscarCommCase.Id, AccountId = oscar.Account__c, 
                                    Subject = (oscar.Process__c == AMS_Utils.IEPBANKACCOUNTSETUP ? 'Due Diligence – ' + oscarCommCase.OSCAR__r.Account__r.Name : 'Due Diligence – ' + oscarCommCase.OSCAR__r.AMS_Online_Accreditation__r.Account_Name__c),
                                    Region__c = oscar.Region__c, BSPCountry__c = oscarCommCase.OSCAR__r.Account__r.IATA_ISO_Country__r.Name);

            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            issCase.setOptions(dmo);

            insert issCase;

            oscar.STEP17__c = 'In Progress';
            oscar.AML_requested__c = Date.today();
            oscar.AML_deadline__c = Date.today() + 3;

            if (updateOscar) {
                update oscar;
            }

            update new Account(Id = oscar.Account__c, Due_Diligence_Status__c = 'In Progress');

            return issCase.Id;

        } catch (Exception ex) {
            return AMS_Utils.errorMessageBeautifyer(ex);
        }
    }

    WebService static String copyDataToAccount(String oscarId) {

        try {
            List<AMS_OSCAR__c> oscar = [select Account__c, AMS_Online_Accreditation__c, Process__c, recordTypeID, Is_PCI_compliant__c from AMS_OSCAR__c where Id = : oscarId];
            AMS_Utils.copyDataToAccount(oscar);
            return 'OK';
        } catch (Exception ex) {
            if (ex.getMessage().contains('ISSP_ContactUpdaetPortalUser')) return Label.AMS_Duplicate_Username;
            else return ex.getMessage();
        }
    }

    WebService static String createChangeCodeNEW(String oscarId) {

        try {
            List<AMS_OSCAR__c> oscar = [select Account__c, Account__r.CNS_Agency__c, Business_Process__c, Process__c, AMS_Online_Accreditation__c, recordTypeID, Is_NewGen__c from AMS_OSCAR__c where Id = : oscarId];

            AMS_OSCAR__c theOSCAR = oscar[0];

            //AMS_Utils.isNewgenProcess = (AMS_Utils.oscarNewGenProcesses.contains(theOSCAR.Process__c));

            String changeCodeId = 'NEW-' + theOSCAR.Business_Process__c;
            AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();
            AMS_ChangeCodes__c n = AMS_ChangeCodes__c.getInstance(changeCodeId);

            changeCode.name = n.Change_Code__c;
            changeCode.reasonCode = n.Reason_Code__c;
            changeCode.memoText = AMS_Utils.getChangeCodeMemoText(theOSCAR.Process__c, changeCodeId, n);
            changeCode.reasonDesc  = n.Reason_Code_Description__c;
            changeCode.status  = n.Account_status_change__c;
            changeCode.publishedOnEBulletin = n.Published_in_bulletin__c;

            Account acct = new Account(Id = theOSCAR.Account__c);
            AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {theOSCAR}, new List<Account> {acct}, true);

            return 'OK';
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }

    /**
    	Find the parent case related to an Oscar Id
    **/
    private static Case findOscarParentCase(Id oscarId) {
        List<Case> cases = [
            SELECT Id, AccountId, Account.Type, ContactId, Region__c, Reason1__c, BSPCountry__c, Account.Accumulated_Irregularities__c,
            SIDRA_Lite_Reason__c, NOT_Date__c, BusinessHoursId,
            oscar__r.Step6__c, oscar__r.Step9__c, oscar__r.Step11__c, oscar__r.Step12__c, oscar__r.Step14__c, oscar__r.Step26__c, oscar__r.Step35__c,
            oscar__r.RPM_Approval__c, oscar__r.Step44__c
            FROM Case
            WHERE OSCAR__c = :oscarId AND ( ParentId = null or Parent.RecordType.Name != 'OSCAR Communication' )
            LIMIT 1];
        if (cases.isEmpty()) {
            throw new OSCARException('Could not find a the Oscar Communication case related to this OSCAR');
        }
        return cases[0];
    }
    
    private static void checkOscarStep(AMS_OSCAR__c oscar, String step) {
        String reason = SidraLiteHelperForOSCAR.MAP_STEP_REASON.get(step);
        String message = 'Sidra Lite for "' + reason + '" cannot be created if the status is not "Failed" in this step.';
        if (step=='6') {
            if (oscar.Step6__c == 'Failed') return;
            throw new OSCARException(message);
        }
        if (step=='9') {
            if (oscar.Step9__c == 'Failed') return;
            throw new OSCARException(message);
        }
        if (step=='11') {
            if (oscar.Step11__c == 'Failed') return;
            throw new OSCARException(message);
        }
        if (step=='12') {
            if (oscar.Step12__c == 'Failed') return;
            throw new OSCARException(message);
        }
        if (step=='14') {
            if (oscar.Step14__c == 'Failed') return;
            throw new OSCARException(message);
        }
        if (step=='26') {
            if (oscar.Step26__c == 'Failed') return;
            throw new OSCARException(message);
        }
        if (step=='35') {
            if (oscar.Step35__c == 'Failed') return;
            throw new OSCARException(message);
        }       
        if (step=='44') {
            if (oscar.Step44__c == 'Failed') return;
            throw new OSCARException(message);
        }
        if (step=='RPM') {
            if (oscar.RPM_Approval__c == 'Authorize Disapproval') return;
            message = 'Sidra Lite for "' + reason + '" cannot be created if the status is not "Authorize Disapproval" in this step.';
            throw new OSCARException(message);
        }
        if (step=='DGR') {
            if (oscar.Step6__c == 'Failed') return;
            throw new OSCARException(message);
        }
        throw new OSCARException('Step ' + step + ' is invalid');
    }

    WebService static String createSIDRALite(String oscarId, String step, Boolean createCase) {
        try {
            Case oscarCase = findOscarParentCase(oscarId);
            checkOscarStep(oscarCase.oscar__r, step);
            SidraLiteHelperForOSCAR.CHECK_STEP = step;
            Case sidraCase = WSSidraLite.sidraLiteAction(oscarCase.Id);
            
            if (createCase) {
                // change the reason and NOT date based on the selected step
                sidraCase.SIDRA_Lite_Reason__c = SidraLiteHelperForOSCAR.MAP_STEP_REASON.get(step);
                if (step == 'RPM') {
                    sidraCase.NOT_Date__c = BusinessDays.addNBusinessDays(DateTime.now(),5,oscarCase.BusinessHoursId).date();
                } else {
                    sidraCase.NOT_Date__c = Date.today();
                }
                insert sidraCase;
            }
            return sidraCase.Id;

        } catch (WSSidraLite.ShowConfirmationException confirmation) {
            // this exception is not an actual error, it contains a message to ask the
            // user if continue the process (using a javascript 'confirm' method)
            throw(confirmation);

        } catch (Exception ex) {
            return AMS_Utils.errorMessageBeautifyer(ex);
        }
    }
    
    WebService static String updateSIDRALite(String oscarId, String step) {
        try {
            Case oscarCase = findOscarParentCase(oscarId);
            checkOscarStep(oscarCase.oscar__r, step);
            WSSidraLite.updateSecondAndThirdDeadline(oscarCase.Id);
            return '';

        } catch (Exception ex) {
            return AMS_Utils.errorMessageBeautifyer(ex);
        }
    }

    WebService static String createCommissionerCase(String oscarId) {

        String result = '';

        try {

            ID commisionerCaseRecType = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');//SAAM

            List<AMS_OSCAR__c> oscar = [select Name, Account__c, Account__r.Location_Class__c, Account__r.Name, Account__r.IATA_ISO_Country__r.Region__c, Account__r.IATA_ISO_Country__r.Name from AMS_OSCAR__c where Id = : oscarId];
            if (oscar != null && oscar.size() > 0) {

                /*Not applicable, comissioner case can be created to passenger agencies on some situations
                if(!AMS_Utils.LocationClassCARGO.contains(oscar[0].Account__r.Location_Class__c)){
                    result = 'Commisoner Case can only be opened on cargo agencies';
                    return 'ERROR: ' + result;
                }
                */

                List<Case> cases = [select Id from Case where OSCAR__c = :oscar[0].Id AND ( ParentId = null or Parent.RecordType.Name != 'OSCAR Communication' ) limit 1];

                if (cases == null || cases.isEmpty()) {
                    result = 'Could not find a the Oscar Communication case related to this OSCAR.';
                    return 'ERROR: ' + result;
                }

                Case oscarCommCase = cases[0];

                Case newCase = new Case(RecordTypeId = commisionerCaseRecType, ParentId = oscarCommCase.Id, AccountId = oscar[0].Account__c, Subject = 'Late/Absence NOC – ' + oscar[0].Account__r.Name, OSCAR__c = oscar[0].Id, Region__c = oscar[0].Account__r.IATA_ISO_Country__r.Region__c, BSPCountry__c = oscar[0].Account__r.IATA_ISO_Country__r.Name, Reason1__c = 'Commissioner Review', Visible_on_ISS_Portal__c = false);

                insert newCase;

                oscar[0].STEP26__c = 'In Progress';
                update oscar;

                return newCase.Id;

            }

            return 'ERROR: OSCAR not found.';

        } catch (Exception ex) {
            return AMS_Utils.errorMessageBeautifyer(ex);
        }

    }



    WebService static String createFSReleaseCase(String oscarId) {

        String result = '';

        try {

            ID fsReleaseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');//SAAM

            List<AMS_OSCAR__c> oscar = [select Name, Account__c, Account__r.Location_Class__c, Account__r.Name, Account__r.IATA_ISO_Country__c, Account__r.IATA_ISO_Country__r.Region__c, Account__r.IATA_ISO_Country__r.Name, Account__r.Category__c from AMS_OSCAR__c where Id = : oscarId];
            if (oscar != null && oscar.size() > 0) {

                List<Case> cases = [select Id, ContactId from Case where OSCAR__c = :oscar[0].Id AND ( ParentId = null or Parent.RecordType.Name != 'OSCAR Communication' ) limit 1];

                if (cases == null || cases.isEmpty()) {
                    result = 'Could not find a the Oscar Communication case related to this OSCAR.';
                    return 'ERROR: ' + result;
                }

                Case oscarCommCase = cases[0];

                Case newCase = new Case(RecordTypeId = fsReleaseRT, ParentId = oscarCommCase.Id, AccountId = oscar[0].Account__c, Subject = 'FS Release', Region__c = oscar[0].Account__r.IATA_ISO_Country__r.Region__c, Reason1__c = 'Financial Security Release', CaseArea__c = 'Risk Management Process', Origin = 'Email', Priority = 'Normal', Type_of_customer__c = oscar[0].Account__r.Category__c, BSPCountry__c = oscar[0].Account__r.IATA_ISO_Country__r.Name, ContactId = oscarCommCase.ContactId);

                insert newCase;

                oscar[0].STEP26__c = 'In Progress';
                update oscar;

                return newCase.Id;

            }

            return 'ERROR: OSCAR not found.';

        } catch (Exception ex) {
            return AMS_Utils.errorMessageBeautifyer(ex);
        }

    }

    WebService static String generateCertificates(String oscarId, String agencyId) {

        try {

            //getAccountConcerned
            List<AMS_OSCAR__c> oscars = [SELECT Id, Name FROM AMS_OSCAR__c WHERE Id = :oscarId LIMIT 1];

            if(!oscars.isEmpty())
            {
                String oscarName = oscars.get(0).Name;
                List<Case> cases = [SELECT Id, Account_Concerned__c FROM Case WHERE CaseNumber = :oscarName AND AccountId = :agencyId LIMIT 1];

                if(!cases.isEmpty() && cases.get(0).Account_Concerned__c != null)
                {
                    agencyId = cases.get(0).Account_Concerned__c;
                }
            } 

            //creates request
            AMS_Certificate_Request__c request = new AMS_Certificate_Request__c();
            request.OSCAR__c = oscarId;
            request.AccountIds__c = JSON.serializePretty(new Set<String> {agencyId});

            //creates certificates on amazon
            String result = AMS_CertificateHelper.createCertificate(request);

            //inserts request
            if (result.startsWithIgnoreCase('ERROR: ')) return result;

            insert request;

            //creates attachments (for the request)
            System.enqueueJob(new AMS_CertificateHelper.CertificateCreation(request.Id, System.now().format('YYYY'), null));

            //creates change code
            //Account acct = new Account(Id = agencyId);
            //TD 2080607: CNS
            Account acct = [Select id, CNS_Agency__c, Status__c from account where id = :AgencyId];
            AMS_OSCAR__c oscar = new AMS_OSCAR__c(Id = oscarId);

            List<Agency_Applied_Change_code__c> accountActiveChangeCode = [SELECT Reason_Code__c, Reason_Description__c,Account__r.Status__c FROM Agency_Applied_Change_code__c WHERE Account__c =: agencyId AND Active__c = TRUE];

            AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();
            //changeCode.status  = null;
            changeCode.name = 'CER';
            changeCode.reasonCode = accountActiveChangeCode[0].Reason_Code__c;
            changeCode.reasonDesc  = accountActiveChangeCode[0].Reason_Description__c;
            changeCode.status  = AMS_Utils.getIATANumericStatus(accountActiveChangeCode[0].Account__r.Status__c);

            AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {oscar}, new List<Account> {acct}, true);

            oscar.Certificate_Generated__c = System.today();
            update oscar;

            return result;

        } catch (Exception ex) {
            return AMS_Utils.errorMessageBeautifyer(ex);
        }
    }

    WebService static String createRiskEvent(String oscarId){

        try{

            List<AMS_OSCAR__c> oscar = [select Risk_event_creation_date__c, RPM_Approval__c, Process__c, RecordTypeId, ANG_Type_Of_Change__c from AMS_OSCAR__c where Id =: oscarId];

            if(oscar!=null && oscar.size()>0){

                if((oscar[0].Process__c == AMS_Utils.NEWHESTANDARD || (oscar[0].Process__c == AMS_Utils.NGCHANGES && ANG_AgencyChangesHelper.containsChange(new List<String>(AMS_Utils.changesRequiringManagerApproval),oscar[0].ANG_Type_Of_Change__c))) && oscar[0].RPM_Approval__c != AMS_Utils.AUTH_APPROVAL)
                    return 'Error - In order to generate a risk event you need to have the Manager Approval.';

                oscar[0].Risk_event_creation_date__c = System.today();
                oscar[0].STEP36__c = 'Passed';
                update oscar;

                List<ANG_Agency_Risk_Event__c> rskEventLst = [SELECT Id from ANG_Agency_Risk_Event__c where ANG_OscarId__c = :oscarId];
                
                if(rskEventLst.isEmpty())
                    return 'No risk event is needed for this OSCAR.';
                else
                    return rskEventLst.size() + ' Risk(s) Event(s) generated successfully';

            }

            return 'ERROR: OSCAR not found.';

        }catch(Exception ex){
            return AMS_Utils.errorMessageBeautifyer(ex);
        }
    }

    WebService static String createIfapPortalServiceRight(String oscarId) {

        try {
            List<AMS_OSCAR__c> oscar = [SELECT Account__c FROM AMS_OSCAR__c WHERE Id = : oscarId];

            List<Contact> lstIfapContacts = [SELECT Id FROM Contact WHERE AccountId = :oscar[0].Account__c AND Financial_Assessment_Contact__c = true LIMIT 1];

            if (lstIfapContacts.isEmpty()) {
                return 'ERROR: No Financial Assessment contact found!';
            }

            list<Portal_Applications__c> lstApp = [SELECT Id FROM Portal_Applications__c WHERE Application_URL__c = '/ISSP_IFAPCases' LIMIT 1];

            if (lstApp.isEmpty()) {
                return 'ERROR: Unable to find the IFAP portal service!';
            }

            Portal_Application_Right__c par = new Portal_Application_Right__c();
            par.Contact__c = lstIfapContacts[0].Id;
            par.Portal_Application__c = lstApp[0].Id;
            par.Right__c = 'Access Granted';

            insert par;

            return 'OK';
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }

    @TestVisible
    private static String fetchAMLCaseReason(String process){
        if (process == AMS_Utils.AGENCYCHANGES)
            return 'Agent Change of Ownership';
        else if (process == AMS_Utils.IEPBANKACCOUNTSETUP)
            return 'IEP Due Diligence';
        else
           return 'New Accredited Agent';
    }

}