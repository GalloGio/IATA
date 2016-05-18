<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>TnC_update_unique_Product_Version</fullName>
        <description>Update the text field Product Version from the formulat field</description>
        <field>Unique_Product_Version__c</field>
        <formula>Product_Version_Formula__c</formula>
        <name>TnC update unique Product Version</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>IECUniqueTnCProductVersion</fullName>
        <actions>
            <name>TnC_update_unique_Product_Version</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Terms_and_Conditions__c.Version__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Rule that checks the unicity of a T&amp;C version for the same product</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
