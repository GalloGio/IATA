import { LightningElement, api, track } from 'lwc';
import getArticlesFromSubtopic from '@salesforce/apex/PortalFAQsCtrl.getArticlesFromSubtopic';
import getFAQsInfo from '@salesforce/apex/PortalFAQsCtrl.getFAQsInfo';

export default class PortalFAQArticleAccordion extends LightningElement {
    @api category;
    @api topic;
    @track _subTopic;
    @track childs;
    @track articles;
    @track error;

    @api
    get subTopic() {
        return this._subTopic;
    }
    set subTopic(value) {
        this._subTopic = [];
        this._subTopic.push(value);

        this.createParameter(this._subTopic);
    }

    connectedCallback() {        
        getFAQsInfo()
            .then(results => {
                let result = JSON.parse(JSON.stringify(results));
                let childs = [];
                
                let tempCategoryName = this.category; //Contains selected category from portalFAQPage
        
                Object.keys(result).forEach(function (el) {                

                    if(tempCategoryName === result[el].categoryName) {
                        Object.keys(result[el].childs).forEach(function (elAux) {
                            childs.push(result[el].childs[elAux]);
                        });
                    }
                });
    
                this.createParameter(childs);
    
                this.loading = false;
            })
            .catch(error => {
                this.error = error;
            }
        );
    }

    articleSelected(event) {
        let article = event.target.attributes.getNamedItem('data-item').value;

        let articleVals = JSON.parse(JSON.stringify(this.articles));
        
        Object.keys(articleVals).forEach(function (el) {
            if(article === articleVals[el].label && articleVals[el].open === false) {
                articleVals[el].open = true;
            } else {
                articleVals[el].open = false;
            }
        });

        this.articles = articleVals;
    }

    createParameter(params) {
        if(params !== undefined) {
            let selectedParams = [];
            selectedParams = '(';

            for(let i = 0; i < params.length; i++) {
                if(i === 0) {
                    selectedParams += params[i] + '__c';
                } else {
                    selectedParams += ', ' + params[i] + '__c';
                } 
            }
            selectedParams += ')';

            this.getArticles(selectedParams);
        }
    }

    getArticles(selectedParams) {
        getArticlesFromSubtopic({ selectedParams : selectedParams })
            .then(result => {                           
                let res = JSON.parse(JSON.stringify(result));
                this.articles = [];
                let tempArticles = [];

                Object.keys(res).forEach(function (el) {  
                    tempArticles.push({ label: res[el].Title, value: res[el].Answer__c, open: false });
                });

                this.articles = tempArticles;           
            })
            .catch(error => {                
                this.error = error;
            }
        );        
    }    
}