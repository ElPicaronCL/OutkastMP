# sadie Quick Reference — OutkastMP Knowledge Queries

## Common Queries

### "What do we know about the Neon API for X?"
```bash
python3 .sadie/sadie.py search "<api or intent>"
python3 .sadie/sadie.py query "SELECT title, content FROM items WHERE category='neon' AND content LIKE '%<term>%' LIMIT 5"
```

### "What is the plan for the gamemode?"
```bash
python3 .sadie/sadie.py query "SELECT title, content FROM items WHERE category='gamemode' LIMIT 10"
```

### "What are the security/ACL rules?"
```bash
python3 .sadie/sadie.py query "SELECT title, content FROM items WHERE category='security'"
```

### "What changed recently?"
```bash
python3 .sadie/sadie.py query "SELECT title, source_file FROM items WHERE item_type='vault_note' ORDER BY id DESC LIMIT 10"
git log --oneline -10
```

### "Is there a recorded gotcha about this?"
```bash
python3 .sadie/sadie.py gotchas
```

## Maintenance

```bash
python3 .sadie/sadie.py init            # reindex .serena, skills, commands, memory-bank
python3 .sadie/sadie_vault_sync.py      # sync docs/ vault
python3 .sadie/sadie.py stats           # item counts and health
python3 .sadie/sadie.py locations       # registered paths
```

Reindex after changing `.serena/memories/`, `.opencode/skills/`, or `memory-bank/`.
Vault sync is idempotent (hash-based).
