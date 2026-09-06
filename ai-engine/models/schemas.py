from typing import List

from pydantic import BaseModel, Field




class PriceRequest(BaseModel):
    crop_name: str = Field(..., min_length=1)
    current_price: float = Field(..., ge=0)




class DemandRequest(BaseModel):
    crop_name: str = Field(..., min_length=1)
    historical_demand: List[float] = Field(..., min_length=1)




class LogisticsRequest(BaseModel):
    distance_km: float = Field(..., ge=0)
    quantity: float = Field(..., ge=0)




class MatchingRequest(BaseModel):
    crop_name: str = Field(..., min_length=1)
    quantity: float = Field(..., ge=0)
    buyer_locations: List[str] = Field(..., min_length=1)
    farmer_location: str = Field(..., min_length=1)



class RiskRequest(BaseModel):
    temperature: float
    rainfall: float = Field(..., ge=0)
    demand: float = Field(..., ge=0)
    supply: float = Field(..., ge=0)




class ShelfLifeRequest(BaseModel):
    crop_name: str = Field(..., min_length=1)
    temperature: float
    humidity: float = Field(..., ge=0, le=100)




class WasteRequest(BaseModel):
    crop_name: str = Field(..., min_length=1)
    quantity: float = Field(..., ge=0)
    shelf_life_days: float = Field(..., ge=0)




class QualityRequest(BaseModel):
    crop_name: str = Field(..., min_length=1)
    moisture: float = Field(..., ge=0)
    temperature: float




class FraudRequest(BaseModel):
    transaction_amount: float = Field(..., ge=0)
    transaction_count: int = Field(..., ge=0)


class FertilizerRequest(BaseModel):
    nitrogen: float = Field(..., ge=0)
    phosphorus: float = Field(..., ge=0)
    potassium: float = Field(..., ge=0)
    ph: float = Field(..., ge=0, le=14)
