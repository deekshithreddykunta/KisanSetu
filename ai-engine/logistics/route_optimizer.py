class LogisticsOptimizer:

    def estimate_cost(
        self,
        distance_km,
        quantity,
        cost_per_km=10,
        capacity=1000
    ):

        trips = max(
            1,
            (quantity + capacity - 1) // capacity
        )

        cost = (
            distance_km
            * cost_per_km
            * trips
        )

        return round(cost, 2)

    def optimize(
        self,
        distance_km,
        quantity
    ):

        cost = self.estimate_cost(
            distance_km,
            quantity
        )

        return {
            "distance_km": distance_km,
            "quantity": quantity,
            "estimated_cost": cost
        }