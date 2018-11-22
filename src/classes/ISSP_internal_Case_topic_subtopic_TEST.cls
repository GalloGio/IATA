@isTest(SeeAllData=true)
private class ISSP_internal_Case_topic_subtopic_TEST {

	static testMethod void ISSP_internal_Case_topic_subtopic_TEST_1()
	{
		Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
		child.sector__c = 'Airline';
        child.Top_Parent__c = parent.Id;
        insert child;
        System.debug('child Id: ' + child.Id);
        Contact con = ISSP_ObjectFactory.createNewContact();
 
        con.AccountId= child.Id;
		con.Email = 'Test@test11.com';
        insert con;
        System.debug('con Id: ' + con.Id);
         User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

		Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'DPC_Service_Request');
        Case c=new Case(Subject='test 1',Status='Open', AccountId=child.id, ContactId=con.id,Region__c = 'Europe', RecordTypeId = recordTypeId , Topic__c = 'Accreditation_Travel_Agent__c' ,subTopic__c = 'MITA Interline Agreements' , isComplaint__c = false ) ;
        insert c;

		 System.debug('SOS1 c ' + c);

        Test.startTest();
		
		ISSP_FAQ2Case_Record_Type__c cs_rt = new ISSP_FAQ2Case_Record_Type__c();
		cs_rt.Name =	'CSRT1'; 
		cs_rt.Country_concerned_by_the_query__c ='EH,NE,CG,QA,BI,MR,BJ,SD,MW,UG,IR,LB,GA,MZ';
		cs_rt.Topic__c		=	'Accreditation_Travel_Agent__c';
		cs_rt.SubTopic__c	=	'TIESS Banking';
		cs_rt.OwnerId__c	=	newUser.Id;
		cs_rt.RecordType__c =	recordTypeId ;
		cs_rt.Complaint__c = false ;
		insert cs_rt;
		System.debug('SOS1 cs_rt ' + cs_rt);
        System.runAs(newUser)
        {		
			ApexPages.StandardController sc = new ApexPages.StandardController(con);
			ApexPages.currentPage().getParameters().put('Id',c.id);
			ISSP_internal_Case_topic_subtopic ctrl = new ISSP_internal_Case_topic_subtopic(sc);

			ctrl.parentCase = c ;
			//init
			ctrl.pageLoad();
			Integer topCatGroupIndex = getIndexWithChildes(ctrl.DataCategoryContainer);
			ctrl.topic = String.valueOf(topCatGroupIndex);
			System.debug('ctrl.topic: ' + ctrl.topic);
			ctrl.subtopic = getSubCat(ctrl.DataCategoryContainer, topCatGroupIndex);
			System.debug('ctrl.subtopic: ' + ctrl.subtopic);

			ctrl.topic = '1';
			ctrl.subtopic = 'TIESS Banking';
			ctrl.SaveTopicSubtopic();			 
            
            ctrl.myTopic = '123';
            ctrl.topic = '';
            ctrl.subtopic = '';
            ctrl.SaveTopicSubtopic();
            ctrl.topic = '1';
            ctrl.addDecsription();   
            ctrl.isEditMode = true;         
			ctrl.ChangemodeMethod();			
		}

		Test.stopTest();
	}


	  private static Integer getIndex(clsDataCategoryContainer cont) {
    	//controller.DataCategoryContainer.lst_DataCategories[index]
    	return 0;
    }

    private static String getSubCat(clsDataCategoryContainer cont, Integer index) {
    	return cont.lst_DataCategories[index].CategoryName;
    }

    private static Integer getIndexWithChildes(clsDataCategoryContainer cont)
    {
    	for (Integer index = 0; index < cont.lst_DataCategories.size(); ++index)
    	{
    		clsDataCategory cdc = cont.lst_DataCategories[index];
    		if (cdc.lst_childs.size() > 0)
    		{
    			return index;
    		}
    	}

    	return 0;
    }

}