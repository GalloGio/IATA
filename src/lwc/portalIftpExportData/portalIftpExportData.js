import { LightningElement, api, track } from 'lwc';

export default class PortalIftpExportData extends LightningElement {
    @track fieldNamesList;
    @track filteredData;

    @api
    exportDataToCsv(columnsTobeExported, dataToExport, csvFileName){
        let columns = JSON.parse(JSON.stringify(columnsTobeExported));
        let data = JSON.parse(JSON.stringify(dataToExport));
        let rowEnd = '\n';
        let csvString = '\ufeff';

        
        let rowData = new Set(); // this set elminates the duplicates if have any duplicate keys
        let headers = []; //can not be a set because there are two columns with the same on purpose

        // getting keys from data
        columns.forEach(column => {
            if(column.fieldName){
                headers.push(column.label);
                rowData.add(column.fieldName);
            }
        });

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData); 
        // splitting using ','
        csvString += headers.join(',');
        csvString += rowEnd;

        // main for loop to get the data based on key value
        for(let i=0; i < data.length; i++){
            let colValue = 0;

            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    // Key value 
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = data[i][rowKey] === undefined ? '' : data[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }
        let month_names_short =  ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        let today = new Date();
        let day = ("0" + today.getDate()).slice(-2);
        let hours = ("0" + today.getHours()).slice(-2);
        let minutes = ("0" + today.getMinutes()).slice(-2);
        today = today.getFullYear()+'-'+ month_names_short[today.getMonth()].toUpperCase() +'-'+day;
        
        if(window.navigator.msSaveBlob) { // IE 10+
            
            let fileName = csvFileName;
            fileName = fileName + '-' + today + '.csv';
            let blob = new Blob([csvString], {
                          "type": "text/csv;charset=utf8;"          
                });
            window.navigator.msSaveBlob(blob, fileName);
        }
        else
        {
        
                // Creating anchor element to download
                let downloadElement = document.createElement('a');

                // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
                downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
                downloadElement.target = '_self';
                // CSV File Name
                downloadElement.download = csvFileName + '-' + today + '.csv';
                // below statement is required if you are using firefox browser
                document.body.appendChild(downloadElement);
                // click() Javascript function to download CSV file
                downloadElement.click();
            

        }

    }

    @api
    exportDataToExcel(columnsTobeExported, dataToExport, excelFileName){
        let columns = JSON.parse(JSON.stringify(columnsTobeExported));
        let data = JSON.parse(JSON.stringify(dataToExport));
        let filteredData = [];
        
        let fieldNamesList = new Set(); // this set elminates the duplicates if have any duplicate keys
        let headers = []; //can not be a set because there are two columns with the same on purpose

        // getting keys from data
        columns.forEach(column => {
            if(column.fieldName){
                headers.push(column.label);
                fieldNamesList.add(column.fieldName);
            }
        });

        // main for loop to get the data based on key value
        for(let i=0; i < data.length; i++){
            let record = {};
            // validating keys in data
            fieldNamesList.forEach(name =>{
                record[name] = data[i][name];
            })
            filteredData.push(record);
        }
        // Create HTML
        let tableSelect = '';
        tableSelect += '<table>';
        tableSelect += '<tr>';
        headers.forEach(field =>{
            tableSelect += '<th>' + field + '</th>';
        })
        tableSelect += '</tr>';
        filteredData.forEach(row =>{
            tableSelect += '<tr>';
            Object.keys(row).forEach(key=> {
                tableSelect += '<td>' + row[key] + '</td>';
             });
                
            tableSelect += '</tr>';
        })
        let month_names_short =  ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        let today = new Date();
        let day = ("0" + today.getDate()).slice(-2);
        let hours = ("0" + today.getHours()).slice(-2);
        let minutes = ("0" + today.getMinutes()).slice(-2);
        let todayNoTime = today.getFullYear()+'-'+ month_names_short[today.getMonth()].toUpperCase() +'-'+day;
        today = today.getFullYear()+'-'+ month_names_short[today.getMonth()].toUpperCase() +'-'+day+' '+hours+':'+minutes;
        
        
        tableSelect += '<tr><td colspan="4"><p align="left"><i>This report was generated by IATA Fueling Training Portal on ';
        tableSelect += today;
        tableSelect += '. </i></p></td></tr>';
        tableSelect += '<tr><td colspan="4"><p align="left"><i>Contains training record information.  Controlled distribution only.</i></p></td></tr>';
        tableSelect += '</table>';

        //let tableHTML = tableSelect.outerHTML.replace(/ /g, '%20');
        let tableHTML ='\ufeff'+ tableSelect;
        
        if(window.navigator.msSaveBlob) { // IE 10+
            let fileName = excelFileName + '-' + todayNoTime + '.xls';
            let blob = new Blob([tableHTML], {
                          type: 'application/vnd.ms-excel;charset=utf-8'          
                });
            window.navigator.msSaveBlob(blob, fileName);
        }
        else
        {
        
                // Creating anchor element to download
                let downloadElement = document.createElement('a');
                // below statement is required if you are using firefox browser
                document.body.appendChild(downloadElement);

                // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
                downloadElement.href = 'data: application/vnd.ms-excel;charset=utf-8,' + encodeURIComponent(tableHTML);
                // CSV File Name
                downloadElement.download = excelFileName + '-' + todayNoTime + '.xls';
                
                // click() Javascript function to download CSV file
                downloadElement.click();
            

        }

    }
}
