import { LightningElement, api, track, wire } from 'lwc';
import getSearchArticles from '@salesforce/apex/PortalFAQsCtrl.getSearchArticles';
import CSP_RelatedArticles from '@salesforce/label/c.CSP_RelatedArticles';


export default class PortalFAQRelatedArticle extends LightningElement {
    label = {
        CSP_RelatedArticles
    };
    @track _article;
    @track relatedArticles;

    @api
    get article() {
        return this._article;
    }

    set article(value) {            
        if(value !== undefined) {
            this._article = value;
        }
    }
    
    get hasArticles() {
        return this.relatedArticles !== undefined && this.relatedArticles.length > 0 ? true : false;
    }

    @wire(getSearchArticles, { searchTerm : '$_article' })
    wiredSearchArticles(results) {
        if (results.data) {
            this.relatedArticles = JSON.parse(JSON.stringify(results.data));
        } else if (results.error) {
            this.error = results.error;
        }
    }
}