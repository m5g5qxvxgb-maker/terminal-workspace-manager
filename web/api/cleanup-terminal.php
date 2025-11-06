<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$workspaceId = isset($_GET['id']) ? intval($_GET['id']) : 0;

if ($workspaceId <= 0 || $workspaceId > 100) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Invalid workspace ID']);
    exit;
}

$output = [];
$return_var = 0;
exec("/var/www/terminal/cleanup-terminal.sh $workspaceId 2>&1", $output, $return_var);

echo json_encode([
    'success' => $return_var === 0,
    'workspaceId' => $workspaceId,
    'output' => implode("\n", $output)
]);
