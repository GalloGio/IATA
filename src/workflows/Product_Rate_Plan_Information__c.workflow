<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>IEC_UpdateUniqueRatePlan</fullName>
        <field>IECUniqueRatePlan__c</field>
        <formula>Related_Product_Information__r.Name  &amp;&apos;-&apos;&amp; TEXT( Related_Product_Information__r.Product_Audience__c )&amp;&apos;-&apos;&amp; Product_Rate_Plan__r.Name</formula>
        <name>IEC UpdateUniqueRatePlan</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>IECUpdateUniqueZuoraPlan</fullName>
        <actions>
            <name>IEC_UpdateUniqueRatePlan</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product_Rate_Plan_Information__c.Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
