<!-- <ul class="list list-radio-select js-radio-list">
    <?php 
    $index = 1;
    foreach ($audience_list as $item): 
        ?>
    <li>
        <div class="radio-box">
            <div class="custom-user-input radio">
                <input class="user-input radio" type="radio" name="audience-list" id="audience-list-<?= $index ?>">
                <label class="custom-radio" for="audience-list-<?= $index ?>"><i class="icon"></i></label>
            </div>
            <label class="input-label" for="audience-list-<?= $index ?>"><?= $item['name'] ?></label>
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
</ul> -->