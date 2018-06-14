@istest
private class MemberContactsCsvTest{
    
    
    static Blob buildContentFile(){
    
        /*return blob.valueOf(    '"BUSINESS AREA*","NAME","JOB TITLE","TELEPHONE","FAX","E-MAIL","GENERIC E-MAIL "' +'\n'+
                                '"IATA Liaison","management","","","","management@gmail.com",""'+'\n'+
                                '"CEO","management","asdasd","asdasda","asds","management@gmail.com",""'+'\n'+
                                '"Gen. Management","nono","tsetdedt","teerrtert","erterter","nono@gmail.com",""' +'\n'+
                                '"Gen. Management","","","","","",""');
        */
        
        return blob.valueOf('"Type of Contact","Salutation","First Name","Last Name","Job Title","Email Address","Country Code","Phone","Fax"'+'\n'+
                                        '"Main Contact","qwe","qwewqe","wewqe","weqwqeeq","qwewqe@gmail.com","","123123","123123"'+'\n'+
                                    '"Chief Executive Officer","","","","","","","",""');
    }
    
    static testMethod void runPositive() {
        Account a = new account(name ='my account');
        insert a;
        
        PageReference pageRef = Page.ContactMembers;
        Test.setCurrentPage(pageRef);
        
        Apexpages.currentPage().getparameters().put('acctID',a.id);
        MemberContactsCsv controller = new MemberContactsCsv();
        controller.contentFile = buildContentFile();
        controller.next();
        controller.save();
        list<Contact> contacts = [Select id, name from contact ];
        system.assertEquals(contacts.size(),1);
        
    }
}