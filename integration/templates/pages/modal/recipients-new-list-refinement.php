<section id="js-modal-new-list-refinement" class="modal-content wide">

    <header class="modal-header">
        <h2 class="modal-title">Create a new list</h2>
        <a href="#" class="icon-close js-close-modal js-clear-form"><i class="fa fa-times"></i></a>
    </header>

    <div class="modal-body">

        <?php 
        $step = 3;
        include 'includes/components/process-new-list.php';
        ?>

        <h3 class="step-title">Refinement</h3>

        <?php include 'includes/components/group-geo-selection.php'; ?>

        <footer class="modal-footer">
            <div class="footer-actions text-right">
                <a class="button js-open-modal" data-target-modal="#js-modal-new-list-confirmation" href="#">Continue</a>
            </div>
        </footer>

</section>