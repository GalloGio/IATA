@isTest
private class AMS_IataCodeRangeLoaderCtrl_Test {

    static testMethod void TestLoading() {
    	//Create country used in csv imported
    	IATA_ISO_Country__c c = new IATA_ISO_Country__c(Name = 'AFGHANISTAN', ISO_Code__c = 'AF');
    	
    	insert c; 
    	
    	test.StartTest();
    	
    	string sFileContent = 'Country Code;Country Description;State Code;State Description;Country State Code;State Number;Class Code;Class Description;Prefix;MIN Area Code;MIN Last four;MAX Area Code;MAX Last four;MIN-MAX area code differ?;';
		sFileContent += '\r\nAF;AFGHANISTAN;AF01;AFGHANISTAN;AF;01;C;CARGO;01;3;0001;3;6999;;'; //will be imported
		sFileContent += '\r\nAF;AFGHANISTAN;AF01;AFGHANISTAN;AF;01;C;CARGO;01;4;0001;5;6999;;'; //2 records imported
		sFileContent += '\r\nAF;AFGHANISTAN;AF01;AFGHANISTAN;AF;01;C;CARGO;01;3;0001;3;6999;;'; //not imported. Generate error (duplicate)
		sFileContent += '\r\nIT;ITALY;IT01;ITALY;IT;01;G;GSA;01;3;8000;3;8999;;'; //will generate error (coutnry not existing)
		
    	PageReference pf;
    	AMS_IataCodeRangesLoaderCtrl ctrl = new AMS_IataCodeRangesLoaderCtrl();
    	
    	//No file provided. Receive Error
    	pf = ctrl.importCSVFile();
    	system.assert(ctrl.sMessage == 'Please provide a valid file');
    	
    	//File Provided, but is not a CSV. Receive error
    	ctrl.csvFileBody = Blob.ValueOf(sFileContent);
    	ctrl.FileName = 'NotWorking.xls';
    	pf = ctrl.importCSVFile();
    	system.assert(ctrl.sMessage == 'Only CSV file are allowed');
    	
    	//File Provided. It's a CSV, it's loaded
    	ctrl.FileName = 'working.csv';
    	pf = ctrl.importCSVFile();
    	system.assert(ctrl.sMessage == '');
    	system.assert(ctrl.RowsInFile == 4);
    	system.assert(ctrl.lsCodeToLoad.size()==4);
    	system.assert(ctrl.mapCSVErrors.size()==1);
    	
    	//Import file
    	pf = ctrl.SaveRecord();
    	
    	system.assert(ctrl.SuccessNumber==3);
    	system.assert(ctrl.ErrorNumber==2);
    	system.assert(ctrl.sMessage == 'Some errors occoured. Please check errors\' file');
    	
    	//Just test open page resutl
    	pf = ctrl.SaveCSVSuccess();
    	pf = ctrl.SaveCSVErrors();
    	pf = ctrl.StartAgain();
    	
    	test.StopTest();
    }
}