<?php
declare(strict_types=1);

/**
 * Burnout Pulse AI Admin - Authentication API
 * Requires db.php and config.php in the same api/ directory.
 *
 * GET  ?action=session : check current login session
 * POST ?action=login   : login with JSON {"username":"...","password":"..."}
 * POST ?action=logout  : destroy current login session
 */

require_once __DIR__ . '/db.php';

$method = request_method();
$action = strtolower(trim((string)($_GET['action'] ?? 'session')));

if ($action === 'session') {
    if ($method !== 'GET') {
        header('Allow: GET');
        json_response(['error' => 'Session endpoint requires GET'], 405);
    }

    json_response([
        'authenticated' => !empty($_SESSION['admin_user']),
        'user' => $_SESSION['admin_user'] ?? null,
    ]);
}

if ($action === 'login') {
    if ($method !== 'POST') {
        header('Allow: POST');
        json_response(['error' => 'Login endpoint requires POST'], 405);
    }

    $body = json_input();
    $username = trim((string)($body['username'] ?? ''));
    $password = (string)($body['password'] ?? '');

    if ($username === '' || $password === '') {
        json_response(['error' => 'กรุณากรอกชื่อผู้ใช้และรหัสผ่าน'], 400);
    }

    if (
        !hash_equals(ADMIN_USERNAME, $username) ||
        !password_verify($password, ADMIN_PASSWORD_HASH)
    ) {
        // Generic error: do not disclose whether the username exists.
        json_response(['error' => 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง'], 401);
    }

    session_regenerate_id(true);
    $_SESSION['admin_user'] = $username;
    json_response(['user' => $username]);
}

if ($action === 'logout') {
    if ($method !== 'POST') {
        header('Allow: POST');
        json_response(['error' => 'Logout endpoint requires POST'], 405);
    }

    $_SESSION = [];

    if (ini_get('session.use_cookies')) {
        $params = session_get_cookie_params();
        setcookie(session_name(), '', [
            'expires' => time() - 42000,
            'path' => $params['path'] ?: '/',
            'domain' => $params['domain'] ?? '',
            'secure' => (bool)($params['secure'] ?? false),
            'httponly' => (bool)($params['httponly'] ?? true),
            'samesite' => $params['samesite'] ?? 'Lax',
        ]);
    }

    session_destroy();
    json_response(['ok' => true]);
}

json_response(['error' => 'ไม่พบ action ที่ร้องขอ'], 404);
