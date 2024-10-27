# Use Python 3.12 slim image as the base
FROM python:3.12-slim

# Set environment variables
ENV DJANGO_ALLOWED_HOSTS=*
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /app

# Install system dependencies required for psycopg2 and other packages
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files into the container
COPY . .

# Collect static files
RUN python manage.py collectstatic --noinput

# Expose the port that the application will run on
EXPOSE 8000

# Run Django with gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "--timeout", "120", "mysite.wsgi:application"]
