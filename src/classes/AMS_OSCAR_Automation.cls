public with sharing class AMS_OSCAR_Automation {
    // Class Factory template
    public interface IClassFactory {
        Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar);
    }

    //OK
    public class AMS_OSCAR_Step6_succeeded implements IClassFactory {

        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            
            system.debug('Start AUTOMATION AMS_OSCAR_Step6_succeeded.processWork');

            Boolean res = False;

            if (oscar != null) {
                
                oscar.Sanity_check_received__c = Date.today();
                
                if(oscar.Process__c == AMS_Utils.VOLRELINQUISH_CA || oscar.Process__c == AMS_Utils.VOLRELINQUISH){

                    oscar.Process_Start_Date__c = oscar.Change_effective_as_of__c;
                
                }
                else {

                    oscar.Process_Start_Date__c = Date.today();
                
                }

                oscar.Sanity_check_results__c = AMS_Utils.PASSED;

                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step6_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step6_failed.processWork');

            Boolean res = False;

            if (oscar != null) {
                oscar.Sanity_check_received__c = Date.today();
                if (oscar.Process__c == AMS_Utils.new_TIDS)
                    oscar.Sanity_check_deadline__c = Date.today() + 3;
                //else if(oscar.Process__c != AMS_Utils.CERTIFICATION)
                //    oscar.Sanity_check_deadline__c = oscar.Sanity_check_received__c + 15;
                else {
                    List<Account> oscarAccount = new List<Account>([select Location_Class__c from Account where id = : oscar.Account__c]);

                    if (oscar.Process__c == AMS_Utils.new_HO && (oscarAccount.get(0).Location_Class__c == 'C' || oscarAccount.get(0).Location_Class__c == 'I' || oscarAccount.get(0).Location_Class__c == 'P' || oscarAccount.get(0).Location_Class__c == 'Q')) {
                    
                        oscar.Sanity_check_deadline__c = Date.today() + 15;
                    
                    } else if (oscar.Process__c == AMS_Utils.new_BR || oscar.Process__c == AMS_Utils.new_BR_ABROAD || oscar.Process__c == AMS_Utils.new_SA || oscarAccount.get(0).Location_Class__c == 'R') {
                    
                        oscar.Sanity_check_deadline__c = Date.today() + 14;

                    } else if (Oscar.Process__c == AMS_Utils.NEWHELITE || Oscar.Process__c == AMS_Utils.NEWHESTANDARD || Oscar.Process__c == AMS_Utils.NEWAE || oscar.Process__c == AMS_Utils.NGCHANGES){

                        oscar.Sanity_check_deadline__c = Date.today() + 15;           

                    } else if (oscar.Process__c == AMS_Utils.NGANNUALREVAL){

                        oscar.Sanity_check_deadline__c = Date.today() + 15;
                        oscar.Sanity_check_received__c = Date.today();

                    }

                }

                oscar.Sanity_check_results__c = AMS_Utils.FAILED;
                res = True;
            }

            return res;
        }
    }

    //STEP WAS REMOVED
    public class AMS_OSCAR_Step7_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step7_succeeded.processWork');

            Boolean res = False;


            if (oscar != null) {

                oscar.IRIS_update_result__c = 'Passed';

                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step7_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step7_failed.processWork');

            Boolean res = False;

            if (oscar != null) {

                oscar.IRIS_update_result__c = 'Failed';

                res = True;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step8_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step8_succeeded.processWork');

            Boolean res = False;

            if (oscar != null) {

                oscar.STEP9__c = 'In Progress';
                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step8_inProgress implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step8_inProgress.processWork');

            Boolean res = False;

            if (oscar != null) {

                res = True;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step9_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step9_succeeded.processWork');

            Boolean res = False;

            if (oscar != null) {
                oscar.Proof_of_payment_received__c = Date.today();
                oscar.Invoice_status__c = 'Paid';
                if (oscar.STEP17__c == 'Not Started' || oscar.STEP17__c == 'Not Applicable' || oscar.STEP17__c == 'Passed')
                    oscar.Process_Start_Date__c = Date.today();
                res = True;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step9_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step9_failed.processWork');

            Boolean res = False;

            if (oscar != null) {
                oscar.Invoice_status__c = 'Outstanding';
                oscar.Proof_of_payment_received__c = Date.today();
                res = True;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step9_notApplicable implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step9_notApplicable.processWork');

            Boolean res = False;

            if (oscar != null) {
                oscar.Invoice_status__c = 'N/A';
                res = True;
            }

            return res;
        }
    }

    //sync from ifap case
    /*public class AMS_OSCAR_Step11_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step11_succeeded.processWork');

            Boolean res = False;

            try{
                //AMS_OSCAR__c objLifecycleRequest = [Select Id, Change_effective_as_of__c from AMS_OSCAR__c where Agency__c = :agencyId];

                if(oscar != null){
                    oscar.Assessment_Performed_Date__c = Date.today();
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step11_failed implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step11_failed.processWork');

            Boolean res = False;

            try{
                //AMS_OSCAR__c objLifecycleRequest = [Select Id, Change_effective_as_of__c from AMS_OSCAR__c where Agency__c = :agencyId];

                if(oscar != null){
                    oscar.Assessment_Performed_Date__c = Date.today();
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }*/

    public class AMS_OSCAR_Step11_inProgress implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step11_inProgress.processWork');

            Boolean res = False;

            if (oscar != null) {
                oscar.Financial_Assessment_requested__c = Date.today();
                oscar.Financial_Assessment_deadline__c = Date.today() + 5;
                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step12_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step12_succeeded.processWork');

            Boolean res = False;

            if (oscar != null) {
                oscar.Bank_Guarantee_received__c = Date.today();
                oscar.Financial_security_result__c = 'Valid';
                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step12_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step12_failed.processWork');

            Boolean res = False;

            if (oscar != null) {
                //RB: 15-11-2017 - INC354179 FS Bank_Guarantee_received__c should only be populated when FS Step is Valid.
                //oscar.Bank_Guarantee_received__c = Date.today();
                oscar.Financial_security_result__c = 'Rejected';
                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step12_notApplicable implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step12_notApplicable.processWork');

            Boolean res = False;

            if (oscar != null) {
                // JH: Removed to fix INC255865
                // oscar.Bank_Guarantee_received__c = Date.today();
                oscar.Financial_security_result__c = 'N/A';
                res = True;
            }

            return res;
        }
    }

    /*public class AMS_OSCAR_Step12_inProgress implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step12_inProgress.processWork');

            Boolean res = False;

            try{
                //AMS_OSCAR__c objLifecycleRequest = [Select Id, Change_effective_as_of__c from AMS_OSCAR__c where Agency__c = :agencyId];

                if(oscar != null){
                    oscar.Bank_Guarantee_requested__c = Date.today();
                    oscar.Bank_Guarantee_deadline__c = Date.today() + 30;
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }*/

    //OK
    public class AMS_OSCAR_Step13_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step13_succeeded.processWork');

            Boolean res = False;

            if (oscar != null) {
                oscar.Local_Inspection_received__c = Date.today();
                oscar.Local_Inspection_compliant__c = 'Passed';
                res = True;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step13_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step13_failed.processWork');

            Boolean res = False;

            if (oscar != null) {
                oscar.Local_Inspection_received__c = Date.today();
                oscar.Local_Inspection_compliant__c = 'Failed';
                res = True;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step13_inProgress implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step13_inProgress.processWork');

            Boolean res = False;

            if (oscar != null) {
                oscar.Local_Inspection_requested__c = Date.today();
                oscar.Local_Inspection_deadline__c = Date.today() + 10;
                res = True;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step13_notApplicable implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step13_notApplicable.processWork');

            Boolean res = False;

            if (oscar != null) {
                oscar.Local_Inspection_compliant__c = 'N/A';
                res = True;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step14_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step14_succeeded.processWork');

            Boolean res = False;

            if (oscar != null) {
                oscar.PSAA_EACP_Agreement_received__c = Date.today();
                oscar.Agreement_result__c = 'Passed';
                res = True;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step14_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step14_failed.processWork');

            Boolean res = False;

            if (oscar != null) {
                oscar.PSAA_EACP_Agreement_received__c = Date.today();
                oscar.Agreement_result__c = 'Failed';
                res = True;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step14_inProgress implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step14_inProgress.processWork');

            Boolean res = False;

            if (oscar != null) {
                oscar.Agreement_requested__c = Date.today();
                if (oscar.Process__c == AMS_Utils.new_GSA_BSP || oscar.Process__c == AMS_Utils.new_AHA_BSP || oscar.Process__c == AMS_Utils.new_GSSA)
                    oscar.Agreement_deadline__c = Date.today();
                else
                    oscar.Agreement_deadline__c = Date.today() + 10;

                res = True;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step14_notApplicable implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step14_notApplicable.processWork');

            Boolean res = False;

            if (oscar != null) {
                oscar.Agreement_result__c = 'N/A';
                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step10_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step10_succeeded.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.AIMS_updated__c = DateTime.now();
                oscar.Invoice_Requested__c = Date.today();
                res = True;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step15_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step15_succeeded.processWork');
            Boolean res = False;               
            Boolean hasFRRequiredStep = false;
            
            if (oscar.ANG_Type_Of_Change__c != null && oscar.Process__c == AMS_Utils.NGCHANGES && oscar.ANG_Type_Of_Change__c.contains(AMS_Utils.ANG_ACCREDITATION_TYPE) && oscar.STEP11__c != AMS_Utils.PASSED){
                Account oscarAccount = [SELECT ANG_Accreditation_Model__c FROM Account WHERE Id = :oscar.Account__c];
                if (oscarAccount.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASH){
                    hasFRRequiredStep = true;
                }
            }

            if (oscar != null && ((oscar.STEP12__c != AMS_Utils.IN_PROGRESS && oscar.STEP12__c != 'Not Started') || (oscar.Process__c == AMS_Utils.NEWHELITE || oscar.Process__c == AMS_Utils.NEWHESTANDARD || oscar.Process__c == AMS_Utils.NEWAE || oscar.Process__c == AMS_Utils.NGCHANGES))
                && !hasFRRequiredStep) {
                oscar.Dossier_Validation__c = Date.today();
                oscar.Validation_result__c = 'Passed';
                oscar.Status__c = 'Pending Approval';
                res = True;
            }else if(hasFRRequiredStep){
                    oscar.addError('When changing the Accreditation Model from "Cashless" to "Cash" the step "Conduct Financial Review" must be passed');
            }else{    
                    oscar.addError('Validation can only be Passed if Manage Financial Security step is Not Applicable, Failed or Passed.');
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step15_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step15_failed.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.Dossier_Validation__c = Date.today();
                oscar.Validation_result__c = 'Failed';
                //RB INC388740: Behavior should be the same for NewGen. Previously, the logic was changing status of the OSCAR to pending approval.
                oscar.Status__c = 'On Hold_Internal';

                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step15_notApplicable implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step15_notApplicable.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.Validation_result__c = 'N/A';
                res = True;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step25_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step25_succeeded.processWork');
            Boolean res = False;

            if (oscar != null && (oscar.STEP12__c == AMS_Utils.PASSED || oscar.STEP12__c == AMS_Utils.NOT_APPLICABLE)) {
                oscar.Dossier_Validation__c = Date.today();
                oscar.Validation_result__c = 'Passed';
                oscar.Status__c = 'Pending Approval';
                res = True;
            } else if(oscar != null && oscar.STEP12__c == AMS_Utils.FAILED) {
                oscar.addError('Validation can\'t be Passed when Manage Financial Security step is Failed.');
            } else {
                oscar.addError('Validation can only be Passed if Manage Financial Security step is Not Applicable or Passed.');
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step25_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step25_failed.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.Dossier_Validation__c = Date.today();
                oscar.Validation_result__c = 'Failed';
                oscar.Status__c = 'On Hold_Internal';
                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step25_inProgress implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step25_inProgress.processWork');
            Boolean res = False;

            if (oscar != null && oscar.STEP12__c == AMS_Utils.FAILED) {
                oscar.addError('Validation can only be Failed when Manage Financial Security step is Failed.');
            } else {
                res = True;
            }

            return res;
        }
    }


    /*public class AMS_OSCAR_Step25_notApplicable implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step25_notApplicable.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.Validation_result__c = 'N/A';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }
            return res;
        }
    }*/

    //OK
    public class AMS_OSCAR_Step2_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step2_succeeded.processWork');
            Boolean res = False;

            if (oscar.STEP6__c != 'Passed' && oscar.Process__c == AMS_Utils.AGENCYCHANGES) {
                oscar.addError('Manager Approval cannot be granted if Sanity check step does not equals PASSED');
            } else {
                
                if (oscar != null && ((oscar.STEP15__c == 'Passed' || oscar.STEP25__c == 'Passed') && oscar.STEP12__c != 'Failed') || (oscar.Process__c == AMS_Utils.NEWHELITE || oscar.Process__c == AMS_Utils.NEWHESTANDARD || oscar.Process__c == AMS_Utils.NEWAE || oscar.Process__c == AMS_Utils.NGCHANGES)) {

                    oscar.Approval_disapproval_date__c = Date.today();
                    oscar.Status__c = 'On Hold_Internal';
                    res = True;

                } else if(oscar != null && oscar.STEP12__c == 'Failed') {
                    oscar.addError('Approval can\'t be set when Manage Financial Security step is Failed.');
                }else {
                    oscar.addError('Approval can only be set after the validation Qualification Criteria is passed');
                }
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step2_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step2_failed.processWork');
            Boolean res = False;

            if (oscar != null) {

                oscar.Disapproval_date__c = Date.today();
                oscar.Status__c = 'On Hold_Internal';
                res = True;

            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step1_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step1_succeeded.processWork');
            Boolean res = False;

            if (oscar.STEP2__c != 'Passed' && !(oscar.Process__c == AMS_Utils.new_TIDS || oscar.Process__c == AMS_Utils.new_AHA || oscar.Process__c == AMS_Utils.new_AHA_BSP || oscar.Process__c == AMS_Utils.new_GSA_BSP || oscar.Process__c == AMS_Utils.new_GSA || oscar.Process__c == AMS_Utils.new_GSSA || oscar.Process__c == AMS_Utils.new_MSO || oscar.Process__c == AMS_Utils.NGCHANGES || oscar.Process__c == AMS_Utils.AGENCYCHANGES || oscar.Process__c == AMS_Utils.NGOPTINOUT))
                oscar.addError('Application Finalization cannot be granted if the Approval step does not equals PASSED');
            else if(oscar.Process__c == AMS_Utils.NGCHANGES && ANG_AgencyChangesHelper.containsChange(new List<String>(AMS_Utils.changesRequiringManagerApproval),oscar.ANG_Type_Of_Change__c) && oscar.RPM_Approval__c <> AMS_Utils.AUTH_APPROVAL)
                oscar.addError('Cannot set application finalization to passed because manager approval is not authorized.');
            else {

                if (oscar != null) {

                    oscar.Finalization_result__c = 'Passed';
                    res = True;

                }
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step1_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step1_failed.processWork');
            Boolean res = False;

            if (oscar != null) {

                oscar.Finalization_result__c = 'Failed';
                res = True;

            }

            return res;
        }
    }

    public class AMS_OSCAR_Step1_notApplicable implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step1_notApplicable.processWork');
            Boolean res = False;

            if (oscar != null) {

                oscar.Finalization_result__c = 'N/A';
                res = True;

            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step3_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step3_succeeded.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.Disapproval_result__c = 'Passed';
                res = True;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step3_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step3_failed.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.Disapproval_result__c = 'Failed';
                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step3_notApplicable implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step3_notApplicable.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.Disapproval_result__c = 'N/A';
                res = True;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step4_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step4_succeeded.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.Withdrawal_result__c = 'Passed';

                if(oscar.Process__c == AMS_Utils.NGCHANGES){
                    List<ANG_Agency_Risk_Event__c> riskEvents = [SELECT Id, ANG_Event_Status__c FROM ANG_Agency_Risk_Event__c WHERE ANG_OscarId__c = :oscar.Id];
                    if(riskEvents != null && !riskEvents.isEmpty()){
                        for(ANG_Agency_Risk_Event__c rEvent : riskEvents)
                            rEvent.ANG_Event_Status__c = 'Inactive_Withdrawn';

                        update riskEvents;
                    }
                }

                res = True;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step4_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step4_failed.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.Withdrawal_result__c = 'Failed';
                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step4_notApplicable implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step4_notApplicable.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.Withdrawal_result__c = 'N/A';
                res = True;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step5_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step5_succeeded.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.Reconsideration_result__c = 'Passed';
                oscar.Reconsideration_date__c = Date.today();
                res = True;

                //restart manager approval step
                oscar.STEP2__c = 'Not Started';
                oscar.RPM_Approval__c = 'Not Started';

                //restart validation step
                if(oscar.Process__c == AMS_Utils.AGENCYCHANGES){

                    oscar.STEP25__c = 'Not Started';
                } else {

                    oscar.STEP15__c = 'Not Started';
                }

                oscar.Validation_result__c = 'N/A';
                oscar.Validation_Status__c = 'Not Applicable';

            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step5_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step5_failed.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.Reconsideration_result__c = 'Failed';
                oscar.Reconsideration_date__c = Date.today();
                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step5_notApplicable implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step5_notApplicable.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.Reconsideration_result__c = 'N/A';
                oscar.Reconsideration_date__c = Date.today();
                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step20_inProgress implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step20_inProgress.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.Fees_refund_requested__c = Date.today();
                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step23_inProgress implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step23_inProgress.processWork');

            Boolean res = False;

            if (oscar != null) {
                oscar.Fees_refund_requested__c = Date.today();
                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step21_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step21_succeeded.processWork');

            Boolean res = False;

            return res;
        }
    }

    public class AMS_OSCAR_Step16_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step16_succeeded.processWork');
            Boolean res = False;

            if (oscar != null) {

                oscar.Finalization_result__c = 'Passed';

                res = true;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step16_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step16_failed.processWork');
            Boolean res = False;

            if (oscar != null) {

                oscar.Finalization_result__c = 'Failed';

                res = true;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step17_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step17_succeeded.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.AML_performed_date__c = Date.today();
                oscar.AML_result__c = 'Passed';
                if (oscar.STEP9__c == 'Passed')
                    oscar.Process_Start_Date__c = Date.today();
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step17_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step17_failed.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.AML_performed_date__c = Date.today();
                oscar.AML_result__c = 'Failed';
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step17_inProgress implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step17_succeeded.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.AML_requested__c = Date.today();
                oscar.AML_deadline__c = Date.today() + 3;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step18_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step18_succeeded.processWork');
            Boolean res = False;

            if (oscar != null) {

                oscar.Rejection_result__c = 'Passed';
                res = True;

            }

            return res;
        }
    }

    public class AMS_OSCAR_Step18_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step18_failed.processWork');
            Boolean res = False;

            if (oscar != null) {

                oscar.Rejection_result__c = 'Failed';
                res = True;

            }

            return res;
        }
    }

    public class AMS_OSCAR_Step18_notApplicable implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step18_notApplicable.processWork');
            Boolean res = False;

            if (oscar != null) {

                oscar.Rejection_result__c = 'N/A';
                res = True;

            }

            return res;
        }
    }

    public class AMS_OSCAR_Step29_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {

            if (oscar != null && !oscar.Apply_Penalty_Fee__c) {
                //oscar.Apply_Penalty_Fee__c = true;
                return true;
            }

            return false;
        }
    }

    public class AMS_OSCAR_Step30_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {

            if (oscar != null) {
                oscar.Suspension_result__c = 'Failed';
                return true;
            }

            return false;
        }
    }

    public class AMS_OSCAR_Step30_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {

            if (oscar != null) {
                oscar.Suspension_result__c = 'Passed';
                return true;
            }

            return false;
        }
    }

    public class AMS_OSCAR_Step31_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {

            if (oscar != null) {
                oscar.Termination_result__c = 'Failed';
                return true;
            }

            return false;
        }
    }

    public class AMS_OSCAR_Step31_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {

            if (oscar != null) {
                oscar.Termination_result__c = 'Passed';
                return true;
            }

            return false;
        }
    }

    public class AMS_OSCAR_Step32_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {

            if (oscar != null) {
                oscar.Withdrawal_result__c = 'Failed';
                return true;
            }

            return false;
        }
    }

    public class AMS_OSCAR_Step32_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {

            if (oscar != null) {
                oscar.Withdrawal_result__c = 'Passed';
                return true;
            }

            return false;
        }
    }

    public class AMS_OSCAR_Step32_notApplicable implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {

            if (oscar != null) {
                oscar.Withdrawal_result__c = 'N/A';
                return true;
            }

            return false;
        }
    }

    public class AMS_OSCAR_Step35_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step35_succeeded.processWork');

            Boolean res = False;

            if (oscar != null) {
                oscar.Bank_Guarantee_received__c = Date.today();
                oscar.Financial_security_result__c = 'Valid';
                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step35_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step35_failed.processWork');

            Boolean res = False;

            if (oscar != null) {
                oscar.Bank_Guarantee_received__c = Date.today();
                oscar.Financial_security_result__c = 'Rejected';
                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step35_notApplicable implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step35_notApplicable.processWork');

            Boolean res = False;

            if (oscar != null) {
                oscar.Financial_security_result__c = 'N/A';
                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step36_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step36_succeeded.processWork');
            Boolean res = False;

            if(oscar.Process__c == AMS_Utils.NGCHANGES && ANG_AgencyChangesHelper.containsChange(new List<String>(AMS_Utils.changesRequiringManagerApproval),oscar.ANG_Type_Of_Change__c) && oscar.RPM_Approval__c <> AMS_Utils.AUTH_APPROVAL)
                oscar.addError('Cannot set risk event to passed because manager approval is not authorized.');

            if (oscar != null) {
            
                res = True;
            }

            return res;
        }
    }
    
    public class AMS_OSCAR_Step38_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step38_succeeded');
            String[] result = ANG_OscarProcessHelper.processRestrictFOP(oscar.id, oscar.ANG_Restrict_Credit_Card__c, oscar.ANG_Restrict_Cash__c);
            if ('0' != result[0]) oscar.addError(result[1]);
           
           return '0' == result[0];
        }
    }

    public class AMS_OSCAR_Step39_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step39_succeeded');
           String[] result = ANG_OscarProcessHelper.processRestoreFOP(oscar.id, oscar.ANG_Restore_Credit_Card__c, oscar.ANG_Restore_Cash__c);
           if ('0' != result[0]) oscar.addError(result[1]);
           
           return '0' == result[0];
        }
    }

    public class AMS_OSCAR_Step41_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step41_failed.processWork');

            Boolean res = False;

            if (oscar != null) {

                oscar.IRIS_update_result__c = 'Failed';

                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step41_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step41_succeeded.processWork');

            Boolean res = False;


            if (oscar != null) {

                oscar.IRIS_update_result__c = 'Passed';

                res = True;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step42_succeeded implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step42_succeeded.processWork');
            Boolean res = False;

            if (oscar != null) {

                oscar.Finalization_result__c = 'Passed';

                res = true;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step42_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step42_failed.processWork');
            Boolean res = False;

            if (oscar != null) {

                oscar.Finalization_result__c = 'Failed';

                res = true;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step46_passed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step46_passed.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.Process_Start_Date__c = Date.today();
                res = true;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step47_passed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step47_passed.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.Payment_requested__c = Date.today();
                oscar.Invoice_deadline__c = Date.today() + 7;

                oscar.STEP48__c = 'In Progress';

                res = true;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step48_passed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step48_passed.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.Proof_of_payment_received__c = Date.today();
                oscar.Invoice_status__c = 'Paid';


                res = true;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step48_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step48_failed.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.Proof_of_payment_received__c = Date.today();
                oscar.Invoice_status__c = 'Outstanding';

                res = true;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step48_notApplicable implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step48_notApplicable.processWork');
            Boolean res = False;

            if (oscar != null) {
                oscar.Invoice_status__c = 'N/A';

                res = true;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step49_passed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step49_passed.processWork');
            Boolean res = False;

            if (oscar != null) {

                if(oscar.Endorsement_Requested__c)  oscar.Endorsement_requested_date__c = Date.today();
                res = true;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step50_passed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step50_passed.processWork');
            Boolean res = False;

            if (oscar != null) {

                oscar.Financial_Security_Received__c = Date.today();
                res = true;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step50_failed implements IClassFactory {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar) {
            system.debug('Start AUTOMATION AMS_OSCAR_Step50_failed.processWork');
            Boolean res = False;

            if (oscar != null) {

                oscar.Financial_Security_Received__c = Date.today();
                res = true;
            }

            return res;
        }
    }

}