import { LightningElement, track } from 'lwc';

import { getParamsFromPage } from'c/navigationUtils';

//import labels
import CSP_Services_MyServicesTabTile from '@salesforce/label/c.CSP_Services_MyServicesTabTile';
import CSP_Services_AvailableServicesTabTitle from '@salesforce/label/c.CSP_Services_AvailableServicesTabTitle';

export default class PortalServicesPage extends LightningElement {

    label = {
        CSP_Services_MyServicesTabTile,
        CSP_Services_AvailableServicesTabTitle
    };

    @track lstTabs = [];
    
    connectedCallback(){

        //get the parameters for this page
        let pageParams = getParamsFromPage();

        let viewAvailableServices = false;
        if(pageParams.tab !== undefined && pageParams.tab !== '' && pageParams.tab === 'availableServices'){
            viewAvailableServices = true;
        }

        let tabsAux = [];

        tabsAux.push({
            "active" : !viewAvailableServices,
            "label" : this.label.CSP_Services_MyServicesTabTile,
            "id" : 0,
            "style" : ""
        });

        tabsAux.push({
            "active" : viewAvailableServices,
            "label" : this.label.CSP_Services_AvailableServicesTabTitle,
            "id" : 1,
            "style" : ""
        });

        this.lstTabs = tabsAux;

        

    }

    get tab0Active(){return this.lstTabs[0].active;}
    get tab1Active(){return this.lstTabs[1].active;}

    onmouseenterTab(event){
        let clickedTab = event.target.dataset.item;
        //console.log('onmouseenterTab', clickedTab);

        //because proxy.......
        let tabsAux = JSON.parse(JSON.stringify(this.lstTabs));
        //console.log(tabsAux);

        for(let i = 0; i < tabsAux.length; i++){
            if(i+"" === clickedTab){
                tabsAux[i].style="color:#f04632;border-bottom: 2px solid #f04632;";
            }else{
                tabsAux[i].style="";
            }
        }

        this.lstTabs = tabsAux;

    }

    onmouseleaveTab(event){
        let clickedTab = event.target.dataset.item;
        //console.log('onmouseleaveTab', clickedTab);

        //because proxy.......
        let tabsAux = JSON.parse(JSON.stringify(this.lstTabs));
        //console.log(tabsAux);

        for(let i = 0; i < tabsAux.length; i++){
            if(i+"" === clickedTab){
                tabsAux[i].style="";
            }else{
                tabsAux[i].style="";
            }
        }

        this.lstTabs = tabsAux;
    }

    onclickTab(event){
        let clickedTab = event.target.dataset.item;
        //console.log('onclickTab', clickedTab);

        //because proxy.......
        let tabsAux = JSON.parse(JSON.stringify(this.lstTabs));
        //console.log(tabsAux);

        for(let i = 0; i < tabsAux.length; i++){
            if(i+"" === clickedTab){
                tabsAux[i].active=true;
            }else{
                tabsAux[i].active=false;
            }
        }

        this.lstTabs = tabsAux;

    }

    handleGoToAvailableServicesTab(){
        let clickedTab = "1";

        //because proxy.......
        let tabsAux = JSON.parse(JSON.stringify(this.lstTabs));
        //console.log(tabsAux);

        for(let i = 0; i < tabsAux.length; i++){
            if(i+"" === clickedTab){
                tabsAux[i].active=true;
            }else{
                tabsAux[i].active=false;
            }
        }

        this.lstTabs = tabsAux;
    }


}