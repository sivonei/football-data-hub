# uk.py - Route handler for the UK league endpoint
# Handles requests to /liga-uk and returns Premier League data

from fastapi import APIRouter, HTTPException
from app.services import football, cache

# APIRouter groups related endpoints together
# This router is registered in main.py with the prefix /liga-uk
router = APIRouter()


@router.get("/tabela")
async def get_tabela_uk():
    """Returns the current Premier League standings."""

    # Try to get data from cache first to avoid hitting the API rate limit
    cached = await cache.get("uk:tabela")
    if cached:
        return cached

    # If not cached, fetch from the external API
    data = await football.get_standings(league="PL")
    if not data:
        raise HTTPException(
            status_code=503, detail="Failed to fetch data from football API")

    # Store in cache with TTL of 1 hour (standings dont change mid-game)
    await cache.set("uk:tabela", data, ttl=3600)

    return data


@router.get("/jogos")
async def get_jogos_uk():
    """Returns upcoming and recent matches for the Premier League."""

    # Try cache first
    cached = await cache.get("uk:jogos")
    if cached:
        return cached

    # Fetch from external API
    data = await football.get_matches(league="PL")
    if not data:
        raise HTTPException(
            status_code=503, detail="Failed to fetch data from football API")

    # Cache for 15 minutes (matches update more frequently than standings)
    await cache.set("uk:jogos", data, ttl=900)

    return data
