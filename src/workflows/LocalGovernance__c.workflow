<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_for_Local_Groups</fullName>
        <description>Alert for Local Groups</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account_management_team</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Local_Governance/Alert_for_Local_Groups</template>
    </alerts>
    <fieldUpdates>
        <fullName>Add_INACTIVE_to_name</fullName>
        <description>Add &quot; - INACTIVE&quot; to the name when inactivated</description>
        <field>Name</field>
        <formula>Name&amp; &quot; - INACTIVE&quot;</formula>
        <name>Add INACTIVE to name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_INACTIVE_from_name</fullName>
        <description>remove &quot; - INACTIVE&quot; from the name</description>
        <field>Name</field>
        <formula>SUBSTITUTE(Name, &quot; - INACTIVE&quot;, &quot;&quot;)</formula>
        <name>Remove INACTIVE from name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Industry_Group_Unique_Name</fullName>
        <description>To be used for Reg / Div Groups. Copies the Name field into the Unique Name field.</description>
        <field>Unique_Name__c</field>
        <formula>SUBSTITUTE(Name, &quot; - INACTIVE&quot;, &quot;&quot;)</formula>
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
    <rules>
        <fullName>Alert for Local Groups</fullName>
        <actions>
            <name>Alert_for_Local_Groups</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Local Groups</value>
        </criteriaItems>
        <description>Notification sent to AMP team when local group is created.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
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
            <value>Reg/Div Groups</value>
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
            <value>Reg/Div Groups</value>
        </criteriaItems>
        <description>Remove &quot;- INACTIVE&quot; from the name of an activated reg/div group or draft</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
