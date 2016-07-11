public with sharing class Term_And_Condition_Svc 
{
    public static void validateTnC(Map<Id, Term_And_Condition__c> oldTerms, List<Term_And_Condition__c> newTerms)
    {
        Attachment_sel attachmentSelector = new Attachment_sel(); 

        for(Term_And_Condition__c term : newTerms)
        {
            //-- Effective Date must not be in the past (onInsert) or change to past date(onUpdate) 
            if(oldTerms == null)
            {
                //-- onInsert
                if(term.Effective_Start_Date__c < Date.today()) term.addError('Effective Date cannot be in the past');
                if(term.Status__c == 'Final') term.addError('Status cannot be Final unless the T&C has an attachment');
            }
            else
            {
                //-- onUpdate 
                Term_And_Condition__c oldTerm = oldTerms.get(term.Id); 
                
                if(term.Effective_Start_Date__c < Date.today() && (term.Effective_Start_Date__c != oldTerm.Effective_Start_Date__c)) term.addError('Effective Date cannot be in the past');

                Map<Id, List<Attachment>> attachmentsByParent =  attachmentSelector.getAttachments(oldTerms.keySet());

                //-- Has no Attachment 
                if(!attachmentsByParent.containsKey(term.Id) && term.Status__c == 'Final') term.addError('Status cannot be Final unless the T&C has an attachment');

                //-- If New Version then flag Notify Customer On T&C Changed checkbox 
                if(term.Version_Number__c > 1) 
                    term.Attachment_Changed__c = true;
            }
        }
    }

    /****************************************************************************************************
        Created by David D 02/2016
            Notify customers for changes in the T&C if they have auto renew on
    ****************************************************************************************************/
    public static void notifyAutoRenewCustomers(List<Term_And_Condition__c> newTerms)
    {
       
    } 

    /****************************************************************************************************
        Created by David D 02/2016
            return T&C which becomes final
    ****************************************************************************************************/
    public static List<Term_And_Condition__c> getFinalTerms(Map<Id, Term_And_Condition__c> oldTerms, List<Term_And_Condition__c> newTerms)
    {
        List<Term_And_Condition__c> ret = new List<Term_And_Condition__c>(); 

        for(Term_And_Condition__c term : newTerms)
        {
            Term_And_Condition__c oldTerm = oldTerms.get(term.Id); 

            //-- If Status became Final
            if(oldTerm.Status__c != term.Status__c && term.Status__c == 'Final' && term.Attachment_Changed__c == true)
            {
                ret.add(term);
            }
        }

        return ret;
    }

}