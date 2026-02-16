Workflows Pipelines

02 - CI + CD
Cómo lo demostrás en 20 segundos

Actions → 02 - CI + CD → Run workflow

Elegís:

release_name: release-002

target_env: qa

Run

Mostrás:

Job CI publica artefacto

Job CD descarga artefacto y “deploy” simulado

Summary ejecutivo en el run ✅

03 03 – Continuous Deployment

Configuración para que se vea “enterprise” (1 minuto)

Repo → Settings

Environments

New environment → production

Activá:

✅ Required reviewers (approvals)

Opcional: deployment branches / wait timer

Así cuando lo corras, se va a quedar “Waiting” hasta que apruebes → demo perfecta.

Cómo lo demostrás rápido

Actions → 03 - Continuous Deployment → Run workflow

release: release-004

change: CHG-1029

dry_run: false

Mostrás:

Approval gate (si está activo)

Deploy simulado

Summary ejecutivo
