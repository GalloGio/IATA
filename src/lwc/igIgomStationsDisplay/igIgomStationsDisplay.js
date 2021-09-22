import { LightningElement, api } from 'lwc';

export default class IgIgomStationsDisplay extends LightningElement {
    @api stations;
    _columns = [{label:'', value:'Logo', width:'13%'}, {label:'Airline', value:'Airline', width:'10%'},
     {label:'City', value:'City', width:'10%'}, {label:'Country', value:'Country', width:'10%'},
     {label:'Last GAP Analysis', value:'Last GAP Analysis', width:'12%'}, {label:'Variations', value:'Variations', width:'13%'},
     {label:'Acknowledgements', value:'Acknowledgements', width:'12%'}, {label:'', value:'Link', width:'20%'}];
}