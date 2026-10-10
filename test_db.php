<?php
try {
    $pdo = new PDO(
        "mysql:host=10.26.1.95;port=3306;dbname=my_database;charset=utf8mb4",
        "admin_user",
        "123456",
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    echo "Database connection OK";
    echo "<br>Database: " .
         $pdo->query("SELECT DATABASE()")->fetchColumn();

} catch (PDOException $e) {
    echo "Database connection FAILED";
    echo "<br>Error: " . htmlspecialchars($e->getMessage());
}