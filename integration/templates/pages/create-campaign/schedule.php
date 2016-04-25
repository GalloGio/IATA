<main class="main-content">
    <div class="inner-wrapper">
        <?php 
        $main_step = 5;
        include 'includes/components/process.php';
        ?>

        <h1 class="page-title">Summary &amp; Schedule</h1>

        <p class="lead">Review these important campaign details before scheduling you campaign.</p>

        <div class="alert subject-line">
            <div class="alert-message icon check-circle">
                <h2 class="title">Subject Line <a class="text-link" href="#">(edit)</a></h2>
                <p>The Email Subject currently setup is “<strong>Campaign 1</strong>”. Please make sure this is accurate.</p>
            </div>
        </div>

        <div class="alert">
            <div class="alert-message icon check-circle">
                <h2 class="title">Recipients</h2>
                <p>
                Your message will be delivered using the <strong>US Agencies</strong> list additionally filtered using the <strong>IP segment</strong>.<br>
                    Total of <strong>20,000 recipients</strong>
                </p>
            </div>
        </div>
        
        <section class="group-container schedule">
            <h2 class="icon schedule group-title">Schedule</h2>
            <div class="group-content">
                <p class="lead"><strong>Please confirm the date you want your campaign to be sent.</strong></p>
                <p class="note"><strong>NOTE:</strong> 48 business hours are necessary for IATA to perform the campaign review process.</p>
                <p class="label"><strong>The below date is the earliest your campaign can be sent:</strong></p>
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
                            <?php for ($i=0; $i < 60; $i = $i+5) { ?>
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
                    <strong>UTC−05:00</strong>
                </div>
            </div>
        </section>
        <div class="footer-actions text-right">
            <a class="button" href="<?= $page_url['confirm'] ?>">Continue</a>
        </div>
    </div>
</main>