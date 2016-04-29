<?php 
    switch($main_step) {

    case 1:
        $step1_class = ' active';
        $step2_class = ' disabled';
        $step3_class = ' disabled';
        $step4_class = ' disabled';
        $step5_class = ' disabled';
        $step6_class = ' disabled';
        $step1_url = '#';
        $step2_url = 'javascript:void(0);';
        $step3_url = 'javascript:void(0);';
        $step4_url = 'javascript:void(0);';
        $step5_url = 'javascript:void(0);';
        $step6_url = 'javascript:void(0);';
        break;

    case 2:
        $step1_class = '';
        $step2_class = ' active';
        $step3_class = ' disabled';
        $step4_class = ' disabled';
        $step5_class = ' disabled';
        $step6_class = ' disabled';
        $step1_url = $pages['setup']['url'];
        $step2_url = '#';
        $step3_url = 'javascript:void(0);';
        $step4_url = 'javascript:void(0);';
        $step5_url = 'javascript:void(0);';
        $step6_url = 'javascript:void(0);';
        break;

    case 3:
        $step1_class = '';
        $step2_class = '';
        $step3_class = ' active';
        $step4_class = ' disabled';
        $step5_class = ' disabled';
        $step6_class = ' disabled';
        $step1_url = $pages['setup']['url'];
        $step2_url = $pages['recipients']['url'];
        $step3_url = '#';
        $step4_url = 'javascript:void(0);';
        $step5_url = 'javascript:void(0);';
        $step6_url = 'javascript:void(0);';
        break;

    case 4:
        $step1_class = '';
        $step2_class = '';
        $step3_class = '';
        $step4_class = ' active';
        $step5_class = ' disabled';
        $step6_class = ' disabled';
        $step1_url = $pages['setup']['url'];
        $step2_url = $pages['recipients']['url'];
        $step3_url = $pages['template']['url'];
        $step4_url = '#';
        $step5_url = 'javascript:void(0);';
        $step6_url = 'javascript:void(0);';
        break;

    case 5:
        $step1_class = '';
        $step2_class = '';
        $step3_class = '';
        $step4_class = '';
        $step5_class = ' active';
        $step6_class = ' disabled';
        $step1_url = $pages['setup']['url'];
        $step2_url = $pages['recipients']['url'];
        $step3_url = $pages['template']['url'];
        $step4_url = $pages['design']['url'];
        $step5_url = '#';
        $step6_url = 'javascript:void(0);';
        break;

    case 6:
        $step1_class = '';
        $step2_class = '';
        $step3_class = '';
        $step4_class = '';
        $step5_class = '';
        $step6_class = ' active';
        $step1_url = $pages['setup']['url'];
        $step2_url = $pages['recipients']['url'];
        $step3_url = $pages['template']['url'];
        $step4_url = $pages['design']['url'];
        $step5_url = $pages['schedule']['url'];
        $step6_url = '#';
        break;
}

?>
<div class="process process-6-steps">
    <ol class="list steps">
        <li class="step step-1<?= $step1_class ?>">
            <a href="<?= $step1_url ?>">Setup</a>
        </li>
        <li class="step step-2<?= $step2_class ?>">
            <a href="<?= $step2_url ?>">Recipients</a>
        </li>
        <li class="step step-3<?= $step3_class ?>">
            <a href="<?= $step3_url ?>">Template</a>
        </li>
        <li class="step step-4<?= $step4_class ?>">
            <a href="<?= $step4_url ?>">Design</a>
        </li>
        <li class="step step-5<?= $step5_class ?>">
            <a href="<?= $step5_url ?>">Summary &amp; schedule</a>
        </li>
        <li class="step step-6<?= $step6_class ?>">
            <a href="<?= $step6_url ?>">Payment</a>
        </li>
    </ol>
</div>