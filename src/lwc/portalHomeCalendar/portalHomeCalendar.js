import { LightningElement, track } from 'lwc';
import getInitialMonthPage from '@salesforce/apex/PortalCalendarCtrl.getInitialMonthPage';
import getNextMonth from '@salesforce/apex/PortalCalendarCtrl.getNextMonth';
import getPreviousMonth from '@salesforce/apex/PortalCalendarCtrl.getPreviousMonth';
import goToOldPortalCalendar from '@salesforce/apex/PortalCalendarCtrl.goToOldPortalCalendar';

export default class PortalHomeCalendar extends LightningElement {

    @track loading = true;
    @track error;
    @track data;

    @track currentViewingMonth;
    @track currentViewingWeek;

    @track lstEventsForCardFooter;
    @track viewEvents;

    connectedCallback() {

        this.getInitialMonth();

    }

    changeEventsButtonClick(event){
        let itemNum = event.target.dataset.item;

        for(let i = 0; i < this.currentViewingWeek.lstDays.length; i++){
            if((this.currentViewingWeek.lstDays[i].dayNumber+'') === itemNum){
                this.lstEventsForCardFooter = this.currentViewingWeek.lstDays[i].lstEvents;
                this.currentViewingWeek.lstDays[i].isSelected = true;
            }else{
                this.currentViewingWeek.lstDays[i].isSelected = false;
            }
        }
        this.viewEvents = true;
    }

    goToOldPortalCalendarJS(){
        goToOldPortalCalendar()
        .then(results => {
            //console.log('results: ' , results);
            window.open(results);
        })
        .catch(error => {
            console.log('error: ' , error);
        });
    }

    getInitialMonth(){
        this.loading = true;

        //"YYYY-MM-DD"
        let dateAux = new Date();
        let dateAuxAux = '' + dateAux.getFullYear() + '-' + (dateAux.getMonth()+1) + '-' + dateAux.getDate();

        getInitialMonthPage({ browserDate : dateAuxAux,  requestedDate : dateAuxAux})
        .then(results => {
            //console.log('results ', results);
            this.currentViewingMonth = results;

            for(let i = 0; i < results.lstWeeks.length; i++){
                let isThisWeek = false;

                for(let j = 0; j < results.lstWeeks[i].lstDays.length; j++){
                
                    if(results.lstWeeks[i].lstDays[j].isHighlighted){
                        isThisWeek = true;
                        results.lstWeeks[i].lstDays[j].isSelected = true;
                        this.lstEventsForCardFooter = results.lstWeeks[i].lstDays[j].lstEvents;
                        this.viewEvents = true;
                        break;
                    } 

                }

                if(isThisWeek){
                    this.currentViewingWeek = results.lstWeeks[i];
                    break;
                }
            }
            this.loading = false;
        })
        .catch(error => {
            console.log('error: ' , error);
            this.loading = false;
        });
    }

    nextWeek(){
        let currentWeekNum = this.currentViewingWeek.weekNumber +1;
        let totalNumber = this.currentViewingMonth.lstWeeks.length;
        this.viewEvents = false;
        for(let i = 0; i < this.currentViewingWeek.lstDays.length; i++){
            this.currentViewingWeek.lstDays[i].isSelected = false;
        }
        if(currentWeekNum < totalNumber){
            this.currentViewingWeek = this.currentViewingMonth.lstWeeks[currentWeekNum];
        }else{
            this.getNextMonthJS();
        }
    }

    getNextMonthJS(){
        this.loading = true;

        //"YYYY-MM-DD"
        let dateAux = new Date();
        let browserDate = '' + dateAux.getFullYear() + '-' + (dateAux.getMonth()+1) + '-' + dateAux.getDate();

        let monthNumber = this.currentViewingMonth.monthNumber;
        let yearNumber = this.currentViewingMonth.monthYear;

        //(String browserDate, Integer monthNumber, Integer yearNumber)
        getNextMonth({ browserDate : browserDate,  monthNumber : monthNumber, yearNumber : yearNumber})
        .then(results => {
            //console.log('results ', results);
            this.currentViewingMonth = results;
            this.currentViewingWeek = results.lstWeeks[0];
            this.loading = false;
        })
        .catch(error => {
            console.log('error: ' , error);
            this.loading = false;
        });
    }

    previousWeek(){
        let currentWeekNum = this.currentViewingWeek.weekNumber;
        this.viewEvents = false;
        for(let i = 0; i < this.currentViewingWeek.lstDays.length; i++){
            this.currentViewingWeek.lstDays[i].isSelected = false;
        }
        if(currentWeekNum > 0){
            this.currentViewingWeek = this.currentViewingMonth.lstWeeks[(currentWeekNum-1)];
        }else{
            this.getPreviousMonthJS();
        }
    }

    getPreviousMonthJS(){ 
        this.loading = true;

        //"YYYY-MM-DD"
        let dateAux = new Date();
        let browserDate = '' + dateAux.getFullYear() + '-' + (dateAux.getMonth()+1) + '-' + dateAux.getDate();

        let monthNumber = this.currentViewingMonth.monthNumber;
        let yearNumber = this.currentViewingMonth.monthYear;

        //(String browserDate, Integer monthNumber, Integer yearNumber)
        getPreviousMonth({ browserDate : browserDate,  monthNumber : monthNumber, yearNumber : yearNumber})
        .then(results => {
            //console.log('results ', results);
            this.currentViewingMonth = results;
            this.currentViewingWeek = results.lstWeeks[(results.lstWeeks.length-1)];
            this.loading = false;
        })
        .catch(error => {
            console.log('error: ' , error);
            this.loading = false;
        });
    }

}