from fastapi import FastAPI

app = FastAPI(
    title="KisanSetu AI Engine",
    description="AI and Logistics services for KisanSetu",
    version="1.0.0"
)


@app.get("/")
def root():
    return {
        "success": True,
        "message": "KisanSetu AI Engine is running"
    }


@app.get("/health")
def health():
    return {
        "success": True,
        "service": "ai-engine",
        "status": "healthy"
    }