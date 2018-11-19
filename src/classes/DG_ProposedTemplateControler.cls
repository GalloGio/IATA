/*
***************************************************************************************************************************************************** 
* Visualforce Page Name:    DG_ProposedTemplate.page    
* Apex class Name:          DG_ProposedTemplateControler.cls
* Test Class:               DG_ProposedTemplate_test.cls
* Description:              Page used to create a new case with a proposed template and to be used in customer responses 
*							(e-mail and chat) and AI training
* Author:                   Right IT Services
* Date:                     09/2017
* 
* Changes control (When, Why, Who, What):
*       ------------------------------------------------------------------------------------------------------------------------------------------
*           Version date:       Case Number:        Author:                                 Description:
*       ------------------------------------------------------------------------------------------------------------------------------------------
*           22_09_2017								Francisco Estanqueiro					Fix the filter on case (ori.Origin.contains('Portal')) 
*			13_10_2017								Francisco Estanqueiro					Add the parent case to the subject instead of the ParentId field           
*
*****************************************************************************************************************************************************
*/


global with sharing class DG_ProposedTemplateControler{
    
    private final Case c;
    
    // empty constructor
    public DG_ProposedTemplateControler()
    {
    }
    
    public DG_ProposedTemplateControler(ApexPages.StandardController stdController)
    {
        this.c = (Case)stdController.getRecord();
    }
    
    @RemoteAction
    global static Case newCase(String template, String caseId){
    
        if(template!= '' && template != null){
            
            Id devRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'InternalCasesEuropeSCE');//Internal Cases (IDFS ISS)
            Group grp = new Group();
            grp = [select Id, Name from Group where Name = 'AI Template Team' and Type = 'Queue'];
            
            Case ori = new Case();
            ori = [Select Id, Origin, CaseNumber from Case where Id =: caseId];
           
            
                Case aux = new case();
                aux.recordtypeId = devRecordTypeId;
                //aux.ParentId = caseId;
                
                aux.CaseArea__c = 'Customer Service';
                aux.Reason1__c = 'AI Template';
                
                if(ori.Origin.contains('Chat')){
                    aux.Subject = 'New Template for Chat (Parent case:'+ ori.CaseNumber+ ')';
                }else if(ori.Origin.contains('Portal')){
                    aux.Subject = 'New Template for Comment (Parent case:'+ ori.CaseNumber+ ')';
                }else{
                    aux.Subject = 'New Template (Parent case:'+ ori.CaseNumber+ ')';
                }
                
                aux.ownerId=grp.Id;
                aux.Description = template;
                
                insert aux;
                
                Case auxr = new Case();
                auxr = [Select Id, CaseNumber from Case where Id =: aux.Id];
                
                return auxr;
                
        }
        
        return null;
        
    }

        
}