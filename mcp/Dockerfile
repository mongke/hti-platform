# Base image pinned by digest; every Python package pinned by version AND hash (2026-10-14).
FROM python@sha256:05cda9777409a9c3ffddd94a4c476b79f0769a0b4857f0c7ed9226b6800b0d6f
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir --require-hashes --no-deps -r /tmp/requirements.txt && rm /tmp/requirements.txt
WORKDIR /app
COPY server.py kpis.py auth.py sqlcheck.py apikeys.py /app/
# Analytics allowlist, public KPI records and the tools documentation - ONLY these three.
# Internal notes, builders and the full dictionary stay out of the image (2026-10-14).
COPY catalog/datasets.json catalog/kpi_public.json catalog/TOOLS.md /app/catalog/
RUN mkdir -p /data && chown 65534:65534 /data
USER 65534
ENV PYTHONDONTWRITEBYTECODE=1
CMD ["python", "/app/server.py"]
