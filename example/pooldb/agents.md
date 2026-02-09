模块pooldb

测试文件也使用模块pooldb

参考rust的实现：

```
use async_trait::async_trait;
use config::structs::{DatabaseConfig, DbType};
use serde_json::Value;
use sqlx::{mysql::MySqlPool, postgres::PgPool, Column, Row};
use std::time::Duration;

// 统一 trait 接口
#[async_trait]
pub trait DbExecutor: Send + Sync {
    async fn execute(&self, sql: &str) -> anyhow::Result<u64>;
    async fn fetch_all(&self, sql: &str) -> anyhow::Result<Vec<Vec<(String, Value)>>>;
    // 可以按需扩展更多方法，例如 fetch_one、transaction 等
}

// ================== MySQL 实现 ==================
pub struct MysqlDb {
    pool: MySqlPool,
}

#[async_trait]
impl DbExecutor for MysqlDb {
    async fn execute(&self, sql: &str) -> anyhow::Result<u64> {
        let res = sqlx::query(sql).execute(&self.pool).await?;
        Ok(res.rows_affected())
    }

    async fn fetch_all(&self, sql: &str) -> anyhow::Result<Vec<Vec<(String, Value)>>> {
        let rows = sqlx::query(sql).fetch_all(&self.pool).await?;
        let mut result = Vec::new();
        for row in rows {
            let mut r = Vec::new();
            for col in row.columns() {
                let val: Value = row.try_get(col.name())?;
                r.push((col.name().to_string(), val));
            }
            result.push(r);
        }
        Ok(result)
    }
}

// ================== Postgres 实现 ==================
pub struct PostgresDb {
    pool: PgPool,
}

#[async_trait]
impl DbExecutor for PostgresDb {
    async fn execute(&self, sql: &str) -> anyhow::Result<u64> {
        let res = sqlx::query(sql).execute(&self.pool).await?;
        Ok(res.rows_affected())
    }

    async fn fetch_all(&self, sql: &str) -> anyhow::Result<Vec<Vec<(String, Value)>>> {
        let rows = sqlx::query(sql).fetch_all(&self.pool).await?;
        let mut result = Vec::new();
        for row in rows {
            let mut r = Vec::new();
            for col in row.columns() {
                let val: Value = row.try_get(col.name())?;
                r.push((col.name().to_string(), val));
            }
            result.push(r);
        }
        Ok(result)
    }
}

// ================== DatabaseClient ==================
pub struct DatabaseClient {
    inner: DatabaseConfig,
}

impl DatabaseClient {
    pub fn new(inner: DatabaseConfig) -> Self {
        Self { inner }
    }

    pub async fn connect(&self) -> anyhow::Result<Box<dyn DbExecutor>> {
        match self.inner.db_type {
            DbType::Mysql => {
                let url = format!(
                    "mysql://{}:{}@{}:{}/{}",
                    self.inner.username,
                    self.inner.password,
                    self.inner.host,
                    self.inner.port,
                    self.inner.database
                );
                let pool = sqlx::mysql::MySqlPoolOptions::new()
                    .max_connections(self.inner.pool_size)
                    .min_connections(self.inner.pool_min_idle)
                    .idle_timeout(Duration::from_secs(self.inner.pool_idle_timeout))
                    .max_lifetime(Duration::from_secs(self.inner.pool_max_lifetime))
                    .connect(&url)
                    .await?;
                Ok(Box::new(MysqlDb { pool }))
            }
            DbType::Postgres => {
                let url = format!(
                    "postgres://{}:{}@{}:{}/{}?connect_timeout=5",
                    self.inner.username,
                    self.inner.password,
                    self.inner.host,
                    self.inner.port,
                    self.inner.database
                );
                let pool = sqlx::postgres::PgPoolOptions::new()
                    .max_connections(self.inner.pool_size)
                    .min_connections(self.inner.pool_min_idle)
                    .idle_timeout(Duration::from_secs(self.inner.pool_idle_timeout))
                    .max_lifetime(Duration::from_secs(self.inner.pool_max_lifetime))
                    .connect(&url)
                    .await?;
                Ok(Box::new(PostgresDb { pool }))
            }
        }
    }
}

```
