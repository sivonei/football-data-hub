# test_routes.py - Tests for the Football Data Hub API endpoints
# Run with: pytest tests/ -v

import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app


# pytest.mark.asyncio tells pytest this is an async test function
@pytest.mark.asyncio
async def test_health_check():
    """Test that the health check endpoint returns 200 and status ok."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


@pytest.mark.asyncio
async def test_liga_espanha_tabela_returns_200_or_503():
    """
    Test that the Spanish league standings endpoint responds correctly.
    Returns 200 if the external API is available, 503 if not.
    Both are valid responses depending on the environment.
    """
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/liga-espanha/tabela")

    assert response.status_code in [200, 503]


@pytest.mark.asyncio
async def test_liga_espanha_jogos_returns_200_or_503():
    """Test that the Spanish league matches endpoint responds correctly."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/liga-espanha/jogos")

    assert response.status_code in [200, 503]


@pytest.mark.asyncio
async def test_liga_uk_tabela_returns_200_or_503():
    """Test that the UK league standings endpoint responds correctly."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/liga-uk/tabela")

    assert response.status_code in [200, 503]


@pytest.mark.asyncio
async def test_liga_uk_jogos_returns_200_or_503():
    """Test that the UK league matches endpoint responds correctly."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/liga-uk/jogos")

    assert response.status_code in [200, 503]


@pytest.mark.asyncio
async def test_invalid_endpoint_returns_404():
    """Test that an unknown endpoint returns 404."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/endpoint-que-nao-existe")

    assert response.status_code == 404
