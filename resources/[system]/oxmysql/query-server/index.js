const mariadb = require('mariadb')
const express = require('express')

const PORT = 8976
const pool = mariadb.createPool({
  host: 'localhost',
  port: 3306,
  user: 'root',
  charset: 'utf8mb4',
  database: 'royale',
  dateStrings: false, 
  typeCast(column, next) {
    if (column.type == "TINY" && column.length === 1) {
      const val = column.int();
      return val === null ? null : val === 1;
    }
    return next();
  }
})

function removeBigInt(object) {
  return JSON.parse(JSON.stringify(object, (_, it) => {
    if (typeof it === "bigint") {
      return parseInt(it);
    } else if (typeof it === "string" && it.match(/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}z$/i)) {
      return new Date(it).getTime();
    }
    return it
  }))
  // return JSON.parse(JSON.stringify(object, (_, it) => typeof it === 'bigint' ? parseInt(it) : it))
}

const app = express()

app.use(express.json())
app.post('/query', (req, res) => {
  const { sql, args, resource } = req.body
  const namedPlaceholders = !Array.isArray(args)
  const started_at = Date.now()

  pool.query({ 
    sql: sql.replace(/@(\w+)/g, ':$1'),
    namedPlaceholders 
  }, args).then(
    it => res.send(removeBigInt(it)),
    err => res.send({ error: err.message })
  ).finally(() => {
    const elapsed = Date.now() - started_at

    if (elapsed > 200) {
      console.warn('[%s] The query "%s" with %s took %d ms to resolve', resource, sql, JSON.stringify(args), elapsed)
    }
  })
})

app.listen(PORT, '127.0.0.1', () => console.log('Running at port %d', PORT))