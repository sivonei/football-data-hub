# espanha.py - Route handler for the Spanish league endpoint
# Handles requests to /liga-espanha and returns league data

from fastapi import APIRouter, HTTPException
from app.services import football, cache

# APIRouter groups related endpoints together
# This router is registered in main.py with the prefix /liga-espanha
router = APIRouter()


@router.get("/tabela")
async def get_tabela_espanha():
    """Returns the current Spanish league standings."""

    # Try to get data from cache first to avoid hitting the API rate limit
    cached = await cache.get("espanha:tabela")
    if cached:
        return cached

    # If not cached, fetch from the external API
    data = await football.get_standings(league="PD")
    if not data:
        raise HTTPException(
            status_code=503, detail="Failed to fetch data from football API")

    # Store in cache with TTL of 1 hour (standings dont change mid-game)
    await cache.set("espanha:tabela", data, ttl=3600)

    return data


@router.get("/jogos")
async def get_jogos_espanha():
    """Returns upcoming and recent matches for the Spanish league."""

    # Try cache first
    cached = await cache.get("espanha:jogos")
    if cached:
        return cached

    # Fetch from external API
    data = await football.get_matches(league="PD")
    if not data:
        raise HTTPException(
            status_code=503, detail="Failed to fetch data from football API")

    # Cache for 15 minutes (matches update more frequently than standings)
    await cache.set("espanha:jogos", data, ttl=900)

    return data
