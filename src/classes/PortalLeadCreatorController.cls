public without sharing class PortalLeadCreatorController {

    private static final String LEAD_SOURCE ='CS Portal';
    private static final String OPP_STAGE_NEW ='3. Needs Assessment';
    private static final String OPP_CONT_ROLE ='Purchasing Agent';

    @AuraEnabled
    public static void handleContactRequest(string params){
   
       Map<String,String> dtlsMap = (Map<String,String>)JSON.deserialize(params, Map<String,String>.class);
       
        
        Recommendations_Visibility__c rec=[select id,RecommendationTitle__c,Lead_Queue__c,Opportunity_Owner__c from Recommendations_Visibility__c where Content_Reference__c=:dtlsMap.get('recommendation')];
       
       //Check if there is a contact with the provided Email

       list<contact> contactList=[select id,accountId from contact where email =:dtlsMap.get('email')];
       String genDesc='Product/Service: '+rec.RecommendationTitle__c+'\n Prefered Contact Method: '+dtlsMap.get('method')+' \n Phone Number: '+dtlsMap.get('phone');
       //if no contact found, generate a lead
        if(contactList.isEmpty()){
            //Create Lead
            Lead l = new Lead(
                firstName=dtlsMap.get('firstName'),
                lastName=dtlsMap.get('lastName'),
                country=dtlsMap.get('country'),
                email=dtlsMap.get('email'),
                phone=dtlsMap.get('phone'),
                leadSource=LEAD_SOURCE,
                company=dtlsMap.get('company'),
                description=genDesc
            );

            insert l;

            list<group> queueList=[select id from group where type='Queue' and name=:rec.Lead_Queue__c];
            if(!queueList.isEmpty()){
                l.OwnerId=queueList.get(0).id;
    
                update l;
            }
         }
        else{ 
            //Create opportunity
            string oppDesc='First Name : '+dtlsMap.get('firstName')+'\n'+
            'Last Name : '+dtlsMap.get('lastName')+'\n'+
            'Company : '+dtlsMap.get('company')+'\n'+
            'Country : '+dtlsMap.get('country')+'\n';

            Id rtId=RecordTypeSingleton.getInstance().getRecordType('Opportunity', 'FieldSales').Id;
            Opportunity opp = new Opportunity(
                name=rec.RecommendationTitle__c+' - '+dtlsMap.get('company'),
                recordtypeId=rtId,
                accountId=contactList.get(0).accountId,
                stageName=OPP_STAGE_NEW,
                leadSource=LEAD_SOURCE,
                CloseDate=system.today().addDays(10),
                description=oppDesc+genDesc       
            );
            insert opp;

            //Create opportunity contact role
            opportunityContactRole ocr=new opportunityContactRole(
                opportunityId=opp.id,
                ContactId=contactList.get(0).id,
                Role=OPP_CONT_ROLE
            );
            insert ocr;


            //Reassign to queue/user            
            opp.OwnerId=rec.Opportunity_Owner__c;
            update opp;  
        }

    }

}