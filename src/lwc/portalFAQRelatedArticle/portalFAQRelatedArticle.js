import { LightningElement, api, track, wire } from 'lwc';
import getSearchArticles from '@salesforce/apex/PortalFAQsCtrl.getSearchArticles';
import CSP_RelatedArticles from '@salesforce/label/c.CSP_RelatedArticles';
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';


export default class PortalFAQRelatedArticle extends NavigationMixin(LightningElement) {
    label = {
        CSP_RelatedArticles
    };
    @track _articleTitle;
    @track _articleId;
    @track relatedArticles;

    @api
    get article() {
        return this._article;
    }

    set article(value) {                    
        if(value !== undefined) {
            let articleInfo = JSON.parse(JSON.stringify(value));
            this._articleTitle = articleInfo.title;
            this._articleId = articleInfo.id;
        }
    }
    
    get hasArticles() {
        return this.relatedArticles !== undefined && this.relatedArticles.length > 0;
    }

    @wire(getSearchArticles, { searchTerm : '$_articleTitle' })
    wiredSearchArticles(results) {        
        if (results.data) {
            this.relatedArticles = JSON.parse(JSON.stringify(results.data));
        } else if (results.error) {
            this.error = results.error;
        }
    }

    renderArticle(event) {        
        let params = {};
        params.id1 = this._articleId; // PARENT ARTICLE
        params.id2 = event.target.attributes.getNamedItem('data-item').value; // SPECIFIC RELATED ARTICLE TO THE PARENT ARTICLE

        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "support-view-article"
            }})
        .then(url => navigateToPage(url, params));
    }
}