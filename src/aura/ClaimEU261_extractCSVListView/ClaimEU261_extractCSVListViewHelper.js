({
	downloadCSV : function(component, listCases) {

		// declare variables
        var csvStringResult, counter, columns, columnDivider, lineDivider;
       
        // check if "listCases" parameter is null, then return from function
        if (listCases == null || !listCases.length) {
            return null;
         }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
 
        // in the columns valirable store fields API Names as a key 
        // this labels use in CSV file header  
        columns = ['CaseNumber','Contact.Name','Subject','Status','Priority', 'CreatedDate', 'Owner.Name', 'Portal_Case_Status__c'];
        
        csvStringResult = '';
        csvStringResult += columns.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < listCases.length; i++){   
            counter = 0;
           
             for(var sTempkey in columns) {
                var skey = columns[sTempkey];
 
                if(counter > 0){ 
                	csvStringResult += columnDivider; 
                }

                if(skey.includes('.')) {

                	var splitKey = skey.split(".");

                	if(listCases[i].hasOwnProperty(splitKey[0])) {
                		csvStringResult += '"'+ listCases[i][splitKey[0]][splitKey[1]]+'"';
                	} else {
                		csvStringResult += '""';
                	}

                } else {
                	csvStringResult += '"'+ listCases[i][skey]+'"';
                }

            	counter++;
            }
            
            csvStringResult += lineDivider;
        }
       
       	// return the CSV formate String
        var csv = csvStringResult.replace(/undefined/g, "");
 
        if (csv == null){return;}

	    var hiddenElement = document.createElement('a');
	    hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
	    hiddenElement.target = '_self';
	    hiddenElement.download = 'ExportData.csv';
	    document.body.appendChild(hiddenElement);
		hiddenElement.click();
	}
})