<main class="main-content">
    <div class="inner-wrapper">
        <h1 class="page-title">Select a template</h1>
        
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

        <?php include 'includes/components/pager.php'; ?>

    </div>
</main>