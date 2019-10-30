public without sharing class ISSP_HierarchyAccountTeamAccounts {
    
    /*
    * Finds the hierarchy members of the inserted(or owner changed) accounts 
    * And calls the function which creates the AccountShares 
    * Importent : The "Top Parent" doesn't have a refrence to himself it's not allowed in SalesForce
    */
    public static map<Id,Id> accUserMap;
    public static map<Id,set<string>> accCountryMap;
    
    @future 
    public static void HierarchyAccountTeamMemberAccounts(set<Id> userIdSet){
        HierarchyAccountTeamMemberAccountsAcc(userIdSet);
    }
    
    @future 
    public static void deleteHierarchyAccountTeamMemberAccounts(set<Id> userIdSet){
        delete [select Id from AccountTeamMember where UserId in:userIdSet and TeamMemberRole =:'Portal Administrator'];
    }
    
    public static void HierarchyAccountTeamMemberAccountsAcc(set<Id> userIdSet){
        
        list<User> userList = [select Id,ContactId from User where Id in:userIdSet ];
        List<AccountTeamMember> accountTeamMemberList = new List<AccountTeamMember>();
        accUserMap = new map<Id,Id>();
        accCountryMap = new map<Id,set<string>>();
        map<Id,Id> ContactIduserIdMap = new map<Id,Id>();
        String portaluserstatus = '';
        
        for(User user : userList){
            ContactIduserIdMap.put(user.ContactId,user.Id);
        }
        
        for(Contact con : [select Id,Account.Top_Parent__c,AccountId,User_Portal_Status__c,Regional_Administrator_Countries__c from Contact where Id in:ContactIduserIdMap.keySet()]){
            
            portaluserstatus = con.User_Portal_Status__c;
             system.debug('\n\n\n\n User_Portal_Status__c: '+con.User_Portal_Status__c+'\n\n\n\n');
              system.debug('\n\n\n\n Regional_Administrator_Countries__c: '+con.Regional_Administrator_Countries__c+'\n\n\n\n');
            
            if(con.Regional_Administrator_Countries__c == null)
                con.Regional_Administrator_Countries__c ='';
            if(con.Account.Top_Parent__c!=null){
                accUserMap.put(con.Account.Top_Parent__c,ContactIduserIdMap.get(con.Id));
                if(con.User_Portal_Status__c == 'Regional Administrator'){
                    accCountryMap.put(con.Account.Top_Parent__c,new set<string>(con.Regional_Administrator_Countries__c.split(';')));
                }
            }
            else if(con.AccountId!=null){
                accUserMap.put(con.AccountId,ContactIduserIdMap.get(con.Id));
                if(con.User_Portal_Status__c == 'Regional Administrator'){
                    accCountryMap.put(con.AccountId,new set<string>(con.Regional_Administrator_Countries__c.split(';')));
                }
            }
        }
        system.debug('\n\n\n\n accUserMap: '+accUserMap+'\n\n\n\n');
        system.debug('\n\n\n\n accCountryMap: '+accCountryMap+'\n\n\n\n');
        
        Map<Id,Account> AccountsWithHierarchies = new Map<id,Account>([Select id,ownerId, Top_Parent__c,IATA_ISO_Country__r.Name, (Select id,OwnerId,Top_Parent__c,IATA_ISO_Country__r.Name From Accounts__r) From Account a Where id in:accUserMap.keySet()]);
        List<Account> temp = new List<Account>();
        for(Account acc : AccountsWithHierarchies.values()){
        
        
                system.debug('\n\n\n\n acc.Id: '+acc.Id+'\n\n\n\n');
                //Adds the "Top Parent" himself to the list
                temp.add(AccountsWithHierarchies.get(acc.Id));
                //Adds the list of the descendants of 'acc.Top_Parent'
                if(portaluserstatus != 'Regional Administrator'){
                    temp.addAll(AccountsWithHierarchies.get(acc.Id).Accounts__r);
                }
                //Making AccountShares for the owners of the acounts in the hierarchy.
                system.debug('\n\n\n\n temp'+temp+'\n\n\n\n');
                if(temp.size()>0)
                    accountTeamMemberList.addAll(createAccountTeamMember(temp));
                system.debug('\n\n\n\n accountTeamMemberList'+accountTeamMemberList+'\n\n\n\n');
                temp.clear();
        }


        //used in method 'DataBase.insert' instead of 'insert' because,
        //in Case that specific AccountShare already exist it will not stop the insert operation
        Database.SaveResult[] Errors = DataBase.insert(accountTeamMemberList,false);
        
        
        system.debug('\n\n Errors:'+Errors+'\n\n');
        
        Integer newcnt=0;
        AccountShare[] newShare = new AccountShare[]{};  //list of new shares to add
        for(Database.SaveResult sr:Errors){
            if(!sr.isSuccess()){
                Database.Error emsg =sr.getErrors()[0];
                system.debug('\n\n ERROR ADDING TEAM MEMBER:'+emsg);
            }else{
                newShare.add(new AccountShare(UserOrGroupId=accountTeamMemberList[newcnt].UserId, AccountId=accountTeamMemberList[newcnt].Accountid,ContactAccessLevel='Edit', AccountAccessLevel='Edit',CaseAccessLevel='Read',OpportunityAccessLevel='None'));
            }
            newcnt++;           
        }
        
        Database.SaveResult[] lsr0 =Database.insert(newShare,false); //insert the new shares
        Integer newcnt0=0;
        for(Database.SaveResult sr0:lsr0){
            if(!sr0.isSuccess()){
                 Database.Error emsg0=sr0.getErrors()[0];
                 system.debug('\n\n ERROR ADDING SHARING:'+newShare[newcnt0]+'::'+emsg0);
            }
            newcnt0++;
         }
        
    }
    
    /*
    * parameters: list of every account in hierarchy
    */
    public static List<AccountTeamMember> createAccountTeamMember(List<Account> Hierarchy){ 
        List<AccountTeamMember> accountTeamMemberList = new List<AccountTeamMember>(); 
        for(Account acc : Hierarchy){
                    if(accCountryMap.containsKey(acc.Top_Parent__c) || accCountryMap.containsKey(acc.Id)){
                        set<string> tSet = accCountryMap.get(acc.Top_Parent__c);
                        if(tSet == null)
                            tSet = accCountryMap.get(acc.Id);
                        if(!tSet.contains(acc.IATA_ISO_Country__r.Name))
                            continue;
                    }
                    AccountTeamMember AccTeamMember = new AccountTeamMember();
                    AccTeamMember.AccountId = acc.Id;
                    AccTeamMember.UserId = accUserMap.get(acc.Top_Parent__c);
                    if(AccTeamMember.UserId==null)
                         AccTeamMember.UserId = accUserMap.get(acc.Id);
                     AccTeamMember.TeamMemberRole = 'Portal Administrator';
                    accountTeamMemberList.add(AccTeamMember);
       }
       
       system.debug('\n\n creatAccountTeamMember => accountTeamMemberList:'+accountTeamMemberList+'\n\n');
       return accountTeamMemberList; 
    }
}