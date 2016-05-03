<main class="main-content">
    <div class="inner-wrapper">
        <?php 
        $main_step = 2;
        include 'includes/components/process.php';
        ?>
        <h1 class="page-title">Select the list you want to use</h1>
        
        <div class="row">
            <div class="main-container columns small-12 medium-8">
                <ul class="list list-radio-select js-radio-list js-form-continue-validation" data-target-button="#js-continue-to-template">
                    <?php 
                    $index = 1;
                    foreach ($campaign_list as $item): 
                        ?>
                    <li>
                        <div class="radio-box">
                            <div class="custom-user-input radio">
                                <input class="user-input radio" type="radio" name="campain-list" id="campain-list-<?= $index ?>">
                                <label class="custom-radio" for="campain-list-<?= $index ?>"><i class="icon"></i></label>
                            </div>
                            <label class="input-label" for="campain-list-<?= $index ?>">
                                <?= $item['name'] ?> 
                                <span class="number-of-recipients">(<?= number_format($item['number_of_recipients']) ?> recipients)</span>
                            </label>
                        </div>
                    </li>
                    <?php 
                    $index++;
                    endforeach 
                    ?>
                </ul>

                <div class="list-actions">
                    <a class="icon-link js-open-modal" href="#" data-target-modal="#js-modal-new-list-audience"><i class="icon fa fa-list-ul" aria-hidden="true"></i>Create a new list</a>
                </div>
            </div>

            <div class="sub-container columns small-12 medium-4">
                <div class="summary-box">
                    <div class="box-body fit">
                        <table class="data-table zibra cost">
                            <caption>Campaign Cost</caption>
                            <tr>
                                <th>
                                    <div class="item-name">Recipients selected</div>
                                </th>
                                <td>
                                    <div class="item-value">
                                        <strong>15,000</strong>
                                        <span class="unit"> emails</span>
                                        <a class="icon-refresh" href="#"><i class="fa fa-refresh" aria-hidden="true"></i></a>
                                    </div>
                                </td>
                            </tr>
                            <tr> 
                                <th>
                                    <div class="item-name">Available balance</div>
                                </th>
                                <td>
                                    <div class="item-value text-green">
                                        <strong>10,000</strong>
                                        <span class="unit"> emails</span>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th>
                                    <div class="item-name">Provisional cost</div>
                                </th>
                                <td>
                                    <div class="item-value">
                                        <strong class="text-orange">USD $500.00</strong>
                                        <p>for 5,000 emails at $0.10 cost/email</p>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="footer-actions text-right">
            <a class="button disabled js-open-modal" data-default-state="disabled" id="js-continue-to-template" href="#" data-target-modal="#js-modal-confirmation">Continue</a>
        </div>
    </div>
</main>
