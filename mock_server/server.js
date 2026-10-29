// Reuse the read-only, memory-backed server. No database writes.
const server = require('./api/server');
server.listen(process.env.PORT || 3000, '0.0.0.0');
