from pydantic import BaseModel
from typing import Optional


class PriceRequest(BaseModel):
    crop_name: str
    current_price: float
    quantity: float = 1


class DemandRequest(BaseModel):
    crop_name: str
    historical_demand: list[float]


class MatchingRequest(BaseModel):
    farmer_location: str
    crop_name: str
    quantity: float
    buyer_locations: list[str]


class LogisticsRequest(BaseModel):
    source: str
    destination: str
    quantity: float
    distance_km: float


class RiskRequest(BaseModel):
    crop_name: str
    temperature: float
    rainfall: float
    demand: float
    supply: float