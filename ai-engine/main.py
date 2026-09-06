from fastapi import FastAPI

from models.schemas import (
    PriceRequest,
    DemandRequest,
    LogisticsRequest,
    MatchingRequest,
    RiskRequest,
    ShelfLifeRequest,
    WasteRequest,
    QualityRequest,
    FraudRequest,
    FertilizerRequest,
)

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


# ==========================================
# FASTAPI APPLICATION
# ==========================================

app = FastAPI(
    title="KisanSetu AI Engine",
    description="AI Engine for KisanSetu Agriculture Platform",
    version="1.0.0",
)


# ==========================================
# AI MODULE INITIALIZATION
# ==========================================

price_predictor = PricePredictor()
demand_predictor = DemandPredictor()
logistics_optimizer = LogisticsOptimizer()
farmer_buyer_matcher = FarmerBuyerMatcher()
supply_risk_predictor = SupplyRiskPredictor()
shelf_life_predictor = ShelfLifePredictor()
waste_predictor = WastePredictor()
quality_analyzer = QualityAnalyzer()
fraud_detector = FraudDetector()
fertilizer_recommender = FertilizerRecommender()


# ==========================================
# HOME
# ==========================================

@app.get("/")
def home():

    return {
        "message": "KisanSetu AI Engine is running",
        "status": "success",
        "version": "1.0.0",
    }


# ==========================================
# HEALTH
# ==========================================

@app.get("/health")
def health():

    return {
        "status": "healthy"
    }


# ==========================================
# PRICE
# ==========================================

@app.post("/ai/price")
def predict_price(request: PriceRequest):

    price = price_predictor.predict(
        request.current_price
    )

    return {
        "crop": request.crop_name,
        "current_price": request.current_price,
        "recommended_price": price,
    }


# ==========================================
# DEMAND
# ==========================================

@app.post("/ai/demand")
def predict_demand(request: DemandRequest):

    prediction = demand_predictor.predict(
        request.historical_demand
    )

    return {
        "crop": request.crop_name,
        "predicted_demand": prediction,
    }


# ==========================================
# LOGISTICS
# ==========================================

@app.post("/ai/logistics")
def optimize_logistics(
    request: LogisticsRequest
):

    return logistics_optimizer.optimize(
        request.distance_km,
        request.quantity,
    )


# ==========================================
# MATCHING
# ==========================================

@app.post("/ai/matching")
def match_buyers(
    request: MatchingRequest
):

    return farmer_buyer_matcher.match(
        request.crop_name,
        request.quantity,
        request.buyer_locations,
        request.farmer_location,
    )


# ==========================================
# SUPPLY RISK
# ==========================================

@app.post("/ai/risk")
def predict_risk(request: RiskRequest):

    return supply_risk_predictor.predict(
        request.temperature,
        request.rainfall,
        request.demand,
        request.supply,
    )


# ==========================================
# SHELF LIFE
# ==========================================

@app.post("/ai/shelf-life")
def predict_shelf_life(
    request: ShelfLifeRequest
):

    return shelf_life_predictor.predict(
        request.crop_name,
        request.temperature,
        request.humidity,
    )


# ==========================================
# WASTE
# ==========================================

@app.post("/ai/waste")
def predict_waste(
    request: WasteRequest
):

    return waste_predictor.predict(
        request.crop_name,
        request.quantity,
        request.shelf_life_days,
    )


# ==========================================
# QUALITY
# ==========================================

@app.post("/ai/quality")
def analyze_quality(
    request: QualityRequest
):

    return quality_analyzer.analyze(
        request.crop_name,
        request.moisture,
        request.temperature,
    )


# ==========================================
# FRAUD
# ==========================================

@app.post("/ai/fraud")
def detect_fraud(
    request: FraudRequest
):

    return fraud_detector.detect(
        request.transaction_amount,
        request.transaction_count,
    )


# ==========================================
# FERTILIZER
# ==========================================

@app.post("/ai/fertilizer")
def recommend_fertilizer(
    request: FertilizerRequest
):

    return fertilizer_recommender.recommend(
        request.nitrogen,
        request.phosphorus,
        request.potassium,
        request.ph,
    )
