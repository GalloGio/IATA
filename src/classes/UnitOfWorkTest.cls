/**
 * Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

@IsTest
private with sharing class UnitOfWorkTest
{
    // SObjects (in order of dependency) used by UnitOfWork in tests bellow
    private static List<Schema.SObjectType> MY_SOBJECTS =
        new Schema.SObjectType[] {
            Product2.SObjectType,
            PricebookEntry.SObjectType,
            Opportunity.SObjectType,
            OpportunityLineItem.SObjectType };

    private static Id recType = RecordTypeSingleton.getInstance().getRecordTypeId('Opportunity', 'SalesOrder');

    
    @isTest
    private static void testUnitOfWorkNewDirtyDelete()
    {
        // Insert Opportunities with UnitOfWork
        {
            UnitOfWork uow = new UnitOfWork(MY_SOBJECTS);
            for(Integer o=0; o<10; o++)
            {
                Opportunity opp = new Opportunity();
                opp.Name = 'UoW Test Name ' + o;
                opp.StageName = 'Open';
                opp.CloseDate = System.today();
                opp.RecordTypeId = recType;
                uow.registerNew(new List<SObject>{opp});
                for(Integer i=0; i<o+1; i++)
                {
                    Product2 product = new Product2();
                    product.Name = opp.Name + ' : Product : ' + i;
                    uow.registerNew(new List<SObject>{product});
                    PricebookEntry pbe = new PricebookEntry();
                    pbe.UnitPrice = 10;
                    pbe.IsActive = true;
                    pbe.UseStandardPrice = false;
                    pbe.Pricebook2Id = Test.getStandardPricebookId();
                    uow.registerNew(pbe, PricebookEntry.Product2Id, product);
                    OpportunityLineItem oppLineItem = new OpportunityLineItem();
                    oppLineItem.Quantity = 1;
                    oppLineItem.TotalPrice = 10;
                    uow.registerRelationship(oppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
                    uow.registerNew(oppLineItem, OpportunityLineItem.OpportunityId, opp);
                }
            }

            uow.commitWork();
        }

  

        // Records to update
        List<Opportunity> opps = [select Id, Name, (Select Id from OpportunityLineItems) from Opportunity where Name like 'UoW Test Name %' order by Name];

        List<SObjectField> oppFields = new List<SObjectField>{
        	Opportunity.Name
        };
        List<SObjectField> pdFields = new List<SObjectField>{
        	OpportunityLineItem.Quantity,
        	OpportunityLineItem.TotalPrice
        };

        // Update some records with UnitOfWork
        {
            UnitOfWork uow = new UnitOfWork(MY_SOBJECTS);
            
            Opportunity opp = opps[0];
            opp.Name = opp.Name + ' Changed';
            uow.registerDirty(new List<SObject>{opp}, oppFields);
            
            Product2 product = new Product2();
            product.Name = opp.Name + ' : New Product';
            uow.registerNew(new List<SObject>{product});
            
            PricebookEntry pbe = new PricebookEntry();
            pbe.UnitPrice = 10;
            pbe.IsActive = true;
            pbe.UseStandardPrice = false;
            pbe.Pricebook2Id = Test.getStandardPricebookId();
            uow.registerNew(pbe, PricebookEntry.Product2Id, product);

            OpportunityLineItem newOppLineItem = new OpportunityLineItem();
            newOppLineItem.Quantity = 1;
            newOppLineItem.TotalPrice = 10;
            uow.registerRelationship(newOppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
            uow.registerNew(newOppLineItem, OpportunityLineItem.OpportunityId, opp);
            
            
            OpportunityLineItem existingOppLine = opp.OpportunityLineItems[0];
            existingOppLine.Quantity = 2;
            existingOppLine.TotalPrice = 20;
            uow.registerDirty(new List<SObject>{existingOppLine}, pdFields);
            uow.commitWork();
        }

       opps = [select Id, Name, (Select Id, PricebookEntry.Product2.Name, Quantity, TotalPrice from OpportunityLineItems Order By PricebookEntry.Product2.Name) from Opportunity where Name like 'UoW Test Name %' order by Name];

        // Delete some records with the UnitOfWork
        {
            UnitOfWork uow = new UnitOfWork(MY_SOBJECTS);
            uow.registerDeleted(new List<SObject>{opps[0].OpportunityLineItems[1].PricebookEntry.Product2}); // Delete PricebookEntry Product
            uow.registerDeleted(new List<SObject>{opps[0].OpportunityLineItems[1].PricebookEntry}); // Delete PricebookEntry
            uow.registerDeleted(new List<SObject>{opps[0].OpportunityLineItems[1]}); // Delete OpportunityLine Item
            // Register the same deletions more than once.
            // This verifies that using a Map to back the deleted records collection prevents duplicate registration.
            uow.registerDeleted(new List<SObject>{opps[0].OpportunityLineItems[1].PricebookEntry.Product2}); // Delete PricebookEntry Product
            uow.registerDeleted(new List<SObject>{opps[0].OpportunityLineItems[1].PricebookEntry}); // Delete PricebookEntry
            uow.registerDeleted(new List<SObject>{opps[0].OpportunityLineItems[1]}); // Delete OpportunityLine Item
            uow.commitWork();
        }
    }
}