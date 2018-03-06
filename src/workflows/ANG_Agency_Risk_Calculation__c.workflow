<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ANG_Risk_Calculation_UK_Adjustment</fullName>
        <field>ANG_UniqueKey__c</field>
        <formula>RecordType.DeveloperName + &apos;_&apos; + TEXT(ANG_Calculation_Rule__r.ANG_Accreditation_Model__c ) + &apos;_&apos; + TEXT(ANG_Calculation_Rule__r.ANG_Occurrence_Num__c) + &apos;_&apos; + TEXT(ANG_Calculation_Rule__r.ANG_Adjusted__c) + &apos;_&apos; + TEXT(ANG_Parent_Occurences__c) + &apos;_&apos; + TEXT(ANG_Remittance_Frequency__c )</formula>
        <name>ANG Risk Calculation UK Adjustment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ANG_Risk_Calculation_UK_Assessment</fullName>
        <field>ANG_UniqueKey__c</field>
        <formula>RecordType.DeveloperName + &apos;_&apos; + TEXT(ANG_Financial_Review_Result__c) + &apos;_&apos; + TEXT(ANG_Risk_History__c) + &apos;_&apos; + TEXT(ANG_Risk_History_Assessment__c)</formula>
        <name>ANG Risk Calculation UK Assessment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ANG_Risk_Calculation_UK_Rules</fullName>
        <field>ANG_UniqueKey__c</field>
        <formula>RecordType.DeveloperName + &apos;_&apos; + TEXT(ANG_Accreditation_Model__c) + &apos;_&apos; + TEXT(ANG_Occurrence_Num__c)+ &apos;_&apos; +TEXT(ANG_Adjusted__c)</formula>
        <name>ANG Risk Calculation UK Rules</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ANG Risk Calculation UK Adjustment</fullName>
        <actions>
            <name>ANG_Risk_Calculation_UK_Adjustment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ANG_Agency_Risk_Calculation__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Adjustment</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ANG Risk Calculation UK Assessment</fullName>
        <actions>
            <name>ANG_Risk_Calculation_UK_Assessment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ANG_Agency_Risk_Calculation__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Risk Status Assessment</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ANG Risk Calculation UK Rules</fullName>
        <actions>
            <name>ANG_Risk_Calculation_UK_Rules</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ANG_Agency_Risk_Calculation__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Rules</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
