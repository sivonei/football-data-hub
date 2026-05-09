#!/bin/bash
# dev.sh - Script to start the local development environment

echo "Starting development environment..."

cd api
source .venv/bin/activate

echo "Running tests..."
pytest tests/ -v

# Stop if any test fails
if [ $? -ne 0 ]; then
    echo "Tests failed. Fix the errors before starting the server."
    exit 1
fi

echo "All tests passed. Starting FastAPI server..."
uvicorn app.main:app --reload