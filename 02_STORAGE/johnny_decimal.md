# 📂 Johnny.Decimal (Nexus Storage System)

O Nexus utiliza o sistema **Johnny.Decimal** para organização de arquivos, garantindo que cada item tenha um endereço único e lógico.

## Estrutura de Áreas (Unificada Março/2026)

| Área | Nome | Descrição |
| :--- | :--- | :--- |
| **00-09** | **System & Core** | Nodes (UBIK, VALIS, PRIS), Arquitetura, Git de Docs, Memória IA. |
| **10-19** | **Life Admin** | Pessoal, Família (Tefa, Vicente), Finanças, Saúde, Casa. |
| **20-29** | **Work (IIVA)** | Gestão de aulas, Materiais Pedagógicos, Relatórios de Alunos. |
| **30-39** | **Tech & ADS** | Estudos da Faculdade (ADS), Projetos de Dev, Scripts, GitHub. |
| **40-49** | **Creative Legacy** | 20 anos de Ilustração, Commissions, Cinema, Publicidade. |
| **50-59** | **Hobby & Soul** | Música, Horror, Lazer, Filmes, Games. |
| **90-99** | **Inbox** | Entrada temporária de arquivos não processados. |

---

## 🛠️ Política de Armazenamento (Tiered Storage)

Para otimizar a performance e facilitar a manutenção (Distro-hopping), o UBIK segue estas regras:

1.  **Tier 1 (SSD Sistema - sda2):** Apenas o SO e binários. Mantido "Stateless" (sem dados de usuário).
2.  **Tier 2 (SSD Home - sdc1):** SSD de 256GB. Contém a Home padrão, Dotfiles e Projetos de Desenvolvimento ativos (para compilação rápida).
3.  **Tier 3 (HDD Almox - sdb1):** HDD de 1TB. A **Morada Final** de todos os dados JD. 

### Regra de Acesso:
Sempre que um arquivo ou pasta do **Tier 3** for necessário para uso frequente no **Tier 2** (ex: pasta de documentos ou projetos), deve-se usar um **link simbólico** (`ln -s`).

**Exemplo:**
`~/Documents/IIVA-classes` ➔ `/mnt/almox/JD/20-29 Work/...`

---

## 🗄️ Database de Inventário (Em Planejamento)
O próximo passo é substituir a manutenção manual desta estrutura por um **Banco de Dados SQLite** reativo via `inotify`.
