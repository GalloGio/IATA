<main class="main-content">
    <div class="inner-wrapper">
        <?php 
        $main_step = 3;
        include 'includes/components/process.php';
        ?>

        <h1 class="page-title">Select Template</h1>
        
        <div class="tab-container js-tabs">
            <ul class="nav tabs">
                <li class="active" data-target="#pane-1"><a href="#">Basic Templates</a></li>
                <li data-target="#pane-2"><a href="#">Saved Templates</a></li>
                <li data-target="#pane-3"><a href="#">Use your HTML code</a></li>
            </ul>

            <div class="tab-content">
                <div class="tab-pane is-open" id="pane-1">
                    <ul class="list template-list js-template-list">
                        <?php 
                        $index = 1;
                        foreach ($templates as $template): 
                            ?>
                        <li class="list-item">
                            <div class="checkbox-box">
                                <div class="custom-user-input checkbox">
                                    <input class="user-input checkbox" type="checkbox" id="template-<?= $index ?>">
                                    <label class="custom-checkbox" for="template-<?= $index ?>"><i class="icon"></i></label>
                                </div>
                                <label class="input-label" for="template-<?= $index ?>"><span class="input-state unselected">Select</span> <span class="input-state selected">Selected</span></label>
                            </div>
                            <h2 class="item-name"><?= $template['name'] ?></h2>
                            <figure class="item-image">
                                <img src="<?= $template['image_path'] ?>" alt="<?= $template['name'] ?>">
                            </figure>
                        </li>
                        <?php 
                        $index++;
                        endforeach 
                        ?>
                    </ul>
                </div>
                <div class="tab-pane" id="pane-2">
                    <ul class="list template-list js-saved-template-list">
                        <?php 
                        $index = 1;
                        foreach ($templates as $template): 
                            ?>
                        <li class="list-item">
                            <div class="checkbox-box">
                                <div class="custom-user-input checkbox">
                                    <input class="user-input checkbox" type="radio" name="template" id="saved-template-<?= $index ?>">
                                    <label class="custom-checkbox" for="saved-template-<?= $index ?>"><i class="icon"></i></label>
                                </div>
                                <label class="input-label" for="saved-template-<?= $index ?>"><span class="input-state unselected">Select</span> <span class="input-state selected">Selected</span></label>
                            </div>
                            <h2 class="item-name"><?= $template['name'] ?></h2>
                            <figure class="item-image">
                                <img src="<?= $template['image_path'] ?>" alt="<?= $template['name'] ?>">
                            </figure>
                        </li>
                        <?php 
                        $index++;
                        endforeach 
                        ?>
                    </ul>
                </div>
                <div class="tab-pane" id="pane-3">
                    <div class="field-group textarea">
                        <label>
                            <span class="input-label">HTML code</span>
                            <textarea class="user-input textarea" rows="10"></textarea>
                        </label>
                    </div>
                </div>
            </div>
        </div>

        <div class="footer-actions text-right">
            <a class="button" href="<?= $page_url['design'] ?>">Continue</a>
        </div>
    </div>
</main>