<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Case_Owner_Changes_after_Due_Date</fullName>
        <description>Notify Case Owner Changes after Due Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Repayment_Instalment/Repayment_Instalment_Updated_After_Due_Date</template>
    </alerts>
    <alerts>
        <fullName>Notify_Case_Owner_Payment_Status_Changed</fullName>
        <description>Notify Case Owner Payment Status Changed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Repayment_Instalment/Repayment_Instalment_Status_Changed</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Payment_Status_Not_received_by_date</fullName>
        <field>Payment_Status__c</field>
        <literalValue>Not received by due date</literalValue>
        <name>Set Payment Status Not received by date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Payment_Status_Pending</fullName>
        <field>Payment_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Set Payment Status Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Payment_Status_Received</fullName>
        <field>Payment_Status__c</field>
        <literalValue>Received</literalValue>
        <name>Set Payment Status Received</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Payment_Status_Received_after_Ter</fullName>
        <field>Payment_Status__c</field>
        <literalValue>Amount Received After Termination</literalValue>
        <name>Set Payment Status Received after Ter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_To_be_confirmed</fullName>
        <field>Payment_Status__c</field>
        <literalValue>To be confirmed</literalValue>
        <name>Set Status To be confirmed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_R_S_feedback_pending</fullName>
        <description>Update the &quot;R&amp;S pending feedback&quot; field on the aprent case to &quot;Check repayment&quot;</description>
        <field>R_S_feedback_pending__c</field>
        <literalValue>Check repayment</literalValue>
        <name>Update R&amp;S feedback pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Case__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Case Detail - Repayment Instalment Amount received after TER</fullName>
        <actions>
            <name>Notify_Case_Owner_Payment_Status_Changed</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Set_Payment_Status_Received_after_Ter</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the status of the repayment instalment record when the payment is received after the account is terminated.</description>
        <formula>AND(    RecordType.DeveloperName = &quot;Repayment_Instalment&quot;,    NOT(ISNULL(Case__r.Update_AIMS_TER__c )),    DATEVALUE(Case__r.Update_AIMS_TER__c) &lt; Date_received__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Detail - Repayment Instalment Changed After Due Date</fullName>
        <actions>
            <name>Notify_Case_Owner_Changes_after_Due_Date</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify the case owner when the admount received or the reception date have been changed after the due date.</description>
        <formula>AND (   RecordType.DeveloperName = &quot;Repayment_Instalment&quot;,   Due_date__c &lt; Date_received__c,   OR (     ISCHANGED( Amount_Received__c ),     ISCHANGED( Date_received__c )   ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Detail - Repayment Instalment Due Date Changed</fullName>
        <actions>
            <name>Set_Payment_Status_Pending</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear the receved amount and received date when the due date is changed.</description>
        <formula>AND(   RecordType.DeveloperName = &quot;Repayment_Instalment&quot;,   ISCHANGED( Due_date__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Detail - Repayment Instalment Full Amount Received</fullName>
        <actions>
            <name>Notify_Case_Owner_Payment_Status_Changed</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Set_Payment_Status_Received</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the Amount received equals the instalment amount, update the status to &quot;Received&quot;.</description>
        <formula>AND (   RecordType.DeveloperName = &quot;Repayment_Instalment&quot;,   Amount_Expected__c &gt;0,   Amount_Received__c &gt;= Amount_Expected__c ,   Due_date__c &gt;= Date_received__c,   OR(     ISNULL(Case__r.Update_AIMS_TER__c ),     DATEVALUE(Case__r.Update_AIMS_TER__c) &gt; Date_received__c   ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Detail - Repayment Instalment Partial Amount Received</fullName>
        <actions>
            <name>Notify_Case_Owner_Payment_Status_Changed</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Set_Payment_Status_Not_received_by_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the Amount received is less than the instalment amount, update the status to &quot;Not received by due date&quot;.</description>
        <formula>AND(   RecordType.DeveloperName = &quot;Repayment_Instalment&quot;,   OR(     ISNULL(Case__r.Update_AIMS_TER__c ),     DATEVALUE(Case__r.Update_AIMS_TER__c) &gt; Date_received__c   ),   OR(     AND (       Amount_Received__c  &lt;  Amount_Expected__c,       Due_date__c &gt;= Date_received__c      ),   AND (     NOT(ISBLANK(Date_received__c)),     Due_date__c &lt; Date_received__c)   ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Detail - Repayment Instalment Payment to be confirmed</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case_Detail__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Repayment Instalment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case_Detail__c.Payment_Status__c</field>
            <operation>equals</operation>
            <value>Pending,Not received by due date</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Update_AIMS_TER__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Change the Status to &quot;To be confirmed&quot; when the due date is reached, if the payment has not been confirmed already.
Only for RT Repayment Instalment</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Case_Owner_Payment_Status_Changed</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Set_Status_To_be_confirmed</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_R_S_feedback_pending</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case_Detail__c.Due_date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
