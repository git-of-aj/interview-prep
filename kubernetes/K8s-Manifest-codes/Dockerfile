FROM python:3.14.6-alpine3.23  

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY v1-api.py .

CMD ["uvicorn", "v1-api:app", "--host", "0.0.0.0", "--port", "8000"]