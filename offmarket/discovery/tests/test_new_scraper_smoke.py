"""Smoke test: every scraper module imports cleanly and returns a list when
its network calls are stubbed. Catches syntax errors, import errors, and
obvious crashes in agent-generated scrapers BEFORE they're committed.
"""
from __future__ import annotations

import importlib
import inspect
import pkgutil

import pytest

import offmarket.discovery.scrapers as scrapers_pkg

# Discover every concrete scraper module under offmarket.discovery.scrapers.
SCRAPER_MODULES = [
    name
    for _, name, ispkg in pkgutil.iter_modules(scrapers_pkg.__path__)
    if not ispkg and not name.startswith("_")
]

# Sanity: at least one scraper got discovered.
assert SCRAPER_MODULES, "No scraper modules discovered under offmarket.discovery.scrapers"


def _stub_get(*args, **kwargs):  # noqa: ARG001 — drop-in signature for base.get
    return "<html><body></body></html>"


@pytest.mark.parametrize("module_name", SCRAPER_MODULES)
def test_scraper_imports_and_runs(module_name, monkeypatch):
    """Each scraper module imports and every scrape* function returns a list."""
    mod = importlib.import_module(f"offmarket.discovery.scrapers.{module_name}")

    # Stub network: each scraper imports `get` at module scope, so patch the
    # name on the scraper module itself. Also patch the source on base in
    # case some helper resolves it dynamically.
    if hasattr(mod, "get"):
        monkeypatch.setattr(mod, "get", _stub_get)
    monkeypatch.setattr("offmarket.discovery.base.get", _stub_get)

    # Make politeness sleeps instant.
    import time as _time
    monkeypatch.setattr(_time, "sleep", lambda *_a, **_kw: None)

    scrape_funcs = [
        (name, fn)
        for name, fn in inspect.getmembers(mod, inspect.isfunction)
        if name.startswith("scrape") and fn.__module__ == mod.__name__
    ]
    assert scrape_funcs, f"{module_name} has no scrape* functions"

    for fn_name, fn in scrape_funcs:
        sig = inspect.signature(fn)
        kwargs: dict = {}
        # Pass an unmatched state code when the function accepts a `states`
        # kwarg — keeps slug-mapped scrapers (rvparkstore, landwatch, ...)
        # from iterating every state on the stubbed HTML.
        if "states" in sig.parameters:
            kwargs["states"] = ["XX"]
        # Cap pagination knobs if they exist, to be fast even if the stub
        # ever returns something parseable.
        for cap_param in ("max_pages", "max_pages_per_state", "max_listings"):
            if cap_param in sig.parameters:
                kwargs[cap_param] = 1
        # Disable detail fetching when offered.
        if "fetch_details" in sig.parameters:
            kwargs["fetch_details"] = False

        try:
            result = fn(**kwargs)
        except Exception as exc:  # pragma: no cover - failure path
            pytest.fail(f"{module_name}.{fn_name} crashed: {exc!r}")

        assert isinstance(result, list), (
            f"{module_name}.{fn_name} returned {type(result).__name__}, expected list"
        )
