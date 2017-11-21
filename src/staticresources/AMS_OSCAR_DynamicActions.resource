var dyn_functions = {
    generateIataCode:function (args) { 
        //$body = $("body");
      
        var result;
        var inspectionRecs;
        var sResult = '';
        
        var argList = args.split(", ");

        var resultOscarData = sforce.connection.query("SELECT Id, AMS_Online_Accreditation__r.Location_Class__c, Account__r.Sector__c,AMS_Online_Accreditation__r.Link_agent_name__c FROM AMS_OSCAR__C WHERE Id ='" + argList[2] + "'");

        var records = resultOscarData.getArray("records");

        if(records[0].AMS_Online_Accreditation__r.Location_Class__c == 'I' && records[0].Account__r.Sector__c == 'Cargo Agent' && records[0].AMS_Online_Accreditation__r.Link_agent_name__c == null ){
            var resultLinkAgent = confirm("The “Link Agent Name” field is not filled. Are you sure you want to proceed ?");
            if(resultLinkAgent == false){
                //$body.removeClass("loading");
                sResult = 'Please fill the Link Agent Name before proceding';
                return 'false';
            }
        }

        resultExecution = sforce.apex.execute("ANG_OscarProcessHelper", "processIATACodeGeneration", {accountId: argList[0], onlineAccreditationId: argList[1],oscarId :argList[2]});

        if(resultExecution[2] == '0'){ // Due Diligence Case created
            
            var changeTab = function(result){
                if(result.success == true){
                }
            };

            var openSubtab = function(result)
            {               
                sforce.console.openSubtab(result.id, '/'+resultExecution[3], true, 'Due Diligence Case', null, changeTab);

            };
            sforce.console.getEnclosingPrimaryTabId(openSubtab);

        }

        var ifapPSR;

		if (records.length > 0 && resultExecution[0] == '0') { // IATA Code created
			var result4 = sforce.apex.execute("AMS_OSCAR_Webservice", "createIfapPortalServiceRight", {oscarId: argList[2]});

			if(result4 != 'OK'){
				ifapPSR = 'Grant IFAP service access - Failed.\n(' + result4 +')\n\r';
			}else{
				ifapPSR = 'Grant IFAP service access - Success!\n\r';
			}
		}

        alert('\n\r ' + resultExecution[1] + ifapPSR);

    },
    issueInvoice:function (args) { 
        var argList = args.split(", ");
        // Query the database to check if invoice has already been sent
        var result = sforce.connection.query("SELECT Invoice_Requested__c FROM AMS_OSCAR__C WHERE Id ='" + argList[1] + "'");
        var record = result.getArray("records");

        if (record.length>0 && record[0].Invoice_Requested__c != null) {
            alert('Billing Document has already been issued');
        }

        var result = sforce.apex.execute("AMS_2_MDM_Webservice", "sendAgencyECC", {agencyId: argList[0], oscarId: argList[1]});
        var queryResult = sforce.connection.query("SELECT ID, STEP8__c from AMS_OSCAR__c WHERE Account__c='" + argList[0] + "'");
        var records = queryResult.getArray('records');

        if(result == ''){
            records[0].STEP8__c = 'In Progress';
            alert('Executed with success.');
        }
        else{
            records[0].STEP8__c = 'Failed';
            alert('XML generated successfully but unable to send it to SAP due to connectivity issues.');
        }
        sforce.connection.update(records);
    },
    salesOrder:function (arg1) { 
        var result = sforce.apex.execute("AMS_2_MDM_Webservice", "sendAgencySalesOrder", {agencyId: arg1});
        var queryResult = sforce.connection.query("SELECT ID, STEP8__c from AMS_OSCAR__c WHERE Account__c='" + arg1 + "'");
        var records = queryResult.getArray('records');
        if(result == 'false'){
            records[0].STEP8__c = 'Passed';
            alert('Executed with success.');
        }
        else{
            records[0].STEP8__c = 'Failed';
            alert('Error on execution.')
        }
        sforce.connection.update(records);
    },
    SubmitForApproval:function (argsList) {
    
        /*
        var result = sforce.apex.execute("AMS_SALM_ApprovalEmailGenerator", "processApprovalEmail", {argsList: argsList});
        
        if(result == 'true'){
            alert('An email has been sent for your manager approval.');
        }
        else{
            alert('An error has occurred.')
        }
        */
    },
    createIFAP:function(arg1){
        var result = sforce.apex.execute("AMS_OSCAR_Webservice","createIFAPFromOSCAR", {oscarId: arg1}); 

        // error
        if (result[0].substring(0, 6) == 'ERROR:') {
            alert(result);
        } 
        else {
            var caseInfo = result[0].split(":");
            var caseId = caseInfo[0];
            var caseNumber = caseInfo[1];

            var changeTab = function(result){
                if(result.success == true){
                    //sforce.console.focusPrimaryTabById(caseId);
                    alert('IFAP Case created successfully.');
                }
            };

            // Use the results primary tab id and open a new subtab
            var openSubtab = function(result)
            {               
                sforce.console.openSubtab(result.id, '/'+caseId, true, caseNumber, null, changeTab);     
            };
            sforce.console.getEnclosingPrimaryTabId(openSubtab);

            /* var changeTab = function(result){
                if(result.success == true){
                    sforce.console.focusPrimaryTabById(caseId);
                    alert('IFAP Case created successfully.');
                }
            };
            sforce.console.openPrimaryTab(null, '/'+caseId, true, caseNumber, changeTab, caseId);*/
        }
    },
    performAML:function (arg) {
        var result = this.performAMLaux(arg);
        alert(result);
    },
    performAMLaux:function (arg) {
        var rc = 'Due Diligence Case created successfully.';
        var result = sforce.apex.execute("AMS_OSCAR_Webservice", "createAMLCase", {oscarId: arg});

        // OK
        if (result[0].substring(0, 6) != 'ERROR:') {                          
            var caseId = result[0];

            var changeTab = function(result){
                if(result.success == true){
                    //sforce.console.focusPrimaryTabById(caseId);
                }
            };

            // Use the results primary tab id and open a new subtab
            var openSubtab = function(result)
            {               
                sforce.console.openSubtab(result.id, '/'+caseId, true, 'Due Diligence Case', null, changeTab);   
            };
            sforce.console.getEnclosingPrimaryTabId(openSubtab);

        } else {
            rc = result;
        }
        return rc;            
    },
    congaMerge:function(args){
        
        var argList = args.split(", ");
    
        var arg1 = argList[0];
        var arg2 = argList[1];
        var arg3 = argList[2];
        var arg4 = argList[3];
        var arg5 = argList[4];


        arg2 = arg2 + '&OscarId=' + arg1;
        arg2 = arg2 + '&TemplateId=' + arg4;
        arg2 = arg2 + '&ReportId=' + arg5;

        var changeTab = function(){
            //alert('Conga alert - ' + url);
        };

        //window.open(arg2, "Conga Merge", "height=450px,width=700px,resizable=1,scrollbars=1,status=0,toolbar=0,menubar=0");

        
        var openSubtab = function(result)
        {    
        
            sforce.console.openSubtab(result.id, arg2, true, 'Conga', null, changeTab);  
        };
        sforce.console.getEnclosingPrimaryTabId(openSubtab);

      

    },
    createCorrectionCase:function (arg) {
        
        var changeTab = function(result){
            /*if(result.success == true){
                alert('Correction Case created successfully.');
            }*/
        };

        // Use the results primary tab id and open a new subtab
        var openSubtab = function(result)
        {               
            sforce.console.openSubtab(result.id, '/apex/AMS_AccountOSCARWizardPage?accountId='+arg+'&process=CORRECTION.1.0', true, 'Correction Case', null, changeTab);     
        };

        sforce.console.getEnclosingPrimaryTabId(openSubtab);
    
    },
    checkAccountHierarchy:function (arg) {
        var changeTab = function(result){
            /*if(result.success == true){
                alert('Tab opened sucessfully');
            }*/
        };

        // Use the results primary tab id and open a new subtab
        var openSubtab = function(result)
        {               
            sforce.console.openSubtab(result.id, '/apex/AMS_AccountHierarchySelection?Id='+arg, true, 'Account Hierarchy Selection', null, changeTab);   
        };

        sforce.console.getEnclosingPrimaryTabId(openSubtab);
    
    },
    ANG_checkAccountHierarchy:function (arg) {
        var changeTab = function(result){
            /*if(result.success == true){
                alert('Tab opened sucessfully');
            }*/
        };

        // Use the results primary tab id and open a new subtab
        var openSubtab = function(result)
        {               
            sforce.console.openSubtab(result.id, '/apex/ANG_AccountHierarchySelection?Id='+arg, true, 'Account Hierarchy Selection', null, changeTab);   
        };

        sforce.console.getEnclosingPrimaryTabId(openSubtab);
    
    },
    createSIDRALite:function (arg) {
        var result;
        result = sforce.apex.execute("AMS_OSCAR_Webservice", "createSIDRALite", {oscarId: arg});
        
        // error
        if (result[0].substring(0, 6) == 'ERROR:') {
            alert(result);
        } 
        else {
            
            var caseId = result[0];

            var changeTab = function(result){
                if(result.success == true){
                    //sforce.console.focusPrimaryTabById(caseId);
                    alert('SIDRA Lite Case created successfully.');
                }
            };

            // Use the results primary tab id and open a new subtab
            var openSubtab = function(result)
            {               
                sforce.console.openSubtab(result.id, '/'+caseId, true, 'SIDRA Lite Case', null, changeTab);  
            };
            sforce.console.getEnclosingPrimaryTabId(openSubtab);

        }
    
    },
    createCommissionerCase:function (arg) {
        var result;
        result = sforce.apex.execute("AMS_OSCAR_Webservice", "createCommissionerCase", {oscarId: arg});
        
        // error
        if (result[0].substring(0, 6) == 'ERROR:') {
            alert(result);
        } 
        else {
            
            var caseId = result[0];

            var changeTab = function(result){
                if(result.success == true){
                    //sforce.console.focusPrimaryTabById(caseId);
                    alert('Commissioner Case created successfully.');
                }
            };

            // Use the results primary tab id and open a new subtab
            var openSubtab = function(result)
            {               
                sforce.console.openSubtab(result.id, '/'+caseId, true, 'Commissioner Lite Case', null, changeTab);   
            };
            sforce.console.getEnclosingPrimaryTabId(openSubtab);

        }
    
    },
    createFSReleaseCase:function (arg) {
        var result;
        result = sforce.apex.execute("AMS_OSCAR_Webservice", "createFSReleaseCase", {oscarId: arg});
        
        // error
        if (result[0].substring(0, 6) == 'ERROR:') {
            alert(result);
        } 
        else {
            
            var caseId = result[0];

            var changeTab = function(result){
                if(result.success == true){
                    alert('Case created successfully.');
                }
            };

            // Use the results primary tab id and open a new subtab
            var openSubtab = function(result)
            {                   
                sforce.console.openSubtab(result.id, '/'+caseId, true, 'Case for FS Release', null, changeTab);  
            };
            sforce.console.getEnclosingPrimaryTabId(openSubtab);

        }
    
    },

    deactivateBSPLink:function (arg) {

        var oscarIdsToRemove = [];
        var sMessageSuccess = "";
        var sMessageError = "";

        if(confirm('Do you want to proceed deactivating agencies?')){
            oscarIdsToRemove.push(arg);

            var response = sforce.apex.execute("AMS_BSPLinkIntegration","ProcessBSPLink",{sProcess:"Deactivation",objectIds:oscarIdsToRemove,sTypeOfRemoval:"AccountsInvolved"});

            for (var i = 0; i < response.length; i++) {
                if(response[i].result=='Ok'){
                    sMessageSuccess = sMessageSuccess + "Success: " + response[i].IATACode + ": " + response[i].description + "\n";
                }
                if(response[i].result=='Error'){
                    sMessageError = sMessageError + "Error: " + response[i].IATACode + ": " + response[i].description + "\n";
                }
            }
            alert("Result: \n\n" + sMessageError + "\n\n" + sMessageSuccess);
        }
    },

    reactivateBSPLink:function (arg) {
        var oscarIdsToRemove = [];
        var sMessageSuccess = "";
        var sMessageError = "";

        if(confirm('Do you want to proceed reactivating agencies?')){
            oscarIdsToRemove.push(arg);

            var response = sforce.apex.execute("AMS_BSPLinkIntegration","ProcessBSPLink",{sProcess:"Reactivation",objectIds:oscarIdsToRemove,sTypeOfRemoval:"AccountsInvolved"});

            for (var i = 0; i < response.length; i++) {
                if(response[i].result=='Ok'){
                    sMessageSuccess = sMessageSuccess + "Success: " + response[i].IATACode + ": " + response[i].description + "\n";
                }
                if(response[i].result=='Error'){
                    sMessageError = sMessageError + "Error: " + response[i].IATACode + ": " + response[i].description + "\n";
                }
            }
            alert("Result: \n\n" + sMessageError + "\n\n" + sMessageSuccess);
        }
    },

    undoDeactivationBSPLink:function (arg) {
        var oscarIdsToRemove = [];
        var sMessageSuccess = "";
        var sMessageError = "";

        if(confirm('Do you want to proceed reactivating agencies?')){
            oscarIdsToRemove.push(arg);

            var response = sforce.apex.execute("AMS_BSPLinkIntegration","ProcessBSPLink",{sProcess:"DeactivationUndo",objectIds:oscarIdsToRemove,sTypeOfRemoval:"AccountsInvolved"});

            for (var i = 0; i < response.length; i++) {
                if(response[i].result=='Ok'){
                    sMessageSuccess = sMessageSuccess + "Success: " + response[i].IATACode + ": " + response[i].description + "\n";
                }
                if(response[i].result=='Error'){
                    sMessageError = sMessageError + "Error: " + response[i].IATACode + ": " + response[i].description + "\n";
                }
            }
            alert("Result: \n\n" + sMessageError + "\n\n" + sMessageSuccess);
        }
    },
    
    generateCertificates:function (args) {

        var argList = args.split(", ");

        var result;
        result = sforce.apex.execute("AMS_OSCAR_Webservice", "generateCertificates", {oscarId: argList[0], agencyId: argList[1]});
        
        alert(result);
    
    },

    createFSObject:function (arg) {
        var result = this.createFSObjectAux(arg);
    },
    createFSObjectAux:function (arg) {

            var changeTab = function(result){
                if(result.success == true){
                    //sforce.console.focusPrimaryTabById(caseId);
                }
            };

            var argList = arg.split(", ");

            accountId = argList[0];
            accountName = argList[1];

            // Use the results primary tab id and open a new subtab
            var openSubtab = function(result)
            {               
                sforce.console.openSubtab(result.id, '/a0p/e?CF00N20000003JfVx='+accountName+'&CF00N20000003JfVx_lkid='+accountId, true, 'Financial Security', null, changeTab);     
            };
            sforce.console.getEnclosingPrimaryTabId(openSubtab);

      

        return '';            
    },
    createRiskEvent:function (arg) {
        
        var result;

        var oscarData = sforce.connection.query("SELECT Risk_event_creation_date__c FROM AMS_OSCAR__C WHERE Id ='" + arg + "'");

        var records = oscarData.getArray("records");

        if(records[0].Risk_event_creation_date__c != null){
            result = 'This button has already been clicked before, no further action will be performed.';  
        }else{
            result = sforce.apex.execute("AMS_OSCAR_Webservice", "createRiskEvent", {oscarId: arg});
        }

        alert('result:\n\r ' + result);
            
    },

    forecast:function (arg) {
        
        var c = sforce.connection.query("SELECT Id FROM Case where OSCAR__c ='" + arg + "' AND ( ParentId = null or Parent.RecordType.Name != 'OSCAR Communication' ) LIMIT 1").getArray("records")[0];

        var w = 800;
        var h = 200;
        
        // Fixes dual-screen position Most browsers Firefox
        var dualScreenLeft = window.screenLeft != undefined ? window.screenLeft : screen.left;
        var dualScreenTop = window.screenTop != undefined ? window.screenTop : screen.top;
        width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
        height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;

        var left = ((width / 2) - (w / 2)) + dualScreenLeft;
        var top = ((height / 2) - (h / 2)) + dualScreenTop;


        //open a popup
        var newWindow = window.open(
            '/apex/ANG_RiskForecastPropertiesPage?id='+c.Id,
            '_blank',
            'toolbar=no,status=no,directories=no,menubar=no,resizable=yes,scrollable=yes,width=' + w + ',height=' + h + ',top=' + top + ',left=' + left
        );

        // Puts focus on the newWindow
        if (window.focus) {
            newWindow.focus();
        }
    }

};