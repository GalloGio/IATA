import { LightningElement, api, track } from 'lwc';

export default class PortalIftpExportData extends LightningElement {
    @track fieldNamesList;
    @track filteredData;

    @api
    exportDataToCsv(columnsTobeExported, dataToExport, csvFileName){
        console.log('columns', columnsTobeExported);
        console.log('data', dataToExport);
        let columns = JSON.parse(JSON.stringify(columnsTobeExported));
        let data = JSON.parse(JSON.stringify(dataToExport));
        let rowEnd = '\n';
        let csvString = '';

        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();
        let headers = new Set();

        // getting keys from data
        columns.forEach(column => {
            if(column.fieldName){
                headers.add(column.label);
                rowData.add(column.fieldName);
            }
        });

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        headers = Array.from(headers);
        
        // splitting using ','
        csvString += headers.join(',');
        csvString += rowEnd;

        console.log('csvString', csvString);
        console.log('rowData', rowData);


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
        
        console.log('window.navigator.msSaveBlob', window.navigator.msSaveBlob);
        if(window.navigator.msSaveBlob) { // IE 10+
            let fileName = csvFileName;
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
                downloadElement.download = csvFileName;
                // below statement is required if you are using firefox browser
                document.body.appendChild(downloadElement);
                // click() Javascript function to download CSV file
                downloadElement.click();
            

        }

    }

    @api
    exportDataToExcel(columnsTobeExported, dataToExport, excelFileName){
        console.log('columns', columnsTobeExported);
        console.log('data', dataToExport);
        let columns = JSON.parse(JSON.stringify(columnsTobeExported));
        let data = JSON.parse(JSON.stringify(dataToExport));
        let filteredData = [];
        // this set elminates the duplicates if have any duplicate keys
        let fieldNamesList = new Set();
        let headers = new Set();

        // getting keys from data
        columns.forEach(column => {
            if(column.fieldName){
                headers.add(column.label);
                fieldNamesList.add(column.fieldName);
            }
        });

        console.log('fieldNamesList', fieldNamesList);
        console.log('headers', headers);


        // main for loop to get the data based on key value
        for(let i=0; i < data.length; i++){
            let record = {};
            // validating keys in data
            fieldNamesList.forEach(name =>{
                record[name] = data[i][name];
            })
            filteredData.push(record);
        }
        console.log('filteredData', filteredData);
        //let tableSelect = document.getElementById(tableID);


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
        tableSelect += '</table>';

        console.log('tableSelect', tableSelect);

        //let tableHTML = tableSelect.outerHTML.replace(/ /g, '%20');
        let tableHTML = tableSelect;
        console.log('tableHTML', tableHTML);
        
        console.log('window.navigator.msSaveBlob', window.navigator.msSaveBlob);
        if(window.navigator.msSaveBlob) { // IE 10+
            let fileName = excelFileName;
            let blob = new Blob(['\ufeff', tableHTML], {
                          type: 'application/vnd.ms-excel'          
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
                downloadElement.href = 'data: application/vnd.ms-excel,' + tableHTML;
                // CSV File Name
                downloadElement.download = excelFileName;
                
                // click() Javascript function to download CSV file
                downloadElement.click();
            

        }

    }
}