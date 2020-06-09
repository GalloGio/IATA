const TABLE_TYPE_GROUP = "group";
const TABLE_TYPE_DETAIL = "detail";

const SEARCH_TYPE_OPERATION = "market";
const SEARCH_TYPE_AGENT = "agent";

const TABLE_GROUP_COLUMNS = [
	{
		type: "text",
		label: "Operation Name",
		targetField: "operation",
		displayTotal: false
	},
	{
		type: "number",
		label: "Total Charged $",
		targetField: "totalChargedUSD",
		displayTotal: true,
		minDecimalPlaces: 2,
		maxDecimalPlaces: 2
	},
	{
		type: "number",
		label: "Total Recovered $",
		targetField: "totalRecoveredUSD",
		displayTotal: true,
		minDecimalPlaces: 2,
		maxDecimalPlaces: 2
	},
	{
		type: "number",
		label: "Total Outstanding $",
		targetField: "totalOutstandingUSD",
		displayTotal: true,
		minDecimalPlaces: 2,
		maxDecimalPlaces: 2
	},
	{
		type: "number",
		label: "Total Charged in Local Currency",
		targetField: "totalCharged",
		displayTotal: false,
		minDecimalPlaces: 2,
		maxDecimalPlaces: 2
	},
	{
		type: "number",
		label: "Total Recovered in Local Currency",
		targetField: "totalRecovered",
		displayTotal: false,
		minDecimalPlaces: 2,
		maxDecimalPlaces: 2
	},
	{
		type: "number",
		label: "Total Outstanding in Local Currency",
		targetField: "totalOutstanding",
		displayTotal: false,
		minDecimalPlaces: 2,
		maxDecimalPlaces: 2
	},
	{
		type: "text",
		label: "CCY",
		targetField: "currencyCode",
		displayTotal: false
	},
	{
		type: "number",
		label: "Exchange Rate",
		targetField: "exchangeRate",
		displayTotal: false
	},
	{
		type: "percent",
		label: "% Recovered",
		targetField: "recoveredRate",
		displayTotal: false,
		minDecimalPlaces: 2,
		maxDecimalPlaces: 2
	}
];

const TABLE_DETAIL_COLUMNS = [
	{
		label:"Agent Code",
		targetField:"agentCode",
		type:"text",
		helptext: "(Head Office Code) The 7 digit code of the Head Office of the agency. All the BR codes are consolidated under the HO code."
	},
	{
		label:"Agent Name",
		targetField:"agentName",
		type:"text",
		helptext: "The legal name of the Agent as per the IATA AIMS database."
	},
	{
		label:"Default Date",
		targetField:"defaultDate",
		type:"text",
		helptext: "The Date when we put the Agent in Default."
	},
	{
		label:"Currently Charged in Local Currency",
		targetField:"charged",
		type:"number",
		helptext: "Total Amount charged to the airline at the last day of the month of the report.",
		minDecimalPlaces: 2,
		maxDecimalPlaces: 2,
		displayTotal: true
	},
	{
 		label: "AL Share versus Total Industry Default %",
 		targetField: "shareRate",
		type: "percent",
		helptext: "[Accumulated Charged in Local Currency] / the total charged amount in the market."
	},
	{
		label:"Currently Refunded in Local Currency",
		targetField:"refunded",
		type:"number",
		helptext: "Total Amount Recovered and refunded to the airline at the last day of the previous month at the report date.",
		minDecimalPlaces: 2,
		maxDecimalPlaces: 2,
		displayTotal: true
	},
	{
		label:"Refunded against Charged %",
		targetField:"refundedRate",
		type:"percent",
		helptext: "[Currently Recovered in Local Currency] / [Accumulated Charged in Local Currency].",
		minDecimalPlaces: 2,
		maxDecimalPlaces: 2
	},
	{
		label:"Current Outstanding in Local Currency",
		targetField:"outstanding",
		type:"number",
		helptext: "[Accumulated Charged in Local Currency] - [Currently Recovered in Local Currency].",
		minDecimalPlaces: 2,
		maxDecimalPlaces: 2,
		displayTotal: true
	},
	{
		label:"Local CCY",
		targetField:"currencyCode",
		type:"text",
		helptext: "Currency"
	},
	{
		label:"Exch. Rate",
		targetField:"exchangeRate",
		type:"percent",
		helptext: "Exchange rate applied to convert to US Dollars.",
		minDecimalPlaces: 2,
		maxDecimalPlaces: 2
	},
	{
		label:"Current Outstanding in USD",
		targetField:"outstandingUSD",
		type:"number",
		helptext: "[Current Remaining Outstanding in Local Currency] X [Exch. Rate].",
		minDecimalPlaces: 2,
		maxDecimalPlaces: 2,
		displayTotal: true
	},
	{
 		label: "Total Industry",
 		targetField: "totalIndustry",
		type: "number",
		helptext: "Total Sum of Financial Cover pending encashment activated by our risk department.",
		minDecimalPlaces: 2,
		maxDecimalPlaces: 2,
		displayTotal: true
	},
	/*
	{
		label: "BG CCY",
		fieldName: "",
		type: "text"
	}*/
	{
		label: "Financial Security Status",
		targetField: "financialSecurityStatus",
		type: "text",
		description: "First Call Letter Sent- Nonpayment notification sent to the Financial Institution providing information about unpaid debt after the Agent’s default.<br>"
					+"Final Claim Sent – Financial security claim notification sent to the Financial Institution providing information about the total unpaid debt after the Agent’s termination.<br>"
					+"Financial Security Encashed- Financial Institution has accepted the claim and proceeded with the down payment equal to the financial security amount or defaulted amount.<br>"
	},
	{
		label: "Agent Status",
		targetField: "agentStatus",
		type: "text",
		helptext: "Current agency standing with IATA",
		description: "Default - Agency, or one if its Locations, has breached the provisions of the Sales Agency Rules to the extent that remedial action is required, and for which failure to take such action may ultimately result in the termination of that Agent's Sales Agency Agreement<br>"
					+"Termination - Notice of removing the agent from the Agency List and terminating the Passenger Sales Agency Agreement<br>"
					+"Repayment Agreement- Defaulted Agency has signed an alternative repayment schedule with IATA<br>"
					+"Reinstated - Agency is not in default status anymore and rejoined agency program after complying with reinstated requirements<br>"
					+"Legal Action- Ongoing court case or other any legal formalities are linked to the agency<br>",
		"info": (record, index, records) => {
			if(record.agentStatus === "Repayment Agreement" && record.dueDate !== undefined && record.dueDate !== null){
				return "AGREEMENT ON REPAYMENT SCHEDULE PLAN HAS BEEN REACHED.<br>"
					+ "AGENT WILL BE REACTIVATED AFTER THE COMPLETION OF THE REPAYMENT PLAN AND SATISFYING THE CONDITIONS OF THE RESOLUTIONS.<br>"
					+ "FAILURE TO HONOR THE REPAYMENT AGREEMENT WILL RESULT IN REMOVAL OF THE AGENT FROM THE AGENCY LIST.<br>"
					+ "LAST INSTALLMENT WILL BE ON " + record.dueDate + ".";
			}
			return false;
		},
		infoStyle: {
			width: '420px',
			top: '- 55px',
			left: '- 260px'
		}
	}
];

export {TABLE_TYPE_GROUP, TABLE_TYPE_DETAIL, SEARCH_TYPE_OPERATION, SEARCH_TYPE_AGENT, TABLE_GROUP_COLUMNS, TABLE_DETAIL_COLUMNS}