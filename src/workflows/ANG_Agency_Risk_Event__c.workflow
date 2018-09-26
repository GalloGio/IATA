<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ANG_RiskEvent_Set_Unique_Key</fullName>
        <field>ANG_UniqueKey__c</field>
        <formula>CASESAFEID(ANG_Source_Id__c)+IF(ANG_TargetAgency__c == &apos;Selected Accounts&apos;,CASESAFEID(ANG_AccountId__c),&apos;&apos;)+ANG_Risk_ID__c</formula>
        <name>Set Unique Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Unique Key</fullName>
        <actions>
            <name>ANG_RiskEvent_Set_Unique_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISNEW() &amp;&amp; ISBLANK(ANG_UniqueKey__c)) || ISCHANGED(ANG_Source_Id__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
