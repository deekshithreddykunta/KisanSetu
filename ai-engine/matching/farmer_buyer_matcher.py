class FarmerBuyerMatcher:

    def match(
        self,
        crop_name,
        quantity,
        buyer_locations,
        farmer_location
    ):

        matches = []

        for location in buyer_locations:

            score = 0

            if location.lower() == farmer_location.lower():
                score += 100
            else:
                score += 50

            matches.append({
                "buyer_location": location,
                "crop": crop_name,
                "required_quantity": quantity,
                "match_score": score
            })

        matches.sort(
            key=lambda x: x["match_score"],
            reverse=True
        )

        return matches