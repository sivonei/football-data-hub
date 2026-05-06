# cache.py - Redis cache service
# Handles all cache operations to avoid hitting the external API rate limit

import json
import os
import redis.asyncio as redis

# Get Redis connection details from environment variables
# This avoids hardcoding credentials in the code
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))

# Create the Redis client
# decode_responses=True automatically converts bytes to strings
client = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)


async def get(key: str):
    """Get a value from cache by key. Returns None if key does not exist."""
    try:
        data = await client.get(key)
        if data:
            # Redis stores strings, so we convert back to Python dict
            return json.loads(data)
        return None
    except Exception:
        # If Redis is down, return None and let the app fetch from the API
        return None


async def set(key: str, value: dict, ttl: int = 3600):
    """Store a value in cache with an expiration time in seconds."""
    try:
        # Convert Python dict to string before storing in Redis
        await client.setex(key, ttl, json.dumps(value))
    except Exception:
        # If Redis is down, skip caching silently
        # The app will still work, just without cache
        pass
