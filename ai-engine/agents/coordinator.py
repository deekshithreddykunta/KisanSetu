from agents.recommendation_agent import RecommendationAgent


class AICoordinator:

    def __init__(self):

        self.agent = RecommendationAgent()

    def process(self, data):

        return self.agent.recommend(
            current_price=data["current_price"],
            historical_demand=data["historical_demand"],
            temperature=data["temperature"],
            rainfall=data["rainfall"],
            supply=data["supply"]
        )