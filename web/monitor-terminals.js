// Automatic Terminal Monitor for Notifications
// Monitors terminal output and automatically sets notifications

const fs = require('fs');
const { exec } = require('child_process');
const http = require('http');

const SYNC_API = 'http://127.0.0.1:8889/sync';
const CHECK_INTERVAL = 2000; // Check every 2 seconds

// Patterns that trigger notifications
const PATTERNS = {
    question: [
        /\[Y\/n\]/i,
        /\[y\/N\]/i,
        /\(y\/n\)/i,
        /continue\?/i,
        /proceed\?/i,
        /are you sure/i,
        /press enter/i,
        /waiting for/i,
        /password:/i,
        /\?$/m
    ],
    success: [
        /✓|✔|done|complete|success|finished|ready/i,
        /successfully/i,
        /build.*ok/i,
        /test.*passed/i,
        /deployment.*complete/i
    ],
    error: [
        /error|fail|fatal|exception|abort/i,
        /command not found/i,
        /permission denied/i,
        /connection refused/i,
        /\[ERROR\]/i,
        /\[FAIL\]/i
    ],
    process_done: [
        /npm.*install.*complete/i,
        /build.*complete/i,
        /compilation.*complete/i,
        /\d+% complete/
    ]
};

// Get workspace data
async function getWorkspaces() {
    return new Promise((resolve, reject) => {
        http.get(SYNC_API, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try {
                    resolve(JSON.parse(data));
                } catch (e) {
                    reject(e);
                }
            });
        }).on('error', reject);
    });
}

// Update workspace notification
async function updateWorkspace(workspacesData) {
    return new Promise((resolve, reject) => {
        const postData = JSON.stringify(workspacesData);
        
        const options = {
            hostname: '127.0.0.1',
            port: 8889,
            path: '/sync',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(postData)
            }
        };
        
        const req = http.request(options, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => resolve(JSON.parse(data)));
        });
        
        req.on('error', reject);
        req.write(postData);
        req.end();
    });
}

// Get last N lines from tmux pane
function getTmuxOutput(session, lines = 50) {
    return new Promise((resolve, reject) => {
        exec(`tmux capture-pane -p -t ${session} -S -${lines}`, (error, stdout, stderr) => {
            if (error) {
                reject(error);
            } else {
                resolve(stdout);
            }
        });
    });
}

// Detect pattern in text
function detectPattern(text, patterns) {
    for (const pattern of patterns) {
        if (pattern.test(text)) {
            return true;
        }
    }
    return false;
}

// Check terminal for notifications
async function checkTerminal(workspaceId, session) {
    try {
        const output = await getTmuxOutput(session, 30);
        const lastLines = output.split('\n').slice(-5).join('\n');
        
        // Check for questions/input needed
        if (detectPattern(lastLines, PATTERNS.question)) {
            return { type: 'warning', icon: '?' };
        }
        
        // Check for errors
        if (detectPattern(lastLines, PATTERNS.error)) {
            return { type: '', icon: '!' };
        }
        
        // Check for success
        if (detectPattern(lastLines, PATTERNS.success)) {
            return { type: 'success', icon: '✓' };
        }
        
        // Check for process completion
        if (detectPattern(lastLines, PATTERNS.process_done)) {
            return { type: 'success', icon: '✓' };
        }
        
        return null;
    } catch (error) {
        // Session might not exist yet
        return null;
    }
}

// Monitor all workspaces
async function monitorWorkspaces() {
    try {
        const data = await getWorkspaces();
        
        if (!data.workspaces || data.workspaces.length === 0) {
            return;
        }
        
        let needsUpdate = false;
        
        for (const workspace of data.workspaces) {
            const notification = await checkTerminal(workspace.id, workspace.terminalSession);
            
            // Set notification if detected and not already set
            if (notification && JSON.stringify(workspace.notification) !== JSON.stringify(notification)) {
                workspace.notification = notification;
                needsUpdate = true;
                console.log(`[${new Date().toISOString()}] Notification set for workspace ${workspace.id}: ${notification.icon}`);
            }
        }
        
        // Update if any changes
        if (needsUpdate) {
            await updateWorkspace(data);
        }
        
    } catch (error) {
        console.error('Monitor error:', error.message);
    }
}

// Start monitoring
console.log('🔔 Terminal Monitor started');
console.log('Checking terminals every', CHECK_INTERVAL / 1000, 'seconds');

setInterval(monitorWorkspaces, CHECK_INTERVAL);

// Initial check
monitorWorkspaces();
