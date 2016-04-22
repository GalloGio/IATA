<div class="modal-container is-hidden" id="js-modal">
    <div class="overlay"></div>
    <div class="modal-dialog" id="js-modal-dialog">
        <?php 
        if ($page == $page_path['dashboard'] || $page == '') {
            include 'pages/modal/dashboard-delete-campaign.php';
            include 'pages/modal/dashboard-rename-campaign.php';
            include 'pages/modal/dashboard-pause-campaign.php';
            include 'pages/modal/dashboard-cancel-campaign.php';
            include 'pages/modal/dashboard-change-schedule.php';
        }

        if ($page == $page_path['recipients']) {
            include 'pages/modal/recipients-new-list-audience.php';
            include 'pages/modal/recipients-new-list-geo-selection.php';
            include 'pages/modal/recipients-new-list-refinement.php';
            include 'pages/modal/recipients-new-list-confirmation.php';
            include 'pages/modal/recipients-confirmation.php';
        }
        ?>
    </div>
</div>