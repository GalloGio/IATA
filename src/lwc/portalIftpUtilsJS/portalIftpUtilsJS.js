import { LightningElement, track } from 'lwc';

//export default class PortalIftpUtils extends LightningElement {

import getITPStations from '@salesforce/apex/PortalIftpUtils.getITPStations';


export var stations;

export function getUserStationsJS(){
    /*             
    return [
        { label: 'Geneve2', value: 'GVA' },
        { label: 'London Heathrow2', value: 'LHT' },
        { label: 'Lisbon2', value: 'LIS' },
    ];
    */
    
    console.log('getITPStations - INIT');
    
    getITPStations()
    .then(result => {
        console.log(result);
        let myResult = JSON.parse(JSON.stringify(result));
        
        console.log(myResult);
        console.log('myResult : ' + myResult);
        let myTopicOptions = [{ label: 'All', value: 'all' }];

        Object.keys(myResult).forEach(function (el) {
            myTopicOptions.push({ label: myResult[el].City__c, value: myResult[el].Code__c });
        });
        stations = myTopicOptions;
        return myTopicOptions;
    })
    /*.then(results => {
        console.log('getITPStations - results : ' + results);
        console.log('getITPStations - results.length : ' + results.length);
        console.log('getITPStations - results:1 : ' + results[1]);

        if(results && results.length > 0) {
            // eslint-disable-next-line guard-for-in
            for(res in results){
                console.log('getITPStations - res : ' + res);
                console.log('getITPStations - results[res].City__c : ' + results[res].City__c + ' :: results[res].Code__c :' + results[res].Code__c);
                dataRecords.push({label:results[res].City__c, value: results[res].Code__c});
            }
        } 
        console.log('getITPStations - dataRecords' + dataRecords);
        return dataRecords;
    })*/
    .catch(error => {
        console.log('getITPStations - Error : ' + error);
    });  
    
    
    
}



//}