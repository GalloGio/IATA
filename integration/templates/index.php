<?php 
$base_dir  = __DIR__; // Absolute path to your installation, ex: /var/www/mywebsite
$doc_root  = preg_replace("!${_SERVER['SCRIPT_NAME']}$!", '', $_SERVER['SCRIPT_FILENAME']); # ex: /var/www
$base_url  = preg_replace("!^${doc_root}!", '', $base_dir); # ex: '' or '/mywebsite'
$protocol  = empty($_SERVER['HTTPS']) ? 'http' : 'https';
$port      = $_SERVER['SERVER_PORT'];
$disp_port = ($protocol == 'http' && $port == 80 || $protocol == 'https' && $port == 443) ? '' : ":$port";
$domain    = $_SERVER['SERVER_NAME'];
$full_url  = "${protocol}://${domain}${disp_port}${base_url}"; # Ex: 'http://example.com', 'https://example.com/mywebsite', etc.


$page = $_GET['page'];
$iata = 'eBroadcast - IATA: International Air Transport Association';

$page_path = array(

    'dashboard'     => 'dashboard',

    'recipients'    => 'recipients',
    'template'      => 'template',
    'design'        => 'design',
    'schedule'      => 'schedule',
    'payment'       => 'payment',
    'setup'         => 'setup'

    );

$page_url = array(

    'dashboard'     => './',

    'recipients'    => './?page=' . $page_path['recipients'],
    'template'      => './?page=' . $page_path['template'],
    'design'        => './?page=' . $page_path['design'],
    'schedule'      => './?page=' . $page_path['schedule'],
    'payment'       => './?page=' . $page_path['payment'],
    'setup'         => './?page=' . $page_path['setup']

    );



switch($page) {

    case $page_path['dashboard']:
        $title = $iata;
        break;

    // Create Campaign
    case $page_path['setup']:
        $title = 'Setup' . ' - ' . $iata;
        break;
    case $page_path['recipients']:
        $title = 'Recipients' . ' - ' . $iata;
        break;
    case $page_path['template']:
        $title = 'Template' . ' - ' . $iata;
        break;
    case $page_path['design']:
        $title = 'Design' . ' - ' . $iata;
        break;
    case $page_path['schedule']:
        $title = 'Summary &amp; Schedule' . ' - ' . $iata;
        break;
    case $page_path['payment']:
        $title = 'Payment' . ' - ' . $iata;
        break;


    // js undefined
    case 'undefined': 
        $title = '404' . ' - ' . $iata;
        break;

    default:
        $title = $iata;
}

include_once("includes/common/header.php");

if(isset($page)) {

    switch($page) {

        case $page_path['dashboard']:
            include_once('pages/landing/dashboard.php');
            break;

        // Create Campaign
        case $page_path['setup']:
            include_once('pages/create-campaign/setup.php');
            break;
        case $page_path['recipients']:
            include_once('pages/create-campaign/recipients.php');
            break;
        case $page_path['template']:
            include_once('pages/create-campaign/template.php');
            break;
        case $page_path['design']:
            include_once('pages/create-campaign/design.php');
            break;
        case $page_path['schedule']:
            include_once('pages/create-campaign/schedule.php');
            break;
        case $page_path['payment']:
            include_once('pages/create-campaign/payment.php');
            break;

        // js undefined
        case 'undefined': 
            include_once('pages/404/404.php');
            break;
    }

} else {
    if ($base_url === '/ui/templates') {
        include_once('pages/landing/dashboard.php');
    } else {
        include_once('pages/404/404.php');
    }
}


include_once("includes/common/footer.php"); 


?>