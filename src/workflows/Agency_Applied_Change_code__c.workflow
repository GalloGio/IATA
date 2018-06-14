<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Change_Code_Change_Recordtype_Irregula</fullName>
        <description>Assign Recordtype &quot;Irregularities&quot; for Change Code with Type &quot;IRR&quot;</description>
        <field>RecordTypeId</field>
        <lookupValue>Irregularities</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change Code - Change Recordtype Irregula</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Code_Change_Recordtype_NO_Irreg</fullName>
        <description>Assign Recordtype &quot;Sandard&quot; for Change Code with Type not equal to &quot;IRR&quot;</description>
        <field>RecordTypeId</field>
        <lookupValue>Standard</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change Code - Change Recordtype NO Irreg</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Code_Unpublish</fullName>
        <field>To_Publish_in_e_Bulletin__c</field>
        <literalValue>0</literalValue>
        <name>Change Code: Unpublish</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
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
    <fieldUpdates>
        <fullName>Update_IRR_Unique_Id</fullName>
        <description>Update unique Id</description>
        <field>AIMS_ID__c</field>
        <formula>AIMS_ID__c + &apos;_A&apos;</formula>
        <name>Update IRR Unique Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Change Code - Change Recordtype Irregularities</fullName>
        <actions>
            <name>Change_Code_Change_Recordtype_Irregula</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Agency_Applied_Change_code__c.Change_Code__c</field>
            <operation>equals</operation>
            <value>IRR,IRS,IRW</value>
        </criteriaItems>
        <description>Assign Recordtype &quot;Irregularities&quot; for Change Code with Type &quot;IRR&quot;</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Change Code - Change Recordtype NO Irregularities</fullName>
        <actions>
            <name>Change_Code_Change_Recordtype_NO_Irreg</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Agency_Applied_Change_code__c.Change_Code__c</field>
            <operation>notEqual</operation>
            <value>IRR,IRS,IRW</value>
        </criteriaItems>
        <description>Assign Recordtype &quot;Standard&quot; for Change Code with Type not equal to &quot;IRR&quot;</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
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
    <rules>
        <fullName>IRR%3A Expire</fullName>
        <active>false</active>
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
        <description>Expire irregularities when it reached the effective date + 12 months</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Agency_Applied_Change_code__c.Effective_Date__c</offsetFromField>
            <timeLength>365</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Rename UniqueID With A</fullName>
        <actions>
            <name>Update_IRR_Unique_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>For IRRegularities with an A operation, rename them</description>
        <formula>AND(NOT(RIGHT(AIMS_ID__c,1)=&apos;A&apos;), Operation__c = &apos;A&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Unpublish MSO</fullName>
        <actions>
            <name>Change_Code_Unpublish</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the published in bulletin flag to false if process is MSO</description>
        <formula>IF( OR( ISPICKVAL( Account__r.Location_Class__c , &apos;M&apos;), ISPICKVAL( Account__r.Location_Class__c , &apos;T&apos;), ISPICKVAL( Account__r.Location_Class__c , &apos;G&apos;), ISPICKVAL( Account__r.Location_Class__c , &apos;X&apos;), CONTAINS( TEXT( OSCAR__r.Process__c ) , &apos;CER.1.0&apos;)), true, false)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
