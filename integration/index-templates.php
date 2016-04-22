<!-- page list index -->
<?php require_once("docs/data/common.php"); ?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <link rel="stylesheet" href="//fonts.googleapis.com/css?family=Open+Sans:300,400,700,800">
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">
    <link rel="stylesheet" href="/ui/docs/assets/css/index.min.css">
    <title><?= $title ?></title>
</head>
<body>
    <div class="page-container">
        <?php include_once("docs/includes/common/page-header.php"); ?>
        <div class="page-content">
        <a href="//4s005j.axshare.com/">4s005j.axshare.com</a>
            <section class="section wiki">
                <h2 class="section-title accordion js-accordion">Wiki</h2>
                <div class="accordion-panel">
                    <dl class="list">
                        <dt class="js-accordion"><h3 class="section-title accordion">Setup Guide</h3></dt>
                        <dd class="accordion-panel">
                            <?php include_once("docs/includes/components/setup-guide-gulp.php"); ?>
                        </dd>
                        <dt class="js-accordion"><h3 class="section-title accordion">Browser support</h3></dt>
                        <dd class="accordion-panel">
                            <?php include_once("docs/includes/components/browser-support.php"); ?>
                        </dd>
                        <dt class="js-accordion"><h3 class="section-title accordion">Testing devices</h3></dt>
                        <dd class="accordion-panel">
                            <?php include_once("docs/includes/components/testing-devices.php"); ?>
                        </dd>
                    </dl>
                </div>
            </section>

            <main class="main-content">
                <h2 class="section-title">Page Templates</h2>

                <div class="sort-container" style="display: none;">
                    <div class="field-group quick-search">
                        <label class="input-label" for="quick-search">Quick Search</label>
                        <input class="user-input" id="quick-search" type="text">
                    </div>
                    <div class="field-group category-sort">
                        <label class="input-label" for="category-sort">Category Sort</label>
                        <select class="user-input" id="category-sort">
                            <option value="all">All</option>
                            <option value="category1">Category 1</option>
                            <option value="category2">Category 2</option>
                        </select>
                    </div>
                    <div class="group-container tag-sort">
                        Tag search
                    </div>
                </div>

                <table class="data-table index" id="js-page-list">
                    <tr>
                        <th class="status">
                            <span class="title">Status</span>
                        </th>
                        <!-- <th class="sprint">
                            <span class="title">Sprint</span>
                            <div class="switch">
                                <input class="user-input" type="checkbox">
                                <label class="input-label" data-on="Show" data-off="Hide"></label>
                            </div>
                        </th> -->
                        <!-- <th class="story">
                            <span class="title">User Story</span>
                            <div class="switch">
                                <input class="user-input" type="checkbox">
                                <label class="input-label" data-on="Show" data-off="Hide"></label>
                            </div>
                        </th> -->
                        <!-- <th class="screenshot">
                            <span class="title">Screenshot</span>
                            <div class="switch">
                                <input class="user-input" type="checkbox">
                                <label class="input-label" data-on="Show" data-off="Hide"></label>
                            </div>
                        </th> -->
                        <th class="category">
                            <span class="category">Category</span>
                        </th>
                        <th class="page">
                            <span class="title">Page</span>
                        </th>
                        <th class="design">
                            <span class="title">Design</span>
                            <div class="switch">
                                <input class="user-input" type="checkbox">
                                <label class="input-label" data-on="Show" data-off="Hide"></label>
                            </div>
                        </th>
                        <th class="tags">
                            <span class="title">Tags</span>
                            <div class="switch">
                                <input class="user-input" type="checkbox">
                                <label class="input-label" data-on="Show" data-off="Hide"></label>
                            </div>
                        </th>
                    </tr>
                </table>
            </main>
        </div>

        <?php include_once("docs/includes/common/page-footer.php"); ?>

    </div>
    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
    <script src="docs/assets/js/index.min.js"></script>
    <script src="docs/assets/vendor/script.min.js"></script>
</body>
</html>