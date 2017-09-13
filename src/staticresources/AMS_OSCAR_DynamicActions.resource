var dyn_functions = {
           generateIataCode:function (args) { 
                $body = $("body");
                $body.addClass("loading");
              
                var r = confirm("Generate Iata Code?");
                
                var result;
                var result2;
                var result3;
                var bUpdate = false;
                var createNewChangeCode = true;
                var inspectionRecs;
                var sResult = '';
                if (r == true) {
                    
                    var argList = args.split(", ");

                    // Query the database to check if the flags for :IATACODE, Copy Data to Account and send Data to SAP ECC 
                    var resultOscarData = sforce.connection.query("SELECT Flag_Data_to_Account__c,Flag_Data_to_SAPECC__c,ID, STEP10__c,STEP8__c,Process_Start_Date__c,recordTypeID,Process__c, Account__r.Due_Diligence_Status__c, AMS_Online_Accreditation__r.Location_Class__c, AMS_Online_Accreditation__r.Link_agent_name__c , AMS_Online_Accreditation__r.Branch_Office_Country__r.Due_diligence_mandatory__c,Account__r.Location_Class__c, Account__r.Sector__c , Account__r.Company_type__C FROM AMS_OSCAR__C WHERE Id ='" + argList[2] + "'");

                    var records = resultOscarData.getArray("records");

                    if(records[0].AMS_Online_Accreditation__r.Location_Class__c == 'I' && records[0].Account__r.Sector__c == 'Cargo Agent' && records[0].AMS_Online_Accreditation__r.Link_agent_name__c == null ){
                        var resultLinkAgent = confirm("The “Link Agent Name” field is not filled. Are you sure you want to proceed ?");
                        if(resultLinkAgent == false){
                            sResult = 'Please fill the Link Agent Name before proceding';
                            return 'false';
                        }
                    }

                    //Prevent error with cross reference fields
                    var oscar = new sforce.SObject("AMS_OSCAR__c");
                    oscar.Id = records[0].Id;

                    //if oscar is mso do not allow more than one appointment
                    if(records.length > 0 && records[0].Process__c == 'NEW.MSO.1.0'){
                        var nInspections = sforce.connection.query("SELECT Id FROM AMS_Inspection__c WHERE Oscar__c ='" + argList[2] + "'");
                        inspectionRecs = nInspections.getArray("records");
                    }

                    if(inspectionRecs != null && inspectionRecs.length > 1)
                        sResult = '- A New MSO cannot have more than one Appointment. Please review the appointments section and try again - \n\r';
                    else{

                        var resultOscarDataFlag = sforce.connection.query("SELECT Flag_IATACode_Formula__c FROM AMS_OSCAR__C WHERE Id ='" + argList[2] + "'");
                        var recordsFlag = resultOscarDataFlag.getArray("records");

                        var resultCC = sforce.connection.query("SELECT Id FROM Agency_Applied_Change_code__c WHERE  OSCAR__c ='" + argList[2] + "'");
                        var recordsCC = resultCC.getArray("records");

                        if (records.length>0 && recordsFlag[0].Flag_IATACode_Formula__c == 'false') {

                            result = sforce.apex.execute("AmsIataCodeGenerator", "generatedAgencyIATACode", {accountId: argList[0], onlineAccreditationId: argList[1]});
                            
                            //FM - Validar com o Maçarico... a query está a pesquisar por conta... podem existir vários Oscar com a mesma conta, logo mudei para ir por OscarId (mas na query acima...)!
                            //var queryResult = sforce.connection.query("SELECT ID, STEP10__c from AMS_OSCAR__c WHERE Account__c='" + argList[0] + "'");
                            //var records = queryResult.getArray('records');

                            
                            if(result[0] == '1'){
                                oscar.STEP10__c = 'Passed';
                                sResult = '- Generate IATACode - Success!\n\r';

                                //Update data after IATACode Generation
                                resultOscarDataFlag = sforce.connection.query("SELECT Flag_IATACode_Formula__c FROM AMS_OSCAR__C WHERE Id ='" + argList[2] + "'");
                                recordsFlag = resultOscarDataFlag.getArray("records");

                                //result2 = sforce.apex.execute("AMS_OSCAR_Webservice", "copyDataToAccount", {oscarId: argList[2]});
                                //if(result2 != 'OK'){
                                //    alert('Failed to copy data to Account. Please contact your Administrator. ' + result2);
                                //}else{
                                //    records[0].Flag_Data_to_Account__c = true;
                                //}
                            } else{
                                oscar.STEP10__c = 'Failed';
                                sResult = '- Generate IATACode - Error! '+ result[1] + ' (code: '+ result[0] +')\n\r';
                            }
                            //sforce.connection.update(records);
                            bUpdate = true;
                        }else{
                        
                            sResult = '- IATA code already generated \n\r';
                        }


                        if (records.length>0 && recordsFlag[0].Flag_IATACode_Formula__c == 'true' && records[0].Flag_Data_to_Account__c == 'false') {
                            result2 = sforce.apex.execute("AMS_OSCAR_Webservice", "copyDataToAccount", {oscarId: argList[2]});
                            if(result2 != 'OK'){
                                sResult = sResult + '- Move Data To Account - Failed to copy data to Account. Please contact your Administrator.\n(Error: ' + result2 +')\n\r';
                                createNewChangeCode = false;
                            }else{
                                oscar.Flag_Data_to_Account__c = 'true';
                                bUpdate = true;
                                sResult = sResult + '- Move Data To Account - Success!\n\r';
                            }

                        }else{
                            sResult = sResult + '- Move Data To Account - ByPassed! \n\r';
                        }

                        if (createNewChangeCode && recordsFlag[0].Flag_IATACode_Formula__c == 'true' && recordsCC.length == 0)
                            sforce.apex.execute("AMS_OSCAR_Webservice", "createChangeCodeNEW", {oscarId: argList[2]});
                   
                        if (records.length>0 && recordsFlag[0].Flag_IATACode_Formula__c == 'true' && records[0].Flag_Data_to_Account__c == 'true' 
                                && records[0].Flag_Data_to_SAPECC__c == 'false') {
                            
                            oscar.Flag_Data_to_SAPECC__c = 'true';
                            oscar.STEP8__c = 'In Progress';
                            
                        }

                        var ddResult = 'ByPassed!';

                        if (
                            records.length > 0 && recordsFlag[0].Flag_IATACode_Formula__c == 'true'
                            && records[0].AMS_Online_Accreditation__r.Branch_Office_Country__r.Due_diligence_mandatory__c == 'true' 
                            && (records[0].Process__c == 'NEW.HO.1.0' || records[0].Process__c == 'NEW.BR.ABROAD' || records[0].Process__c == 'NEW.TIDS.1.0' || records[0].Process__c == 'ANG.NEW.HE.LITE.1.0' || records[0].Process__c == 'ANG.NEW.HE.STANDARD.1.0')
                        ){
                            
                            if(records[0].Account__r.Due_Diligence_Status__c == 'In Progress'){
                                ddResult = 'ByPassed (process is already in progress)';
                                oscar.STEP17__c = 'In progress';
                                bUpdate = true;
                            }else{
                                ddResult = this.performAMLaux(argList[2]);
                            }
                            

                        } 

                        sResult = sResult + '- Due diligence - ' + ddResult + '\r\n'; 

                        if(bUpdate){
                            console.info("Update result: "+sforce.connection.update([oscar]));
                        }

                    }

                } else {
                    //result = "You pressed Cancel!";
                }
                $body.removeClass("loading");
                
                alert('result:\n\r ' + sResult);
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
                    result = 'The risk event has already been generated.';   
                }else{
                    result = sforce.apex.execute("AMS_OSCAR_Webservice", "createRiskEvent", {oscarId: arg});
                }

                alert('result:\n\r ' + result);
                    
           }

};