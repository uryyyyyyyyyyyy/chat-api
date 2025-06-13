const { Pool } = require('pg');

const pool = new Pool({
  host: 'ep-holy-tree-a86qztrt-pooler.eastus2.azure.neon.tech',
  user: 'neondb_owner',
  password: 'npg_2XyqRnJcueA3',
  database: 'neondb',
  port: 5432,
  ssl: { rejectUnauthorized: false }
});

module.exports = pool;
