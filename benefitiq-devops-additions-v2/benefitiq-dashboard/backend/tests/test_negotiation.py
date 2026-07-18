from app.schemas.schemas import NegotiateRequest
from app.services.negotiation import simulate_deal


def make_req(**kwargs):
    defaults = dict(duration_months=24, revenue_share_pct=18, tier_commitment=3, customer_coverage_pct=65)
    defaults.update(kwargs)
    return NegotiateRequest(**defaults)


def test_simulate_returns_valid_roi():
    result = simulate_deal(make_req())
    assert 0 < result.projected_roi_pct <= 40


def test_roi_capped_at_40():
    result = simulate_deal(make_req(duration_months=60, revenue_share_pct=35, tier_commitment=5, customer_coverage_pct=100))
    assert result.projected_roi_pct <= 40


def test_risk_score_in_range():
    result = simulate_deal(make_req())
    assert 0 <= result.risk_score <= 100


def test_breakeven_positive():
    result = simulate_deal(make_req())
    assert result.breakeven_months >= 1


def test_recommendation_strong_deal():
    result = simulate_deal(make_req(duration_months=60, revenue_share_pct=35, tier_commitment=5, customer_coverage_pct=100))
    assert "Strong deal" in result.recommendation
