<?php $scenario = $_GET['scenario']; ?>
<main class="main-content">
    <div class="inner-wrapper">
        <?php
        $main_step = 6;
        include 'includes/components/process.php';
        ?>

        <h1 class="page-title">Payment</h1>

        <div class="row row-payment">
            <section class="columns main-container campaign-cost">
                <h2 class="section-title">Campaign Cost</h2>
                <div class="table-container">
                    <table class="data-table table-payment table-campaign-cost">
                        <tr class="total-recipients">
                            <th>
                                Total recipients for this campaign
                            </th>
                            <td>
                                <div class="item-value">
                                    <strong>15,000</strong>
                                    <span class="unit"> emails</span>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th>
                                Available balance
                            </th>
                            <td>
                                <div class="item-value text-green">
                                    <strong>10,000</strong>
                                    <span class="unit"> emails</span>
                                </div>
                            </td>
                        </tr>
                        <tr class="new-balance">
                            <th>
                                New balance
                            </th>
                            <td>
                                <div class="item-value">
                                    <strong>0</strong>
                                    <span class="unit"> email</span>
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
                <?php if ($scenario == 2) { ?>
                <?php } else if ($scenario == 3) { ?>
                <?php } else if ($scenario == 4) { ?>
                <?php } ?>

                <?php if ($scenario != 1) { ?>
                <div class="group-container plan">
                    <?php if ($scenario == 4) { ?>
                    <h3 class="group-title">Select a plan</h3>
                    <?php } else { ?>
                    <h3 class="group-title"><span class="light">Current plan:</span> Starter edition</h3>
                    <?php } ?>

                    <ul class="list js-radio-list">
                        <?php if ($scenario == 2 || $scenario == 3) { ?>
                        <li<?= ($scenario == 2)? ' class="is-selected"':'' ?>>
                            <div class="field-group radio">
                                <div class="radio-box">
                                    <div class="custom-user-input radio">
                                        <input class="user-input radio" type="radio" name="radio1" id="radio1-option1"<?= ($scenario == 2)? ' checked':'' ?>>
                                        <label class="custom-radio" for="radio1-option1"><i class="icon"></i></label>
                                    </div>
                                    <label class="input-label" for="radio1-option1">Get an email package</label>
                                    <p class="input-description">Nulla vitae elit libero, a pharetra augue. Nullam quis risus eget urna mollis ornare vel eu leo.</p>
                                </div>
                            </div>
                            <?php 
                                $packages = array(
                                    array(
                                        'credits' => '300',
                                        'price' => '9.00'
                                        ),
                                    array(
                                        'credits' => '1,000',
                                        'price' => '30.00'
                                        ),
                                    array(
                                        'credits' => '2,000',
                                        'price' => '60.00'
                                        ),
                                    array(
                                        'credits' => '7,500',
                                        'price' => '150.00'
                                        ),
                                    array(
                                        'credits' => '10,000',
                                        'price' => '200.00'
                                        ),
                                    array(
                                        'credits' => '25,000',
                                        'price' => '250.00'
                                        ),
                                    array(
                                        'credits' => '75,000',
                                        'price' => '750.00'
                                        ),
                                    array(
                                        'credits' => '200,000',
                                        'price' => '1,000.00'
                                        ),
                                    array(
                                        'credits' => '375,000',
                                        'price' => '1,875.00'
                                        ),
                                    );
                            ?>
                            <div class="toggle-container show-hide-toggle">
                                <ul class="list package-list js-checkbox-list">
                                    <?php 
                                    $index = 1;
                                    foreach ($packages as $package): 
                                        ?>
                                    <li class="list-item<?= ($index < 4)? ' disabled':'' ?><?= ($index == 8)? ' has-promotion':'' ?>">
                                        <?php if ($index == 8) { ?>
                                        <div class="promotion-label">
                                            get 10% <br>more
                                        </div>
                                        <?php } ?>
                                        <div class="checkbox-box">
                                            <div class="custom-user-input checkbox">
                                                <input class="user-input checkbox" type="checkbox" id="package-<?= $index ?>"<?= ($index < 4)? ' disabled':'' ?>>
                                                <label class="custom-checkbox" for="package-<?= $index ?>"><i class="icon"></i></label>
                                            </div>
                                            <label class="input-label" for="package-<?= $index ?>">
                                                <span class="input-state unselected">Select</span>
                                                <span class="input-state selected">Selected</span>
                                            </label>
                                            <?php if ($index < 4) { ?>
                                                <a href="#" class="tooltip-icon js-tooltip"><i class="fa fa-exclamation-triangle"></i></a>
                                                <div class="tooltip-container">
                                                    <div class="tooltip-description">
                                                        <p>You can only select email packages above the balance owing.</p>
                                                    </div>
                                                </div>
                                            <?php } ?>
                                        </div>
                                        <div class="package-credits">
                                            <?php if ($index == 8) { ?>
                                            <span class="line-stroke"><?= $package['credits'] ?></span>
                                            <span class="text-orange">220,000</span>
                                            <br>
                                            <?php } else { ?>
                                            <?= $package['credits'] ?>
                                            <?php } ?>
                                             credits
                                        </div>
                                        <div class="package-price">$<?= $package['price'] ?></div>
                                    </li>
                                    <?php 
                                    $index++;
                                    endforeach 
                                    ?>
                                </ul>
                            </div>
                        </li>
                        <?php } ?>
                        <?php if ($scenario == 4) { ?>
                        <li class="is-selected">
                            <div class="field-group radio">
                                <div class="radio-box">
                                    <div class="custom-user-input radio">
                                        <input class="user-input radio" type="radio" name="radio1" id="radio1-option1"<?= ($scenario == 4)? ' checked':'' ?>>
                                        <label class="custom-radio" for="radio1-option1"><i class="icon"></i></label>
                                    </div>
                                    <label class="input-label" for="radio1-option1">Prepaid</label>
                                    <p class="input-description">Nulla vitae elit libero, a pharetra augue. Nullam quis risus eget urna mollis ornare vel eu leo.</p>
                                </div>
                            </div>
                            
                            <?php 
                                $plans = array(
                                    array(
                                        'name' => 'Starter edition',
                                        'price' => '1,500.00'
                                        ),
                                    array(
                                        'name' => 'Professional edition',
                                        'price' => '2,500.00'
                                        ),
                                    array(
                                        'name' => 'Enterprise edition',
                                        'price' => '5,000.00'
                                        ),
                                    array(
                                        'name' => 'Premium edition',
                                        'price' => '10,000.00'
                                        ),
                                    );
                            ?>
                            <div class="toggle-container show-hide-toggle">
                                <ul class="list plan-list js-checkbox-list">
                                    <?php 
                                    $index = 1;
                                    foreach ($plans as $plan): 
                                        ?>
                                    <li class="list-item">
                                        <div class="checkbox-box">
                                            <div class="custom-user-input checkbox">
                                                <input class="user-input checkbox" type="checkbox" id="get-this-plan-<?= $index ?>">
                                                <label class="custom-checkbox" for="get-this-plan-<?= $index ?>"><i class="icon"></i></label>
                                            </div>
                                            <label class="input-label" for="get-this-plan-<?= $index ?>">Get this plan</label>
                                        </div>
                                        <div class="plan-box">
                                            <div class="box plan-name">
                                                <?= $plan['name'] ?>
                                            </div>
                                            <div class="box plan-price">
                                                <div class="price">$<?= $plan['price'] ?></div>
                                                <span class="currency-per-year">USD/year</span>
                                                <span class="billed-annually">(billed annually)</span>
                                            </div>
                                            <div class="box plan-description">
                                                <ul class="list check-circle-list">
                                                    <li class="icon check-circle">Nulla vitae elit libero, a pharetra augue.</li>
                                                    <li class="icon check-circle">Curabitur blandit tempus porttitor.</li>
                                                    <li class="icon check-circle">Maecenas sed diam eget risus varius blandit sit amet non magna.</li>
                                                    <li class="icon check-circle">Donec ullamcorper nulla non metus auctor fringilla.</li>
                                                </ul>
                                            </div>
                                        </div>
                                    </li>
                                    <?php 
                                    $index++;
                                    endforeach 
                                    ?>
                                </ul>
                            </div>
                        </li>
                        <?php } ?>
                        <li>
                            <div class="field-group radio">
                                <div class="radio-box">
                                    <div class="custom-user-input radio">
                                        <input class="user-input radio" type="radio" name="radio1" id="radio1-option2"<?= ($scenario == 3)? ' checked':'' ?>>
                                        <label class="custom-radio" for="radio1-option2"><i class="icon"></i></label>
                                    </div>
                                    <label class="input-label" for="radio1-option2">Pay exact amount</label>
                                    <p class="input-description">Nulla vitae elit libero, a pharetra augue. Nullam quis risus eget urna mollis ornare vel eu leo.</p>
                                </div>
                            </div>
                        </li>
                    </ul>
                </div>
                <?php } ?>

                <?php if ($scenario != 1) { ?>
                <div class="group-container payment-info">
                    <h3 class="group-title">Payment information</h3>
                    <div class="box box-payment-type">
                        <div class="field-group radio inline">
                            <div class="radio-box">
                                <div class="custom-user-input radio">
                                    <input class="user-input radio" type="radio" name="pay-by" id="pay-by-credit-card">
                                    <label class="custom-radio" for="pay-by-credit-card"><i class="icon"></i></label>
                                </div>
                                <label class="input-label" for="pay-by-credit-card">Credit card</label>
                            </div>
                            <div class="radio-box">
                                <div class="custom-user-input radio">
                                    <input class="user-input radio" type="radio" name="pay-by" id="pay-by-ich">
                                    <label class="custom-radio" for="pay-by-ich"><i class="icon"></i></label>
                                </div>
                                <label class="input-label" for="pay-by-ich">ICH</label>
                            </div>

                        </div>
                    </div>
                    <div class="box box-card-holder-name">
                        <div class="field-group text">
                            <label>
                                <span class="input-label">Name on credit card</span>
                                <input class="user-input text" type="text">
                            </label>
                        </div>
                    </div>
                    <div class="box box-card-info">
                        <div class="field-group text card-number">
                            <label>
                                <span class="input-label">Credit card number</span>
                                <input class="user-input text" type="tel">
                            </label>
                        </div>
                        <div class="field-group text expires">
                            <label>
                                <span class="input-label">Expires</span>
                                <input class="user-input text" type="tel" placeholder="YY-MM">
                            </label>
                        </div>
                        <div class="field-group text csv-code">
                            <label>
                                <span class="input-label">CSV Code <a class="csv-info" href="#"><i class="fa fa-info" aria-hidden="true"></i></a></span>
                                <input class="user-input text" type="tel">
                            </label>
                        </div>
                    </div>
                </div>
                <?php } ?>

            </section>

            <section class="columns sub-container payment-confirmation">
                <h2 class="section-title">Payment Confirmation</h2>
                <div class="table-container">
                    <table class="data-table table-payment table-confirmation">
                        <tr class="item">
                            <th>
                                <?php
                                if ($scenario == 1) {
                                    $text = '<p class="no-payment">No payment necessary</p>';
                                } else if ($scenario == 2) {
                                    $text = '<strong>7,500</strong> email credits';
                                } else if ($scenario == 3) {
                                    $text = '<strong>5,000</strong> emails at $0.10 cost/email';
                                } else {
                                    $text = '<strong>Starter edition</strong> subscription';
                                }
                                ?>
                                <?= $text ?>
                            </th>
                            <td class="price">
                                <?php
                                if ($scenario == 1) {
                                    $price = '';
                                } else if ($scenario == 2) {
                                    $price = '$150.00';
                                } else if ($scenario == 3) {
                                    $price = '$500.00';
                                } else {
                                    $price = '$1,500.00';
                                }
                                ?>
                                <strong><?= $price ?></strong>
                            </td>
                        </tr>
                        <tr class="total">
                            <th>
                                Total
                            </th>
                            <td class="price">
                                <?php
                                if ($scenario == 1) {
                                    $price = '0.00';
                                } else if ($scenario == 2) {
                                    $price = '150.00';
                                } else if ($scenario == 3) {
                                    $price = '500.00';
                                } else {
                                    $price = '1,500.00';
                                }
                                ?>
                                $<?= $price ?> USD
                            </td>
                        </tr>
                    </table>
                </div>
            </section>

        </div>

        <div class="footer-actions">
            <ul class="list actions">
                <li><a class="text-link" href="#">Cancel</a></li>
                <li><a class="button" href="#">Submit payment</a></li>
            </ul>
        </div>

    </div>
</main>