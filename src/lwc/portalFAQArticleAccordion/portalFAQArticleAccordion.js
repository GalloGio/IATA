import { LightningElement, api, track } from 'lwc';
import getArticlesByLanguage from '@salesforce/apex/PortalFAQsCtrl.getArticlesByLanguage';
import getFAQsInfoByLanguage from '@salesforce/apex/PortalFAQsCtrl.getFAQsInfoByLanguage';
import createFeedback from '@salesforce/apex/PortalFAQsCtrl.createFeedback';
import getArticlesFeedback from '@salesforce/apex/PortalFAQsCtrl.getArticlesFeedback';
import randomUUID from '@salesforce/apex/CSP_Utils.randomUUID';
import getArticleTitle from '@salesforce/apex/PortalFAQsCtrl.getArticleTitle';
import getFilteredFAQsResultsPage from '@salesforce/apex/PortalFAQsCtrl.getFilteredFAQsResultsPage';
import getShareableLink from '@salesforce/apex/PortalFAQsCtrl.getShareableLink';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import { NavigationMixin } from 'lightning/navigation';

import CSP_ArticleHelpful from '@salesforce/label/c.CSP_ArticleHelpful';
import CSP_ThanksFeedback from '@salesforce/label/c.CSP_ThanksFeedback';
import CSP_FeedbackTitle from '@salesforce/label/c.CSP_FeedbackTitle';
import CSP_FeedbackBody from '@salesforce/label/c.CSP_FeedbackBody';
import CSP_FeedbackBody2 from '@salesforce/label/c.CSP_FeedbackBody2';
import CSP_Submit from '@salesforce/label/c.CSP_Submit';
import CSP_Cancel from '@salesforce/label/c.CSP_Cancel';
import csp_GoToSupport from '@salesforce/label/c.CSP_Continue';
import CSP_SearchFAQ from '@salesforce/label/c.CSP_SearchFAQ';
import CSP_ShareLink from '@salesforce/label/c.CSP_ShareLink';
import CSP_Share_CopiedToClipBoard from '@salesforce/label/c.CSP_Share_CopiedToClipBoard';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalFAQArticleAccordion extends NavigationMixin(LightningElement) {
    label = {
        CSP_ArticleHelpful,
        CSP_ThanksFeedback,
        CSP_FeedbackTitle,
        CSP_FeedbackBody,
        CSP_FeedbackBody2,
        CSP_Submit,
        CSP_Cancel,
        csp_GoToSupport,
        CSP_ShareLink,
        CSP_Share_CopiedToClipBoard,
        CSP_SearchFAQ
    }
    @api category;
    @track _articleView;
    @track language;
    @track loading = true;
    @track userInfo = {};
    @track _topic = [];
    @track _subTopic;
    @track childs;
    @track articles;
    @track renderedModal = false;
    @track articleComments = '';
    @track articleIds;
    @track sessionCookie;
    @track childs;
    @track articleInfo;
    @track counter;
    @track renderConfirmation = false;
    @track searchText;
    @track _faqObject = {};
    @track showCross=false;
    @track isGuestUser=true;

    searchIconUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchColored.svg';
    shareIconUrl = CSP_PortalPath + 'CSPortal/Images/Icons/CopyLinkIcon.png';

    @api
    get faqObject() {
        return this._faqObject;
    }
    set faqObject(value) {
        let _value = JSON.parse(JSON.stringify(value));
        this._faqObject = _value;
        this.language = this._faqObject.language !== undefined && this._faqObject.language !== '' ? this._faqObject.language : '';

        this.userInfo.language = this.language;
        this.isGuestUser=this._faqObject.language !== undefined && this._faqObject.language !== '' ? true : false;        
        this.userInfo.guestUser = this.isGuestUser;

        this.redirectionTo();
    }

    @api redirectObject;

    @api
    get articleView() {
        return this._articleView;
    }
    set articleView(value) {
        this._articleView = value;
        
        this.language = this._articleView.language !== undefined && this._articleView.language !== '' ? this._articleView.language : '';
        this.isGuestUser=this._articleView.language !== undefined && this._articleView.language !== '' ? true : false;        
        this.userInfo.guestUser = this.isGuestUser;
        this.userInfo.language=this.language ;
        this.redirectionTo();
    }

    get hasArticles() {
        return this.articles !== undefined && this.articles.length > 0;
    }

    get hideSearchbar(){
        return  this._articleView !== undefined &&this._articleView.UrlName != undefined;
    }

    
    // GET COOKIE SESSION AND INITIALIZE LIST OF ARTICLES
    connectedCallback() {
        // Used on portalFAQRelatedArticle
     
        let cookie = this.getCookie('PKB2SessionId');
        
        if(this._articleView !== undefined && this._articleView.q !== undefined) {
            this.searchText = this._articleView.q;
        }

        if(cookie !== null && cookie !== undefined) {
            this.sessionCookie = cookie;
        } else {
            randomUUID()
                .then(results => {
                    this.sessionCookie = results;
                    this.setCookie('PKB2SessionId', this.sessionCookie, 1);
                });
        }
    }

    // DEFINE WHICH METHOD TO LOAD BASED ON CATEGORY, A SPECIFIC ARTICLE OR FROM SEARCH PARAM
    redirectionTo() {
        if(this._faqObject.category !== undefined) {

            if(this._faqObject.category !== '') {
                this.renderFAQs(); // RENDER ARTICLES FROM DEEPEST SUBTOPICS
            } else if(this._faqObject.topic !== '') {
                let _topic = [];
                _topic.push(this._faqObject.topic);
    
                this.createParameter(_topic);
            } else if(this._faqObject.subtopic !== '') {
                let _subtopic = [];
                _subtopic.push(this._faqObject.subtopic);
        
                this.createParameter(_subtopic);
            }

        } else if(this._articleView !== undefined) {

            if(this._articleView.q !== undefined || this._articleView.UrlName !== undefined) {
                let filteringObject = {};
                filteringObject.searchText = this._articleView.q;
                filteringObject.language = this.language;
                filteringObject.urlName = this._articleView.UrlName;
                filteringObject.guestUser = this.language !== undefined && this.language !== '' ? true : false;
                
                /* SAME METHOD USED IN SEARCH FUNCTIONALITY
                RETRIEVE ARTICLES WITH SEARCH TERMS OCURRIENCES IN TITLE AND SUMMARY FIELDS */
                getFilteredFAQsResultsPage({ searchKey : JSON.stringify(filteringObject), requestedPage : '0'})
                .then(results => {
                    this.articles = [];
                    if(results.records && results.records.length>=0) {
                        this.handleCallback(results.records);
                    }
                });            
            } else {
                /* GET ARTICLE TITLE FROM ITS ID, TO BE USED IN THE SOSL SEARCH */
                getArticleTitle({ articleId : this._articleView.id1 })
                    .then(resultsTitle => {
                        let filteringObject = {};
                        filteringObject.searchText = resultsTitle;
                        filteringObject.language = this.language;
                        filteringObject.guestUser = this.language !== undefined && this.language !== '' ? true : false;
                        
                        this.renderSearchArticles(JSON.stringify(filteringObject));
                    });
            }

        }
    }

    // RELATED TO SUPPORT VIEW CATEGORY PAGE, GETTING THE DEEPEST SUBTOPICS TO RENDER ARTICLES FOR A SPECIFIC CATEGORY
    renderFAQs() {
        getFAQsInfoByLanguage({ lang : this.language })
            .then(results => {
                let result = JSON.parse(JSON.stringify(results));

                let childs = [];
                
                let tempCategoryName = this._faqObject.category; //Contains selected category from portalFAQPage
        
                Object.keys(result).forEach(function (el) {
                    if(tempCategoryName === result[el].categoryName) {
                        Object.keys(result[el].childs).forEach(function (elAux) {
                            childs.push(result[el].childs[elAux]);
                        });
                    }
                });
                this.childs = childs;
                this.createParameter(childs);
            });        
    }

    // SOSL SEARCH TO RETRIEVE RELATED ARTICLES FOR A GIVEN SEARCH PARAM
    renderSearchArticles(searchParam) {
        getFilteredFAQsResultsPage({ searchKey : searchParam, requestedPage : '0'})
            .then(resultsArticles => {
                this.articles = [];
                if(resultsArticles.records.length) {
                    this.handleCallback(resultsArticles.records);
                }
            });
    }

    // HANDLE CALLBACK TO BUILD ARTICLE'S LIST, WITH AN OPEN ARTICLE, ARTICLE'S FEEDBACK AND A LIST OF RELATED ARTICLES
    handleCallback(results) {
        this.loading = true;
        let res = JSON.parse(JSON.stringify(results));
    
        this.articleIds = [];
        let tempArticles = [];
        let tempArticleIds;
        let articleSelected = {};              
        let relatedArticleId;

        if(this._articleView !== undefined) {
            if(this._articleView.q !== undefined) {
                relatedArticleId = this._articleView.id1;
            } else {
                relatedArticleId = this._articleView.id2;
            }
        } else {
            relatedArticleId = undefined;
        }

        tempArticleIds = '(';

      
        for(let el=0;el< res.length;el++){
             if((relatedArticleId !== undefined && relatedArticleId === res[el].Id)||res.length==1 ) { // OPENS THE ARTICLE PREVIOUSLY CLICKED THAT CAME FROM RELATED ARTICLES LIST OR SEARCH LIST
                tempArticles.push({ id: res[el].Id, number: res[el].ArticleNumber, label: res[el].Title, value: res[el].Answer__c, urlName:res[el].UrlName, open: true, feedback: false, Link : res[el].CS_Portal_link__c });
                articleSelected = {
                    title : res[el].Title,
                    id : res[el].Id
                };
            } else { 
                tempArticles.push({ id: res[el].Id, number: res[el].ArticleNumber, label: res[el].Title, value: res[el].Answer__c, urlName:res[el].UrlName, open: false, feedback: false, Link : res[el].CS_Portal_link__c });
            }
            tempArticleIds += (el === 0) ? '\'' + res[el].Id + '\'' : ', \'' + res[el].Id + '\'';
        }

        tempArticleIds += ')';
        
        this.articles = tempArticles;
        this.articleIds = tempArticleIds; // SET OF IDS USED TO SEARCH ARTICLE'S FEEDBACK
        this.articleInfo = articleSelected; // RENDER RELATED ARTICLES
        this.loading = false;

        this.articlesFeedback();
    }

    // CREATE THE RIGHT PATTERN TO BE USED IN A SOQL QUERY TO RETRIEVE ARTICLES
    createParameter(params) {                
        let selectedParams = [];
        selectedParams = '(';

        for(let i = 0; i < params.length; i++) {
            selectedParams += (i === 0) ? params[i] + '__c' : ', ' + params[i] + '__c';
        }
        selectedParams += ')';
        
        this.getArticlesFromParams(selectedParams);
    }

    // GET SPECIFIC ARTICLES FOR A GIVEN CATEGORY/TOPIC/SUBTOPIC
    getArticlesFromParams(selectedParams) {
        getArticlesByLanguage({ selectedParams : selectedParams, lang : this.language })
            .then(result => {
                this.articles = [];
                if(result.length) {
                    this.loading = true;
                    let res = JSON.parse(JSON.stringify(result));

                    this.articleIds = [];
                    let tempArticles = [];
                    let tempArticleIds;
                    tempArticleIds = '(';
    
                   for (let el = 0; el < res.length; el++) {
                      
                        tempArticles.push({ id: res[el].Id, number: res[el].ArticleNumber, label: res[el].Title, value: res[el].Answer__c, open: false, feedback: false, Link : res[el].CS_Portal_link__c });
                        tempArticleIds += (el === 0) ? '\'' + res[el].Id + '\'' : ', \'' + res[el].Id + '\'';
                    }
                    tempArticleIds += ')';
    
                    this.articles = tempArticles;
                    this.articleIds = tempArticleIds; // SET OF IDS USED TO SEARCH ARTICLE'S FEEDBACK
    
                    this.articlesFeedback();
                }
                this.loading = false;
            });
    }
    
    // GET ARTICLE'S FEEDBACKS ACCORDING TO SESSION COOKIE AND ARTICLES BEING DISPLAYED
    articlesFeedback() {
         getArticlesFeedback({ articleIds : this.articleIds, sessionCookie : this.sessionCookie })
            .then(result => {
                let res = JSON.parse(JSON.stringify(result));

                let articleVals = JSON.parse(JSON.stringify(this.articles));
        
                for(let i = 0; i < articleVals.length; i++) {
                    for(let j = 0; j < res.length; j++) {
                        if(articleVals[i].id === res[j].Article_ID__c) {
                            articleVals[i].feedback = true;
                            break;
                        }
                    }
                }
        
                this.articles = articleVals;
                this.loading = false;
            }).catch(error=>{
                this.loading = false;
            }); 
    }

    // HANDLE FOR SELECTED ARTICLE
    expandArticle(event) {
        let articleTitle = event.target.attributes.getNamedItem('data-item').value;
        let articleId = event.target.attributes.getNamedItem('data-id').value;
        this.articleInfo = { // RENDER RELATED ARTICLES
            title : articleTitle,
            id : articleId
        };        

        let articleVals = JSON.parse(JSON.stringify(this.articles));        
       
        for (let index = 0; index < articleVals.length; index++) {
            
            if(articleTitle === articleVals[index].label && articleVals[index].open === false) {
                articleVals[index].open = true;
            } else {
                articleVals[index].open = false;
            }
        }
           
        this.articles = articleVals;
    }

    onInputChange(event) {    
        if(event.detail.key !== '') {
            this.searchText = event.detail.key;
            let filteringObject = {};
            filteringObject.searchText = this.searchText;
            filteringObject.language = this.language;
            filteringObject.guestUser = this.language !== undefined && this.language !== '' ? true : false;

            this.renderSearchArticles(JSON.stringify(filteringObject));
        }else{
            this.redirectionTo();
        }
    }

    feedbackComments(event) {
        this.articleComments = event.target.value;
    }

    feedbackStatus(event) {
        this.articleId = event.target.attributes.getNamedItem('data-item').value;
        this.articleNumber = event.target.attributes.getNamedItem('data-number').value;
        this.articleTitle = event.target.attributes.getNamedItem('data-title').value;
        this.isDeferred = event.target.attributes.getNamedItem('data-option').value;

        if(!this.renderedModal) this.saveFeedback();
    }

    saveFeedback() {
        createFeedback({ 
            articleId : this.articleId,
            articleNumber: this.articleNumber ,
            articleTitle: this.articleTitle,
            feedbackSource: 'Search',
            feedbackComments: this.articleComments,
            sessionId: this.sessionCookie,
            isDeferred: this.isDeferred
        })
            .then(result => {
                this.renderConfirmation = true;      
                let articleVals = JSON.parse(JSON.stringify(this.articles));
        
                for(let i = 0; i < articleVals.length; i++) {
                    if(articleVals[i].id === this.articleId) {
                        articleVals[i].feedback = true;
                        break;
                    }
                }
        
                this.articles = articleVals; 
                if(this.renderedModal) this.renderModal();
            })
            .catch(error => {
                if(this.renderedModal) this.renderModal();
            }
        );
    }
    
    renderModal(event) {
        this.renderedModal = !this.renderedModal;
        
        if(this.renderedModal) this.feedbackStatus(event);
    }

    setCookie(name, value, days) {
        let expires = "";
        if (days) {
          let date = new Date();
          date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
          expires = "; expires=" + date.toUTCString();
        }
        document.cookie = name + "=" + (value || "") + expires + "; path=/";
    }
      
    getCookie(name) {
        let nameEQ = name + "=";
        let ca = document.cookie.split(';');
        for (let i = 0; i < ca.length; i++) {
          let c = ca[i];
          while (c.charAt(0) === ' ') c = c.substring(1, c.length);
          if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length, c.length);
        }
        return null;
    } 
    
    closeModal() {
        this.renderConfirmation = !this.renderConfirmation;
    }
    removeTextSearch(){
        this.showCross=false;
        this.searchText='';
        this.redirectionTo();
    }


    copyUrlToClipboard(e){
        let artid = e.target.dataset.id;

        //temporary show the input, and hide it just after the link has been copied

        getShareableLink({articleId : artid})
            .then(data=>{
                let urlPlaceholder=this.template.querySelector("[data-article-url]");
                urlPlaceholder.value=data;
                urlPlaceholder.classList.toggle('slds-hide');
            
                urlPlaceholder.select();
                urlPlaceholder.setSelectionRange(0, 99999);
            
                document.execCommand("copy");

                urlPlaceholder.classList.toggle('slds-hide');
                
                const toast = new ShowToastEvent({
                    title: this.label.CSP_Success,
                    variant:'success',
                    mode:'pester',
                    message: this.label.CSP_Share_CopiedToClipBoard
                });
                this.dispatchEvent(toast);
            }
        );
        
    }
}