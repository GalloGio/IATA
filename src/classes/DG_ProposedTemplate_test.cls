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
*           22_09_2017									Francisco Estanqueiro					Fix the filter on case (c.Origin = 'Portal')       
*
*****************************************************************************************************************************************************
*/

@isTest
public with sharing class DG_ProposedTemplate_test{

    static testMethod void ProposedTemplate_test(){
    
        String message='Test';
        Case c = new Case();
        c.Origin = 'Chat';
        insert c;
        
        ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(c);        
        DG_ProposedTemplateControler controller = new DG_ProposedTemplateControler(std);
        
        DG_ProposedTemplateControler.newCase(message, c.Id);
        
        list<Case> total = [Select Id from case];
        System.assertEquals(2, total.size());
        
    }

    static testMethod void ProposedTemplate_test2(){
    
        String message='Test';
        Case c = new Case();
        c.Origin = 'Portal';
        insert c;
        
        ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(c);        
        DG_ProposedTemplateControler controller = new DG_ProposedTemplateControler(std);
        
        DG_ProposedTemplateControler.newCase(message, c.Id);
        
        list<Case> total = [Select Id from case];
        System.assertEquals(2, total.size());
        
    }


}