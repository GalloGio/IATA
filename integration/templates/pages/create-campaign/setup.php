<main class="main-content">
    <div class="inner-wrapper">
        <?php 
        $main_step = 1;
        include 'includes/components/process.php';
        ?>

        <h1 class="page-title">Campaign Info</h1>

        <div class="alert">
            <h2 class="alert-title">Account balance</h2>
            <div class="alert-message icon check-circle">
                <p>Your current account balance is <strong>50,000 emails</strong></p>
            </div>
        </div>
        <div class="row">
            <div class="columns medium-6">
                <div class="field-group text">
                    <label>
                        <span class="input-label">Name your campaign</span>
                        <input class="user-input text" type="text">
                    </label>
                    <p class="input-description">Internal use only. Ex: "Newsletter Test#4"</p>
                </div>

                <div class="field-group text">
                    <label>
                        <span class="input-label">Email subject</span>
                        <input class="user-input text js-remaining-characters" type="text" data-target-element=".js-remaining-count" data-target-id="email-subject" data-max-length="10">
                    </label>
                    <div class="input-remaining">
                        <span class="js-remaining-count" data-id="email-subject">10</span>
                    </div>
                    <p class="input-description">This is the email subject that your recipients will see</p>
                </div>

                <div class="field-group text">
                    <label>
                        <span class="input-label">From name</span>
                        <input class="user-input text js-remaining-characters" type="text" data-target-element=".js-remaining-count" data-target-id="from-name" data-max-length="96">
                    </label>
                    <div class="input-remaining">
                        <span class="js-remaining-count" data-id="from-name">96</span>
                    </div>
                    <p class="input-description">Use something recipients will instantly recognize, like your company name</p>
                </div>
            </div>
            <div class="columns medium-6">

                <div class="field-group checkbox google-analytics">
                    <div class="checkbox-box">
                        <div class="custom-user-input checkbox">
                            <input class="user-input checkbox" type="checkbox" id="google-analytics">
                            <label class="custom-checkbox" for="google-analytics"><i class="icon"></i></label>
                        </div>
                        <label class="input-label" for="google-analytics">Google Analytics <sup>TM</sup> tracker</label>
                        <input class="user-input text" type="text">
                        <p class="input-description">Track clicks from your campaigns all the way to your website.</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="footer-actions text-right">
            <a class="button" href="<?= $pages['recipients']['url'] ?>">Continue</a>
        </div>

    </div>
</main>