from fastapi import FastAPI

from pricing.price_predictor import PricePredictor
from demand.demand_predictor import DemandPredictor
from logistics.route_optimizer import LogisticsOptimizer
from matching.farmer_buyer_matcher import FarmerBuyerMatcher
from supply_risk.risk_predictor import SupplyRiskPredictor
from shelf_life.shelf_life_predictor import ShelfLifePredictor
from waste.waste_predictor import WastePredictor
from quality.quality_analyzer import QualityAnalyzer
from fraud.fraud_detector import FraudDetector
from fertilizer.fertilizer_recommender import FertilizerRecommender

from models.schemas import (
    PriceRequest,
    DemandRequest,
    MatchingRequest,
    LogisticsRequest,
    RiskRequest
)

app = FastAPI(
    title="KisanSetu AI Engine",
    version="1.0.0"
)


price_predictor = PricePredictor()
demand_predictor = DemandPredictor()
logistics_optimizer = LogisticsOptimizer()
matcher = FarmerBuyerMatcher()
risk_predictor = SupplyRiskPredictor()
shelf_predictor = ShelfLifePredictor()
waste_predictor = WastePredictor()
quality_analyzer = QualityAnalyzer()
fraud_detector = FraudDetector()
fertilizer_recommender = FertilizerRecommender()


@app.get("/")
def home():

    return {
        "message": "KisanSetu AI Engine is running"
    }


@app.post("/ai/price")
def predict_price(request: PriceRequest):

    price = price_predictor.predict(
        request.current_price
    )

    return {
        "crop": request.crop_name,
        "current_price": request.current_price,
        "recommended_price": price
    }


@app.post("/ai/demand")
def predict_demand(request: DemandRequest):

    prediction = demand_predictor.predict(
        request.historical_demand
    )

    return {
        "crop": request.crop_name,
        "predicted_demand": prediction
    }


@app.post("/ai/logistics")
def optimize_logistics(request: LogisticsRequest):

    return logistics_optimizer.optimize(
        request.distance_km,
        request.quantity
    )


@app.post("/ai/matching")
def match_buyers(request: MatchingRequest):

    return matcher.match(
        request.crop_name,
        request.quantity,
        request.buyer_locations,
        request.farmer_location
    )


@app.post("/ai/risk")
def predict_risk(request: RiskRequest):

    return risk_predictor.predict(
        request.temperature,
        request.rainfall,
        request.demand,
        request.supply
    )


@app.get("/health")
def health():

    return {
        "status": "healthy"
    }