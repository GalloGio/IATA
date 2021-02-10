import { LightningElement, track } from 'lwc';

//import methods
import getInnovationHubTabs from '@salesforce/apex/PortalServicesInnovationHubCtrl.getInnovationHubTabs';

export default class PortalServicesInnovationHubHomePage extends LightningElement {

    @track componentLoading = true;
    @track lstTabs = [];
    @track viewTabs = false;
    
    connectedCallback(){

        //get the tabs from the server
        getInnovationHubTabs({})
        .then(results => {
            let tabsAux = JSON.parse(JSON.stringify(results));
            if(tabsAux !== undefined && tabsAux !== null && tabsAux.length > 0){
                this.lstTabs = tabsAux;
                this.componentLoading = false;
                this.viewTabs = true;
            }
        });
    }

    get tab0Active(){return this.lstTabs !== undefined && this.lstTabs.length > 0 && this.lstTabs[0].tabIsActive;}
    get tab1Active(){return this.lstTabs !== undefined && this.lstTabs.length > 0 && this.lstTabs[1].tabIsActive;}

    onmouseenterTab(event){
        let clickedTab = event.target.dataset.item;
        let tabsAux = JSON.parse(JSON.stringify(this.lstTabs));

        for(let i = 0; i < tabsAux.length; i++){
            if(i+"" === clickedTab){
                tabsAux[i].tabStyle="color:#f04632;border-bottom: 2px solid #f04632;";
            }else{
                tabsAux[i].tabStyle="";
            }
        }

        this.lstTabs = tabsAux;
    }

    onmouseleaveTab(event){
        let clickedTab = event.target.dataset.item;
        let tabsAux = JSON.parse(JSON.stringify(this.lstTabs));//because proxy.......

        for(let i = 0; i < tabsAux.length; i++){
            if(i+"" === clickedTab){
                tabsAux[i].tabStyle="";
            }else{
                tabsAux[i].tabStyle="";
            }
        }

        this.lstTabs = tabsAux;
    }

    onclickTab(event){
        let clickedTab = event.target.dataset.item;
        let tabsAux = JSON.parse(JSON.stringify(this.lstTabs));//because proxy.......

        for(let i = 0; i < tabsAux.length; i++){
            if(i+"" === clickedTab){
                tabsAux[i].tabIsActive=true;
            }else{
                tabsAux[i].tabIsActive=false;
                tabsAux[i].tabStyle="";
            }
        }

        this.lstTabs = tabsAux;
    }

}