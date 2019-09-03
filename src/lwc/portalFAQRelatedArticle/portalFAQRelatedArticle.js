import { LightningElement, api, track } from 'lwc';
import getFilteredFAQsResultsPage from '@salesforce/apex/PortalFAQsCtrl.getFilteredFAQsResultsPage';
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
    @track loading = true;
    @api guestUser;

    @api
    get article() {
        return this._article;
    }

    set article(value) {                    
        if(value !== undefined) {
            let articleInfo = JSON.parse(JSON.stringify(value));
            this._articleTitle = articleInfo.title;
            this._articleId = articleInfo.id;

            let filteringObject = {};
            filteringObject.searchText = this._articleTitle;

            this.renderSearchArticles(JSON.stringify(filteringObject));
        }
    }
    
    get hasArticles() {
        return this.relatedArticles !== undefined && this.relatedArticles.length > 0;
    }

    renderSearchArticles(searchParam) {
        getFilteredFAQsResultsPage({ searchKey : searchParam, requestedPage : '0'})
            .then(results => {                
                if(results.records.length) {
                    let articles = [];
                    for(let i=1; i < 6 && i < results.records.length; i++) {
                        articles.push({ id: results.records[i].Id, title: results.records[i].Title });
                    }
                    this.relatedArticles = articles;
                }
                this.loading = false;
            });
    }

    renderArticle(event) {        
        let params = {};
        params.id1 = this._articleId; // PARENT ARTICLE
        params.id2 = event.target.attributes.getNamedItem('data-item').value; // SPECIFIC RELATED ARTICLE TO THE PARENT ARTICLE

        let pageName;
        if(!this.guestUser) {
            pageName = 'support-view-article';
        } else {
            pageName = 'faq-article';
        }

        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: pageName
            }})
        .then(url => navigateToPage(url, params));
    }
}