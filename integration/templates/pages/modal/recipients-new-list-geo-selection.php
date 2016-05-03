<section id="js-modal-new-list-geo-selection" class="modal-content wide is-hidden">

    <header class="modal-header">
        <h2 class="modal-title">Create a new list</h2>
        <a href="#" class="icon-close js-close-modal js-clear-form"><i class="fa fa-times"></i></a>
    </header>

    <div class="modal-body">

        <?php 
        $step = 2;
        include 'includes/components/process-new-list.php';
        ?>

        <h3 class="step-title">Geo-Selection</h3>
        <p>For your convenience, we have ready-made Geo-Selections. Select one of the following or create your own Geo-Selection.</p>
        <ul class="list list-radio-select js-radio-list js-form-continue-validation" id="js-radio-list-geo-selection" data-target-button="#js-continue-to-refinement">
            <?php 
            $index = 1;
            foreach ($geo_selection_list as $item): 
                ?>
            <li>
                <div class="radio-box">
                    <div class="custom-user-input radio">
                        <input class="user-input radio" type="radio" name="audience-list" id="audience-list-<?= $index ?>">
                        <label class="custom-radio" for="audience-list-<?= $index ?>"><i class="icon"></i></label>
                    </div>
                    <label class="input-label" for="audience-list-<?= $index ?>">
                        <?= $item['name'] ?>
                        <?php if ($index != 5) { ?>
                        <span class="number-of-recipients">(<?= number_format($item['number_of_recipients']) ?> recipients)</span>
                        <?php } ?>
                    </label>
                </div>
                <?php if ($index == 5) { ?>
                <div class="toggle-container show-hide-toggle">
                    <?php include 'includes/components/group-geo-selection.php'; ?>
                </div>
                <?php } ?>
            </li>
            <?php 
            $index++;
            endforeach 
            ?>
        </ul>
    </div>

    <footer class="modal-footer">
        <div class="footer-actions text-right">
            <a class="button disabled js-open-modal" data-default-state="disabled" id="js-continue-to-refinement" data-target-modal="#js-modal-new-list-refinement" href="#">Continue</a>
        </div>
    </footer>

</section>