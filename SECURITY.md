# Security Policy

## Protected Health Information (PHI)

This repository contains code for analyzing Cleveland Clinic patient data. **The data itself contains PHI and must NEVER be committed to version control.**

### What is excluded from this repository

The following are explicitly excluded via `.gitignore`:

- `data/` - Raw patient data
- `data-derived/` - Processed datasets  
- `output/models/` - Trained models (may memorize patient information)
- All data file formats: `.rds`, `.RDS`, `.rda`, `.RData`, `.csv`, `.xlsx`, `.sas7bdat`, `.dta`, `.sav`
- Credentials: `.Renviron`, `.env`, `*.pem`, `*.key`

### What IS safe to commit

- R code (`R/*.R`, `_targets.R`)
- Documentation (`docs/`, `README.md`)
- Configuration files (`renv.lock`, `.gitignore`)
- Report source files (`reports/*.qmd`, `reports/*.Rmd`)

### Before committing

Always run:
```bash
git status
```

And verify that NO data files are staged. If you see any `.rds`, `.csv`, or files from `data/` in the staged changes, **do not commit**.

### If PHI is accidentally committed

If patient data is ever accidentally committed:

1. **Do NOT push to remote**
2. Remove the file and amend the commit:
   ```bash
   git rm --cached <file>
   git commit --amend
   ```
3. If already pushed, contact IT Security immediately - the repository may need to be deleted and recreated
4. Report the incident per Cleveland Clinic data breach policies

## Credential Management

- Never hardcode database credentials or API keys in code
- Use `.Renviron` for sensitive environment variables (this file is gitignored)
- For production deployment, use institutional credential management systems

## Questions

Contact the project lead or Cleveland Clinic IT Security with any concerns about data handling.
