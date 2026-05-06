# football.py - External football API service
# Handles all communication with the Football-Data.org API

import os
import httpx

BASE_URL = "https://api.football-data.org/v4"


def get_api_key() -> str:
    """Reads the API key from environment variables at request time."""
    return os.getenv("FOOTBALL_API_KEY", "")


async def get_standings(league: str) -> dict | None:
    """
    Fetch current standings for a given league.
    League codes: PD = La Liga, PL = Premier League
    """
    try:
        # Build headers here so the key is read after dotenv loads
        headers = {"X-Auth-Token": get_api_key()}

        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{BASE_URL}/competitions/{league}/standings",
                headers=headers
            )
            response.raise_for_status()
            return response.json()

    except httpx.HTTPStatusError as e:
        # API returned an error response (ex: 429 rate limit exceeded)
        print(
            f"Football API error for standings [{league}]: {e.response.status_code}")
        return None

    except Exception as e:
        # Network error or any other unexpected error
        print(f"Unexpected error fetching standings [{league}]: {e}")
        return None


async def get_matches(league: str) -> dict | None:
    """
    Fetch upcoming and recent matches for a given league.
    League codes: PD = La Liga, PL = Premier League
    """
    try:
        headers = {"X-Auth-Token": get_api_key()}

        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{BASE_URL}/competitions/{league}/matches",
                headers=headers
            )
            response.raise_for_status()
            return response.json()

    except httpx.HTTPStatusError as e:
        print(
            f"Football API error for matches [{league}]: {e.response.status_code}")
        return None

    except Exception as e:
        print(f"Unexpected error fetching matches [{league}]: {e}")
        return None
