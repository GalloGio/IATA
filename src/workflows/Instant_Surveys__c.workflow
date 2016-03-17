<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>test workflow</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Instant_Surveys__c.Overall_satisfaction__c</field>
            <operation>equals</operation>
            <value>Somewhat dissatisfied,Very dissatisfied</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
