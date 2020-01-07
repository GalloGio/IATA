import { LightningElement, api, track } from 'lwc';
import getArticles from '@salesforce/apex/PortalFAQsCtrl.getArticlesWithParam';
import TitleLabel from '@salesforce/label/c.csp_Suggestion_label';
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';


export default class PortalSupportTopArticles extends NavigationMixin(LightningElement) {
    label = {
        TitleLabel
    };

    @track relatedArticles = [];
    @track loading = true;

    @track _category;
    @track _topic;
    @track _subtopic;

    @api numberOfArticles = 5;

    @api
    get category() {
        return this._category;
    }

    set category(value) {
       this._category = value;
    }

    @api
    get topic() {
        return this._topic;
    }

    set topic(value) {
       this._topic = value;
    }

    @api
    get subtopic() {
        return this._subtopic;
    }

    set subtopic(value) {
       this._subtopic = value;
    }

    connectedCallback() {
        this.fetchTopArticles();
    }
    
    get hasArticles() {
        return this.relatedArticles !== undefined && this.relatedArticles.length > 0;
    }

    fetchTopArticles() {
        this.loading = true;
        let searchParam;

        if(this._category !== undefined && this._category.length > 0) {
            searchParam = this._category + '__c';
        }
        if(this._topic !== undefined && this._topic.length > 0) {
            searchParam = this._topic + '__c';
        }
        if(this._subtopic !== undefined && this._subtopic.length > 0) {
            searchParam = this._subtopic + '__c';
        }
        if(searchParam === undefined) {
            searchParam = 'All__c';
        }

        getArticles({ selectedParams: searchParam, limitParam: this.numberOfArticles })
            .then(results => {
                if(results && results.length) {
                    let articles = [];
                    results.forEach( article => {
                        articles.push({ id: article.Id, title: article.Title });
                    });
                    
                    this.relatedArticles = articles;
                }
                this.loading = false;
            })
            .catch(error => {
                console.error('Top Articles error', JSON.parse(JSON.stringify(error)));
                this.loading = false;
            });
    }

    navigateToArticle(event) {
        let params = {};
        params.id1 = event.target.attributes.getNamedItem('data-item').value; // PARENT ARTICLE
        params.id2 = params.id1; // SPECIFIC RELATED ARTICLE TO THE PARENT ARTICLE

        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "support-view-article"
            }})
        .then(url => navigateToPage(url, params));
    }
}