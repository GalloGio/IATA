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
    @track loadingSpinner = true;
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
            if(this.filteringObject.searchText){
                this.renderSearchArticles(JSON.stringify(this.filteringObject));
            }
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
            if(this.filteringObject.language){
                this.renderSearchArticles(JSON.stringify(this.filteringObject));
            }
        }
    }
    connectedCallback() {
     
    }

    renderSearchArticles(searchParam) {
        console.log(searchParam);
        if(searchParam != undefined && searchParam != ''){
            this.isRendered=false;
            try {
                getFilteredFAQsResultsPage({ searchKey : searchParam, requestedPage : '0'})
                .then(results => {  
                    if(results.records.length) {
                        let articles = [];
                        for(let i=1; i < 6 && i < results.records.length; i++) {
                            articles.push({ id: results.records[i].UrlName, title: results.records[i].Title });
                        }
                        this.relatedArticles = articles;
                        this.isRendered=this.relatedArticles.length>0;
                    } 
                }).finally(() =>{
                    this.loadingSpinner = false;
                    
                });  
            }catch(error){
                this.loadingSpinner = false;
            }
        }
    }

    renderArticle(event) {        
        let params = {};    

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__knowledgeArticlePage',
            attributes: {
                urlName: event.target.attributes.getNamedItem('data-item').value
            }})
        .then(url => navigateToPage(url, params));
    }
}
