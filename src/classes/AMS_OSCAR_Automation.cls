public with sharing class AMS_OSCAR_Automation 
{
    // Class Factory template
    public interface IClassFactory
    {
        Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar);
    }

    //OK
    public class AMS_OSCAR_Step6_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step6_succeeded.processWork');

            Boolean res = False;

            try{

                if(oscar != null){
                    oscar.Sanity_check_received__c = Date.today();
                    oscar.Process_Start_Date__c = Date.today();
                    oscar.Sanity_check_results__c = AMS_Utils.PASSED;
                    res = True;
                    
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step6_failed implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step6_failed.processWork');

            Boolean res = False;

            try{

                if(oscar != null){
                    oscar.Sanity_check_received__c = Date.today();
                    if(oscar.Process__c == AMS_Utils.new_TIDS)
                        oscar.Sanity_check_deadline__c = Date.today()+3;
                    else{
						List<Account> oscarAccount = new List<Account>([select Location_Class__c from Account where id =: oscar.Account__c]);
						if(oscar.Process__c == AMS_Utils.new_HO && (oscarAccount.get(0).Location_Class__c == 'C' || oscarAccount.get(0).Location_Class__c == 'I' || oscarAccount.get(0).Location_Class__c == 'P' || oscarAccount.get(0).Location_Class__c == 'Q')){                    
							oscar.Sanity_check_deadline__c = Date.today() + 15;
						}
						else if(oscar.Process__c == AMS_Utils.new_BR || oscar.Process__c == AMS_Utils.new_BR_ABROAD || oscar.Process__c == AMS_Utils.new_SA || oscarAccount.get(0).Location_Class__c == 'R'){
							oscar.Sanity_check_deadline__c = Date.today() + 14;
						}
                    }

					oscar.Sanity_check_results__c = AMS_Utils.FAILED;
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }
    
    //STEP WAS REMOVED
    public class AMS_OSCAR_Step7_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step7_succeeded.processWork');

            Boolean res = False;

            try{

                if(oscar != null){

                    oscar.IRIS_update_result__c = 'Passed';

                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }
    
    public class AMS_OSCAR_Step7_failed implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step7_failed.processWork');

            Boolean res = False;

            try{

                if(oscar != null){

                    oscar.IRIS_update_result__c = 'Failed';

                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step8_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step8_succeeded.processWork');

            Boolean res = False;

            try{

                if(oscar != null){
                    
                    oscar.STEP9__c = 'In Progress';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step8_inProgress implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step8_inProgress.processWork');

            Boolean res = False;

            try{

                if(oscar != null){
                    
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step9_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step9_succeeded.processWork');

            Boolean res = False;

            try{

                if(oscar != null){
                    oscar.Proof_of_payment_received__c = Date.today();
                    oscar.Invoice_status__c = 'Paid';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step9_failed implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step9_failed.processWork');

            Boolean res = False;

            try{

                if(oscar != null){
                    oscar.Invoice_status__c = 'Outstanding';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step9_notApplicable implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step9_notApplicable.processWork');

            Boolean res = False;

            try{

                if(oscar != null){
                    oscar.Invoice_status__c = 'N/A';
                    res = True;
                }
            }catch(Exception e){
                res = False;
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

    public class AMS_OSCAR_Step11_inProgress implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step11_inProgress.processWork');

            Boolean res = False;

            try{
                //AMS_OSCAR__c objLifecycleRequest = [Select Id, Change_effective_as_of__c from AMS_OSCAR__c where Agency__c = :agencyId];

                if(oscar != null){
                    oscar.Financial_Assessment_requested__c = Date.today();
                    oscar.Financial_Assessment_deadline__c = Date.today() + 5;
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step12_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step12_succeeded.processWork');

            Boolean res = False;

            try{

                if(oscar != null){
                    oscar.Bank_Guarantee_received__c = Date.today();
                    oscar.Financial_security_result__c = 'Valid';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step12_failed implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step12_failed.processWork');

            Boolean res = False;

            try{

                if(oscar != null){
                    oscar.Bank_Guarantee_received__c = Date.today();
                    oscar.Financial_security_result__c = 'Rejected';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step12_notApplicable implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step12_notApplicable.processWork');

            Boolean res = False;

            try{

                if(oscar != null){
                    // JH: Removed to fix INC255865 
                        // oscar.Bank_Guarantee_received__c = Date.today();
                    oscar.Financial_security_result__c = 'N/A';
                    res = True;
                }
            }catch(Exception e){
                res = False;
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
    public class AMS_OSCAR_Step13_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step13_succeeded.processWork');

            Boolean res = False;

            try{

                if(oscar != null){
                    oscar.Local_Inspection_received__c = Date.today();
                    oscar.Local_Inspection_compliant__c = 'Passed';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step13_failed implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step13_failed.processWork');

            Boolean res = False;

            try{
                //AMS_OSCAR__c objLifecycleRequest = [Select Id, Change_effective_as_of__c from AMS_OSCAR__c where Agency__c = :agencyId];

                if(oscar != null){
                    oscar.Local_Inspection_received__c = Date.today();
                    oscar.Local_Inspection_compliant__c = 'Failed';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step13_inProgress implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step13_inProgress.processWork');

            Boolean res = False;

            try{

                if(oscar != null){
                    oscar.Local_Inspection_requested__c = Date.today();
                    oscar.Local_Inspection_deadline__c = Date.today() + 10;
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step13_notApplicable implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step13_notApplicable.processWork');

            Boolean res = False;

            try{

                if(oscar != null){
                    oscar.Local_Inspection_compliant__c = 'N/A';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step14_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step14_succeeded.processWork');

            Boolean res = False;

            try{

                if(oscar != null){
                    oscar.PSAA_EACP_Agreement_received__c = Date.today();
                    oscar.Agreement_result__c = 'Passed';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step14_failed implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step14_failed.processWork');

            Boolean res = False;

            try{

                if(oscar != null){
                    oscar.PSAA_EACP_Agreement_received__c = Date.today();
                    oscar.Agreement_result__c = 'Failed';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step14_inProgress implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step14_inProgress.processWork');

            Boolean res = False;

            try{

                if(oscar != null){
                    oscar.Agreement_requested__c = Date.today();
                    if(oscar.Process__c==AMS_Utils.new_GSA_BSP || oscar.Process__c==AMS_Utils.new_AHA_BSP || oscar.Process__c==AMS_Utils.new_GSSA)
                        oscar.Agreement_deadline__c = Date.today();
                    else
                        oscar.Agreement_deadline__c = Date.today()+10;

                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step14_notApplicable implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step14_notApplicable.processWork');

            Boolean res = False;

            try{

                if(oscar != null){
                    oscar.Agreement_result__c = 'N/A';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }
    
    public class AMS_OSCAR_Step10_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step10_succeeded.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.AIMS_updated__c = DateTime.now();
                    oscar.Invoice_Requested__c = Date.today();
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }
            return res;
        }
    }
    
    //OK
    public class AMS_OSCAR_Step15_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step15_succeeded.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.Dossier_Validation__c = Date.today();
                    oscar.Validation_result__c = 'Passed';
                    oscar.Status__c = 'Pending Approval';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }
            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step15_failed implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step15_failed.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.Dossier_Validation__c = Date.today();
                    oscar.Validation_result__c = 'Failed';
                    oscar.Status__c = 'On Hold_Internal';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }
            return res;
        }
    }

    public class AMS_OSCAR_Step15_notApplicable implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step15_notApplicable.processWork');
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
    }
    
     //OK
    public class AMS_OSCAR_Step25_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step25_succeeded.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.Dossier_Validation__c = Date.today();
                    oscar.Validation_result__c = 'Passed';
                    oscar.Status__c = 'Pending Approval';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }
            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step25_failed implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step25_failed.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.Dossier_Validation__c = Date.today();
                    oscar.Validation_result__c = 'Failed';
                    oscar.Status__c = 'On Hold_Internal';
                    res = True;
                }
            }catch(Exception e){
                res = False;
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
    public class AMS_OSCAR_Step2_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step2_succeeded.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                   
                    oscar.Approval_disapproval_date__c = Date.today();
                    oscar.Status__c = 'On Hold_Internal';
                    res = True;
                    
                }
            }catch(Exception e){
                system.debug('ERROR: '+e);
                res = False;
            }
            return res;
        }
    }
    
    //OK
    public class AMS_OSCAR_Step2_failed implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step2_failed.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                   
                    oscar.Approval_disapproval_date__c = Date.today();
                    oscar.Status__c = 'On Hold_Internal';
                    res = True;
                    
                }
            }catch(Exception e){
                system.debug('ERROR: '+e);
                res = False;
            }
            return res;
        }
    }
    
    //OK
    public class AMS_OSCAR_Step1_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step1_succeeded.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                   
                    oscar.Finalization_result__c = 'Passed';
                    res = True;
                    
                }
            }catch(Exception e){
                system.debug('ERROR: '+e);
                res = False;
            }
            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step1_failed implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step1_failed.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                   
                    oscar.Finalization_result__c = 'Failed';
                    res = True;
                    
                }
            }catch(Exception e){
                system.debug('ERROR: '+e);
                res = False;
            }
            return res;
        }
    }

    public class AMS_OSCAR_Step1_notApplicable implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step1_notApplicable.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                   
                    oscar.Finalization_result__c = 'N/A';
                    res = True;
                    
                }
            }catch(Exception e){
                system.debug('ERROR: '+e);
                res = False;
            }
            return res;
        }
    }
    
    //OK
    public class AMS_OSCAR_Step3_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step3_succeeded.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.Disapproval_result__c = 'Passed';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }
            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step3_failed implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step3_failed.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.Disapproval_result__c = 'Failed';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }
            return res;
        }
    }

    public class AMS_OSCAR_Step3_notApplicable implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step3_notApplicable.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.Disapproval_result__c = 'N/A';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }
            return res;
        }
    }
    
    //OK
    public class AMS_OSCAR_Step4_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step4_succeeded.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.Withdrawal_result__c = 'Passed';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }
            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step4_failed implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step4_failed.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.Withdrawal_result__c = 'Failed';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }
            return res;
        }
    }

    public class AMS_OSCAR_Step4_notApplicable implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step4_notApplicable.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.Withdrawal_result__c = 'N/A';
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }
            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step5_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step5_succeeded.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.Reconsideration_result__c = 'Passed';
                    oscar.Reconsideration_date__c = Date.today();
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }
            return res;
        }
    }

    //OK
    public class AMS_OSCAR_Step5_failed implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step5_failed.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.Reconsideration_result__c = 'Failed';
                    oscar.Reconsideration_date__c = Date.today();
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }
            return res;
        }
    }

    public class AMS_OSCAR_Step5_notApplicable implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step5_notApplicable.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.Reconsideration_result__c = 'N/A';
                    oscar.Reconsideration_date__c = Date.today();
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }
            return res;
        }
    }
    
    public class AMS_OSCAR_Step20_inProgress implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step20_inProgress.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.Fees_refund_requested__c = Date.today();
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }
            return res;
        }
    }

     public class AMS_OSCAR_Step23_inProgress implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step23_inProgress.processWork');

            Boolean res = False;

            try{
              
                if(oscar != null){
                    oscar.Fees_refund_requested__c = Date.today();
                    res = True;
                }
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

     public class AMS_OSCAR_Step21_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            // ... Class-specific work goes here
            system.debug('Start AUTOMATION AMS_OSCAR_Step21_succeeded.processWork');

            Boolean res = False;

            try{
            
            }catch(Exception e){
                res = False;
            }

            return res;
        }
    }

    public class AMS_OSCAR_Step16_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step16_succeeded.processWork');
            Boolean res = False;
            try{
                if(oscar != null){

                    oscar.Finalization_result__c = 'Passed';

                    res = true;
                }
            }catch(Exception e){
                system.debug('ERROR: '+e);
                res = False;
            }
            return res;
        }
    }

    public class AMS_OSCAR_Step16_failed implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step16_failed.processWork');
            Boolean res = False;
            try{
                if(oscar != null){

                    oscar.Finalization_result__c = 'Failed';
                    
                    res = true;
                }
            }catch(Exception e){
                system.debug('ERROR: '+e);
                res = False;
            }
            return res;
        }
    }

    public class AMS_OSCAR_Step17_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step17_succeeded.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.AML_performed_date__c = Date.today();
                    oscar.AML_result__c = 'Passed';
                }
            }catch(Exception e){
                system.debug('ERROR: '+e);
                res = False;
            }
            return res;
        }
    }

    public class AMS_OSCAR_Step17_failed implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step17_failed.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.AML_performed_date__c = Date.today();
                    oscar.AML_result__c = 'Failed';
                }
            }catch(Exception e){
                system.debug('ERROR: '+e);
                res = False;
            }
            return res;
        }
    }

    public class AMS_OSCAR_Step17_inProgress implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step17_succeeded.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                    oscar.AML_requested__c = Date.today();
                    oscar.AML_deadline__c = Date.today()+3;
                }
            }catch(Exception e){
                system.debug('ERROR: '+e);
                res = False;
            }
            return res;
        }
    }

    public class AMS_OSCAR_Step18_succeeded implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step18_succeeded.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                   
                    oscar.Rejection_result__c = 'Passed';
                    res = True;
                    
                }
            }catch(Exception e){
                system.debug('ERROR: '+e);
                res = False;
            }
            return res;
        }
    }

    public class AMS_OSCAR_Step18_failed implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step18_failed.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                   
                    oscar.Rejection_result__c = 'Failed';
                    res = True;
                    
                }
            }catch(Exception e){
                system.debug('ERROR: '+e);
                res = False;
            }
            return res;
        }
    }

    public class AMS_OSCAR_Step18_notApplicable implements IClassFactory
    {
        public Boolean processWork(AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar)
        {
            system.debug('Start AUTOMATION AMS_OSCAR_Step18_notApplicable.processWork');
            Boolean res = False;
            try{
                if(oscar != null){
                   
                    oscar.Rejection_result__c = 'N/A';
                    res = True;
                    
                }
            }catch(Exception e){
                system.debug('ERROR: '+e);
                res = False;
            }
            return res;
        }
    }

}