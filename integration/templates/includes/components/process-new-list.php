<?php 
    switch($step) {

    case 1:
        $step1_class = ' active';
        $step2_class = ' disabled';
        $step3_class = ' disabled';
        $step4_class = ' disabled';
        $step1_url = '#';
        $step2_url = 'javascript:void(0);';
        $step3_url = 'javascript:void(0);';
        $step4_url = 'javascript:void(0);';
        $step1_modal_class = '';
        $step2_modal_class = '';
        $step3_modal_class = '';
        $step4_modal_class = '';
        break;

    case 2:
        $step1_class = '';
        $step2_class = ' active';
        $step3_class = ' disabled';
        $step4_class = ' disabled';
        $step1_url = '#';
        $step2_url = '#';
        $step3_url = 'javascript:void(0);';
        $step4_url = 'javascript:void(0);';
        $step1_modal_class = 'js-open-modal';
        $step2_modal_class = '';
        $step3_modal_class = '';
        $step4_modal_class = '';
        break;

    case 3:
        $step1_class = '';
        $step2_class = '';
        $step3_class = ' active';
        $step4_class = ' disabled';
        $step1_url = '#';
        $step2_url = '#';
        $step3_url = '#';
        $step4_url = 'javascript:void(0);';
        $step1_modal_class = 'js-open-modal';
        $step2_modal_class = 'js-open-modal';
        $step3_modal_class = '';
        $step4_modal_class = '';
        break;

    case 4:
        $step1_class = '';
        $step2_class = '';
        $step3_class = '';
        $step4_class = ' active';
        $step1_url = '#';
        $step2_url = '#';
        $step3_url = '#';
        $step4_url = '#';
        $step1_modal_class = 'js-open-modal';
        $step2_modal_class = 'js-open-modal';
        $step3_modal_class = 'js-open-modal';
        $step4_modal_class = '';
        break;
}

?>

<div class="process process-2-steps is-hidden">
    <ol class="list steps">
        <li class="step step-1<?= $step1_class ?>">
            <a class="<?= $step1_modal_class ?>" data-target-modal="#js-modal-new-list-audience" href="<?= $step1_url ?>">Audience</a>
        </li>
        <li class="step step-2<?= $step4_class ?>">
            <a class="<?= $step4_modal_class ?>" data-target-modal="" href="<?= $step2_url ?>">Confirmation</a>
        </li>
    </ol>
</div>

<div class="process process-4-steps">
    <ol class="list steps">
        <li class="step step-1<?= $step1_class ?>">
            <a class="<?= $step1_modal_class ?>" data-target-modal="#js-modal-new-list-audience" href="<?= $step1_url ?>">Audience</a>
        </li>
        <li class="step step-2<?= $step2_class ?>">
            <a class="<?= $step2_modal_class ?>" data-target-modal="#js-modal-new-list-geo-selection" href="<?= $step2_url ?>">Geo Selection</a>
        </li>
        <li class="step step-3<?= $step3_class ?>">
            <a class="<?= $step3_modal_class ?>" data-target-modal="#js-modal-new-list-refinement" href="<?= $step3_url ?>">Refinement</a>
        </li>
        <li class="step step-4<?= $step4_class ?>">
            <a class="<?= $step4_modal_class ?>" data-target-modal="" href="<?= $step4_url ?>">Confirmation</a>
        </li>
    </ol>
</div>