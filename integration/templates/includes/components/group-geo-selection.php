<div class="group-container custom-geo-selection">
    <div class="field-group recipents-match select default">
        Recipents match
        <div class="custom-user-input select">
            <i class="icon angle-down"></i>
            <select class="user-input select">
                <option value="">Any</option>
            </select>
        </div>
        of the following Geo-Selections:
    </div>

    <?php if ($step == 3) { ?>
        
        <div class="field-group select default">
            <div class="custom-user-input select">
                <i class="icon angle-down"></i>
                <select class="user-input select">
                    <option value="">Country</option>
                </select>
            </div>
            <div class="custom-user-input select">
                <i class="icon angle-down"></i>
                <select class="user-input select">
                    <option value="">is</option>
                </select>
            </div>
            <input class="user-input text" type="text">
        </div>
        <div class="field-group select default js-target-field">
            <div class="custom-user-input select">
                <i class="icon angle-down"></i>
                <select class="user-input select">
                    <option value="">Country</option>
                </select>
            </div>
            <div class="custom-user-input select">
                <i class="icon angle-down"></i>
                <select class="user-input select">
                    <option value="">is</option>
                </select>
            </div>
            <input class="user-input text" type="text">
            <a class="action-link js-remove-field" href="#"><i class="icon fa fa-minus-circle" aria-hidden="true"></i>Remove</a>
        </div>
        <div class="field-group select default js-target-field">
            <div class="custom-user-input select">
                <i class="icon angle-down"></i>
                <select class="user-input select">
                    <option value="">Country</option>
                </select>
            </div>
            <div class="custom-user-input select">
                <i class="icon angle-down"></i>
                <select class="user-input select">
                    <option value="">is</option>
                </select>
            </div>
            <input class="user-input text" type="text">
            <a class="action-link js-remove-field" href="#"><i class="icon fa fa-minus-circle" aria-hidden="true"></i>Remove</a>
        </div>

    <?php } else { ?>

        <div class="field-group select default">
            <div class="custom-user-input select">
                <i class="icon angle-down"></i>
                <select class="user-input select">
                    <option value="">Country</option>
                </select>
            </div>
            <div class="custom-user-input select">
                <i class="icon angle-down"></i>
                <select class="user-input select">
                    <option value="">is</option>
                </select>
            </div>
            <input class="user-input text" type="text">
        </div>

    <?php } ?>
    

    <div class="action add-field">
        <a class="js-add-field" data-target-field="#js-template-add-field" href="#"><i class="icon fa fa-plus-circle" aria-hidden="true"></i>Add</a>
    </div>

    <div class="action refresh-count">
        <strong>15,000 recipients</strong> in this segment.
        <a class="button secondary" href="#"><i class="icon fa fa-refresh" aria-hidden="true"></i> Refresh count</a>
    </div>

    <!-- Field template -->
    <script type="text/template" id="js-template-add-field">
        <div class="field-group select default js-target-field">
            <div class="custom-user-input select">
                <i class="icon angle-down"></i>
                <select class="user-input select">
                    <option value="">Country</option>
                </select>
            </div>
            <div class="custom-user-input select">
                <i class="icon angle-down"></i>
                <select class="user-input select">
                    <option value="">is</option>
                </select>
            </div>
            <input class="user-input text" type="text">
            <a class="action-link js-remove-field" href="#"><i class="icon fa fa-minus-circle" aria-hidden="true"></i>Remove</a>
        </div>
    </script>
    <!-- /END Field template -->
</div>