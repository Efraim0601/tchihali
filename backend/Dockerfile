FROM python:3.12-slim
ENV PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1
WORKDIR /srv
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app app
COPY migrations migrations
COPY seeds seeds
RUN useradd -r -u 10001 tchihali
USER tchihali
EXPOSE 8080
CMD ["sh", "-c", "python -m app.migrate && uvicorn app.main:app --host 0.0.0.0 --port 8080"]
