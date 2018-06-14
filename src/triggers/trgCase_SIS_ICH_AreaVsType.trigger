trigger trgCase_SIS_ICH_AreaVsType on Case(before insert, before update) {

    for (
    case newCase:
            Trigger.new) {

            if (newCase.Type != null && newCase.CaseArea__c != null) {
                if (newCase.CaseArea__c == 'ICH' && (newCase.Type == 'SIS Feature Request' || newCase.Type == 'SIS Technical Problem' || newCase.Type == 'SIS Internal Case'
                                                     || newCase.Type == 'SIS Question/Problem' || newCase.Type == 'SIS Member Profile Update' || newCase.Type == 'SIS Membership'
                                                     || newCase.Type == 'Feature Request' || newCase.Type == 'General Question' || newCase.Type == 'Problem / Issue')) {

                    //system.debug('\n case area:' + newCase.CaseArea__c + ' type: ' + newCase.Type );
                    system.debug('\n Assert error2 caught .......');
                    newCase.addError(Label.HelpDesk_SIS_ICH_Type_Area_Mismatch);
                }

                if (newCase.CaseArea__c == 'SIS' && (newCase.Type != 'SIS Feature Request' && newCase.Type != 'SIS Technical Problem' && newCase.Type != 'SIS Internal Case'
                                                     && newCase.Type != 'SIS Question/Problem' && newCase.Type != 'SIS Member Profile Update' && newCase.Type != 'SIS Membership'
                                                     && newCase.Type != 'Feature Request' && newCase.Type != 'General Question' && newCase.Type != 'Problem / Issue')) {

                    //system.debug('\n case area:' + newCase.CaseArea__c + ' type: ' + newCase.Type);
                    system.debug('\n Assert error1 caught .......');
                    newCase.addError(Label.HelpDesk_SIS_ICH_Type_Area_Mismatch);
                }
            }


            if (Trigger.isUpdate) {
                if (newCase.priority != null && newCase.Type != null && newCase.CaseArea__c != null && newCase.CaseArea__c == 'ICH' && newCase.Assigned_To__c == 'ICH Application Support' && newCase.Status == 'Escalated' && newCase.L2_Support_Priority__c == null && newCase.Priority != 'Priority 1 (Showstopper)') {
                    system.debug('\n Assert error3 caught .......');
                    newCase.addError(Label.L2_Support_Priority_escalation_check);
                }

                String oldStatus = trigger.oldMap.get(newCase.id).status;
                String oldPriority = trigger.oldMap.get(newCase.id).priority;
                String oldTeam = trigger.oldMap.get(newCase.id).assigned_to__c;
                if (newCase.priority != null && newCase.Type != null && newCase.CaseArea__c != null && newCase.CaseArea__c == 'ICH' && (((newCase.status != oldStatus || newCase.assigned_to__c != oldTeam) && newCase.status == 'Escalated' && oldPriority != 'Priority 1 (Showstopper)' && newCase.assigned_to__c == 'ICH Application Support') || (oldPriority != newCase.priority && newCase.priority == 'Priority 1 (Showstopper)' && !(oldStatus == 'Escalated' && newCase.assigned_to__c == 'ICH Application Support')))) {

                    if (newCase.L2_Support_Priority__c == null) newCase.L2_Support_Priority__c = '1 - High';
                    if (newCase.Kale_Status__c == null) newCase.Kale_Status__c = 'New';
                }
            }
        }
}