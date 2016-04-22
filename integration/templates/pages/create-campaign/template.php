<main class="main-content">
    <div class="inner-wrapper">
        <?php 
        $main_step = 3;
        include 'includes/components/process.php';
        ?>

        <h1 class="page-title">Select Template</h1>
        
        <ul class="nav tabs">
            <li class="active"><a href="#">Basic Templates</a></li>
            <li><a href="#">Saved Templates</a></li>
            <li><a href="#">Use your HTML code</a></li>
        </ul>
        
        <ul class="list template-list">
            <?php foreach ($templates as $template): ?>
                <li class="list-item">
                    <figure class="item-image">
                        <img src="<?= $template['image_path'] ?>" alt="<?= $template['name'] ?>">
                    </figure>
                    <h2 class="item-name"><?= $template['name'] ?></h2>
                    <p class="item-description"><?= $template['description'] ?></p>
                    <div class="action">
                        <a class="button" href="#">Select</a>
                    </div>
                </li>
            <?php endforeach ?>
        </ul>

        <div class="footer-actions text-right">
            <a class="button" href="<?= $page_url['design'] ?>">Continue</a>
        </div>
    </div>
</main>