<main class="main-content">
    <div class="inner-wrapper">
        <h1 class="page-title">Campaign details - Confirmation</h1>
        <p>Review these important campaign details before sending.</p>
        
        <div class="row">
            <div class="columns medium-10">
                <ul class="list info-box">
                    <li class="info-box icon check-circle">
                        <h2 class="section-title"><i>Recipients</i></h2>
                        <p>Your message will be delivered using the <strong>US Agencies</strong> list additionally filtered using the <strong>IP</strong> segment.</p>
                        <p>=> Total of <span class="accent">20,000 recipients</span></p>
                        <div class="action">
                            <a class="button" href="#">Edit</a>
                        </div>
                    </li>
                    <li class="info-box icon check-circle">
                        <h2 class="section-title"><i>Subject line</i></h2>
                        <p>The email Subject currently setup is <strong>"Campaign 1"</strong>. Please make sure this is accurate...</p>
                        <div class="action">
                            <a class="button" href="#">Edit</a>
                        </div>
                    </li>
                    <li class="info-box icon check-circle">
                        <h2 class="section-title"><i>Suchedule delivery</i></h2>
                        <p>Please confirm the date you want your campaign to be sent</p>
                        <p><strong>Important</strong>: <abbr title="International Air Transport Association">IATA</abbr> needs to review all campaign content and requires 48 business hours to do so.</p>
                        <div class="action">
                            <a class="button" href="#">Suchedule</a>
                        </div>
                    </li>
                    <li class="info-box icon clock">
                        <h2 class="section-title"><i>Set up your schedule</i></h2>
                        <p><strong>48 business hours are necessary for <abbr title="International Air Transport Association">IATA</abbr> to perform the campaign review proess.</strong></p>
                        <p><strong>The below date is the earliest your campaign can be sent.</strong></p>
                        <div class="field-group">
                            <div class="datepicker">
                                <input class="user-input js-datepicker" type="text">
                            </div>

                            <div class="custom-user-input select">
                                <i class="icon caret-down"></i>
                                <select class="user-input select" name="" id="">
                                    <?php for ($i=1; $i < 13; $i++) { ?>
                                        <option value="<?= $i ?>"><?= $i ?></option>
                                    <?php } ?>
                                </select>
                            </div>
                            &nbsp;: &nbsp;
                            <div class="custom-user-input select">
                                <i class="icon caret-down"></i>
                                <select class="user-input select" name="" id="">
                                    <?php 
                                    for ($i=0; $i < 60; $i++) { 
                                        if ($i< 10) {
                                            ?>
                                            <option value="<?= $i ?>">0<?= $i ?></option>
                                            <?php 
                                        } else {
                                            ?>

                                            <option value="<?= $i ?>"><?= $i ?></option>
                                            <?php 
                                        }
                                    } 
                                    ?>
                                </select>
                            </div>

                            <div class="custom-user-input select">
                                <i class="icon caret-down"></i>
                                <select class="user-input select" name="" id="">
                                    <option value="am">AM</option>
                                    <option value="pm">PM</option>
                                </select>
                            </div>
                            <span class="input-label">Eastern Time</span>
                        </div>
                        <div class="actions">
                            <button class="button primary" href="#">Schedule Campaign</button>
                            <button class="button text-link" href="#">Cancel</button>
                        </div>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</main>