import { LightningElement, wire, track } from 'lwc';
import { resources, util, constants } from 'c/igUtility';
import getStations from '@salesforce/apex/IGOMStationUtil.getStationsData';
import userToProcedureToAcknowledgementStatus from '@salesforce/apex/IGOMDashboardDataUtil.userToProcedureToAcknowledgementStatus';
import variationStatusPerChapter from '@salesforce/apex/IGOMDashboardDataUtil.variationStatusPerChapter';
import itemStatusPerChapter from '@salesforce/apex/IGOMDashboardDataUtil.itemStatusPerChapter';
import statusPerStation from '@salesforce/apex/IGOMDashboardDataUtil.statusPerStation';
import stationSummaries from '@salesforce/apex/IGOMDashboardDataUtil.getStationSummary';
import getActualGapAnalyses from '@salesforce/apex/IGOMComplianceReviewUtil.getActualGapAnalyses';

const int = i => i === undefined ? 0 : parseInt(i);

const getName = (str) => str.substring(str.indexOf(':') + 1);
const getId = (str) => str.substring(0, str.indexOf(':'));

export default class IgDashboard extends LightningElement {
    
    resources = resources;

    stationDetail = false;
    selectedGapAnalysisId;
    @track selectAccountRoleId;

    @wire(getActualGapAnalyses, { stationId: '$selectAccountRoleId' })
	actualGapAnalyses;

    @wire(stationSummaries, { stationIds: '$stationListAccountRoleIds'})
    statusSummariesWired({ data, error}) {
        if (data) {
            for (const accountRoleId of Object.keys(data)) {
                const stationData = this.stationList.find(station => station.accountRoleId === accountRoleId);
                if (stationData) {
                    stationData.lastRevision = data[accountRoleId].lastGapAnalysisDate;
                    stationData.variations = data[accountRoleId].lastGapAnalysisVariations;
                    if (data[accountRoleId].readAcknowledgements) {
                        stationData.acknowledgements = data[accountRoleId].readAcknowledgements + '/' + data[accountRoleId].totalAcknowledgements;
                    }
                }
            }
            this.stationList = [...this.stationList];
        }
    }

    @track statusPerStationWiredChartable;
    @track statusPerStationData;
    statusPerStationColumns;

    @wire(statusPerStation)
    statusPerStationWired({ data, error }) {
        if (data) {
            this.statusPerStationData = Object.keys(data).map(el => ({ 
                id: el.split(':')[0], 
                name: el.split(':')[1], 
                status: data[el] 
            }));
            this.statusPerStationColumns = Object.keys(this.statusPerStationData[0]).filter(col => col !== 'id').map(col => ({ label: col, fieldName: col }));
            const labelToColor = {
                'Non-existing': constants.COLORS.CHART.VALUES.GRAY,
                'Reviewed': constants.COLORS.CHART.VALUES.GREEN,
                'Pending review': constants.COLORS.CHART.VALUES.RED
            };
            // Accumulate results
            const countedData = util.object.countValues(data);
            this.statusPerStationWiredChartable = {
                datasets: [
                    {
                        data: Object.values(countedData),
                        backgroundColor: Object.keys(countedData).map(label => labelToColor[label]),
                        label: 'Status'
                    }
                ],
                labels: Object.keys(countedData)
            };
        }
    }

    @track acknowledgementsOnVariationChartable;
    acknowledgementsOnVariationChartOptions = {
        scales: {
            yAxes: [{
                stacked: true
            }],
            xAxes: [{
                stacked: true,
                ticks: {
                    callback: (value) => value.substr(0, 12) + (value.length > 12 ? '...' : ''),
                }
            }]
        }
    };
    acknowledgementsOnVariationData;
    acknowledgementsOnVariationGeneralView;

    @wire(userToProcedureToAcknowledgementStatus, { gapAnalysisId: '$selectedGapAnalysisId' })
    acknowledgementsOnVariationWired({ data, error }) {
        if (data) {
            // Preparsing
            data = JSON.parse(data);
            this.acknowledgementsOnVariationData = data;
            const procedureNames = util.array.unique([...Object.keys(data).map(user => Object.keys(data[user]))].flat());
            const generalData = procedureNames.map(procedureName => ({ 
                procedure: procedureName, 
                values: util.object.countValues(Object.values(data).map(procedure => procedure[procedureName])) 
            }));
            this.acknowledgementsOnVariationGeneralView = generalData;
            this.acknowledgementsOnVariationChartable = {
                datasets: [
                    {
                        data: generalData.map(el => int(el.values[constants.NOTIFICATION.STATUS.VALUES.ACKNOWLEDGED])),
                        backgroundColor: constants.COLORS.CHART.VALUES.GREEN,
                        label: constants.NOTIFICATION.STATUS.VALUES.ACKNOWLEDGED
                    },
                    {
                        data: generalData.map(el => int(el.values[constants.NOTIFICATION.STATUS.VALUES.UNREAD])),
                        backgroundColor: constants.COLORS.CHART.VALUES.YELLOW,
                        label: constants.NOTIFICATION.STATUS.VALUES.UNREAD
                    },
                ],
                labels: generalData.map(element => getName(element.procedure))
            };
        }
    }

