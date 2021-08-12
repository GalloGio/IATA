<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Expire_IRR</fullName>
        <field>Irregularities_Expired__c</field>
        <literalValue>1</literalValue>
        <name>Expire IRR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IRR_Expire</fullName>
        <description>Expire Irregularities 1 year after effective date</description>
        <field>Irregularities_Expired__c</field>
        <literalValue>1</literalValue>
        <name>IRR: Expire</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Expire Irregularity</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Agency_Applied_Change_code__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Irregularities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Agency_Applied_Change_code__c.Irregularities_Expired__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Agency_Applied_Change_code__c.IRR_Expiration_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Expires the irregularity 1 year (using date-time) After it was issued (field: effective_date__c)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Expire_IRR</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Agency_Applied_Change_code__c.IRR_Expiration_Date__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
