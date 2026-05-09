# main.py - Entry point of the Football Data Hub API
# This file initializes the FastAPI application and registers the routes

# Load environment variables from .env file
# This only applies in development, in production variables are set directly on the VM
from fastapi.middleware.cors import CORSMiddleware
from app.routes import espanha, uk
from fastapi import FastAPI
from dotenv import load_dotenv
load_dotenv()


# Create the FastAPI application instance
# title and description appear in the automatic Swagger documentation
app = FastAPI(
    title="Football Data Hub",
    description="API that provides real-time football data from Spain and UK leagues",
    version="1.0.0"
)

# Allow the frontend to call the API from the browser
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET"],
    allow_headers=["*"],
)


# Register the routes
# Each router groups related endpoints under a specific prefix
app.include_router(espanha.router, prefix="/liga-espanha", tags=["Spain"])
app.include_router(uk.router, prefix="/liga-uk", tags=["UK"])

# Health check endpoint
# Used by the Azure Load Balancer to verify if the application is running


@app.get("/health")
async def health_check():
    return {"status": "ok"}
