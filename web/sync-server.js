const http = require('http');
const fs = require('fs');
const path = require('path');

const DATA_FILE = '/var/www/terminal/data/workspaces.json';
const PORT = 8889;

// Ensure data directory exists
const dataDir = path.dirname(DATA_FILE);
if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir, { recursive: true });
}

const server = http.createServer((req, res) => {
    // CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    res.setHeader('Content-Type', 'application/json');
    
    // Handle preflight
    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }
    
    // GET - retrieve data
    if (req.method === 'GET' && req.url === '/sync') {
        if (fs.existsSync(DATA_FILE)) {
            const data = fs.readFileSync(DATA_FILE, 'utf8');
            res.writeHead(200);
            res.end(data);
        } else {
            const defaultData = {
                workspaces: [],
                nextId: 1,
                zoomLevels: {},
                lastUpdate: Date.now()
            };
            res.writeHead(200);
            res.end(JSON.stringify(defaultData));
        }
        return;
    }
    
    // POST - save data
    if (req.method === 'POST' && req.url === '/sync') {
        let body = '';
        
        req.on('data', chunk => {
            body += chunk.toString();
        });
        
        req.on('end', () => {
            try {
                const data = JSON.parse(body);
                data.lastUpdate = Date.now();
                
                fs.writeFileSync(DATA_FILE, JSON.stringify(data, null, 2));
                
                res.writeHead(200);
                res.end(JSON.stringify({ 
                    success: true, 
                    lastUpdate: data.lastUpdate 
                }));
            } catch (error) {
                res.writeHead(400);
                res.end(JSON.stringify({ 
                    success: false, 
                    error: error.message 
                }));
            }
        });
        return;
    }
    
    // 404
    res.writeHead(404);
    res.end(JSON.stringify({ error: 'Not found' }));
});

server.listen(PORT, '127.0.0.1', () => {
    console.log(`Sync server running on port ${PORT}`);
});
