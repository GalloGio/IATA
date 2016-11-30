@istest
private class NewRelatedAccountTest {
    
    static testmethod void positive(){
            
             account a = new account(name = 'pippo', iatacode__C = '123',Airline_designator__c = 'AA');
             insert a;
             
             PageReference pageRef = Page.NewRelatedAccount;
             Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('accID',a.id); 
            NewRelatedAccount  controller = new NewRelatedAccount();
            controller.save();
            controller.cancel();
            List<SelectOption> selection = controller.getReasons();
            system.assertNotEquals(selection.size(),0);
            string standardRT= TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string>{'Account'})
                                .get('Account')
                                .get('Standard_Account'); 
            list<Account> stantdardAccts = [select id,name,iatacode__C,Airline_designator__c 
                                            from account 
                                            where recordtypeid =:standardRT];   
                                            
          system.assertEquals(1,stantdardAccts.size());
          system.assertEquals(a.name,stantdardAccts[0].name);
          
    }
    
    
    
        static testmethod void negative(){
            
            PageReference pageRef = Page.NewRelatedAccount;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('accID','bla'); 
           try{ 
            NewRelatedAccount  controller = new NewRelatedAccount();
           }catch(TransformationException e){
                system.assertEquals(e.getMessage().contains('This Page should not be accessed directly or invalid ID'),true);
           
           }
            
          
    }
    

}