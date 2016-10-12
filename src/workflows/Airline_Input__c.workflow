<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>sMAP_Inform_to_CM</fullName>
        <description>sMAP - Input entered by other - inform CM</description>
        <protected>false</protected>
        <recipients>
            <field>Country_Manager_del__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/sMAP_Inform_to_CM</template>
    </alerts>
    <alerts>
        <fullName>sMAP_Inform_to_CM_Backup_Contact</fullName>
        <description>sMAP - new case created inform CM and Backup</description>
        <protected>false</protected>
        <recipients>
            <field>Country_Manager_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Country_Manager_del__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/sMAP_Inform_to_CM_Backup_Contact</template>
    </alerts>
    <fieldUpdates>
        <fullName>sMAP_Update_Airline_Input_By</fullName>
        <field>Airline_Input_by__c</field>
        <formula>$User.FirstName &amp; &quot; &quot;&amp; $User.LastName</formula>
        <name>sMAP_Update_Airline Input By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>sMAP_Update_Airline_Input_Date</fullName>
        <field>Airline_Input_Date__c</field>
        <formula>NOW()</formula>
        <name>sMAP_Update_Airline Input Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>sMAP - Input entered by other - inform CM</fullName>
        <actions>
            <name>sMAP_Inform_to_CM</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>If someone update &quot;Airline Input&quot;, this notification goes to CM</description>
        <formula>AND(ISBLANK(Airline_Input__c)=false,  Airline_Input_by__c &lt;&gt; Country_Manager_del__r.FirstName&amp;&quot; &quot;&amp;Country_Manager_del__r.LastName)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>sMAP_Update_Airline Input by %26 date</fullName>
        <actions>
            <name>sMAP_Update_Airline_Input_By</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>sMAP_Update_Airline_Input_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Airline_Input__c.Airline_Input_by__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Airline_Input__c.Airline_Input__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
