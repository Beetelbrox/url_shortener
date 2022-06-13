ARG POETRY_VERSION=1.1.13

FROM python:3.9@sha256:d88a0a58aeaa7e72b518fedb2b41c247587afd9f00105143c103cf37d7c29ef4 AS build
ARG POETRY_VERSION
WORKDIR /usr/app
RUN pip install "poetry==${POETRY_VERSION}" \
    && python -m venv /usr/app/venv

COPY pyproject.toml poetry.lock ./
RUN poetry export -f requirements.txt | /usr/app/venv/bin/pip install -r /dev/stdin

COPY src/ ./src
RUN poetry build \
    && /usr/app/venv/bin/pip install dist/*.whl

FROM python:3.9-slim AS final

RUN groupadd app && useradd -r -g app app
COPY --chown=app:app --from=build /usr/app/venv /usr/app/venv
ENV PATH="/usr/app/venv/bin:${PATH}"

USER app
HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 CMD curl -f https://localhost:8000/health

ENTRYPOINT ["gunicorn", "url_shortener.app:app", "-b", "0.0.0.0:8000", "-k", "uvicorn.workers.UvicornWorker"]