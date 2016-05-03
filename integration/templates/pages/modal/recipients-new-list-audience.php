<section id="js-modal-new-list-audience" class="modal-content wide is-hidden">
    
    <header class="modal-header">
        <h2 class="modal-title">Create a new list</h2>
        <a href="#" class="icon-close js-close-modal js-clear-form"><i class="fa fa-times"></i></a>
    </header>

    <div class="modal-body">

        <?php 
        $step = 1;
        include 'includes/components/process-new-list.php';
        ?>

        <h3 class="step-title">Audience</h3>
        <p>Please select lorem dolor sit amet nulla vel sodales mauris. Maecenas ante magna, henderite at mollis quis.</p>

        <ul class="list list-radio-select js-radio-list js-form-continue-validation" data-target-button="#js-continue-to-geo-selection" id="js-radio-list-audience">
            <?php 
            $index = 1;
            foreach ($audience_list as $item): 
                ?>
            <li>
                <div class="radio-box">
                    <div class="custom-user-input radio">
                        <input class="user-input radio" type="radio" name="new-list" id="new-list-<?= $index ?>" value="audience-option-<?= $item['value'] ?>" data-assign-target="<?= $item['target'] ?>">
                        <label class="custom-radio" for="new-list-<?= $index ?>"><i class="icon"></i></label>
                    </div>
                    <label class="input-label" for="new-list-<?= $index ?>"><?= $item['name'] ?></label>
                </div>
                <?php if ($index == 3) { ?>
                <div class="toggle-container show-hide-toggle">

                    <div class="field-group textarea">
                        <label>
                            <span class="input-label">Paste your list of IATA numeric codes in the box below:</span>
                            <textarea class="user-input textarea" rows="3"></textarea>
                        </label>
                        <p class="input-description">Each IATA code needs to be entered seperated by a semicolon with a max of <strong>5,000 codes</strong>.</p>
                    </div>
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
        <div class="footer-actions text-right process-4-steps">
            <a class="button disabled js-open-modal" data-default-state="disabled" id="js-continue-to-geo-selection" data-target-modal="#js-modal-new-list-geo-selection" href="#">Continue</a>
        </div>
        <div class="footer-actions text-right is-hidden process-2-steps">
            <a class="button js-open-modal" data-target-modal="#js-modal-new-list-confirmation" href="#">Continue</a>
        </div>
    </footer>
</section>