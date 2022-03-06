<?php
$ip = $_SERVER['REMOTE_ADDR'];
// display it back
echo "<h1>VERSION 2</h1>";
echo "<h2>Hostname</h2>";
echo "Server Hostname: " . php_uname("n");
echo "<h2>Server Location</h2>";
echo "Region and Zone: " . "region-here";
?>