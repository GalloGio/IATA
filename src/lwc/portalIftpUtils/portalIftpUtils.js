import { LightningElement } from 'lwc';

//export default class PortalIftpUtils extends LightningElement {

import getUserStations from '@salesforce/apex/PortalIftpUtils.getUserStations';



export function getUserStationsJS(){
    /*             
    return [
        { label: 'Geneve2', value: 'GVA' },
        { label: 'London Heathrow2', value: 'LHT' },
        { label: 'Lisbon2', value: 'LIS' },
    ];
    */

    console.log('getUserStations - INIT');
    getUserStations()
    .then(results => {
        console.log('getUserStations - results : ' + results);
        console.log('getUserStations - results.length : ' + results.length);
        console.log('getUserStations - results:1 : ' + results[1]);

        if(results && results.length > 0) {
            data = results;
        } 
        
    })
    .catch(error => {
        console.log('getUserStations - Error : ' + error);
    });  
    console.log('getUserStations - END');
    
    return data;
    
}



//}