    acknowledgementsOnVariationDetail;
    acknowledgementsOnVariationDataSelectHandler(event) {
        const detail = event.detail;
        const procedureIndex = event.detail.dataIndex;
        const procedure = this.acknowledgementsOnVariationGeneralView[procedureIndex].procedure;
        const procedureId = getId(procedure);
        const chart = event.target;
        if (this.acknowledgementsOnVariationDetail && this.acknowledgementsOnVariationDetail.procedureId === procedureId) {
            this.acknowledgementsOnVariationDetail = null;
            chart.hideDetail();
        } else {
            const userToStatus = Object.keys(this.acknowledgementsOnVariationData).map(user => ({
                id: getId(user),
                userName: getName(user),
                status: this.acknowledgementsOnVariationData[user][procedure]
            }));
            this.acknowledgementsOnVariationDetail = {
                procedure: getName(procedure),
                procedureId: procedureId,
                data: userToStatus,
                columns: [{ 
                    label: 'User',
                    fieldName: 'userName'
                }, {
                    label: 'Status',
                    fieldName: 'status'
                }]
            };
            chart.showDetail();
        }        
    }

    @track variationStatusPerChapterChartable;
    variationStatusPerChapterOptions = {
        scales: {
            yAxes: [{
                stacked: true
            }],
            xAxes: [{
                stacked: true
            }]
        },
        legend: {
            display: false
        }
    };

    @track variationStatusAllChartable;
    
    @wire(variationStatusPerChapter, { gapAnalysisId: '$selectedGapAnalysisId' })
    variationStatusPerChapterWired({ data, error }) {
        if (data) {
            this.variationStatusPerChapterChartable = {
                datasets: [
                    {
                        data: Object.keys(data).map(chapter => int(data[chapter][constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.CONFORMITY])),
                        backgroundColor: constants.COLORS.CHART.VALUES.GREEN,
                        label: 'Conformity'
                    },
                    {
                        data: Object.keys(data).map(chapter => int(data[chapter][constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.VARIATION])),
                        backgroundColor: constants.COLORS.CHART.VALUES.YELLOW,
                        label: 'Variation'
                    },
                    {
                        data: Object.keys(data).map(chapter => int(data[chapter][constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.OUT_OF_SCOPE])),
                        backgroundColor: constants.COLORS.CHART.VALUES.GRAY,
                        label: 'Out of scope'
                    }
                ],
                labels: Object.keys(data)
            };
            this.variationStatusAllChartable = {
                datasets: [
                    {
                        data: [constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.CONFORMITY, constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.VARIATION, constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.OUT_OF_SCOPE].map(field =>
                            Object.keys(data).map(chapter => int(data[chapter][field])).reduce((el, acc) => el+acc, 0)
                        ),
                        backgroundColor: [
                            constants.COLORS.CHART.VALUES.GREEN,
                            constants.COLORS.CHART.VALUES.YELLOW,
                            constants.COLORS.CHART.VALUES.GRAY
                        ],
                        label: 'Variation status'
                    }
                ],
                labels: ['Conformity', 'Variation', 'Out of Scope']
            };
        }
    }

    @track itemStatusAllChartable;

    @wire(itemStatusPerChapter, { gapAnalysisId: '$selectedGapAnalysisId' })
    itemStatusPerChapterWired({ data, error }) {
        if (data) {
            this.itemStatusAllChartable = {
                datasets: [
                    {
                        data: [true, false].map(field =>
                            Object.keys(data).map(chapter => int(data[chapter][field])).reduce((el, acc) => el+acc, 0)
                        ),
                        backgroundColor: [
                            constants.COLORS.CHART.VALUES.GREEN,
                            constants.COLORS.CHART.VALUES.RED
                        ],
                        label: 'Item status'
                    }
                ],
                labels: ['Reviewed', 'Pending review']
            };
        }
    }

    selectTab(event){
        let selectedTab = event.target.closest('.dashboard-section');
        let unselectedTab = this.template.querySelector('.section-selected');
        unselectedTab.classList.remove('section-selected');
        selectedTab.classList.add('section-selected');
    }

    showSelect(){
        this.template.querySelector('.divSelect').classList.remove('hidden');
    }

    // Station lists
    @track stationList;
    stationListAccountRoleIds;
    stationListConfig = {
		logo: {
			type: 'image',
			hideHeader: true
		},
		name: {
            sortable: true,
            searchable: true
        },
        type: {
            centerContent: true
        },
		country: {
            sortable: true,
            searchable: true
		},
		city: {
            sortable: true,
            searchable: true
		},
		lastRevision: {
			centerContent: true
		},
		variations: {
			centerContent: true
		},
		acknowledgements: {
            label: 'Acks',
			centerContent: true
		},
		goToReport: {
			type: 'link',
			hideHeader: true,
			centerContent: true
        }, 
        accountId: {
            ignore: true
        },
        accountRoleId: {
            ignore: true
        },
		publishesTemplates: {
			ignore: true
		}
    };
    @wire(getStations, { forPage: 'Dashboard' })
	getStationLists({data, error}) {
		if (data) {
			let stations = JSON.parse(JSON.stringify(data));
			for (let station of stations) {
                station.goToReport = station.id;
			}
            this.stationList = stations;
		}
    };
    
    goToStationDetail(event) { 
		const stationId = event.detail.linkData;
        this.selectedStation = this.stationList.find(el => el.id === stationId);
        this.selectAccountRoleId = this.selectedStation.accountRoleId;
        this.stationDetail = true;
    }

    changedShownStationIds(event) {
        const shownIds = event.detail.shownIds;
        if (shownIds && shownIds.length > 0) {
            this.stationListAccountRoleIds = this.stationList.filter(station => shownIds.includes(station.id)).map(station => station.accountRoleId);
        }
    }

    leaveStationDetail() {
        this.stationDetail = false;
        this.chartjsInitialized = false;
        this.selectedGapAnalysisId = undefined;
    }

    gapAnalaysisChangeHandler(event) {
        const gapAnalysisId = event.detail.gapAnalysisId;
        this.selectedGapAnalysisId = gapAnalysisId;
    }

}