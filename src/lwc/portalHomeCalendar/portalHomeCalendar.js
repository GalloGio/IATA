import { LightningElement, track } from 'lwc';
import getInitialMonthPage from '@salesforce/apex/PortalCalendarCtrl.getInitialMonthPage';
import getNextMonth from '@salesforce/apex/PortalCalendarCtrl.getNextMonth';
import getPreviousMonth from '@salesforce/apex/PortalCalendarCtrl.getPreviousMonth';
import goToOldPortalCalendar from '@salesforce/apex/PortalCalendarCtrl.goToOldPortalCalendar';
import isAirlineOrAgencyUser from '@salesforce/apex/PortalCalendarCtrl.isAirlineOrAgencyUser';

//custom labels
import ISSP_Weekday_Short_Sunday from '@salesforce/label/c.ISSP_Weekday_Short_Sunday';
import ISSP_Weekday_Short_Monday from '@salesforce/label/c.ISSP_Weekday_Short_Monday';
import ISSP_Weekday_Short_Tuesday from '@salesforce/label/c.ISSP_Weekday_Short_Tuesday';
import ISSP_Weekday_Short_Wednesday from '@salesforce/label/c.ISSP_Weekday_Short_Wednesday';
import ISSP_Weekday_Short_Thursday from '@salesforce/label/c.ISSP_Weekday_Short_Thursday';
import ISSP_Weekday_Short_Friday from '@salesforce/label/c.ISSP_Weekday_Short_Friday';
import ISSP_Weekday_Short_Saturday from '@salesforce/label/c.ISSP_Weekday_Short_Saturday';
import CSP_OperationalCalendar_HomeTileTitle from '@salesforce/label/c.CSP_OperationalCalendar_HomeTileTitle';
import CSP_OperationalCalendar_SeeMonthlyLink from '@salesforce/label/c.CSP_OperationalCalendar_SeeMonthlyLink';

export default class PortalHomeCalendar extends LightningElement {

    // Expose the labels to use in the template.
    label = {
        ISSP_Weekday_Short_Sunday,
        ISSP_Weekday_Short_Monday,
        ISSP_Weekday_Short_Tuesday,
        ISSP_Weekday_Short_Wednesday,
        ISSP_Weekday_Short_Thursday,
        ISSP_Weekday_Short_Friday,
        ISSP_Weekday_Short_Saturday,
        CSP_OperationalCalendar_HomeTileTitle,
        CSP_OperationalCalendar_SeeMonthlyLink
    };

    @track loading = true;

    @track currentViewingMonth;
    @track currentViewingWeek;

    @track lstEventsForCardFooter;
    @track viewEvents;

    @track showCalendar = false;

    connectedCallback() {

        isAirlineOrAgencyUser({})
        .then(results => {
            if(results === true){
                //renders if user is airline or agency
                this.loading = true;
                this.showCalendar = true;
                this.getInitialMonth();
            }
        });

    }

    get showCalendar(){
        return this.currentViewingMonth !== undefined && this.currentViewingWeek !== undefined;
    }

    changeEventsButtonClick(event){
        let itemNum = event.target.dataset.item;

        for(let i = 0; i < this.currentViewingWeek.lstDays.length; i++){
            if((this.currentViewingWeek.lstDays[i].dayNumber+'') === itemNum){
                this.lstEventsForCardFooter = this.currentViewingWeek.lstDays[i].lstEvents;
                this.currentViewingWeek.lstDays[i].isSelected = true;
                this.currentViewingWeek.lstDays[i].isSelectedClass = 'selectedDayBar';
            }else{
                this.currentViewingWeek.lstDays[i].isSelected = false;
                this.currentViewingWeek.lstDays[i].isSelectedClass = '';
            }
        }
        this.viewEvents = true;
    }

    goToOldPortalCalendarJS(){
        goToOldPortalCalendar({})
        .then(results => {
            window.open(results, "_self");
        });
    }

    getInitialMonth(){
        this.loading = true;

        //"YYYY-MM-DD"
        let dateAux = new Date();
        let dateAuxAux = '' + dateAux.getFullYear() + '-' + (dateAux.getMonth()+1) + '-' + dateAux.getDate();

        getInitialMonthPage({ browserDate : dateAuxAux,  requestedDate : dateAuxAux})
        .then(results => {
            this.updateEventClassName(results);
            this.currentViewingMonth = results;

            for(let i = 0; i < results.lstWeeks.length; i++){
                let isThisWeek = false;

                for(let j = 0; j < results.lstWeeks[i].lstDays.length; j++){
                
                    if(results.lstWeeks[i].lstDays[j].isHighlighted){
                        isThisWeek = true;
                        results.lstWeeks[i].lstDays[j].isSelected = true;
                        results.lstWeeks[i].lstDays[j].isSelectedClass = 'selectedDayBar';
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
        });
    }

    nextWeek(){
        let currentWeekNum = this.currentViewingWeek.weekNumber +1;
        let totalNumber = this.currentViewingMonth.lstWeeks.length;
        this.viewEvents = false;
        for(let i = 0; i < this.currentViewingWeek.lstDays.length; i++){
            this.currentViewingWeek.lstDays[i].isSelected = false;
            this.currentViewingWeek.lstDays[i].isSelectedClass = '';
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
            this.updateEventClassName(results);
            this.currentViewingMonth = results;
            this.currentViewingWeek = results.lstWeeks[0];
            this.loading = false;
        })
        .catch(error => {
            this.loading = false;
        });
    }

    previousWeek(){
        let currentWeekNum = this.currentViewingWeek.weekNumber;
        this.viewEvents = false;
        for(let i = 0; i < this.currentViewingWeek.lstDays.length; i++){
            this.currentViewingWeek.lstDays[i].isSelected = false;
            this.currentViewingWeek.lstDays[i].isSelectedClass = '';
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
            this.updateEventClassName(results);
            this.currentViewingMonth = results;
            this.currentViewingWeek = results.lstWeeks[(results.lstWeeks.length-1)];
            this.loading = false;
        })
        .catch(error => {
            this.loading = false;
        });
    }

    updateEventClassName(data) {
        if (data.lstWeeks) {
            data.lstWeeks.forEach(w => {
                if (w.lstDays) {
                    w.lstDays.forEach(d => {
                        if (d.lstEvents) {
                            d.lstEvents.forEach(e => {
                                e.className = `eventDot ${e.className}`;
                            });
                        }                        
                    });
                }
            });
        }
    }


}