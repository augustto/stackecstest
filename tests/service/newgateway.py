import requests
import pytest

def test_api_gateway_returns_200():
    # Substitua pela URL do seu API Gateway
    api_url = "https://ee1eayxfb9.execute-api.us-east-1.amazonaws.com/dev"
    
    response = requests.get(api_url)
    assert response.status_code == 200
    # Opcionalmente, verifique se o conteúdo é JSON
    assert "application/json" in response.headers.get("Content-Type", "")