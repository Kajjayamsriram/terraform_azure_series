<?php
session_start();

$host = "azureserver90.mysql.database.azure.com";
$user = "sriram";
$password = "demo!321";
$dbname = "mysqldb";

$conn = mysqli_init();

mysqli_ssl_set(
    $conn,
    NULL,
    NULL,
    "/var/www/html/DigiCertGlobalRootG2.crt.pem",
    NULL,
    NULL
);

mysqli_options($conn, MYSQLI_OPT_SSL_VERIFY_SERVER_CERT, true);

if (!mysqli_real_connect(
    $conn,
    $host,
    $user,
    $password,
    $dbname,
    3306,
    NULL,
    MYSQLI_CLIENT_SSL
)) {
    die("Connection failed: " . mysqli_connect_error());
}

?>