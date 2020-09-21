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
    @track filteringObject = {};
    @track loading = true;
    @track _userInfo;
    @track language;
    @track guestUser;
    @track isRendered=false;

    @api
    get userInfo() {
        return this._userInfo;
    }

    set userInfo(value) {
        if(value !== undefined) {
            let __userInfo = JSON.parse(JSON.stringify(value));

            this.language = __userInfo.language;
            this.guestUser = __userInfo.guestUser;
        }        
    }

    @api
    get article() {
        return this._article;
    }

    set article(value) {                    
        if(value !== undefined) {
            let articleInfo = JSON.parse(JSON.stringify(value));

            this._articleTitle = articleInfo.title;
            this._articleId = articleInfo.id;

            this.filteringObject.searchText = this._articleTitle;
        }
    }
    
    get hasArticles() {
        return this.relatedArticles !== undefined && this.relatedArticles.length > 0;
    }

    connectedCallback() {
        let _filteringObject = JSON.parse(JSON.stringify(this.filteringObject));
        if(this.guestUser) {
            _filteringObject.language = this.language;
            _filteringObject.guestUser = this.guestUser;
        }
        
        this.renderSearchArticles(JSON.stringify(_filteringObject));
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
            })
            .finally(() =>{
                this.loading = false;
                this.isRendered=true;
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
