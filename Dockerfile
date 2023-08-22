FROM python:3.11-slim

LABEL "maintainer" "Dustin Ingram <di@python.org>"
LABEL "repository" "https://github.com/di/gh-action-build"
LABEL "homepage" "https://github.com/di/gh-action-build"

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

ENV PIP_NO_CACHE_DIR 1
ENV PIP_ROOT_USER_ACTION ignore

ENV PATH "/root/.local/bin:${PATH}"
ENV PYTHONPATH "/root/.local/lib/python3.11/site-packages"

COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

WORKDIR /app
COPY LICENSE .
COPY build.sh .

RUN chmod +x build.sh
ENTRYPOINT ["/app/build.sh"]
