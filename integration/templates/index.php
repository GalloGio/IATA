<?php 
// Templates
require_once 'data/common.php';
$page_title = $project_name;

$page = $_GET['page'];

if (isset($page) && !empty($page)) {
    if (array_key_exists($page, $pages)) {
        $page_title = $pages[$page]['title'] . ' - ' . $project_name;
    } else {
        // 404
        $page_title = '404 - ' . $project_name;
    }
} else {
    // home
    $page_title = 'Dashboard - ' . $project_name;
} 

include_once 'includes/common/header.php';

if (isset($page) && !empty($page)) {

    if (array_key_exists($page, $pages)) {

        include_once $pages[$page]['file'];

    } else {
        include_once 'pages/404/404.php';
    }
} else {
    include_once 'pages/landing/dashboard.php';
}

include_once 'includes/common/footer.php'; 


?>