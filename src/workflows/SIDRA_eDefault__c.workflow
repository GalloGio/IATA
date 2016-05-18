<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SIDRA_Default_details_update_case_number</fullName>
        <field>Default_record_code__c</field>
        <formula>SIDRA_Case__r.CaseNumber</formula>
        <name>SIDRA Default details update case number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_default_details_fill_default_date</fullName>
        <field>Default_date__c</field>
        <formula>DATEVALUE(SIDRA_Case__r.Update_AIMS_DEF__c)</formula>
        <name>SIDRA default details fill default date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>SIDRA Default Details update case number as code</fullName>
        <actions>
            <name>SIDRA_Default_details_update_case_number</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_default_details_fill_default_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISNULL(SIDRA_Case__r.Id)) &amp;&amp; NOT(ISNULL(SIDRA_Case__r.Update_AIMS_DEF__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
