<section id="js-modal-change-schedule" class="modal-content is-hidden">
    <header class="modal-header">
        <h2 class="modal-title">Change Schedule</h2>
        <a href="#" class="icon-close js-close-modal"><i class="fa fa-times"></i></a>
    </header>
    <div class="modal-body">
        <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit.</p>
        <div class="field-group default field-datepicker">
            <div class="datepicker">
                <input class="user-input text js-datepicker" type="text">
            </div>

            <div class="custom-user-input select">
                <i class="icon angle-down"></i>
                <select class="user-input select">
                    <?php for ($i=1; $i < 13; $i++) { ?>
                    <option value="<?= $i ?>"><?= $i ?></option>
                    <?php } ?>
                </select>
            </div>
            :
            <div class="custom-user-input select">
                <i class="icon angle-down"></i>
                <select class="user-input select">
                    <?php for ($i=0; $i < 61; $i++) { ?>
                    <?php if ($i < 10) { ?>
                    <option value="0<?= $i ?>">0<?= $i ?></option>
                    <?php } else { ?>
                    <option value="<?= $i ?>"><?= $i ?></option>
                    <?php } ?>
                    <?php } ?>
                </select>
            </div>
            <div class="custom-user-input select">
                <i class="icon angle-down"></i>
                <select class="user-input select">
                    <option value="am">AM</option>
                    <option value="pm">PM</option>
                </select>
            </div>
        </div>
    </div>
    <footer class="modal-footer">
        <ul class="list actions">
            <li>
                <button class="text-link js-close-modal">Cancel</button>
            </li>
            <li>
                <button class="button">Change</button>
            </li>
        </ul>
    </footer>
</section>