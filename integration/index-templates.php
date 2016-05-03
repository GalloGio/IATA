<?php 
// Index
require_once 'index/data/common.php'; 
?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <link rel="stylesheet" href="//fonts.googleapis.com/css?family=Open+Sans:300,400,700,800">
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">
    <link rel="stylesheet" href="index/assets/css/index.min.css">
    <title><?= $title ?></title>
</head>
<body>
    <div class="page-container">
        
        <header class="page-header">
            <div class="inner-wrapper">
                <div class="title-wrapper">
                    <div class="project-logo">
                        <a href="./">
                        <!--[if lte IE 8]>
                            <img src="<?= $project_logo_bitmap ?>" alt="<?= $project_name ?>" width="150">
                        <![endif]-->
                        <!--[if (gte IE 9)|!(IE)]><!-->
                            <img src="<?= $project_logo_vector ?>" alt="<?= $project_name ?>" width="150">
                        <!--<![endif]-->
                        </a>
                    </div>
                    <h1 class="page-title"><?= $page_title ?></h1>
                </div>
                <!-- <nav class="nav-top">
                    <a href="docs/">Docs</a>
                </nav> -->
            </div>
        </header>

        <div class="page-content">
            <section class="group-container design">
                <h2 class="group-title">Designs</h2>
                <ul class="list inline">
                    <li><a href="//4s005j.axshare.com/">4s005j.axshare.com</a></li>
                </ul>
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

        <footer class="page-footer">
            <div class="inner-wrapper">

                <p class="note">
                    Created and maintained by <?= $author_name ?>
                    <?= (isset($author_email))? '&lt;'.$author_email.'&gt;':'' ?>
                    <?= (isset($company_name))? ' at '.$company_name:'' ?>.
                </p>

                <div class="last-update">Last update: <?= $last_update ?></div>

                <small class="copyright">
                    <?php if (isset($company_name)) { ?>
                    <img src="docs/assets/img/cgi-logo.png" alt="<?= $company_name ?>" class="cgi-logo">
                    <?php } ?>
                    &copy; <?= (isset($company_name))? $company_name : $author_name ?> <?= date('Y') ?>. All rights reserved.
                </small>

            </div>
        </footer>

    </div>
    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
    <script src="index/assets/js/index.min.js"></script>
</body>
</html>