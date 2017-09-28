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
*           Version date:           Case Number:        Author:                                 Description:
*       ------------------------------------------------------------------------------------------------------------------------------------------
*           22_09_2017									Francisco Estanqueiro					Fix the filter on case (ori.Origin.contains('Portal'))          
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
            
            Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Cases (IDFS ISS)').getRecordTypeId();
            Group grp = new Group();
            grp = [select Id, Name from Group where Name = 'AI Template Team' and Type = 'Queue'];
            
            Case ori = new Case();
            ori = [Select Id, Origin from Case where Id =: caseId];
           
            
                Case aux = new case();
                aux.recordtypeId = devRecordTypeId;
                aux.ParentId = caseId;
                
                aux.CaseArea__c = 'Customer Service';
                aux.Reason1__c = 'AI Template';
                
                if(ori.Origin.contains('Chat')){
                    aux.Subject = 'New Template for Chat';
                }else if(ori.Origin.contains('Portal')){
                    aux.Subject = 'New Template for Comment';
                }else{
                    aux.Subject = 'New Template';
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