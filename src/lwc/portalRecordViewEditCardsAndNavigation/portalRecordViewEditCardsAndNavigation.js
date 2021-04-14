import { LightningElement,track,api } from 'lwc';

export default class PortalRecordViewEditCardsAndNavigation extends LightningElement {

    @track propertiesAndCardsList = {};
    @track handleScrolling = true;
    @track componentLoading = true;
    @track detailClass = '';
    @track showNavigation = true;

    @api 
    get propertiesAndCardsListApi(){
        return this.propertiesAndCardsList;
    }
    set propertiesAndCardsListApi(value){
        this.propertiesAndCardsList = value;
        //this.processPropertiesAndCardsList();
    }

    constructor() {
        super();
        var self = this;
        window.addEventListener('scroll', function (e) { self.handleScroll(window.scrollY, self); });
    }

    renderedCallback() {

        if(this.propertiesAndCardsList.viewNavigation === true){
            this.detailClass = 'slds-col slds-size_1-of-1 slds-large-size_2-of-3 slds-float_right';
            this.showNavigation = true;
            let sections = this.template.querySelectorAll('.section');

            const leftNav = this.template.querySelector('c-portal-company-profile-info-nav');
            if (leftNav) {
                let navItems = [];

                for(let i = 0; i < this.propertiesAndCardsList.lstCards.length; i++){
                    navItems.push({ label: this.propertiesAndCardsList.lstCards[i].cardTitle, value: this.propertiesAndCardsList.lstCards[i].cardTitle, open: true });
                }

                leftNav.navItems = navItems;
                leftNav.activesection = this.propertiesAndCardsList.lstCards[0].cardTitle;
            }
            
        } else{
            this.detailClass = 'slds-col slds-size_1-of-1 slds-large-size_2-of-3';
            this.showNavigation = false;
        }
        this.componentLoading = false;

    }

    handleNavigation(event) {
        let section = event.detail;
        let target = this.template.querySelector(`[data-name="${section}"]`);
        this.handleScrolling = false;

        target.scrollIntoView({ behavior: "smooth", block: "start" });

        this.timeout = setTimeout(function () {
            this.handleScrolling = true;
        }.bind(this), 1000);
    }

    handleScroll(yposition, self) {
        if (!this.handleScrolling) { return; }
        let sections = self.template.querySelectorAll('.section');

        for (let i = 0; i < sections.length; i++) {
            let offsetTop = sections[i].offsetTop;
            let sectionName = sections[i].attributes.getNamedItem('data-name').value;

            if ((offsetTop - yposition < 200) && (offsetTop - yposition > -200)) {
                if (self.currentSection != sectionName) {
                    self.currentSection = sectionName;
                    const leftNav = this.template.querySelector('c-portal-company-profile-info-nav');
                    if (leftNav) {
                        leftNav.activesection = sectionName;
                    }
                }
            }
        }
    }

    refreshview(event){

    }


}