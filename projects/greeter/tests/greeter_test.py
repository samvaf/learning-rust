import sys

import pytest

from greeter import greet


def test_greet():
    assert greet("world") == "Hello, world!"


if __name__ == "__main__":
    sys.exit(pytest.main([__file__, "-vv"]))
