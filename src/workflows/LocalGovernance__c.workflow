<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Add_INACTIVE_to_name</fullName>
        <field>Name</field>
        <formula>Name&amp; &quot;- INACTIVE&quot;</formula>
        <name>Add INACTIVE to name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_recordtype</fullName>
        <description>Change the recordtype from draft to permanent to hide the Approval History on the assigned page layout</description>
        <field>RecordTypeId</field>
        <lookupValue>Reg_Div_Groups</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change recordtype</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reg_Dig_Group_to_Draft</fullName>
        <description>Change the record type back to Draft Reg/Div Group</description>
        <field>RecordTypeId</field>
        <lookupValue>Draft_Reg_Div_Group</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Reg/Dig Group to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_INACTIVE_from_name</fullName>
        <description>remove &quot;- INACTIVE&quot; from the name</description>
        <field>Name</field>
        <formula>SUBSTITUTE(Name, &quot;- INACTIVE&quot;, &quot;&quot;)</formula>
        <name>Remove INACTIVE from name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Industry_Group_Unique_Name</fullName>
        <description>To be used for Reg / Div Groups. Copies the Name field into the Unique Name field.</description>
        <field>Unique_Name__c</field>
        <formula>SUBSTITUTE(Name, &quot;- INACTIVE&quot;, &quot;&quot;)</formula>
        <name>Set Industry Group Unique Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Local_Governance_Name</fullName>
        <field>Name</field>
        <formula>IF( ISBLANK(Country__c), Cluster__r.Name, Country__r.Name) +
&quot; - &quot;+
TEXT(Local_Governance_type__c)+
IF(Active__c, &quot;&quot;, &quot; - INACTIVE&quot;)</formula>
        <name>Set Local Governance Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Local_Governance_Unique_Name</fullName>
        <field>Unique_Name__c</field>
        <formula>IF(Active__c, (

RecordType.Name + &quot; - &quot; + IF( ISBLANK(Country__c), Cluster__r.Name, Country__r.Name) +&quot; - &quot;+ TEXT(Local_Governance_type__c)

), 
&quot;&quot;)</formula>
        <name>Set Local Governance Unique Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_as_Approved</fullName>
        <field>Approved__c</field>
        <literalValue>1</literalValue>
        <name>Set as Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_as_Not_Approved</fullName>
        <field>Approved__c</field>
        <literalValue>0</literalValue>
        <name>Set as Not Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Local Governance Auto Name</fullName>
        <actions>
            <name>Set_Local_Governance_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Local_Governance_Unique_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Local Groups</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reg %2F Div Group Auto Unique Name</fullName>
        <actions>
            <name>Set_Industry_Group_Unique_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Reg/Div Groups,Draft Reg/Div Group</value>
        </criteriaItems>
        <description>Fill the Unique Name field for industry groups with the (Draft) Reg / Div Group record types. Note that &quot;- INACTIVE&quot; is ignored from the name so inactive groups are also considered unique.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reg%2FDig Group auto-rename</fullName>
        <actions>
            <name>Add_INACTIVE_to_name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance__c.Active__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Draft Reg/Div Group,Reg/Div Groups</value>
        </criteriaItems>
        <description>Add &quot;- INACTIVE&quot; to the name of and inactivated reg/div group or draft</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reg%2FDig Group auto-rename back</fullName>
        <actions>
            <name>Remove_INACTIVE_from_name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance__c.Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Draft Reg/Div Group,Reg/Div Groups</value>
        </criteriaItems>
        <description>Remove &quot;- INACTIVE&quot; from the name of an activated reg/div group or draft</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reg%2FDiv group reporting to changed</fullName>
        <actions>
            <name>Reg_Dig_Group_to_Draft</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the reporting to of an approved group is changed, send it back for re-approval</description>
        <formula>AND( RecordType.DeveloperName = &apos;Reg_Div_Groups&apos;, ISCHANGED( Reporting_to__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
