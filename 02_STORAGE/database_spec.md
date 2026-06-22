# 🗄️ Nexus Database Specification (ADS Project)

Este documento define o schema do Banco de Dados SQLite que servirá como o inventário central do ecossistema Nexus.

## Diagrama de Entidade-Relacionamento (DER)

O banco é normalizado para garantir integridade referencial através de Chaves Primárias (PK) e Chaves Estrangeiras (FK).

### 1. Tabela: `nodes`
Mapeia os dispositivos físicos/virtuais da rede.

```sql
CREATE TABLE nodes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,        -- UBIK, VALIS, PRIS, etc.
    ip_tailscale TEXT,                -- IP fixo na rede mesh.
    os_distro TEXT,                   -- Ubuntu 24.04, Mint, etc.
    role TEXT                         -- Workstation, Server, Media.
);
```

### 2. Tabela: `services`
Mapeia as aplicações e containers rodando em cada nó.

```sql
CREATE TABLE services (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    node_id INTEGER NOT NULL,         -- FK -> nodes.id
    name TEXT NOT NULL,               -- Nome do serviço (ex: Jellyfin).
    container_name TEXT,              -- Nome no Docker.
    port_host INTEGER,                -- Porta de acesso.
    external_url TEXT,                -- URL via Cloudflare (se houver).
    status TEXT DEFAULT 'unknown',    -- Up, Down, Maintenance.
    FOREIGN KEY (node_id) REFERENCES nodes(id) ON DELETE CASCADE
);
```

### 3. Tabela: `jd_areas`
Define as categorias de topo do Johnny.Decimal.

```sql
CREATE TABLE jd_areas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,        -- 00-09, 10-19, etc.
    name TEXT NOT NULL,               -- System, Work, Hobby.
    description TEXT
);
```

### 4. Tabela: `inventory_items`
O inventário dinâmico de arquivos e pastas.

```sql
CREATE TABLE inventory_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    area_id INTEGER,                  -- FK -> jd_areas.id
    name TEXT NOT NULL,               -- Nome do arquivo/pasta.
    physical_path TEXT NOT NULL UNIQUE, -- Caminho real no Almox.
    is_symlinked BOOLEAN DEFAULT 0,   -- Se possui atalho na Home.
    tags TEXT,                        -- Tags JSON para busca.
    last_indexed DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (area_id) REFERENCES jd_areas(id)
);
```

### 5. Tabela: `user_knowledge`
Onde a identidade "viva" e o conhecimento do usuário são armazenados.

```sql
CREATE TABLE user_knowledge (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category TEXT NOT NULL,      -- 'Cinema', 'Music', 'Tech', 'Art', etc.
    entity_name TEXT NOT NULL,   -- 'John Carpenter', 'Radiohead', 'Rust'.
    rating INTEGER DEFAULT 5,    -- Preferência (1-5).
    description TEXT,            -- Motivo da preferência ou notas.
    tags TEXT,                   -- JSON: ['Horror', '80s', 'Synth'].
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### 6. Tabela: `nexus_logs`
O diário de bordo (Changelog) automatizado do ecossistema.

```sql
CREATE TABLE nexus_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    node_id INTEGER,             -- FK -> nodes.id.
    action TEXT NOT NULL,        -- 'UPDATE_STACK', 'NEW_DIRECTOR', etc.
    description TEXT,            -- Detalhamento da mudança.
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (node_id) REFERENCES nodes(id) ON DELETE SET NULL
);
```

---

## 🛠️ Mecanismo de Atualização (The "Live" Factor)

Para manter o banco sincronizado com o sistema de arquivos, utilizaremos o **`inotify-tools`** em conjunto com um script Python (`nexus-sync.py`).

1.  **Monitoramento:** O script monitora `/mnt/almox/JD` recursivamente.
2.  **Eventos:**
    *   `CREATE / MOVED_TO`: Dispara um `INSERT` ou `UPDATE` no banco.
    *   `DELETE / MOVED_FROM`: Marca o item como removido ou o deleta do banco.
3.  **Auditoria:** Uma tarefa agendada (Cron) realiza um "Deep Scan" semanal para garantir que nada foi perdido por falhas de monitoramento.
