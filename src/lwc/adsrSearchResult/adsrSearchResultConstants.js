const TABLE_TYPE_GROUP = "group";
const TABLE_TYPE_DETAIL = "detail";

const TABLE_GROUP_COLUMNS = [
    {
        label: "Operation",
        fieldName: "operation",
        type: "text"
    },
    {
        label: "Total Charged",
        fieldName: "totalCharged",
        type: "number"
    },
    {
        label: "Exchange Rate",
        fieldName: "exchangeRate",
        type: "number"
    },
    {
        label: "CCY",
        fieldName: "currencyCode",
        type: "text"
    }
];

const TABLE_DETAIL_COLUMNS = [
    {
        label: "Agent Code",
        fieldName: "agentCode",
        type: "text"
    },
    {
        label: "Agent Name",
        fieldName: "agentName",
        type: "text"
    },
    {
        label: "Default Date",
        fieldName: "defaultDate",
        type: "text"
    },
    {
        label: "Charged",
        fieldName: "charged",
        type: "number"
    },
    /*{
        label: "Share Rate",
        fieldName: "shareRate",
        type: "text"
    },*/
    {
        label: "Refunded",
        fieldName: "refunded",
        type: "number"
    },
    {
        label: "Refunded Rate",
        fieldName: "refundedRate",
        type: "number"
    },
    {
        label: "Outstanding",
        fieldName: "outstanding",
        type: "number"
    },
    {
        label: "CCY",
        fieldName: "currencyCode",
        type: "text"
    },
    {
        label: "Exchange Rate",
        fieldName: "exchangeRate",
        type: "number"
    },
    {
        label: "Outstanding USD",
        fieldName: "outstandingUSD",
        type: "number"
    },
    /*{
        label: "Total Industry",
        fieldName: "totalIndustry",
        type: "text"
    },
    {
        label: "Financial Security Status",
        fieldName: "financialSecurityStatus",
        type: "text"
    },
    {
        label: "Agent Status",
        fieldName: "agentStatus",
        type: "text"
    }*/
];

export {TABLE_TYPE_GROUP, TABLE_TYPE_DETAIL, TABLE_GROUP_COLUMNS, TABLE_DETAIL_COLUMNS}