const express = require('express');
const WebSocket = require('ws');
const prometheus = require('prom-client');

const app = express();
const port = 3001;

// Prometheus Metriken
const register = new prometheus.Registry();
prometheus.collectDefaultMetrics({ register });

const connectionStatus = new prometheus.Gauge({
  name: 'kraken_websocket_connection_status',
  help: 'Kraken WebSocket connection status',
  registers: [register]
});

const messageCount = new prometheus.Counter({
  name: 'kraken_websocket_messages_total',
  help: 'Total messages received from Kraken',
  registers: [register]
});

// WebSocket Client
let ws = null;
let reconnectTimeout = null;

function connectToKraken() {
  console.log('🔌 Connecting to Kraken WebSocket...');
  
  ws = new WebSocket('wss://ws.kraken.com');
  
  ws.on('open', function open() {
    console.log('✅ Connected to Kraken WebSocket');
    connectionStatus.set(1);
    
    // Subscribe to BTC/EUR ticker
    const subscribeMessage = {
      event: 'subscribe',
      pair: ['XBT/EUR'],
      subscription: {
        name: 'ticker'
      }
    };
    ws.send(JSON.stringify(subscribeMessage));
  });
  
  ws.on('message', function message(data) {
    messageCount.inc();
    try {
      const parsed = JSON.parse(data);
      console.log('📨 Received:', JSON.stringify(parsed).substring(0, 100));
    } catch (err) {
      console.error('Error parsing message:', err);
    }
  });
  
  ws.on('close', function close() {
    console.log('❌ WebSocket disconnected');
    connectionStatus.set(0);
    scheduleReconnect();
  });
  
  ws.on('error', function error(err) {
    console.error('WebSocket error:', err);
    connectionStatus.set(0);
  });
}

function scheduleReconnect() {
  if (reconnectTimeout) clearTimeout(reconnectTimeout);
  reconnectTimeout = setTimeout(() => {
    console.log('🔄 Reconnecting...');
    connectToKraken();
  }, 5000);
}

// HTTP Routes
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    service: 'md-collector-spot',
    websocket: ws && ws.readyState === WebSocket.OPEN ? 'connected' : 'disconnected'
  });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Start server
app.listen(port, () => {
  console.log(`🚀 MD Collector Spot running on port ${port}`);
  connectToKraken();
});
