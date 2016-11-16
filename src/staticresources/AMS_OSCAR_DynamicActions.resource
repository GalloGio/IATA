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
                    var resultOscarData = sforce.connection.query("SELECT Flag_Data_to_Account__c,Flag_Data_to_SAPECC__c,ID, STEP10__c,STEP8__c,Process_Start_Date__c,recordTypeID,Process__c FROM AMS_OSCAR__C WHERE Id ='" + argList[2] + "'");
                    var records = resultOscarData.getArray("records");

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
                                records[0].STEP10__c = 'Passed';
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
                        		records[0].STEP10__c = 'Failed';
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
                                records[0].Flag_Data_to_Account__c = 'true';
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
                            
                            records[0].Flag_Data_to_SAPECC__c = 'true';
                            records[0].STEP8__c = 'In Progress';
                            
                        }

                        if(bUpdate){
                            sforce.connection.update(records);
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
                var result;
                result = sforce.apex.execute("AMS_OSCAR_Webservice", "createAMLCase", {oscarId: arg});
                
                // error
                if (result[0].substring(0, 6) == 'ERROR:') {
                    alert(result);
                } 
                else {
                    
                    var caseId = result[0];

                    var changeTab = function(result){
                        if(result.success == true){
                            //sforce.console.focusPrimaryTabById(caseId);
                            alert('AML Case created successfully.');
                        }
                    };

                    // Use the results primary tab id and open a new subtab
                   var openSubtab = function(result)
                   {            
                        sforce.console.openSubtab(result.id, '/'+caseId, true, 'AML Case', null, changeTab);    
                   };
                   sforce.console.getEnclosingPrimaryTabId(openSubtab);

                }
           
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
           
           }

};