<?xml version="1.0" encoding="UTF-8"?>
<CustomApplication xmlns="http://soap.sforce.com/2006/04/metadata">
    <brand>
        <headerColor>#00ACFD</headerColor>
        <shouldOverrideOrgTheme>false</shouldOverrideOrgTheme>
    </brand>
    <description>IATA Training Support- Lightning App</description>
    <formFactors>Large</formFactors>
    <isNavAutoTempTabsDisabled>false</isNavAutoTempTabsDisabled>
    <isNavPersonalizationDisabled>false</isNavPersonalizationDisabled>
    <label>IATA Training Service</label>
    <navType>Standard</navType>
    <profileActionOverrides>
        <actionName>View</actionName>
        <content>IATA_Training_cases</content>
        <formFactor>Large</formFactor>
        <pageOrSobjectType>Case</pageOrSobjectType>
        <recordType>Case.IATA_Training</recordType>
        <type>Flexipage</type>
        <profile>Admin</profile>
    </profileActionOverrides>
    <profileActionOverrides>
        <actionName>View</actionName>
        <content>IATA_Training_cases</content>
        <formFactor>Large</formFactor>
        <pageOrSobjectType>Case</pageOrSobjectType>
        <recordType>Case.IATA_Training</recordType>
        <type>Flexipage</type>
        <profile>IATA Training - Support Team</profile>
    </profileActionOverrides>
    <profileActionOverrides>
        <actionName>Tab</actionName>
        <content>IATA_Training_Home_Page</content>
        <formFactor>Large</formFactor>
        <pageOrSobjectType>standard-home</pageOrSobjectType>
        <type>Flexipage</type>
        <profile>IATA Training - Support Team</profile>
    </profileActionOverrides>
    <tabs>standard-home</tabs>
    <tabs>standard-Feed</tabs>
    <tabs>standard-Account</tabs>
    <tabs>standard-Contact</tabs>
    <tabs>standard-Case</tabs>
    <tabs>standard-report</tabs>
    <tabs>standard-Dashboard</tabs>
    <uiType>Lightning</uiType>
    <utilityBar>Service_UtilityBar</utilityBar>
</CustomApplication>
