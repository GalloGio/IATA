import { LightningElement, api, track } from 'lwc';
import getArticles from '@salesforce/apex/PortalFAQsCtrl.getArticles';
import getFAQsInfo from '@salesforce/apex/PortalFAQsCtrl.getFAQsInfo';
import createFeedback from '@salesforce/apex/PortalFAQsCtrl.createFeedback';
import getArticlesFeedback from '@salesforce/apex/PortalFAQsCtrl.getArticlesFeedback';
import randomUUID from '@salesforce/apex/PortalFAQsCtrl.randomUUID';
import CSP_ArticleHelpful from '@salesforce/label/c.CSP_ArticleHelpful';
import CSP_ThanksFeedback from '@salesforce/label/c.CSP_ThanksFeedback';
import CSP_FeedbackTitle from '@salesforce/label/c.CSP_FeedbackTitle';
import CSP_FeedbackBody from '@salesforce/label/c.CSP_FeedbackBody';
import CSP_FeedbackBody2 from '@salesforce/label/c.CSP_FeedbackBody2';
import CSP_Submit from '@salesforce/label/c.CSP_Submit';
import CSP_Cancel from '@salesforce/label/c.CSP_Cancel';
import csp_GoToSupport from '@salesforce/label/c.csp_GoToSupport';

export default class PortalFAQArticleAccordion extends LightningElement {
    label = {
        CSP_ArticleHelpful,
        CSP_ThanksFeedback,
        CSP_FeedbackTitle,
        CSP_FeedbackBody,
        CSP_FeedbackBody2,
        CSP_Submit,
        CSP_Cancel,
        csp_GoToSupport
    }
    @api category;
    @track _topic = [];
    @track _subTopic;
    @track childs;
    @track articles;
    @track error;
    @track renderedModal = false;
    @track articleComments = '';
    @track articleIds;
    @track sessionCookie;
    @track cookieValue;
    @track childs;
    @track searchRelated;
    @track counter;
    @track renderConfirmation = false;

    @api
    get topic() {
        return this._topic;
    }
    set topic(value) {
        if(value !== undefined) {
            let topicAux = JSON.parse(JSON.stringify(value));
            
            if(JSON.parse(JSON.stringify(this._topic)) !== topicAux.topic && this.counter !== topicAux.counter) {
                this._topic = topicAux.topic;
                this.counter = topicAux.counter;

                let actualTopic = [];
                actualTopic.push(this._topic);

                this.createParameter(actualTopic);
            } else {
                let _category = [];
                _category.push(this.category);

                this.createParameter(_category);
            }
        }
    }

    @api
    get subTopic() {
        return this._subTopic;
    }
    set subTopic(value) {
        if(value !== undefined) {
            this._subTopic = [];
            let _subtopic = JSON.parse(JSON.stringify(value));
            this._subTopic.push(_subtopic.subtopic);
    
            this.createParameter(this._subTopic);
        }
    }

    get hasArticles() {
        return this.articles !== undefined && this.articles.length > 0;
    }

    // GET COOKIE SESSION AND ALL SUBTOPICS TO RENDER CATEGORY ARTICLES
    connectedCallback() {
        let cookie = this.getCookie('PKB2SessionId');

        if(cookie !== null && cookie !== undefined) {
            this.sessionCookie = cookie;
        } else {
            randomUUID()
                .then(results => {
                    this.sessionCookie = results;
                    this.setCookie('PKB2SessionId', this.sessionCookie, 1);
                })
                .catch(error => {
                    this.error = error;
                }
            );
        }

        this.renderFAQs();
    }

    renderFAQs() {
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
                this.childs = childs;
                this.createParameter(childs);
    
                this.loading = false;
            })
            .catch(error => {
                this.error = error;
            }
        );        
    }

    createParameter(params) {        
        let selectedParams = [];
        selectedParams = '(';

        for(let i = 0; i < params.length; i++) {
            selectedParams += (i === 0) ? params[i] + '__c' : ', ' + params[i] + '__c';
        }
        selectedParams += ')';
        
        this.getArticlesFromParams(selectedParams);
    }

    getArticlesFromParams(selectedParams) {
        getArticles({ selectedParams : selectedParams })
            .then(result => {
                this.articles = [];
                if(result.length) {
                    let res = JSON.parse(JSON.stringify(result));

                    this.articleIds = [];
                    let tempArticles = [];
                    let tempArticleIds;
                    tempArticleIds = '(';
    
                    Object.keys(res).forEach(function (el) {                                  
                        tempArticles.push({ id: res[el].Id, number: res[el].ArticleNumber, label: res[el].Title, value: res[el].Answer__c, open: false, feedback: false });
                        tempArticleIds += (el === '0') ? '\'' + res[el].Id + '\'' : ', \'' + res[el].Id + '\'';
                    });
                    tempArticleIds += ')';
    
                    this.articles = tempArticles;
                    this.articleIds = tempArticleIds;
    
                    this.articlesFeedback();
                }                
            })
            .catch(error => {                
                this.error = error;
            }
        );        
    }
    
    articlesFeedback() {        
        getArticlesFeedback({ articleIds : this.articleIds, sessionCookie: this.sessionCookie })
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
            })
            .catch(error => {
                this.error = error;
            }
        );
    }

    articleSelected(event) {    
        let article = event.target.attributes.getNamedItem('data-item').value;
        this.searchRelated = article;

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
        
        if(this.renderedModal) {
            this.feedbackStatus(event);
        }
    }

    redirectSupport() {
        window.location.href = "/csportal/s/support-view-category?category=" + this.category;
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
}