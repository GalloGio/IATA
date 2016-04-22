<main class="main-content content-dashboard">
    <div class="inner-wrapper">
        <h1 class="page-title">Dashboard</h1>

        <div class="row">
            <div class="main-container columns small-12 medium-8">

                <?php

                $select_drop_down = '
                                    <div class="custom-user-input select">
                                        <i class="icon angle-down"></i>
                                        <select class="user-input select js-champaign-actions js-open-modal">
                                            <option value="default">Select action</option>
                                            <option value="delete" data-target-modal="#js-modal-delete-campaign">Delete</option>
                                            <option value="rename" data-target-modal="#js-modal-rename-campaign">Rename</option>
                                            <option value="pause" data-target-modal="#js-modal-pause-campaign">Pause</option>
                                            <option value="pause" data-target-modal="#js-modal-cancel-campaign">Cancel</option>
                                            <option value="pause" data-target-modal="#js-modal-change-schedule">Change schedule</option>
                                        </select>
                                    </div>
                                    ';

                $scenario = $_GET['scenario'];
                if ($scenario == 2) { 
                    ?>
                    <div class="group-container campaigns">
                        <h2 class="group-title">Campaigns</h2>
                        <h3 class="lead">You have no saved campaigns</h3>
                        <p>Increase the exposure of your products &amp; services to the population of IATA travel Agencies</p>
                    </div>

                    <div class="action-box">
                        <a class="button" href="<?= $page_url['setup'] ?>">Create campaign</a>
                    </div>
                    <?php
                } else {
                    ?>
                    
                    <div class="group-container campaigns">
                        <h2 class="group-title">Campaigns</h2>
                        <div class="action-box text-right create-campaign">
                            <a class="button" href="<?= $page_url['setup'] ?>">Create campaign</a>
                        </div>
                        <table class="data-table campaign">
                            <?php if ($scenario == 3) { ?>
                            <tr>
                                <td class="icon">
                                    <i class="icon icon-status draft"></i>
                                </td>
                                <td class="name">
                                    <ul class="list campaign">
                                        <li><a href="#">Campaign 1 (copy 01)</a></li>
                                        <li>Regular - IP, AS &amp; LD</li>
                                        <li><strong>Draft</strong></li>
                                        <li>Sun Feb 28, 2016 7:00 pm</li>
                                    </ul>
                                </td>
                                <td class="recipients">
                                </td>
                                <td class="opens">
                                </td>
                                <td class="clicks">
                                </td>
                                <td class="action">
                                    <?= $select_drop_down ?>
                                </td>
                            </tr>
                            <tr>
                                <td class="icon">
                                    <i class="icon icon-status pending"></i>
                                </td>
                                <td class="name">
                                    <ul class="list campaign">
                                        <li><a href="#">Campaign 1 (copy 01)</a></li>
                                        <li>Regular - IP, AS &amp; LD</li>
                                        <li><strong>Pending</strong></li>
                                        <li>Sun Feb 28, 2016 7:00 pm</li>
                                    </ul>
                                </td>
                                <td class="recipients">
                                </td>
                                <td class="opens">
                                </td>
                                <td class="clicks">
                                </td>
                                <td class="action">
                                    <?= $select_drop_down ?>
                                </td>
                            </tr>
                            <tr>
                                <td class="icon">
                                    <i class="icon icon-status rejected"></i>
                                </td>
                                <td class="name">
                                    <ul class="list campaign">
                                        <li><a href="#">Campaign 1 (copy 01)</a></li>
                                        <li>Regular - IP, AS &amp; LD</li>
                                        <li><strong>Rejected</strong></li>
                                        <li>Sun Feb 28, 2016 7:00 pm</li>
                                    </ul>
                                </td>
                                <td class="recipients">
                                </td>
                                <td class="opens">
                                </td>
                                <td class="clicks">
                                </td>
                                <td class="action">
                                    <?= $select_drop_down ?>
                                </td>
                            </tr>
                            <?php } ?>
                            <tr>
                                <td class="icon">
                                    <i class="icon icon-status schedule"></i>
                                </td>
                                <td class="name">
                                    <ul class="list campaign">
                                        <li><a href="#">Campaign 1 (copy 01)</a></li>
                                        <li>Regular - IP, AS &amp; LD</li>
                                        <li><strong>Schedule</strong></li>
                                        <li>Sun Feb 28, 2016 7:00 pm</li>
                                    </ul>
                                </td>
                                <td class="recipients">
                                </td>
                                <td class="opens">
                                </td>
                                <td class="clicks">
                                </td>
                                <td class="action">
                                    <?= $select_drop_down ?>
                                </td>
                            </tr>
                            <tr>
                                <td class="icon">
                                    <i class="icon icon-status sent"></i>
                                </td>
                                <td class="name">
                                    <ul class="list campaign">
                                        <li><a href="#">Campaign 1</a></li>
                                        <li>Recipients -  List ABC</li>
                                        <li><strong>Sent</strong></li>
                                        <li>Fri, Feb 26, 2016 11:00 am</li>
                                    </ul>
                                </td>
                                <td class="recipients">
                                    <strong class="value">3</strong> 
                                    <span class="label">Recipients</span>
                                </td>
                                <td class="opens">
                                    <strong class="value">100%</strong>
                                    <span class="label">Opens</span>
                                </td>
                                <td class="clicks">
                                    <strong class="value">66.7%</strong>
                                    <span class="label">Clicks</span>
                                </td>
                                <td class="action">
                                    <?= $select_drop_down ?>
                                </td>
                            </tr>
                            <tr>
                                <td class="icon">
                                    <i class="icon icon-status sent"></i>
                                </td>
                                <td class="name">
                                    <ul class="list campaign">
                                        <li><a href="#">Campaign 1</a></li>
                                        <li>Recipients -  List ABC</li>
                                        <li><strong>Sent</strong></li>
                                        <li>Fri, Feb 26, 2016 11:00 am</li>
                                    </ul>
                                </td>
                                <td class="recipients">
                                    <strong class="value">3</strong> 
                                    <span class="label">Recipients</span>
                                </td>
                                <td class="opens">
                                    <strong class="value">100%</strong>
                                    <span class="label">Opens</span>
                                </td>
                                <td class="clicks">
                                    <strong class="value">66.7%</strong>
                                    <span class="label">Clicks</span>
                                </td>
                                <td class="action">
                                    <?= $select_drop_down ?>
                                </td>
                            </tr>
                        </table>
                        <div class="action-box text-right">
                            <a href="#">View all campaigns</a>
                        </div>
                    </div>
                   <?php
                }
               ?>
            </div>

            <div class="sub-container columns small-12 medium-4">
                <div class="summary-box">
                    <div class="box-body fit">
                        <table class="data-table zibra">
                            <caption>Account Summary</caption>
                            <tr>
                                <th>
                                    <div class="item-name">Current Billing Plan</div>
                                    <p class="item-description">Pay-As-You-Go</p>
                                </th>
                                <td>
                                    <div class="item-value">
                                        <strong>$0.10</strong>
                                        <span class="per-unit">/email</span>
                                    </div>
                                    <a href="#">Upgrade to Pre-Paid plan</a>
                                </td>
                            </tr>
                            <tr> 
                                <th>
                                    <div class="item-name">Email Balance on Account</div>
                                </th>
                                <td>
                                    <div class="item-value">
                                        <strong>15, 000 emails</strong>
                                    </div>
                                    <a href="#">Purchase credits</a>
                                </td>
                            </tr>
                            <tr>
                                <th>
                                    <div class="item-name">Available Add Ons</div>
                                </th>
                                <td>
                                    <div class="item-value">
                                        <strong>Enhanced Reporting</strong>
                                    </div>
                                    <a href="#">View Add Ons Options</a>
                                </td>
                            </tr>
                        </table>
                        <div class="action-box text-right">
                            <a href="#">Manage account</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row row-mangage js-match-height">
            <div class="columns medium-4 group-container manage-templates">
                <h2 class="group-title">Manage templates and other resources</h2>
                <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum euismod neque ac dolor vestibulum, vitae tempor erat.</p>
                <div class="action">
                    <a href="#">Manage templates</a>
                </div>
            </div>
            <div class="columns medium-4 group-container manage-list">
                <h2 class="group-title">Manage your lists and create segments</h2>
                <p>Praesent pellentesque ligula eu metus euismod, eu commodo lorem eleifend. Phasellus nec fringilla dui, eu fermentum.</p>
                <div class="action">
                    <a href="#">Manage lists</a>
                </div>
            </div>
            <div class="columns medium-4 group-container view-reports">
                <h2 class="group-title">View how your campaigns perform</h2>
                <p>Nullam vitae dui vel diam accumsan aliquet id nec odio. Mauris at purus a arcu placerat lacinia. Aenean vulputate sem nisl, vitae.</p>
                <div class="action">
                    <a href="#">View reports</a>
                </div>
            </div>
        </div>

    </div>
</main>
