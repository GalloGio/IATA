<section id="js-modal-new-list-confirmation" class="modal-content wide">

    <header class="modal-header">
        <h2 class="modal-title">Create a new list</h2>
        <a href="#" class="icon-close js-close-modal js-clear-form"><i class="fa fa-times"></i></a>
    </header>

    <div class="modal-body">

        <?php 
        $step = 4;
        include 'includes/components/process-new-list.php';
        ?>

        <h3 class="step-title">Confirmation</h3>

        <div class="row">
            <div class="main-container columns small-12 medium-8">
                <table class="data-table new-campaign">
                    <tr>
                        <th>Audience:</th>
                        <td>
                            IATA Travel Agencies
                        </td>
                    </tr>
                    <tr>
                        <th>Geo Selection:</th>
                        <td>
                            <span class="label">Country</span>
                            <span class="value">Canada</span>
                        </td>
                    </tr>
                    <tr>
                        <th>Refinement:</th>
                        <td>
                            <ul class="list">
                                <li>
                                    <span class="label">Email address</span>
                                    <span class="value">john.doe@email.com</span>
                                </li>
                                <li>
                                    <span class="label">Lorem ipsum dolor</span>
                                    <span class="value">Dolor sit amet quon mullis</span>
                                </li>
                            </ul>
                        </td>
                    </tr>
                </table>
                <div class="field-group text list-name">
                    <label>
                        <span class="input-label">Please provide a list name</span>
                        <input class="user-input text js-remaining-characters" type="text" data-target-element=".js-remaining-count" data-target-id="list-name" data-max-length="82">
                    </label>
                    <div class="input-remaining">
                        <span class="js-remaining-count" data-id="list-name">82</span>
                    </div>
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
                            <tr>
                                <th>
                                    <div class="item-name">Your new account balance will be</div>
                                </th>
                                <td>
                                    <div class="item-value">
                                        <strong>0</strong>
                                        <span class="unit"> email(s)</span>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <footer class="modal-footer">
        <div class="footer-actions text-right">
            <a class="button wide js-close-modal js-clear-form" href="#">Save and use in campaign</a>
        </div>
    </footer>

</section>